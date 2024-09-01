extends Node

enum gameModes {
	CLASSIC,
	TANK_MAYHEM,
	POWER_MANIA,
	CHAOS_MODE
}

# Default values
var high_scores : Array = [0, 0, 0, 0]
var current_game_mode : int = gameModes.CLASSIC
var sound_effects_on : int = 1
var music_on : int = 1

func _ready():
	load_game_data()

func save_game_data() -> void:
	var save_file = FileAccess.open("user://save.json", FileAccess.WRITE)
	
	var save_data = {
		"high_scores": high_scores,
		"current_game_mode": current_game_mode,
		"sound_effects_on": sound_effects_on,
		"music_on": music_on,
	}
	
	var json_data = JSON.stringify(save_data)
	
	save_file.store_line(json_data)

func load_game_data() -> void:
	# Save the default values if the save file does not exist
	if not FileAccess.file_exists("user://save.json"):
		save_game_data()
		load_game_data()
		return
	
	var save_file = FileAccess.open("user://save.json", FileAccess.READ)
	
	var json_string = save_file.get_line()
	var json = JSON.new()

	# Check if there is any error while parsing the JSON string, skip in case of failure
	var parse_result = json.parse(json_string)
	if not parse_result == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		return

	# Get the data from the JSON object
	var json_data = json.get_data()
	
	sound_effects_on = json_data["sound_effects_on"]
	music_on = json_data["music_on"]
	
	current_game_mode = json_data["current_game_mode"]
	
	# If there is a new game mode added, save the new
	if len(json_data["high_scores"]) < len(high_scores):
		save_game_data()
	
	high_scores = json_data["high_scores"]
