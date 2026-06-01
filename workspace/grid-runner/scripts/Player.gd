extends CharacterBody2D

# Grid-based movement. Snaps cell-by-cell, clamped to the play area (so the boundary
# walls don't kill you — only the red hazards do). Keyboard + touch/mouse swipe.

@export var speed: float = 400.0
@export var grid_size: int = 64

var target_position: Vector2
var is_moving: bool = false

const SWIPE_THRESHOLD: float = 40.0
var _swipe_start: Vector2 = Vector2.ZERO
var _swiping: bool = false

func _ready():
	target_position = position
	add_to_group("player")

func _input(event):
	if is_moving:
		return

	var input_dir = Vector2.ZERO
	if event.is_action_pressed("ui_up"):
		input_dir = Vector2.UP
	elif event.is_action_pressed("ui_down"):
		input_dir = Vector2.DOWN
	elif event.is_action_pressed("ui_left"):
		input_dir = Vector2.LEFT
	elif event.is_action_pressed("ui_right"):
		input_dir = Vector2.RIGHT
	else:
		input_dir = _handle_swipe(event)

	if input_dir == Vector2.ZERO:
		return

	var t = position + input_dir * grid_size
	# Clamp to the play area so we never step onto the boundary walls.
	t.x = clamp(t.x, GridGameManager.MIN_X, GridGameManager.MAX_X)
	t.y = clamp(t.y, GridGameManager.MIN_Y, GridGameManager.MAX_Y)
	if t != position:
		target_position = t
		is_moving = true
		if AudioManager:
			AudioManager.play_move()

func _handle_swipe(event) -> Vector2:
	var pos = Vector2.ZERO
	var pressed = false
	if event is InputEventScreenTouch:
		pos = event.position
		pressed = event.pressed
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		pos = event.position
		pressed = event.pressed
	else:
		return Vector2.ZERO

	if pressed:
		_swipe_start = pos
		_swiping = true
		return Vector2.ZERO

	if _swiping:
		_swiping = false
		var delta = pos - _swipe_start
		if delta.length() < SWIPE_THRESHOLD:
			return Vector2.ZERO
		if abs(delta.x) > abs(delta.y):
			return Vector2.RIGHT if delta.x > 0 else Vector2.LEFT
		return Vector2.DOWN if delta.y > 0 else Vector2.UP

	return Vector2.ZERO

func _physics_process(delta):
	if not is_moving:
		return
	var step = speed * delta
	if position.distance_to(target_position) <= step:
		position = target_position
		velocity = Vector2.ZERO
		is_moving = false
	else:
		velocity = (target_position - position).normalized() * speed
		move_and_slide()
