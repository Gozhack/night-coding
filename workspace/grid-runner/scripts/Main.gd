extends Node2D

# Main script for Grid-Runner
# Handles UI and game initialization

var game_over_label: Label
var menu_button: Button

func _ready():
	game_over_label = get_node_or_null("UI/Msg")
	menu_button = get_node_or_null("UI/MenuButton")

	if GridGameManager:
		GridGameManager.player_died.connect(_on_game_over)

	if menu_button:
		menu_button.pressed.connect(_on_menu_pressed)

func _on_game_over():
	if game_over_label:
		game_over_label.visible = true

func _on_menu_pressed():
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.location.href = '../index.html'")
	else:
		print("Back to Menu pressed (Desktop)")

