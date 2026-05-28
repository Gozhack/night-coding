extends Node2D

# Main script for Grid-Runner
# Handles dynamic UI creation and game orchestration

var start_menu: CanvasLayer
var game_over_label: Label
var score_label: Label

func _ready():
	_create_ui()
	
	if GridGameManager:
		GridGameManager.player_died.connect(_on_game_over)
		GridGameManager.score_updated.connect(_on_score_updated)
	
	# Initial State
	get_tree().paused = true

func _create_ui():
	# Root UI Layer
	start_menu = CanvasLayer.new()
	add_child(start_menu)
	
	# Background dim
	var bg = ColorRect.new()
	bg.name = "Background"
	bg.color = Color(0, 0, 0, 0.7)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	start_menu.add_child(bg)
	
	# Title
	var title = Label.new()
	title.name = "Title"
	title.text = "GRID RUNNER"
	title.add_theme_font_size_override("font_size", 80)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	title.position.y = 150
	title.modulate = Color("#38bdf8") # Cyan
	start_menu.add_child(title)
	
	# Pulse animation for title
	var t_tween = create_tween().set_loops()
	t_tween.tween_property(title, "scale", Vector2(1.05, 1.05), 1.0).set_trans(Tween.TRANS_SINE)
	t_tween.tween_property(title, "scale", Vector2(1.0, 1.0), 1.0).set_trans(Tween.TRANS_SINE)
	title.pivot_offset = Vector2(250, 50) # Approx center
	
	# Play Button
	var play_btn = Button.new()
	play_btn.name = "PlayButton"
	play_btn.text = "START RUN"
	play_btn.custom_minimum_size = Vector2(250, 80)
	play_btn.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	play_btn.pressed.connect(_on_play_pressed)
	start_menu.add_child(play_btn)
	
	# Pulse animation for button
	var b_tween = create_tween().set_loops()
	b_tween.tween_property(play_btn, "scale", Vector2(1.1, 1.1), 0.5).set_trans(Tween.TRANS_SINE)
	b_tween.tween_property(play_btn, "scale", Vector2(1.0, 1.0), 0.5).set_trans(Tween.TRANS_SINE)
	play_btn.pivot_offset = Vector2(125, 40)

	# Score Label (HUD)
	score_label = Label.new()
	score_label.name = "ScoreLabel"
	score_label.text = "RUN: 0"
	score_label.add_theme_font_size_override("font_size", 40)
	score_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	score_label.position = Vector2(20, 20)
	score_label.visible = false
	start_menu.add_child(score_label)

	# Game Over Label (Hidden initially)
	game_over_label = Label.new()
	game_over_label.name = "GameOverLabel"
	game_over_label.text = "GLITCHED!"
	game_over_label.add_theme_font_size_override("font_size", 100)
	game_over_label.modulate = Color("#ef4444") # Red
	game_over_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	game_over_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	game_over_label.visible = false
	start_menu.add_child(game_over_label)

func _on_play_pressed():
	start_menu.get_node("Background").visible = false
	start_menu.get_node("Title").visible = false
	start_menu.get_node("PlayButton").visible = false
	score_label.visible = true
	if GridGameManager:
		GridGameManager.start_game()

func _on_score_updated(score):
	score_label.text = "RUN: " + str(score)

func _on_game_over():
	var score = GridGameManager.current_score
	var high = GridGameManager.high_score
	
	if score >= high and score > 0:
		game_over_label.text = "GLITCHED!\nNEW BEST: " + str(score)
		game_over_label.modulate = Color("#00ffff") # Cyan
	else:
		game_over_label.text = "GLITCHED!\nSCORE: " + str(score) + "\nBEST: " + str(high)
		game_over_label.modulate = Color("#ef4444") # Red
	
	game_over_label.visible = true

func _on_menu_pressed():
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.location.href = '../index.html'")
	else:
		get_tree().quit()
