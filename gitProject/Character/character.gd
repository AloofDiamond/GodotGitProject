extends CharacterBody2D

const SPEED : float = 2000.0
const JUMP_VELOCITY : float = -40.0
const FRICTION : Vector2 = Vector2(1.2,1.0)
const UP_GRAVITY : Vector2 = Vector2(0,900)
const DOWN_GRAVITY : Vector2 = Vector2(0,1250)
const MAX_JUMP_TIME : float = 10.0
const JUMP_TIME_MULTIPLIER : float = 50.0
const DASH_COOLDOWN : int = 24

const DASH_ARRAY : Array[float] = [
	150,
	150,
	140,
	125,
	100,
	50,
	35,
	20,
	15
]

const JUMP_ARRAY : Array[float] = [
	-10,
	-10,
	-20,
	-30,
	-40,
	-40,
	-38,
	-36,
	-34,
	-32,
	-30,
	-28,
	-26,
	-25,
	-20,
	-15,
	-10,
	-10,
	0
]

var dash_frame : int = 0
var dashing : bool = false
var dash_direction : int = 0
var dashing_counter : int = -1

var direction : int = 1
var accumulated_velocity : Vector2 = Vector2.ZERO
var jumping : bool = false
var jump_time : float = 0


@onready var spawn_pos : Vector2 = get_node("../spawn").position
@onready var animated : AnimatedSprite2D = $animated

func _ready() -> void:
	position = spawn_pos

func _physics_process(delta: float) -> void:
	if is_on_wall():
		accumulated_velocity.x = 0
	
	if is_on_ceiling():
		accumulated_velocity.y = 1
		if jumping:
			jumping = false
			accumulated_velocity.y = -300
	
	if is_on_floor():
		accumulated_velocity.y = 0
	else:
		if accumulated_velocity.y > 0:
			accumulated_velocity += DOWN_GRAVITY * delta
		else:
			accumulated_velocity += UP_GRAVITY * delta
	
	if Input.is_action_just_pressed("JUMP") and is_on_floor():
		jump_time = 0
		jumping = true
	
	if Input.is_action_pressed("JUMP"):
		jump_time += delta
	else:
		jumping = false
	
	if jumping and jump_time < MAX_JUMP_TIME:
		var idx : float = jump_time * JUMP_TIME_MULTIPLIER
		if idx > JUMP_ARRAY.size()-1:
			idx = JUMP_ARRAY.size()-1
		
		accumulated_velocity.y += getValue(idx, JUMP_ARRAY)
	elif jumping:
		jumping = false
	
	var input_direction : float = Input.get_axis("LEFT", "RIGHT")
	accumulated_velocity.x += input_direction * SPEED * delta
	
	if dashing_counter >= 0:
		dashing_counter -= 1
	
	if Input.is_action_just_pressed("DASH") and dashing_counter < 0:
		dashing = true
		dashing_counter = DASH_COOLDOWN
		dash_frame = 0
		if input_direction == 0:
			dash_direction = direction
		else:
			dash_direction = input_direction
	
	if dashing and dash_frame < DASH_ARRAY.size()-1:
		dash_frame += 1
		accumulated_velocity.x += direction*DASH_ARRAY[dash_frame]
	
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

func getValue(fac:float, arr:Array[float]) -> float:
	if int(fac)+1 > arr.size()-1:
		return 0
	
	var first_val : float = arr[int(fac)]
	var second_val : float = arr[int(fac)+1]
	var factor : float = fac - int(fac)
	
	return lerp(first_val, second_val, factor)

func died():
	accumulated_velocity = Vector2.ZERO
	position = spawn_pos
	return true
