#!/usr/bin/env python3
"""Sinh font con (subset) đóng gói trong app: Noto Sans + Noto Sans JP, đậm 400/700.

Vì sao: CanvasKit không dùng font hệ thống; thiếu glyph thì nó tải Noto từ
fonts.gstatic.com lúc chạy (lần đầu hiện ô vuông, offline thì hỏng). Đóng gói
sẵn một bản đã cắt chỉ còn ký tự app dùng thì chữ Việt và kanji hiện ngay.

  - NotoSans    : Latin + tiếng Việt (Noto Sans JP thiếu dấu chồng như ế, ặ).
  - NotoSansJP  : kana + kanji có trong assets/*.json và chuỗi trong lib/**.dart.

Nguồn: https://github.com/google/fonts (OFL, giấy phép kèm ở assets/fonts/OFL.txt).
Kết quả (assets/fonts/*.ttf) được commit; script KHÔNG chạy trên CI/Vercel.
Dữ liệu đồng bộ sau này có kanji ngoài tập này thì rơi về font Google (khi
online) — chạy lại script để đưa vào gói.

Cần:  pip install --user fonttools
Chạy: python3 tools/subset-fonts.py [thư-mục-cache-font-gốc]   (mặc định: thư mục tạm)
"""

from __future__ import annotations

import importlib.util
import sys
import tempfile
import urllib.parse
import urllib.request
from pathlib import Path

from fontTools import subset
from fontTools.ttLib import TTFont
from fontTools.varLib import instancer

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "assets/fonts"
BASE = "https://github.com/google/fonts/raw/main/ofl/"
WEIGHTS = {"Regular": 400, "Bold": 700}

# (family, thư mục upstream, file upstream, trục cố định ngoài wght)
FAMILIES = [
    ("NotoSans", "notosans", "NotoSans[wdth,wght].ttf", {"wdth": 100}),
    ("NotoSansJP", "notosansjp", "NotoSansJP[wght].ttf", {}),
]

# Luôn có, bất kể dữ liệu: ASCII, Latin-1, Latin mở rộng + tiếng Việt, dấu
# chồng, dấu câu, kana đủ bộ, CJK punctuation, fullwidth.
ALWAYS = (
    list(range(0x20, 0x7F)) + list(range(0xA0, 0x180)) + [0x1A0, 0x1A1, 0x1AF, 0x1B0]
    + list(range(0x300, 0x328)) + list(range(0x1EA0, 0x1EFA))
    + list(range(0x2010, 0x2060)) + [0x20AB]
    + list(range(0x3000, 0x3100)) + list(range(0xFF00, 0xFFF0))
    + [0x25B2, 0x25BC, 0x2190, 0x2191, 0x2192, 0x2193]  # ▲▼←↑→↓ (Noto Sans JP có, Noto Sans không)
)

# Dùng chung bộ quét ký tự với check-font-coverage.py (một nguồn sự thật).
_spec = importlib.util.spec_from_file_location(
    "check_font_coverage", ROOT / "tools/check-font-coverage.py"
)
_check = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(_check)


def collect_chars() -> set[int]:
    return set(ALWAYS) | set(_check.used_chars())


def fetch(cache: Path, folder: str, name: str) -> Path:
    dest = cache / name
    if not dest.exists():
        url = BASE + folder + "/" + urllib.parse.quote(name)
        print("tải", url)
        cache.mkdir(parents=True, exist_ok=True)
        urllib.request.urlretrieve(url, dest)
    return dest


def build(src: Path, family: str, fixed: dict, chars: set[int]) -> None:
    for label, wght in WEIGHTS.items():
        font = TTFont(src)
        font = instancer.instantiateVariableFont(font, {"wght": wght, **fixed})
        opts = subset.Options()
        opts.layout_features = ["kern", "mark", "mkmk", "ccmp", "locl", "liga", "calt"]
        opts.hinting = False
        opts.desubroutinize = True
        opts.name_IDs = [1, 2, 3, 4, 6]
        opts.notdef_outline = True
        sub = subset.Subsetter(opts)
        sub.populate(unicodes=sorted(chars))
        sub.subset(font)
        out = OUT / f"{family}-{label}.ttf"
        font.save(out)
        print(f"{out.relative_to(ROOT)}  {out.stat().st_size / 1024:.0f} KB")


def main() -> int:
    cache = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(tempfile.gettempdir()) / "kotoba-font-cache"
    OUT.mkdir(parents=True, exist_ok=True)
    chars = collect_chars()
    cjk = sum(1 for c in chars if c >= 0x3400)
    print(f"{len(chars)} ký tự ({cjk} CJK/fullwidth)")
    fetch(cache, "notosans", "OFL.txt")
    (OUT / "OFL.txt").write_bytes((cache / "OFL.txt").read_bytes())
    for family, folder, name, fixed in FAMILIES:
        build(fetch(cache, folder, name), family, fixed, chars)
    # Ghi danh sách ký tự phủ cho test Dart, rồi kiểm luôn.
    sys.argv.append("--write")
    return _check.main()


if __name__ == "__main__":
    sys.exit(main())
