extends Node

signal stat_changed(stat_name: String, new_value: int)

var stats = {
	"lif": 5,
	"spd": 2,
	"atk": 2,
	"def": 4,
	"mag": 7,
	"fai": 1,
	"res": 3,
	"hte": 8,
	"gld": 1,
	"exp": 4
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
