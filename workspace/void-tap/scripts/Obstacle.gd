extends Area2D

# Obstacle script for Void-Tap
# Moves downward and detects collision with the player

@export var min_speed: float = 200.0
@export var max_speed: float = 500.0

var speed: float

func _ready():
	# Randomized speed
	speed = randf_range(min_speed, max_speed)
	
	# Connect collision signal
	body_entered.connect(_on_body_entered)

func _physics_process(delta):
	# Move downward
	position.y += speed * delta
	
	# Delete if it goes off-screen
	if position.y > 750:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("player") or body.name == "Player":
		# Notify GameManager
		if VoidGameManager:
			VoidGameManager.game_over()
