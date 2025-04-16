extends Node

# Define min and max for each stat
const DEFAULT_STAT_RANGES := {
	"lif": Vector2i(3, 8),
	"spd": Vector2i(1, 5),
	"atk": Vector2i(2, 6),
	"def": Vector2i(2, 6),
	"mag": Vector2i(1, 7),
	"fai": Vector2i(0, 4),
	"res": Vector2i(2, 5),
	"hte": Vector2i(5, 10),
	"gld": Vector2i(0, 2),
	"exp": Vector2i(0, 0)
}

# Custom ranges by deity color
const COLOR_STAT_RANGES := {
	Global.ColorName.RED: {
		"atk": Vector2i(4, 8),
		"lif": Vector2i(4, 9),
		"mag": Vector2i(0, 3)
	},
	Global.ColorName.BLUE: {
		"mag": Vector2i(5, 10),
		"res": Vector2i(3, 6),
		"atk": Vector2i(1, 4)
	},
	Global.ColorName.GREEN: {
		"spd": Vector2i(3, 7),
		"fai": Vector2i(2, 6),
		"hte": Vector2i(4, 8)
	},
	Global.ColorName.GOLD: {
		"gld": Vector2i(3, 6),
		"exp": Vector2i(10, 20)
	}
}

func generate_stats_with_modifiers(modifiers: Dictionary, color_id: int) -> Dictionary:
	var stats := {}

	for stat in DEFAULT_STAT_RANGES.keys():
		var base_range = DEFAULT_STAT_RANGES[stat]

		# If the color overrides this stat, use it
		if COLOR_STAT_RANGES.has(color_id) and COLOR_STAT_RANGES[color_id].has(stat):
			base_range = COLOR_STAT_RANGES[color_id][stat]

		var base_value = randi_range(base_range.x, base_range.y)
		var modified = base_value + modifiers.get(stat, 0)
		stats[stat] = max(0, modified)
	
	return stats
