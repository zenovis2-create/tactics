#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter


ROOT = Path("/Volumes/AI/tactics")
ROLE_DIR = ROOT / "assets/ui/production/unit_role_icons"
TOKEN_DIR = ROOT / "assets/ui/production/unit_token_art"

PALETTE = {
    "knight": ((218, 232, 255, 255), (110, 154, 214, 255)),
    "ranger": ((183, 240, 192, 255), (89, 162, 104, 255)),
    "mystic": ((236, 206, 255, 255), (148, 102, 187, 255)),
    "vanguard": ((255, 226, 154, 255), (190, 135, 62, 255)),
    "medic": ((255, 241, 205, 255), (186, 154, 102, 255)),
    "boss": ((255, 190, 190, 255), (185, 73, 73, 255)),
}


def _role_icon(kind: str, size: int = 28) -> Image.Image:
    fg, accent = PALETTE[kind]
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    if kind == "knight":
        d.rounded_rectangle((4, 4, size - 4, size - 4), radius=8, fill=(10, 18, 28, 70))
        d.polygon((size // 2, 4, size - 7, 10, size - 9, size - 5, 9, size - 5, 7, 10), outline=fg, width=2)
        d.line((9, size // 2, size - 9, size // 2), fill=accent, width=2)
    elif kind == "ranger":
        d.rounded_rectangle((4, 4, size - 4, size - 4), radius=8, fill=(10, 24, 16, 60))
        d.arc((5, 5, size - 5, size - 5), 300, 120, fill=fg, width=3)
        d.line((8, size - 8, size - 7, 8), fill=accent, width=2)
    elif kind == "mystic":
        d.rounded_rectangle((4, 4, size - 4, size - 4), radius=8, fill=(20, 12, 28, 70))
        d.ellipse((7, 7, size - 7, size - 7), outline=fg, width=2)
        d.line((size // 2, 5, size // 2, size - 5), fill=accent, width=2)
        d.line((5, size // 2, size - 5, size // 2), fill=accent, width=2)
    elif kind == "vanguard":
        d.rounded_rectangle((4, 4, size - 4, size - 4), radius=8, fill=(28, 20, 10, 70))
        d.polygon((size // 2, 5, size - 6, size // 2, size // 2, size - 5, 6, size // 2), outline=fg, width=2)
        d.line((8, size // 2 + 3, size - 8, size // 2 + 3), fill=accent, width=2)
    elif kind == "medic":
        d.rounded_rectangle((4, 4, size - 4, size - 4), radius=8, fill=(28, 24, 16, 70))
        d.line((size // 2, 6, size // 2, size - 6), fill=fg, width=3)
        d.line((6, size // 2, size - 6, size // 2), fill=fg, width=3)
        d.ellipse((7, 7, size - 7, size - 7), outline=accent, width=1)
    elif kind == "boss":
        d.rounded_rectangle((4, 4, size - 4, size - 4), radius=8, fill=(36, 10, 10, 75))
        d.polygon((size // 2, 4, size // 2 + 5, 11, size - 5, 10, size - 9, 17, size - 7, size - 7, size // 2, size - 12, 7, size - 7, 9, 17, 5, 10, size // 2 - 5, 11), outline=fg, width=2)
        d.arc((7, 10, size - 7, size - 4), 210, 330, fill=accent, width=2)
    return img


def _token_art(kind: str, size: int = 48) -> Image.Image:
    fg, accent = PALETTE[kind]
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    glow = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    gd = ImageDraw.Draw(glow)
    gd.ellipse((10, 10, size - 10, size - 10), fill=(fg[0], fg[1], fg[2], 38))
    glow = glow.filter(ImageFilter.GaussianBlur(4))
    img.alpha_composite(glow)
    d = ImageDraw.Draw(img)
    d.ellipse((8, 8, size - 8, size - 8), fill=(16, 22, 34, 110), outline=(255, 255, 255, 24), width=1)

    if kind == "knight":
        d.polygon((size // 2, 8, size - 12, 16, size - 15, size - 10, 15, size - 10, 12, 16), outline=fg, width=3)
        d.line((16, size // 2, size - 16, size // 2), fill=accent, width=3)
        d.line((size // 2, 16, size // 2, size - 14), fill=accent, width=2)
    elif kind == "ranger":
        d.arc((10, 10, size - 10, size - 10), 300, 120, fill=fg, width=4)
        d.line((15, size - 12, size - 13, 13), fill=accent, width=3)
        d.line((size - 18, 20, size - 10, 12), fill=accent, width=2)
    elif kind == "mystic":
        d.ellipse((13, 13, size - 13, size - 13), outline=fg, width=3)
        d.line((size // 2, 9, size // 2, size - 9), fill=accent, width=2)
        d.line((9, size // 2, size - 9, size // 2), fill=accent, width=2)
        d.arc((8, 8, size - 8, size - 8), 210, 330, fill=fg, width=2)
    elif kind == "vanguard":
        d.polygon((size // 2, 8, size - 10, size // 2, size // 2, size - 8, 10, size // 2), outline=fg, width=3)
        d.line((15, size // 2 + 5, size - 15, size // 2 + 5), fill=accent, width=3)
        d.line((size // 2, 15, size // 2, size - 14), fill=accent, width=2)
    elif kind == "medic":
        d.line((size // 2, 10, size // 2, size - 10), fill=fg, width=4)
        d.line((10, size // 2, size - 10, size // 2), fill=fg, width=4)
        d.ellipse((12, 12, size - 12, size - 12), outline=accent, width=2)
    elif kind == "boss":
        d.polygon((size // 2, 8, size // 2 + 7, 18, size - 8, 15, size - 14, 25, size - 10, size - 10, size // 2, size - 16, 10, size - 10, 14, 25, 8, 15, size // 2 - 7, 18), outline=fg, width=3)
        d.arc((10, 15, size - 10, size - 5), 210, 330, fill=accent, width=2)
    return img


def main() -> int:
    ROLE_DIR.mkdir(parents=True, exist_ok=True)
    TOKEN_DIR.mkdir(parents=True, exist_ok=True)
    for kind in PALETTE.keys():
        _role_icon(kind).save(ROLE_DIR / f"{kind}.png")
        _token_art(kind).save(TOKEN_DIR / f"{kind}.png")
    print("generated production unit art overrides")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
