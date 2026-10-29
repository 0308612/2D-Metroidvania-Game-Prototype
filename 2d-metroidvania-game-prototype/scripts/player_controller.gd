extends CharacterBody2D

@onready var player: CharacterBody2D = $"."
@onready var animation_player: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast_left: RayCast2D = $"raycast/RayCast left"
@onready var ray_cast_right: RayCast2D = $"raycast/RayCast right"
@onready var sword_collider: CollisionShape2D = $"sword/sword collider"
@onready var save_piont: Area2D = $"../save point/Area2D"

@export_category("Movement Varibles")
@export var Move_Speed:float = 250.0
@export var Deceleration:float = 0.1
@export var Gravity:float = 1000.0

var Movement = Vector2()

@export_category("Jump Varibles")
@export var Jump_speed:float = 500.0
@export var Aceleration:float = 550.0
@export var Jump_amount:int = 1
@export var Jump_upgrade:bool = false

var landing_animation_can_play:bool = false

@export_category("Wall Logic Variables")
@export var Wall_force_x:float = 500.0
@export var Wall_force_y:float = -450.0
var is_wall_jumping:bool = false

@export_category("Dash Variables")
@export var Dash_Speed:float = 450.0
@export var Facing_Right:bool = true
@export var Dash_Gravity:float = 0.0
var Dash_number:int = 1
var Dash_key_is_pressed:bool = false
var is_dashing:bool = false

@export_category("Attack Variables")
var damage:int = 5
var is_attacking:bool = false
var can_attack:bool = true

var healing = false

var dead = false

var sprinting = false

var get_up = false

var resting = false

func _ready() -> void:
	sword_collider.disabled = true
	$"../UI".health()
	if FileAccess.file_exists(SaveManager.save_file_name):
		SaveManager.load_game()
		apply_saved_state()

func _physics_process(delta: float) -> void:
	if is_dashing == false:
		velocity.y += Gravity * delta
	elif is_dashing == true:
		velocity.y = Dash_Gravity
	
	Horizontal_Movement()
	Animations()
	flip()
	Jump_Logic()
	wall_logic()
	attack()
	changeing_mana(delta)
	die()
	running()
	
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if not Movement:
		if event.is_action_pressed("look up") or event.is_action_pressed("jump"):
			if save_piont and save_piont.has_method("stand_up"):
				save_piont.stand_up()


func Horizontal_Movement():
	if is_wall_jumping == false and is_dashing == false and save_piont.resting == false:
		Movement = Input.get_axis("move left", "move right")
		
		if Movement:
			velocity.x = Movement * Move_Speed
		else:
			velocity.x = move_toward(velocity.x, 0, Move_Speed * Deceleration)
	if Input.is_action_just_pressed("dash") and Dash_key_is_pressed == false and Dash_number >= 1:
		Dash_number -= 1                                                                                                        
		Dash_key_is_pressed = true
		dash()

func Animations():
	if not get_up:
		if not save_piont.resting:
			if not dead:
				if not healing:
					if not is_attacking:
						if velocity.x != 0 and is_on_floor() and not sprinting:
							animation_player.play("Move")
						elif velocity.x == 0 and is_on_floor():
							animation_player.play("Idle")
						if sprinting and is_on_floor() and velocity.x != 0:
							animation_player.play("Run")
						if velocity.y != 0 and is_on_floor() and velocity.y == 0:
							animation_player.play("Land")
						if velocity.y < 0:
							animation_player.play("Jump")
						if velocity.y > 10 and is_on_floor() == false:
							animation_player.play("fall")
					if is_attacking:
						animation_player.play("attack")
				if healing:
					animation_player.play("Heal")
			if dead:
				animation_player.play("Death")
		if resting:
			animation_player.play("lie down")
			await animation_player.animation_finished
			resting = false
	if get_up:
		animation_player.play("get up")
		await animation_player.animation_finished
		get_up = false


func flip():
	if not is_attacking:
		if velocity.x > 0.0:
			Facing_Right = true
			scale.x = scale.y * 1
			Wall_force_x = 450.0
		elif velocity.x < 0.0:
			Facing_Right = false
			scale.x = scale.y * -1
			Wall_force_x = -450.0

func Jump_Logic():
	if is_on_floor():
		Dash_number = 1
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
		velocity.y = 200
		if Input.is_action_just_pressed("jump"):
			if ray_cast_right.is_colliding():
				velocity = Vector2(-Wall_force_x, Wall_force_y)
				wall_jumping()

func wall_jumping():
	is_wall_jumping = true
	await get_tree().create_timer(0.12).timeout
	is_wall_jumping = false

func dash():
	if Dash_key_is_pressed:
		is_dashing = true
	else:
		is_dashing = false
	if Facing_Right == true:
		velocity.x = Dash_Speed
		dash_started()
	else:
		velocity.x -= Dash_Speed
		dash_started()

func dash_started():
	if is_dashing:
		Dash_key_is_pressed = true
		await get_tree().create_timer(0.3).timeout
		is_dashing = false
		Dash_key_is_pressed = false
	else:
		return

func running():
	if Input.is_action_pressed("sprint") and Movement and not is_dashing:
		velocity.x = move_toward(velocity.x, 0, Move_Speed * Deceleration) * 2
		sprinting = true
	if Input.is_action_just_released("sprint"):
		velocity.x = move_toward(velocity.x, 0, Move_Speed * Deceleration)
		sprinting = false

func attack():
	
	if Input.is_action_just_pressed("attack") and can_attack:
		can_attack = false
		is_attacking = true
		await get_tree().create_timer(0.1).timeout
		sword_collider.disabled = false
		await get_tree().create_timer(0.6).timeout
		sword_collider.disabled = true
		is_attacking = false
		can_attack = true

func changeing_mana(_delta: float):
	if Input.is_action_just_pressed("heal"):
		healing = true
		if $"Heal timer".is_stopped():
			$"Heal timer".start()
	if healing:
		velocity = Vector2.ZERO

func can_heal():
	if Globals.Player_mana >= 0.25:
		if Globals.Player_health < Globals.Max_player_health:
			Globals.Player_health += 1
		Globals.Player_mana -= 0.25

func _on_heal_timer_timeout() -> void:
	if Input.is_action_pressed("heal"):
		can_heal()
		healing = false

func die():
	if Globals.Player_health <= 0:
		dead = true
		velocity = Vector2.ZERO
		await get_tree().create_timer(2).timeout
		dead = false
		SaveManager.handle_player_death()

func apply_saved_state() -> void:
	var data = SaveManager.default_dictionary
	
	position = Vector2(data["player_pos_x"], data["player_pos_y"])
	
