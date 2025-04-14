extends Node

var items: Array[String] = []

func add_item(item: String):
	if item not in items:
		items.append(item)

func remove_item(item: String):
	items.erase(item)

func list_items() -> String:
	return ", ".join(items) if items.size() > 0 else "You have nothing."
