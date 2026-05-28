extends Area2D

# Hazard script for Grid-Runner
# Detects collision with the player and handles optional patrol movement

@export var is_patrol: bool = false
@export var patrol_dir: Vector2 = Vector2.RIGHT
@export var patrol_distance: int = 2
@export var grid_size: int = 64
@export var move_speed: float = 1.0

var start_pos: Vector2

func _ready():
	body_entered.connect(_on_body_entered)
	start_pos = position
	
	if is_patrol:
		_start_patrol()

func _start_patrol():
	var target_pos = start_pos + (patrol_dir * patrol_distance * grid_size)
	var tween = create_tween().set_loops()
	tween.tween_property(self, "position", target_pos, move_speed).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position", start_pos, move_speed).set_trans(Tween.TRANS_SINE)

func _on_body_entered(body):
	if body.is_in_group("player") or body.name == "Player":
		if GridGameManager:
			GridGameManager.game_over()
