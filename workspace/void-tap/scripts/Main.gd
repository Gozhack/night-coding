extends Node2D

# Main script for Void-Tap
# Manages UI and game logic

var game_over_label: Label

func _ready():
	game_over_label = get_node("UI/GameOverLabel")

	# Connect to the GameManager signal
	if VoidGameManager:
		VoidGameManager.player_died.connect(_on_game_over)

func _on_game_over():
	if game_over_label:
		game_over_label.visible = true
