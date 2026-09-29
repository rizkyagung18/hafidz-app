"""Golden cases for the shared Arabic normalization and query cleanup rules."""

from __future__ import annotations

import unittest

from app.matching.normalize import CleanedQuery, cleanup_query, normalize_ar


class NormalizeArabicTests(unittest.TestCase):
    def test_golden_normalization_cases(self) -> None:
        cases = [
            ("آ", "ا"),
            ("أ", "ا"),
            ("إ", "ا"),
            ("ٱ", "ا"),
            ("ٲ", "ا"),
            ("ٳ", "ا"),
            ("ى", "ي"),
            ("ی", "ي"),
            ("ئ", "ي"),
            ("ؤ", "و"),
            ("ة", "ه"),
            ("ک", "ك"),
            ("ء", ""),
            ("اـب", "اب"),
            ("بَ", "ب"),
            ("بً", "ب"),
            ("بُ", "ب"),
            ("بٌ", "ب"),
            ("بِ", "ب"),
            ("بٍ", "ب"),
            ("بْ", "ب"),
            ("بّ", "ب"),
            ("بٰ", "ب"),
            ("بۖ", "ب"),
            ("بۗ", "ب"),
            ("بۘ", "ب"),
            ("بۙ", "ب"),
            ("بۚ", "ب"),
            ("بۛ", "ب"),
            ("بۜ", "ب"),
            ("ب۞", "ب"),
            ("ب۩", "ب"),
            ("ب۝", "ب"),
            ("ب123", "ب"),
            ("ب١٢٣", "ب"),
            ("ب!؟،؛", "ب"),
            ("abc ب xyz", "ب"),
            ("  ب   ت  ", "ب ت"),
            ("ب\tت\nث", "ب ت ث"),
            ("ب\u00a0ت", "ب ت"),
            ("بِسْمِ اللَّهِ", "بسم الله"),
            ("ﻻ", "لا"),
            ("بـسـم", "بسم"),
            ("ٱلْحَمْدُ", "الحمد"),
            ("رَبِّ", "رب"),
        ]
        self.assertGreaterEqual(len(cases), 40)
        for source, expected in cases:
            with self.subTest(source=source):
                self.assertEqual(normalize_ar(source), expected)

    def test_normalization_is_idempotent_for_golden_inputs(self) -> None:
        inputs = [
            "آيةٌ۞ ١٢",
            "إِنَّ ٱللَّهَ غَفُورٌ",
            "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
            "یٰسٓ",
            "لَا إِلَٰهَ إِلَّا اللَّهُ",
            "مُوسَىٰ عَلَيْهِ السَّلَامُ",
            "رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً",
            "قُلْ هُوَ اللَّهُ أَحَدٌ",
        ]
        for source in inputs:
            with self.subTest(source=source):
                once = normalize_ar(source)
                self.assertEqual(normalize_ar(once), once)


class CleanupQueryTests(unittest.TestCase):
    def test_exact_leading_isti_adha_is_removed(self) -> None:
        result = cleanup_query("أعوذ بالله من الشيطان الرجيم الحمد لله رب العالمين")
        self.assertEqual(result, CleanedQuery("الحمد لله رب العالمين"))

    def test_fuzzy_leading_isti_adha_is_removed(self) -> None:
        result = cleanup_query("اعوز بالله من الشيطان الرجيم الحمد لله رب العالمين")
        self.assertEqual(result.text, "الحمد لله رب العالمين")

    def test_unrelated_prefix_is_preserved(self) -> None:
        result = cleanup_query("الحمد لله رب العالمين")
        self.assertEqual(result.text, "الحمد لله رب العالمين")

    def test_leading_basmala_is_removed_and_flagged(self) -> None:
        result = cleanup_query("بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ الْحَمْدُ لِلَّهِ")
        self.assertEqual(result.text, "الحمد لله")
        self.assertTrue(result.had_basmala)
        self.assertFalse(result.basmala_only)

    def test_basmala_only_is_flagged_for_matcher(self) -> None:
        result = cleanup_query("بسم الله الرحمن الرحيم")
        self.assertEqual(result, CleanedQuery("", had_basmala=True, basmala_only=True))

    def test_trailing_sadaqa_phrase_is_removed(self) -> None:
        result = cleanup_query("الحمد لله رب العالمين صدق الله العظيم")
        self.assertEqual(result.text, "الحمد لله رب العالمين")

    def test_sadaqa_phrase_in_middle_is_preserved(self) -> None:
        result = cleanup_query("صدق الله العظيم الحمد لله")
        self.assertEqual(result.text, "صدق الله العظيم الحمد لله")

    def test_all_cleanup_phrases_are_removed_in_order(self) -> None:
        result = cleanup_query(
            "أعوذ بالله من الشيطان الرجيم بسم الله الرحمن الرحيم الحمد لله صدق الله العظيم"
        )
        self.assertEqual(result, CleanedQuery("الحمد لله", had_basmala=True))

    def test_empty_input_returns_empty_result(self) -> None:
        self.assertEqual(cleanup_query(""), CleanedQuery(""))

    def test_cleanup_normalizes_before_matching_phrases(self) -> None:
        result = cleanup_query("أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ")
        self.assertEqual(result.text, "")


if __name__ == "__main__":
    unittest.main()
