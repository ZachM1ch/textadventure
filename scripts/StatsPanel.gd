extends Panel

@onready var stats_box = $StatsBox
var stat_labels = {}

func update_stats_display(stats: Dictionary):
	var box_kids = stats_box.get_children(true)
	for i in box_kids:
		i.queue_free()
	stat_labels.clear()

	for stat_name in stats.keys():
		var label = Label.new()
		label.text = "%s: %d" % [stat_name.capitalize(), stats[stat_name]]
		stats_box.add_child(label)
		stat_labels[stat_name] = label

func update_single_stat(stat_name: String, new_value: int):
	if stat_labels.has(stat_name):
		stat_labels[stat_name].text = "%s: %d" % [stat_name.capitalize(), new_value]
