extends Node2D

# Grid-Runner: reach-the-goal arcade. Navigate to the green goal, avoid the red hazards.
# Each goal reached relocates the goal and (every 3) spawns another patrolling hazard.

const HAZARD = preload("res://scenes/Hazard.tscn")
const GOAL = preload("res://scenes/Goal.tscn")

var ui: CanvasLayer
var menu: Control
var hud: Control
var over_panel: Control
var score_label: Label
var final_label: Label
var player: CharacterBody2D
var goal: Area2D = null
var hazards: Array = []

func _ready():
	player = get_node("Player")
	_build_ui()
	if GridGameManager:
		GridGameManager.score_updated.connect(_on_score)
		GridGameManager.goal_reached.connect(_on_goal)
		GridGameManager.player_died.connect(_on_died)
	get_tree().paused = true

# ---------- UI (built in code) ----------

func _build_ui():
	ui = CanvasLayer.new()
	add_child(ui)

	# --- Start menu ---
	menu = Control.new()
	menu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui.add_child(menu)

	var dim = ColorRect.new()
	dim.color = Color(0, 0, 0, 0.65)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu.add_child(dim)

	_centered_label(menu, "GRID RUNNER", 76, Color("#38bdf8"), Vector2(-250, 110), Vector2(500, 95))
	_centered_label(menu, "Desliza o usa las flechas para moverte\nLlega al cuadro VERDE\nEsquiva los enemigos ROJOS", 24, Color("#cfe8ff"), Vector2(-300, -50), Vector2(600, 120))

	var play = _make_button("START", Vector2(240, 76), Vector2(-120, 130))
	play.pressed.connect(_on_play)
	menu.add_child(play)

	# --- HUD ---
	hud = Control.new()
	hud.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.visible = false
	ui.add_child(hud)

	score_label = Label.new()
	score_label.text = "GOALS: 0"
	score_label.add_theme_font_size_override("font_size", 36)
	score_label.position = Vector2(24, 18)
	hud.add_child(score_label)

	var back = _make_button("← Menu", Vector2(140, 44), Vector2(0, 0))
	back.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	back.position = Vector2(-156, 18)
	back.pressed.connect(_on_menu)
	hud.add_child(back)

	# --- Game over ---
	over_panel = Control.new()
	over_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	over_panel.visible = false
	ui.add_child(over_panel)

	var odim = ColorRect.new()
	odim.color = Color(0, 0, 0, 0.7)
	odim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	over_panel.add_child(odim)

	_centered_label(over_panel, "GLITCHED!", 84, Color("#ef4444"), Vector2(-300, 130), Vector2(600, 100))
	final_label = _centered_label(over_panel, "", 32, Color.WHITE, Vector2(-300, -10), Vector2(600, 70))

	var rbtn = _make_button("RESTART", Vector2(220, 64), Vector2(-110, 80))
	rbtn.pressed.connect(_on_play)
	over_panel.add_child(rbtn)

	var mbtn = _make_button("BACK TO MENU", Vector2(220, 56), Vector2(-110, 160))
	mbtn.pressed.connect(_on_menu)
	over_panel.add_child(mbtn)

func _centered_label(parent: Control, text: String, size: int, color: Color, off: Vector2, dims: Vector2) -> Label:
	var l = Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.modulate = color
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	l.position = off
	l.size = dims
	parent.add_child(l)
	return l

func _make_button(text: String, dims: Vector2, off: Vector2) -> Button:
	var b = Button.new()
	b.text = text
	b.custom_minimum_size = dims
	b.process_mode = Node.PROCESS_MODE_ALWAYS  # clickable while the tree is paused
	b.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	b.position = off
	return b

# ---------- Flow ----------

func _on_play():
	menu.visible = false
	over_panel.visible = false
	hud.visible = true
	_reset_round()
	GridGameManager.start_game()

func _reset_round():
	for h in hazards:
		if is_instance_valid(h):
			h.queue_free()
	hazards.clear()
	if goal and is_instance_valid(goal):
		goal.queue_free()
		goal = null
	player.position = Vector2(576, 320)
	player.target_position = player.position
	player.is_moving = false
	_spawn_goal()
	_spawn_hazard()
	_spawn_hazard()

func _on_score(s):
	score_label.text = "GOALS: " + str(s)

func _on_goal(world_pos):
	_popup("+1", world_pos, Color("#22ff88"))
	_burst(world_pos, Color("#22ff88"), 18)
	_spawn_goal()
	if GridGameManager.score % 3 == 0 and hazards.size() < 9:
		_spawn_hazard()

func _on_died():
	var s = GridGameManager.score
	var hi = GridGameManager.high_score
	if s >= hi and s > 0:
		final_label.text = "NEW BEST: " + str(s)
		final_label.modulate = Color("#22ff88")
	else:
		final_label.text = "GOALS: " + str(s) + "    BEST: " + str(hi)
		final_label.modulate = Color.WHITE
	_burst(player.global_position, Color("#ef4444"), 36)
	over_panel.visible = true
	hud.visible = false

func _on_menu():
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.location.href = '../index.html'")
	else:
		get_tree().quit()

# ---------- Spawning ----------

func _spawn_goal():
	if goal and is_instance_valid(goal):
		goal.queue_free()
	goal = GOAL.instantiate()
	goal.position = _free_cell()
	add_child(goal)

func _spawn_hazard():
	var h = HAZARD.instantiate()
	h.position = _free_cell()
	h.is_patrol = true
	# Patrol toward the center so it never wanders off the play area / into the walls.
	var cx = (GridGameManager.MIN_X + GridGameManager.MAX_X) / 2
	var cy = (GridGameManager.MIN_Y + GridGameManager.MAX_Y) / 2
	if randf() < 0.5:
		h.patrol_dir = Vector2.LEFT if h.position.x > cx else Vector2.RIGHT
	else:
		h.patrol_dir = Vector2.UP if h.position.y > cy else Vector2.DOWN
	h.patrol_distance = 2
	h.move_speed = randf_range(0.8, 1.5)
	add_child(h)
	hazards.append(h)

func _free_cell() -> Vector2:
	var cols = (GridGameManager.MAX_X - GridGameManager.MIN_X) / GridGameManager.CELL
	var rows = (GridGameManager.MAX_Y - GridGameManager.MIN_Y) / GridGameManager.CELL
	for i in range(30):
		var c = Vector2(
			GridGameManager.MIN_X + randi_range(0, cols) * GridGameManager.CELL,
			GridGameManager.MIN_Y + randi_range(0, rows) * GridGameManager.CELL)
		if c.distance_to(player.position) < 100.0:
			continue
		var bad = false
		for h in hazards:
			if is_instance_valid(h) and h.position.distance_to(c) < 80.0:
				bad = true
				break
		if goal and is_instance_valid(goal) and goal.position.distance_to(c) < 80.0:
			bad = true
		if not bad:
			return c
	return Vector2(GridGameManager.MIN_X, GridGameManager.MIN_Y)

# ---------- Juice ----------

func _burst(pos: Vector2, color: Color, amount: int = 18):
	var p = CPUParticles2D.new()
	p.process_mode = Node.PROCESS_MODE_ALWAYS
	p.position = pos
	p.emitting = true
	p.one_shot = true
	p.explosiveness = 1.0
	p.amount = amount
	p.lifetime = 0.5
	p.spread = 180.0
	p.gravity = Vector2.ZERO
	p.initial_velocity_min = 70.0
	p.initial_velocity_max = 200.0
	p.scale_amount_min = 2.0
	p.scale_amount_max = 5.0
	var g = Gradient.new()
	g.add_point(0.0, color)
	g.add_point(1.0, Color(color.r, color.g, color.b, 0.0))
	p.color_ramp = g
	add_child(p)
	get_tree().create_timer(1.0).timeout.connect(p.queue_free)

func _popup(text: String, pos: Vector2, color: Color):
	var l = Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", 28)
	l.modulate = color
	l.z_index = 100
	l.position = pos - Vector2(16, 16)
	add_child(l)
	var tw = create_tween()
	tw.tween_property(l, "position:y", l.position.y - 48.0, 0.7)
	tw.parallel().tween_property(l, "modulate:a", 0.0, 0.7)
	tw.tween_callback(l.queue_free)
