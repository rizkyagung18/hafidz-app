"""Pure metric calculations shared by the evaluation runner and tuner."""

from __future__ import annotations

import math
from collections import defaultdict
from collections.abc import Iterable, Mapping, Sequence
from typing import Any


def _ratio(numerator: int, denominator: int) -> float | None:
    return numerator / denominator if denominator else None


def range_covers(candidate: Mapping[str, Any] | None, surah: int, ayah: int) -> bool:
    return bool(
        candidate
        and int(candidate["surah"]) == surah
        and int(candidate["ayah_start"]) <= ayah <= int(candidate["ayah_end"])
    )


def is_auto_navigate(sample: Mapping[str, Any], *, auto: float, margin: float) -> bool:
    return (
        float(sample["confidence"]) >= auto
        and float(sample["margin"]) >= margin
        and not bool(sample["ambiguous"])
        and sample.get("best") is not None
    )


def decide(sample: Mapping[str, Any], *, auto: float, minimum: float, margin: float) -> str:
    """Mirror the mobile decision order from docs/03 §5.1."""
    if is_auto_navigate(sample, auto=auto, margin=margin):
        return "auto_navigate"
    if float(sample["confidence"]) >= minimum or bool(sample["ambiguous"]):
        return "picker"
    return "not_found"


def summarize_samples(
    samples: Sequence[Mapping[str, Any]],
    *,
    auto: float = 0.80,
    minimum: float = 0.55,
    margin: float = 0.10,
) -> dict[str, Any]:
    """Calculate accuracy and safety metrics without retaining transcript text."""
    groups: dict[str, list[Mapping[str, Any]]] = defaultdict(list)
    for sample in samples:
        groups[str(sample["condition"])].append(sample)
        if sample.get("length_bucket") is not None:
            groups[f"length:{sample['length_bucket']}"].append(sample)
    groups["overall"] = list(samples)
    return {
        name: _summarize_group(group, auto=auto, minimum=minimum, margin=margin)
        for name, group in sorted(groups.items())
    }


def _summarize_group(
    samples: Sequence[Mapping[str, Any]], *, auto: float, minimum: float, margin: float
) -> dict[str, Any]:
    positives = [sample for sample in samples if sample["condition"] != "negative"]
    negatives = [sample for sample in samples if sample["condition"] == "negative"]
    top1 = sum(
        range_covers(sample.get("best"), int(sample["surah"]), int(sample["ayah_start"]))
        for sample in positives
    )
    top3 = sum(
        any(
            range_covers(candidate, int(sample["surah"]), int(sample["ayah_start"]))
            for candidate in sample.get("candidates", [])[:3]
        )
        for sample in positives
    )
    spans = [sample for sample in positives if sample["condition"] == "span"]
    exact_ranges = sum(
        bool(
            sample.get("best")
            and int(sample["best"]["surah"]) == int(sample["surah"])
            and int(sample["best"]["ayah_start"]) == int(sample["ayah_start"])
            and int(sample["best"]["ayah_end"]) == int(sample["ayah_end"])
        )
        for sample in spans
    )
    wrong_auto = 0
    auto_count = 0
    correct_routes = 0
    latencies = sorted(float(sample["latency_ms"]) for sample in samples)
    for sample in samples:
        auto_decision = is_auto_navigate(sample, auto=auto, margin=margin)
        decision = decide(sample, auto=auto, minimum=minimum, margin=margin)
        if auto_decision:
            auto_count += 1
            if sample["condition"] == "negative" or not range_covers(
                sample.get("best"), int(sample["surah"]), int(sample["ayah_start"])
            ):
                wrong_auto += 1
        if sample["condition"] != "negative":
            correct_routes += int(
                (
                    decision == "auto_navigate"
                    and range_covers(
                        sample.get("best"), int(sample["surah"]), int(sample["ayah_start"])
                    )
                )
                or (
                    decision == "picker"
                    and any(
                        range_covers(
                            candidate,
                            int(sample["surah"]),
                            int(sample["ayah_start"]),
                        )
                        for candidate in sample.get("candidates", [])[:3]
                    )
                )
            )
    cer_values = [float(sample["cer"]) for sample in samples if sample.get("cer") is not None]
    wer_values = [float(sample["wer"]) for sample in samples if sample.get("wer") is not None]
    return {
        "samples": len(samples),
        "positive_samples": len(positives),
        "negative_samples": len(negatives),
        "top1_accuracy": _ratio(top1, len(positives)),
        "top3_accuracy": _ratio(top3, len(positives)),
        "span_samples": len(spans),
        "range_exact_accuracy": _ratio(exact_ranges, len(spans)),
        "false_auto_navigate_rate": _ratio(wrong_auto, len(samples)),
        "negative_rejection_rate": _ratio(
            sum(not is_auto_navigate(sample, auto=auto, margin=margin) for sample in negatives),
            len(negatives),
        ),
        "correct_positive_route_rate": _ratio(correct_routes, len(positives)),
        "auto_navigate_rate": _ratio(auto_count, len(samples)),
        "cer_clean_full_mean": _ratio(sum(cer_values), len(cer_values)),
        "wer_clean_full_mean": _ratio(sum(wer_values), len(wer_values)),
        "latency_ms_p50": _percentile(latencies, 0.50),
        "latency_ms_p95": _percentile(latencies, 0.95),
    }


def tune_thresholds(
    samples: Sequence[Mapping[str, Any]],
    *,
    auto_values: Iterable[float] = (0.70, 0.75, 0.80, 0.85, 0.90, 0.95),
    min_values: Iterable[float] = (0.40, 0.45, 0.50, 0.55, 0.60, 0.65),
    margin_values: Iterable[float] = (0.05, 0.10, 0.15, 0.20),
    max_false_auto_rate: float = 0.01,
    min_negative_rejection_rate: float = 0.95,
) -> dict[str, Any]:
    """Sweep configured decision thresholds; favor safe, correct positive routing."""
    grid: list[dict[str, Any]] = []
    for auto in auto_values:
        for minimum in min_values:
            if minimum >= auto:
                continue
            for margin in margin_values:
                metrics = summarize_samples(samples, auto=auto, minimum=minimum, margin=margin)[
                    "overall"
                ]
                grid.append(
                    {
                        "auto": auto,
                        "min": minimum,
                        "margin": margin,
                        "correct_positive_route_rate": metrics["correct_positive_route_rate"],
                        "false_auto_navigate_rate": metrics["false_auto_navigate_rate"],
                        "negative_rejection_rate": metrics["negative_rejection_rate"],
                        "auto_navigate_rate": metrics["auto_navigate_rate"],
                    }
                )
    eligible = [
        item
        for item in grid
        if item["false_auto_navigate_rate"] is not None
        and item["false_auto_navigate_rate"] <= max_false_auto_rate
        and (
            item["negative_rejection_rate"] is None
            or item["negative_rejection_rate"] >= min_negative_rejection_rate
        )
    ]
    eligible.sort(
        key=lambda item: (
            item["correct_positive_route_rate"] or 0.0,
            item["auto_navigate_rate"] or 0.0,
            item["min"],
            item["auto"],
            item["margin"],
        ),
        reverse=True,
    )
    return {
        "status": "selected" if eligible else "no_safe_configuration",
        "selection_rule": (
            "Maximize correctly routed positive samples while false auto-navigation is ≤1% "
            "and negative rejection is ≥95%; ties prefer the higher picker threshold."
        ),
        "selected": (
            {key: eligible[0][key] for key in ("auto", "min", "margin")} if eligible else None
        ),
        "grid": grid,
    }


def edit_distance(left: Sequence[Any], right: Sequence[Any]) -> int:
    """Levenshtein distance using O(min(n, m)) auxiliary memory."""
    if len(left) < len(right):
        left, right = right, left
    previous = list(range(len(right) + 1))
    for left_index, left_item in enumerate(left, start=1):
        current = [left_index]
        for right_index, right_item in enumerate(right, start=1):
            current.append(
                min(
                    current[-1] + 1,
                    previous[right_index] + 1,
                    previous[right_index - 1] + (left_item != right_item),
                )
            )
        previous = current
    return previous[-1]


def character_error_rate(reference: str, transcript: str) -> float:
    reference_chars = list(reference.replace(" ", ""))
    transcript_chars = list(transcript.replace(" ", ""))
    if not reference_chars:
        return 0.0 if not transcript_chars else 1.0
    return edit_distance(reference_chars, transcript_chars) / len(reference_chars)


def word_error_rate(reference: str, transcript: str) -> float:
    reference_words = reference.split()
    transcript_words = transcript.split()
    if not reference_words:
        return 0.0 if not transcript_words else 1.0
    return edit_distance(reference_words, transcript_words) / len(reference_words)


def _percentile(values: Sequence[float], percentile: float) -> float | None:
    if not values:
        return None
    index = max(0, math.ceil(percentile * len(values)) - 1)
    return values[index]
