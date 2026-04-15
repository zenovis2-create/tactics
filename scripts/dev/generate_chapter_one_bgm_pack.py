#!/usr/bin/env python3
"""Generate the chapter-one BGM pack on the AI volume.

Primary backend:
- ACE-Step via /Volumes/AI/ace-step-env

Fallback backend:
- MusicGen via /Volumes/AI/mlx-env

Outputs:
- /Volumes/AI/tactics/audio/bgm/*.wav
- /Volumes/AI/tactics/data/audio/bgm_manifest.json
- /Volumes/AI/tactics/audio/bgm/README.md
"""

from __future__ import annotations

import argparse
import json
import os
import math
import struct
import wave
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Callable


AI_ROOT = Path("/Volumes/AI")
TACTICS_ROOT = Path("/Volumes/AI/tactics")
BGM_DIR = TACTICS_ROOT / "audio" / "bgm"
DATA_AUDIO_DIR = TACTICS_ROOT / "data" / "audio"
MANIFEST_PATH = DATA_AUDIO_DIR / "bgm_manifest.json"
README_PATH = BGM_DIR / "README.md"
ACE_STEP_CHECKPOINT_DIR = AI_ROOT / "models" / "ace-step-checkpoints"
PLACEHOLDER_SAMPLE_RATE = 22050


@dataclass(frozen=True)
class TrackSpec:
    cue_id: str
    file_name: str
    duration_sec: int
    seed: int
    prompt: str
    notes: str


TRACKS: list[TrackSpec] = [
    TrackSpec(
        cue_id="bgm_battle_default",
        file_name="bgm_battle_default.wav",
        duration_sec=120,
        seed=1101,
        prompt=(
            "somber tactical RPG battle theme, orchestral strings and brass, "
            "late-1990s console SRPG warmth, minor key, 80bpm, loopable, "
            "steady snare pulse, heroic but weary"
        ),
        notes="General battle cue for standard encounters.",
    ),
    TrackSpec(
        cue_id="bgm_battle_boss",
        file_name="bgm_battle_boss.wav",
        duration_sec=120,
        seed=1102,
        prompt=(
            "boss battle theme for a fantasy tactics RPG, brass ostinato, "
            "low timpani, tense string runs, late-1990s console SRPG energy, "
            "minor key, 92bpm, loopable, oppressive but melodic"
        ),
        notes="Boss battle cue with heavier brass and threat.",
    ),
    TrackSpec(
        cue_id="bgm_camp",
        file_name="bgm_camp.wav",
        duration_sec=120,
        seed=1103,
        prompt=(
            "camp screen music for a memory-themed tactics RPG, soft piano, "
            "harp, strings, gentle woodwinds, late-1990s SRPG warmth, "
            "reflective and safe, loopable, 72bpm"
        ),
        notes="Camp and recovery cue for the party hub.",
    ),
    TrackSpec(
        cue_id="bgm_title",
        file_name="bgm_title.wav",
        duration_sec=60,
        seed=1104,
        prompt=(
            "title screen music for a classic tactics RPG, bittersweet melody, "
            "strings and soft choir pad, hopeful but haunted, late-1990s "
            "console SRPG style, loopable, 68bpm"
        ),
        notes="Title screen cue.",
    ),
    TrackSpec(
        cue_id="bgm_cutscene_ch01",
        file_name="bgm_cutscene_ch01.wav",
        duration_sec=60,
        seed=1105,
        prompt=(
            "chapter one cutscene underscore for a memory-themed tactics RPG, "
            "quiet strings, restrained piano, faint bells, uneasy but tender, "
            "late-1990s console SRPG mood, loopable, 64bpm"
        ),
        notes="Chapter one intro/outro cutscene cue.",
    ),
]


def ensure_dirs() -> None:
    BGM_DIR.mkdir(parents=True, exist_ok=True)
    DATA_AUDIO_DIR.mkdir(parents=True, exist_ok=True)


def write_readme(tracks: list[dict[str, Any]]) -> None:
    lines = [
        "# Chapter One BGM Pack",
        "",
        "Generated on the AI volume for the Memory Tactics RPG vertical slice.",
        "",
        "| Cue | Duration | Backend | Output |",
        "| --- | --- | --- | --- |",
    ]
    for track in tracks:
        lines.append(
            f"| `{track['cue_id']}` | {track['duration_sec']}s | {track['backend']} | `{track['asset_path']}` |"
        )
    lines.append("")
    lines.append("Notes:")
    lines.append("")
    lines.append("- Late-1990s console SRPG warmth was the target.")
    lines.append("- Tracks are written as WAV so Godot can import them directly.")
    lines.append("- BGM manifest lives in `data/audio/bgm_manifest.json`.")
    README_PATH.write_text("\n".join(lines) + "\n", encoding="utf-8")


def write_manifest(tracks: list[dict[str, Any]]) -> None:
    manifest = {}
    for track in tracks:
        manifest[track["cue_id"]] = {
            "asset_path": track["asset_path"],
            "duration_ms": int(track["duration_sec"] * 1000),
            "lane": "bgm",
            "notes": track["notes"],
            "prompt": track["prompt"],
            "seed": track["seed"],
            "backend": track["backend"],
            "source_duration_sec": track["duration_sec"],
        }
    MANIFEST_PATH.write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


def try_import_acestep() -> tuple[Any, Any]:
    from acestep.pipeline_ace_step import ACEStepPipeline
    return ACEStepPipeline, None


def generate_with_acestep(
    spec: TrackSpec,
    checkpoint_dir: Path,
    output_path: Path,
    infer_steps: int,
    guidance_scale: float,
    cpu_offload: bool,
    torch_compile: bool,
) -> dict[str, Any]:
    ACEStepPipeline, _ = try_import_acestep()
    pipeline = ACEStepPipeline(
        checkpoint_dir=str(checkpoint_dir),
        cpu_offload=cpu_offload,
        torch_compile=torch_compile,
        quantized=False,
        overlapped_decode=True,
    )
    result = pipeline(
        prompt=spec.prompt,
        lyrics="",
        audio_duration=spec.duration_sec,
        infer_step=infer_steps,
        guidance_scale=guidance_scale,
        scheduler_type="euler",
        cfg_type="apg",
        omega_scale=10.0,
        use_erg_tag=True,
        use_erg_lyric=False,
        use_erg_diffusion=True,
        audio2audio_enable=False,
        batch_size=1,
        manual_seeds=[spec.seed],
        save_path=str(output_path),
        format="wav",
        debug=False,
    )
    saved_path = str(output_path)
    if isinstance(result, list) and result:
        for item in result:
            if isinstance(item, str) and item.endswith(".wav"):
                saved_path = item
                break
    return {
        "backend": "acestep",
        "asset_path": f"res://audio/bgm/{Path(saved_path).name}",
        "output_path": saved_path,
    }


def generate_with_musicgen(spec: TrackSpec, output_path: Path, device: str) -> dict[str, Any]:
    import torch
    import torchaudio
    from audiocraft.models import MusicGen

    if device == "mps":
        device = "cpu"
    model = MusicGen.get_pretrained("facebook/musicgen-small", device=device)
    model.set_generation_params(
        duration=spec.duration_sec,
        top_k=250,
        temperature=1.0,
        cfg_coef=3.0,
    )
    wav = model.generate([spec.prompt])[0].detach().cpu()
    sample_rate = getattr(model, "sample_rate", 32000)
    if wav.dim() == 1:
        wav = wav.unsqueeze(0)
    torchaudio.save(str(output_path), wav, sample_rate=sample_rate)
    return {
        "backend": "musicgen-small",
        "asset_path": f"res://audio/bgm/{output_path.name}",
        "output_path": str(output_path),
    }


def _clamp(sample: float) -> float:
    return max(-1.0, min(1.0, sample))


def _sine(freq: float, t: float) -> float:
    return math.sin(2.0 * math.pi * freq * t)


def _triangle(freq: float, t: float) -> float:
    phase = (t * freq) % 1.0
    return 4.0 * abs(phase - 0.5) - 1.0


def _note_frequency(semitone_offset: int, root_midi: int = 57) -> float:
    midi = root_midi + semitone_offset
    return 440.0 * (2.0 ** ((midi - 69) / 12.0))


def _write_wav(samples: list[float], output_path: Path, sample_rate: int = PLACEHOLDER_SAMPLE_RATE) -> None:
    output_path.parent.mkdir(parents=True, exist_ok=True)
    pcm = [int(_clamp(sample) * 32767.0) for sample in samples]
    with wave.open(str(output_path), "wb") as handle:
        handle.setnchannels(2)
        handle.setsampwidth(2)
        handle.setframerate(sample_rate)
        interleaved = bytearray()
        for value in pcm:
            packed = struct.pack("<h", value)
            interleaved.extend(packed)
            interleaved.extend(packed)
        handle.writeframes(interleaved)


def generate_with_placeholder(spec: TrackSpec, output_path: Path) -> dict[str, Any]:
    sample_rate = PLACEHOLDER_SAMPLE_RATE
    total_samples = int(spec.duration_sec * sample_rate)
    bpm_map = {
        "bgm_battle_default": 80.0,
        "bgm_battle_boss": 92.0,
        "bgm_camp": 72.0,
        "bgm_title": 68.0,
        "bgm_cutscene_ch01": 64.0,
    }
    root_map = {
        "bgm_battle_default": 0,
        "bgm_battle_boss": -2,
        "bgm_camp": -5,
        "bgm_title": -7,
        "bgm_cutscene_ch01": -9,
    }
    progression_map = {
        "bgm_battle_default": [[0, 3, 7], [5, 8, 12], [7, 10, 14], [3, 7, 10]],
        "bgm_battle_boss": [[-2, 1, 5], [3, 6, 10], [5, 8, 12], [1, 5, 8]],
        "bgm_camp": [[-5, -1, 2], [0, 3, 7], [-2, 2, 5], [-7, -3, 0]],
        "bgm_title": [[-7, -3, 0], [-2, 1, 5], [0, 3, 7], [-5, -1, 2]],
        "bgm_cutscene_ch01": [[-9, -5, -2], [-4, -1, 3], [-7, -3, 0], [-2, 1, 5]],
    }
    melody_map = {
        "bgm_battle_default": [7, 10, 12, 10, 7, 5, 3, 5],
        "bgm_battle_boss": [5, 8, 10, 8, 5, 3, 1, 3],
        "bgm_camp": [2, 3, 5, 7, 5, 3, 2, 0],
        "bgm_title": [0, 3, 5, 7, 8, 7, 5, 3],
        "bgm_cutscene_ch01": [-2, 0, 2, 3, 2, 0, -2, -5],
    }
    bass_map = {
        "bgm_battle_default": [0, 5, 7, 3],
        "bgm_battle_boss": [-2, 3, 5, 1],
        "bgm_camp": [-5, 0, -2, -7],
        "bgm_title": [-7, -2, 0, -5],
        "bgm_cutscene_ch01": [-9, -4, -7, -2],
    }
    cue_id = spec.cue_id
    bpm = bpm_map[cue_id]
    beat_duration = 60.0 / bpm
    bar_duration = beat_duration * 4.0
    progression = progression_map[cue_id]
    melody = melody_map[cue_id]
    bass = bass_map[cue_id]
    root_shift = root_map[cue_id]
    is_battle = "battle" in cue_id
    samples: list[float] = []
    for sample_index in range(total_samples):
        t = sample_index / sample_rate
        bar_index = int(t / bar_duration) % len(progression)
        beat_in_bar = (t % bar_duration) / beat_duration
        eighth_index = int(((t % bar_duration) / beat_duration) * 2.0) % len(melody)
        chord = progression[bar_index]
        pad = 0.0
        for semitone in chord:
            freq = _note_frequency(root_shift + semitone)
            pad += _sine(freq * 0.5, t) * 0.10
            pad += _triangle(freq, t) * 0.03
        bass_freq = _note_frequency(root_shift + bass[bar_index], root_midi=45)
        bass_wave = _triangle(bass_freq, t) * 0.16
        melody_freq = _note_frequency(root_shift + melody[eighth_index], root_midi=69)
        melody_gate = 1.0 if (beat_in_bar * 2.0) % 1.0 < 0.82 else 0.0
        phase_in_note = (t % (beat_duration / 2.0)) / (beat_duration / 2.0)
        melody_env = max(0.0, 1.0 - (phase_in_note * 0.35))
        lead = _sine(melody_freq, t) * 0.18 * melody_gate * melody_env
        percussion = 0.0
        phase_beat = t % beat_duration
        if is_battle and phase_beat < 0.06:
            percussion += _sine(90.0, phase_beat) * (1.0 - phase_beat / 0.06) * 0.20
        if beat_in_bar % 1.0 < 0.04:
            percussion += _sine(1400.0, phase_beat) * (1.0 - min(1.0, phase_beat / 0.03)) * 0.04
        slow_wobble = _sine(0.08, t) * 0.015
        sample = (pad + bass_wave + lead + percussion + slow_wobble) * 0.72
        samples.append(_clamp(sample))
    fade_samples = min(sample_rate, len(samples) // 8)
    for index in range(fade_samples):
        factor = index / max(1, fade_samples)
        samples[index] *= factor
        samples[-(index + 1)] *= factor
    _write_wav(samples, output_path, sample_rate=sample_rate)
    return {
        "backend": "placeholder-synth",
        "asset_path": f"res://audio/bgm/{output_path.name}",
        "output_path": str(output_path),
    }


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Generate the chapter one BGM pack.")
    parser.add_argument(
        "--backend",
        choices=["acestep", "musicgen", "placeholder"],
        default="acestep",
        help="Primary generation backend.",
    )
    parser.add_argument(
        "--checkpoint-dir",
        default=str(ACE_STEP_CHECKPOINT_DIR),
        help="ACE-Step checkpoint directory on the AI volume.",
    )
    parser.add_argument(
        "--infer-steps",
        type=int,
        default=24,
        help="ACE-Step inference steps.",
    )
    parser.add_argument(
        "--guidance-scale",
        type=float,
        default=7.5,
        help="ACE-Step guidance scale.",
    )
    parser.add_argument(
        "--cpu-offload",
        action="store_true",
        default=True,
        help="Use ACE-Step CPU offload.",
    )
    parser.add_argument(
        "--torch-compile",
        action="store_true",
        default=False,
        help="Enable ACE-Step torch.compile.",
    )
    parser.add_argument(
        "--musicgen-device",
        default="mps" if __import__("torch").backends.mps.is_available() else "cpu",
        help="Device for MusicGen fallback.",
    )
    parser.add_argument(
        "--duration-cap",
        type=int,
        default=0,
        help="If set, clamp every track duration to this many seconds for preview renders.",
    )
    parser.add_argument(
        "--only",
        action="append",
        default=[],
        help="Generate only matching cue ids. Can be passed multiple times.",
    )
    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()
    ensure_dirs()

    selected_tracks = TRACKS
    if args.only:
        selected = set(args.only)
        selected_tracks = [track for track in TRACKS if track.cue_id in selected]
    generated_tracks: list[dict[str, Any]] = []
    failures: list[dict[str, str]] = []

    if args.backend == "acestep":
        for spec in selected_tracks:
            effective_duration = (
                min(spec.duration_sec, args.duration_cap)
                if args.duration_cap and args.duration_cap > 0
                else spec.duration_sec
            )
            output_path = BGM_DIR / spec.file_name
            try:
                generated = generate_with_acestep(
                    spec=TrackSpec(
                        cue_id=spec.cue_id,
                        file_name=spec.file_name,
                        duration_sec=effective_duration,
                        seed=spec.seed,
                        prompt=spec.prompt,
                        notes=spec.notes,
                    ),
                    checkpoint_dir=Path(args.checkpoint_dir),
                    output_path=output_path,
                    infer_steps=args.infer_steps,
                    guidance_scale=args.guidance_scale,
                    cpu_offload=args.cpu_offload,
                    torch_compile=args.torch_compile,
                )
            except Exception as exc:  # pragma: no cover - fallback path
                failures.append({"cue_id": spec.cue_id, "error": repr(exc)})
                generated = generate_with_musicgen(
                    spec=TrackSpec(
                        cue_id=spec.cue_id,
                        file_name=spec.file_name,
                        duration_sec=effective_duration,
                        seed=spec.seed,
                        prompt=spec.prompt,
                        notes=spec.notes,
                    ),
                    output_path=output_path,
                    device=args.musicgen_device,
                )
            generated.update(
                {
                    "cue_id": spec.cue_id,
                    "duration_sec": effective_duration,
                    "requested_duration_sec": spec.duration_sec,
                    "seed": spec.seed,
                    "prompt": spec.prompt,
                    "notes": spec.notes,
                }
            )
            generated_tracks.append(generated)
            print(f"{spec.cue_id}: {generated['backend']} -> {generated['output_path']}")
    elif args.backend == "musicgen":
        for spec in selected_tracks:
            effective_duration = (
                min(spec.duration_sec, args.duration_cap)
                if args.duration_cap and args.duration_cap > 0
                else spec.duration_sec
            )
            output_path = BGM_DIR / spec.file_name
            generated = generate_with_musicgen(
                spec=TrackSpec(
                    cue_id=spec.cue_id,
                    file_name=spec.file_name,
                    duration_sec=effective_duration,
                    seed=spec.seed,
                    prompt=spec.prompt,
                    notes=spec.notes,
                ),
                output_path=output_path,
                device=args.musicgen_device,
            )
            generated.update(
                {
                    "cue_id": spec.cue_id,
                    "duration_sec": effective_duration,
                    "requested_duration_sec": spec.duration_sec,
                    "seed": spec.seed,
                    "prompt": spec.prompt,
                    "notes": spec.notes,
                }
            )
            generated_tracks.append(generated)
            print(f"{spec.cue_id}: {generated['backend']} -> {generated['output_path']}")
    else:
        for spec in selected_tracks:
            effective_duration = (
                min(spec.duration_sec, args.duration_cap)
                if args.duration_cap and args.duration_cap > 0
                else spec.duration_sec
            )
            output_path = BGM_DIR / spec.file_name
            generated = generate_with_placeholder(
                spec=TrackSpec(
                    cue_id=spec.cue_id,
                    file_name=spec.file_name,
                    duration_sec=effective_duration,
                    seed=spec.seed,
                    prompt=spec.prompt,
                    notes=spec.notes,
                ),
                output_path=output_path,
            )
            generated.update(
                {
                    "cue_id": spec.cue_id,
                    "duration_sec": effective_duration,
                    "requested_duration_sec": spec.duration_sec,
                    "seed": spec.seed,
                    "prompt": spec.prompt,
                    "notes": spec.notes,
                }
            )
            generated_tracks.append(generated)
            print(f"{spec.cue_id}: {generated['backend']} -> {generated['output_path']}")

    write_manifest(generated_tracks)
    write_readme(generated_tracks)

    summary = {
        "generated_count": len(generated_tracks),
        "failures": failures,
        "manifest_path": str(MANIFEST_PATH),
        "readme_path": str(README_PATH),
    }
    print(json.dumps(summary, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
