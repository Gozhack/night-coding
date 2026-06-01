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
	# UI References (with null checks for safety)
	start_menu = get_node_or_null("UI/StartMenu")
	hud = get_node_or_null("UI/HUD")
	game_over_screen = get_node_or_null("UI/GameOverScreen")
	score_label = get_node_or_null("UI/HUD/ScoreLabel")
	level_label = get_node_or_null("UI/HUD/LevelLabel")
	final_score_label = get_node_or_null("UI/GameOverScreen/FinalScoreLabel")
	high_score_label = get_node_or_null("UI/GameOverScreen/HighScoreLabel")
	
	spawner = get_node_or_null("Spawner")
	camera = get_node_or_null("Camera2D")
	
	# Failsafe: If essential nodes are missing, don't initialize the game.
	# This avoids crashes on start. The screen will be blank if something is wrong.
	if not start_menu or not hud or not game_over_screen or not spawner or not camera:
		print("CRITICAL ERROR: One or more essential nodes are missing in Main.tscn.")
		return

	# Initial State
	start_menu.visible = true
	hud.visible = false
	game_over_screen.visible = false
	get_tree().paused = true
	
	# Start Menu Animations (VT-02)
	_setup_start_menu_animations()
	
	# Signal connections live in _setup_start_menu_animations() below.

func _setup_start_menu_animations():
	var play_button = get_node_or_null("UI/StartMenu/PlayButton")
	var title = get_node_or_null("UI/StartMenu/Title")
	
	if play_button:
		# Signal connection is handled in Main.tscn
		var tween = create_tween().set_loops()
		tween.tween_property(play_button, "scale", Vector2(1.1, 1.1), 0.6).set_trans(Tween.TRANS_SINE)
		tween.tween_property(play_button, "scale", Vector2(1.0, 1.0), 0.6).set_trans(Tween.TRANS_SINE)
		play_button.pivot_offset = play_button.size / 2
		
	if title:
		var tween = create_tween().set_loops()
		tween.tween_property(title, "position:y", title.position.y - 10, 1.5).set_trans(Tween.TRANS_SINE)
		tween.tween_property(title, "position:y", title.position.y, 1.5).set_trans(Tween.TRANS_SINE)
	if VoidGameManager:
		VoidGameManager.player_died.connect(_on_player_died)
		VoidGameManager.score_updated.connect(_on_score_updated)
		VoidGameManager.level_up.connect(_on_level_up)
		VoidGameManager.effect.connect(_on_effect)
	
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

	# Camera Shake logic (VT-06)
	if shake_intensity > 0:
		# Use a noise-like approach for more organic shake
		camera.offset = Vector2(
			randf_range(-1.0, 1.0) * shake_intensity,
			randf_range(-1.0, 1.0) * shake_intensity
		)
		shake_intensity = lerp(shake_intensity, 0.0, shake_decay * delta)
		if shake_intensity < 0.1:
			shake_intensity = 0.0
			camera.offset = Vector2.ZERO
	else:
		camera.offset = Vector2.ZERO

func _on_play_pressed():
	# Failsafe checks for nodes
	if start_menu:
		start_menu.visible = false
	if hud:
		hud.visible = true
	if game_over_screen:
		game_over_screen.visible = false

	# Ensure audio starts after user gesture (VT-04)
	if AudioManager:
		AudioManager.resume_audio()

	# This is a global singleton, should be safe
	VoidGameManager.start_game()

	if spawner:
		spawner.start_spawning()
	else:
		print("ERROR: Spawner node not found, cannot start spawning obstacles.")

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
	var player = get_node_or_null("Player")
	if player:
		_burst(player.global_position, Color("#ff2244"), 40)
	var final_score = VoidGameManager.score()
	final_score_label.text = "SCORE: " + str(final_score)
	
	if final_score >= VoidGameManager.high_score:
		high_score_label.text = "NEW BEST: " + str(final_score)
		high_score_label.modulate = Color("#00ffff") # Cyan highlight
	else:
		high_score_label.text = "BEST: " + str(VoidGameManager.high_score)
		high_score_label.modulate = Color.WHITE
		
	spawner.stop_spawning()
	
	# Trigger Shake
	shake_intensity = 15.0

func _on_score_updated(score, _high_score):
	score_label.text = "VOID: " + str(score)

func _on_level_up(level):
	level_label.text = "LEVEL: " + str(level)
	
	# Visual announcement (VT-03)
	var announcement = Label.new()
	announcement.text = "LEVEL " + str(level)
	announcement.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	announcement.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	announcement.add_theme_font_size_override("font_size", 64)
	announcement.modulate = Color("#00ffff") # Cyan
	
	# Center it on screen
	var screen_size = get_viewport().get_visible_rect().size
	announcement.position = (screen_size / 2) - Vector2(200, 50) # Approx center
	
	add_child(announcement)
	
	# Animate and remove
	var tween = create_tween()
	tween.tween_property(announcement, "scale", Vector2(1.5, 1.5), 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(announcement, "modulate:a", 0.0, 1.0).set_delay(1.0)
	tween.tween_callback(announcement.queue_free)

func _on_menu_pressed():
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.location.href = '../index.html'")
	else:
		get_tree().quit()

# --- Juice (orbs, shields, near-misses, death) ---

func _on_effect(kind: String, world_pos: Vector2):
	match kind:
		"collect":
			_burst(world_pos, Color("#00ffcc"), 16)
			_popup("+5", world_pos, Color("#00ffcc"))
		"shield":
			_burst(world_pos, Color("#ffcc33"), 24)
			_popup("SHIELD", world_pos, Color("#ffcc33"))
		"near_miss":
			_popup("+1", world_pos, Color("#aaffff"))

func _burst(pos: Vector2, color: Color, amount: int = 18):
	var p = CPUParticles2D.new()
	p.process_mode = Node.PROCESS_MODE_ALWAYS  # play even during the game-over pause
	p.position = pos
	p.emitting = true
	p.one_shot = true
	p.explosiveness = 1.0
	p.amount = amount
	p.lifetime = 0.5
	p.spread = 180.0
	p.gravity = Vector2.ZERO
	p.initial_velocity_min = 80.0
	p.initial_velocity_max = 220.0
	p.scale_amount_min = 2.0
	p.scale_amount_max = 5.0
	var g = Gradient.new()
	g.add_point(0.0, color)
	g.add_point(1.0, Color(color.r, color.g, color.b, 0.0))
	p.color_ramp = g
	add_child(p)
	get_tree().create_timer(1.0).timeout.connect(p.queue_free)

func _popup(text: String, pos: Vector2, color: Color):
	var l = Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", 28)
	l.modulate = color
	l.z_index = 100
	l.position = pos - Vector2(20, 20)
	add_child(l)
	var tw = create_tween()
	tw.tween_property(l, "position:y", l.position.y - 50.0, 0.7)
	tw.parallel().tween_property(l, "modulate:a", 0.0, 0.7)
	tw.tween_callback(l.queue_free)
