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
		
		match stat_name:
			"lif":
				label.text = "%s: %d" % ["Life (LIF)", stats[stat_name]]
			"spd":
				label.text = "%s: %d" % ["Speed (SPD)", stats[stat_name]]
			"atk":
				label.text = "%s: %d" % ["Attack (ATK)", stats[stat_name]]
			"def":
				label.text = "%s: %d" % ["Defense (DEF)", stats[stat_name]]
			"mag":
				label.text = "%s: %d" % ["Magic (MAG)", stats[stat_name]]
			"fai":
				label.text = "%s: %d" % ["Faith (FAI)", stats[stat_name]]
			"res":
				label.text = "%s: %d" % ["Resolve (RES)", stats[stat_name]]
			"hte":
				label.text = "%s: %d" % ["Hate (HTE)", stats[stat_name]]
			"gld":
				label.text = "%s: %d" % ["Gold (GLD)", stats[stat_name]]
			"exp":
				label.text = "%s: %d" % ["Experience (EXP)", stats[stat_name]]
		stats_box.add_child(label)
		stat_labels[stat_name] = label

func update_single_stat(stat_name: String, new_value: int):
	if stat_labels.has(stat_name):
		stat_labels[stat_name].text = "%s: %d" % [stat_name.capitalize(), new_value]
