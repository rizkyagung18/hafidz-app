"""Stage an untracked local-only QUL V1 print pack for Flutter device review.

Do not publish the generated assets until resource-specific redistribution rights
and the print appearance have been approved. The source ZIPs remain in .cache.
"""

from __future__ import annotations

import json
import shutil
import subprocess
from pathlib import Path
from zipfile import ZipFile

from build import (  # type: ignore[import-not-found]
    EXPECTED_AYAT,
    ROOT,
    BuildError,
    _page_mapping,
    open_source,
    read_lock,
    sha256_bytes,
    source_path,
)

ASSETS = ROOT / "apps/mobile/assets/mushaf"


def stage() -> Path:
    lock = read_lock()
    print_lock = json.loads((ROOT / "tools/build_quran_db/print_sources.lock.json").read_text(encoding="utf-8"))
    if print_lock.get("schema_version") != 1 or set(print_lock.get("sources", {})) != {
        "surah_header_font", "surah_name_v2_font", "quran_common_font",
        "surah_header_ligatures", "surah_name_v1_font"
    }:
        raise BuildError("Invalid QUL print source lock")
    lock["sources"] = {**lock["sources"], **print_lock["sources"]}
    layout = open_source(lock, "layout_1405h")
    glyphs = open_source(lock, "word_glyphs_1405h")
    try:
        first_page, members = _page_mapping(layout, glyphs)
        if len(first_page) != EXPECTED_AYAT or len(members) != 604:
            raise BuildError("Incomplete 1405H print mapping")
        fonts_dir = ASSETS / "fonts"
        fonts_dir.mkdir(parents=True, exist_ok=True)
        font_hashes: dict[str, str] = {}
        font_archive = source_path(lock, "page_fonts_1405h")
        with ZipFile(font_archive) as archive:
            for page in range(1, 605):
                name = f"p{page}.ttf"
                members_in_zip = [item for item in archive.namelist() if item.endswith(f"/{name}") or item == name]
                if len(members_in_zip) != 1:
                    raise BuildError(f"Missing or duplicate font {name}")
                data = archive.read(members_in_zip[0])
                (fonts_dir / name).write_bytes(data)
                font_hashes[name] = sha256_bytes(data)
        for source, name in (
            ("quran_common_font", "quran-common.ttf"),
            ("surah_name_v2_font", "surah-name-v2.ttf"),
            ("surah_header_font", "QCF_SurahHeader_COLOR-Regular.ttf"),
        ):
            with ZipFile(source_path(lock, source)) as archive:
                entries = [item for item in archive.infolist() if not item.is_dir()]
                if len(entries) != 1 or entries[0].filename != name:
                    raise BuildError(f"Unexpected QUL font archive for {source}")
                data = archive.read(entries[0])
            (fonts_dir / name).write_bytes(data)
            font_hashes[name] = sha256_bytes(data)
        path = source_path(lock, "surah_name_v1_font")
        shutil.copy2(path, fonts_dir / "surah_name_v1.ttf")
        font_hashes["surah_name_v1.ttf"] = sha256_bytes(path.read_bytes())
        header_glyphs = json.loads(source_path(lock, "surah_header_ligatures").read_text(encoding="utf-8"))
        if set(header_glyphs) != {str(number) for number in range(1, 115)} or any(
            not isinstance(glyph, str) or len(glyph) != 1 for glyph in header_glyphs.values()
        ):
            raise BuildError("Incomplete QUL Surah header ligatures")
        if shutil.which("hb-view") is None:
            raise BuildError("hb-view is required to render local QUL color headers")
        headers_dir = ASSETS / "headers"
        headers_dir.mkdir(parents=True, exist_ok=True)
        header_hashes: dict[str, str] = {}
        for number in range(1, 115):
            image = headers_dir / f"{number}.png"
            subprocess.run(
                [
                    "hb-view", str(fonts_dir / "QCF_SurahHeader_COLOR-Regular.ttf"),
                    header_glyphs[str(number)], "--font-size=180", "--ink",
                    "--margin=0", "--background=none", "-o", str(image),
                ],
                check=True,
                capture_output=True,
            )
            header_hashes[str(number)] = sha256_bytes(image.read_bytes())
        manifest = {
            "pack_version": 3,
            "edition": "madinah-1405h-qpc-v1",
            "pages": 604,
            "source_sha256": {name: item["sha256"] for name, item in lock["sources"].items()},
            "font_sha256": font_hashes,
            "surah_header_glyphs": header_glyphs,
            "header_png_sha256": header_hashes,
            "distribution": "local-review-only; rights unverified",
        }
        manifest_path = ASSETS / "manifest.json"
        manifest_path.write_text(json.dumps(manifest, sort_keys=True), encoding="utf-8")
        print(f"Staged local 604-page QUL V1 proof at {ASSETS}")
        return manifest_path
    finally:
        layout.close()
        glyphs.close()


if __name__ == "__main__":
    stage()
