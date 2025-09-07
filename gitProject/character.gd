extends CharacterBody2D


const SPEED : float = 5000.0
const JUMP_VELOCITY : float = -40.0
const FRICTION : Vector2 = Vector2(1.75,1.0)
const UP_GRAVITY : Vector2 = Vector2(0,900)
const DOWN_GRAVITY : Vector2 = Vector2(0,1400)
const MAX_JUMP_FRAMES : int = 1000

var accumulated_velocity : Vector2 = Vector2.ZERO
var jumping : bool = false
var jump_frames : int = 0

@onready var animated = $Animated

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
	
	var direction : float = Input.get_axis("LEFT", "RIGHT")
	accumulated_velocity.x += direction * SPEED * delta
	
	if abs(accumulated_velocity.x) > .2:
		if accumulated_velocity.x > 0:
			animated.play("Walk")
		else:
			animated.play_backwards("Walk")
	else:
		animated.play("Idle")
	
	if accumulated_velocity.x > 0:
		animated.scale.x = 1
	else:
		animated.scale.x = -1
	
	animated.speed_scale = accumulated_velocity.x/50
	
	accumulated_velocity /= FRICTION
	velocity = accumulated_velocity
	move_and_slide()
