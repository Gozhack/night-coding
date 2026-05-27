extends CharacterBody2D

# Player script for Void-Tap MVP
# Features: Smooth movement (lerp), screen clamping, and procedural drawing

@export var speed: float = 800.0
@export var lerp_weight: float = 0.15

var target_position: Vector2
var screen_size: Vector2
var radius: float = 25.0

func _ready():
	screen_size = get_viewport_rect().size
	target_position = position
	add_to_group("player")
	
	# Hide the existing ColorRect if it exists (we'll draw our own)
	if has_node("ColorRect"):
		get_node("ColorRect").visible = false

func _input(event):
	if event is InputEventScreenTouch and event.pressed:
		target_position = event.position
	elif event is InputEventScreenDrag:
		target_position = event.position
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		target_position = event.position

func _physics_process(_delta):
	# Smoothly move towards target
	global_position = global_position.lerp(target_position, lerp_weight)
	
	# Clamp to screen boundaries
	global_position.x = clamp(global_position.x, radius, screen_size.x - radius)
	global_position.y = clamp(global_position.y, radius, screen_size.y - radius)

func _draw():
	# Draw the "Cyan/Jade" circle
	draw_circle(Vector2.ZERO, radius, Color("#00ffcc")) # Cyan-Jade Neon
	# Inner glow effect (subtle)
	draw_circle(Vector2.ZERO, radius * 0.7, Color("#aaffff", 0.5))
