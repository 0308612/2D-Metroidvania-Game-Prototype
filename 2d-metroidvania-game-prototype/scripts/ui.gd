extends CanvasLayer

const heart_row_size = 8
const heart_offset = 2

func health():
	for i in Globals.Max_player_health:
		var new_heart = Sprite2D.new()
		new_heart.texture = $hearts.texture
		new_heart.hframes = $hearts.hframes
		$hearts.add_child(new_heart)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	mana_regen()
	
	for hearts in $hearts.get_children():
		var index = hearts.get_index()
		var x = (index * heart_row_size) * heart_offset
		@warning_ignore("integer_division")
		var y = (index / heart_row_size) * heart_offset
		hearts.position = Vector2(x,y)
		
		var last_heart = floor(Globals.Player_health)
		if index > last_heart:
			hearts.frame = 0
		if index == last_heart:
			hearts.frame = (Globals.Player_health - last_heart) * 4
		if index < last_heart:
			hearts.frame = 4
			

func mana_regen():
	if Globals.Player_mana == 1.0:
		$mana.frame = 0
	if Globals.Player_mana == 0.75:
		$mana.frame = 1
	if Globals.Player_mana == 0.5:
		$mana.frame = 2
	if Globals.Player_mana == 0.25:
		$mana.frame = 3
	if Globals.Player_mana == 0.0:
		$mana.frame = 4
