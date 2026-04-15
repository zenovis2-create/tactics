#!/usr/bin/env python3
"""
Ashen Bell — Character Portrait & Silhouette Generator
Generates styled character silhouette tokens and portrait placeholder sheets.
Visual style: classic tactical JRPG, cel-shaded, warm restraint, readable silhouettes.
"""

import math
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter, ImageFont

OUT_PORTRAITS   = Path("/Volumes/AI/tactics/assets/characters/portraits")
OUT_SILHOUETTES = Path("/Volumes/AI/tactics/assets/characters/silhouettes")

# ── Palette ──────────────────────────────────────────────────────────────────
T = (0, 0, 0, 0)  # transparent

# World palette
ASH_BLUE   = (72, 80, 96, 255)
ASH_DARK   = (32, 36, 44, 255)
BONE       = (220, 210, 188, 255)
BONE_MID   = (170, 158, 136, 255)
BONE_DARK  = (110, 100, 82, 255)
VOW_GOLD   = (201, 168, 76, 255)
VOW_LIGHT  = (240, 210, 120, 255)
EMBER_RED  = (180, 56, 40, 255)
MOSS_GREEN = (80, 120, 64, 255)
SKY_BLUE   = (120, 172, 200, 255)
SKY_LIGHT  = (180, 215, 230, 255)
PURPLE_SOFT= (140, 100, 180, 255)
IRON       = (110, 116, 124, 255)
IRON_DARK  = (64, 68, 76, 255)
SKIN_LIGHT = (232, 196, 160, 255)
SKIN_MID   = (196, 152, 116, 255)
SKIN_DARK  = (148, 108, 80, 255)
HAIR_DARK  = (60, 48, 40, 255)
HAIR_MED   = (96, 76, 56, 255)
WHITE_CLOTH= (230, 226, 218, 255)
WHITE_TRIM = (200, 196, 188, 255)

def new_img(w, h, bg=T):
    return Image.new("RGBA", (w, h), bg)

def d_ellipse(draw, cx, cy, rx, ry, fill, outline=None, width=1):
    draw.ellipse([cx-rx, cy-ry, cx+rx, cy+ry], fill=fill, outline=outline, width=width)

def d_circle(draw, cx, cy, r, fill, outline=None, width=1):
    d_ellipse(draw, cx, cy, r, r, fill, outline, width)

def d_poly(draw, pts, fill, outline=None, width=2):
    draw.polygon(pts, fill=fill, outline=outline)
    if outline and width > 1:
        for i in range(len(pts)):
            draw.line([pts[i], pts[(i+1)%len(pts)]], fill=outline, width=width)

# ─────────────────────────────────────────────────────────────────────────────
# SILHOUETTE TOKENS  (64×64) — stylized tactical piece silhouettes
# ─────────────────────────────────────────────────────────────────────────────

def gen_rian_silhouette(size=64):
    """Rian — young commander-swordsman, directional mantle, map-mark motif."""
    img = new_img(size, size)
    d = ImageDraw.Draw(img)
    cx = size // 2
    m = 4

    # Soft background field (ash blue)
    d_circle(d, cx, size//2, size//2 - m + 2, ASH_BLUE)

    # Color: ally gold-warm
    body_color = VOW_GOLD
    outline_color = (100, 80, 24, 255)

    # Legs/stance (slightly spread)
    d.polygon([(cx-10, size-m-4), (cx-3, size//2+6), (cx+3, size//2+6), (cx+10, size-m-4)],
              fill=body_color)

    # Torso
    torso = [(cx-8, size//2-2), (cx+8, size//2-2),
             (cx+6, size//2+8), (cx-6, size//2+8)]
    d_poly(d, torso, body_color, outline_color, 1)

    # Mantle/cape (asymmetric, left side wider — directional split)
    mantle_l = [(cx-8, size//2-6), (cx-18, size//2+2), (cx-14, size//2+14), (cx-6, size//2+8)]
    d_poly(d, mantle_l, (160, 130, 50, 240), outline_color, 1)

    # Sword arm (right, raised slightly)
    d_poly(d, [(cx+8, size//2-2), (cx+16, size//2-10), (cx+14, size//2+2), (cx+6, size//2+6)],
           body_color, outline_color, 1)
    # Sword
    d.line([(cx+18, m+2), (cx+10, size//2-6)], fill=IRON, width=3)
    d.line([(cx+14, size//2-12), (cx+22, size//2-8)], fill=IRON, width=2)  # guard

    # Head
    d_circle(d, cx, size//2-10, 9, SKIN_LIGHT, outline_color, 1)

    # Hair (dark, short)
    d.chord([cx-9, size//2-19, cx+9, size//2-8], start=200, end=340, fill=HAIR_DARK)

    # Eyes (calm, alert)
    d.line([(cx-4, size//2-11), (cx-1, size//2-11)], fill=ASH_DARK, width=2)
    d.line([(cx+1, size//2-11), (cx+4, size//2-11)], fill=ASH_DARK, width=2)

    # Map-mark motif on chest (small cross/mark)
    d_circle(d, cx, size//2+2, 3, T, VOW_LIGHT, 1)
    d.line([(cx, size//2-1), (cx, size//2+5)], fill=VOW_LIGHT, width=1)
    d.line([(cx-3, size//2+2), (cx+3, size//2+2)], fill=VOW_LIGHT, width=1)

    return img

def gen_serin_silhouette(size=64):
    """Serin — healer/support, layered white-blue cloth, ward-ring motif."""
    img = new_img(size, size)
    d = ImageDraw.Draw(img)
    cx = size // 2
    m = 4

    # Background field (sky blue, lighter)
    d_circle(d, cx, size//2, size//2 - m + 2, (80, 130, 160, 200))

    body_color = WHITE_CLOTH
    trim_color = SKY_BLUE
    outline_color = (80, 100, 120, 255)

    # Robes (wide, layered)
    robe = [(cx-12, size//2), (cx+12, size//2),
            (cx+16, size-m-2), (cx-16, size-m-2)]
    d_poly(d, robe, body_color, outline_color, 1)

    # Inner robe layer (slightly different tone)
    d_poly(d, [(cx-6, size//2+2), (cx+6, size//2+2),
               (cx+10, size-m-4), (cx-10, size-m-4)],
           WHITE_TRIM, None, 0)

    # Torso / upper body
    torso = [(cx-8, size//2-6), (cx+8, size//2-6),
             (cx+10, size//2+2), (cx-10, size//2+2)]
    d_poly(d, torso, body_color, outline_color, 1)

    # Sacred trim on hem
    d.line([(cx-15, size-m-4), (cx+15, size-m-4)], fill=trim_color, width=2)

    # Left arm — holding staff/ward item
    d_poly(d, [(cx-8, size//2-4), (cx-16, size//2+4), (cx-14, size//2+12), (cx-6, size//2+4)],
           body_color, outline_color, 1)
    # Staff
    d.line([(cx-18, m+2), (cx-15, size//2+6)], fill=BONE_MID, width=3)
    # Staff head (ward ring)
    d_circle(d, cx-18, m+6, 5, T, trim_color, 2)
    d_circle(d, cx-18, m+6, 2, SKY_LIGHT)

    # Right arm — open, stabilizing palm gesture
    d_poly(d, [(cx+8, size//2-4), (cx+16, size//2+2), (cx+14, size//2+10), (cx+6, size//2+2)],
           body_color, outline_color, 1)

    # Head
    d_circle(d, cx, size//2-12, 9, SKIN_LIGHT, outline_color, 1)

    # Hair (lighter, soft)
    d.chord([cx-9, size//2-21, cx+9, size//2-10], start=200, end=340, fill=(180, 160, 130, 255))

    # Eyes (compassionate, open)
    d.arc([cx-5, size//2-14, cx-1, size//2-10], start=200, end=340, fill=ASH_DARK, width=2)
    d.arc([cx+1, size//2-14, cx+5, size//2-10], start=200, end=340, fill=ASH_DARK, width=2)

    # Ward-ring motif on chest collar
    d_circle(d, cx, size//2-3, 5, T, trim_color, 1)

    return img

def gen_bran_silhouette(size=64):
    """Bran — veteran knight, broad upper mass, fortress-like."""
    img = new_img(size, size)
    d = ImageDraw.Draw(img)
    cx = size // 2
    m = 4

    d_circle(d, cx, size//2, size//2 - m + 2, (50, 54, 62, 200))

    body_color = IRON
    trim_color = BONE_MID
    outline_color = (30, 34, 42, 255)

    # Wide legs, planted
    d_poly(d, [(cx-12, size-m-2), (cx-4, size//2+8), (cx+4, size//2+8), (cx+12, size-m-2)],
           body_color, outline_color, 1)

    # Heavy tabard/torso
    torso = [(cx-14, size//2-4), (cx+14, size//2-4),
             (cx+12, size//2+10), (cx-12, size//2+10)]
    d_poly(d, torso, body_color, outline_color, 1)

    # Mantle (heavy, shoulder weight)
    d_poly(d, [(cx-14, size//2-4), (cx-22, size//2+6), (cx-18, size//2+16), (cx-12, size//2+8)],
           IRON_DARK, outline_color, 1)
    d_poly(d, [(cx+14, size//2-4), (cx+22, size//2+6), (cx+18, size//2+16), (cx+12, size//2+8)],
           IRON_DARK, outline_color, 1)

    # Shield (left arm)
    shield = [(cx-20, size//2-8), (cx-16, size//2-14),
              (cx-10, size//2-12), (cx-8, size//2+6),
              (cx-14, size//2+12)]
    d_poly(d, shield, IRON_DARK, trim_color, 1)
    d_circle(d, cx-15, size//2-2, 3, trim_color)  # boss stud

    # Weapon hand (right, sword held low)
    d.line([(cx+14, size//2+4), (cx+22, size-m-4)], fill=IRON, width=4)

    # Head (broad jaw, scarred)
    d_circle(d, cx+2, size//2-12, 8, SKIN_MID, outline_color, 1)

    # Helmet/hair
    d.chord([cx-6, size//2-21, cx+10, size//2-10], start=190, end=350, fill=IRON_DARK)

    # Eyes (narrow, judging)
    d.line([(cx-2, size//2-14), (cx+1, size//2-13)], fill=ASH_DARK, width=2)
    d.line([(cx+3, size//2-14), (cx+6, size//2-13)], fill=ASH_DARK, width=2)

    # Scar (cheek line)
    d.line([(cx+2, size//2-11), (cx+6, size//2-8)], fill=SKIN_DARK, width=1)

    return img

def gen_tia_silhouette(size=64):
    """Tia — lean forest archer, asymmetric hunter silhouette, hood."""
    img = new_img(size, size)
    d = ImageDraw.Draw(img)
    cx = size // 2
    m = 4

    d_circle(d, cx, size//2, size//2 - m + 2, (44, 64, 44, 200))

    body_color = MOSS_GREEN
    trim_color = (60, 90, 50, 255)
    outline_color = (28, 44, 24, 255)

    # Lean stance (slightly crouched/asymmetric)
    d_poly(d, [(cx-6, size-m-4), (cx-2, size//2+8), (cx+2, size//2+8), (cx+8, size-m-4)],
           body_color, outline_color, 1)

    # Torso (lean)
    torso = [(cx-7, size//2-2), (cx+7, size//2-2),
             (cx+6, size//2+10), (cx-6, size//2+10)]
    d_poly(d, torso, body_color, outline_color, 1)

    # Cloak/cloak asymmetric (hood break on left)
    d_poly(d, [(cx-7, size//2-6), (cx-18, size//2+4), (cx-12, size//2+16), (cx-6, size//2+8)],
           (52, 76, 44, 240), outline_color, 1)

    # Drawing arm (right, extended with bow)
    d_poly(d, [(cx+7, size//2-2), (cx+22, size//2-8), (cx+20, size//2+2), (cx+5, size//2+6)],
           body_color, outline_color, 1)

    # Bow (right side, arc)
    d.arc([cx+18, size//2-18, cx+34, size//2+10], start=120, end=240, fill=BONE_MID, width=3)
    d.line([(cx+18, size//2-12), (cx+18, size//2+8)], fill=BONE_DARK, width=1)  # string

    # Arrow nocked
    d.line([(cx+8, size//2-4), (cx+20, size//2-8)], fill=BONE_MID, width=2)

    # Hood (left side, partial break)
    d.chord([cx-10, size//2-22, cx+8, size//2-8], start=195, end=345, fill=(44, 66, 38, 255))
    # Hood gap (showing face on right side)
    d.chord([cx-8, size//2-21, cx+8, size//2-9], start=220, end=345, fill=SKIN_LIGHT)

    # Face (partially hidden, sharp angle)
    d_circle(d, cx+1, size//2-13, 7, SKIN_LIGHT, outline_color, 1)

    # Eyes (sharp, wary)
    d.line([(cx-1, size//2-15), (cx+2, size//2-14)], fill=ASH_DARK, width=2)
    d.line([(cx+4, size//2-15), (cx+7, size//2-14)], fill=ASH_DARK, width=2)

    # Utility strap across chest
    d.line([(cx-7, size//2), (cx+7, size//2+4)], fill=BONE_DARK, width=2)

    return img

# ─────────────────────────────────────────────────────────────────────────────
# PORTRAIT PLACEHOLDER SHEET  (160×200 each character)
# Classic tactical JRPG portrait — chest-up, clean background field
# ─────────────────────────────────────────────────────────────────────────────

def gen_portrait_rian(w=160, h=200):
    """Rian portrait — chest-up, controlled, alert, quietly heavy."""
    img = new_img(w, h, ASH_BLUE)
    d = ImageDraw.Draw(img)
    cx, cy = w // 2, h // 2

    # Background — ash field with subtle record-line motif
    for y in range(0, h, 12):
        d.line([(0, y), (w, y)], fill=(80, 88, 104, 60), width=1)
    # Map-mark grid overlay (very subtle)
    for x in range(0, w, 20):
        d.line([(x, 0), (x, h)], fill=(80, 88, 104, 40), width=1)

    # Shoulder and torso base
    shoulder_l = [(0, h*3//4), (cx-30, h//2+10), (cx-24, h), (0, h)]
    shoulder_r = [(w, h*3//4), (cx+30, h//2+10), (cx+24, h), (w, h)]
    d_poly(d, shoulder_l + [(0, h)], (110, 90, 40, 255), None, 0)
    d_poly(d, shoulder_r + [(w, h)], (100, 82, 34, 255), None, 0)

    # Mantle (left, directional split)
    mantle = [(0, h//2+20), (cx-28, h//2+8), (cx-20, h), (0, h)]
    d_poly(d, mantle, (140, 110, 44, 255), (80, 60, 20, 200), 1)

    # Torso center
    d.rectangle([cx-20, h//2+6, cx+20, h], fill=VOW_GOLD)

    # Collar and chest detail
    d_poly(d, [(cx-12, h//2), (cx+12, h//2),
               (cx+10, h//2+14), (cx-10, h//2+14)],
           (190, 155, 62, 255), None, 0)

    # Map-mark on chest
    d_circle(d, cx, h//2+22, 8, T, VOW_LIGHT, 1)
    d.line([(cx, h//2+14), (cx, h//2+30)], fill=VOW_LIGHT, width=1)
    d.line([(cx-8, h//2+22), (cx+8, h//2+22)], fill=VOW_LIGHT, width=1)

    # Neck
    d.rectangle([cx-8, h//2-6, cx+8, h//2+2], fill=SKIN_LIGHT)

    # Head (young, clean, masculine)
    head_r_x, head_r_y = 22, 26
    d_ellipse(d, cx, h//3, head_r_x, head_r_y, SKIN_LIGHT)

    # Jaw
    jaw = [(cx-18, h//3+10), (cx-10, h//3+28), (cx, h//3+32),
           (cx+10, h//3+28), (cx+18, h//3+10)]
    d.polygon(jaw, fill=SKIN_LIGHT)

    # Shading (left cheek darker)
    d.polygon([(cx-20, h//3-10), (cx-4, h//3-10), (cx-6, h//3+28), (cx-16, h//3+24)],
              fill=(SKIN_MID[0], SKIN_MID[1], SKIN_MID[2], 60))

    # Hair — dark, structured, slightly windswept left
    hair_pts = [
        (cx-22, h//3-10),
        (cx-20, h//3-24),
        (cx-8, h//3-30),
        (cx+4, h//3-30),
        (cx+18, h//3-24),
        (cx+22, h//3-10),
        (cx+14, h//3-8),
        (cx+6, h//3-16),
        (cx-4, h//3-18),
        (cx-14, h//3-12),
    ]
    d.polygon(hair_pts, fill=HAIR_DARK)
    # Hair highlight
    d.line([(cx-2, h//3-28), (cx+10, h//3-22)], fill=HAIR_MED, width=2)

    # Eyes (calm, alert — slightly heavy under-eye)
    # Left eye
    d.polygon([(cx-16, h//3-2), (cx-6, h//3-6), (cx-4, h//3),
               (cx-8, h//3+4), (cx-16, h//3+2)],
              fill=(50, 70, 100, 255))
    d_circle(d, cx-10, h//3-1, 4, (35, 55, 85, 255))
    d_circle(d, cx-10, h//3-1, 2, (20, 30, 50, 255))
    d_circle(d, cx-9, h//3-3, 1, (230, 230, 240, 255))  # highlight

    # Right eye
    d.polygon([(cx+4, h//3-6), (cx+14, h//3-2), (cx+16, h//3+2),
               (cx+12, h//3+4), (cx+4, h//3)],
              fill=(50, 70, 100, 255))
    d_circle(d, cx+10, h//3-1, 4, (35, 55, 85, 255))
    d_circle(d, cx+10, h//3-1, 2, (20, 30, 50, 255))
    d_circle(d, cx+11, h//3-3, 1, (230, 230, 240, 255))

    # Nose (simple, clean line)
    d.line([(cx+2, h//3+6), (cx+2, h//3+14)], fill=SKIN_DARK, width=1)
    d.line([(cx-2, h//3+14), (cx+6, h//3+14)], fill=SKIN_DARK, width=1)

    # Mouth (pressed, quiet determination)
    d.line([(cx-8, h//3+22), (cx+8, h//3+22)], fill=SKIN_DARK, width=2)
    d.arc([cx-6, h//3+20, cx+6, h//3+26], start=180, end=360, fill=SKIN_DARK, width=1)

    # Eyebrows (controlled, slight furrow)
    d.line([(cx-18, h//3-10), (cx-6, h//3-8)], fill=HAIR_DARK, width=2)
    d.line([(cx+6, h//3-8), (cx+18, h//3-10)], fill=HAIR_DARK, width=2)

    # Ear (left, partially visible)
    d.arc([cx-24, h//3+2, cx-16, h//3+14], start=150, end=210, fill=SKIN_MID, width=3)

    # Soft glow on face from ash-field ambient
    face_glow = new_img(w, h)
    fg = ImageDraw.Draw(face_glow)
    d_ellipse(fg, cx, h//3+4, 30, 34, (200, 180, 130, 30))
    face_glow = face_glow.filter(ImageFilter.GaussianBlur(12))
    img = Image.alpha_composite(img, face_glow)

    return img

def gen_portrait_serin(w=160, h=200):
    """Serin portrait — compassionate but firm, clean sacred silhouette."""
    img = new_img(w, h, (60, 90, 115, 255))
    d = ImageDraw.Draw(img)
    cx, cy = w // 2, h // 2

    # Background — sky/water-light field with ward-ring motifs
    for r in [70, 55, 42]:
        d_circle(d, cx, h//2+20, r, T, (140, 190, 220, 30), 1)

    # Robes (wide, layered, white-blue)
    robe = [(0, h*3//4), (cx-32, h//2+4), (cx+32, h//2+4), (w, h*3//4), (w, h), (0, h)]
    d_poly(d, robe, WHITE_CLOTH, None, 0)

    # Inner robe layer
    d_poly(d, [(cx-18, h//2+8), (cx+18, h//2+8),
               (cx+22, h), (cx-22, h)],
           WHITE_TRIM, None, 0)

    # Sacred trim on shoulder
    d.line([(0, h*2//3), (w, h*2//3)], fill=SKY_BLUE, width=2)

    # Staff (left side)
    d.line([(cx-36, 8), (cx-28, h//2+8)], fill=BONE_MID, width=4)
    # Staff head — ward ring
    d_circle(d, cx-36, 14, 9, T, SKY_BLUE, 2)
    d_circle(d, cx-36, 14, 4, SKY_LIGHT)
    d_circle(d, cx-36, 14, 2, (220, 235, 240, 255))

    # Open right arm (palm forward, stabilizing gesture)
    d_poly(d, [(cx+16, h//2), (cx+34, h//2+6), (cx+32, h//2+20), (cx+16, h//2+14)],
           WHITE_CLOTH, (160, 170, 176, 180), 1)

    # Neck
    d.rectangle([cx-7, h//2-4, cx+7, h//2+4], fill=SKIN_LIGHT)

    # Head (round, composed, slightly smaller = female proportions)
    d_ellipse(d, cx, h//3, 20, 24, SKIN_LIGHT)

    # Jaw
    jaw = [(cx-16, h//3+8), (cx-8, h//3+26), (cx, h//3+30),
           (cx+8, h//3+26), (cx+16, h//3+8)]
    d.polygon(jaw, fill=SKIN_LIGHT)

    # Hair — lighter, soft waves
    hair_color = (190, 168, 130, 255)
    hair_pts = [
        (cx-20, h//3-8),
        (cx-18, h//3-26),
        (cx-6, h//3-32),
        (cx+6, h//3-32),
        (cx+18, h//3-26),
        (cx+20, h//3-8),
        (cx+16, h//3-4),
        (cx+10, h//3-14),
        (cx, h//3-18),
        (cx-10, h//3-14),
        (cx-16, h//3-4),
    ]
    d.polygon(hair_pts, fill=hair_color)
    # Hair side strands
    d_poly(d, [(cx-20, h//3-8), (cx-28, h//3+4), (cx-24, h//3+18), (cx-16, h//3+8)],
           hair_color, None, 0)
    # Highlight
    d.line([(cx-4, h//3-30), (cx+8, h//3-24)], fill=(220, 198, 160, 255), width=2)

    # Eyes (compassionate, open arc shape)
    # Left eye — open, warm
    d.polygon([(cx-16, h//3-2), (cx-7, h//3-7), (cx-4, h//3-2),
               (cx-8, h//3+5), (cx-15, h//3+3)],
              fill=(100, 140, 170, 255))
    d_circle(d, cx-10, h//3-1, 4, (70, 110, 145, 255))
    d_circle(d, cx-10, h//3-1, 2, (45, 80, 115, 255))
    d_circle(d, cx-9, h//3-3, 1, (230, 238, 245, 255))

    # Right eye
    d.polygon([(cx+4, h//3-7), (cx+13, h//3-2), (cx+15, h//3+3),
               (cx+8, h//3+5), (cx+4, h//3-2)],
              fill=(100, 140, 170, 255))
    d_circle(d, cx+9, h//3-1, 4, (70, 110, 145, 255))
    d_circle(d, cx+9, h//3-1, 2, (45, 80, 115, 255))
    d_circle(d, cx+10, h//3-3, 1, (230, 238, 245, 255))

    # Nose
    d.line([(cx+1, h//3+6), (cx+1, h//3+13)], fill=SKIN_MID, width=1)
    d.line([(cx-2, h//3+13), (cx+4, h//3+13)], fill=SKIN_MID, width=1)

    # Mouth (soft, settled — slightly upward corners)
    d.arc([cx-9, h//3+18, cx+9, h//3+26], start=180, end=360, fill=SKIN_DARK, width=2)

    # Eyebrows (gentle, clean arc)
    d.arc([cx-18, h//3-14, cx-4, h//3-4], start=200, end=340, fill=hair_color, width=2)
    d.arc([cx+4, h//3-14, cx+18, h//3-4], start=200, end=340, fill=hair_color, width=2)

    # Ear (right, small)
    d.arc([cx+16, h//3+4, cx+24, h//3+14], start=330, end=30, fill=SKIN_MID, width=2)

    # Ward-ring collar ornament
    d_circle(d, cx, h//2, 7, T, SKY_BLUE, 2)
    d_circle(d, cx, h//2, 3, SKY_LIGHT)

    # Face ambient glow
    face_glow = new_img(w, h)
    fg = ImageDraw.Draw(face_glow)
    d_ellipse(fg, cx, h//3+4, 28, 32, (180, 210, 230, 35))
    face_glow = face_glow.filter(ImageFilter.GaussianBlur(14))
    img = Image.alpha_composite(img, face_glow)

    return img

# ─────────────────────────────────────────────────────────────────────────────
# ROSTER CONTACT SHEET  (4-up, 160×200 each)
# ─────────────────────────────────────────────────────────────────────────────

def gen_roster_contact_sheet():
    """4-up portrait contact sheet: Rian, Serin, Bran, Tia (placeholders)."""
    PAD = 8
    PW, PH = 160, 200
    COLS = 2
    ROWS = 2
    sheet_w = COLS * PW + (COLS + 1) * PAD
    sheet_h = ROWS * PH + (ROWS + 1) * PAD + 30  # 30 for title bar

    sheet = new_img(sheet_w, sheet_h, ASH_DARK)
    d = ImageDraw.Draw(sheet)

    # Title bar
    d.rectangle([0, 0, sheet_w, 28], fill=(28, 32, 40, 255))
    d.text((PAD, 8), "잿빛의 기억 — Roster v1", fill=BONE_MID)

    portraits = [
        ("rian",  gen_portrait_rian()),
        ("serin", gen_portrait_serin()),
    ]

    # Silhouette placeholders for Bran and Tia (tinted, labeled)
    bran_placeholder = new_img(PW, PH, (50, 54, 62, 255))
    pd = ImageDraw.Draw(bran_placeholder)
    sil = gen_bran_silhouette(64)
    bran_placeholder.paste(sil, ((PW - 64) // 2, (PH - 64) // 2), sil)
    pd.text((PW//2 - 14, PH - 20), "BRAN", fill=BONE_MID)
    portraits.append(("bran", bran_placeholder))

    tia_placeholder = new_img(PW, PH, (44, 64, 44, 255))
    pd = ImageDraw.Draw(tia_placeholder)
    sil = gen_tia_silhouette(64)
    tia_placeholder.paste(sil, ((PW - 64) // 2, (PH - 64) // 2), sil)
    pd.text((PW//2 - 10, PH - 20), "TIA", fill=BONE_MID)
    portraits.append(("tia", tia_placeholder))

    for idx, (name, portrait) in enumerate(portraits):
        row = idx // COLS
        col = idx % COLS
        x = PAD + col * (PW + PAD)
        y = 30 + PAD + row * (PH + PAD)
        sheet.paste(portrait, (x, y))
        # Name label
        d.rectangle([x, y + PH - 20, x + PW, y + PH], fill=(0, 0, 0, 140))
        d.text((x + 6, y + PH - 18), name.upper(), fill=BONE)

    return sheet

# ─────────────────────────────────────────────────────────────────────────────
# MAIN
# ─────────────────────────────────────────────────────────────────────────────

def save(img, path):
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    img.save(str(path), "PNG")
    print(f"  ✓ {path}")

def main():
    print("=== Character Art Generator ===\n")

    print("[ Silhouette Tokens 64×64 ]")
    save(gen_rian_silhouette(),  OUT_SILHOUETTES / "rian.png")
    save(gen_serin_silhouette(), OUT_SILHOUETTES / "serin.png")
    save(gen_bran_silhouette(),  OUT_SILHOUETTES / "bran.png")
    save(gen_tia_silhouette(),   OUT_SILHOUETTES / "tia.png")

    print("\n[ Character Portraits 160×200 ]")
    save(gen_portrait_rian(),    OUT_PORTRAITS / "rian.png")
    save(gen_portrait_serin(),   OUT_PORTRAITS / "serin.png")

    print("\n[ Roster Contact Sheet ]")
    save(gen_roster_contact_sheet(), Path("/Volumes/AI/tactics/artifacts/ash37/roster_contact_sheet_v1.png"))

    print("\n=== Done ===")

if __name__ == "__main__":
    main()
