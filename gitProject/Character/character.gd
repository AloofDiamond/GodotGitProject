extends CharacterBody2D

const SPEED : float = 2000.0
const JUMP_VELOCITY : float = -40.0
const FRICTION : Vector2 = Vector2(1.2,1.0)
const UP_GRAVITY : Vector2 = Vector2(0,900)
const DOWN_GRAVITY : Vector2 = Vector2(0,1400)
const MAX_JUMP_FRAMES : int = 1000
const DASH_COOLDOWN : int = 20
const DASH_SPEED : float = 500



var direction : int = 1
var accumulated_velocity : Vector2 = Vector2.ZERO
var jumping : bool = false
var jump_frames : int = 0
var dashing_counter : int = -1

@onready var spawn_pos : Vector2 = get_node("../spawn").position
@onready var animated = $animated

func _ready() -> void:
	position = spawn_pos

func _physics_process(delta: float) -> void:
	if is_on_floor():
		accumulated_velocity.y = 0
	else:
		if accumulated_velocity.y > 0:
			accumulated_velocity += DOWN_GRAVITY * delta
		else:
			accumulated_velocity += UP_GRAVITY * delta
	
	if Input.is_action_just_pressed("JUMP") and is_on_floor():
		jumping = true
		jump_frames = 1
	
	if not Input.is_action_pressed("JUMP"):
		jumping = false
	
	if jumping and jump_frames < MAX_JUMP_FRAMES:
		accumulated_velocity.y += JUMP_VELOCITY / max((jump_frames-3)/2,1)
		jump_frames += 1
	
	var input_direction : float = Input.get_axis("LEFT", "RIGHT")
	accumulated_velocity.x += input_direction * SPEED * delta
	
	if dashing_counter >= 0:
		dashing_counter -= 1
	
	if Input.is_action_just_pressed("DASH") and dashing_counter < 0:
		dashing_counter = DASH_COOLDOWN
		if input_direction == 0:
			accumulated_velocity.x = direction*DASH_SPEED
		else:
			accumulated_velocity.x = input_direction*DASH_SPEED
	
	#Animation (replace with anim tree and player later)
	if abs(accumulated_velocity.x) > .2:
		if accumulated_velocity.x > 0:
			animated.play("Walk")
		else:
			animated.play_backwards("Walk")
	else:
		animated.play("Idle")
	
	if accumulated_velocity.x > 0:
		direction = 1
	else:
		direction = -1
		
	animated.scale.x = direction
	
	animated.speed_scale = accumulated_velocity.x/50
	
	accumulated_velocity /= FRICTION
	velocity = accumulated_velocity
	move_and_slide()

func died():
	position = spawn_pos
	return true
