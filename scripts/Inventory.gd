extends Node

var items: Dictionary = {}  # key: item name, value: description

func add_item(item: String, desc: String):
	items[item] = desc  # Will overwrite if already exists (you can guard this if needed)

func add_item_from_dict(item_data: Dictionary):
	var name = item_data.get("name", "")
	var desc = item_data.get("description", "An item.")
	if name != "":
		add_item(name, desc)

func remove_item(item: String):
	items.erase(item)

func list_items() -> String:
	return ", ".join(items.keys()) if items.size() > 0 else "You have nothing."

func get_description(item: String) -> String:
	return items.get(item, "You don't recognize this item.")
