extends PathFollow2D

@export var speed:float = 0.08
var dead:bool = false

func _ready() -> void:
	$slime.enemy_died.connect(_on_enemy_died)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not dead:
		progress_ratio += speed * delta
		if progress_ratio > 0.5:
			$slime.scale.x = -2.0
		elif progress_ratio < 0.5:
			$slime.scale.x = 2.0

func _on_enemy_died(_enemy_instance):
	dead = true
