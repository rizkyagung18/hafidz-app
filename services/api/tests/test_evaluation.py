"""Metrics and manifest validation tests for the golden-set evaluation tools."""

from __future__ import annotations

import csv
from pathlib import Path
from typing import Any

import pytest
from eval.evaluation import (
    character_error_rate,
    decide,
    range_covers,
    summarize_samples,
    tune_thresholds,
    word_error_rate,
)
from eval.run_eval import _empty_result, read_manifest, render_report, write_outputs


def _sample(
    *,
    condition: str = "clean-full",
    surah: int | None = 2,
    ayah: int | None = 10,
    confidence: float = 0.90,
    margin: float = 0.25,
    best: dict[str, int] | None = None,
    candidates: list[dict[str, int]] | None = None,
    ambiguous: bool = False,
) -> dict[str, Any]:
    prediction = best if best is not None else {"surah": 2, "ayah_start": 10, "ayah_end": 10}
    return {
        "condition": condition,
        "surah": surah,
        "ayah_start": ayah,
        "ayah_end": ayah,
        "confidence": confidence,
        "margin": margin,
        "ambiguous": ambiguous,
        "best": prediction,
        "candidates": candidates or [prediction],
        "latency_ms": 100.0,
        "cer": 0.0,
        "wer": 0.0,
    }


def test_range_overlap_checks_surah_and_inclusive_ayah() -> None:
    candidate = {"surah": 2, "ayah_start": 9, "ayah_end": 10}

    assert range_covers(candidate, 2, 10)
    assert not range_covers(candidate, 2, 11)
    assert not range_covers(candidate, 3, 10)


def test_decision_obeys_auto_margin_minimum_and_ambiguity() -> None:
    sample = _sample()
    assert decide(sample, auto=0.8, minimum=0.55, margin=0.1) == "auto_navigate"
    assert decide(sample, auto=0.95, minimum=0.55, margin=0.1) == "picker"
    assert decide(sample, auto=0.95, minimum=0.95, margin=0.1) == "not_found"
    assert decide({**sample, "ambiguous": True}, auto=0.8, minimum=0.55, margin=0.1) == "picker"


def test_metrics_exclude_negative_from_accuracy_and_count_false_auto() -> None:
    correct = _sample()
    wrong = _sample(best={"surah": 2, "ayah_start": 9, "ayah_end": 9})
    negative = _sample(condition="negative", surah=None, ayah=None)
    metrics = summarize_samples([correct, wrong, negative])["overall"]

    assert metrics["top1_accuracy"] == pytest.approx(0.5)
    assert metrics["top3_accuracy"] == pytest.approx(0.5)
    assert metrics["false_auto_navigate_rate"] == pytest.approx(2 / 3)
    assert metrics["negative_rejection_rate"] == 0.0
    assert metrics["latency_ms_p50"] == 100.0


def test_span_exact_range_requires_same_start_and_end() -> None:
    exact = _sample(condition="span", ayah=10)
    exact["ayah_end"] = 11
    exact["best"] = {"surah": 2, "ayah_start": 10, "ayah_end": 11}
    wrong = _sample(condition="span", ayah=10)
    wrong["ayah_end"] = 11
    wrong["best"] = {"surah": 2, "ayah_start": 10, "ayah_end": 12}

    metrics = summarize_samples([exact, wrong])["overall"]
    assert metrics["range_exact_accuracy"] == pytest.approx(0.5)


def test_character_and_word_error_rates_use_normalized_tokens() -> None:
    assert character_error_rate("اب ج", "اب د") == pytest.approx(1 / 3)
    assert word_error_rate("اب ج", "اب د") == pytest.approx(0.5)
    assert word_error_rate("اب", "") == 1.0


def test_threshold_grid_respects_false_auto_gate() -> None:
    samples = [
        _sample(confidence=0.9),
        _sample(confidence=0.7),
        _sample(condition="negative", surah=None, ayah=None, confidence=0.9),
    ]
    result = tune_thresholds(
        samples,
        auto_values=(0.8, 0.95),
        min_values=(0.4, 0.6),
        margin_values=(0.1,),
    )

    assert result["status"] == "selected"
    assert result["selected"]["auto"] == 0.95
    assert result["selected"]["margin"] == 0.1


def test_manifest_parses_positive_and_negative_labels(tmp_path: Path) -> None:
    manifest = tmp_path / "manifest.csv"
    with manifest.open("w", encoding="utf-8", newline="") as stream:
        writer = csv.writer(stream)
        writer.writerow(["path", "surah", "ayah_start", "ayah_end", "condition"])
        writer.writerow(["clip.wav", "2", "10", "11", "span"])
        writer.writerow(["noise.wav", "", "", "", "negative"])

    entries = read_manifest(manifest)
    assert entries[0].surah == 2
    assert entries[0].ayah_end == 11
    assert entries[1].condition == "negative"
    assert entries[1].surah is None


@pytest.mark.parametrize("unsafe_path", ["../outside.wav", "/tmp/outside.wav"])
def test_manifest_rejects_paths_outside_audio_root(tmp_path: Path, unsafe_path: str) -> None:
    manifest = tmp_path / "manifest.csv"
    manifest.write_text(
        f"path,surah,ayah_start,ayah_end,condition\n{unsafe_path},2,10,10,clean-full\n",
        encoding="utf-8",
    )

    with pytest.raises(ValueError, match="path"):
        read_manifest(manifest)


def test_empty_dataset_report_explicitly_makes_no_accuracy_claim(tmp_path: Path) -> None:
    result = _empty_result()
    report = render_report(result)
    write_outputs(result, tmp_path / "metrics.json", tmp_path / "report.md")

    assert "`blocked`" in report
    assert "No accuracy or latency claim is made" in report
    assert "blocked" in (tmp_path / "metrics.json").read_text(encoding="utf-8")
    assert (tmp_path / "report.md").read_text(encoding="utf-8") == report
