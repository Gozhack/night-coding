extends Node2D

# Spawner for Void-Tap: drops obstacles (faster with difficulty) and collectible orbs.

@export var obstacle_scene: PackedScene
@export var orb_scene: PackedScene
@export var base_spawn_rate: float = 1.0

var spawn_timer: Timer
var orb_timer: Timer

func _ready():
	spawn_timer = Timer.new()
	add_child(spawn_timer)
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)

	orb_timer = Timer.new()
	add_child(orb_timer)
	orb_timer.timeout.connect(_on_orb_timer_timeout)

	if VoidGameManager:
		VoidGameManager.level_up.connect(_on_level_up)

func _on_level_up(level):
	# Faster spawning as the level rises (Level 1: 1.0s, Level 5: ~0.66s).
	var new_rate = base_spawn_rate * pow(0.9, level - 1)
	spawn_timer.wait_time = max(0.2, new_rate)
	if VoidGameManager and VoidGameManager.is_playing:
		spawn_timer.start()

func start_spawning():
	_on_level_up(VoidGameManager.difficulty_level)
	spawn_timer.start()
	orb_timer.wait_time = randf_range(2.2, 3.4)
	orb_timer.start()

func stop_spawning():
	spawn_timer.stop()
	orb_timer.stop()

func _on_spawn_timer_timeout():
	if not obstacle_scene or (VoidGameManager and not VoidGameManager.is_playing):
		return
	var obstacle = obstacle_scene.instantiate()
	var vw = get_viewport().get_visible_rect().size.x
	obstacle.position = Vector2(randf_range(50.0, vw - 50.0), -50.0)
	get_parent().add_child(obstacle)

func _on_orb_timer_timeout():
	if not orb_scene or (VoidGameManager and not VoidGameManager.is_playing):
		return
	var orb = orb_scene.instantiate()
	orb.is_shield = randf() < 0.16  # ~1 in 6 orbs is a shield
	var vw = get_viewport().get_visible_rect().size.x
	orb.position = Vector2(randf_range(60.0, vw - 60.0), -40.0)
	get_parent().add_child(orb)
	orb_timer.wait_time = randf_range(2.2, 3.6)
