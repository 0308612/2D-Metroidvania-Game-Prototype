extends CharacterBody2D

@onready var player: CharacterBody2D = $"."
@onready var animation_player: AnimatedSprite2D = $AnimatedSprite2D

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

func _physics_process(delta: float) -> void:
	velocity.y += Gravity * delta
	Horizontal_Movement()
	Animations()
	flip()
	Jump_Logic()
	print(velocity.y)
	move_and_slide()

func Horizontal_Movement():
	Movement = Input.get_axis("move left", "move right")
	
	if Movement:
		velocity.x = Movement * Move_Speed
	else:
		velocity.x = move_toward(velocity.x, 0, Move_Speed * Deceleration)

func Animations():
	if velocity.x != 0 and velocity.y == 0:
		animation_player.play("Move")
	if velocity.x == 0 and velocity.y == 0:
		animation_player.play("Idle")
	if is_on_floor() and velocity.y != 0:
		animation_player.play("Land")

func flip():
	if velocity.x > 0.0:
		scale.x = scale.y * 1
	elif velocity.x < 0.0:
		scale.x = scale.y * -1

func Jump_Logic():
	if is_on_floor() and Jump_upgrade == false:
		Jump_amount = 1
		velocity.y = 0
	
	elif is_on_floor() and Jump_upgrade == true:
		Jump_amount = 2
		velocity.y = 0
	
	if Input.is_action_just_pressed("jump") and Jump_amount > 0:
		Jump_amount -= 1
		animation_player.play("Jump")
		velocity.y -= lerp(Jump_speed, Aceleration, 0.1)
	
	if not is_on_floor():
		if Jump_amount > 0:
			if Input.is_action_just_pressed("jump"):
				animation_player.play("Jump")
				velocity.y -= lerp(Jump_speed, Aceleration, 1)
		if Input.is_action_just_released("jump"):
			velocity.y = lerp(velocity.y, Gravity, 0.2)
			velocity.y *= 0.3
	else:
		return
