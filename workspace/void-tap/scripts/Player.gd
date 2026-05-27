extends CharacterBody2D

# Player script for Void-Tap
# Handles touch/mouse movement

@export var speed: float = 400.0

var target_position: Vector2
var is_moving: bool = false

func _ready():
	# Start at the current position
	target_position = position
	# Add to group for easier collision detection
	add_to_group("player")

func _input(event):
	if event is InputEventScreenTouch and event.pressed:
		target_position = event.position
		is_moving = true
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		target_position = event.position
		is_moving = true

func _physics_process(_delta):
	if is_moving:
		var direction = (target_position - global_position).normalized()
		var distance = global_position.distance_to(target_position)
		
		if distance > 5.0:
			velocity = direction * speed
			move_and_slide()
		else:
			velocity = Vector2.ZERO
			is_moving = false
