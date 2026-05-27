extends Node2D

# Spawner script for Void-Tap
# Spawns obstacles at a fixed rate

@export var obstacle_scene: PackedScene
@export var spawn_rate: float = 1.0

var spawn_timer: Timer

func _ready():
	spawn_timer = Timer.new()
	add_child(spawn_timer)
	spawn_timer.wait_time = spawn_rate
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()

func _on_spawn_timer_timeout():
	if not obstacle_scene or (VoidGameManager and not VoidGameManager.is_playing):
		return
	
	var obstacle = obstacle_scene.instantiate()
	
	# Randomized X position based on standard width 1152
	var spawn_x = randf_range(50, 1100)
	obstacle.position = Vector2(spawn_x, -50)
	
	get_parent().add_child(obstacle)
