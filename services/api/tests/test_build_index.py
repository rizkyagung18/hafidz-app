"""Tests for Quran search-index unit construction."""

from __future__ import annotations

import importlib
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

_index_builder = importlib.import_module("tools.build_quran_db.build_index")
_build_word_index = _index_builder._build_word_index
_make_unit = _index_builder._make_unit
build_units = _index_builder.build_units


def ayah(surah: int, number: int, uthmani: str, simple: str) -> dict[str, int | str]:
    return {
        "id": number,
        "surah": surah,
        "ayah": number,
        "text_uthmani": uthmani,
        "text_simple": simple,
        "text_norm": simple,
    }


class BuildIndexTests(unittest.TestCase):
    def test_builds_single_and_2_3_ayah_windows_without_crossing_surahs(self) -> None:
        rows = [
            ayah(1, 1, "الحمد لله", "الحمد لله"),
            ayah(1, 2, "رب العالمين", "رب العالمين"),
            ayah(1, 3, "الرحمن الرحيم", "الرحمن الرحيم"),
            ayah(114, 1, "الم", "الم"),
        ]
        units, counts = build_units(rows)
        self.assertEqual(counts, {"single": 4, "window_2": 2, "window_3": 1, "muqattaat_alias": 0})
        self.assertEqual(len(units), 7)
        self.assertEqual(
            [
                (unit["surah"], unit["ayah_start"], unit["ayah_end"])
                for unit in units
                if unit["kind"] == "window_2"
            ],
            [(1, 1, 2), (1, 2, 3)],
        )

    def test_offsets_are_separate_for_uthmani_and_simple_spellings(self) -> None:
        first = ayah(1, 1, "أَلْحَمْدُ", "الحمد")
        second = ayah(1, 2, "رَبِّ", "رب")
        unit = _make_unit([first, second], 0, "window_2")
        self.assertEqual(
            unit["char_offsets_A"],
            [0, len(unit["text_norm_A"].split()[0]) + 1, len(unit["text_norm_A"])],
        )
        self.assertEqual(unit["char_offsets_B"], [0, 6, len(unit["text_norm_B"])])

    def test_muquattaat_aliases_are_search_only_units(self) -> None:
        unit = _make_unit([ayah(2, 1, "الم", "الم")], 1, "muqattaat_alias", "الف لام ميم")
        self.assertEqual(unit["text_norm_A"], "الف لام ميم")
        self.assertEqual(unit["text_norm_B"], "الف لام ميم")
        self.assertEqual((unit["surah"], unit["ayah_start"], unit["ayah_end"]), (2, 1, 1))

    def test_word_index_tracks_units_and_smooth_idf(self) -> None:
        units = [
            {"unit_id": 0, "text_norm_A": "الحمد لله", "text_norm_B": "الحمد لله"},
            {"unit_id": 1, "text_norm_A": "لله رب", "text_norm_B": "لله رب"},
        ]
        mapping, idf = _build_word_index(units)
        self.assertEqual(mapping["لله"], [0, 1])
        self.assertGreater(idf["الحمد"], idf["لله"])


if __name__ == "__main__":
    unittest.main()
