"""Read Quran location metadata from the generated read-only SQLite database."""

from __future__ import annotations

import sqlite3
from pathlib import Path
from typing import TypedDict


class AyahLocation(TypedDict):
    page: int
    juz: int


class SurahName(TypedDict):
    arabic: str
    latin: str
    translation_id: str
    translation_en: str


class QuranMetadata:
    """Small, immutable metadata lookup loaded once during API startup."""

    def __init__(
        self,
        locations: dict[tuple[int, int], AyahLocation],
        surahs: dict[int, SurahName],
    ) -> None:
        self._locations = locations
        self._surahs = surahs

    @classmethod
    def load(cls, path: Path) -> QuranMetadata:
        if not path.is_file():
            raise FileNotFoundError(f"Quran metadata database not found: {path}")
        uri = f"file:{path.resolve()}?mode=ro"
        with sqlite3.connect(uri, uri=True) as connection:
            locations: dict[tuple[int, int], AyahLocation] = {
                (int(row[0]), int(row[1])): {"page": int(row[2]), "juz": int(row[3])}
                for row in connection.execute("SELECT surah, ayah, page, juz FROM ayah")
            }
            surahs: dict[int, SurahName] = {
                int(row[0]): {
                    "arabic": str(row[1]),
                    "latin": str(row[2]),
                    "translation_id": str(row[3]),
                    "translation_en": str(row[4]),
                }
                for row in connection.execute(
                    "SELECT number, name_arabic, name_latin, translation_id, "
                    "translation_en FROM surah"
                )
            }
        if len(locations) != 6_236 or len(surahs) != 114:
            raise ValueError("Quran metadata database failed its row-count checks.")
        return cls(locations, surahs)

    def ayah(self, surah: int, ayah: int) -> AyahLocation:
        return self._locations[(surah, ayah)]

    def surah(self, number: int) -> SurahName:
        return self._surahs[number]
