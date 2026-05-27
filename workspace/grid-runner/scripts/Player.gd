extends CharacterBody2D

# Player script for Grid-Runner
# Handles grid-based movement

@export var speed: float = 400.0
@export var grid_size: int = 64

var target_position: Vector2
var is_moving: bool = false

func _ready():
	target_position = position
	add_to_group("player")

func _input(event):
	if is_moving:
		return
		
	var input_dir = Vector2.ZERO
	if event.is_action_pressed("ui_up"):
		input_dir = Vector2.UP
	elif event.is_action_pressed("ui_down"):
		input_dir = Vector2.DOWN
	elif event.is_action_pressed("ui_left"):
		input_dir = Vector2.LEFT
	elif event.is_action_pressed("ui_right"):
		input_dir = Vector2.RIGHT
		
	if input_dir != Vector2.ZERO:
		target_position = position + input_dir * grid_size
		is_moving = true

func _physics_process(_delta):
	if is_moving:
		var direction = (target_position - position).normalized()
		var distance = position.distance_to(target_position)
		
		if distance > 2.0:
			velocity = direction * speed
			move_and_slide()
		else:
			position = target_position
			velocity = Vector2.ZERO
			is_moving = false
