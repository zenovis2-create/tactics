#!/usr/bin/env python3
"""
Ashen Bell — Placeholder SFX Generator
Synthesizes Tier 0 + Tier 1 SFX as .ogg files using pure Python WAV synthesis + ffmpeg OGG conversion.

Design direction:
- battle_hit_*  : wood/metal impact, compact click
- battle_boss_* : seal-stamp pulse, ember edge, narrow rise
- battle_state_*: broad but clipped pulse markers
- battle_miss_* : filtered whoosh / scrape-through
- battle_counter_*: deflect transient, sting
- ui_*          : dry ticks, slides, soft glass/metal
- camp_*        : parchment, cloth, clasp, low ember warmth
"""

import math, struct, subprocess, sys, wave
from pathlib import Path

SAMPLE_RATE = 22050
CHANNELS    = 1
OUT_ROOT    = Path("/Volumes/AI/tactics/assets/audio/sfx/placeholders")

# ── Core synthesis helpers ────────────────────────────────────────────────────

def sine(freq, t):          return math.sin(2 * math.pi * freq * t)
def square(freq, t):        return 1.0 if (t * freq % 1.0) < 0.5 else -1.0
def noise(t):               import random; return random.uniform(-1, 1)
def env_ad(t, attack, decay, total):
    """Linear attack-decay envelope."""
    if t < attack:
        return t / attack if attack > 0 else 1.0
    elif t < attack + decay:
        return 1.0 - (t - attack) / decay
    return 0.0
def env_exp_decay(t, decay):
    """Exponential decay envelope."""
    return math.exp(-t / decay) if decay > 0 else 0.0
def clip(v, lo=-1.0, hi=1.0):
    return max(lo, min(hi, v))
def mix(*signals):
    return sum(signals) / max(1, len(signals))

def render(fn, duration, sr=SAMPLE_RATE):
    """Render a sample function to a list of floats."""
    n = int(duration * sr)
    return [clip(fn(i / sr)) for i in range(n)]

def save_wav(samples, path: Path, sr=SAMPLE_RATE):
    path.parent.mkdir(parents=True, exist_ok=True)
    with wave.open(str(path.with_suffix('.wav')), 'w') as f:
        f.setnchannels(CHANNELS)
        f.setsampwidth(2)
        f.setframerate(sr)
        data = struct.pack(f'<{len(samples)}h',
                           *[int(max(-32767, min(32767, s * 32767))) for s in samples])
        f.writeframes(data)

def wav_to_ogg(wav_path: Path, ogg_path: Path, quality=3):
    subprocess.run(
        ['ffmpeg', '-y', '-i', str(wav_path),
         '-c:a', 'libopus', '-b:a', '64k',
         str(ogg_path)],
        capture_output=True, check=True
    )
    wav_path.unlink()

def save(samples, ogg_path: Path):
    wav_path = ogg_path.with_suffix('.wav')
    save_wav(samples, wav_path)
    wav_to_ogg(wav_path, ogg_path)
    print(f"  ✓ {ogg_path.relative_to(OUT_ROOT.parent.parent.parent)}")

# ── SFX Synthesizers ─────────────────────────────────────────────────────────

def sfx_impact_compact(pitch=400, body_pitch=120, dur=0.18):
    """Compact wood/metal hit — battle_hit_confirm."""
    def fn(t):
        env = env_exp_decay(t, 0.05)
        body_env = env_exp_decay(t, 0.12)
        click = sine(pitch * (1 - t * 4), t) * env
        body  = sine(body_pitch, t) * body_env * 0.5
        return clip((click + body) * 0.85)
    return render(fn, dur)

def sfx_whoosh_miss(dur=0.22):
    """Filtered whoosh / scrape-through — battle_miss."""
    import random; rng = random.Random(42)
    def fn(t):
        env   = env_ad(t, 0.04, 0.18, dur)
        freq  = 800 + 1200 * (1 - t / dur)
        n_raw = rng.uniform(-1, 1)
        # LP-ish: mix noise with sine undertone
        s = mix(n_raw * 0.7, sine(freq, t) * 0.3) * env
        return clip(s * 0.6)
    return render(fn, dur)

def sfx_deflect_counter(dur=0.20):
    """Deflect sting — battle_counter_hit."""
    def fn(t):
        env1 = env_exp_decay(t, 0.03)
        env2 = env_exp_decay(t, 0.14)
        sting  = sine(900 + 200 * math.exp(-t * 30), t) * env1
        body   = sine(220, t) * env2 * 0.4
        return clip((sting + body) * 0.9)
    return render(fn, dur)

def sfx_seal_stamp(dur=0.28):
    """Stamped seal tick + narrow rise — battle_boss_mark_warn."""
    def fn(t):
        # Stamp transient
        stamp_env = env_exp_decay(t, 0.04)
        stamp = mix(sine(80, t), sine(160, t)) * stamp_env
        # Rise tone
        if t > 0.05:
            rise_t = t - 0.05
            rise_env = env_ad(rise_t, 0.06, 0.15, 0.21)
            rise_freq = 320 + 180 * (rise_t / 0.21)
            rise = sine(rise_freq, rise_t) * rise_env * 0.5
        else:
            rise = 0.0
        return clip((stamp + rise) * 0.9)
    return render(fn, dur)

def sfx_barred_pulse(dur=0.24):
    """Clipped pulse in barred rhythm — battle_boss_command_warn."""
    def fn(t):
        # Two quick pulses
        p1_env = env_exp_decay(t, 0.04) if t < 0.12 else 0.0
        p2_env = env_exp_decay(t - 0.12, 0.04) if t >= 0.12 else 0.0
        p1 = sine(100, t) * p1_env
        p2 = sine(100, t - 0.12) * p2_env * 0.7
        return clip((p1 + p2) * 0.85)
    return render(fn, dur)

def sfx_thrust_impact(dur=0.30):
    """Forward thrust into compact impact — battle_boss_charge_impact."""
    def fn(t):
        # Thrust lead
        if t < 0.12:
            thrust_env = t / 0.12
            thrust = sine(200 + 400 * (t / 0.12), t) * thrust_env * 0.4
        else:
            thrust = 0.0
        # Impact
        if t >= 0.12:
            imp_t = t - 0.12
            imp_env = env_exp_decay(imp_t, 0.06)
            imp = mix(sine(80, imp_t), sine(200, imp_t)) * imp_env
        else:
            imp = 0.0
        return clip((thrust + imp) * 0.9)
    return render(fn, dur)

def sfx_broad_pulse_upward(dur=0.22):
    """Restrained upward brace — battle_state_player_phase."""
    def fn(t):
        env   = env_ad(t, 0.06, 0.16, dur)
        sweep = sine(220 + 180 * (t / dur), t)
        return clip(sweep * env * 0.7)
    return render(fn, dur)

def sfx_broad_pulse_downward(dur=0.22):
    """Firmer low pulse — battle_state_enemy_phase."""
    def fn(t):
        env  = env_ad(t, 0.02, 0.20, dur)
        tone = mix(sine(120, t), sine(80, t)) * env
        return clip(tone * 0.75)
    return render(fn, dur)

def sfx_dry_tick(pitch=1200, dur=0.10):
    """Dry tick — UI utility."""
    def fn(t):
        env = env_exp_decay(t, 0.04)
        return clip(sine(pitch, t) * env * 0.7)
    return render(fn, dur)

def sfx_panel_open(dur=0.18):
    """Dry panel reveal — ui_inventory_open."""
    def fn(t):
        env  = env_ad(t, 0.04, 0.14, dur)
        slide = sine(600 + 400 * (t / dur), t) * env * 0.5
        tick  = env_exp_decay(t, 0.03) * sine(1400, t) * 0.4
        return clip(slide + tick)
    return render(fn, dur)

def sfx_panel_close(dur=0.14):
    """Short fold-away — ui_inventory_close."""
    def fn(t):
        env  = env_ad(t, 0.01, 0.13, dur)
        slide = sine(1000 - 400 * (t / dur), t) * env * 0.5
        return clip(slide * 0.65)
    return render(fn, dur)

def sfx_cancel(dur=0.14):
    """Soft downward tick — ui_cancel."""
    def fn(t):
        env = env_exp_decay(t, 0.06)
        tone = sine(400 - 200 * (t / dur), t) * env
        return clip(tone * 0.55)
    return render(fn, dur)

def sfx_confirm(dur=0.16):
    """Restrained forward confirm — ui_confirm."""
    def fn(t):
        env = env_ad(t, 0.03, 0.13, dur)
        tone = sine(600 + 100 * (t / dur), t) * env
        return clip(tone * 0.65)
    return render(fn, dur)

def sfx_parchment_glint(dur=0.20):
    """Gentle upward glint — camp_recommend_focus / camp_memory_reveal."""
    def fn(t):
        env  = env_ad(t, 0.05, 0.15, dur)
        tone = sine(800 + 400 * (t / dur), t) * env * 0.45
        return clip(tone)
    return render(fn, dur)

def sfx_tab_shift(dur=0.12):
    """Brushed tick + soft slide — ui_panel_tab_shift."""
    import random; rng = random.Random(7)
    def fn(t):
        tick_env  = env_exp_decay(t, 0.02)
        slide_env = env_ad(t, 0.02, 0.10, dur)
        tick  = rng.uniform(-1, 1) * tick_env * 0.4
        slide = sine(500 + 300 * (t / dur), t) * slide_env * 0.3
        return clip(tick + slide)
    return render(fn, dur)

def sfx_emblem_tick(dur=0.14):
    """Soft emblem tick — camp_party_select."""
    def fn(t):
        env = env_exp_decay(t, 0.06)
        return clip(sine(700, t) * env * 0.55)
    return render(fn, dur)

def sfx_confirm_low_pulse(dur=0.24):
    """Confirm + low pulse — camp_next_battle_confirm."""
    def fn(t):
        env_c = env_exp_decay(t, 0.06)
        env_p = env_exp_decay(t, 0.18)
        confirm = sine(600, t) * env_c * 0.5
        pulse   = sine(100, t) * env_p * 0.5
        return clip(confirm + pulse)
    return render(fn, dur)

def sfx_metal_slide(dur=0.20):
    """Metal slide + latch — camp_loadout_weapon_cycle."""
    def fn(t):
        slide_env = env_ad(t, 0.06, 0.14, dur)
        latch_env = env_exp_decay(max(0, t - 0.16), 0.03)
        slide = sine(300 + 200 * (t / dur), t) * slide_env * 0.45
        latch = sine(1200, t) * latch_env * 0.4
        return clip(slide + latch)
    return render(fn, dur)

def sfx_cloth_clasp(dur=0.18):
    """Cloth move + clasp — camp_loadout_armor_cycle."""
    import random; rng = random.Random(13)
    def fn(t):
        cloth_env = env_ad(t, 0.04, 0.12, dur)
        clasp_env = env_exp_decay(max(0, t - 0.13), 0.04)
        cloth = rng.uniform(-1, 1) * cloth_env * 0.3
        clasp = sine(800, t) * clasp_env * 0.45
        return clip(cloth + clasp)
    return render(fn, dur)

def sfx_charm_ring(dur=0.22):
    """Charm ring + soft click — camp_loadout_accessory_cycle."""
    def fn(t):
        ring_env  = env_exp_decay(t, 0.10)
        click_env = env_exp_decay(t, 0.03)
        ring  = sine(1000 + 200 * math.exp(-t * 10), t) * ring_env * 0.5
        click = sine(1600, t) * click_env * 0.3
        return clip(ring + click)
    return render(fn, dur)

def sfx_confirm_variant(dur=0.20):
    """Confirm variant + gear settle — camp_party_assign."""
    def fn(t):
        env_c = env_exp_decay(t, 0.05)
        env_s = env_exp_decay(t, 0.14)
        conf = sine(650, t) * env_c * 0.5
        settle = mix(sine(180, t), sine(90, t)) * env_s * 0.4
        return clip(conf + settle)
    return render(fn, dur)

# ── Tier 1 Reserve cues ───────────────────────────────────────────────────────

def sfx_heavy_impact(dur=0.24):
    """Stronger boss-class hit — battle_hit_confirm_heavy."""
    def fn(t):
        env = env_exp_decay(t, 0.08)
        b   = env_exp_decay(t, 0.18)
        hit  = mix(sine(100, t), sine(250, t)) * env
        tail = sine(80, t) * b * 0.4
        return clip((hit + tail) * 0.9)
    return render(fn, dur)

def sfx_ally_pain(dur=0.20):
    """Ally damage — sympathetic lane — battle_pain_ally."""
    def fn(t):
        env = env_exp_decay(t, 0.07)
        s   = sine(300 - 100 * (t / dur), t) * env * 0.6
        n_env = env_exp_decay(t, 0.04)
        import random; rng = random.Random(99)
        n = rng.uniform(-1, 1) * n_env * 0.3
        return clip(s + n)
    return render(fn, dur)

def sfx_enemy_pain(dur=0.18):
    """Enemy damage — hostile lane — battle_pain_enemy."""
    def fn(t):
        env = env_exp_decay(t, 0.05)
        s   = sine(160 - 60 * (t / dur), t) * env * 0.7
        return clip(s)
    return render(fn, dur)

def sfx_action_commit(dur=0.12):
    """Attack commit intent — battle_action_commit."""
    def fn(t):
        env = env_exp_decay(t, 0.05)
        return clip(sine(500, t) * env * 0.6)
    return render(fn, dur)

def sfx_wait_action(dur=0.14):
    """Battle wait action — battle_action_wait."""
    def fn(t):
        env = env_ad(t, 0.04, 0.10, dur)
        return clip(sine(300, t) * env * 0.45)
    return render(fn, dur)

def sfx_unit_defeat(dur=0.32):
    """Unit removal — battle_unit_defeat."""
    def fn(t):
        env  = env_exp_decay(t, 0.12)
        fall = sine(200 - 150 * (t / dur), t) * env
        return clip(fall * 0.7)
    return render(fn, dur)

def sfx_round_advance(dur=0.20):
    """Round turnover — battle_state_round_advance."""
    def fn(t):
        env = env_ad(t, 0.04, 0.16, dur)
        return clip(mix(sine(180, t), sine(240, t)) * env * 0.6)
    return render(fn, dur)

def sfx_boss_danger(dur=0.36):
    """Highest-priority boss state — battle_boss_danger."""
    def fn(t):
        env  = env_exp_decay(t, 0.10)
        env2 = env_exp_decay(t, 0.30)
        stamp = mix(sine(60, t), sine(120, t)) * env
        rise  = sine(160 + 80 * (t / dur), t) * env2 * 0.5
        return clip((stamp + rise) * 0.9)
    return render(fn, dur)

def sfx_result_victory(dur=0.60):
    """Victory result — battle_result_victory."""
    def fn(t):
        env = env_ad(t, 0.08, 0.52, dur)
        chord = mix(
            sine(330, t),
            sine(415, t),
            sine(495, t),
        )
        return clip(chord * env * 0.75)
    return render(fn, dur)

def sfx_result_defeat(dur=0.60):
    """Defeat result — battle_result_defeat."""
    def fn(t):
        env = env_ad(t, 0.06, 0.54, dur)
        fall = mix(
            sine(220 - 80 * (t / dur), t),
            sine(165 - 60 * (t / dur), t),
        )
        return clip(fall * env * 0.6)
    return render(fn, dur)

def sfx_tap_soft(dur=0.10):
    """Generic soft tap — ui_common_tap_soft."""
    def fn(t):
        env = env_exp_decay(t, 0.04)
        return clip(sine(900, t) * env * 0.45)
    return render(fn, dur)

def sfx_tap_primary(dur=0.12):
    """Primary CTA tap — ui_common_tap_primary."""
    def fn(t):
        env = env_exp_decay(t, 0.05)
        return clip(sine(700, t) * env * 0.6)
    return render(fn, dur)

def sfx_invalid(dur=0.14):
    """Muted invalid — ui_common_invalid."""
    def fn(t):
        env = env_exp_decay(t, 0.07)
        return clip(mix(sine(200, t), sine(150, t)) * env * 0.35)
    return render(fn, dur)

def sfx_panel_open_generic(dur=0.16):
    """Generic open — ui_panel_open."""
    def fn(t):
        env = env_ad(t, 0.03, 0.13, dur)
        return clip(sine(500 + 300 * (t / dur), t) * env * 0.5)
    return render(fn, dur)

def sfx_panel_close_generic(dur=0.14):
    """Generic close — ui_panel_close."""
    def fn(t):
        env = env_ad(t, 0.01, 0.13, dur)
        return clip(sine(800 - 300 * (t / dur), t) * env * 0.5)
    return render(fn, dur)

def sfx_panel_dismiss(dur=0.12):
    """Overlay dismiss — ui_panel_dismiss."""
    def fn(t):
        env = env_exp_decay(t, 0.05)
        return clip(sine(600, t) * env * 0.4)
    return render(fn, dur)

def sfx_camp_enter(dur=0.50):
    """Key emotional reset — camp_hub_enter."""
    def fn(t):
        env  = env_ad(t, 0.12, 0.38, dur)
        warm = mix(sine(220, t), sine(330, t), sine(165, t))
        return clip(warm * env * 0.55)
    return render(fn, dur)

def sfx_unlock_notice(dur=0.28):
    """System unlock — camp_unlock_notice."""
    def fn(t):
        env = env_ad(t, 0.06, 0.22, dur)
        tone = mix(sine(440, t), sine(550, t)) * env
        return clip(tone * 0.6)
    return render(fn, dur)

def sfx_dialogue_new(dur=0.18):
    """Dialogue available — camp_dialogue_new."""
    def fn(t):
        env = env_ad(t, 0.04, 0.14, dur)
        return clip(sine(660, t) * env * 0.5)
    return render(fn, dur)

def sfx_letter_new(dur=0.22):
    """Personal correspondence — camp_letter_new."""
    import random; rng = random.Random(21)
    def fn(t):
        parch_env = env_ad(t, 0.06, 0.14, dur)
        tick_env  = env_exp_decay(t, 0.04)
        parch = rng.uniform(-1, 1) * parch_env * 0.25
        tick  = sine(800, t) * tick_env * 0.5
        return clip(parch + tick)
    return render(fn, dur)

def sfx_evidence_reveal(dur=0.30):
    """Proof/discovery — camp_evidence_reveal."""
    def fn(t):
        env1 = env_exp_decay(t, 0.06)
        env2 = env_exp_decay(t, 0.24)
        stamp = mix(sine(90, t), sine(180, t)) * env1
        rise  = sine(360 + 200 * (t / dur), t) * env2 * 0.45
        return clip(stamp + rise)
    return render(fn, dur)

# ── Main ─────────────────────────────────────────────────────────────────────

CUES = [
    # Tier 0 — Mandatory
    ("battle/battle_hit_confirm_01.ogg",          sfx_impact_compact()),
    ("battle/battle_miss_01.ogg",                 sfx_whoosh_miss()),
    ("battle/battle_counter_hit_01.ogg",          sfx_deflect_counter()),
    ("battle/battle_boss_mark_warn_01.ogg",       sfx_seal_stamp()),
    ("battle/battle_boss_command_warn_01.ogg",    sfx_barred_pulse()),
    ("battle/battle_boss_charge_impact_01.ogg",   sfx_thrust_impact()),
    ("battle/battle_state_player_phase_01.ogg",   sfx_broad_pulse_upward()),
    ("battle/battle_state_enemy_phase_01.ogg",    sfx_broad_pulse_downward()),
    ("ui/ui_inventory_open_01.ogg",               sfx_panel_open()),
    ("ui/ui_inventory_close_01.ogg",              sfx_panel_close()),
    ("ui/ui_common_cancel_01.ogg",                sfx_cancel()),
    ("ui/ui_common_confirm_01.ogg",               sfx_confirm()),
    ("ui/ui_panel_tab_shift_01.ogg",              sfx_tab_shift()),
    ("camp/camp_recommend_focus_01.ogg",          sfx_parchment_glint()),
    ("camp/camp_party_select_01.ogg",             sfx_emblem_tick()),
    ("camp/camp_next_battle_confirm_01.ogg",      sfx_confirm_low_pulse()),
    ("camp/camp_party_assign_01.ogg",             sfx_confirm_variant()),
    ("camp/camp_loadout_weapon_cycle_01.ogg",     sfx_metal_slide()),
    ("camp/camp_loadout_armor_cycle_01.ogg",      sfx_cloth_clasp()),
    ("camp/camp_loadout_accessory_cycle_01.ogg",  sfx_charm_ring()),
    # Tier 1 — Reserve
    ("battle/battle_hit_confirm_heavy_01.ogg",    sfx_heavy_impact()),
    ("battle/battle_pain_ally_01.ogg",            sfx_ally_pain()),
    ("battle/battle_pain_enemy_01.ogg",           sfx_enemy_pain()),
    ("battle/battle_action_commit_01.ogg",        sfx_action_commit()),
    ("battle/battle_action_wait_01.ogg",          sfx_wait_action()),
    ("battle/battle_unit_defeat_01.ogg",          sfx_unit_defeat()),
    ("battle/battle_state_round_advance_01.ogg",  sfx_round_advance()),
    ("battle/battle_boss_danger_01.ogg",          sfx_boss_danger()),
    ("battle/battle_result_victory_01.ogg",       sfx_result_victory()),
    ("battle/battle_result_defeat_01.ogg",        sfx_result_defeat()),
    ("ui/ui_common_tap_soft_01.ogg",              sfx_tap_soft()),
    ("ui/ui_common_tap_primary_01.ogg",           sfx_tap_primary()),
    ("ui/ui_common_invalid_01.ogg",               sfx_invalid()),
    ("ui/ui_panel_open_01.ogg",                   sfx_panel_open_generic()),
    ("ui/ui_panel_close_01.ogg",                  sfx_panel_close_generic()),
    ("ui/ui_panel_dismiss_01.ogg",                sfx_panel_dismiss()),
    ("camp/camp_hub_enter_01.ogg",                sfx_camp_enter()),
    ("camp/camp_unlock_notice_01.ogg",            sfx_unlock_notice()),
    ("camp/camp_dialogue_new_01.ogg",             sfx_dialogue_new()),
    ("camp/camp_letter_new_01.ogg",               sfx_letter_new()),
    ("camp/camp_memory_reveal_01.ogg",            sfx_parchment_glint()),
    ("camp/camp_evidence_reveal_01.ogg",          sfx_evidence_reveal()),
]

def main():
    print(f"=== Ashen Bell SFX Generator ({len(CUES)} cues) ===\n")
    ok = 0
    for rel_path, samples in CUES:
        ogg_path = OUT_ROOT / rel_path
        try:
            save(samples, ogg_path)
            ok += 1
        except Exception as e:
            print(f"  ✗ {rel_path}: {e}", file=sys.stderr)
    print(f"\n=== Done: {ok}/{len(CUES)} cues generated ===")

if __name__ == "__main__":
    main()
