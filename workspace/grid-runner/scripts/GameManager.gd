extends Node

# GridRunner GameManager
# Handles game state, scoring, and high score persistence

signal player_died
signal score_updated(score)

var is_playing: bool = false
var current_score: int = 0
var high_score: int = 0

const SAVE_PATH = "user://gridrunner_highscore.save"

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	load_high_score()

func start_game():
	is_playing = true
	current_score = 0
	get_tree().paused = false
	score_updated.emit(0)
	print("Grid Runner: Game Started!")

func add_score(points: int = 1):
	if is_playing:
		current_score += points
		score_updated.emit(current_score)

func game_over():
	if not is_playing:
		return
	
	is_playing = false
	print("Grid Runner: Game Over!")
	
	if current_score > high_score:
		high_score = current_score
		save_high_score()
	
	player_died.emit()
	get_tree().paused = true
	
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 2.0
	timer.one_shot = true
	timer.process_mode = Node.PROCESS_MODE_ALWAYS
	
	timer.timeout.connect(func():
		get_tree().paused = false
		get_tree().reload_current_scene()
	)
	
	timer.start()

func save_high_score():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_32(high_score)

func load_high_score():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			high_score = file.get_32()
