#!/usr/bin/env python3
from pathlib import Path
import sys

from PIL import Image, ImageDraw, ImageFont


TILES = [
    ("Tutorial", "tutorial00000001.png"),
    ("CH03", "ch0300000001.png"),
    ("CH07", "ch0700000001.png"),
    ("CH10", "ch1000000001.png"),
    ("CH02-04", "ch02_0400000001.png"),
    ("CH09A-01", "ch09a_0100000001.png"),
    ("CH04-01", "ch04_0100000001.png"),
    ("CH08-01", "ch08_0100000001.png"),
]


def _load_font(size: int):
    for candidate in [
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
        "/System/Library/Fonts/Supplemental/Arial.ttf",
        "/System/Library/Fonts/SFNS.ttf",
    ]:
        path = Path(candidate)
        if path.exists():
            try:
                return ImageFont.truetype(str(path), size=size)
            except Exception:
                pass
    return ImageFont.load_default()


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: build_representative_contact_sheet.py <snapshot-dir>", file=sys.stderr)
        return 2

    snap_dir = Path(sys.argv[1])
    if not snap_dir.exists():
        print(f"missing snapshot dir: {snap_dir}", file=sys.stderr)
        return 1

    card_width = 480
    card_height = 270
    columns = 2
    rows = 4
    gutter = 28
    margin = 44
    label_height = 34
    header_height = 78

    canvas_width = margin * 2 + columns * card_width + (columns - 1) * gutter
    canvas_height = margin * 2 + header_height + rows * (card_height + label_height) + (rows - 1) * gutter

    canvas = Image.new("RGBA", (canvas_width, canvas_height), (17, 21, 33, 255))
    draw = ImageDraw.Draw(canvas)

    draw.rectangle([0, 0, canvas_width, canvas_height], fill=(18, 22, 36, 255))
    draw.rectangle([0, 0, canvas_width, 120], fill=(23, 29, 45, 255))
    draw.ellipse([canvas_width - 260, -40, canvas_width + 40, 220], fill=(88, 45, 70, 120))
    draw.ellipse([-80, 110, 220, 340], fill=(36, 58, 105, 120))

    title_font = _load_font(28)
    subtitle_font = _load_font(15)
    label_font = _load_font(20)

    draw.text((margin, margin - 4), "Ashen Bell Battle Mood Board", font=title_font, fill=(238, 244, 252, 255))
    draw.text(
        (margin, margin + 34),
        "Tutorial, CH03, CH07, CH10, CH02-04, CH09A-01, CH04-01, CH08-01 representative battle frames",
        font=subtitle_font,
        fill=(178, 191, 215, 255),
    )

    for idx, (label, filename) in enumerate(TILES):
        src = snap_dir / filename
        if not src.exists():
            continue
        image = Image.open(src).convert("RGBA").resize((card_width, card_height), Image.Resampling.LANCZOS)
        col = idx % columns
        row = idx // columns
        x = margin + col * (card_width + gutter)
        y = margin + header_height + row * (card_height + label_height + gutter)

        shadow_box = [x + 8, y + 10, x + card_width + 8, y + card_height + 10]
        draw.rounded_rectangle(shadow_box, radius=18, fill=(0, 0, 0, 90))
        draw.rounded_rectangle([x - 4, y - 4, x + card_width + 4, y + card_height + 4], radius=20, fill=(31, 39, 60, 255))
        canvas.alpha_composite(image, (x, y))
        draw.rounded_rectangle([x, y, x + card_width, y + card_height], radius=16, outline=(246, 214, 119, 180), width=2)

        label_y = y + card_height + 8
        draw.rounded_rectangle([x, label_y, x + 132, label_y + 26], radius=10, fill=(26, 33, 52, 255), outline=(77, 101, 147, 180), width=1)
        draw.text((x + 14, label_y + 3), label, font=label_font, fill=(237, 242, 250, 255))

    output = snap_dir / "representative_contact_sheet.png"
    canvas.save(output)
    print(str(output))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
