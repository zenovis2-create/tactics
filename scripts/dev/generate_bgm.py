"""
BGM placeholder generator — numpy + ffmpeg (libopus)
잿빛의 기억 / 5 tracks / 32-second loopable WAV → OGG 변환 없이 WAV 저장

출력: /Volumes/AI/tactics/audio/bgm/*.wav  (기존 파일 덮어쓰기)
"""

import numpy as np
import struct
import wave
import os
import math

SAMPLE_RATE = 44100
DURATION    = 32.0          # loopable
NUM_SAMPLES = int(SAMPLE_RATE * DURATION)
OUT_DIR     = "/Volumes/AI/tactics/audio/bgm"

# ─────────────────────────────────────────────
# 유틸리티
# ─────────────────────────────────────────────

def note_to_hz(midi: int) -> float:
    return 440.0 * (2.0 ** ((midi - 69) / 12.0))

def env(t, attack=0.01, decay=0.05, sustain=0.7, release=0.15, dur=0.5):
    """ADSR envelope 적용."""
    out = np.ones_like(t) * sustain
    a_end   = attack
    d_end   = attack + decay
    s_end   = dur - release
    out = np.where(t < a_end,  t / attack, out)
    out = np.where((t >= a_end) & (t < d_end),
                   1.0 - (1.0 - sustain) * (t - a_end) / decay, out)
    out = np.where(t >= s_end,
                   sustain * (1.0 - np.clip((t - s_end) / release, 0, 1)), out)
    return np.clip(out, 0, 1)

def sine_tone(freq, dur, amp=1.0, harmonics=None, sr=SAMPLE_RATE):
    """배음 포함 sine 합성. harmonics = [(ratio, amp), ...]"""
    t = np.linspace(0, dur, int(sr * dur), endpoint=False)
    s = np.sin(2 * np.pi * freq * t) * amp
    if harmonics:
        for ratio, ha in harmonics:
            s += np.sin(2 * np.pi * freq * ratio * t) * ha * amp
    return t, s

def note(midi, dur, amp=1.0, timbre="strings", sr=SAMPLE_RATE):
    """단일 노트 생성."""
    freq = note_to_hz(midi)
    t    = np.linspace(0, dur, int(sr * dur), endpoint=False)
    if timbre == "piano":
        h = [(2, 0.5), (3, 0.25), (4, 0.12), (5, 0.06)]
        s = sum(np.sin(2 * np.pi * freq * r * t) * a for r, a in [(1, 1.0)] + h)
        e = env(t, 0.005, 0.08, 0.4, 0.25, dur)
    elif timbre == "strings":
        h = [(2, 0.6), (3, 0.4), (4, 0.25), (5, 0.15), (6, 0.08)]
        s = sum(np.sin(2 * np.pi * freq * r * t) * a for r, a in [(1, 1.0)] + h)
        # 약간의 vibrato
        vib = 1.0 + 0.003 * np.sin(2 * np.pi * 5.5 * t)
        s *= vib
        e = env(t, 0.08, 0.05, 0.75, 0.2, dur)
    elif timbre == "brass":
        h = [(2, 0.8), (3, 0.6), (4, 0.4), (5, 0.2), (6, 0.1)]
        s = sum(np.sin(2 * np.pi * freq * r * t) * a for r, a in [(1, 1.0)] + h)
        e = env(t, 0.04, 0.06, 0.8, 0.12, dur)
    elif timbre == "harp":
        h = [(2, 0.4), (3, 0.2), (4, 0.1)]
        s = sum(np.sin(2 * np.pi * freq * r * t) * a for r, a in [(1, 1.0)] + h)
        e = env(t, 0.003, 0.12, 0.1, 0.05, dur)
    elif timbre == "choir":
        # formant-like soft choir
        h = [(2, 0.35), (3, 0.2), (4, 0.1)]
        s = sum(np.sin(2 * np.pi * freq * r * t) * a for r, a in [(1, 1.0)] + h)
        vib = 1.0 + 0.005 * np.sin(2 * np.pi * 4.8 * t)
        s *= vib
        e = env(t, 0.15, 0.1, 0.6, 0.3, dur)
    else:
        s = np.sin(2 * np.pi * freq * t)
        e = env(t, 0.01, 0.05, 0.7, 0.1, dur)
    return (s * e * amp).astype(np.float32)

def drum_kick(dur=0.25, sr=SAMPLE_RATE):
    t = np.linspace(0, dur, int(sr * dur), endpoint=False)
    freq_env = 120 * np.exp(-30 * t) + 40
    s = np.sin(2 * np.pi * np.cumsum(freq_env) / sr)
    e = np.exp(-18 * t)
    return (s * e * 0.7).astype(np.float32)

def drum_snare(dur=0.2, sr=SAMPLE_RATE):
    t = np.linspace(0, dur, int(sr * dur), endpoint=False)
    noise = np.random.randn(len(t)).astype(np.float32)
    e = np.exp(-20 * t)
    tone = np.sin(2 * np.pi * 200 * t) * np.exp(-40 * t)
    return ((noise * e * 0.4 + tone * 0.3)).astype(np.float32)

def place(buf, sig, offset_samples):
    end = min(offset_samples + len(sig), len(buf))
    n   = end - offset_samples
    if n > 0:
        buf[offset_samples:end] += sig[:n]

def beat_to_s(beat, bpm):
    return beat * 60.0 / bpm

def save_wav(buf, path):
    buf = np.clip(buf, -1.0, 1.0)
    # fade in/out 0.5s for seamless loop
    fade = int(SAMPLE_RATE * 0.5)
    ramp = np.linspace(0, 1, fade, dtype=np.float32)
    buf[:fade]  *= ramp
    buf[-fade:] *= ramp[::-1]
    with wave.open(path, 'w') as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)   # 16-bit int
        wf.setframerate(SAMPLE_RATE)
        pcm = (buf * 32767).astype(np.int16)
        wf.writeframes(pcm.tobytes())
    print(f"  saved: {os.path.basename(path)}  ({len(buf)/SAMPLE_RATE:.1f}s)")


# ─────────────────────────────────────────────
# Track 1: bgm_title   A minor 68BPM
# 타이틀 화면 — 쓸쓸한 멜로디, 현악+합창
# ─────────────────────────────────────────────

def gen_title():
    bpm  = 68
    buf  = np.zeros(NUM_SAMPLES, dtype=np.float32)

    # A minor scale: A B C D E F G
    # MIDI: A3=57, B3=59, C4=60, D4=62, E4=64, F4=65, G4=67, A4=69

    melody = [
        # (midi, beats, timbre, amp)
        (69, 2, "strings", 0.35),  # A4
        (67, 1, "strings", 0.28),  # G
        (65, 1, "strings", 0.28),  # F
        (64, 2, "strings", 0.32),  # E
        (62, 2, "strings", 0.28),  # D
        (60, 2, "strings", 0.32),  # C
        (62, 2, "strings", 0.28),  # D
        (64, 4, "strings", 0.35),  # E  (held)
        # phrase 2
        (65, 2, "strings", 0.32),  # F
        (67, 1, "strings", 0.28),  # G
        (69, 1, "strings", 0.28),  # A4
        (72, 3, "strings", 0.38),  # C5
        (71, 1, "strings", 0.28),  # B
        (69, 4, "strings", 0.35),  # A4 (held)
    ]

    # choir pad — sustain chords
    chords = [
        (0,  [57, 60, 64], 8, "choir", 0.18),  # Am
        (8,  [55, 59, 62], 4, "choir", 0.16),  # G
        (12, [53, 57, 60], 4, "choir", 0.16),  # F
        (16, [52, 55, 59], 4, "choir", 0.16),  # Em
        (20, [53, 57, 60], 4, "choir", 0.18),  # F
        (24, [55, 59, 62], 4, "choir", 0.16),  # G
        (28, [57, 60, 64], 4, "choir", 0.18),  # Am
    ]

    beat = 0
    for (midi, beats, timbre, amp) in melody:
        t0 = int(beat_to_s(beat, bpm) * SAMPLE_RATE)
        dur = beat_to_s(beats, bpm) + 0.05
        place(buf, note(midi, dur, amp, timbre), t0)
        # harmony a third below
        place(buf, note(midi - 3, dur, amp * 0.6, "strings"), t0)
        beat += beats

    for (b, notes, beats, timbre, amp) in chords:
        t0  = int(beat_to_s(b, bpm) * SAMPLE_RATE)
        dur = beat_to_s(beats, bpm) + 0.1
        for n in notes:
            place(buf, note(n, dur, amp, timbre), t0)

    save_wav(buf, os.path.join(OUT_DIR, "bgm_title.wav"))


# ─────────────────────────────────────────────
# Track 2: bgm_battle_default   E minor 80BPM
# 일반 전투 — 현악+금관, 긴장감
# ─────────────────────────────────────────────

def gen_battle_default():
    bpm = 80
    buf = np.zeros(NUM_SAMPLES, dtype=np.float32)

    # Em: E3=52, G3=55, B3=59
    # 4박 스네어/킥 패턴 (1마디 = 4비트)

    beats_total = int(DURATION * bpm / 60)
    measure = 4

    for b in range(0, beats_total, measure):
        t_kick   = int(beat_to_s(b,     bpm) * SAMPLE_RATE)
        t_kick2  = int(beat_to_s(b+2,   bpm) * SAMPLE_RATE)
        t_snare  = int(beat_to_s(b+1,   bpm) * SAMPLE_RATE)
        t_snare2 = int(beat_to_s(b+3,   bpm) * SAMPLE_RATE)
        place(buf, drum_kick(), t_kick)
        place(buf, drum_kick() * 0.7, t_kick2)
        place(buf, drum_snare(), t_snare)
        place(buf, drum_snare(), t_snare2)

    # brass ostinato: 8분음표 리프 (E G B E)
    riff = [52, 55, 59, 64, 59, 55, 52, 55]  # E G B E B G E G
    beat_dur = beat_to_s(0.5, bpm)
    for i, m in enumerate(riff * (beats_total // len(riff) + 1)):
        t0 = int(beat_to_s(i * 0.5, bpm) * SAMPLE_RATE)
        if t0 >= NUM_SAMPLES:
            break
        place(buf, note(m, beat_dur + 0.02, 0.22, "brass"), t0)

    # 현악 코드
    chords_b = [
        (0,  [52, 55, 59], 4, "strings", 0.2),  # Em
        (4,  [50, 53, 57], 4, "strings", 0.2),  # Dm
        (8,  [48, 52, 55], 4, "strings", 0.2),  # Cm
        (12, [50, 53, 57], 4, "strings", 0.2),  # Dm
        (16, [52, 55, 59], 4, "strings", 0.2),  # Em
        (20, [47, 52, 55], 4, "strings", 0.2),  # Bm/B
        (24, [48, 52, 55], 4, "strings", 0.2),  # Cm
        (28, [50, 53, 57], 4, "strings", 0.2),  # Dm
    ]
    for (b, notes, beats, timbre, amp) in chords_b:
        t0  = int(beat_to_s(b, bpm) * SAMPLE_RATE)
        dur = beat_to_s(beats, bpm) + 0.05
        for n in notes:
            place(buf, note(n, dur, amp, timbre), t0)

    save_wav(buf, os.path.join(OUT_DIR, "bgm_battle_default.wav"))


# ─────────────────────────────────────────────
# Track 3: bgm_battle_boss   D minor 92BPM
# 보스 전투 — 금관 오스티나토, 저음 강조, 위압감
# ─────────────────────────────────────────────

def gen_battle_boss():
    bpm = 92
    buf = np.zeros(NUM_SAMPLES, dtype=np.float32)

    beats_total = int(DURATION * bpm / 60)

    # 더 빠른 킥 패턴 (2/4박)
    for b in range(0, beats_total):
        t0 = int(beat_to_s(b, bpm) * SAMPLE_RATE)
        place(buf, drum_kick() * 0.9, t0)
        if b % 2 == 1:
            place(buf, drum_snare(), t0)

    # 짧은 off-beat 킥
    for b in range(0, beats_total, 2):
        t0 = int(beat_to_s(b + 0.5, bpm) * SAMPLE_RATE)
        place(buf, drum_kick() * 0.5, t0)

    # brass ostinato: Dm feel — D F A C
    boss_riff = [50, 53, 57, 48, 50, 48, 53, 50]  # D F A C D C F D (lower)
    for i, m in enumerate(boss_riff * (beats_total // len(boss_riff) + 1)):
        t0 = int(beat_to_s(i * 0.5, bpm) * SAMPLE_RATE)
        if t0 >= NUM_SAMPLES:
            break
        place(buf, note(m, beat_to_s(0.45, bpm), 0.30, "brass"), t0)

    # 저음 현악 (베이스라인)
    bass = [38, 38, 41, 36, 38, 36, 41, 38]  # D2 D F C D C F D
    for i, m in enumerate(bass * (beats_total // len(bass) + 1)):
        t0 = int(beat_to_s(i * 1.0, bpm) * SAMPLE_RATE)
        if t0 >= NUM_SAMPLES:
            break
        place(buf, note(m, beat_to_s(0.9, bpm), 0.28, "strings"), t0)

    # 상위 멜로디 현악 — 위협적 라인
    melody_b = [
        (0,  62, 2, "strings", 0.25),  # D4
        (2,  60, 1, "strings", 0.22),  # C
        (3,  61, 1, "strings", 0.22),  # Db
        (4,  62, 3, "strings", 0.28),  # D4
        (7,  65, 1, "strings", 0.25),  # F
        (8,  64, 2, "strings", 0.25),  # E
        (10, 62, 2, "strings", 0.22),  # D
        (12, 60, 4, "strings", 0.28),  # C (held)
    ]
    for (b, m, beats, timbre, amp) in melody_b:
        t0  = int(beat_to_s(b, bpm) * SAMPLE_RATE)
        dur = beat_to_s(beats, bpm) + 0.05
        place(buf, note(m, dur, amp, timbre), t0)

    save_wav(buf, os.path.join(OUT_DIR, "bgm_battle_boss.wav"))


# ─────────────────────────────────────────────
# Track 4: bgm_camp   G major 72BPM
# 야영지 — 피아노+하프, 따뜻하고 안락
# ─────────────────────────────────────────────

def gen_camp():
    bpm = 72
    buf = np.zeros(NUM_SAMPLES, dtype=np.float32)

    # G major: G A B C D E F# G
    # 피아노 아르페지오 + 하프 아르페지오 + 현악 패드

    # 하프 아르페지오 (G 장조 코드)
    arpeggios = [
        (0,  [55, 59, 62, 67], 1, "harp", 0.30),  # G B D G
        (4,  [53, 57, 60, 65], 1, "harp", 0.28),  # F A C F — FM7
        (8,  [55, 59, 62, 67], 1, "harp", 0.30),  # G
        (12, [52, 55, 59, 64], 1, "harp", 0.28),  # Em
        (16, [53, 57, 60, 65], 1, "harp", 0.28),  # F
        (20, [50, 54, 57, 62], 1, "harp", 0.28),  # Dm
        (24, [52, 55, 59, 64], 1, "harp", 0.30),  # Em
        (28, [55, 59, 62, 67], 1, "harp", 0.32),  # G
    ]
    for (start_b, notes, step_b, timbre, amp) in arpeggios:
        for i, n in enumerate(notes * 4):
            beat = start_b + i * step_b
            t0   = int(beat_to_s(beat, bpm) * SAMPLE_RATE)
            if t0 >= NUM_SAMPLES:
                break
            place(buf, note(n % 12 + 48 + (i // 4) * 12, beat_to_s(0.8, bpm), amp, timbre), t0)

    # 피아노 멜로디
    melody_c = [
        (0,  67, 2, "piano", 0.30),  # G4
        (2,  69, 1, "piano", 0.26),  # A
        (3,  71, 1, "piano", 0.26),  # B
        (4,  72, 3, "piano", 0.32),  # C5
        (7,  71, 1, "piano", 0.26),  # B
        (8,  69, 2, "piano", 0.28),  # A
        (10, 67, 2, "piano", 0.26),  # G
        (12, 65, 2, "piano", 0.28),  # F
        (14, 64, 2, "piano", 0.26),  # E
        (16, 62, 4, "piano", 0.30),  # D (held)
        (20, 64, 2, "piano", 0.28),  # E
        (22, 65, 1, "piano", 0.26),  # F
        (23, 67, 1, "piano", 0.26),  # G
        (24, 69, 4, "piano", 0.32),  # A (held)
        (28, 67, 4, "piano", 0.35),  # G (cadence)
    ]
    for (b, m, beats, timbre, amp) in melody_c:
        t0  = int(beat_to_s(b, bpm) * SAMPLE_RATE)
        dur = beat_to_s(beats, bpm) + 0.04
        place(buf, note(m, dur, amp, timbre), t0)

    # 현악 패드 (낮은 G, 따뜻한 배경)
    for chord_b, notes in [(0, [43, 47, 50]), (8, [43, 47, 50]), (16, [41, 45, 48]), (24, [43, 47, 50])]:
        t0  = int(beat_to_s(chord_b, bpm) * SAMPLE_RATE)
        dur = beat_to_s(8.0, bpm) + 0.1
        for n in notes:
            place(buf, note(n, dur, 0.18, "strings"), t0)

    save_wav(buf, os.path.join(OUT_DIR, "bgm_camp.wav"))


# ─────────────────────────────────────────────
# Track 5: bgm_cutscene_ch01   A minor 64BPM
# 컷씬 ch01 — 서정적, 기억과 상실, 피아노+현악
# ─────────────────────────────────────────────

def gen_cutscene_ch01():
    bpm = 64
    buf = np.zeros(NUM_SAMPLES, dtype=np.float32)

    # 피아노 주제: Am → F → C → G (순환)
    melody_cs = [
        (0,  69, 3, "piano", 0.32),   # A4
        (3,  67, 1, "piano", 0.26),   # G
        (4,  65, 2, "piano", 0.28),   # F
        (6,  64, 2, "piano", 0.26),   # E
        (8,  62, 4, "piano", 0.30),   # D (held)
        (12, 60, 2, "piano", 0.28),   # C
        (14, 62, 2, "piano", 0.26),   # D
        (16, 64, 3, "piano", 0.30),   # E
        (19, 65, 1, "piano", 0.24),   # F
        (20, 67, 4, "piano", 0.32),   # G (held)
        (24, 69, 3, "piano", 0.35),   # A4
        (27, 71, 1, "piano", 0.28),   # B
        (28, 72, 4, "piano", 0.38),   # C5 (peak, held)
    ]
    for (b, m, beats, timbre, amp) in melody_cs:
        t0  = int(beat_to_s(b, bpm) * SAMPLE_RATE)
        dur = beat_to_s(beats, bpm) + 0.06
        place(buf, note(m, dur, amp, timbre), t0)
        # 한 옥타브 아래 현악 더블링
        place(buf, note(m - 12, dur, amp * 0.45, "strings"), t0)

    # 현악 코드 패드
    cs_chords = [
        (0,  [57, 60, 64], 8, "strings", 0.20),  # Am
        (8,  [53, 57, 60], 8, "strings", 0.18),  # F
        (16, [48, 52, 55], 8, "strings", 0.18),  # C
        (24, [55, 59, 62], 8, "strings", 0.20),  # G
    ]
    for (b, notes, beats, timbre, amp) in cs_chords:
        t0  = int(beat_to_s(b, bpm) * SAMPLE_RATE)
        dur = beat_to_s(beats, bpm) + 0.1
        for n in notes:
            place(buf, note(n, dur, amp, timbre), t0)

    save_wav(buf, os.path.join(OUT_DIR, "bgm_cutscene_ch01.wav"))


# ─────────────────────────────────────────────
# main
# ─────────────────────────────────────────────

if __name__ == "__main__":
    os.makedirs(OUT_DIR, exist_ok=True)
    np.random.seed(42)
    print("BGM 생성 시작...")
    gen_title()
    gen_battle_default()
    gen_battle_boss()
    gen_camp()
    gen_cutscene_ch01()
    print("완료.")
