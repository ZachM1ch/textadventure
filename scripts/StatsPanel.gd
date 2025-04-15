extends Panel

@onready var stats_box = $StatsBox
var stat_labels = {}
var effect_labels = {}

var stat_tooltips = {
	"lif": "Represents your health. If this reaches 0, you die.",
	"spd": "Determines your action order and evasion.",
	"atk": "Increases your physical damage.",
	"def": "Reduces incoming physical damage.",
	"mag": "Affects the power of spells and arcane effects.",
	"fai": "Faith-based ability. Influences miracles, blessings.",
	"res": "Mental fortitude. Resists fear, charm, and madness.",
	"hte": "Hate fuels certain powerful abilities, but can backfire.",
	"gld": "Your accumulated wealth.",
	"exp": "Earn experience to increase your level.",
	"Level": "Your overall power and progression tier.",
	"XP to Next": "Experience needed to reach the next level."
}

var effect_tooltips = {
	"poisoned": "Loses life each turn. Wears off over time.",
	"blessed": "Increased defense and healing.",
	"burning": "Takes damage each turn. Can spread.",
	"cursed": "Reduced stats or prevents healing.",
	"focused": "Increased accuracy and critical chance."
	# Add more as you define them!
}

func refresh_all(stats: Dictionary, effects: Dictionary):
	# Clear previous content
	for child in stats_box.get_children():
		child.queue_free()
	stat_labels.clear()
	effect_labels.clear()

	# Add all stats
	for stat_name in stats.keys():
		var label = RichTextLabel.new()
		label.bbcode_enabled = true
		label.scroll_active = false
		label.fit_content = true
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		
		match stat_name:
			"lif":
				label.text = "Life (LIF): %d" % stats[stat_name]
			"spd":
				label.text = "Speed (SPD): %d" % stats[stat_name]
			"atk":
				label.text = "Attack (ATK): %d" % stats[stat_name]
			"def":
				label.text = "Defense (DEF): %d" % stats[stat_name]
			"mag":
				label.text = "Magic (MAG): %d" % stats[stat_name]
			"fai":
				label.text = "Faith (FAI): %d" % stats[stat_name]
			"res":
				label.text = "Resolve (RES): %d" % stats[stat_name]
			"hte":
				label.text = "Hate (HTE): %d" % stats[stat_name]
			"gld":
				label.text = "Gold (GLD): %d" % stats[stat_name]
			"exp":
				label.text = "Experience (EXP): %d" % stats[stat_name]
			"Level":
				label.text = "Level: %d" % stats[stat_name]
			"XP to Next":
				label.text = "XP to Next: %d" % stats[stat_name]
			_:
				label.text = "%s: %s" % [stat_name.capitalize(), str(stats[stat_name])]
		
		stats_box.add_child(label)
		# Add tooltip if we have one
		if stat_tooltips.has(stat_name):
			label.tooltip_text = stat_tooltips[stat_name]
		stat_labels[stat_name] = label
		
	# Add status effects section
	if !effects.is_empty():
		var title_effect_label = RichTextLabel.new()
		title_effect_label.bbcode_enabled = true
		title_effect_label.scroll_active = false
		title_effect_label.fit_content = true
		title_effect_label.autowrap_mode = TextServer.AUTOWRAP_WORD
		
		title_effect_label.text = "Status Effects:"
		stats_box.add_child(title_effect_label)
		
		for effect_name in effects.keys():
			var effect_label = RichTextLabel.new()
			effect_label.bbcode_enabled = true
			effect_label.scroll_active = false
			effect_label.fit_content = true
			effect_label.autowrap_mode = TextServer.AUTOWRAP_WORD
		
			var duration = effects[effect_name]
			effect_label.text = "%s (%s)" % [effect_name.capitalize(), duration if duration >= 0 else "∞"]
			stats_box.add_child(effect_label)
			# Add tooltip if we have one
			if effect_tooltips.has(effect_name):
				effect_label.tooltip_text = effect_tooltips[effect_name]
			effect_labels[effect_name] = effect_label
