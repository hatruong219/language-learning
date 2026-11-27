#!/usr/bin/env python3
"""Sinh icon web/PWA cho Kotoba từ một ảnh nguồn vuông (assets/app-icon-source.png).

Dùng chung icon với app Kana Quiz trên desktop — hai công cụ học tiếng Nhật của
cùng một người thì nên nhận ra nhau ngay trên màn hình chính.

Ra (trong web/):
  icons/Icon-192.png, Icon-512.png            — "any", tràn viền
  icons/Icon-maskable-192.png, -512.png       — nền đặc + hình thu còn 80% (vùng an toàn)
  icons/apple-touch-icon.png                  — 180×180, không alpha (iOS tự bo góc)
  favicon.png                                 — 32×32

Chạy:  python3 tools/make-app-icon.py
"""

from __future__ import annotations

import sys
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / "assets/app-icon-source.png"
WEB = ROOT / "web"
SAFE = 0.80   # maskable: nội dung nằm trong 80% giữa


def corner_color(img: Image.Image) -> tuple[int, int, int]:
    """Màu nền: trung bình bốn góc, để vùng đệm của icon maskable liền với ảnh."""
    n = 24
    boxes = [(0, 0), (img.width - n, 0), (0, img.height - n), (img.width - n, img.height - n)]
    px = [img.crop((x, y, x + n, y + n)).resize((1, 1), Image.BOX).getpixel((0, 0)) for x, y in boxes]
    return tuple(sum(p[i] for p in px) // len(px) for i in range(3))  # type: ignore[return-value]


def maskable(img: Image.Image, px: int) -> Image.Image:
    canvas = Image.new("RGB", (px, px), corner_color(img))
    inner = round(px * SAFE)
    canvas.paste(img.resize((inner, inner), Image.LANCZOS), ((px - inner) // 2,) * 2)
    return canvas


def main() -> int:
    if not SOURCE.exists():
        print(f"Không thấy ảnh nguồn: {SOURCE}", file=sys.stderr)
        return 1
    img = Image.open(SOURCE).convert("RGB")
    if img.width != img.height:
        print(f"Ảnh nguồn không vuông: {img.size}", file=sys.stderr)
        return 1

    icons = WEB / "icons"
    icons.mkdir(parents=True, exist_ok=True)
    for px in (192, 512):
        img.resize((px, px), Image.LANCZOS).save(icons / f"Icon-{px}.png", optimize=True)
        maskable(img, px).save(icons / f"Icon-maskable-{px}.png", optimize=True)
    img.resize((180, 180), Image.LANCZOS).save(icons / "apple-touch-icon.png", optimize=True)
    img.resize((32, 32), Image.LANCZOS).save(WEB / "favicon.png", optimize=True)
    print(f"đã ghi icon web vào {WEB.relative_to(ROOT)}/ (nguồn {img.width}px)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
