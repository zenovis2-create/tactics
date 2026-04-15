#!/usr/bin/env python3
"""
Ashen Bell — Art Asset Generator
Generates production-quality PNG icons for unit tokens, object icons, FX, terrain, and HUD.
Visual style: classic tactical JRPG, dark board base, bold silhouettes, transparent backgrounds.
"""

import math
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter

BASE = Path("/Volumes/AI/tactics/assets/ui")

# ── Palette ──────────────────────────────────────────────────────────────────
GOLD        = (201, 168, 76,  255)
GOLD_DARK   = (120,  96, 32,  255)
SILVER      = (168, 164, 160, 255)
SILVER_DARK = ( 90,  86, 82,  255)
GREEN       = ( 94, 139, 78,  255)
GREEN_DARK  = ( 44,  80, 34,  255)
CYAN        = (126, 207, 207, 255)
CYAN_DARK   = ( 56, 130, 130, 255)
SKY         = (126, 184, 207, 255)
SKY_DARK    = ( 56, 108, 130, 255)
RED         = (204,  58,  47,  255)
RED_DARK    = (110,  24,  16,  255)
BONE        = (220, 210, 188, 255)
BONE_DARK   = (130, 120, 100, 255)
EMBER       = (220, 120,  40,  255)
EMBER_DARK  = (130,  60,  12,  255)
PURPLE      = (160, 100, 200, 255)
PURPLE_DARK = ( 80,  40, 120, 255)
TRANSPARENT = (0, 0, 0, 0)

def new_img(size):
    return Image.new("RGBA", (size, size), TRANSPARENT)

def outline_poly(draw, pts, fill, outline, width=3):
    draw.polygon(pts, fill=fill, outline=outline)
    # Re-draw outline explicitly for thickness
    for i in range(len(pts)):
        p1 = pts[i]
        p2 = pts[(i + 1) % len(pts)]
        draw.line([p1, p2], fill=outline, width=width)

def circle(draw, cx, cy, r, fill, outline=None, width=2):
    draw.ellipse([cx-r, cy-r, cx+r, cy+r], fill=fill, outline=outline, width=width)

def ring(draw, cx, cy, r_outer, r_inner, fill):
    """Draw a ring (annulus)."""
    # Draw filled outer circle then punch inner transparent
    draw.ellipse([cx-r_outer, cy-r_outer, cx+r_outer, cy+r_outer], fill=fill)
    draw.ellipse([cx-r_inner, cy-r_inner, cx+r_inner, cy+r_inner], fill=TRANSPARENT)

def rounded_rect(draw, x0, y0, x1, y1, radius, fill, outline=None, width=2):
    draw.rounded_rectangle([x0, y0, x1, y1], radius=radius, fill=fill, outline=outline, width=width)

# ─────────────────────────────────────────────────────────────────────────────
# UNIT TOKEN ART  (48×48)
# ─────────────────────────────────────────────────────────────────────────────

def gen_vanguard(size=48):
    """Bold upward chevron/shield — heavy melee frontliner, gold."""
    img = new_img(size)
    d = ImageDraw.Draw(img)
    cx, cy = size // 2, size // 2
    m = 5  # margin

    # Shield base: hexagonal-ish shield shape
    shield = [
        (cx, m),           # top
        (size-m, m+8),     # top-right
        (size-m, cy+4),    # right
        (cx, size-m),      # bottom point
        (m, cy+4),         # left
        (m, m+8),          # top-left
    ]
    outline_poly(d, shield, GOLD, GOLD_DARK, width=3)

    # Inner chevron mark
    chev = [
        (cx, m+10),
        (cx+10, cy),
        (cx+6, cy),
        (cx, m+18),
        (cx-6, cy),
        (cx-10, cy),
    ]
    d.polygon(chev, fill=GOLD_DARK)
    return img

def gen_knight(size=48):
    """Cross + tower base — armored defender, silver."""
    img = new_img(size)
    d = ImageDraw.Draw(img)
    cx, cy = size // 2, size // 2
    m = 5

    # Tower/castle crenellation silhouette
    tower_pts = [
        (m+2, size-m),       # bottom-left
        (m+2, cy),           # left mid
        (m+2, cy-4), (m+6, cy-4), (m+6, cy),   # left crenel
        (cx-5, cy),
        (cx-5, m+2),         # left column top
        (cx-2, m+2), (cx-2, m+6), (cx+2, m+6), (cx+2, m+2),  # center merlons
        (cx+5, m+2),         # right column top
        (cx+5, cy),
        (size-m-6, cy), (size-m-6, cy-4), (size-m-2, cy-4), (size-m-2, cy),  # right crenel
        (size-m-2, size-m),  # bottom-right
    ]
    d.polygon(tower_pts, fill=SILVER, outline=SILVER_DARK)

    # Cross overlay
    bar_w = 5
    cross_pts_v = [(cx-bar_w//2, m+4), (cx+bar_w//2, m+4),
                   (cx+bar_w//2, size-m-4), (cx-bar_w//2, size-m-4)]
    cross_pts_h = [(m+4, cy-bar_w//2), (size-m-4, cy-bar_w//2),
                   (size-m-4, cy+bar_w//2), (m+4, cy+bar_w//2)]
    d.polygon(cross_pts_v, fill=SILVER_DARK)
    d.polygon(cross_pts_h, fill=SILVER_DARK)
    return img

def gen_ranger(size=48):
    """Bow arc + arrow — light scout, moss green."""
    img = new_img(size)
    d = ImageDraw.Draw(img)
    cx, cy = size // 2, size // 2
    m = 6

    # Leaf/feather background shape
    leaf = [
        (cx, m),
        (size-m, cy),
        (cx, size-m),
        (m, cy),
    ]
    d.polygon(leaf, fill=GREEN, outline=GREEN_DARK)

    # Bow arc (left half circle)
    bow_r = 12
    bbox = [cx-bow_r-4, cy-bow_r, cx+bow_r-4, cy+bow_r]
    d.arc(bbox, start=300, end=60, fill=GREEN_DARK, width=4)

    # Bowstring
    d.line([(cx-4, cy-bow_r+2), (cx-4, cy+bow_r-2)], fill=GREEN_DARK, width=2)

    # Arrow shaft + head
    d.line([(cx-2, cy), (cx+14, cy)], fill=BONE, width=2)
    arrow_head = [(cx+14, cy-3), (cx+20, cy), (cx+14, cy+3)]
    d.polygon(arrow_head, fill=BONE)
    return img

def gen_mystic(size=48):
    """Arcane orb with radial arcs — spellcaster, pale cyan."""
    img = new_img(size)
    d = ImageDraw.Draw(img)
    cx, cy = size // 2, size // 2
    m = 5

    # Outer glow ring
    ring(d, cx, cy, size//2-m, size//2-m-5, CYAN_DARK)

    # Inner orb
    orb_r = 12
    circle(d, cx, cy, orb_r, CYAN, CYAN_DARK, width=2)

    # Three radiating arcs
    for angle in [0, 120, 240]:
        rad = math.radians(angle)
        sx = cx + int((orb_r+1) * math.cos(rad))
        sy = cy + int((orb_r+1) * math.sin(rad))
        ex = cx + int((size//2-m-2) * math.cos(rad))
        ey = cy + int((size//2-m-2) * math.sin(rad))
        d.line([(sx, sy), (ex, ey)], fill=CYAN_DARK, width=3)
        circle(d, ex, ey, 3, CYAN, CYAN_DARK, width=1)

    # Small center dot
    circle(d, cx, cy, 4, BONE)
    return img

def gen_medic(size=48):
    """Bold plus cross with teardrop below — healer support, sky blue."""
    img = new_img(size)
    d = ImageDraw.Draw(img)
    cx, cy = size // 2, size // 2 - 3
    m = 6

    # Background circle
    circle(d, cx, cy+3, size//2-m, SKY, SKY_DARK, width=2)

    # Bold plus
    arm = 10
    thick = 5
    cross_v = [(cx-thick, cy-arm-2), (cx+thick, cy-arm-2),
               (cx+thick, cy+arm+2), (cx-thick, cy+arm+2)]
    cross_h = [(cx-arm-2, cy-thick), (cx+arm+2, cy-thick),
               (cx+arm+2, cy+thick), (cx-arm-2, cy+thick)]
    d.polygon(cross_v, fill=BONE, outline=SKY_DARK, width=1)
    d.polygon(cross_h, fill=BONE, outline=SKY_DARK, width=1)

    # Center square
    d.rectangle([cx-thick, cy-thick, cx+thick, cy+thick], fill=BONE)
    return img

def gen_boss(size=48):
    """Crown with spike mark — enemy commander, ember red, heavier."""
    img = new_img(size)
    d = ImageDraw.Draw(img)
    cx, cy = size // 2, size // 2
    m = 4

    # Heavy pentagon base
    base = [
        (m+2, cy+4),
        (cx, size-m-2),
        (size-m-2, cy+4),
        (size-m-2, m+14),
        (m+2, m+14),
    ]
    d.polygon(base, fill=RED, outline=RED_DARK)
    for i in range(len(base)):
        p1 = base[i]; p2 = base[(i+1)%len(base)]
        d.line([p1, p2], fill=RED_DARK, width=3)

    # Crown spikes (3 upward points)
    crown = [
        (m+2, m+14),       # left base
        (m+2, m+2),        # left spike top
        (cx-4, m+10),      # left valley
        (cx, m),           # center spike top
        (cx+4, m+10),      # right valley
        (size-m-2, m+2),   # right spike top
        (size-m-2, m+14),  # right base
    ]
    d.polygon(crown, fill=RED_DARK, outline=RED_DARK)
    for i in range(len(crown)-1):
        d.line([crown[i], crown[i+1]], fill=(80,10,5,255), width=2)

    # Skull/mark symbol in center
    skull_cx, skull_cy = cx, cy + 4
    # Eye sockets
    circle(d, skull_cx-5, skull_cy-3, 3, BONE)
    circle(d, skull_cx+5, skull_cy-3, 3, BONE)
    # Jaw line
    d.line([(skull_cx-6, skull_cy+4), (skull_cx+6, skull_cy+4)], fill=BONE, width=2)
    d.line([(skull_cx-3, skull_cy+4), (skull_cx-3, skull_cy+8)], fill=BONE, width=2)
    d.line([(skull_cx+3, skull_cy+4), (skull_cx+3, skull_cy+8)], fill=BONE, width=2)
    return img

# ─────────────────────────────────────────────────────────────────────────────
# UNIT ROLE ICONS  (28×28)
# ─────────────────────────────────────────────────────────────────────────────

def scale_token_to_icon(img, size=28):
    """Downscale token to role icon size."""
    return img.resize((size, size), Image.LANCZOS)

# ─────────────────────────────────────────────────────────────────────────────
# OBJECT ICONS  (40×40)
# ─────────────────────────────────────────────────────────────────────────────

def gen_chest(size=40):
    """Treasure chest — supply reward."""
    img = new_img(size)
    d = ImageDraw.Draw(img)
    m = 4
    # Chest body
    rounded_rect(d, m, size//2-2, size-m, size-m, 3, GOLD, GOLD_DARK, width=3)
    # Chest lid (rounded top)
    lid = [(m, size//2-2), (size-m, size//2-2), (size-m, m+6),
           (size-m-4, m), (m+4, m)]
    d.polygon(lid, fill=GOLD, outline=GOLD_DARK)
    for i in range(len(lid)-1):
        d.line([lid[i], lid[i+1]], fill=GOLD_DARK, width=2)
    # Lock hasp
    cx = size//2
    circle(d, cx, size//2, 4, BONE, GOLD_DARK, width=2)
    d.rectangle([cx-3, size//2, cx+3, size//2+5], fill=BONE, outline=GOLD_DARK, width=1)
    # Horizontal band
    d.line([(m+2, size//2-2), (size-m-2, size//2-2)], fill=GOLD_DARK, width=2)
    return img

def gen_lever(size=40):
    """Control lever/wheel — mechanism."""
    img = new_img(size)
    d = ImageDraw.Draw(img)
    cx, cy = size//2, size//2
    m = 5

    # Gear/wheel ring
    ring(d, cx, cy, size//2-m, size//2-m-7, SILVER)
    # Gear teeth (8 rects around perimeter)
    for i in range(8):
        angle = math.radians(i * 45)
        tx = cx + int((size//2-m-2) * math.cos(angle))
        ty = cy + int((size//2-m-2) * math.sin(angle))
        d.ellipse([tx-3, ty-3, tx+3, ty+3], fill=SILVER_DARK)

    # Lever arm
    d.line([(cx, cy), (size-m-2, m+2)], fill=BONE, width=5)
    circle(d, size-m-4, m+4, 4, BONE, SILVER_DARK, width=2)

    # Center hub
    circle(d, cx, cy, 5, BONE, SILVER_DARK, width=2)
    return img

def gen_altar(size=40):
    """Ritual altar/anchor — inspection point."""
    img = new_img(size)
    d = ImageDraw.Draw(img)
    cx, cy = size//2, size//2
    m = 4

    # Pedestal base
    d.trapezoid([(m, size-m), (size-m, size-m), (size-m-4, cy+4), (m+4, cy+4)],
                fill=BONE_DARK, outline=BONE, width=2) if hasattr(d, 'trapezoid') else \
        d.polygon([(m, size-m), (size-m, size-m), (size-m-4, cy+4), (m+4, cy+4)],
                  fill=BONE_DARK, outline=BONE)

    # Altar top slab
    rounded_rect(d, m-2, cy, size-m+2, cy+6, 2, BONE, BONE_DARK, width=2)

    # Runic circle on top
    circle(d, cx, cy-6, 10, TRANSPARENT, PURPLE, width=2)
    circle(d, cx, cy-6, 5, TRANSPARENT, PURPLE, width=2)
    # Cross inside circle
    d.line([(cx, cy-16), (cx, cy+4)], fill=PURPLE, width=2)
    d.line([(cx-10, cy-6), (cx+10, cy-6)], fill=PURPLE, width=2)

    # Candle flames (2 sides)
    for fx in [cx-8, cx+8]:
        circle(d, fx, m+4, 3, EMBER, EMBER_DARK, width=1)
        d.line([(fx, m+7), (fx, cy-2)], fill=BONE_DARK, width=2)
    return img

def gen_gate(size=40):
    """Gate/door — barrier, access control."""
    img = new_img(size)
    d = ImageDraw.Draw(img)
    m = 4
    cx = size // 2

    # Stone arch frame
    arch_pts = [
        (m, size-m),         # bottom-left
        (m, size//3),        # left pillar mid
        (m+2, m+6),          # left arch start
        (cx, m),             # arch peak
        (size-m-2, m+6),     # right arch start
        (size-m, size//3),   # right pillar mid
        (size-m, size-m),    # bottom-right
        (size-m-5, size-m),  # inner bottom-right
        (size-m-5, size//3+2),
        (cx+3, m+8),
        (cx, m+4),
        (cx-3, m+8),
        (m+5, size//3+2),
        (m+5, size-m),       # inner bottom-left
    ]
    d.polygon(arch_pts, fill=SILVER_DARK, outline=SILVER)
    for i in range(len(arch_pts)-1):
        d.line([arch_pts[i], arch_pts[i+1]], fill=SILVER, width=2)

    # Door panels (2 sides, slightly open)
    left_door = [(m+5, size//3+2), (cx-2, size//3+2),
                 (cx-2, size-m-1), (m+5, size-m-1)]
    right_door = [(cx+2, size//3+2), (size-m-5, size//3+2),
                  (size-m-5, size-m-1), (cx+2, size-m-1)]
    d.polygon(left_door, fill=BONE_DARK, outline=BONE)
    d.polygon(right_door, fill=BONE_DARK, outline=BONE)

    # Door handles
    circle(d, cx-4, size*2//3, 2, GOLD)
    circle(d, cx+4, size*2//3, 2, GOLD)
    return img

# ─────────────────────────────────────────────────────────────────────────────
# COMBAT FX  (64×64)
# ─────────────────────────────────────────────────────────────────────────────

def gen_hit_spark(size=64):
    """Pale gold / warm white melee hit spark."""
    img = new_img(size)
    d = ImageDraw.Draw(img)
    cx, cy = size//2, size//2

    # Radial burst lines (8 directions)
    spark_color = (255, 240, 160, 220)
    spark_dark  = (200, 160, 60, 200)
    for i in range(8):
        angle = math.radians(i * 45)
        # Long primary lines
        length = 22 if i % 2 == 0 else 14
        ex = cx + int(length * math.cos(angle))
        ey = cy + int(length * math.sin(angle))
        width = 3 if i % 2 == 0 else 2
        d.line([(cx, cy), (ex, ey)], fill=spark_color, width=width)

    # 4 angled slash lines (X shape)
    for angle_deg in [30, 60, 120, 150]:
        angle = math.radians(angle_deg)
        ex = cx + int(16 * math.cos(angle))
        ey = cy + int(16 * math.sin(angle))
        sx = cx - int(16 * math.cos(angle))
        sy = cy - int(16 * math.sin(angle))
        d.line([(sx, sy), (ex, ey)], fill=spark_dark, width=2)

    # Core flash
    circle(d, cx, cy, 6, (255, 255, 200, 240))
    circle(d, cx, cy, 3, (255, 255, 255, 255))

    # Soft glow (blur overlay)
    glow = new_img(size)
    gd = ImageDraw.Draw(glow)
    circle(gd, cx, cy, 18, (255, 220, 100, 80))
    glow = glow.filter(ImageFilter.GaussianBlur(8))
    img = Image.alpha_composite(glow, img)
    return img

def gen_mark_ring(size=64):
    """Pink-violet boss mark ring — ritual threat."""
    img = new_img(size)
    d = ImageDraw.Draw(img)
    cx, cy = size//2, size//2
    r_outer = size//2 - 6
    r_inner = r_outer - 7

    # Outer ring
    ring_color = (200, 80, 220, 200)
    ring_dark  = (120, 40, 160, 220)
    ring(d, cx, cy, r_outer, r_inner, ring_dark)

    # 6 rune dots on ring
    for i in range(6):
        angle = math.radians(i * 60 - 90)
        rx = cx + int((r_outer + r_inner)//2 * math.cos(angle))
        ry = cy + int((r_outer + r_inner)//2 * math.sin(angle))
        circle(d, rx, ry, 4, ring_color)

    # Inner triangle mark
    tri_r = r_inner - 6
    tri_pts = []
    for i in range(3):
        angle = math.radians(i * 120 - 90)
        tri_pts.append((cx + int(tri_r * math.cos(angle)),
                        cy + int(tri_r * math.sin(angle))))
    d.polygon(tri_pts, fill=TRANSPARENT, outline=ring_color)
    for i in range(3):
        d.line([tri_pts[i], tri_pts[(i+1)%3]], fill=ring_color, width=2)

    # Center boss mark (X with circle)
    circle(d, cx, cy, 6, TRANSPARENT, ring_color, width=2)
    d.line([(cx-5, cy-5), (cx+5, cy+5)], fill=ring_color, width=2)
    d.line([(cx+5, cy-5), (cx-5, cy+5)], fill=ring_color, width=2)

    # Soft glow
    glow = new_img(size)
    gd = ImageDraw.Draw(glow)
    ring(gd, cx, cy, r_outer+4, r_inner-4, (160, 50, 190, 60))
    glow = glow.filter(ImageFilter.GaussianBlur(10))
    img = Image.alpha_composite(glow, img)
    return img

def gen_objective_burst(size=64):
    """Gold objective resolve burst."""
    img = new_img(size)
    d = ImageDraw.Draw(img)
    cx, cy = size//2, size//2

    burst_gold   = (255, 220, 80, 230)
    burst_bright = (255, 255, 200, 255)
    burst_dark   = (180, 140, 30, 200)

    # 12-pointed star burst
    pts = []
    for i in range(24):
        angle = math.radians(i * 15 - 90)
        r = 26 if i % 2 == 0 else 14
        pts.append((cx + int(r * math.cos(angle)),
                    cy + int(r * math.sin(angle))))
    d.polygon(pts, fill=burst_gold, outline=burst_dark)

    # Inner ring
    circle(d, cx, cy, 12, burst_gold, burst_dark, width=2)

    # Checkmark in center
    check_pts = [(cx-7, cy), (cx-2, cy+6), (cx+8, cy-7)]
    d.line(check_pts, fill=burst_bright, width=4)

    # Core flash
    circle(d, cx, cy, 4, burst_bright)

    # Soft glow
    glow = new_img(size)
    gd = ImageDraw.Draw(glow)
    circle(gd, cx, cy, 28, (255, 200, 60, 80))
    glow = glow.filter(ImageFilter.GaussianBlur(12))
    img = Image.alpha_composite(glow, img)
    return img

# ─────────────────────────────────────────────────────────────────────────────
# TERRAIN ICONS  (24×24) + TERRAIN CARDS  (48×48)
# ─────────────────────────────────────────────────────────────────────────────

TERRAIN_DEFS = {
    # name: (fg_color, bg_color, symbol_fn_name)
    "forest":     (GREEN, GREEN_DARK, "tree"),
    "wall":       (SILVER, SILVER_DARK, "wall"),
    "highground": (BONE, BONE_DARK, "mountain"),
    "battery":    (EMBER, EMBER_DARK, "lightning"),
    "bridge":     (BONE_DARK, SILVER_DARK, "bridge"),
    "bell":       (GOLD, GOLD_DARK, "bell"),
    "cathedral":  (PURPLE, PURPLE_DARK, "arch"),
}

def gen_terrain_icon(name, fg, bg, size=24):
    """Small 24×24 terrain pictogram."""
    img = new_img(size)
    d = ImageDraw.Draw(img)
    cx, cy = size//2, size//2
    m = 2

    # Background circle
    circle(d, cx, cy, size//2-m, bg)

    # Symbol (simplified)
    if name == "forest":
        # Pine tree
        tri = [(cx, m+1), (cx-7, size-m-4), (cx+7, size-m-4)]
        d.polygon(tri, fill=fg)
        tri2 = [(cx, m+4), (cx-5, cy+1), (cx+5, cy+1)]
        d.polygon(tri2, fill=fg)
        d.rectangle([cx-2, size-m-5, cx+2, size-m-2], fill=fg)

    elif name == "wall":
        # Brick pattern
        d.rectangle([m+1, cy-3, size-m-1, cy+3], fill=fg)
        d.rectangle([m+1, m+2, size-m-1, cy-2], fill=fg)
        for x in [cx, m+2, size-m-5]:
            d.line([(x, m+2), (x, cy-2)], fill=bg, width=1)
        d.line([(cx-3, cy-2), (cx-3, cy+3)], fill=bg, width=1)
        d.line([(cx+3, cy+3), (cx+3, size-m-2)], fill=bg, width=1)

    elif name == "highground":
        # Mountain silhouette
        tri = [(cx, m+1), (cx-8, size-m-2), (cx+8, size-m-2)]
        d.polygon(tri, fill=fg)
        d.polygon([(cx-4, m+6), (cx-10, size-m-2), (cx+2, size-m-2)], fill=bg)
        # Snow cap
        cap = [(cx, m+1), (cx-3, m+6), (cx+3, m+6)]
        d.polygon(cap, fill=(220,220,220,220))

    elif name == "battery":
        # Lightning bolt
        bolt = [(cx+2, m+1), (cx-4, cy), (cx+1, cy), (cx-2, size-m-1), (cx+5, cy+1), (cx, cy+1)]
        d.polygon(bolt, fill=fg)

    elif name == "bridge":
        # Two arches
        d.arc([m+1, cy-3, cx, size-m-2], start=180, end=0, fill=fg, width=3)
        d.arc([cx, cy-3, size-m-1, size-m-2], start=180, end=0, fill=fg, width=3)
        d.line([(m+1, size-m-2), (size-m-1, size-m-2)], fill=fg, width=2)

    elif name == "bell":
        # Bell silhouette
        bell_pts = [(cx, m+1), (cx+5, m+5), (cx+7, cy+2),
                    (cx+4, cy+5), (cx-4, cy+5), (cx-7, cy+2),
                    (cx-5, m+5)]
        d.polygon(bell_pts, fill=fg)
        circle(d, cx, cy+5, 2, fg)
        d.line([(cx-3, cy+7), (cx+3, cy+7)], fill=fg, width=2)

    elif name == "cathedral":
        # Gothic arch
        d.arc([cx-6, m+1, cx+6, cy+2], start=180, end=0, fill=fg, width=3)
        d.line([(cx-6, m+6), (cx-6, size-m-2)], fill=fg, width=3)
        d.line([(cx+6, m+6), (cx+6, size-m-2)], fill=fg, width=3)
        d.line([(cx-6, size-m-2), (cx+6, size-m-2)], fill=fg, width=3)
        # Cross on top
        d.line([(cx, m+1), (cx, m-2)], fill=fg, width=2)
        d.line([(cx-2, m), (cx+2, m)], fill=fg, width=2)

    return img

def scale_to_card(icon, size=48):
    """Scale 24px icon to 48px card (terrain card = larger stamp version)."""
    card = icon.resize((size, size), Image.NEAREST)
    # Add subtle outer glow
    glow = card.filter(ImageFilter.GaussianBlur(4))
    result = Image.alpha_composite(glow, card)
    return result

# ─────────────────────────────────────────────────────────────────────────────
# HUD COMMAND ICONS  (32×32)
# ─────────────────────────────────────────────────────────────────────────────

HUD_BG   = (40, 36, 32, 200)
HUD_ICON = (220, 200, 160, 255)
HUD_DARK = (100, 90, 70, 255)

def gen_hud_bag(size=32):
    """Inventory bag icon."""
    img = new_img(size)
    d = ImageDraw.Draw(img)
    m = 4
    cx = size//2

    # Bag body
    rounded_rect(d, m, size//3, size-m, size-m, 4, HUD_ICON, HUD_DARK, width=2)
    # Bag strap loop
    d.arc([cx-5, m, cx+5, size//3+2], start=200, end=340, fill=HUD_ICON, width=3)
    # Flap line
    d.line([(m+2, size//3+5), (size-m-2, size//3+5)], fill=HUD_DARK, width=2)
    # Buckle
    rounded_rect(d, cx-4, size//3+2, cx+4, size//3+8, 1, HUD_DARK, HUD_ICON, width=1)
    return img

def gen_hud_back(size=32):
    """Back/undo arrow icon."""
    img = new_img(size)
    d = ImageDraw.Draw(img)
    m = 5
    cx, cy = size//2, size//2

    # Left-pointing arrow
    arrow_pts = [
        (m+2, cy),         # arrow tip
        (cx+2, m+2),       # top-right of head
        (cx+2, cy-3),      # head bottom-right inner
        (size-m, cy-3),    # shaft top-right
        (size-m, cy+3),    # shaft bottom-right
        (cx+2, cy+3),      # head top-left inner
        (cx+2, size-m-2),  # bottom-right of head
    ]
    d.polygon(arrow_pts, fill=HUD_ICON, outline=HUD_DARK)
    for i in range(len(arrow_pts)):
        d.line([arrow_pts[i], arrow_pts[(i+1)%len(arrow_pts)]], fill=HUD_DARK, width=2)
    return img

def gen_hud_wait(size=32):
    """Wait/hourglass icon."""
    img = new_img(size)
    d = ImageDraw.Draw(img)
    m = 5
    cx, cy = size//2, size//2

    # Hourglass shape
    hg = [
        (m, m+2),           # top-left
        (size-m, m+2),      # top-right
        (cx+2, cy),         # mid-right
        (size-m, size-m-2), # bottom-right
        (m, size-m-2),      # bottom-left
        (cx-2, cy),         # mid-left
    ]
    d.polygon(hg, fill=HUD_ICON, outline=HUD_DARK)
    for i in range(len(hg)):
        d.line([hg[i], hg[(i+1)%len(hg)]], fill=HUD_DARK, width=2)

    # Top + bottom lines
    d.line([(m, m+2), (size-m, m+2)], fill=HUD_DARK, width=3)
    d.line([(m, size-m-2), (size-m, size-m-2)], fill=HUD_DARK, width=3)

    # Sand fill (bottom triangle)
    sand = [(m+3, size-m-3), (size-m-3, size-m-3), (cx, cy+3)]
    d.polygon(sand, fill=HUD_DARK)
    return img

def gen_hud_enemy(size=32):
    """Enemy turn / end turn icon — crossed swords."""
    img = new_img(size)
    d = ImageDraw.Draw(img)
    m = 5
    cx, cy = size//2, size//2

    # Diagonal sword 1 (top-left to bottom-right)
    d.line([(m, m), (size-m, size-m)], fill=RED, width=4)
    # Sword 2 (top-right to bottom-left)
    d.line([(size-m, m), (m, size-m)], fill=RED, width=4)

    # Crossguard on sword 1
    d.line([(m+5, cy-5), (m+5+8, cy-5+8)], fill=HUD_ICON, width=3)
    # Crossguard on sword 2
    d.line([(size-m-5, cy-5), (size-m-5-8, cy-5+8)], fill=HUD_ICON, width=3)

    # Center diamond
    center_dia = [(cx, cy-4), (cx+4, cy), (cx, cy+4), (cx-4, cy)]
    d.polygon(center_dia, fill=(255, 80, 60, 220))
    return img

# ─────────────────────────────────────────────────────────────────────────────
# MAIN RUNNER
# ─────────────────────────────────────────────────────────────────────────────

def ensure_dir(path: Path):
    path.mkdir(parents=True, exist_ok=True)

def save(img: Image.Image, path: Path):
    img.save(str(path), "PNG")
    print(f"  ✓ {path.relative_to(BASE.parent.parent)}")

def main():
    print("=== Ashen Bell Art Asset Generator ===\n")

    # ── Unit Token Art  (48×48) ───────────────────────────────────────────────
    print("[ Unit Token Art 48×48 ]")
    token_dir = BASE / "unit_token_art_generated"
    ensure_dir(token_dir)
    tokens = {
        "vanguard": gen_vanguard(),
        "knight":   gen_knight(),
        "ranger":   gen_ranger(),
        "mystic":   gen_mystic(),
        "medic":    gen_medic(),
        "boss":     gen_boss(),
    }
    for name, img in tokens.items():
        save(img, token_dir / f"{name}.png")

    # ── Unit Role Icons  (28×28) ──────────────────────────────────────────────
    print("\n[ Unit Role Icons 28×28 ]")
    icon_dir = BASE / "unit_role_icons_generated"
    ensure_dir(icon_dir)
    for name, img in tokens.items():
        role_icon = scale_token_to_icon(img, 28)
        save(role_icon, icon_dir / f"{name}.png")

    # ── Object Icons  (40×40) ─────────────────────────────────────────────────
    print("\n[ Object Icons 40×40 ]")
    obj_dir = BASE / "object_icons_generated"
    ensure_dir(obj_dir)
    objects = {
        "chest": gen_chest(),
        "lever": gen_lever(),
        "altar": gen_altar(),
        "gate":  gen_gate(),
    }
    for name, img in objects.items():
        save(img, obj_dir / f"{name}.png")

    # ── Combat FX  (64×64) ───────────────────────────────────────────────────
    print("\n[ Combat FX 64×64 ]")
    fx_dir = BASE / "fx_generated"
    ensure_dir(fx_dir)
    fx = {
        "hit_spark":       gen_hit_spark(),
        "mark_ring":       gen_mark_ring(),
        "objective_burst": gen_objective_burst(),
    }
    for name, img in fx.items():
        save(img, fx_dir / f"{name}.png")

    # ── Terrain Icons  (24×24) + Cards  (48×48) ───────────────────────────────
    print("\n[ Terrain Icons 24×24 ]")
    tile_icon_dir = BASE / "tile_icons_generated"
    tile_card_dir = BASE / "tile_cards_generated"
    ensure_dir(tile_icon_dir)
    ensure_dir(tile_card_dir)
    for name, (fg, bg, _sym) in TERRAIN_DEFS.items():
        icon = gen_terrain_icon(name, fg, bg, 24)
        save(icon, tile_icon_dir / f"{name}.png")
        card = scale_to_card(icon, 48)
        save(card, tile_card_dir / f"{name}.png")
    # plain terrain card (no overlay icon needed, just subtle background stamp)
    plain = new_img(48)
    pd = ImageDraw.Draw(plain)
    for i in range(0, 48, 8):
        pd.line([(i, 0), (i, 48)], fill=(60, 56, 50, 40), width=1)
        pd.line([(0, i), (48, i)], fill=(60, 56, 50, 40), width=1)
    save(plain, tile_card_dir / "plain.png")

    # ── HUD Command Icons  (32×32) ───────────────────────────────────────────
    print("\n[ HUD Command Icons 32×32 ]")
    hud_dir = BASE / "icons_generated"
    ensure_dir(hud_dir)
    huds = {
        "bag":   gen_hud_bag(),
        "back":  gen_hud_back(),
        "wait":  gen_hud_wait(),
        "enemy": gen_hud_enemy(),
    }
    for name, img in huds.items():
        save(img, hud_dir / f"{name}.png")

    print("\n=== Done ===")

if __name__ == "__main__":
    main()
