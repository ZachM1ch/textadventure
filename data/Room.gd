extends Resource
class_name Room

@export var name: String = ""
@export var description: String = ""
@export var connections: Dictionary = {}
@export var items: Dictionary = {}   # key: description
@export var objects: Dictionary = {} # key: {description, interactions}
@export var enemies: Dictionary = {}
@export var points_of_interest: Dictionary = {}

func describe() -> String:
	var desc = "\n[b]" + name + "[/b]\n" + description + "\n"

	if items.size() > 0:
		desc += "Items: " + ", ".join(items.keys()) + "\n"
	if objects.size() > 0:
		desc += "Objects: " + ", ".join(objects.keys()) + "\n"
	if enemies.size() > 0:
		desc += "Enemies: " + ", ".join(enemies.keys()) + "\n"
	if points_of_interest.size() > 0:
		desc += "Points of Interest: " + ", ".join(points_of_interest.keys()) + "\n"

	if connections.size() > 0:
		desc += "Exits: " + ", ".join(connections.keys())

	return desc
