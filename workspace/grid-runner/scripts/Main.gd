extends Node2D

# Main script for Grid-Runner
# Handles UI and game initialization

var game_over_label: Label

func _ready():
	game_over_label = get_node_or_null("UI/GameOverLabel")
	
	if GridGameManager:
		GridGameManager.player_died.connect(_on_game_over)

func _on_game_over():
	if game_over_label:
		game_over_label.visible = true
