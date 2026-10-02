"""Build a local, non-distributable visual proof from signed-in QUL exports.

The output links to the owner's ignored local font cache. It is a browser proof
for page typography and word selection, not the Flutter reader or a licensed pack.
"""

from __future__ import annotations

import argparse
import html
import os
import sqlite3
from pathlib import Path
from urllib.parse import quote

PAGES = (1, 2, 42, 48, 121, 187, 604)


def _read_only(path: Path) -> sqlite3.Connection:
    if not path.is_file():
        raise ValueError(f"Missing input: {path}")
    database = sqlite3.connect(f"file:{quote(str(path.resolve()))}?mode=ro", uri=True)
    database.row_factory = sqlite3.Row
    database.execute("PRAGMA query_only = ON")
    return database


def _relative_asset(output: Path, asset: Path) -> str:
    if not asset.is_file():
        raise ValueError(f"Missing font asset: {asset}")
    return quote(Path(os.path.relpath(asset, output.parent)).as_posix())


def generate(
    layout_db: Path,
    script_db: Path,
    font_dir: Path,
    output: Path,
    *,
    pages: tuple[int, ...] = PAGES,
) -> None:
    """Write a source-driven proof for selected pages; never change source files."""
    if len(set(pages)) != len(pages) or any(page < 1 or page > 604 for page in pages):
        raise ValueError("Pages must be distinct and in the 1..604 range")
    with _read_only(layout_db) as layout, _read_only(script_db) as script:
        font_rules = []
        buttons = []
        sheets = []
        for page in pages:
            font = _relative_asset(output, font_dir / f"p{page}.ttf")
            font_rules.append(
                f"@font-face{{font-family:'page-{page}';src:url('{font}') format('truetype');font-display:block}}"
            )
            buttons.append(
                f'<button type="button" data-go="{page}">{page}</button>'
            )
            rows = layout.execute(
                "SELECT line_number,line_type,is_centered,first_word_id,last_word_id,surah_number "
                "FROM pages WHERE page_number=? ORDER BY line_number",
                (page,),
            ).fetchall()
            if not rows:
                raise ValueError(f"No layout rows for page {page}")
            line_html = []
            for row in rows:
                kind = row["line_type"]
                number = int(row["line_number"])
                if kind == "surah_name":
                    surah = int(row["surah_number"])
                    content = (
                        '<span class="header-frame" aria-hidden="true">header</span>'
                        f'<span class="surah-title" aria-label="Surah {surah}">surah{surah:03d}</span>'
                    )
                elif kind == "basmallah":
                    content = '<span class="basmallah" aria-label="Basmala">﷽</span>'
                elif kind == "ayah":
                    words = script.execute(
                        "SELECT id,surah,ayah,word,text FROM words WHERE id BETWEEN ? AND ? ORDER BY id",
                        (row["first_word_id"], row["last_word_id"]),
                    ).fetchall()
                    if (
                        not words
                        or words[0]["id"] != row["first_word_id"]
                        or words[-1]["id"] != row["last_word_id"]
                        or len(words) != row["last_word_id"] - row["first_word_id"] + 1
                    ):
                        raise ValueError(f"Page {page}, line {number} has missing source words")
                    spans = []
                    for word in words:
                        ayah = f"{word['surah']}:{word['ayah']}"
                        spans.append(
                            f'<span class="word" data-ayah="{ayah}" data-word="{word["id"]}" '
                            f'title="{ayah} word {word["word"]}">{html.escape(word["text"])}</span>'
                        )
                    content = " ".join(spans)
                else:
                    raise ValueError(f"Unknown line type {kind!r} on page {page}")
                line_html.append(
                    f'<div class="line {"center" if row["is_centered"] else "justify"} {kind}" '
                    f'data-line="{number}">{content}</div>'
                )
            sheets.append(
                f'<article class="sheet" data-page="{page}" style="--page-font:page-{page}">'
                f'<div class="page-frame"><div class="page-lines">{"".join(line_html)}</div></div>'
                f'<div class="folio">{page}</div></article>'
            )
    common = _relative_asset(output, font_dir.parent / "quran-common.ttf")
    names = _relative_asset(output, font_dir.parent / "surah_name_v1.ttf")
    document = f"""<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>1405H Mushaf local visual proof</title>
<style>
@font-face{{font-family:common;src:url('{common}') format('truetype');font-display:block}}
@font-face{{font-family:surah-names;src:url('{names}') format('truetype');font-display:block}}
{''.join(font_rules)}
*{{box-sizing:border-box}}
body{{margin:0;background:#e5e4de;color:#25241f;font-family:system-ui,sans-serif}}
nav{{position:sticky;top:0;z-index:5;display:flex;align-items:center;gap:8px;flex-wrap:wrap;padding:12px;background:#fffffff0;border-bottom:1px solid #ccc}}
nav strong{{margin-right:12px}}button{{cursor:pointer;border:1px solid #b6b8b0;border-radius:7px;background:#fff;padding:7px 12px;font:inherit}}
button.active{{background:#174e42;color:#fff}}#selection{{margin-left:auto;min-width:180px;color:#174e42;font-weight:600}}
main{{padding:20px 8px 45px;overflow:auto}}
.viewport{{width:660px;height:940px;margin:auto;position:relative}}
.sheet{{display:none;width:660px;height:940px;background:#fcfaf2;padding:28px 10px 22px;box-shadow:0 6px 24px #0003;transform-origin:top left;direction:rtl}}
.sheet.active{{display:block}}.page-frame{{height:858px;border:2px solid #5e5c48;padding:15px 5px 11px;outline:1px solid #b9b096;outline-offset:-8px}}
.page-lines{{font-family:var(--page-font);font-size:30px;line-height:1.85;color:#151411}}
.line{{height:55px;white-space:nowrap;direction:rtl;unicode-bidi:normal}}
.line.justify{{text-align:justify;text-align-last:justify}}.line.center{{text-align:center;text-align-last:center}}
.line.surah_name{{position:relative;text-align:center;text-align-last:center;height:55px;line-height:55px}}
.header-frame{{font-family:common;font-size:48px;line-height:1;display:block;position:absolute;inset:2px 0 auto;pointer-events:none}}
.surah-title{{font-family:surah-names;font-size:29px;line-height:55px;position:relative;display:block}}
.basmallah{{font-family:common;font-size:36px}}
.word{{cursor:pointer;border-radius:4px}}.word:hover{{background:#eacb7555}}.word.selected{{background:#e6ba54a8}}
.folio{{text-align:center;font:17px Georgia,serif;margin-top:9px}}
@media(max-width:690px){{nav{{font-size:13px}}button{{padding:5px 9px}}main{{padding:10px 0 25px}}}}
</style></head><body>
<nav><strong>1405H local proof</strong>{''.join(buttons)}<button type="button" id="zoom-out">−</button><button type="button" id="zoom-in">+</button><span id="selection">Tap an ayah word</span></nav>
<main><div class="viewport">{''.join(sheets)}</div></main>
<script>
const sheets=[...document.querySelectorAll('.sheet')],buttons=[...document.querySelectorAll('[data-go]')];
const params=new URLSearchParams(location.search),requested=Number(params.get('page'));
let current={pages[0]},zoom=1,selected=null;
function fit(){{let viewport=document.querySelector('.viewport');let available=Math.max(250,Math.min(window.innerWidth-16,660));let scale=available/660*zoom;viewport.style.width=`${{660*scale}}px`;viewport.style.height=`${{940*scale}}px`;sheets.forEach(s=>s.style.transform=`scale(${{scale}})`);}}
function show(page){{current=page;sheets.forEach(s=>s.classList.toggle('active',+s.dataset.page===page));buttons.forEach(b=>b.classList.toggle('active',+b.dataset.go===page));selected=null;document.querySelectorAll('.selected').forEach(w=>w.classList.remove('selected'));document.querySelector('#selection').textContent='Tap an ayah word';}}
function selectAyah(ayah,word=''){{selected=ayah;document.querySelectorAll('.word').forEach(x=>x.classList.toggle('selected',x.dataset.ayah===ayah));document.querySelector('#selection').textContent=`Selected ${{ayah}}${{word?` (word ${{word}})`:''}}`;}}
buttons.forEach(b=>b.addEventListener('click',()=>show(+b.dataset.go)));
document.querySelectorAll('.word').forEach(w=>w.addEventListener('click',()=>selectAyah(w.dataset.ayah,w.dataset.word)));
document.querySelector('#zoom-in').addEventListener('click',()=>{{zoom=Math.min(2,zoom+.2);fit()}});
document.querySelector('#zoom-out').addEventListener('click',()=>{{zoom=Math.max(.6,zoom-.2);fit()}});
window.addEventListener('resize',fit);show([{','.join(map(str, pages))}].includes(requested)?requested:current);fit();
if(params.has('ayah'))selectAyah(params.get('ayah'));
document.fonts.ready.then(()=>{{for(const sheet of sheets){{const overflow=[...sheet.querySelectorAll('.line.ayah')].filter(line=>line.scrollWidth>line.clientWidth+1);sheet.dataset.overflowLines=overflow.map(x=>x.dataset.line).join(',');if(overflow.length)console.warn(`Page ${{sheet.dataset.page}}: overflow on lines ${{sheet.dataset.overflowLines}}`);}}}});
</script></body></html>"""
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(document, encoding="utf-8")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--layout", type=Path, required=True)
    parser.add_argument("--script", type=Path, required=True)
    parser.add_argument("--fonts", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    generate(args.layout, args.script, args.fonts, args.output)
    print(f"Wrote {args.output} for pages {', '.join(map(str, PAGES))}")


if __name__ == "__main__":
    main()
