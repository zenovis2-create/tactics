class_name RewardService
extends Node

## M5: Reward integrity — anti-snowball and policy validation.
## SYS-017, SYS-018, SYS-019, SYS-020

## Reward categories.
const CAT_COUNTER_TOOL := &"counter_tool"   # Items that counter chapter gimmicks
const CAT_STAT_BOOST := &"stat_boost"       # Pure stat upgrades
const CAT_SKILL_UNLOCK := &"skill_unlock"   # New skill access
const CAT_CONSUMABLE := &"consumable"       # One-use items
const CAT_STORY := &"story"                 # Narrative unlocks (no stat effect)

## Minimum ratio of counter-tool rewards in any batch (anti-snowball gate).
const MIN_COUNTER_TOOL_RATIO := 0.25

## Maximum stat bonus any single reward may grant (hard cap).
const MAX_SINGLE_STAT_BONUS := 5

## Per-stage seed cache (stage_id -> attempt_count).
var _attempt_counts: Dictionary = {}
var _log: Array[Dictionary] = []

# --- Public API ---

## Generate a deterministic drop seed for a given stage and attempt.
## Same stage_id + attempt always produces the same seed — no reroll exploit.
func generate_drop_seed(stage_id: StringName, attempt: int) -> int:
	var raw := "%s::%d" % [String(stage_id), attempt]
	return raw.hash()

## Increment attempt counter for a stage (call on stage entry, not on reload).
func record_stage_entry(stage_id: StringName) -> int:
	var count: int = _attempt_counts.get(stage_id, 0) + 1
	_attempt_counts[stage_id] = count
	return count

## Get current attempt count for a stage.
func get_attempt_count(stage_id: StringName) -> int:
	return _attempt_counts.get(stage_id, 0)

## Validate a reward batch against the policy.
## reward_batch: Array of Dictionaries with keys: id, category, stat_bonus (optional)
## Returns: { "valid": bool, "violations": Array[String], "counter_tool_ratio": float }
func validate_reward_policy(reward_batch: Array) -> Dictionary:
	var violations: Array = []

	if reward_batch.is_empty():
		return {"valid": true, "violations": [], "counter_tool_ratio": 0.0}

	# Check individual stat caps.
	for reward in reward_batch:
		var bonus: int = int(reward.get("stat_bonus", 0))
		if bonus > MAX_SINGLE_STAT_BONUS:
			violations.append("reward '%s' exceeds max stat bonus: %d > %d" % [
				str(reward.get("id", "?")), bonus, MAX_SINGLE_STAT_BONUS
			])

	# Check counter-tool ratio.
	var counter_count := 0
	for reward in reward_batch:
		if reward.get("category") == CAT_COUNTER_TOOL:
			counter_count += 1
	var ratio: float = float(counter_count) / float(reward_batch.size())

	if ratio < MIN_COUNTER_TOOL_RATIO and reward_batch.size() >= 2:
		violations.append("counter-tool ratio too low: %.2f < %.2f (counter_tools=%d, total=%d)" % [
			ratio, MIN_COUNTER_TOOL_RATIO, counter_count, reward_batch.size()
		])

	var valid := violations.is_empty()
	var entry := {
		"event": "reward_policy_checked",
		"valid": valid,
		"violations": violations.duplicate(),
		"counter_tool_ratio": ratio,
		"batch_size": reward_batch.size()
	}
	_log.append(entry)

	if not valid:
		for v in violations:
			print("[RewardService] POLICY VIOLATION: ", v)

	return {"valid": valid, "violations": violations, "counter_tool_ratio": ratio}

## Apply the drop seed to a reward pool and pick items deterministically.
## pool: Array of reward Dictionaries. Returns a subset selected by seed.
func pick_rewards(pool: Array, seed: int, count: int) -> Array:
	if pool.is_empty() or count <= 0:
		return []

	# Use the seed to create a reproducible shuffle.
	var rng := RandomNumberGenerator.new()
	rng.seed = seed

	var indices := range(pool.size())
	# Fisher-Yates with seeded rng.
	for i in range(indices.size() - 1, 0, -1):
		var j: int = rng.randi_range(0, i)
		var tmp: int = indices[i]
		indices[i] = indices[j]
		indices[j] = tmp

	var result: Array = []
	for i in range(mini(count, indices.size())):
		result.append(pool[indices[i]])
	return result

## Safety valve: if player is underpowered (avg_unit_level < threshold), inject a
## counter-tool reward regardless of normal drop logic.
func apply_underpowered_safety(reward_batch: Array, avg_unit_level: float, threshold: float, fallback_reward: Dictionary) -> Array:
	if avg_unit_level < threshold:
		var has_counter_tool := false
		for r in reward_batch:
			if r.get("category") == CAT_COUNTER_TOOL:
				has_counter_tool = true
				break
		if not has_counter_tool:
			var patched := reward_batch.duplicate()
			patched.append(fallback_reward)
			print("[RewardService] Safety valve triggered: injected counter_tool for underpowered squad.")
			return patched
	return reward_batch

func get_event_log() -> Array[Dictionary]:
	return _log.duplicate()
