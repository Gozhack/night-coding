extends Area2D

# Hazard script for Grid-Runner
# Detects collision with the player

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player") or body.name == "Player":
		if GridGameManager:
			GridGameManager.game_over()
