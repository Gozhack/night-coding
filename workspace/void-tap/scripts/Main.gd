extends Node2D

# Void-Tap Main Orchestrator
# Handles UI transitions, screen shake, and shader setup

var start_menu: Control
var hud: Control
var game_over_screen: Control
var score_label: Label
var high_score_label: Label
var level_label: Label
var final_score_label: Label
var spawner: Node2D
var camera: Camera2D

var shake_intensity: float = 0.0
var shake_decay: float = 5.0

func _ready():
	# UI References
	start_menu = get_node("UI/StartMenu")
	hud = get_node("UI/HUD")
	game_over_screen = get_node("UI/GameOverScreen")
	score_label = get_node("UI/HUD/ScoreLabel")
	level_label = get_node("UI/HUD/LevelLabel")
	final_score_label = get_node("UI/GameOverScreen/FinalScoreLabel")
	high_score_label = get_node("UI/GameOverScreen/HighScoreLabel")
	
	spawner = get_node("Spawner")
	camera = get_node("Camera2D")
	
	# Initial State
	start_menu.visible = true
	hud.visible = false
	game_over_screen.visible = false
	get_tree().paused = true
	
	# Signal Connections
	if VoidGameManager:
		VoidGameManager.player_died.connect(_on_player_died)
		VoidGameManager.score_updated.connect(_on_score_updated)
		VoidGameManager.level_up.connect(_on_level_up)
	
	# Set Background to solid black (as requested by Gozhack)
	var bg = get_node("Background")
	bg.material = null # Remove any shader material
	# Assuming 'Background' is a ColorRect or similar node with a 'color' property
	if bg is ColorRect:
		bg.color = Color("#0a0a0a")
	else:
		# Fallback if not ColorRect - try to set color if possible, or leave a note
		# This might require checking node type in editor for full certainty
		pass # No direct way to set color for generic Node2D without explicit property
		# Gozhack, si el fondo sigue blanco, puede que 'Background' no sea un ColorRect directamente.


func _process(delta):
	# Keep background filling the screen
	get_node("Background").size = get_viewport().get_visible_rect().size

	# Camera Shake logic

	if shake_intensity > 0:
		camera.offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * shake_intensity
		shake_intensity = move_toward(shake_intensity, 0, shake_decay * delta)
	else:
		camera.offset = Vector2.ZERO

func _on_play_pressed():
	start_menu.visible = false
	hud.visible = true
	game_over_screen.visible = false
	VoidGameManager.start_game()
	spawner.start_spawning()

func _on_restart_pressed():
	# Clear existing obstacles
	for child in get_children():
		if child.is_in_group("obstacle") or child is Area2D: # Simple check
			child.queue_free()
	
	game_over_screen.visible = false
	hud.visible = true
	VoidGameManager.start_game()
	spawner.start_spawning()

func _on_player_died():
	hud.visible = false
	game_over_screen.visible = true
	final_score_label.text = "SCORE: " + str(int(VoidGameManager.current_score))
	high_score_label.text = "BEST: " + str(VoidGameManager.high_score)
	spawner.stop_spawning()
	
	# Trigger Shake
	shake_intensity = 15.0

func _on_score_updated(score, _high_score):
	score_label.text = "VOID: " + str(score)

func _on_level_up(level):
	level_label.text = "LEVEL: " + str(level)

func _on_menu_pressed():
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.location.href = '../index.html'")
	else:
		get_tree().quit()
