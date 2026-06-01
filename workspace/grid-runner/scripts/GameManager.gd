extends Node

# Grid-Runner GameManager: reach-the-goal arcade.
# Score = goals reached. Difficulty (hazard count) ramps in Main.

const CELL := 64
const MIN_X := 128
const MAX_X := 1024
const MIN_Y := 128
const MAX_Y := 512

signal player_died
signal score_updated(score)
signal goal_reached(world_pos)

var is_playing: bool = false
var score: int = 0
var high_score: int = 0

const SAVE_PATH = "user://gridrunner_highscore.save"

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	load_high_score()

func start_game():
	score = 0
	is_playing = true
	get_tree().paused = false
	score_updated.emit(0)

func reach_goal(world_pos: Vector2):
	if not is_playing:
		return
	score += 1
	score_updated.emit(score)
	if AudioManager:
		AudioManager.play_goal()
	goal_reached.emit(world_pos)

func game_over():
	if not is_playing:
		return
	is_playing = false
	if AudioManager:
		AudioManager.play_death()
	if score > high_score:
		high_score = score
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
