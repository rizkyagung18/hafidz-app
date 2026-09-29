"""Synthetic tests for ayah retrieval and disambiguation."""

from __future__ import annotations

import math
from collections import defaultdict
from typing import Any

import numpy as np
import pytest
from app.matching.matcher import QuranMatcher
from app.matching.normalize import normalize_ar
from sklearn.feature_extraction.text import TfidfVectorizer


def _unit(
    unit_id: int,
    surah: int,
    start: int,
    texts: tuple[str, ...],
    kind: str = "single",
) -> dict[str, Any]:
    normalized = [normalize_ar(text) for text in texts]
    offsets: list[int] = []
    cursor = 0
    for text in normalized:
        offsets.append(cursor)
        cursor += len(text) + 1
    combined = " ".join(normalized)
    offsets.append(len(combined))
    return {
        "unit_id": unit_id,
        "kind": kind,
        "surah": surah,
        "ayah_start": start,
        "ayah_end": start + len(texts) - 1,
        "text_norm_A": combined,
        "text_norm_B": combined,
        "char_offsets_A": offsets,
        "char_offsets_B": offsets,
    }


def _make_matcher() -> QuranMatcher:
    # These are deliberately invented Arabic-like strings, not Qur'an quotations.
    ayahs = [
        (2, 1, "سما نور هدى علم رحمة"),
        (2, 255, "باب علم نور طريق رحمة كريم"),
        (2, 256, "سلام هدى كتاب حق واضح"),
        (2, 282, "قلم دفتر شاهد عدل دين اجل معلوم"),
        (55, 13, "فضل رب كريم"),
        (55, 16, "فضل رب كريم"),
        (1, 1, "فاتحة بداية طريق"),
        (3, 1, "سما نور هدى علم رحمة"),
        (4, 1, "طريق كتاب عدل سلام"),
        (5, 1, "قلم شاهد باب كريم"),
        (6, 1, "دفتر اجل طريق واضح"),
    ]
    units = [_unit(i, surah, ayah, (text,)) for i, (surah, ayah, text) in enumerate(ayahs)]
    by_key = {(surah, ayah): text for surah, ayah, text in ayahs}
    window = _unit(len(units), 2, 255, (by_key[(2, 255)], by_key[(2, 256)]), "window_2")
    units.append(window)
    units.append(_unit(len(units), 2, 1, ("الف لام ميم",), "muqattaat_alias"))
    vectorizer = TfidfVectorizer(
        analyzer="char_wb", ngram_range=(3, 3), sublinear_tf=True, dtype=np.float32
    )
    matrix = vectorizer.fit_transform(
        [f"{unit['text_norm_A']}\n{unit['text_norm_B']}" for unit in units]
    )
    postings: defaultdict[str, list[int]] = defaultdict(list)
    frequencies: defaultdict[str, int] = defaultdict(int)
    for unit in units:
        for word in set(str(unit["text_norm_A"]).split()):
            postings[word].append(int(unit["unit_id"]))
            frequencies[word] += 1
    idf = {
        word: math.log((1 + len(units)) / (1 + count)) + 1.0 for word, count in frequencies.items()
    }
    return QuranMatcher(
        {
            "units": units,
            "vectorizer": vectorizer,
            "char_tfidf": matrix,
            "word_to_units": dict(postings),
            "word_idf": idf,
        }
    )


@pytest.fixture
def matcher() -> QuranMatcher:
    return _make_matcher()


def test_exact_ayah_returns_single_ayah(matcher: QuranMatcher) -> None:
    result = matcher.match("قلم دفتر شاهد عدل دين اجل معلوم")

    assert result.best is not None
    assert result.best.key == "2:282"


def test_partial_long_ayah_returns_ayah_282(matcher: QuranMatcher) -> None:
    result = matcher.match("شاهد عدل دين اجل معلوم")

    assert result.best is not None
    assert result.best.key == "2:282"


def test_two_ayah_query_resolves_to_two_ayah_window(matcher: QuranMatcher) -> None:
    result = matcher.match("باب علم نور طريق رحمة كريم سلام هدى كتاب حق واضح")

    assert result.best is not None
    assert result.best.key == "2:255-256"


def test_thirty_percent_character_corruption_keeps_target_top_one(
    matcher: QuranMatcher,
) -> None:
    original = "قلم دفتر شاهد عدل دين اجل معلوم"
    corrupted: list[str] = []
    arabic_index = 0
    for character in original:
        if character.isspace():
            corrupted.append(character)
            continue
        if arabic_index % 3 == 0:
            corrupted.append("ث" if character != "ث" else "ز")
        else:
            corrupted.append(character)
        arabic_index += 1
    assert (
        sum(left != right for left, right in zip(original, corrupted, strict=True))
        / len(original.replace(" ", ""))
        >= 0.30
    )
    result = matcher.match("".join(corrupted))

    assert result.best is not None
    assert result.best.key == "2:282"


def test_repeated_refrain_is_ambiguous(matcher: QuranMatcher) -> None:
    result = matcher.match("فضل رب كريم")

    assert result.best is not None
    assert result.best.key in {"55:13", "55:16"}
    assert result.ambiguous
    assert result.reason == "identical_ayat"


def test_basmala_only_is_reported_without_normal_matching(matcher: QuranMatcher) -> None:
    result = matcher.match("بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ")

    assert result.reason == "basmala_only"
    assert result.best is not None
    assert result.best.key == "1:1"


def test_muqattaat_alias_matches_alif_lam_meem_candidate(matcher: QuranMatcher) -> None:
    result = matcher.match("الف لام ميم")

    assert result.best is not None
    assert "2:1" in {candidate.key for candidate in result.candidates}


@pytest.mark.parametrize(
    ("kwargs", "message"),
    [
        ({"hint_surah": 0}, "hint_surah"),
        ({"asr_quality": 1.1}, "asr_quality"),
        ({"max_candidates": 6}, "max_candidates"),
    ],
)
def test_rejects_invalid_match_options(
    matcher: QuranMatcher, kwargs: dict[str, object], message: str
) -> None:
    with pytest.raises(ValueError, match=message):
        matcher.match("قلم دفتر شاهد", **kwargs)  # type: ignore[arg-type]


def test_single_word_is_too_short(matcher: QuranMatcher) -> None:
    result = matcher.match("كريم")

    assert result.best is None
    assert result.reason == "too_short"
