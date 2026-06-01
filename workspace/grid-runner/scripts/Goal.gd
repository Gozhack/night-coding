extends Area2D

# The goal cell to reach. Pulses; when the player overlaps it, scores and Main relocates it.

var _t: float = 0.0
var base_size: float = 48.0

func _ready():
	body_entered.connect(_on_body_entered)

func _process(delta):
	_t += delta
	queue_redraw()

func _draw():
	var s = base_size * (1.0 + sin(_t * 5.0) * 0.15)
	var r = Rect2(-s / 2.0, -s / 2.0, s, s)
	draw_rect(r, Color("#22ff88"))                      # glowing green
	draw_rect(r, Color("#aaffcc", 0.6), false, 3.0)     # halo border

func _on_body_entered(body):
	if body.is_in_group("player") or body.name == "Player":
		if GridGameManager:
			GridGameManager.reach_goal(global_position)
