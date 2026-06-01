extends Area2D

# Obstacle for Void-Tap: falls down, ends the run on contact (unless the player has a
# shield). Tracks its closest approach to award a near-miss bonus on a clean pass.

@export var base_min_speed: float = 250.0
@export var base_max_speed: float = 500.0

var speed: float
var size: Vector2 = Vector2(60, 30)
var _player: Node2D = null
var _closest: float = 99999.0
var _counted: bool = false

func _ready():
	var level = 1
	if VoidGameManager:
		level = VoidGameManager.difficulty_level
	var speed_multiplier = 1.0 + (level - 1) * 0.1
	speed = randf_range(base_min_speed, base_max_speed) * speed_multiplier
	# Slight size variety so the field feels less uniform.
	size = Vector2(randf_range(50.0, 82.0), randf_range(24.0, 40.0))

	body_entered.connect(_on_body_entered)
	_player = get_tree().get_first_node_in_group("player")

	if has_node("ColorRect"):
		get_node("ColorRect").visible = false

func _physics_process(delta):
	position.y += speed * delta
	if _player and is_instance_valid(_player) and not _counted:
		_closest = min(_closest, global_position.distance_to(_player.global_position))

	if position.y > get_viewport().get_visible_rect().size.y + 100:
		_award_near_miss()
		queue_free()

func _award_near_miss():
	if _counted:
		return
	_counted = true
	if _closest < 75.0 and VoidGameManager and VoidGameManager.is_playing:
		VoidGameManager.add_points(1, global_position, "near_miss")

func _draw():
	var rect = Rect2(-size / 2.0, size)
	draw_rect(rect, Color("#ff2244"))            # neon red
	draw_rect(rect, Color("#ffaaaa", 0.6), false, 2.0)  # glow border

func _on_body_entered(body):
	if not (body.is_in_group("player") or body.name == "Player"):
		return
	_counted = true  # contact -> no near-miss credit
	if body.has_method("hit") and body.hit():
		# Shield absorbed it: pop the obstacle with a shield flash, no death.
		if VoidGameManager:
			VoidGameManager.notify_effect("shield", global_position)
		queue_free()
	elif VoidGameManager:
		VoidGameManager.game_over()
