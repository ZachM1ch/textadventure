extends Control

@onready var scroll_container = $ScrollContainer
@onready var deity_container = scroll_container.get_node("DeityContainer")
@onready var left_button = $NavButtons/LeftButton
@onready var right_button = $NavButtons/RightButton
@onready var background = $Background
@onready var select_button = $SelectButton
@onready var back_button = $BackButton

var deities: Array = []
var all_cards: Array = []
var selected_card_index: int = 4  # First actual deity card (after spacers)

func _ready():
	back_button.pressed.connect(_on_back_pressed)
	select_button.pressed.connect(_on_select_pressed)
	left_button.pressed.connect(func(): _scroll_to_adjacent(-1))
	right_button.pressed.connect(func(): _scroll_to_adjacent(1))
	_load_deities()

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _on_select_pressed():
	var deity_index = selected_card_index - 4
	if deity_index < 0 or deity_index >= deities.size():
		_show_message("Please select a deity.")
		return

	var selected = deities[deity_index]
	if selected.get("locked", false):
		_show_message("You have not unlocked this deity.")
		return

	Global.deity_choice = selected
	get_tree().change_scene_to_file("res://scenes/Game.tscn")

func _scroll_to_adjacent(direction: int):
	var new_index = clamp(selected_card_index + direction, 4, all_cards.size() - 5)
	selected_card_index = new_index
	_highlight_selected_card()
	_update_background()
	_scroll_selected_card_to_center()

func _load_deities():
	var file = FileAccess.open("res://deity/deities.json", FileAccess.READ)
	if not file:
		push_error("Deity file failed to load")
		return
	deities = JSON.parse_string(file.get_as_text())

	all_cards.clear()
	for child in deity_container.get_children():
		child.queue_free()

	# Leading empty spacers
	for i in range(4):
		var spacer = _create_empty_card()
		deity_container.add_child(spacer)
		all_cards.append(spacer)

	# Real deity cards
	for deity in deities:
		var card = _create_deity_card(deity)
		deity_container.add_child(card)
		all_cards.append(card)

	# Trailing empty spacers
	for i in range(4):
		var spacer = _create_empty_card()
		deity_container.add_child(spacer)
		all_cards.append(spacer)

	_highlight_selected_card()
	_update_background()
	_scroll_selected_card_to_center()


func _highlight_selected_card():
	for i in all_cards.size():
		var card = all_cards[i]
		if i == selected_card_index:
			card.scale = Vector2(1.1, 1.1)
			card.modulate = Color(1, 0, 0, 1)
		else:
			card.scale = Vector2(1, 1)
			card.modulate = Color(1, 1, 1, 0.7)

func _update_background():
	var deity_index = selected_card_index - 4
	if deity_index >= 0 and deity_index < deities.size():
		var color_str = deities[deity_index].get("color", "#222222")
		background.color = Color(color_str)
	else:
		background.color = Color("#222222")

func _show_message(text: String):
	var popup = AcceptDialog.new()
	popup.dialog_text = text
	add_child(popup)
	popup.popup_centered()

func _create_deity_card(deity: Dictionary) -> Control:
	var box = VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.alignment = BoxContainer.ALIGNMENT_CENTER

	var name_label = Label.new()
	name_label.text = "[LOCKED]" if deity.get("locked", false) else deity["name"]
	box.add_child(name_label)

	var img = TextureRect.new()
	img.texture = load(deity["image"])
	img.expand_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	img.custom_minimum_size = Vector2(128, 128)
	box.add_child(img)

	if deity.get("locked", false):
		var lock_icon = TextureRect.new()
		lock_icon.texture = load("res://deity/lock.png")
		lock_icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		lock_icon.custom_minimum_size = Vector2(32, 32)
		box.add_child(lock_icon)
	else:
		for stat in deity["modifiers"].keys():
			var mod_label = RichTextLabel.new()
			mod_label.bbcode_enabled = true
			mod_label.text = "[color=gray]%s[/color]: [b]%+d[/b]" % [stat.capitalize(), deity["modifiers"][stat]]
			mod_label.scroll_active = false
			mod_label.fit_content = true
			box.add_child(mod_label)

	box.tooltip_text = deity.get("description", "No information available.")
	return box

func _create_empty_card() -> Control:
	var box = VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.custom_minimum_size = Vector2(150, 200)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return box

func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_LEFT:
				_scroll_to_adjacent(-1)
			KEY_RIGHT:
				_scroll_to_adjacent(1)

func _scroll_selected_card_to_center():
	if selected_card_index < 0 or selected_card_index >= all_cards.size():
		return

	var card = all_cards[selected_card_index]
	var card_pos = card.position.x
	var scroll_target = card_pos + card.size.x / 2 - scroll_container.size.x / 2

	scroll_container.scroll_horizontal = scroll_target
