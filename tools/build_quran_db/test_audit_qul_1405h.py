"""Synthetic export fixtures for the read-only QUL 1405H source audit."""

from __future__ import annotations

import sqlite3
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

from tools.build_quran_db.audit_qul_1405h import AuditError, _font_charset, audit


class QulAuditTest(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary = tempfile.TemporaryDirectory(prefix="qul-audit-")
        self.addCleanup(self.temporary.cleanup)
        root = Path(self.temporary.name)
        self.layout = root / "layout.sqlite"
        self.script = root / "script.sqlite"
        self.canonical = root / "quran.sqlite"
        self.fonts = root / "fonts"
        self.fonts.mkdir()
        (self.fonts / "p1.ttf").write_bytes(b"fixture-font-one")
        (self.fonts / "p2.ttf").write_bytes(b"fixture-font-two")
        (self.fonts / "LICENSE.txt").write_text("Test fixture only")

        with sqlite3.connect(self.layout) as db:
            db.execute(
                "CREATE TABLE info (name TEXT, number_of_pages INT, "
                "lines_per_page INT, font_name TEXT)"
            )
            db.execute(
                "INSERT INTO info VALUES ('Quran Complex V1 (1405 print)', 2, 2, 'v1')"
            )
            db.execute(
                "CREATE TABLE pages (page_number INT, line_number INT, "
                "line_type TEXT, is_centered INT, first_word_id INT, "
                "last_word_id INT, surah_number INT)"
            )
            db.executemany(
                "INSERT INTO pages VALUES (?, ?, ?, ?, ?, ?, ?)",
                [
                    (1, 1, "surah_name", 1, None, None, 1),
                    (1, 2, "ayah", 1, 1, 2, None),
                    (2, 1, "basmallah", 1, None, None, 2),
                    (2, 2, "ayah", 0, 3, 4, None),
                ],
            )
        with sqlite3.connect(self.script) as db:
            db.execute(
                "CREATE TABLE words (id INT, location TEXT, surah INT, ayah INT, word INT, text TEXT)"
            )
            db.executemany(
                "INSERT INTO words VALUES (?, ?, ?, ?, ?, ?)",
                [
                    (1, "1:1:1", 1, 1, 1, "glyph-1"),
                    (2, "1:1:2", 1, 1, 2, "marker-1"),
                    (3, "2:1:1", 2, 1, 1, "glyph-2"),
                    (4, "2:1:2", 2, 1, 2, "marker-2"),
                ],
            )
        with sqlite3.connect(self.canonical) as db:
            db.execute("CREATE TABLE ayah (id INT, surah INT, ayah INT, page INT)")
            db.executemany(
                "INSERT INTO ayah VALUES (?, ?, ?, ?)",
                [(1, 1, 1, 1), (2, 2, 1, 2)],
            )

    def run_audit(self) -> dict:
        return audit(
            self.layout,
            self.script,
            self.canonical,
            self.fonts,
            expected_pages=2,
            expected_ayahs=2,
        )

    def test_reports_complete_mapping_and_source_identity_without_mutation(
        self,
    ) -> None:
        original = (
            self.layout.read_bytes(),
            self.script.read_bytes(),
            self.canonical.read_bytes(),
        )
        report = self.run_audit()
        self.assertEqual(report["errors"], [])
        self.assertEqual(report["counts"]["mapped_ayat"], 2)
        self.assertEqual(report["page_differences"], [])
        self.assertEqual(
            report["line_types"], {"ayah": 2, "basmallah": 1, "surah_name": 1}
        )
        self.assertEqual(report["license_files"], ["LICENSE.txt"])
        self.assertEqual(
            original,
            (
                self.layout.read_bytes(),
                self.script.read_bytes(),
                self.canonical.read_bytes(),
            ),
        )

    def test_reports_every_legacy_page_difference_without_rewriting_it(self) -> None:
        with sqlite3.connect(self.canonical) as db:
            db.execute("UPDATE ayah SET page = 1 WHERE surah = 2")
        report = self.run_audit()
        self.assertEqual(
            report["page_differences"],
            [{"ayah": "2:1", "legacy_page": 1, "edition_page": 2}],
        )
        self.assertEqual(report["errors"], [])

    def test_detects_missing_word_and_font(self) -> None:
        with sqlite3.connect(self.script) as db:
            db.execute("DELETE FROM words WHERE id = 4")
        (self.fonts / "p2.ttf").unlink()
        report = self.run_audit()
        self.assertTrue(
            any("Missing first/last" in error for error in report["errors"])
        )
        self.assertEqual(report["missing_font_pages"], [2])

    def test_detects_duplicate_word_membership_and_unmapped_ayah(self) -> None:
        with sqlite3.connect(self.layout) as db:
            db.execute(
                "UPDATE pages SET first_word_id = 1, last_word_id = 2 WHERE page_number = 2 AND line_number = 2"
            )
        report = self.run_audit()
        self.assertEqual(report["repeated_word_ids"], [1, 2])
        self.assertEqual(report["missing_ayat"], ["2:1"])

    def test_rejects_export_schema_that_does_not_match_documentation(self) -> None:
        with sqlite3.connect(self.script) as db:
            db.execute("ALTER TABLE words RENAME COLUMN id TO unexpected_id")
        with self.assertRaisesRegex(AuditError, "source word ID column"):
            self.run_audit()

    def test_rejects_mismatched_canonical_word_location(self) -> None:
        with sqlite3.connect(self.script) as db:
            db.execute("UPDATE words SET location = '9:9:9' WHERE id = 2")
        report = self.run_audit()
        self.assertTrue(any("location" in error for error in report["errors"]))

    def test_detects_missing_internal_word_id(self) -> None:
        with sqlite3.connect(self.script) as db:
            db.execute("DELETE FROM words WHERE id = 2")
        report = self.run_audit()
        self.assertTrue(any("word IDs" in error for error in report["errors"]))

    def test_detects_duplicate_word_position(self) -> None:
        with sqlite3.connect(self.script) as db:
            db.execute("UPDATE words SET word = 1, location = '1:1:1' WHERE id = 2")
        report = self.run_audit()
        self.assertTrue(any("Duplicate source word position" in error for error in report["errors"]))

    def test_font_coverage_reports_missing_source_glyph(self) -> None:
        with patch(
            "tools.build_quran_db.audit_qul_1405h._font_charset",
            return_value={ord(char) for char in "glyph-1marker-1"},
        ):
            report = audit(
                self.layout,
                self.script,
                self.canonical,
                self.fonts,
                expected_pages=2,
                expected_ayahs=2,
                check_font_coverage=True,
            )
        self.assertEqual(report["counts"]["font_coverage_checked_pages"], 2)
        self.assertEqual(report["missing_glyphs_by_page"], {"2": ["U+0032"]})

    def test_font_charset_parses_single_codepoints_and_ranges(self) -> None:
        class Result:
            stdout = "20-22 fb50 fb51-fb52\n"

        with patch(
            "tools.build_quran_db.audit_qul_1405h.subprocess.run",
            return_value=Result(),
        ):
            self.assertEqual(
                _font_charset(self.fonts / "p1.ttf"),
                {0x20, 0x21, 0x22, 0xFB50, 0xFB51, 0xFB52},
            )


if __name__ == "__main__":
    unittest.main()
