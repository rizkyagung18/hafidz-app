"""Deterministic fuzzy matching from an Arabic transcript to Quran ayah ranges."""

from __future__ import annotations

import math
from collections import Counter
from collections.abc import Mapping, Sequence
from dataclasses import dataclass
from typing import Any, Literal

import numpy as np
from rapidfuzz import fuzz
from sklearn.metrics.pairwise import cosine_similarity  # type: ignore[import-untyped]

from app.matching.normalize import cleanup_query

MatchReason = Literal["too_short", "basmala_only", "identical_ayat", "low_confidence"]

MAX_RETRIEVED_UNITS = 50
MAX_ALIGNMENT_UNITS = 60
MIN_COVERED_AYAH_RATIO = 0.30
MIN_COVERED_AYAH_CHARS = 12
MIN_ALIGNMENT_WINDOW = 0.02
SHORT_QUERY_WORDS = 4
SHORT_QUERY_CONFIDENCE_CAP = 0.79


@dataclass(frozen=True, slots=True)
class MatchThresholds:
    """Decision thresholds returned to clients rather than duplicated in the app."""

    auto: float = 0.80
    min: float = 0.55
    margin: float = 0.10


DEFAULT_THRESHOLDS = MatchThresholds()


@dataclass(frozen=True, slots=True)
class MatchCandidate:
    """A resolved Quran location and its separate ranking signals."""

    surah: int
    ayah_start: int
    ayah_end: int
    score: float
    alignment: float
    tfidf: float

    @property
    def key(self) -> str:
        if self.ayah_start == self.ayah_end:
            return f"{self.surah}:{self.ayah_start}"
        return f"{self.surah}:{self.ayah_start}-{self.ayah_end}"


@dataclass(frozen=True, slots=True)
class MatchResult:
    """Best candidate, ranked alternatives, confidence, and disambiguation metadata."""

    best: MatchCandidate | None
    candidates: tuple[MatchCandidate, ...]
    confidence: float
    margin: float
    ambiguous: bool
    reason: MatchReason | None
    thresholds: MatchThresholds = DEFAULT_THRESHOLDS


@dataclass(frozen=True, slots=True)
class _ResolvedCandidate:
    match: MatchCandidate
    normalized_span: str


class QuranMatcher:
    """Reuse a verified F04 retrieval index to find and rank ayah ranges."""

    def __init__(
        self,
        index: Mapping[str, Any],
        thresholds: MatchThresholds = DEFAULT_THRESHOLDS,
    ) -> None:
        self._units: Sequence[Mapping[str, Any]] = index["units"]
        self._vectorizer: Any = index["vectorizer"]
        self._char_tfidf: Any = index["char_tfidf"]
        self._word_to_units: Mapping[str, Sequence[int]] = index["word_to_units"]
        self._word_idf: Mapping[str, float] = index["word_idf"]
        self.thresholds = thresholds

        if not self._units:
            raise ValueError("Quran search index contains no units.")
        if self._char_tfidf.shape[0] != len(self._units):
            raise ValueError("Quran search index TF-IDF rows do not match unit count.")
        for row, unit in enumerate(self._units):
            if int(unit["unit_id"]) != row:
                raise ValueError("Quran search index unit IDs must match TF-IDF row positions.")
        idf_values = np.fromiter(self._word_idf.values(), dtype=np.float64)
        if idf_values.size == 0:
            raise ValueError("Quran search index has no word IDF values.")
        self._rare_word_cutoff = float(np.percentile(idf_values, 90))

    def match(
        self,
        transcript: str,
        *,
        hint_surah: int | None = None,
        asr_quality: float = 1.0,
        max_candidates: int = 5,
    ) -> MatchResult:
        """Match ASR text to one or more ayat; normalized text is never returned."""
        if hint_surah is not None and not 1 <= hint_surah <= 114:
            raise ValueError("hint_surah must be between 1 and 114.")
        if not math.isfinite(asr_quality) or not 0.0 <= asr_quality <= 1.0:
            raise ValueError("asr_quality must be a finite value between 0 and 1.")
        if not 1 <= max_candidates <= 5:
            raise ValueError("max_candidates must be between 1 and 5.")

        cleaned = cleanup_query(transcript)
        query = cleaned.text
        words = query.split()
        if cleaned.basmala_only:
            return self._basmala_only_result()
        if len(words) < 2:
            return MatchResult(None, (), 0.0, 0.0, False, "too_short", self.thresholds)

        retrieved = self._retrieve(query, words)
        collapsed: dict[tuple[int, int, int], _ResolvedCandidate] = {}
        for unit_id, tfidf_score in retrieved:
            unit = self._units[unit_id]
            aligned = self._align_unit(
                query,
                unit,
                tfidf_score=tfidf_score,
                asr_quality=asr_quality,
                hint_surah=hint_surah,
            )
            if aligned is None:
                continue
            key = (aligned.match.surah, aligned.match.ayah_start, aligned.match.ayah_end)
            previous = collapsed.get(key)
            if previous is None or self._resolved_rank(aligned) > self._resolved_rank(previous):
                collapsed[key] = aligned

        if not collapsed:
            return MatchResult(None, (), 0.0, 0.0, False, "low_confidence", self.thresholds)

        resolved = list(collapsed.values())
        best_alignment = max(item.match.alignment for item in resolved)
        near_best = [
            item
            for item in resolved
            if item.match.alignment >= best_alignment - MIN_ALIGNMENT_WINDOW
        ]
        smallest_range = min(item.match.ayah_end - item.match.ayah_start + 1 for item in near_best)
        preferred = [
            item
            for item in near_best
            if item.match.ayah_end - item.match.ayah_start + 1 == smallest_range
        ]
        best = max(preferred, key=self._match_rank)

        distinct_alternatives = [
            item
            for item in resolved
            if item.match.key != best.match.key and not self._ranges_overlap(item.match, best.match)
        ]
        second_score = max((item.match.score for item in distinct_alternatives), default=0.0)
        margin = max(0.0, best.match.score - second_score)
        identical = any(
            item.match.key != best.match.key
            and not self._ranges_overlap(item.match, best.match)
            and item.normalized_span == best.normalized_span
            for item in resolved
        )
        confidence = best.match.score
        if identical:
            confidence = min(confidence, SHORT_QUERY_CONFIDENCE_CAP)
        if len(words) < SHORT_QUERY_WORDS:
            confidence = min(confidence, SHORT_QUERY_CONFIDENCE_CAP)
        ambiguous = identical or margin < self.thresholds.margin
        if identical:
            reason: MatchReason | None = "identical_ayat"
        elif confidence < self.thresholds.min or margin < self.thresholds.margin:
            reason = "low_confidence"
        else:
            reason = None

        ranked = sorted(resolved, key=self._match_rank, reverse=True)
        ordered_matches = [best.match]
        ordered_matches.extend(item.match for item in ranked if item.match.key != best.match.key)
        return MatchResult(
            best=best.match,
            candidates=tuple(ordered_matches[:max_candidates]),
            confidence=confidence,
            margin=margin,
            ambiguous=ambiguous,
            reason=reason,
            thresholds=self.thresholds,
        )

    def _retrieve(self, query: str, words: list[str]) -> list[tuple[int, float]]:
        query_vector = self._vectorizer.transform([query])
        similarities = np.asarray(
            cosine_similarity(query_vector, self._char_tfidf), dtype=np.float64
        ).reshape(-1)
        top_ids = np.argsort(-similarities, kind="stable")[:MAX_RETRIEVED_UNITS].tolist()
        scores = {int(unit_id): float(similarities[unit_id]) for unit_id in top_ids}

        rare_words = {
            word for word in set(words) if self._word_idf.get(word, 0.0) >= self._rare_word_cutoff
        }
        unit_frequency: Counter[int] = Counter()
        for word in rare_words:
            unit_frequency.update(int(unit_id) for unit_id in self._word_to_units.get(word, ()))
        rescue_ids = [
            unit_id
            for unit_id, count in unit_frequency.items()
            if count >= 2 and unit_id not in scores
        ]
        rescue_ids.sort(
            key=lambda unit_id: (
                -unit_frequency[unit_id],
                -similarities[unit_id],
                unit_id,
            )
        )
        for unit_id in rescue_ids[: max(0, MAX_ALIGNMENT_UNITS - len(scores))]:
            scores[unit_id] = float(similarities[unit_id])
        return sorted(scores.items(), key=lambda item: item[0])

    def _align_unit(
        self,
        query: str,
        unit: Mapping[str, Any],
        *,
        tfidf_score: float,
        asr_quality: float,
        hint_surah: int | None,
    ) -> _ResolvedCandidate | None:
        best_alignment: tuple[float, float, int, int, str, tuple[int, int]] | None = None
        for text_key, offsets_key in (
            ("text_norm_A", "char_offsets_A"),
            ("text_norm_B", "char_offsets_B"),
        ):
            variant = str(unit.get(text_key, ""))
            if not variant:
                continue
            alignment = fuzz.partial_ratio_alignment(query, variant)
            if alignment is None:
                continue
            span_start, span_end = int(alignment.dest_start), int(alignment.dest_end)
            if span_end <= span_start:
                continue
            normalized_span = variant[span_start:span_end]
            length_ratio = min(len(query), len(normalized_span)) / max(
                len(query), len(normalized_span)
            )
            adjusted_alignment = (float(alignment.score) / 100.0) * math.sqrt(
                max(0.6, min(1.0, length_ratio))
            )
            candidate_alignment = (
                adjusted_alignment,
                float(alignment.score),
                span_start,
                span_end,
                normalized_span,
                self._resolve_ayah_range(unit, offsets_key, span_start, span_end, len(variant)),
            )
            if candidate_alignment[5][0] <= 0:
                continue
            if best_alignment is None or candidate_alignment[:2] > best_alignment[:2]:
                best_alignment = candidate_alignment

        if best_alignment is None:
            return None
        alignment_score, _, _, _, normalized_span, ayah_range = best_alignment
        ayah_start, ayah_end = ayah_range
        surah = int(unit["surah"])
        score = (
            0.75 * alignment_score
            + 0.15 * max(0.0, min(1.0, tfidf_score))
            + 0.10 * asr_quality
            + (0.02 if hint_surah == surah else 0.0)
        )
        match = MatchCandidate(
            surah=surah,
            ayah_start=ayah_start,
            ayah_end=ayah_end,
            score=min(1.0, score),
            alignment=alignment_score,
            tfidf=max(0.0, min(1.0, tfidf_score)),
        )
        return _ResolvedCandidate(match, normalized_span)

    @staticmethod
    def _resolve_ayah_range(
        unit: Mapping[str, Any], offsets_key: str, span_start: int, span_end: int, text_length: int
    ) -> tuple[int, int]:
        unit_start = int(unit["ayah_start"])
        unit_end = int(unit["ayah_end"])
        ayah_count = unit_end - unit_start + 1
        offsets = [int(value) for value in unit.get(offsets_key, ())]
        if len(offsets) != ayah_count + 1:
            overlap = max(0, min(span_end, text_length) - max(span_start, 0))
            if overlap >= MIN_COVERED_AYAH_CHARS or overlap >= MIN_COVERED_AYAH_RATIO * text_length:
                return unit_start, unit_end
            return 0, 0

        covered: list[int] = []
        for index in range(ayah_count):
            ayah_text_start = offsets[index]
            ayah_text_end = offsets[index + 1]
            ayah_length = ayah_text_end - ayah_text_start
            overlap = max(0, min(span_end, ayah_text_end) - max(span_start, ayah_text_start))
            if overlap >= MIN_COVERED_AYAH_CHARS or (
                ayah_length > 0 and overlap >= MIN_COVERED_AYAH_RATIO * ayah_length
            ):
                covered.append(unit_start + index)
        if not covered:
            return 0, 0
        return min(covered), max(covered)

    def _basmala_only_result(self) -> MatchResult:
        # This is a routing hint only; never expose or reconstruct Qur'an text here.
        candidate = MatchCandidate(1, 1, 1, 0.0, 0.0, 0.0)
        return MatchResult(
            candidate,
            (candidate,),
            0.0,
            0.0,
            True,
            "basmala_only",
            self.thresholds,
        )

    @staticmethod
    def _resolved_rank(candidate: _ResolvedCandidate) -> tuple[float, float, float]:
        return (
            candidate.match.alignment,
            candidate.match.tfidf,
            candidate.match.score,
        )

    @staticmethod
    def _match_rank(candidate: _ResolvedCandidate) -> tuple[float, float, float, int, int, int]:
        match = candidate.match
        range_size = match.ayah_end - match.ayah_start + 1
        return (
            match.score,
            match.alignment,
            match.tfidf,
            -range_size,
            -match.surah,
            -match.ayah_start,
        )

    @staticmethod
    def _ranges_overlap(left: MatchCandidate, right: MatchCandidate) -> bool:
        return left.surah == right.surah and not (
            left.ayah_end < right.ayah_start or right.ayah_end < left.ayah_start
        )
