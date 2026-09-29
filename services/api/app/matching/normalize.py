"""Canonical Arabic normalization and query-only cleanup for ayah matching."""

from __future__ import annotations

import re
import unicodedata
from dataclasses import dataclass
from difflib import SequenceMatcher

_TASHKEEL = re.compile(r"[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED\u08D3-\u08FF]")
_TATWEEL = "\u0640"
_NON_ARABIC = re.compile(r"[^\u0621-\u063A\u0641-\u064A\s]")
_SPACES = re.compile(r"\s+")

_CHAR_MAP = str.maketrans(
    {
        "\u0622": "\u0627",  # آ -> ا
        "\u0623": "\u0627",  # أ -> ا
        "\u0625": "\u0627",  # إ -> ا
        "\u0671": "\u0627",  # ٱ -> ا
        "\u0672": "\u0627",
        "\u0673": "\u0627",
        "\u0649": "\u064a",  # ى -> ي
        "\u06cc": "\u064a",  # Farsi yeh -> ي
        "\u0626": "\u064a",  # ئ -> ي
        "\u0624": "\u0648",  # ؤ -> و
        "\u0629": "\u0647",  # ة -> ه
        "\u06a9": "\u0643",  # Farsi kaf -> ك
        "\u0621": "",  # standalone hamza
    }
)

_ISTIADHA = "اعوذ بالله من الشيطان الرجيم"
_BASMALA = "بسم الله الرحمن الرحيم"
_SADAQA = "صدق الله العظيم"
_ISTIADHA_THRESHOLD = 85.0


@dataclass(frozen=True, slots=True)
class CleanedQuery:
    """Normalized query and flags needed by the matcher."""

    text: str
    had_basmala: bool = False
    basmala_only: bool = False


def normalize_ar(text: str) -> str:
    """Normalize Arabic for matching only; never use the result as display text."""
    value = unicodedata.normalize("NFKC", text)
    value = _TASHKEEL.sub("", value)
    value = value.replace(_TATWEEL, "")
    value = value.translate(_CHAR_MAP)
    value = _NON_ARABIC.sub(" ", value)
    return _SPACES.sub(" ", value).strip()


def _leading_isti_adha_length(words: list[str]) -> int:
    """Return the number of leading words to remove when they match the isti'adha."""
    target = _ISTIADHA.split()
    best: tuple[float, int] = (0.0, 0)
    for count in range(max(1, len(target) - 1), len(target) + 2):
        if len(words) < count:
            continue
        candidate = " ".join(words[:count])
        ratio = SequenceMatcher(None, candidate, _ISTIADHA, autojunk=False).ratio() * 100
        if ratio > best[0]:
            best = (ratio, count)
    return best[1] if best[0] >= _ISTIADHA_THRESHOLD else 0


def cleanup_query(text: str) -> CleanedQuery:
    """Normalize a recognition query and remove common recitation framing phrases."""
    words = normalize_ar(text).split()
    isti_adha_length = _leading_isti_adha_length(words)
    if isti_adha_length:
        words = words[isti_adha_length:]

    had_basmala = words[:4] == _BASMALA.split()
    if had_basmala:
        words = words[4:]

    if words[-3:] == _SADAQA.split():
        words = words[:-3]

    cleaned = " ".join(words)
    return CleanedQuery(
        text=cleaned,
        had_basmala=had_basmala,
        basmala_only=had_basmala and not cleaned,
    )
