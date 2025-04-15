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
var selected_card_index: int = 0
var deity_boxes: Array[Control] = []
var scroll_locked := false

func _ready():
	back_button.pressed.connect(_on_back_pressed)
	select_button.pressed.connect(_on_select_pressed)
	scroll_container.gui_input.connect(_on_scroll_input)
	left_button.pressed.connect(func(): _scroll_to_adjacent(-1))
	right_button.pressed.connect(func(): _scroll_to_adjacent(1))

	_load_deities()

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _on_select_pressed():
	if all_cards.is_empty():
		return

	var card_index = selected_card_index
	var deity_index = card_index - 4  # Adjust for 4 padding cards

	# Ignore if selection is out of bounds (it's a spacer)
	if deity_index < 0 or deity_index >= deities.size():
		_show_message("Please select a deity.")
		return

	var selected = deities[deity_index]

	if selected.get("locked", false):
		_show_message("You have not unlocked this deity.")
		return

	Global.deity_choice = selected
	get_tree().change_scene_to_file("res://scenes/Game.tscn")
	
func _on_scroll_input(event):
	if event is InputEventMouseMotion or event is InputEventPanGesture:
		await get_tree().create_timer(0.01).timeout
		_detect_center_card()

func _detect_center_card():
	var center_x = scroll_container.scroll_horizontal + scroll_container.size.x / 2

	var min_dist = INF
	var closest_index = 0
	for i in all_cards.size():
		var box = all_cards[i]
		var box_x = box.global_position.x + box.size.x / 2
		var dist = abs(center_x - box_x)
		if dist < min_dist:
			min_dist = dist
			closest_index = i

	selected_card_index = closest_index
	_highlight_selected_card()

	# OPTIONAL: update background color only if real card
	var deity_index = selected_card_index - 4
	if deity_index >= 0 and deity_index < deities.size():
		var color_str = deities[deity_index].get("color", "#222222")
		background.color = Color(color_str)
	else:
		background.color = Color("#222222")  # Neutral for empty card

	
func _scroll_to_adjacent(direction: int):
	if scroll_locked:
		return
	scroll_locked = true

	var target_index = clamp(selected_card_index + direction, 4, all_cards.size() - 5)
	var target_card = all_cards[target_index]
	await _center_on_card(target_card, target_index)
	scroll_locked = false


func _show_message(text: String):
	var popup = AcceptDialog.new()
	popup.dialog_text = text
	add_child(popup)
	popup.popup_centered()

func _load_deities():
	var file = FileAccess.open("res://deity/deities.json", FileAccess.READ)
	if not file:
		push_error("Deity file failed to load")
		return
	deities = JSON.parse_string(file.get_as_text())

	all_cards.clear()
	for child in deity_container.get_children():
		child.queue_free()

	# Add 4 leading empty padding cards
	for i in range(4):
		var spacer = _create_empty_card()
		deity_container.add_child(spacer)
		all_cards.append(spacer)

	# Add actual deity cards
	for i in range(deities.size()):
		var deity = deities[i]
		var box = _create_deity_card(deity)
		#box.modulate.a = 0.0
		#var tween = create_tween()
		#tween.tween_property(box, "modulate:a", 1.0, 0.3).set_delay(0.03 * i)
		deity_container.add_child(box)
		all_cards.append(box)

	# Add 4 trailing empty padding cards
	for i in range(4):
		var spacer = _create_empty_card()
		deity_container.add_child(spacer)
		all_cards.append(spacer)

	await get_tree().process_frame
	_center_on_card(all_cards[4])  # First real deity card
	await get_tree().create_timer(0.05).timeout
	_detect_center_card()

func _center_scroll():
	await get_tree().process_frame
	var total_width = deity_container.get_combined_minimum_size().x
	var visible_width = scroll_container.size.x
	var section_width = total_width
	scroll_container.scroll_horizontal = section_width - (visible_width / 2)


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
	var this_index = all_cards.size()  # Index the card will have when added
	box.gui_input.connect(func(event):
		if event is InputEventMouseButton and event.pressed:
			_center_on_card(box, this_index)
	)

	return box
	
func _create_empty_card() -> Control:
	var box = VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.custom_minimum_size = Vector2(150, 200)  # Adjust spacing as needed
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return box


func _center_on_card(target: Control, index_override := -1) -> void:
	var box_center = target.global_position.x + target.size.x / 2
	var scroll_target = box_center - scroll_container.size.x / 2

	var tween = create_tween()
	tween.tween_property(scroll_container, "scroll_horizontal", scroll_target, 0.25)

	await tween.finished

	if index_override >= 0:
		selected_card_index = index_override
	else:
		_detect_center_card()
		
	if index_override >= 0:
		selected_card_index = index_override
		print("Selected via click: ", selected_card_index)
	else:
		_detect_center_card()
		print("Selected via scroll: ", selected_card_index)


func _highlight_selected_card():
	for i in all_cards.size():
		var card = all_cards[i]
		if i == selected_card_index:
			card.scale = Vector2(1.1, 1.1)
			card.modulate = Color(1, 0, 0, 1)
		else:
			card.scale = Vector2(1, 1)
			card.modulate = Color(1, 1, 1, 0.7)

func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_LEFT:
				_scroll_to_adjacent(-1)
			KEY_RIGHT:
				_scroll_to_adjacent(1)
