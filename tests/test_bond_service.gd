@tool
extends GutTest

## BondService unit tests
## Tests bond level management, support attacks, damage share

const BondService = preload("res://scripts/battle/bond_service.gd")
const UnitActor = preload("res://scripts/battle/unit_actor.gd")
const UnitData = preload("res://scripts/data/unit_data.gd")

var _bond_service: BondService
var _test_root: Node


func before_each():
	_test_root = Node.new()
	_test_root.name = "TestRoot"
	get_tree().root.add_child(_test_root)

	_bond_service = BondService.new()
	_bond_service.name = "BondService"
	_test_root.add_child(_bond_service)


func after_each():
	if is_instance_valid(_test_root):
		_test_root.free()


func _create_unit_data(
	unit_id: StringName,
	display_name: String = "TestUnit",
	faction: String = "ally",
	max_hp: int = 50,
	attack: int = 10,
	defense: int = 5
) -> UnitData:
	var data := UnitData.new()
	data.unit_id = unit_id
	data.display_name = display_name
	data.faction = faction
	data.max_hp = max_hp
	data.attack = attack
	data.defense = defense
	data.movement = 3
	data.attack_range = 1
	return data


func _create_unit_actor(
	unit_data: UnitData,
	grid_pos: Vector2i = Vector2i.ZERO
) -> UnitActor:
	var actor := UnitActor.new()
	actor.name = String(unit_data.unit_id)
	actor.unit_data = unit_data
	actor.current_hp = unit_data.max_hp
	actor.grid_position = grid_pos
	actor.faction = unit_data.faction
	_test_root.add_child(actor)
	return actor


## --- Bond Level Management Tests ---

func test_initial_bond_is_zero():
	"""All companions should start with bond level 0"""
	assert_eq(_bond_service.get_bond(&"ally_serin"), 0, "Initial bond should be 0")
	assert_eq(_bond_service.get_bond(&"ally_bran"), 0, "Initial bond should be 0")


func test_apply_bond_delta_increases_bond():
	"""apply_bond_delta should increase bond level"""
	var entry: Dictionary = _bond_service.apply_bond_delta(&"ally_serin", 2, "shared_battle")

	assert_eq(entry.get("before"), 0, "Before should be 0")
	assert_eq(entry.get("after"), 2, "After should be 2")
	assert_eq(entry.get("delta"), 2, "Delta should be 2")


func test_apply_bond_delta_clamps_at_max():
	"""apply_bond_delta should clamp at MAX_BOND (5)"""
	var entry: Dictionary = _bond_service.apply_bond_delta(&"ally_serin", 10, "max_test")

	assert_eq(entry.get("after"), 5, "Bond should clamp at 5")


func test_apply_bond_delta_negative_delta():
	"""apply_bond_delta with negative delta should decrease bond"""
	_bond_service.apply_bond_delta(&"ally_serin", 3, "increase_first")
	var entry: Dictionary = _bond_service.apply_bond_delta(&"ally_serin", -1, "decrease")

	assert_eq(entry.get("after"), 2, "Bond should decrease to 2")


func test_apply_bond_delta_clamps_at_zero():
	"""apply_bond_delta should not go below 0"""
	var entry: Dictionary = _bond_service.apply_bond_delta(&"ally_serin", -5, "negative_test")

	assert_eq(entry.get("after"), 0, "Bond should clamp at 0")


func test_get_squad_trust_average():
	"""get_squad_trust_average should return correct average"""
	_bond_service.apply_bond_delta(&"ally_serin", 3, "t1")
	_bond_service.apply_bond_delta(&"ally_bran", 2, "t1")
	# 4 others still at 0

	var avg: float = _bond_service.get_squad_trust_average()
	# (3 + 2 + 0 + 0 + 0 + 0) / 6 = 5/6 ≈ 0.833
	assert_true(abs(avg - 0.8333) < 0.01, "Average should be ~0.833, got %f" % avg)


func test_get_name_anchor_eligible_empty_at_start():
	"""get_name_anchor_eligible should return empty array when no bond 5"""
	var eligible: Array = _bond_service.get_name_anchor_eligible()
	assert_eq(eligible.size(), 0, "Should have no eligible at start")


func test_get_name_anchor_eligible_includes_bond_5():
	"""get_name_anchor_eligible should include companions with bond 5"""
	_bond_service.apply_bond_delta(&"ally_serin", 5, "max_bond")
	_bond_service.apply_bond_delta(&"ally_bran", 4, "not_yet_max")

	var eligible: Array = _bond_service.get_name_anchor_eligible()
	assert_eq(eligible.size(), 1, "Should have 1 eligible")
	assert_true(eligible.has(&"ally_serin"), "Serin should be eligible")


func test_reset_restores_all_to_zero():
	"""reset should restore all bonds to 0"""
	_bond_service.apply_bond_delta(&"ally_serin", 3, "test")
	_bond_service.apply_bond_delta(&"ally_bran", 5, "test")

	_bond_service.reset()

	assert_eq(_bond_service.get_bond(&"ally_serin"), 0, "Serin bond should be reset to 0")
	assert_eq(_bond_service.get_bond(&"ally_bran"), 0, "Bran bond should be reset to 0")


## --- Support Attack Tests ---

func test_can_support_attack_requires_bond_3():
	"""can_support_attack requires bond >= 3"""
	var attacker_data := _create_unit_data(&"ally_serin", "Serin", "ally", 50, 10, 5)
	var supporter_data := _create_unit_data(&"ally_bran", "Bran", "ally", 50, 8, 4)

	var attacker := _create_unit_actor(attacker_data, Vector2i(0, 0))
	var supporter := _create_unit_actor(supporter_data, Vector2i(1, 0))

	_bond_service.apply_bond_delta(&"ally_serin", 2, "test")
	_bond_service.apply_bond_delta(&"ally_bran", 3, "test")

	assert_false(_bond_service.can_support_attack(attacker, supporter), "Bond 2 attacker cannot support")


func test_can_support_attack_requires_adjacent():
	"""can_support_attack requires distance <= 1"""
	var attacker_data := _create_unit_data(&"ally_serin", "Serin", "ally", 50, 10, 5)
	var supporter_data := _create_unit_data(&"ally_bran", "Bran", "ally", 50, 8, 4)

	var attacker := _create_unit_actor(attacker_data, Vector2i(0, 0))
	var supporter := _create_unit_actor(supporter_data, Vector2i(3, 0))  # Distance 3

	_bond_service.apply_bond_delta(&"ally_serin", 3, "test")
	_bond_service.apply_bond_delta(&"ally_bran", 3, "test")

	assert_false(_bond_service.can_support_attack(attacker, supporter), "Distance 3 should not support")


func test_compute_bond_attack_bonus_no_allies():
	"""compute_bond_attack_bonus should return 0 with no adjacent allies"""
	var attacker_data := _create_unit_data(&"ally_serin", "Serin", "ally", 50, 10, 5)
	var attacker := _create_unit_actor(attacker_data, Vector2i(0, 0))

	_bond_service.apply_bond_delta(&"ally_serin", 5, "test")

	var bonus: int = _bond_service.compute_bond_attack_bonus(attacker, [])
	assert_eq(bonus, 0, "No allies means no bonus")


func test_compute_bond_attack_bonus_single_adjacent_ally():
	"""compute_bond_attack_bonus: 1 adjacent ally bond 3+ → +1 bonus"""
	var attacker_data := _create_unit_data(&"ally_serin", "Serin", "ally", 50, 10, 5)
	var ally_data := _create_unit_data(&"ally_bran", "Bran", "ally", 50, 8, 4)

	var attacker := _create_unit_actor(attacker_data, Vector2i(0, 0))
	var ally := _create_unit_actor(ally_data, Vector2i(1, 0))

	_bond_service.apply_bond_delta(&"ally_serin", 3, "test")
	_bond_service.apply_bond_delta(&"ally_bran", 3, "test")

	var bonus: int = _bond_service.compute_bond_attack_bonus(attacker, [ally])
	assert_eq(bonus, 1, "Should have +1 bonus from 1 adjacent bonded ally")


func test_compute_bond_attack_bonus_multiple_allies():
	"""compute_bond_attack_bonus: 2 adjacent allies bond 3+ → +2 bonus"""
	var attacker_data := _create_unit_data(&"ally_serin", "Serin", "ally", 50, 10, 5)
	var ally1_data := _create_unit_data(&"ally_bran", "Bran", "ally", 50, 8, 4)
	var ally2_data := _create_unit_data(&"ally_tia", "Tia", "ally", 50, 8, 4)

	var attacker := _create_unit_actor(attacker_data, Vector2i(0, 0))
	var ally1 := _create_unit_actor(ally1_data, Vector2i(1, 0))
	var ally2 := _create_unit_actor(ally2_data, Vector2i(0, 1))

	_bond_service.apply_bond_delta(&"ally_serin", 4, "test")
	_bond_service.apply_bond_delta(&"ally_bran", 3, "test")
	_bond_service.apply_bond_delta(&"ally_tia", 3, "test")

	var bonus: int = _bond_service.compute_bond_attack_bonus(attacker, [ally1, ally2])
	assert_eq(bonus, 2, "Should have +2 bonus from 2 adjacent bonded allies")


func test_compute_bond_attack_bonus_ally_below_bond_3():
	"""compute_bond_attack_bonus ignores allies with bond < 3"""
	var attacker_data := _create_unit_data(&"ally_serin", "Serin", "ally", 50, 10, 5)
	var ally_data := _create_unit_data(&"ally_bran", "Bran", "ally", 50, 8, 4)

	var attacker := _create_unit_actor(attacker_data, Vector2i(0, 0))
	var ally := _create_unit_actor(ally_data, Vector2i(1, 0))

	_bond_service.apply_bond_delta(&"ally_serin", 3, "test")
	_bond_service.apply_bond_delta(&"ally_bran", 2, "test")  # Bond 2, below threshold

	var bonus: int = _bond_service.compute_bond_attack_bonus(attacker, [ally])
	assert_eq(bonus, 0, "Bond 2 ally should not contribute bonus")


func test_resolve_support_attack_bond_3():
	"""resolve_support_attack: Bond 3 triggers with extra_damage = bond * 1"""
	var attacker_data := _create_unit_data(&"ally_serin", "Serin", "ally", 50, 10, 5)
	var ally_data := _create_unit_data(&"ally_bran", "Bran", "ally", 50, 8, 4)
	var enemy_data := _create_unit_data(&"enemy_01", "Enemy1", "enemy", 30, 4, 3)

	var attacker := _create_unit_actor(attacker_data, Vector2i(0, 0))
	var ally := _create_unit_actor(ally_data, Vector2i(1, 0))
	var enemy := _create_unit_actor(enemy_data, Vector2i(2, 0))

	_bond_service.apply_bond_delta(&"ally_serin", 3, "test")
	_bond_service.apply_bond_delta(&"ally_bran", 3, "test")

	var result: Dictionary = _bond_service.resolve_support_attack(attacker, enemy, [ally])

	assert_true(result.get("triggered", false), "Support attack should trigger")
	assert_eq(result.get("extra_damage"), 3, "Bond 3 should give +3 extra damage")
	assert_eq(result.get("bond_level"), 3, "Bond level should be 3")


func test_resolve_support_attack_bond_4():
	"""resolve_support_attack: Bond 4 → extra_damage = 4"""
	var attacker_data := _create_unit_data(&"ally_serin", "Serin", "ally", 50, 10, 5)
	var ally_data := _create_unit_data(&"ally_bran", "Bran", "ally", 50, 8, 4)
	var enemy_data := _create_unit_data(&"enemy_01", "Enemy1", "enemy", 30, 4, 3)

	var attacker := _create_unit_actor(attacker_data, Vector2i(0, 0))
	var ally := _create_unit_actor(ally_data, Vector2i(1, 0))
	var enemy := _create_unit_actor(enemy_data, Vector2i(2, 0))

	_bond_service.apply_bond_delta(&"ally_serin", 4, "test")
	_bond_service.apply_bond_delta(&"ally_bran", 4, "test")

	var result: Dictionary = _bond_service.resolve_support_attack(attacker, enemy, [ally])

	assert_true(result.get("triggered", false), "Support attack should trigger")
	assert_eq(result.get("extra_damage"), 4, "Bond 4 should give +4 extra damage")


func test_resolve_support_attack_bond_5():
	"""resolve_support_attack: Bond 5 → extra_damage = 5"""
	var attacker_data := _create_unit_data(&"ally_serin", "Serin", "ally", 50, 10, 5)
	var ally_data := _create_unit_data(&"ally_bran", "Bran", "ally", 50, 8, 4)
	var enemy_data := _create_unit_data(&"enemy_01", "Enemy1", "enemy", 30, 4, 3)

	var attacker := _create_unit_actor(attacker_data, Vector2i(0, 0))
	var ally := _create_unit_actor(ally_data, Vector2i(1, 0))
	var enemy := _create_unit_actor(enemy_data, Vector2i(2, 0))

	_bond_service.apply_bond_delta(&"ally_serin", 5, "test")
	_bond_service.apply_bond_delta(&"ally_bran", 5, "test")

	var result: Dictionary = _bond_service.resolve_support_attack(attacker, enemy, [ally])

	assert_true(result.get("triggered", false), "Support attack should trigger")
	assert_eq(result.get("extra_damage"), 5, "Bond 5 should give +5 extra damage")


func test_resolve_support_attack_no_adjacent_ally():
	"""resolve_support_attack: no adjacent ally → not triggered"""
	var attacker_data := _create_unit_data(&"ally_serin", "Serin", "ally", 50, 10, 5)
	var ally_data := _create_unit_data(&"ally_bran", "Bran", "ally", 50, 8, 4)
	var enemy_data := _create_unit_data(&"enemy_01", "Enemy1", "enemy", 30, 4, 3)

	var attacker := _create_unit_actor(attacker_data, Vector2i(0, 0))
	var ally := _create_unit_actor(ally_data, Vector2i(5, 0))  # Far away
	var enemy := _create_unit_actor(enemy_data, Vector2i(2, 0))

	_bond_service.apply_bond_delta(&"ally_serin", 3, "test")
	_bond_service.apply_bond_delta(&"ally_bran", 3, "test")

	var result: Dictionary = _bond_service.resolve_support_attack(attacker, enemy, [ally])

	assert_false(result.get("triggered", false), "Should not trigger without adjacent ally")


func test_resolve_support_attack_bond_below_threshold():
	"""resolve_support_attack: bond < 3 → not triggered"""
	var attacker_data := _create_unit_data(&"ally_serin", "Serin", "ally", 50, 10, 5)
	var ally_data := _create_unit_data(&"ally_bran", "Bran", "ally", 50, 8, 4)
	var enemy_data := _create_unit_data(&"enemy_01", "Enemy1", "enemy", 30, 4, 3)

	var attacker := _create_unit_actor(attacker_data, Vector2i(0, 0))
	var ally := _create_unit_actor(ally_data, Vector2i(1, 0))
	var enemy := _create_unit_actor(enemy_data, Vector2i(2, 0))

	_bond_service.apply_bond_delta(&"ally_serin", 2, "test")
	_bond_service.apply_bond_delta(&"ally_bran", 3, "test")

	var result: Dictionary = _bond_service.resolve_support_attack(attacker, enemy, [ally])

	assert_false(result.get("triggered", false), "Should not trigger with bond < 3")


## --- Damage Share Tests ---

func test_resolve_damage_share_bond_5():
	"""resolve_damage_share: Bond 5 distributes damage to adjacent allies"""
	var target_data := _create_unit_data(&"ally_serin", "Serin", "ally", 50, 10, 5)
	var ally_data := _create_unit_data(&"ally_bran", "Bran", "ally", 50, 8, 4)
	var ally2_data := _create_unit_data(&"ally_tia", "Tia", "ally", 50, 8, 4)

	var target := _create_unit_actor(target_data, Vector2i(0, 0))
	var ally1 := _create_unit_actor(ally_data, Vector2i(1, 0))
	var ally2 := _create_unit_actor(ally2_data, Vector2i(0, 1))

	_bond_service.apply_bond_delta(&"ally_serin", 5, "test")
	_bond_service.apply_bond_delta(&"ally_bran", 5, "test")
	_bond_service.apply_bond_delta(&"ally_tia", 5, "test")

	var result: Dictionary = _bond_service.resolve_damage_share(target, 9, [ally1, ally2])

	assert_false(result.get("target_takes_all", true), "Should distribute damage")
	var target_damage: int = result.get("target_damage", 0)
	var share_per_ally: int = result.get("share_per_ally", 0)
	# 9 damage / (2 allies + 1 target) = 3 each
	# Target takes: 9 - (3 * 2) = 3
	assert_eq(share_per_ally, 3, "Each sharer should take 3 damage")
	assert_eq(target_damage, 3, "Target should take 3 damage")


func test_resolve_damage_share_bond_4_no_share():
	"""resolve_damage_share: Bond 4 does NOT share (requires bond 5)"""
	var target_data := _create_unit_data(&"ally_serin", "Serin", "ally", 50, 10, 5)
	var ally_data := _create_unit_data(&"ally_bran", "Bran", "ally", 50, 8, 4)

	var target := _create_unit_actor(target_data, Vector2i(0, 0))
	var ally := _create_unit_actor(ally_data, Vector2i(1, 0))

	_bond_service.apply_bond_delta(&"ally_serin", 4, "test")
	_bond_service.apply_bond_delta(&"ally_bran", 5, "test")

	var result: Dictionary = _bond_service.resolve_damage_share(target, 9, [ally])

	assert_true(result.get("target_takes_all", false), "Target should take all damage at bond 4")


func test_resolve_damage_share_no_adjacent_bond_5():
	"""resolve_damage_share: No adjacent bond 5 allies → target takes all"""
	var target_data := _create_unit_data(&"ally_serin", "Serin", "ally", 50, 10, 5)
	var ally_data := _create_unit_data(&"ally_bran", "Bran", "ally", 50, 8, 4)

	var target := _create_unit_actor(target_data, Vector2i(0, 0))
	var ally := _create_unit_actor(ally_data, Vector2i(5, 0))  # Far away

	_bond_service.apply_bond_delta(&"ally_serin", 5, "test")
	_bond_service.apply_bond_delta(&"ally_bran", 5, "test")

	var result: Dictionary = _bond_service.resolve_damage_share(target, 9, [ally])

	assert_true(result.get("target_takes_all", false), "Target should take all without adjacent bond 5")


func test_resolve_damage_share_minimum_share_amount():
	"""resolve_damage_share: share_amount minimum is 1"""
	var target_data := _create_unit_data(&"ally_serin", "Serin", "ally", 50, 10, 5)
	var ally_data := _create_unit_data(&"ally_bran", "Bran", "ally", 50, 8, 4)

	var target := _create_unit_actor(target_data, Vector2i(0, 0))
	var ally := _create_unit_actor(ally_data, Vector2i(1, 0))

	_bond_service.apply_bond_delta(&"ally_serin", 5, "test")
	_bond_service.apply_bond_delta(&"ally_bran", 5, "test")

	var result: Dictionary = _bond_service.resolve_damage_share(target, 1, [ally])

	var share_per_ally: int = result.get("share_per_ally", 0)
	assert_eq(share_per_ally, 1, "Minimum share should be 1")


func test_get_snapshot_returns_correct_data():
	"""get_snapshot should return bonds and trust average"""
	_bond_service.apply_bond_delta(&"ally_serin", 5, "test")
	_bond_service.apply_bond_delta(&"ally_bran", 3, "test")

	var snapshot: Dictionary = _bond_service.get_snapshot()

	assert_true(snapshot.has("bonds"), "Snapshot should have bonds")
	assert_true(snapshot.has("squad_trust_average"), "Snapshot should have trust average")
	assert_true(snapshot.has("name_anchor_eligible"), "Snapshot should have name_anchor_eligible")
	assert_eq(snapshot.get("name_anchor_eligible").size(), 1, "Should have 1 name anchor eligible")
