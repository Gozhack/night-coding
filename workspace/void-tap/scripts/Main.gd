extends Node2D

# Main script for Void-Tap
# Manages UI and game logic

var game_over_label: Label
var menu_button: Button

func _ready():
	game_over_label = get_node("UI/GameOverLabel")
	menu_button = get_node("UI/MenuButton")

	# Connect to the GameManager signal
	if VoidGameManager:
		VoidGameManager.player_died.connect(_on_game_over)
	
	if menu_button:
		menu_button.pressed.connect(_on_menu_pressed)

func _on_game_over():
	if game_over_label:
		game_over_label.visible = true

func _on_menu_pressed():
	# Use JavaScript to navigate back to the hub if running on Web
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.location.href = '../index.html'")
	else:
		print("Back to Menu pressed (Desktop)")
