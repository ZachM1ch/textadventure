extends Node
class_name RoomDatabase

const ROOM_DATA_PATH = "res://data/rooms.json"
var rooms: Dictionary = {}
var current_room: Room

func _ready():
	_load_rooms_from_json()

func _load_rooms_from_json():
	var file = FileAccess.open(ROOM_DATA_PATH, FileAccess.READ)
	if not file:
		push_error("Failed to load room data.")
		return

	var raw_json = file.get_as_text()
	var parsed_data = JSON.parse_string(raw_json)
	if typeof(parsed_data) != TYPE_DICTIONARY:
		push_error("Room JSON is invalid.")
		return

	for room_id in parsed_data.keys():
		var room_data = parsed_data[room_id]
		var room = Room.new()
		
		var room_items = []
		var room_objects = []
		var room_enemies = []
		var room_pois = []
		
		room.name = room_data.get("name", "")
		room.description = room_data.get("description", "")
		room.items = room_data.get("items", {})
		room.objects = room_data.get("objects", {})
		room.enemies = room_data.get("enemies", {})
		room.points_of_interest = room_data.get("points_of_interest", {})

		room.connections = room_data.get("connections", {})

		rooms[room_id] = room

	# Default starting room
	current_room = rooms.get("bedroom", null)

func move(direction: String) -> bool:
	var destination_id = current_room.connections.get(direction, null)
	if destination_id and rooms.has(destination_id):
		current_room = rooms[destination_id]
		return true
	return false

func get_current_room_description() -> String:
	return current_room.describe()

func get_all_room_items() -> Array:
	var names = []
	names += current_room.items.keys()
	names += current_room.objects.keys()
	names += current_room.enemies.keys()
	names += current_room.points_of_interest.keys()
	return names
