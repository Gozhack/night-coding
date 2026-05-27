extends Node

# VoidTap GameManager
# Handles game state and singleton instance

signal player_died

var instance = null
var is_playing: bool = true

func _ready():
	instance = self
	# Set process mode to always so the timer works when paused
	process_mode = Node.PROCESS_MODE_ALWAYS

func game_over():
	if not is_playing:
		return

	is_playing = false
	player_died.emit()
	print("Game Over!")

	# Reload the scene after a brief delay
	get_tree().paused = true
	
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 2.0
	timer.one_shot = true
	timer.process_mode = Node.PROCESS_MODE_ALWAYS
	
	timer.timeout.connect(func():
		get_tree().paused = false
		get_tree().reload_current_scene()
		is_playing = true
	)
	
	timer.start()
