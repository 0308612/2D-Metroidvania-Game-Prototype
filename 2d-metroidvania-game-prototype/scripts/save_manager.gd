extends Node

const save_file_name: String = "user://save_file.json"
var default_dictionary: Dictionary = {"player_pos_x": 0, "player_pos_y": -48, "save_points_visited": [], "scene_path": "res://scenes/opening_room.tscn"}

func save_game() -> void:
	var save_file: FileAccess = FileAccess.open(save_file_name, FileAccess.WRITE)
	if save_file == null:
		push_error("Error opening file")
		return
	var string_data: String = JSON.stringify(default_dictionary)
	save_file.store_string(string_data)
	save_file.close()

func load_game() -> Dictionary:
	if FileAccess.file_exists(save_file_name):
		var save_file: FileAccess = FileAccess.open(save_file_name, FileAccess.READ)
		if save_file == null:
			push_error("Error readinf file")
			return default_dictionary

		var json_string = save_file.get_as_text()
		var json = JSON.new()
		
		if json.parse(json_string) == OK:
			var data: Dictionary = json.get_data()
			for key in data:
				default_dictionary[key] = data[key]
			save_file.close()
			return data
		push_error("Corrupted data")
	return default_dictionary

func reset_to_last_save() -> void:
	load_game()
	get_tree().change_scene_to_file(default_dictionary["scene_path"])

func handle_player_death() -> void:
	Globals.Player_health = Globals.Max_player_health
	Globals.Player_mana = 0.0
	save_game()
	reset_to_last_save()
	
