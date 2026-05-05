#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import shutil
from dataclasses import dataclass
from pathlib import Path

from PIL import Image, ImageOps


ROOT = Path("/Volumes/AI/tactics")
SOURCE_ROOT = ROOT / "output/imagegen/sprite_16f_bundles"
PACKAGE_ROOT = ROOT / "tmp/asset_forge_packages/sprite_bundle_runtime_v02_1"

STATES = ["idle", "move", "attack", "cast", "hit", "guard", "defeat"]
FACINGS = ["front_right", "front_left", "back_right", "back_left"]
FRAME_SIZE = (256, 256)
PIVOT = {"x": 128, "y": 238}
FOOTLINE_Y = 238


@dataclass(frozen=True)
class BundleSpec:
    character_id: str
    display_name: str
    anchor: str
    prefix: str
    core: Path
    completion: Path
    aliases: tuple[str, ...]


SPECS = {
    "enemy_hes": BundleSpec(
        character_id="enemy_hes",
        display_name="Hes",
        anchor="sprite_anchor_enemy_hes",
        prefix="enemy_hes",
        core=SOURCE_ROOT / "sprite_anchor_enemy_hes/v01/enemy_hes_front_right_caster_4x16f_bundle_v01_grid2048.png",
        completion=SOURCE_ROOT / "sprite_anchor_enemy_hes/v02/enemy_hes_front_right_completion_4x16f_bundle_v02_grid2048.png",
        aliases=("Hes", "enemy_hes"),
    ),
    "enemy_resin_warden": BundleSpec(
        character_id="enemy_resin_warden",
        display_name="Resin Warden",
        anchor="sprite_anchor_enemy_resin_warden",
        prefix="enemy_resin_warden",
        core=SOURCE_ROOT / "sprite_anchor_enemy_resin_warden/v01/enemy_resin_warden_front_right_caster_4x16f_bundle_v01_grid2048.png",
        completion=SOURCE_ROOT / "sprite_anchor_enemy_resin_warden/v02/enemy_resin_warden_front_right_completion_4x16f_bundle_v02_grid2048.png",
        aliases=("Resin Warden", "enemy_resin_warden"),
    ),
    "enemy_ash_archivist": BundleSpec(
        character_id="enemy_ash_archivist",
        display_name="Ash Archivist",
        anchor="sprite_anchor_enemy_ash_archivist",
        prefix="enemy_ash_archivist",
        core=SOURCE_ROOT / "sprite_anchor_enemy_ash_archivist/v01/enemy_ash_archivist_front_right_caster_4x16f_bundle_v01_grid2048.png",
        completion=SOURCE_ROOT / "sprite_anchor_enemy_ash_archivist/v02/enemy_ash_archivist_front_right_completion_4x16f_bundle_v02_grid2048.png",
        aliases=("Ash Archivist", "enemy_ash_archivist"),
    ),
}

STATE_SOURCES = {
    "idle": ("core", 0, 0),
    "cast": ("core", 0, 1),
    "attack": ("core", 1, 0),
    "hit": ("core", 1, 1),
    "move": ("completion", 0, 0),
    "guard": ("completion", 0, 1),
    "defeat": ("completion", 1, 0),
}


def _is_background_pixel(r: int, g: int, b: int, a: int) -> bool:
    if a == 0:
        return True
    mean = (r + g + b) / 3
    chroma = max(r, g, b) - min(r, g, b)
    if 92 <= mean <= 205 and chroma <= 17:
        return True
    if 108 <= mean <= 195 and chroma <= 27 and abs(r - g) <= 20 and abs(g - b) <= 22:
        return True
    return False


def _component_cleanup(image: Image.Image) -> None:
    pixels = image.load()
    width, height = image.size
    visited: set[tuple[int, int]] = set()
    components: list[dict[str, object]] = []

    for y in range(height):
        for x in range(width):
            if (x, y) in visited or pixels[x, y][3] == 0:
                continue
            stack = [(x, y)]
            visited.add((x, y))
            points: list[tuple[int, int]] = []
            min_x = max_x = x
            min_y = max_y = y
            while stack:
                px, py = stack.pop()
                points.append((px, py))
                min_x = min(min_x, px)
                min_y = min(min_y, py)
                max_x = max(max_x, px)
                max_y = max(max_y, py)
                for ny in range(max(0, py - 1), min(height, py + 2)):
                    for nx in range(max(0, px - 1), min(width, px + 2)):
                        if (nx, ny) in visited or pixels[nx, ny][3] == 0:
                            continue
                        visited.add((nx, ny))
                        stack.append((nx, ny))
            components.append({
                "points": points,
                "area": len(points),
                "bbox": (min_x, min_y, max_x, max_y),
            })

    if not components:
        return

    main = max(components, key=lambda item: int(item["area"]))
    main_area = int(main["area"])
    min_keep = max(60, int(main_area * 0.012))
    for component in components:
        if component is main:
            continue
        area = int(component["area"])
        bbox = component["bbox"]
        touches_edge = bbox[0] <= 1 or bbox[1] <= 1 or bbox[2] >= width - 2 or bbox[3] >= height - 2
        keep = area >= min_keep and not touches_edge
        if keep:
            continue
        for x, y in component["points"]:
            r, g, b, _a = pixels[x, y]
            pixels[x, y] = (r, g, b, 0)


def _normalize_cell(cell: Image.Image) -> tuple[Image.Image, dict[str, object]]:
    rgba = cell.convert("RGBA")
    pixels = rgba.load()
    width, height = rgba.size

    for y in range(height):
        for x in range(width):
            r, g, b, a = pixels[x, y]
            if _is_background_pixel(r, g, b, a):
                pixels[x, y] = (r, g, b, 0)

    _component_cleanup(rgba)
    bbox = rgba.getchannel("A").getbbox()
    if bbox is None:
        return Image.new("RGBA", FRAME_SIZE, (0, 0, 0, 0)), {"bbox": None, "scale": 1.0}

    pad = 4
    bbox = (
        max(0, bbox[0] - pad),
        max(0, bbox[1] - pad),
        min(width, bbox[2] + pad),
        min(height, bbox[3] + pad),
    )
    crop = rgba.crop(bbox)
    crop_w, crop_h = crop.size
    scale = min(218 / crop_w, 230 / crop_h, 2.6)
    resized_size = (max(1, round(crop_w * scale)), max(1, round(crop_h * scale)))
    resized = crop.resize(resized_size, Image.Resampling.LANCZOS)
    resized_bbox = resized.getchannel("A").getbbox()
    content_bottom = resized_bbox[3] if resized_bbox else resized_size[1]

    canvas = Image.new("RGBA", FRAME_SIZE, (0, 0, 0, 0))
    paste_x = (FRAME_SIZE[0] - resized_size[0]) // 2
    paste_y = FOOTLINE_Y - content_bottom
    canvas.alpha_composite(resized, (paste_x, paste_y))
    final_bbox = canvas.getchannel("A").getbbox()
    return canvas, {
        "bbox": list(bbox),
        "crop_size": [crop_w, crop_h],
        "scale": round(scale, 4),
        "paste": [paste_x, paste_y],
        "final_bbox": list(final_bbox) if final_bbox else None,
    }


def _state_cells(sheet: Image.Image, quadrant_row: int, quadrant_col: int) -> list[Image.Image]:
    cell_w = sheet.width // 8
    cell_h = sheet.height // 8
    cells: list[Image.Image] = []
    for local_row in range(4):
        for local_col in range(4):
            col = quadrant_col * 4 + local_col
            row = quadrant_row * 4 + local_row
            cells.append(sheet.crop((col * cell_w, row * cell_h, (col + 1) * cell_w, (row + 1) * cell_h)))
    return cells


def _write_sprite_frames_tres(runtime_dir: Path, spec: BundleSpec, state_frame_paths: dict[str, list[str]]) -> None:
    lines: list[str] = ['[gd_resource type="SpriteFrames" format=3]', ""]
    lines.append("[resource]")
    lines.append("animations = [{")
    animation_chunks: list[str] = []
    for state in STATES:
        frame_entries = []
        for rel_path in state_frame_paths[state]:
            frame_entries.append('{"duration": 1.0, "texture": load("res://assets/characters/%s/%s")}' % (spec.anchor, rel_path))
        animation_chunks.append(
            '"frames": [%s], "loop": %s, "name": &"%s", "speed": 8.0'
            % (", ".join(frame_entries), "true" if state in ("idle", "move") else "false", state)
        )
    lines.append("}, {".join(animation_chunks))
    lines.append("}]")
    (runtime_dir / f"{spec.prefix}_sprite_frames.tres").write_text("\n".join(lines) + "\n")


def _contract(spec: BundleSpec, states: dict[str, dict[str, object]]) -> dict[str, object]:
    return {
        "anchor": spec.anchor,
        "asset_version": "v02_1_bundle_prototype",
        "character_id": spec.character_id,
        "contract_version": "2.1",
        "direction_set": "diagonal_4",
        "directions": ["front", "front_right", "right", "back_right", "back", "back_left", "left", "front_left"],
        "facings": FACINGS,
        "schema_version": 2,
        "source_manifest": f"source/sheets/{spec.prefix}_bundle_runtime_v02_1_manifest.json",
        "states": states,
        "generation_metadata": {
            "source": "OpenAI imagegen 8x8 4x16 sprite bundle converted into an Asset Forge tactics package",
            "prototype_direction_derivation": "front_right source frames; front_left mirrored; back_right/back_left are temporary derived placeholders pending live back-view image generation",
            "style_contract": "modern diagonal-4 tactical JRPG sprite runtime",
            "aliases": list(spec.aliases),
        },
    }


def build_package(spec: BundleSpec) -> Path:
    if not spec.core.is_file():
        raise FileNotFoundError(spec.core)
    if not spec.completion.is_file():
        raise FileNotFoundError(spec.completion)

    package_dir = PACKAGE_ROOT / spec.anchor
    if package_dir.exists():
        shutil.rmtree(package_dir)

    anchor_root = package_dir / "godot/assets/characters" / spec.anchor
    runtime_dir = anchor_root / "runtime"
    facing_root = runtime_dir / "facing_frames"
    source_dir = anchor_root / "source/sheets"
    source_dir.mkdir(parents=True, exist_ok=True)

    core = Image.open(spec.core).convert("RGBA")
    completion = Image.open(spec.completion).convert("RGBA")
    sheets = {"core": core, "completion": completion}
    source_copies = {
        "core": source_dir / f"{spec.prefix}_core_bundle_v02_1_grid2048.png",
        "completion": source_dir / f"{spec.prefix}_completion_bundle_v02_1_grid2048.png",
    }
    shutil.copy2(spec.core, source_copies["core"])
    shutil.copy2(spec.completion, source_copies["completion"])

    contract_states: dict[str, dict[str, object]] = {}
    flat_frame_paths: dict[str, list[str]] = {}
    extraction: dict[str, list[dict[str, object]]] = {}

    for state in STATES:
        sheet_name, quadrant_row, quadrant_col = STATE_SOURCES[state]
        cells = _state_cells(sheets[sheet_name], quadrant_row, quadrant_col)
        normalized_frames: list[Image.Image] = []
        extraction[state] = []
        for index, cell in enumerate(cells):
            frame, meta = _normalize_cell(cell)
            normalized_frames.append(frame)
            extraction[state].append({"index": index, "sheet": sheet_name, "quadrant": [quadrant_row, quadrant_col], **meta})

        facings: dict[str, dict[str, object]] = {}
        for facing in FACINGS:
            frame_dir = facing_root / state / facing
            frame_dir.mkdir(parents=True, exist_ok=True)
            facing_paths: list[str] = []
            for index, frame in enumerate(normalized_frames):
                output = frame
                if facing in ("front_left", "back_left"):
                    output = ImageOps.mirror(frame)
                frame_path = frame_dir / f"{spec.prefix}_{state}_{facing}_{index:02d}.png"
                output.save(frame_path)
                facing_paths.append(str(frame_path.relative_to(anchor_root)))
            facings[facing] = {
                "fps": 8,
                "frame_count": 16,
                "frame_size": {"w": FRAME_SIZE[0], "h": FRAME_SIZE[1]},
                "frames": facing_paths,
                "loop": state in ("idle", "move"),
                "pivot": PIVOT,
                "derived_from": "front_right" if facing.startswith("back_") else None,
            }

        state_dir = runtime_dir / state
        state_dir.mkdir(parents=True, exist_ok=True)
        flat_paths: list[str] = []
        for index, frame in enumerate(normalized_frames[:8]):
            frame_path = state_dir / f"{spec.prefix}_{state}_{index:02d}.png"
            frame.save(frame_path)
            flat_paths.append(str(frame_path.relative_to(anchor_root)))
        flat_frame_paths[state] = flat_paths
        contract_states[state] = {
            "direction_set": "diagonal_4",
            "facing_frame_count": 64,
            "facings": facings,
            "fps": 8,
            "frame_count": 8,
            "frame_size": {"w": FRAME_SIZE[0], "h": FRAME_SIZE[1]},
            "frames": flat_paths,
            "loop": state in ("idle", "move"),
            "pivot": PIVOT,
        }

    contract_path = anchor_root / "runtime_contract_v02.json"
    contract_path.write_text(json.dumps(_contract(spec, contract_states), indent=2) + "\n")
    manifest = {
        "anchor": spec.anchor,
        "character_id": spec.character_id,
        "display_name": spec.display_name,
        "aliases": list(spec.aliases),
        "source_images": {key: str(path.relative_to(anchor_root)) for key, path in source_copies.items()},
        "state_sources": STATE_SOURCES,
        "extraction": extraction,
        "notes": [
            "Generated from existing imagegen front_right bundle because OPENAI_API_KEY was unavailable for live back-view generation.",
            "Back facings are temporary derived placeholders; replace with true back_right/back_left generated sheets when available.",
        ],
    }
    (source_dir / f"{spec.prefix}_bundle_runtime_v02_1_manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")
    return package_dir


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("characters", nargs="*", choices=sorted(SPECS), default=sorted(SPECS))
    args = parser.parse_args()

    built = []
    for character in args.characters:
        package_dir = build_package(SPECS[character])
        built.append(str(package_dir))

    print(json.dumps({"packages": built}, indent=2))


if __name__ == "__main__":
    main()
