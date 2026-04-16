extends SceneTree

## Sprint 4-B: Skill unlock condition runner
## Verifies:
## 1. SkillData exposes unlock_condition Dictionary field
## 2. SkillData.is_unlocked() checks progression thresholds
## 3. Empty unlock_condition means always unlocked
## 4. trust_min requires Trust >= threshold
## 5. burden_max requires Burden <= threshold
## 6. Combined trust/burden uses AND logic
## 7. fragment requires recovered fragment
## 8. Mixed trust/burden/fragment uses AND logic
## 9. get_unlock_description() returns Korean text
## 10. ProgressionService filters unlockable and locked skills

const SkillData = preload("res://scripts/data/skill_data.gd")
const ProgressionData = preload("res://scripts/data/progression_data.gd")
const ProgressionService = preload("res://scripts/battle/progression_service.gd")

var _failed: bool = false

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var progression: ProgressionData = ProgressionData.new()
    progression.trust = 5
    progression.burden = 3
    progression.recovered_fragments[&"ch05_fragment"] = true

    if not _assert_unlock_condition_field(): return
    if not _assert_is_unlocked_method(progression): return
    if not _assert_empty_condition_unlocks(progression): return
    if not _assert_trust_min_condition(): return
    if not _assert_burden_max_condition(): return
    if not _assert_combined_trust_burden_condition(): return
    if not _assert_fragment_condition(): return
    if not _assert_combined_all_condition(): return
    if not _assert_unlock_description(): return
    if not _assert_progression_service_filtering(): return

    print("[PASS] s4b_skill_unlock_runner: all assertions passed.")
    quit(0)

func _assert_unlock_condition_field() -> bool:
    var skill: SkillData = SkillData.new()
    var value = skill.get("unlock_condition")
    if not value is Dictionary:
        return _fail("SkillData.unlock_condition must be a Dictionary")
    if not value.is_empty():
        return _fail("SkillData.unlock_condition should default to an empty Dictionary")
    return true

func _assert_is_unlocked_method(progression: ProgressionData) -> bool:
    var skill: SkillData = SkillData.new()
    if not skill.has_method("is_unlocked"):
        return _fail("SkillData must implement is_unlocked(progression_data)")
    var result = skill.call("is_unlocked", progression)
    if not result is bool:
        return _fail("SkillData.is_unlocked() must return bool")
    return true

func _assert_empty_condition_unlocks(progression: ProgressionData) -> bool:
    var skill := _make_skill({})
    if not skill.is_unlocked(progression):
        return _fail("Empty unlock_condition should always unlock skill")
    return true

func _assert_trust_min_condition() -> bool:
    var skill := _make_skill({"trust_min": 5})
    var met := ProgressionData.new()
    met.trust = 5
    if not skill.is_unlocked(met):
        return _fail("trust_min should unlock when trust meets threshold")
    var unmet := ProgressionData.new()
    unmet.trust = 4
    if skill.is_unlocked(unmet):
        return _fail("trust_min should stay locked when trust is below threshold")
    return true

func _assert_burden_max_condition() -> bool:
    var skill := _make_skill({"burden_max": 3})
    var met := ProgressionData.new()
    met.burden = 3
    if not skill.is_unlocked(met):
        return _fail("burden_max should unlock when burden is within limit")
    var unmet := ProgressionData.new()
    unmet.burden = 4
    if skill.is_unlocked(unmet):
        return _fail("burden_max should stay locked when burden exceeds limit")
    return true

func _assert_combined_trust_burden_condition() -> bool:
    var skill := _make_skill({"trust_min": 5, "burden_max": 6})
    var met := ProgressionData.new()
    met.trust = 5
    met.burden = 6
    if not skill.is_unlocked(met):
        return _fail("trust_min + burden_max should unlock when both are satisfied")
    var bad_trust := ProgressionData.new()
    bad_trust.trust = 4
    bad_trust.burden = 6
    if skill.is_unlocked(bad_trust):
        return _fail("Combined trust/burden condition should fail when trust is too low")
    var bad_burden := ProgressionData.new()
    bad_burden.trust = 5
    bad_burden.burden = 7
    if skill.is_unlocked(bad_burden):
        return _fail("Combined trust/burden condition should fail when burden is too high")
    return true

func _assert_fragment_condition() -> bool:
    var skill := _make_skill({"fragment": "ch03_fragment"})
    var met := ProgressionData.new()
    met.recovered_fragments[&"ch03_fragment"] = true
    if not skill.is_unlocked(met):
        return _fail("fragment condition should unlock when fragment is recovered")
    var unmet := ProgressionData.new()
    if skill.is_unlocked(unmet):
        return _fail("fragment condition should stay locked when fragment is missing")
    return true

func _assert_combined_all_condition() -> bool:
    var skill := _make_skill({
        "trust_min": 4,
        "burden_max": 7,
        "fragment": "ch05_fragment"
    })
    var met := ProgressionData.new()
    met.trust = 4
    met.burden = 7
    met.recovered_fragments[&"ch05_fragment"] = true
    if not skill.is_unlocked(met):
        return _fail("All unlock conditions should pass only when every condition is satisfied")
    var missing_fragment := ProgressionData.new()
    missing_fragment.trust = 4
    missing_fragment.burden = 7
    if skill.is_unlocked(missing_fragment):
        return _fail("All unlock conditions should fail when fragment is missing")
    return true

func _assert_unlock_description() -> bool:
    var trust_burden := _make_skill({"trust_min": 5, "burden_max": 3})
    if trust_burden.get_unlock_description() != "신뢰 5이상 / 부담 3이하":
        return _fail("Trust/Burden description should be '신뢰 5이상 / 부담 3이하'")

    var all_conditions := _make_skill({
        "trust_min": 4,
        "burden_max": 7,
        "fragment": "ch05_fragment"
    })
    if all_conditions.get_unlock_description() != "신뢰 4이상 / 부담 7이하 / 기억 ch05_fragment":
        return _fail("Combined description should list trust, burden, and fragment in Korean")

    var always := _make_skill({})
    if always.get_unlock_description() != "":
        return _fail("Empty unlock condition description should be an empty string")
    return true

func _assert_progression_service_filtering() -> bool:
    var svc: ProgressionService = ProgressionService.new()
    root.add_child(svc)
    var data := ProgressionData.new()
    data.trust = 5
    data.burden = 3
    data.recovered_fragments[&"ch03_fragment"] = true
    svc.load_data(data)

    var always := _make_skill({})
    always.skill_id = &"always"
    var trust_locked := _make_skill({"trust_min": 6})
    trust_locked.skill_id = &"trust_locked"
    var burden_open := _make_skill({"burden_max": 3})
    burden_open.skill_id = &"burden_open"
    var fragment_open := _make_skill({"fragment": "ch03_fragment"})
    fragment_open.skill_id = &"fragment_open"

    var all_skills: Array = [always, trust_locked, burden_open, fragment_open]
    var unlockable: Array = svc.get_unlockable_skills(all_skills)
    var locked: Array = svc.get_locked_skills(all_skills)

    if unlockable.size() != 3:
        svc.queue_free()
        return _fail("get_unlockable_skills() should return 3 matching skills, got %d" % unlockable.size())
    if not unlockable.has(always) or not unlockable.has(burden_open) or not unlockable.has(fragment_open):
        svc.queue_free()
        return _fail("get_unlockable_skills() should include only matching skills")
    if locked.size() != 1 or not locked.has(trust_locked):
        svc.queue_free()
        return _fail("get_locked_skills() should include only non-matching skills")
    svc.queue_free()
    return true

func _make_skill(condition: Dictionary) -> SkillData:
    var skill: SkillData = SkillData.new()
    skill.unlock_condition = condition.duplicate(true)
    return skill

func _fail(msg: String) -> bool:
    print("[FAIL] ", msg)
    _failed = true
    quit(1)
    return false
