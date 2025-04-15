extends Control

@onready var select_button = $SelectButton
@onready var back_button = $BackButton

const NUM_REPEAT_COPIES := 3  # Full sets to display (left, center, right)

@onready var scroll_container = $ScrollContainer
@onready var deity_container = scroll_container.get_node("DeityContainer")

var deities: Array = []
var all_cards: Array = []

var deity_boxes: Array[Control] = []

func _ready():
	back_button.pressed.connect(_on_back_pressed)
	select_button.pressed.connect(_on_select_pressed)
	scroll_container.gui_input.connect(_on_scroll_input)

	_load_deities()

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _on_select_pressed():
	# For now, we will just select the first unlocked deity (center logic will be added later)
	for deity in deities:
		if not deity.get("locked", false):
			Global.deity_choice = deity
			get_tree().change_scene_to_file("res://scenes/Game.tscn")
			return
	_show_message("You have not unlocked a deity yet.")
	
func _on_scroll_input(event):
	if event is InputEventMouseMotion:
		await get_tree().create_timer(0.01).timeout
		_check_scroll_loop()

func _check_scroll_loop():
	var total_width = deity_container.get_combined_minimum_size().x
	var section_width = total_width / NUM_REPEAT_COPIES
	var current = scroll_container.scroll_horizontal

	if current < section_width * 0.5:
		scroll_container.scroll_horizontal += section_width
	elif current > section_width * 1.5:
		scroll_container.scroll_horizontal -= section_width


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

	for n in range(NUM_REPEAT_COPIES):
		for i in range(deities.size()):
			var deity = deities[i]
			var box = _create_deity_card(deity)
			box.modulate.a = 0.0

			var tween = create_tween()
			tween.tween_property(box, "modulate:a", 1.0, 0.3).set_delay(0.02 * (n * deities.size() + i))

			deity_container.add_child(box)
			all_cards.append(box)

	await get_tree().create_timer(0.1).timeout
	_center_scroll()

func _center_scroll():
	await get_tree().process_frame
	var total_width = deity_container.get_combined_minimum_size().x
	var visible_width = scroll_container.size.x
	var section_width = total_width / NUM_REPEAT_COPIES
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
	return box
