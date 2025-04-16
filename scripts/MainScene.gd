extends Control

@onready var room_database = preload("res://data/RoomDatabase.gd").new()
@onready var stat_generator = preload("res://scripts/StatGenerator.gd").new()

@onready var text_input = $TextInput
@onready var output_log = $OutputLog
@onready var parser = $Parser
@onready var inventory = $PlayerData/Inventory
@onready var stats = $PlayerData/Stats
@onready var stats_panel = $StatsPanel

var typing_speed := 0.02  # Seconds per character
var output_queue: Array[String] = []
var is_typing := false

func _ready():
	var deity_modifiers = Global.deity_choice.get("modifiers", {})
	var color_str = Global.deity_choice.get("color", "#222222")
	var color_id = ""
	if "#" in color_str:
		color_id = Global.get_color_enum_from_hex(color_str)
	else:
		for color in Global.COLOR_NAME_MAP.keys():
			if color == color_str:
				color_id = Global.COLOR_NAME_MAP[color]
			else:
				color_id = Global.ColorName.GRAY
	
	var starting_stats = stat_generator.generate_stats_with_modifiers(deity_modifiers, color_id)
	stats.load_generated_stats(starting_stats)
	
	text_input.grab_focus()
	text_input.keep_editing_on_text_submit = true
	$SubmitButton.pressed.connect(_on_submit_pressed)
	
	# Initial stats UI update
	stats_panel.refresh_all(stats.get_all_stats(), stats.get_effects())
	# Connect stat_changed signal
	stats.stat_changed.connect(_on_stat_changed)
	
	stats.effects_changed.connect(_on_effects_changed)
	stats.level_up.connect(_on_level_up)

	add_child(room_database)
	_print_to_log(room_database.get_current_room_description())
	
	


func _on_submit_pressed():
	var input_text = text_input.text
	text_input.clear()
	text_input.grab_focus()

	if input_text.is_empty():
		return

	output_log.text += "[i][color=green]\n> " + input_text + "[/color][/i]"
	var parsed = parser.parse_input(input_text)
	_process_command(parsed, input_text)
	
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ENTER:
			if text_input.has_focus():
				_on_submit_pressed()	

func _process_command(parsed: Dictionary, input_text: String):
	var command = parsed.get("command", "")
	var args = parsed.get("args", [])

	match command:
		"examine":
			if args.size() > 0:
				_examine_target(args[0])
			else:
				_print_to_log("Examine what?")
		"look":
			_print_to_log(room_database.get_current_room_description())
		"inventory":
			_print_to_log("Inventory: " + inventory.list_items())
		"get":
			if args.size() > 0:
				var item = args[0]
				if item in room_database.current_room.items:
					inventory.add_item(item, room_database.current_room.items[item])
					room_database.current_room.items.erase(item)
					_print_to_log("You take the " + item + ".")
				else:
					_print_to_log("There is no " + item + " here.")
		"go":
			if args.size() > 0:
				if room_database.move(args[0]):
					_print_to_log("You go " + args[0] + ".")
					_print_to_log(room_database.get_current_room_description())
				else:
					_print_to_log("You can't go that way.")
		"interact":
			if args.size() > 1:
				var action = args[0]
				var target = args[1]
				var r = room_database.current_room

				if r.objects.has(target):
					var interactions = r.objects[target].get("interactions", {})
					if interactions.has(action):
						_print_to_log(interactions[action])
						return
				if r.points_of_interest.has(target):
					var interactions = r.points_of_interest[target].get("interactions", {})
					if interactions.has(action):
						_print_to_log(interactions[action])
						return
				_print_to_log("You can't do that.")
			else:
				_print_to_log("Try something like: open dresser or search bed.")
# ---- DEBUG ---- #
		"set":
			if args.size() >= 2:
				var stat = args[0]
				var value = int(args[1])
				stats.set_stat(stat, value)
				_print_to_log("%s set to %d" % [stat, value])
			else:
				_print_to_log("Usage: set [stat] [value]")
		"mod":
			if args.size() >= 2:
				var stat = args[0]
				var value = int(args[1])
				stats.modify_stat(stat, value)
				_print_to_log("%s changed by %d" % [stat, value])
		"xp":
			if args.size() > 0:
				stats.add_xp(int(args[0]))
				_print_to_log("Gained %s XP." % args[0])
		"effect":
			if args.size() > 0:
				var effect = args[0]
				var duration = int(args[1]) if args.size() > 1 else -1
				stats.add_effect(effect, duration)
				_print_to_log("Gained status effect: %s." % effect)
		"advance":
			stats.advance_effects()
			_print_to_log("Advanced status effects by one tick.")
		_:
			var suggestion = parser.suggest_command(input_text, room_database.get_all_room_items())
			if suggestion != "":
				_print_to_log(suggestion)
			else:
				_print_to_log("I don't understand that command.")

func _print_to_log(text: String):
	output_queue.append(text)
	if not is_typing:
		_process_next_output()
		
func _process_next_output():
	if output_queue.is_empty():
		is_typing = false
		return

	is_typing = true
	var label = $OutputLog
	var next_line = output_queue.pop_front()
	var bbcode_line = "\n" + next_line
	var char_index = 0
	var display_text = label.text

	while char_index < bbcode_line.length():
		var c = bbcode_line[char_index]
		display_text += c
		label.text = display_text
		await get_tree().create_timer(typing_speed).timeout
		char_index += 1

		label.scroll_to_line(label.get_line_count())  # Auto-scroll

	# After typing, allow the next line
	_process_next_output()


func _examine_target(target: String):
	var r = room_database.current_room

	if inventory.items.has(target):
		_print_to_log(inventory.items[target])
	elif r.items.has(target):
		_print_to_log(r.items[target])
	elif r.objects.has(target):
		_print_to_log(r.objects[target].get("description", "You see nothing unusual."))
	elif r.enemies.has(target):
		_print_to_log(r.enemies[target].get("description", "It looks dangerous."))
	elif r.points_of_interest.has(target):
		_print_to_log(r.points_of_interest[target].get("description", "It catches your attention."))
	else:
		_print_to_log("There's nothing like that here.")

func _on_stat_changed(_name: String, _value: int):
	stats_panel.refresh_all(stats.get_all_stats(), stats.get_effects())

func _on_effects_changed():
	stats_panel.refresh_all(stats.get_all_stats(), stats.get_effects())

func _on_level_up(new_level: int):
	_print_to_log("You leveled up! You are now level %d!" % new_level)
	# No need to update stats panel here, stat_changed will already be triggered
