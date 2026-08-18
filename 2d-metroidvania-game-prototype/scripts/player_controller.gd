extends CharacterBody2D

@onready var player: CharacterBody2D = $"."
@onready var animation_player: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast_left: RayCast2D = $"raycast/RayCast left"
@onready var ray_cast_right: RayCast2D = $"raycast/RayCast right"

@export_category("Movement Varibles")
@export var Move_Speed:float = 600.0
@export var Deceleration:float = 0.1
@export var Gravity:float = 2000.0

var Movement = Vector2()

@export_category("Jump Varibles")
@export var Jump_speed:float = 1590.0
@export var Aceleration:float = 1690.0
@export var Jump_amount:int = 1
@export var Jump_upgrade:bool = false

var landing_animation_can_play:bool = false

@export_category("Wall Logic Variables")
@export var Wall_force_x:float = 1500.0
@export var Wall_force_y:float = -1700.0
var is_wall_jumping:bool = false

func _physics_process(delta: float) -> void:
	velocity.y += Gravity * delta
	Horizontal_Movement()
	Animations()
	flip()
	Jump_Logic()
	wall_logic()
	
	move_and_slide()

func Horizontal_Movement():
	Movement = Input.get_axis("move left", "move right")
	
	if Movement:
		velocity.x = Movement * Move_Speed
	else:
		velocity.x = move_toward(velocity.x, 0, Move_Speed * Deceleration)

func Animations():
	if velocity.x != 0 and is_on_floor():
		animation_player.play("Move")
	elif velocity.x == 0 and is_on_floor():
		animation_player.play("Idle")
	if velocity.y != 0 and is_on_floor() and velocity.y == 0:
		animation_player.play("Land")
	if velocity.y < 0:
		animation_player.play("Jump")
	if velocity.y > 10 and is_on_floor() == false:
		animation_player.play("fall")

func flip():
	if velocity.x > 0.0:
		scale.x = scale.y * 1
		Wall_force_x = 1500.0
	elif velocity.x < 0.0:
		scale.x = scale.y * -1
		Wall_force_x = -1500.0

func Jump_Logic():
	if is_on_floor() and Jump_upgrade == false:
		Jump_amount = 1
		velocity.y = 0
	
	elif is_on_floor() and Jump_upgrade == true:
		Jump_amount = 2
		velocity.y = 0
	
	if Input.is_action_just_pressed("jump") and Jump_amount > 0:
		Jump_amount -= 1
		velocity.y -= lerp(Jump_speed, Aceleration, 0.1)
	
	if not is_on_floor():
		if Jump_amount > 0:
			if Input.is_action_just_pressed("jump"):
				velocity.y -= lerp(Jump_speed, Aceleration, 0.9)
		if Input.is_action_just_released("jump"):
			velocity.y = lerp(velocity.y, Gravity, 0.3)
			velocity.y *= 0.6
			landing_animation_can_play = true
	else:
		return

func wall_logic():
	if is_on_wall_only():
		velocity.y = 400
		if Input.is_action_just_pressed("jump"):
			if ray_cast_left.is_colliding():
				velocity = Vector2(Wall_force_x, Wall_force_y)
			if ray_cast_right.is_colliding():
				velocity = Vector2(-Wall_force_x, Wall_force_y)
