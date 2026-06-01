extends Node

# Void-Tap GameManager
# Score = survival time + collected bonus points. DIFFICULTY ramps on survival time only,
# so grabbing orbs (bonus points) doesn't distort the difficulty curve.

signal player_died
signal score_updated(score, high_score)
signal level_up(level)
signal effect(kind, world_pos)  # kind: "collect" | "shield" | "near_miss" | "death"

var is_playing: bool = false
var survival_time: float = 0.0
var bonus_points: int = 0
var high_score: int = 0
var difficulty_level: int = 1
var _last_tick: int = 0

const SAVE_PATH = "user://voidtap_highscore.save"

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	load_high_score()

func score() -> int:
	return int(survival_time) + bonus_points

func start_game():
	survival_time = 0.0
	bonus_points = 0
	difficulty_level = 1
	_last_tick = 0
	is_playing = true
	get_tree().paused = false
	score_updated.emit(0, high_score)
	level_up.emit(1)

func _process(delta):
	if is_playing and not get_tree().paused:
		survival_time += delta
		score_updated.emit(score(), high_score)

		var t = int(survival_time)
		if t > _last_tick:
			_last_tick = t
			if AudioManager:
				AudioManager.play_beep(880.0, 0.05)
			# Level up every 10 seconds survived.
			if t % 10 == 0:
				difficulty_level += 1
				level_up.emit(difficulty_level)
				if AudioManager:
					AudioManager.play_level_up(difficulty_level)

# Award bonus points (orbs, near-misses) and fire a visual/audio effect at world_pos.
func add_points(p: int, world_pos: Vector2, kind: String = "collect"):
	if not is_playing:
		return
	bonus_points += p
	score_updated.emit(score(), high_score)
	if AudioManager and kind == "collect":
		AudioManager.play_collect()
	effect.emit(kind, world_pos)

# Shield pickup: no points, just SFX + effect (the shield state lives on the Player).
func grant_shield(world_pos: Vector2):
	if AudioManager:
		AudioManager.play_shield()
	effect.emit("shield", world_pos)

# Fire a visual effect without points/SFX (e.g. an obstacle absorbed by a shield).
func notify_effect(kind: String, world_pos: Vector2):
	effect.emit(kind, world_pos)

func game_over():
	if not is_playing:
		return
	is_playing = false
	if AudioManager:
		AudioManager.play_death()
	if score() > high_score:
		high_score = score()
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
