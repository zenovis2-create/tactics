#!/usr/bin/env python3
from __future__ import annotations

import json
import shutil
from dataclasses import dataclass
from pathlib import Path

from PIL import Image, ImageEnhance, ImageFilter, ImageOps


ROOT = Path(__file__).resolve().parents[2]
PACKAGE_ROOT = ROOT / "tmp/asset_forge_packages/prop_surfaces_runtime_v02_1"
GODOT_ROOT = PACKAGE_ROOT / "godot"
ICON_SIZE = 256


@dataclass(frozen=True)
class PropSurfaceSpec:
    asset_id: str
    source_path: Path
    clean_path: Path
    runtime_outputs: tuple[str, ...]
    production_icon: str
    icon_label: str


SPECS: tuple[PropSurfaceSpec, ...] = (
    PropSurfaceSpec(
        asset_id="altar_01",
        source_path=ROOT / "output/imagegen/altar_01/v02/altar_01_battlefield_candidate_v02.png",
        clean_path=ROOT / "assets/props/altar_01/clean/altar_01_clean_v01.png",
        runtime_outputs=(
            "assets/props/altar_01/runtime/altar_01_clean_v01.png",
            "assets/props/altar_01/runtime/altar_01_integration_v01.png",
            "assets/props/altar_01/runtime/altar_01_object_icon_v01.png",
        ),
        production_icon="assets/ui/production/object_icons/altar.png",
        icon_label="altar object icon",
    ),
    PropSurfaceSpec(
        asset_id="paladin_shield",
        source_path=ROOT / "output/imagegen/paladin_shield/v02/paladin_shield_candidate_v02.png",
        clean_path=ROOT / "assets/props/paladin_shield/clean/paladin_shield_clean_v01.png",
        runtime_outputs=(
            "assets/props/paladin_shield/runtime/paladin_shield_clean_v01.png",
            "assets/props/paladin_shield/runtime/paladin_shield_equipment_v01.png",
            "assets/props/paladin_shield/runtime/paladin_shield_icon_v01.png",
            "assets/props/paladin_shield/runtime/paladin_shield_integration_v01.png",
        ),
        production_icon="assets/ui/production/object_icons/paladin_shield.png",
        icon_label="paladin shield support icon",
    ),
)


def main() -> None:
    if PACKAGE_ROOT.exists():
        shutil.rmtree(PACKAGE_ROOT)
    PACKAGE_ROOT.mkdir(parents=True, exist_ok=True)
    (PACKAGE_ROOT / ".gdignore").write_text(
        "Asset Forge handoff package; ignore package staging files during Godot project import.\n",
        encoding="utf-8",
    )

    manifest: dict[str, object] = {
        "schema_version": 1,
        "asset_type": "prop_surface_runtime_bundle",
        "version": "v02.1",
        "outputs": {
            "production_icon_size": [ICON_SIZE, ICON_SIZE],
            "runtime_surfaces_preserve_source_canvas": True,
        },
        "assets": [],
        "notes": [
            "Built from existing imagegen prop candidates and cleaned RGBA surfaces.",
            "Keeps runtime integration filenames stable for existing Godot preview/campaign routing.",
        ],
    }

    for spec in SPECS:
        manifest["assets"].append(build_prop_surface(spec))

    manifest_path = GODOT_ROOT / "assets/props/prop_surfaces_runtime_v02_1_manifest.json"
    manifest_path.parent.mkdir(parents=True, exist_ok=True)
    manifest_path.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    print(PACKAGE_ROOT)


def build_prop_surface(spec: PropSurfaceSpec) -> dict[str, object]:
    if not spec.source_path.is_file():
        raise FileNotFoundError(spec.source_path)
    if not spec.clean_path.is_file():
        raise FileNotFoundError(spec.clean_path)

    source_dir = GODOT_ROOT / "assets/props" / spec.asset_id / "source"
    source_dir.mkdir(parents=True, exist_ok=True)
    source_copy = source_dir / spec.source_path.name
    shutil.copy2(spec.source_path, source_copy)

    clean = Image.open(spec.clean_path).convert("RGBA")
    runtime_paths: list[str] = []
    for output in spec.runtime_outputs:
        output_path = GODOT_ROOT / output
        output_path.parent.mkdir(parents=True, exist_ok=True)
        if output.endswith("_icon_v01.png"):
            _make_icon(clean).save(output_path)
        else:
            _polish_runtime_surface(clean).save(output_path)
        runtime_paths.append(str(output_path.relative_to(GODOT_ROOT)))

    production_icon_path = GODOT_ROOT / spec.production_icon
    production_icon_path.parent.mkdir(parents=True, exist_ok=True)
    _make_icon(clean).save(production_icon_path)

    return {
        "asset_id": spec.asset_id,
        "source": str(source_copy.relative_to(GODOT_ROOT)),
        "clean_source": str(spec.clean_path.relative_to(ROOT)),
        "runtime_outputs": runtime_paths,
        "production_icon": str(production_icon_path.relative_to(GODOT_ROOT)),
        "icon_label": spec.icon_label,
    }


def _polish_runtime_surface(image: Image.Image) -> Image.Image:
    polished = ImageEnhance.Color(image).enhance(0.96)
    polished = ImageEnhance.Contrast(polished).enhance(1.06)
    polished = ImageEnhance.Sharpness(polished).enhance(1.08)
    return polished


def _make_icon(image: Image.Image) -> Image.Image:
    bbox = image.getbbox()
    if bbox == None:
        fitted = Image.new("RGBA", (ICON_SIZE, ICON_SIZE), (0, 0, 0, 0))
    else:
        cropped = image.crop(bbox)
        fitted = ImageOps.contain(cropped, (ICON_SIZE - 24, ICON_SIZE - 24), Image.Resampling.LANCZOS)
        canvas = Image.new("RGBA", (ICON_SIZE, ICON_SIZE), (0, 0, 0, 0))
        paste_at = ((ICON_SIZE - fitted.width) // 2, (ICON_SIZE - fitted.height) // 2)
        canvas.alpha_composite(fitted, paste_at)
        fitted = canvas

    fitted = ImageEnhance.Contrast(fitted).enhance(1.12)
    fitted = fitted.filter(ImageFilter.UnsharpMask(radius=0.8, percent=85, threshold=3))
    return fitted


if __name__ == "__main__":
    main()
