extends Control

@onready var exit_dialog = $ExitDialog

func _ready():
	$VBoxContainer/NewButton.pressed.connect(_on_new_pressed)
	$VBoxContainer/LoadButton.disabled = true  # Placeholder
	$VBoxContainer/ExitButton.pressed.connect(_on_exit_pressed)
	exit_dialog.confirmed.connect(_on_exit_confirmed)

func _on_new_pressed():
	get_tree().change_scene_to_file("res://scenes/NewRun.tscn")

func _on_exit_pressed():
	exit_dialog.dialog_text = "Are you sure you want to exit the game?"
	exit_dialog.popup_centered()

func _on_exit_confirmed():
	get_tree().quit()
