#!/usr/bin/env python3
"""Kiểm mọi ký tự UI dùng đều có trong font đóng gói; sinh danh sách phủ.

  python3 tools/check-font-coverage.py           # kiểm, thoát 1 nếu thiếu
  python3 tools/check-font-coverage.py --write   # ghi lại tools/font-coverage.txt

`tools/font-coverage.txt` là hợp cmap của các TTF trong assets/fonts (mỗi dòng
một mã Unicode, hex). Test Dart `test/font_coverage_test.dart` đọc file này để
khỏi phải parse TTF; chạy --write mỗi khi sinh lại font (subset-fonts.py tự gọi).

Ký tự thiếu glyph khiến CanvasKit tải font Noto từ fonts.gstatic.com lúc chạy.
Cần: pip install --user fonttools
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

from fontTools.ttLib import TTFont

ROOT = Path(__file__).resolve().parent.parent
COVERAGE = ROOT / "tools/font-coverage.txt"

# Khớp với test/font_coverage_test.dart: chuỗi nháy đơn/kép (cả '''/""").
STRING_RE = re.compile(r"'(?:\\.|[^'\\\n])*'|\"(?:\\.|[^\"\\\n])*\"")
ESC_RE = re.compile(r"\\u\{([0-9a-fA-F]+)\}|\\u([0-9a-fA-F]{4})|\\x([0-9a-fA-F]{2})")


def decode_escapes(lit: str) -> str:
    return ESC_RE.sub(lambda m: chr(int(m.group(1) or m.group(2) or m.group(3), 16)), lit)


def used_chars() -> dict[int, str]:
    """Mã -> nơi dùng đầu tiên."""
    used: dict[int, str] = {}
    for f in sorted((ROOT / "assets").glob("*.json")):
        for ch in f.read_text(encoding="utf-8"):
            used.setdefault(ord(ch), str(f.relative_to(ROOT)))
    for f in sorted((ROOT / "lib").rglob("*.dart")):
        for line in f.read_text(encoding="utf-8").splitlines():
            # Biểu thức chính quy chỉ để so khớp, không hiển thị: bỏ qua.
            if "RegExp(" in line:
                continue
            for lit in STRING_RE.findall(line):
                for ch in decode_escapes(lit):
                    used.setdefault(ord(ch), str(f.relative_to(ROOT)))
    return {c: w for c, w in used.items() if c >= 0x20}


def covered_chars() -> set[int]:
    sets = []
    for ttf in sorted((ROOT / "assets/fonts").glob("*.ttf")):
        sets.append(set(TTFont(ttf).getBestCmap()))
    # Một ký tự chỉ an toàn khi MỘT font nào đó có cho cả hai độ đậm.
    reg = set().union(*(s for p, s in zip(sorted((ROOT / "assets/fonts").glob("*.ttf")), sets) if "Regular" in p.name))
    bold = set().union(*(s for p, s in zip(sorted((ROOT / "assets/fonts").glob("*.ttf")), sets) if "Bold" in p.name))
    return reg & bold


def main() -> int:
    cov = covered_chars()
    if "--write" in sys.argv:
        COVERAGE.write_text("".join(f"{c:X}\n" for c in sorted(cov)), encoding="ascii")
        print(f"ghi {COVERAGE.relative_to(ROOT)}: {len(cov)} mã")
    missing = {c: w for c, w in used_chars().items() if c not in cov}
    for c, w in sorted(missing.items()):
        print(f"THIẾU U+{c:04X} {chr(c)!r}  ({w})")
    print("OK" if not missing else f"{len(missing)} ký tự thiếu")
    return 1 if missing else 0


if __name__ == "__main__":
    sys.exit(main())
