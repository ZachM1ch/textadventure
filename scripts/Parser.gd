extends Node

var synonym_dict = {
	"examine": ["inspect", "look at", "study"],
	"look": ["inspect", "examine", "observe"],
	"get": ["take", "pick"],
	"inventory": ["inv", "bag"],
	"go": ["move", "walk"]#,
	#"interact": ["use", "do"]
}

func parse_input(text: String) -> Dictionary:
	var words = text.strip_edges().to_lower().split(" ")
	if words.is_empty():
		return {}

	# Handle one-word commands like "look" or "inventory"
	if words.size() == 1:
		return {
			"command": _resolve_command(words[0]),
			"args": []
		}

	# Handle two-word interaction-like commands: "open dresser", "search bed"
	if words.size() == 2:
		var cmd = _resolve_command(words[0])
		var noun = words[1]

		# If it's an action word that typically implies interaction
		if cmd in ["open", "search", "use", "move", "push", "pull", "read", "touch", "look"]:
			return {
				"command": "interact",
				"args": [cmd, noun]
			}

	# Otherwise treat first word as command, rest as args
	var command = _resolve_command(words[0])
	var args = words.slice(1, words.size())
	return {
		"command": command,
		"args": args
	}


func _resolve_command(word: String) -> String:
	for key in synonym_dict:
		if word == key or word in synonym_dict[key]:
			return key
	return word  # fallback to original if no match

func suggest_command(input_text: String, available_targets: Array[String]) -> String:
	var words = input_text.strip_edges().to_lower().split(" ")
	if words.is_empty():
		return ""

	# Try to handle vague one-word inputs
	if words.size() == 1:
		var verb = words[0]
		if verb in ["open", "search", "read", "use", "touch"]:
			if available_targets.size() == 1:
				return "interact " + verb + " " + available_targets[0]
			elif available_targets.size() > 1:
				return "What would you like to " + verb + "? Try: " + ", ".join(available_targets)
		elif verb in ["go", "move", "walk"]:
			return "Where would you like to go?"

	# Try matching known verbs with incomplete/missing targets
	if words.size() == 2 and words[0] in ["interact", "examine", "use"]:
		if words[1] not in available_targets:
			return "There's no '" + words[1] + "' here. Available: " + ", ".join(available_targets)

	return ""  # no suggestion
