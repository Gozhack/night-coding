extends Area2D

# Obstacle script for Void-Tap MVP
# Features: Progressive speed, procedural neon visuals

@export var base_min_speed: float = 250.0
@export var base_max_speed: float = 500.0

var speed: float
var size: Vector2 = Vector2(60, 30)

func _ready():
	# Scale speed based on difficulty level
	var level = 1
	if VoidGameManager:
		level = VoidGameManager.difficulty_level
	
	var speed_multiplier = 1.0 + (level - 1) * 0.1
	speed = randf_range(base_min_speed, base_max_speed) * speed_multiplier
	
	# Connect collision signal
	body_entered.connect(_on_body_entered)
	
	# Hide existing ColorRect if it exists
	if has_node("ColorRect"):
		get_node("ColorRect").visible = false

func _physics_process(delta):
	# Move downward
	position.y += speed * delta

	# Delete if it goes off-screen (dynamic based on viewport)
	var screen_height = get_viewport_rect().size.y
	if position.y > screen_height + 100:
		queue_free()
func _draw():
	# Draw neon red rectangle
	# Using rect with offset to center it
	var rect = Rect2(-size/2, size)
	draw_rect(rect, Color("#ff2244")) # Neon Red
	# Border for glow effect
	draw_rect(rect, Color("#ffaaaa", 0.6), false, 2.0)

func _on_body_entered(body):
	if body.is_in_group("player") or body.name == "Player":
		if VoidGameManager:
			VoidGameManager.game_over()
