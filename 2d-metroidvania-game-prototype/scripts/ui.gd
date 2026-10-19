extends CanvasLayer

const heart_row_size = 8
const heart_offset = 16

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in Globals.Player_health:
		var new_heart = Sprite2D.new()
		new_heart.texture = $hearts.texture
		new_heart.hframes = $hearts.hframes
		$hearts.add_child(new_heart)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
