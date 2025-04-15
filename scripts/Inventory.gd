extends Node

var items: Dictionary = {}

func add_item(item: String, desc: String):
	if item not in items:
		items[item] = desc

func remove_item(item: String):
	items.erase(item)

func list_items() -> String:
	return ", ".join(items.keys()) if items.size() > 0 else "You have nothing."
