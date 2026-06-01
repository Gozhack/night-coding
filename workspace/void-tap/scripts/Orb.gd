extends Area2D

# Collectible orb. Cyan = +points (risk/reward), golden = shield power-up.
# Falls from the top; the player grabs it by overlapping.

@export var is_shield: bool = false

var speed: float = 180.0
var radius: float = 20.0
var _t: float = 0.0

func _ready():
	body_entered.connect(_on_body_entered)
	if is_shield:
		speed = 140.0

func _physics_process(delta):
	if VoidGameManager and not VoidGameManager.is_playing:
		return
	_t += delta
	position.y += speed * delta
	queue_redraw()  # animate the pulse
	if position.y > get_viewport().get_visible_rect().size.y + 60:
		queue_free()

func _draw():
	var r = radius * (1.0 + sin(_t * 6.0) * 0.12)
	if is_shield:
		draw_circle(Vector2.ZERO, r, Color("#ffcc33"))
		draw_circle(Vector2.ZERO, r * 0.55, Color("#fff2b0"))
		draw_arc(Vector2.ZERO, r * 1.35, 0.0, TAU, 24, Color("#ffcc33", 0.5), 2.0)
	else:
		draw_circle(Vector2.ZERO, r, Color("#00ffcc"))
		draw_circle(Vector2.ZERO, r * 0.55, Color("#aaffff", 0.7))

func _on_body_entered(body):
	if not (body.is_in_group("player") or body.name == "Player"):
		return
	if is_shield:
		if body.has_method("give_shield"):
			body.give_shield()
		if VoidGameManager:
			VoidGameManager.grant_shield(global_position)
	elif VoidGameManager:
		VoidGameManager.add_points(5, global_position, "collect")
	queue_free()
