extends Control

@onready var deity_container = $ScrollContainer/DeityContainer
@onready var select_button = $SelectButton
@onready var back_button = $BackButton

var deities = []  # Holds original, real deities
var deity_boxes: Array[Control] = []  # Holds actual displayed boxes (including clones)
var selected_index = 1  # Start at 1 because of wrap clone

func _ready():
	back_button.pressed.connect(_on_back_pressed)
	select_button.pressed.connect(_on_select_pressed)
	$ScrollContainer.gui_input.connect(_on_scroll_input)
	_load_deities()

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _on_select_pressed():
	var actual_index = selected_index - 1  # Since we added a clone at index 0
	if actual_index < 0 or actual_index >= deities.size():
		return

	var selected = deities[actual_index]
	if selected.get("locked", false):
		_show_message("You have not unlocked this deity.")
		return

	Global.deity_choice = selected
	get_tree().change_scene_to_file("res://scenes/Game.tscn")


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

	deity_boxes.clear()
	for child in deity_container.get_children():
		child.queue_free()

	# Create clone list for wrap-around
	var clone_list = deities.duplicate()
	clone_list.insert(0, deities[-1])  # Last deity clone at front
	clone_list.append(deities[0])      # First deity clone at end

	for i in range(clone_list.size()):
		var deity = clone_list[i]
		var box = _create_deity_card(deity)
		box.modulate.a = 0.0
		var tween = create_tween()
		tween.tween_property(box, "modulate:a", 1.0, 0.3).set_delay(0.05 * i)
		deity_container.add_child(box)
		deity_boxes.append(box)

	await get_tree().create_timer(0.1).timeout
	_snap_to_center_card()  # Initial snap

		
func _on_scroll_input(event):
	if event is InputEventMouseButton and not event.pressed:
		# Mouse released, trigger snap
		await get_tree().create_timer(0.05).timeout
		_snap_to_center_card()
	elif event is InputEventMouseMotion:
		# Optional: detect dragging movement, debounce
		pass
		
func _snap_to_center_card():
	var scroll = $ScrollContainer
	var center_x = scroll.scroll_horizontal + scroll.size.x / 2

	var min_dist = INF
	var closest_index = 0

	for i in deity_boxes.size():
		var box = deity_boxes[i]
		var box_x = box.global_position.x + box.size.x / 2
		var dist = abs(center_x - box_x)
		if dist < min_dist:
			min_dist = dist
			closest_index = i

	selected_index = closest_index
	_highlight_selected_card()

	# Scroll smoothly to selected
	var target_box = deity_boxes[selected_index]
	var box_center = target_box.global_position.x + target_box.size.x / 2
	var target_scroll = box_center - scroll.size.x / 2
	var tween = create_tween()
	tween.tween_property(scroll, "scroll_horizontal", target_scroll, 0.2)

	# Handle infinite wrap
	if selected_index == 0:
		await get_tree().create_timer(0.3).timeout
		scroll.scroll_horizontal = deity_boxes[deities.size()].global_position.x - scroll.size.x / 2
		selected_index = deities.size()
		_highlight_selected_card()
	elif selected_index == deity_boxes.size() - 1:
		await get_tree().create_timer(0.3).timeout
		scroll.scroll_horizontal = deity_boxes[1].global_position.x - scroll.size.x / 2
		selected_index = 1
		_highlight_selected_card()

func _highlight_selected_card():
	for i in deity_boxes.size():
		var box = deity_boxes[i]
		if i == selected_index:
			box.scale = Vector2(1.1, 1.1)
			box.modulate = Color(1, 1, 1, 1)
		else:
			box.scale = Vector2(1, 1)
			box.modulate = Color(1, 1, 1, 0.7)


func _create_deity_card(deity: Dictionary) -> Control:
	var box = VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.alignment = BoxContainer.ALIGNMENT_CENTER

	var name_label = Label.new()
	if deity.get("locked", false):
		name_label.text = "[LOCKED]"
	else:
		name_label.text = deity["name"]
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

func _find_center_card():
	var scroll = $ScrollContainer
	var center_x = scroll.scroll_horizontal + scroll.size.x / 2

	var min_dist = INF
	var closest_index = 0

	for i in deity_boxes.size():
		var box = deity_boxes[i]
		var box_x = box.global_position.x + box.size.x / 2
		var dist = abs(center_x - box_x)
		if dist < min_dist:
			min_dist = dist
			closest_index = i

	selected_index = closest_index
	_highlight_selected_card()
