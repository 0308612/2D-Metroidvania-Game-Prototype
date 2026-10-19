extends CharacterBody2D

@onready var player: CharacterBody2D = $"../../../../Player"
signal enemy_died(enemy_node)
@export var health:int = 10

func _process(_delta: float) -> void:
	if health <= 0:
		emit_signal("enemy_died", self)
		queue_free()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("sword"):
		health -= player.damage
