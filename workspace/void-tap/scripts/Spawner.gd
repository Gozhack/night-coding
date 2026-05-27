extends Node2D

# Spawner script for Void-Tap MVP
# Features: Dynamic spawn rate based on difficulty level

@export var obstacle_scene: PackedScene
@export var base_spawn_rate: float = 1.0

var spawn_timer: Timer

func _ready():
	spawn_timer = Timer.new()
	add_child(spawn_timer)
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	
	if VoidGameManager:
		VoidGameManager.level_up.connect(_on_level_up)

func _on_level_up(level):
	# Decrease spawn rate as level increases (faster spawning)
	# Level 1: 1.0s, Level 5: ~0.6s, etc.
	var new_rate = base_spawn_rate * pow(0.9, level - 1)
	spawn_timer.wait_time = max(0.2, new_rate)
	if VoidGameManager.is_playing:
		spawn_timer.start()

func start_spawning():
	_on_level_up(VoidGameManager.difficulty_level)
	spawn_timer.start()

func stop_spawning():
	spawn_timer.stop()

func _on_spawn_timer_timeout():
	if not obstacle_scene or (VoidGameManager and not VoidGameManager.is_playing):
		return

	var obstacle = obstacle_scene.instantiate()

	# Randomized X position based on current viewport width
	var viewport_size = get_viewport_rect().size
	var spawn_x = randf_range(50, viewport_size.x - 50)
	obstacle.position = Vector2(spawn_x, -50)

	# Add to main scene so it doesn't move with the spawner
	get_parent().add_child(obstacle)

