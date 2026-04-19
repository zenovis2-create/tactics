class_name GuildSystem
extends Node

# Guild System — guild creation, join, leave, ranking
# Persists guilds + members to user://guild_registry.dat

signal guild_created(guild_id: String)
signal guild_member_joined(guild_id: String, member_id: String)
signal guild_member_left(guild_id: String, member_id: String)

const SAVE_PATH := "user://guild_registry.dat"

const MAX_GUILD_NAME := 24
const MAX_MEMBER_NAME := 16
const MAX_BANNER_SYMBOLS := 5

const BANNER_SYMBOLS: Array = ["sword", "shield", "crown", "wolf", "phoenix"]

const MEMBER_RANK_TROOPERS := 1
const MEMBER_RANK_VETERANS := 2
const MEMBER_RANK_COMMANDERS := 3

var guilds: Array = []
var _current_player_guild_id: String = ""
var _current_player_member_id: String = ""

class GuildMember:
	var member_id: String = ""
	var display_name: String = ""
	var battle_grade: float = 1.0
	var joined_date: String = ""
	var rank: int = MEMBER_RANK_TROOPERS
	var is_leader: bool = false

class Guild:
	var guild_id: String = ""
	var name: String = ""
	var description: String = ""
	var leader_id: String = ""
	var banner_symbol: String = "sword"
	var founded_date: String = ""
	var member_count: int = 0
	var members: Array = []  # Array[GuildMember]

	func get_average_grade() -> float:
		if members.is_empty():
			return 1.0
		var total: float = 0.0
		for m: GuildMember in members:
			total += m.battle_grade
		return total / float(members.size())

	func get_ranking_score() -> float:
		# Ranking = average grade * log(members + 1) * 10
		return get_average_grade() * log(members.size() + 1) * 10.0

	func has_member(member_id: String) -> bool:
		for m: GuildMember in members:
			if m.member_id == member_id:
				return true
		return false

	func get_member(member_id: String) -> GuildMember:
		for m: GuildMember in members:
			if m.member_id == member_id:
				return m
		return null

func _ready() -> void:
	_load()

func _load() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
		if f != null:
			var data: Dictionary = f.get_var()
			guilds = _dict_to_guilds(data.get("guilds", []))
			_current_player_guild_id = data.get("current_player_guild_id", "")
			_current_player_member_id = data.get("current_player_member_id", "")

func _save() -> void:
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f != null:
		f.store_var({
			"guilds": _guilds_to_dict(guilds),
			"current_player_guild_id": _current_player_guild_id,
			"current_player_member_id": _current_player_member_id
		})

func _dict_to_guilds(data: Array) -> Array:
	var result: Array = []
	for gd: Dictionary in data:
		var guild := Guild.new()
		guild.guild_id = gd.get("guild_id", "")
		guild.name = gd.get("name", "")
		guild.description = gd.get("description", "")
		guild.leader_id = gd.get("leader_id", "")
		guild.banner_symbol = gd.get("banner_symbol", "sword")
		guild.founded_date = gd.get("founded_date", "")
		guild.member_count = gd.get("member_count", 0)
		for md: Dictionary in gd.get("members", []):
			var member := GuildMember.new()
			member.member_id = md.get("member_id", "")
			member.display_name = md.get("display_name", "")
			member.battle_grade = md.get("battle_grade", 1.0)
			member.joined_date = md.get("joined_date", "")
			member.rank = md.get("rank", MEMBER_RANK_TROOPERS)
			member.is_leader = md.get("is_leader", false)
			guild.members.append(member)
		result.append(guild)
	return result

func _guilds_to_dict(arr: Array) -> Array:
	var result: Array = []
	for guild: Guild in arr:
		var members_data: Array = []
		for member: GuildMember in guild.members:
			members_data.append({
				"member_id": member.member_id,
				"display_name": member.display_name,
				"battle_grade": member.battle_grade,
				"joined_date": member.joined_date,
				"rank": member.rank,
				"is_leader": member.is_leader
			})
		result.append({
			"guild_id": guild.guild_id,
			"name": guild.name,
			"description": guild.description,
			"leader_id": guild.leader_id,
			"banner_symbol": guild.banner_symbol,
			"founded_date": guild.founded_date,
			"member_count": guild.members.size(),
			"members": members_data
		})
	return result

func create_guild(name: String, leader_name: String, description: String = "", banner_symbol: String = "sword") -> Guild:
	var guild := Guild.new()
	guild.guild_id = "guild_%d" % Time.get_unix_time_from_system()
	guild.name = name.strip_edges()
	guild.description = description.strip_edges()
	guild.leader_id = guild.guild_id + "_leader"
	guild.banner_symbol = banner_symbol if BANNER_SYMBOLS.has(banner_symbol) else "sword"
	guild.founded_date = Time.get_datetime_string_from_system()

	var leader := GuildMember.new()
	leader.member_id = guild.leader_id
	leader.display_name = leader_name.strip_edges()
	leader.joined_date = guild.founded_date
	leader.rank = MEMBER_RANK_COMMANDERS
	leader.is_leader = true
	leader.battle_grade = 1.0
	guild.members.append(leader)

	_current_player_guild_id = guild.guild_id
	_current_player_member_id = guild.leader_id
	_current_player_guild_id = guild.guild_id
	guilds.append(guild)
	_save()
	guild_created.emit(guild.guild_id)
	return guild

func join_guild(guild_id: String, player_name: String, battle_grade: float = 1.0) -> bool:
	var guild: Guild = get_guild(guild_id)
	if guild == null:
		return false
	if _current_player_guild_id != "":
		return false  # Already in a guild
	var member := GuildMember.new()
	member.member_id = "member_%d" % Time.get_unix_time_from_system()
	member.display_name = player_name.strip_edges()
	member.battle_grade = battle_grade
	member.joined_date = Time.get_datetime_string_from_system()
	member.rank = MEMBER_RANK_TROOPERS
	member.is_leader = false
	guild.members.append(member)
	_current_player_guild_id = guild_id
	_current_player_member_id = member.member_id
	_save()
	guild_member_joined.emit(guild_id, member.member_id)
	return true

func leave_guild() -> bool:
	if _current_player_guild_id == "":
		return false
	var guild: Guild = get_guild(_current_player_guild_id)
	if guild == null:
		_current_player_guild_id = ""
		_current_player_member_id = ""
		return false
	var member_id := _current_player_member_id
	guild.members.erase(guild.get_member(member_id))
	_current_player_guild_id = ""
	_current_player_member_id = ""
	_save()
	guild_member_left.emit(guild.guild_id, member_id)
	return true

func get_guild(guild_id: String) -> Guild:
	for g: Guild in guilds:
		if g.guild_id == guild_id:
			return g
	return null

func get_current_guild() -> Guild:
	if _current_player_guild_id == "":
		return null
	return get_guild(_current_player_guild_id)

func is_in_guild() -> bool:
	return _current_player_guild_id != ""

func get_current_member() -> GuildMember:
	if _current_player_guild_id == "" or _current_player_member_id == "":
		return null
	var guild: Guild = get_current_guild()
	if guild == null:
		return null
	return guild.get_member(_current_player_member_id)

func get_all_guilds() -> Array:
	var sorted: Array = guilds.duplicate()
	sorted.sort_custom(func(a, b) -> bool:
		return a.get_ranking_score() > b.get_ranking_score()
	)
	return sorted

func get_guild_count() -> int:
	return guilds.size()

func get_ranking_board(limit: int = 10) -> Array:
	var board: Array = []
	for guild in get_all_guilds():
		board.append({
			"guild_id": guild.guild_id,
			"name": guild.name,
			"banner_symbol": guild.banner_symbol,
			"member_count": guild.members.size(),
			"average_grade": guild.get_average_grade(),
			"ranking_score": guild.get_ranking_score()
		})
		if board.size() >= limit:
			break
	return board

func update_member_grade(member_id: String, new_grade: float) -> bool:
	for guild in guilds:
		var member = guild.get_member(member_id)
		if member != null:
			member.battle_grade = clampf(new_grade, 1.0, 5.0)
			_save()
			return true
	return false

func get_banner_symbols() -> Array:
	return BANNER_SYMBOLS.duplicate()

func get_member_rank_label(rank: int) -> String:
	match rank:
		MEMBER_RANK_TROOPERS:
			return "Trooper"
		MEMBER_RANK_VETERANS:
			return "Veteran"
		MEMBER_RANK_COMMANDERS:
			return "Commander"
		_:
			return "Unknown"
