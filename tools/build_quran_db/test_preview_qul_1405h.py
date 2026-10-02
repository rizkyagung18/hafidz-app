"""Tests for the local QUL 1405H browser proof generator."""

from __future__ import annotations

import sqlite3
import tempfile
import unittest
from pathlib import Path

from tools.build_quran_db.preview_qul_1405h import generate


class PreviewTest(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary = tempfile.TemporaryDirectory(prefix="qul-preview-")
        self.addCleanup(self.temporary.cleanup)
        root = Path(self.temporary.name)
        self.layout = root / "layout.sqlite"
        self.script = root / "script.sqlite"
        self.fonts = root / "fonts"
        self.fonts.mkdir()
        self.output = root / "proof.html"
        for name in ("p1.ttf", "p2.ttf"):
            (self.fonts / name).write_bytes(b"fixture")
        (root / "quran-common.ttf").write_bytes(b"fixture")
        (root / "surah_name_v1.ttf").write_bytes(b"fixture")
        with sqlite3.connect(self.layout) as db:
            db.execute(
                "CREATE TABLE pages (page_number INT,line_number INT,line_type TEXT,"
                "is_centered INT,first_word_id INT,last_word_id INT,surah_number INT)"
            )
            db.executemany(
                "INSERT INTO pages VALUES (?,?,?,?,?,?,?)",
                [
                    (1, 1, "surah_name", 1, "", "", 1),
                    (1, 2, "ayah", 1, 1, 2, ""),
                    (2, 1, "basmallah", 1, "", "", ""),
                    (2, 2, "ayah", 0, 3, 3, ""),
                ],
            )
        with sqlite3.connect(self.script) as db:
            db.execute(
                "CREATE TABLE words (id INT,surah INT,ayah INT,word INT,text TEXT)"
            )
            db.executemany(
                "INSERT INTO words VALUES (?,?,?,?,?)",
                [(1, 1, 1, 1, "ﭑ"), (2, 1, 1, 2, "ﭒ"), (3, 2, 1, 1, "ﭑ")],
            )

    def test_proof_uses_source_lines_and_pressable_canonical_ayahs(self) -> None:
        original = (self.layout.read_bytes(), self.script.read_bytes())
        generate(self.layout, self.script, self.fonts, self.output, pages=(1, 2))
        page = self.output.read_text(encoding="utf-8")
        self.assertIn('data-page="1"', page)
        self.assertIn('data-line="2"', page)
        self.assertIn('data-ayah="1:1" data-word="1"', page)
        self.assertIn('data-ayah="1:1" data-word="2"', page)
        self.assertIn('data-ayah="2:1" data-word="3"', page)
        self.assertIn("surah001", page)
        self.assertIn("﷽", page)
        self.assertIn("fonts/p1.ttf", page)
        self.assertIn("[1,2].includes(requested)", page)
        self.assertEqual(original, (self.layout.read_bytes(), self.script.read_bytes()))

    def test_missing_line_word_rejected(self) -> None:
        with sqlite3.connect(self.script) as db:
            db.execute("DELETE FROM words WHERE id=2")
        with self.assertRaisesRegex(ValueError, "missing source words"):
            generate(self.layout, self.script, self.fonts, self.output, pages=(1, 2))
        self.assertFalse(self.output.exists())

    def test_missing_page_font_rejected(self) -> None:
        (self.fonts / "p2.ttf").unlink()
        with self.assertRaisesRegex(ValueError, "Missing font asset"):
            generate(self.layout, self.script, self.fonts, self.output, pages=(1, 2))


if __name__ == "__main__":
    unittest.main()
