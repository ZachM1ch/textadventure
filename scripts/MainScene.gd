extends Control

@onready var room_database = preload("res://data/RoomDatabase.gd").new()

@onready var text_input = $TextInput
@onready var output_log = $OutputLog
@onready var parser = $Parser
@onready var inventory = $PlayerData/Inventory
@onready var stats = $PlayerData/Stats
@onready var stats_panel = $StatsPanel


func _ready():
	output_log.editable = false
	text_input.grab_focus()
	text_input.keep_editing_on_text_submit = true
	$SubmitButton.pressed.connect(_on_submit_pressed)
	
	# Initial stats UI update
	stats_panel.update_stats_display(stats.get_all_stats())
	# Connect stat_changed signal
	stats.stat_changed.connect(_on_stat_changed)
	
	add_child(room_database)
	_print_to_log(room_database.get_current_room_description())


func _on_submit_pressed():
	var input_text = text_input.text
	text_input.clear()
	text_input.grab_focus()

	if input_text.is_empty():
		return

	output_log.text += "\n> " + input_text
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
					room_database.current_room.items.erase(item)
					inventory.add_item(item)
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
		_:
			var suggestion = parser.suggest_command(input_text, room_database.get_all_room_items())
			if suggestion != "":
				_print_to_log(suggestion)
			else:
				_print_to_log("I don't understand that command.")

func _print_to_log(text: String):
	output_log.text += "\n" + text

func _examine_target(target: String):
	var r = room_database.current_room

	if r.items.has(target):
		_print_to_log(r.items[target])
	elif r.objects.has(target):
		_print_to_log(r.objects[target].get("description", "You see nothing unusual."))
	elif r.enemies.has(target):
		_print_to_log(r.enemies[target].get("description", "It looks dangerous."))
	elif r.points_of_interest.has(target):
		_print_to_log(r.points_of_interest[target].get("description", "It catches your attention."))
	else:
		_print_to_log("There's nothing like that here.")

func _on_stat_changed(stat_name: String, new_value: int):
	stats_panel.update_single_stat(stat_name, new_value)
