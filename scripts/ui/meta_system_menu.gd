class_name MetaSystemMenu
extends Control

const ForgeService = preload("res://scripts/battle/forge_service.gd")
const EnchantService = preload("res://scripts/battle/enchant_service.gd")
const ReforgeService = preload("res://scripts/battle/reforge_service.gd")
const SigilService = preload("res://scripts/battle/sigil_service.gd")

signal panel_closed

var game_controller = null
var current_unit = null
var selected_slot = "weapon"

@onready var panel = $Panel
@onready var result_label = $Panel/Margin/Content/ResultLabel if has_node("Panel/Margin/Content/ResultLabel") else null
@onready var close_button = $Panel/Margin/Content/CloseButton if has_node("Panel/Margin/Content/CloseButton") else null

func _ready():
	if close_button:
		close_button.pressed.connect(_on_close_pressed)
	
	var tab_container = $Panel/Margin/Content/TabContainer if has_node("Panel/Margin/Content/TabContainer") else null
	if tab_container:
		var forge_tab = tab_container.get_node("Forge") if tab_container.has_node("Forge") else null
		var enchant_tab = tab_container.get_node("EnchantTab") if tab_container.has_node("EnchantTab") else null
		var reforge_tab = tab_container.get_node("ReforgeTab") if tab_container.has_node("ReforgeTab") else null
		var sigil_tab = tab_container.get_node("SigilTab") if tab_container.has_node("SigilTab") else null
		
		if forge_tab and forge_tab.has_node("UpgradeBtn"):
			forge_tab.get_node("UpgradeBtn").pressed.connect(_on_forge_pressed)
		if enchant_tab and enchant_tab.has_node("EnchantBtn"):
			enchant_tab.get_node("EnchantBtn").pressed.connect(_on_enchant_pressed)
		if reforge_tab and reforge_tab.has_node("ReforgeBtn"):
			reforge_tab.get_node("ReforgeBtn").pressed.connect(_on_reforge_pressed)
		if sigil_tab and sigil_tab.has_node("SigilBtn"):
			sigil_tab.get_node("SigilBtn").pressed.connect(_on_sigil_pressed)

func open(ctrl, unit):
	game_controller = ctrl
	current_unit = unit
	_clear_result()
	visible = true

func close():
	visible = false
	panel_closed.emit()

func _on_close_pressed():
	close()

func _clear_result():
	if result_label:
		result_label.text = ""

func _show_result(msg: String):
	if result_label:
		result_label.text = msg

func _on_forge_pressed():
	if current_unit == null:
		_show_result("장비가 선택되지 않음")
		return
	
	var equip = current_unit.equipment.get(selected_slot)
	if equip == null:
		_show_result("해당 슬롯에 장비가 없음")
		return
	
	var tier = equip.tier if "tier" in equip else 0
	if tier >= 3:
		_show_result("이미 최상급입니다")
		return
	
	var next_tier = tier + 1
	var cost = ForgeService.upgrade_cost(0, tier, next_tier)
	var mats = ForgeService.material_required(next_tier)
	_show_result("강화 비용: %d gold, 재료: %d개" % [cost, mats])
	
	if ForgeService.upgrade_equipment(current_unit, selected_slot, next_tier):
		_show_result("강화 성공! (%s → %s)" % [
			ForgeService.tier_names.get(tier, "?"),
			ForgeService.tier_names.get(next_tier, "?")
		])
	else:
		_show_result("강화 실패 — 재화나 재료 부족")

func _on_enchant_pressed():
	if current_unit == null:
		_show_result("장비가 선택되지 않음")
		return
	
	var equip = current_unit.equipment.get(selected_slot)
	if equip == null:
		_show_result("해당 슬롯에 장비가 없음")
		return
	
	var tier = equip.tier if "tier" in equip else 0
	if tier < 1:
		_show_result("강화 이상의 장비만 인챈트 가능")
		return
	
	var enchant_types = EnchantService.enchant_types.keys()
	if enchant_types.is_empty():
		_show_result("인챈트 종류가 없음")
		return
	
	# use first type as default
	var ench_type = enchant_types[0]
	var cost = EnchantService.enchant_cost(0, tier)
	_show_result("인챈트 비용: %d gold (%s)" % [cost, EnchantService.enchant_types.get(ench_type, ench_type)])
	
	if EnchantService.enchant_equipment(equip, ench_type):
		_show_result("인챈트 성공! (%s)" % EnchantService.enchant_types.get(ench_type, ench_type))
	else:
		_show_result("인챈트 실패 — 비용 부족 또는 강화 Tier 3 30%% 실패")

func _on_reforge_pressed():
	if current_unit == null:
		_show_result("장비가 선택되지 않음")
		return
	
	var equip = current_unit.equipment.get(selected_slot)
	if equip == null:
		_show_result("해당 슬롯에 장비가 없음")
		return
	
	var cost = ReforgeService.reforge_cost(0)
	_show_result("재련 비용: %d gold" % cost)
	
	if ReforgeService.reforge_equipment(equip):
		var new_tier = equip.tier if "tier" in equip else 0
		_show_result("재련 성공! Tier %d → %d" % [new_tier - 1, new_tier])
	else:
		_show_result("재련 실패 — 골드 부족")

func _on_sigil_pressed():
	if current_unit == null:
		_show_result("장비가 선택되지 않음")
		return
	
	var equip = current_unit.equipment.get(selected_slot)
	if equip == null:
		_show_result("해당 슬롯에 장비가 없음")
		return
	
	var tier = equip.tier if "tier" in equip else 0
	if tier < 1:
		_show_result("강화 이상의 장비만 인장 가능")
		return
	
	var sigil_types = SigilService.sigil_types.keys()
	if sigil_types.is_empty():
		_show_result("인장 종류가 없음")
		return
	
	var sigil_id = sigil_types[0]
	var cost = SigilService.sigil_cost_by_tier(tier)
	_show_result("인장 비용: %d gold (%s)" % [cost, SigilService.sigil_types.get(sigil_id, sigil_id)])
	
	if SigilService.apply_sigil(equip, sigil_id):
		_show_result("인장 성공! (%s)" % SigilService.sigil_types.get(sigil_id, sigil_id))
	else:
		_show_result("인장 실패 — 골드 부족")
