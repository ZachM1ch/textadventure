extends Node

signal stat_changed(stat_name: String, new_value: int)

var stats = {
	"health": 100,
	"strength": 10,
	"agility": 5
}

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
	return stats.duplicate()
