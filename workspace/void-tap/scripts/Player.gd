extends CharacterBody2D

# Player for Void-Tap: smooth lerped movement, screen clamping, procedural drawing,
# and a shield power-up that absorbs one hit.

@export var speed: float = 800.0
@export var lerp_weight: float = 0.15

var target_position: Vector2
var screen_size: Vector2
var radius: float = 25.0
var trail: CPUParticles2D
var has_shield: bool = false

func _ready():
	screen_size = get_viewport_rect().size
	target_position = position
	add_to_group("player")
	_setup_trail()

func _setup_trail():
	trail = CPUParticles2D.new()
	add_child(trail)
	move_child(trail, 0)  # behind the player

	trail.amount = 20
	trail.lifetime = 0.5
	trail.explosiveness = 0.0
	trail.randomness = 0.5
	trail.local_coords = false
	trail.draw_order = CPUParticles2D.DRAW_ORDER_LIFETIME
	trail.spread = 180.0
	trail.gravity = Vector2.ZERO
	trail.initial_velocity_min = 10.0
	trail.initial_velocity_max = 30.0
	trail.scale_amount_min = 5.0
	trail.scale_amount_max = 10.0

	var gradient = Gradient.new()
	gradient.add_point(0.0, Color("#00ffcc"))
	gradient.add_point(1.0, Color("#00ffcc", 0.0))
	trail.color_ramp = gradient
	trail.emitting = true

	if has_node("ColorRect"):
		get_node("ColorRect").visible = false

func give_shield():
	has_shield = true
	queue_redraw()

# Returns true if a shield absorbed the hit (player survives), false otherwise.
func hit() -> bool:
	if has_shield:
		has_shield = false
		queue_redraw()
		return true
	return false

func _input(event):
	if event is InputEventScreenTouch and event.pressed:
		target_position = event.position
	elif event is InputEventScreenDrag:
		target_position = event.position
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		target_position = event.position

func _physics_process(_delta):
	screen_size = get_viewport_rect().size
	global_position = global_position.lerp(target_position, lerp_weight)
	global_position.x = clamp(global_position.x, radius, screen_size.x - radius)
	global_position.y = clamp(global_position.y, radius, screen_size.y - radius)

func _draw():
	draw_circle(Vector2.ZERO, radius, Color("#00ffcc"))
	draw_circle(Vector2.ZERO, radius * 0.7, Color("#aaffff", 0.5))
	if has_shield:
		draw_arc(Vector2.ZERO, radius + 10.0, 0.0, TAU, 28, Color("#ffcc33", 0.9), 3.0)
