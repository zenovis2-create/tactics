class_name TacticalCommentary
extends Node

# Tactical Commentary — Dictionary-based rule engine for battle narration
# Generates text descriptions of tactical events during observation

signal commentary_generated(text: String, event_type: String)

const EVENT_KILL := "kill"
const EVENT_HEAL := "heal"
const EVENT_MOVE := "move"
const EVENT_CRITICAL := "critical"
const EVENT_DEBUFF := "debuff"
const EVENT_BUFF := "buff"
const EVENT_SPAWN := "spawn"
const EVENT_TURN := "turn"
const EVENT_GUARD := "guard"

var _commentary_enabled: bool = true
var _history: Array[String] = []
var _max_history: int = 50

var _rules: Array = []

func _ready() -> void:
	_build_rules()

func _build_rules() -> void:
	_rules = []

	# Kill events
	var kill_rule := {
		"event_pattern": EVENT_KILL,
		"keywords": ["defeated", "killed", "eliminated"],
		"templates": [
			"%s has fallen to %s!",
			"%s's unit was defeated by %s.",
			"A decisive blow from %s ends %s.",
			"%s crumbles under %s's assault."
		],
		"priority": 10
	}
	_rules.append(kill_rule)

	# Critical hits
	var crit_rule := {
		"event_pattern": EVENT_CRITICAL,
		"keywords": ["critical", "crushing", "devastating"],
		"templates": [
			"CRITICAL HIT! %s lands a crushing blow on %s!",
			"A devastating strike from %s!",
			"%s's attack overwhelms %s's defenses!"
		],
		"priority": 9
	}
	_rules.append(crit_rule)

	# Healing
	var heal_rule := {
		"event_pattern": EVENT_HEAL,
		"keywords": ["healed", "restored", "recovered"],
		"templates": [
			"%s tends to %s's wounds.",
			"%s restores %s's strength!",
			"A moment of respite — %s heals %s."
		],
		"priority": 5
	}
	_rules.append(heal_rule)

	# Movement
	var move_rule := {
		"event_pattern": EVENT_MOVE,
		"keywords": ["moved", "advanced", "retreated"],
		"templates": [
			"%s repositions to %s.",
			"%s makes a tactical withdrawal to %s.",
			"%s advances toward %s."
		],
		"priority": 3
	}
	_rules.append(move_rule)

	# Guard
	var guard_rule := {
		"event_pattern": EVENT_GUARD,
		"keywords": ["guarding", "protecting", "defended"],
		"templates": [
			"%s takes a defensive stance!",
			"%s braces for impact!",
			"%s guards the flank."
		],
		"priority": 4
	}
	_rules.append(guard_rule)

	# Buff applied
	var buff_rule := {
		"event_pattern": EVENT_BUFF,
		"keywords": ["buffed", "strengthened", "empowered"],
		"templates": [
			"%s gains increased power!",
			"A morale boost for %s!",
			"%s is emboldened by the surrounding forces."
		],
		"priority": 4
	}
	_rules.append(buff_rule)

	# Debuff applied
	var debuff_rule := {
		"event_pattern": EVENT_DEBUFF,
		"keywords": ["weakened", "debuffed", "slowed"],
		"templates": [
			"%s is weakened by %s's action!",
			"A strategic disadvantage for %s.",
			"%s's effectiveness is diminished."
		],
		"priority": 4
	}
	_rules.append(debuff_rule)

	# Unit spawn
	var spawn_rule := {
		"event_pattern": EVENT_SPAWN,
		"keywords": ["spawned", "arrived", "deployed"],
		"templates": [
			"%s enters the battlefield!",
			"Reinforcements — %s has arrived!",
			"A new combatant joins: %s!"
		],
		"priority": 7
	}
	_rules.append(spawn_rule)

	# Turn change
	var turn_rule := {
		"event_pattern": EVENT_TURN,
		"keywords": ["turn", "round"],
		"templates": [
			"Turn %d begins.",
			"Round %d — the situation evolves.",
			"A new phase of combat: Turn %d."
		],
		"priority": 1
	}
	_rules.append(turn_rule)

	# Sort rules by priority (highest first)
	_rules.sort_custom(func(a, b) -> bool:
		return a["priority"] > b["priority"]
	)

func generate_commentary(event_type: String, attacker: String = "", defender: String = "", location: String = "", extra: Dictionary = {}) -> String:
	if not _commentary_enabled:
		return ""
	var rule = _find_rule(event_type)
	if rule == null:
		return ""
	var templates: Array = rule["templates"]
	var template: String = templates[randi() % templates.size()]
	var name_a := _pick_name(attacker, defender, extra)
	var name_b := _pick_name(defender, attacker, extra)
	var loc := _pick_location(location, extra)
	var text := _format_template(template, name_a, name_b, loc)
	_history.append(text)
	if _history.size() > _max_history:
		_history.pop_front()
	commentary_generated.emit(text, event_type)
	return text

func _format_template(template: String, a: String, b: String, loc: String) -> String:
	# Count %s placeholders and pass only needed args
	var count := 0
	for i in range(template.length()):
		if template[i] == '%' and i + 1 < template.length():
			var next := template[i + 1]
			if next == 's' or next == 'd':
				count += 1
	if count == 1:
		return template % [a]
	elif count == 2:
		return template % [a, b]
	elif count == 3:
		return template % [a, b, loc]
	else:
		return template

func _find_rule(event_type: String) -> Variant:
	for rule in _rules:
		if rule["event_pattern"] == event_type:
			return rule
	return null

func _pick_name(primary: String, secondary: String, extra: Dictionary) -> String:
	if not primary.is_empty():
		return primary
	if not secondary.is_empty():
		return secondary
	if extra.has("ally_name"):
		return str(extra.get("ally_name", "Unknown"))
	return "Unknown"

func _pick_location(location: String, extra: Dictionary) -> String:
	if not location.is_empty():
		return location
	if extra.has("terrain"):
		return str(extra.get("terrain", "the field"))
	return "the battlefield"

func set_commentary_enabled(enabled: bool) -> void:
	_commentary_enabled = enabled

func is_commentary_enabled() -> bool:
	return _commentary_enabled

func get_commentary_history() -> Array[String]:
	return _history.duplicate()

func clear_history() -> void:
	_history.clear()

func generate_turn_commentary(turn_number: int, current_faction: String) -> String:
	var faction_name := current_faction if not current_faction.is_empty() else "Unknown"
	var templates: Array[String] = [
		"Turn %d — %s's forces engage.",
		"Round %d: %s takes the initiative.",
		"Turn %d — the battlefield shifts as %s advances."
	]
	var template: String = templates[randi() % templates.size()]
	return template % [turn_number, faction_name]
