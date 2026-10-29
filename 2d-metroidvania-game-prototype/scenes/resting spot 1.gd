extends Area2D

@onready var lie_position: Marker2D = $"../Lie position"

@export var ID:String = "opening_room_save_point"
@export var respawn_position: Vector2 = Vector2(0.0, 36.0)
var player_in_range: CharacterBody2D = null
var resting:bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func rest() -> void:
	resting = true
	
	player_in_range.resting = true
	
	player_in_range.global_position = lie_position.global_position
	player_in_range.velocity = Vector2.ZERO
	
	Globals.Player_health = Globals.Max_player_health
	
	SaveManager.default_dictionary["scene_path"] = get_tree().current_scene.scene_file_path
	
	SaveManager.default_dictionary["player_pos_x"] = -396.0
	SaveManager.default_dictionary["player_pos_y"] = 117.0
	if not ID in SaveManager.default_dictionary["save_points_visited"]:
		SaveManager.default_dictionary["save_points_visited"].append(ID)
		
	SaveManager.save_game()

func stand_up() -> void:
	if resting and player_in_range:
		player_in_range.get_up = true
		resting = false

func _unhandled_input(event: InputEvent) -> void:
	if player_in_range and event.is_action_pressed("look down") and not resting:
		rest()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = body

func _on_body_exited(body: Node2D) -> void:
	if body == player_in_range:
		player_in_range = null
