extends Node

signal stat_changed(stat_name: String, new_value: int)
signal level_up(new_level: int)
signal effects_changed()

var stats = {
	"lif": 0,
	"spd": 0,
	"atk": 0,
	"def": 0,
	"mag": 0,
	"fai": 0,
	"res": 0,
	"hte": 0,
	"gld": 0,
	"exp": 0
}

var level: int = 1
var xp_to_next: int = 100  # Can scale later
var status_effects: Dictionary = {}  # effect_name: duration (int or null)

func get_stat(stat_name: String) -> int:
	return stats.get(stat_name, 0)

func modify_stat(stat_name: String, amount: int):
	if stats.has(stat_name):
		stats[stat_name] += amount
		emit_signal("stat_changed", stat_name, stats[stat_name])

func set_stat(stat_name: String, value: int):
	stats[stat_name] = value
	emit_signal("stat_changed", stat_name, value)
	
func get_all_stats() -> Dictionary:
	var full = stats.duplicate()
	full["Level"] = level
	full["XP to Next"] = xp_to_next
	return full

func add_xp(amount: int):
	stats.exp += amount
	emit_signal("stat_changed", "XP", stats.exp)
	while stats.exp >= xp_to_next:
		_level_up()

func _level_up():
	level += 1
	stats.exp -= xp_to_next
	xp_to_next = int(xp_to_next * 1.5)  # Scale up
	emit_signal("stat_changed", "Level", level)
	emit_signal("stat_changed", "XP to Next", xp_to_next)
	emit_signal("level_up", level)
	
# -------- Status Effect Management --------

func add_effect(effect_name: String, duration: int = -1):
	status_effects[effect_name] = duration
	emit_signal("effects_changed")

func remove_effect(effect_name: String):
	status_effects.erase(effect_name)
	emit_signal("effects_changed")

func get_effects() -> Dictionary:
	return status_effects.duplicate()

func advance_effects():
	emit_signal("effects_changed")
	var to_remove = []
	for effect in status_effects:
		if status_effects[effect] > 0:
			status_effects[effect] -= 1
			if status_effects[effect] <= 0:
				to_remove.append(effect)
	for effect in to_remove:
		status_effects.erase(effect)
	#if to_remove.size() > 0:
		#emit_signal("effects_changed")
		
func load_generated_stats(data: Dictionary):
	for stat in data.keys():
		stats[stat] = data[stat]
		emit_signal("stat_changed", stat, data[stat])
