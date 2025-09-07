extends Camera2D

signal die

@export var target : Node2D

var player_visible : bool = true

@onready var cam_area : Area2D = $camArea

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position = target.position
	cam_area.global_position = get_screen_center_position()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("character"):
		player_visible = true


func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("character"):
		player_visible = false
		print("wow")
		die.emit()
