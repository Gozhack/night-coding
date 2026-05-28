extends Node

# Void-Tap GameManager (MVP Version)
# Handles game state, scoring, difficulty scaling, and high score persistence

signal player_died
signal score_updated(score, high_score)
signal level_up(level)

var is_playing: bool = false
var current_score: float = 0.0
var high_score: int = 0
var difficulty_level: int = 1
var last_beep_score: int = 0

const SAVE_PATH = "user://voidtap_highscore.save"

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	load_high_score()

func start_game():
	current_score = 0.0
	difficulty_level = 1
	last_beep_score = 0
	is_playing = true
	get_tree().paused = false
	score_updated.emit(0, high_score)
	level_up.emit(1)

func _process(delta):
	if is_playing and not get_tree().paused:
		current_score += delta
		
		# Update score HUD
		score_updated.emit(int(current_score), high_score)
		
		# Survival Beep every second
		if int(current_score) > last_beep_score:
			last_beep_score = int(current_score)
			if AudioManager:
				AudioManager.play_beep(880, 0.05)
			
			# Check for level up every 10 seconds
			if last_beep_score % 10 == 0:
				difficulty_level += 1
				level_up.emit(difficulty_level)
				if AudioManager:
					AudioManager.play_level_up(difficulty_level)

func game_over():
	if not is_playing:
		return

	is_playing = false
	if AudioManager:
		AudioManager.play_death()
	
	if int(current_score) > high_score:
		high_score = int(current_score)
		save_high_score()
	
	player_died.emit()
	get_tree().paused = true

func save_high_score():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_32(high_score)

func load_high_score():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			high_score = file.get_32()
