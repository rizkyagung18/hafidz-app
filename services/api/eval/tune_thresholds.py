"""Select a safer confidence/margin configuration from run_eval.py sample results."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any

from eval.evaluation import tune_thresholds


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "metrics_json",
        type=Path,
        nargs="?",
        default=Path(__file__).resolve().parent / "output/golden-v1-metrics.json",
    )
    parser.add_argument(
        "--output-json",
        type=Path,
        default=Path(__file__).resolve().parent / "output/golden-v1-thresholds.json",
    )
    parser.add_argument("--max-false-auto-rate", type=float, default=0.01)
    parser.add_argument("--min-negative-rejection-rate", type=float, default=0.95)
    return parser


def render_report(result: dict[str, Any]) -> str:
    lines = [
        "# Golden-v1 threshold sweep",
        "",
        f"**Selection:** `{result['status']}`",
        "",
        result["selection_rule"],
        "",
        "| Auto | Min | Margin | Correct positive routing | False auto | Negative rejection |",
        "|---:|---:|---:|---:|---:|---:|",
    ]
    for row in result["grid"]:

        def percent(value: float | None) -> str:
            return "n/a" if value is None else f"{value:.2%}"

        lines.append(
            f"| {row['auto']:.2f} | {row['min']:.2f} | {row['margin']:.2f} | "
            f"{percent(row['correct_positive_route_rate'])} | "
            f"{percent(row['false_auto_navigate_rate'])} | "
            f"{percent(row['negative_rejection_rate'])} |"
        )
    selected = result.get("selected")
    lines.extend(
        [
            "",
            f"Selected: `{json.dumps(selected, sort_keys=True)}`"
            if selected
            else "No threshold configuration met the safety constraints.",
            "",
        ]
    )
    return "\n".join(lines)


def main() -> int:
    args = build_parser().parse_args()
    evaluation = json.loads(args.metrics_json.read_text(encoding="utf-8"))
    samples = evaluation.get("samples", [])
    if not samples:
        raise SystemExit("No per-sample evaluation results are available to tune.")
    result = tune_thresholds(
        samples,
        max_false_auto_rate=args.max_false_auto_rate,
        min_negative_rejection_rate=args.min_negative_rejection_rate,
    )
    args.output_json.parent.mkdir(parents=True, exist_ok=True)
    args.output_json.write_text(
        json.dumps(result, ensure_ascii=False, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )
    print(render_report(result))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
