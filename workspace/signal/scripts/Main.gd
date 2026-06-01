extends Control

# Signal — memory game (Simon style). Watch the colour sequence, then repeat it.
# Each round adds one colour. A wrong tap ends the run. Score = rounds reached.

enum State { MENU, SHOWING, INPUT, OVER }

const COLORS := [Color("#ef4444"), Color("#22c55e"), Color("#3b82f6"), Color("#eab308")]
const TONES := [330.0, 392.0, 494.0, 587.0]  # one distinct tone per colour
const NAMES := ["RED", "GREEN", "BLUE", "YELLOW"]

@onready var red_button = $CenterContainer/GridContainer/RedButton
@onready var green_button = $CenterContainer/GridContainer/GreenButton
@onready var blue_button = $CenterContainer/GridContainer/BlueButton
@onready var yellow_button = $CenterContainer/GridContainer/YellowButton
@onready var buttons = [red_button, green_button, blue_button, yellow_button]

var _rects: Array = []  # the ColorRect inside each button (drives the colour/flash)
var sequence: Array[int] = []
var input_index: int = 0
var level: int = 0
var best: int = 0
var state: State = State.MENU

# UI built in code
var status_label: Label
var menu_overlay: Control
var over_overlay: Control
var result_label: Label

# Audio
var audio_player: AudioStreamPlayer
var generator: AudioStreamGeneratorPlayback
var sample_rate: float = 22050.0

const SAVE_PATH = "user://signal_best.save"

func _ready():
	_setup_audio()
	_load_best()

	for i in range(buttons.size()):
		var cr = buttons[i].get_node_or_null("ColorRect")
		if cr:
			cr.show_behind_parent = false  # draw the colour on top of the button face
		_rects.append(cr)
		_unhighlight(i)
	red_button.pressed.connect(_on_button_pressed.bind(0))
	green_button.pressed.connect(_on_button_pressed.bind(1))
	blue_button.pressed.connect(_on_button_pressed.bind(2))
	yellow_button.pressed.connect(_on_button_pressed.bind(3))

	_build_ui()
	_show_menu()

# ---------- UI ----------

func _build_ui():
	status_label = Label.new()
	status_label.add_theme_font_size_override("font_size", 38)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	status_label.position = Vector2(-300, 40)
	status_label.size = Vector2(600, 60)
	status_label.modulate = Color("#cfe8ff")
	add_child(status_label)

	menu_overlay = _make_overlay()
	_label(menu_overlay, "SIGNAL", 88, Color("#38bdf8"), Vector2(-300, 120), Vector2(600, 110))
	_label(menu_overlay, "Observa la secuencia de colores\ny repítela tocando.\nCada ronda agrega un color.", 26, Color("#cfe8ff"), Vector2(-320, -60), Vector2(640, 130))
	var start_btn = _button("START", Vector2(240, 76), Vector2(-120, 150))
	start_btn.pressed.connect(_on_start)
	menu_overlay.add_child(start_btn)

	over_overlay = _make_overlay()
	_label(over_overlay, "FALLASTE", 84, Color("#ef4444"), Vector2(-300, 130), Vector2(600, 100))
	result_label = _label(over_overlay, "", 34, Color.WHITE, Vector2(-300, -10), Vector2(600, 70))
	var restart_btn = _button("REINTENTAR", Vector2(240, 68), Vector2(-120, 90))
	restart_btn.pressed.connect(_on_restart)
	over_overlay.add_child(restart_btn)
	var menu_btn = _button("MENÚ", Vector2(240, 56), Vector2(-120, 170))
	menu_btn.pressed.connect(_on_menu)
	over_overlay.add_child(menu_btn)
	over_overlay.visible = false

func _make_overlay() -> Control:
	var o = Control.new()
	o.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(o)
	var bg = ColorRect.new()
	bg.color = Color(0.02, 0.03, 0.06, 0.82)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	o.add_child(bg)
	return o

func _label(parent: Control, text: String, size: int, color: Color, off: Vector2, dims: Vector2) -> Label:
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

func _button(text: String, dims: Vector2, off: Vector2) -> Button:
	var b = Button.new()
	b.text = text
	b.custom_minimum_size = dims
	b.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	b.position = off
	return b

func _show_menu():
	state = State.MENU
	menu_overlay.visible = true
	over_overlay.visible = false
	status_label.text = ""

# ---------- Flow ----------

func _on_start():
	_resume_audio()
	menu_overlay.visible = false
	_start_game()

func _start_game():
	sequence.clear()
	level = 0
	over_overlay.visible = false
	_next_round()

func _next_round():
	sequence.append(randi() % 4)
	level = sequence.size()
	status_label.text = "Nivel %d — observa" % level
	await get_tree().create_timer(0.7).timeout
	await _show_sequence()

func _show_sequence() -> void:
	state = State.SHOWING
	var on_time = maxf(0.22, 0.5 - level * 0.015)
	for index in sequence:
		_highlight(index)
		_play_tone(TONES[index], on_time, 0.25)
		await get_tree().create_timer(on_time).timeout
		_unhighlight(index)
		await get_tree().create_timer(0.18).timeout
	input_index = 0
	state = State.INPUT
	status_label.text = "Tu turno (%d)" % level

func _on_button_pressed(index: int):
	if state != State.INPUT:
		return
	_flash(index)
	_play_tone(TONES[index], 0.18, 0.25)

	if index == sequence[input_index]:
		input_index += 1
		if input_index >= sequence.size():
			# Round cleared.
			state = State.SHOWING
			status_label.text = "¡Bien! +1"
			await get_tree().create_timer(0.6).timeout
			_next_round()
	else:
		_game_over()

func _game_over():
	state = State.OVER
	_play_error()
	var is_record = level > best
	if is_record:
		best = level
		_save_best()
	if is_record and level > 0:
		result_label.text = "NUEVO RÉCORD: nivel %d" % level
		result_label.modulate = Color("#22ff88")
	else:
		result_label.text = "Llegaste al nivel %d    Récord: %d" % [level, best]
		result_label.modulate = Color.WHITE
	status_label.text = ""
	over_overlay.visible = true

func _on_restart():
	over_overlay.visible = false
	_start_game()

func _on_menu():
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.location.href = '../index.html'")
	else:
		_show_menu()

# ---------- Button visuals ----------

func _highlight(index: int):
	if _rects[index]:
		_rects[index].color = COLORS[index].lightened(0.55)

func _unhighlight(index: int):
	if _rects[index]:
		_rects[index].color = COLORS[index]

func _flash(index: int):
	_highlight(index)
	var idx = index
	get_tree().create_timer(0.18).timeout.connect(func(): _unhighlight(idx))

# ---------- Audio (procedural tones) ----------

func _setup_audio():
	audio_player = AudioStreamPlayer.new()
	var stream = AudioStreamGenerator.new()
	stream.mix_rate = sample_rate
	stream.buffer_length = 0.3
	audio_player.stream = stream
	add_child(audio_player)

func _resume_audio():
	if audio_player and not audio_player.playing:
		audio_player.play()
		generator = audio_player.get_stream_playback()

func _play_tone(freq: float, duration: float, volume: float):
	_resume_audio()
	if not generator:
		return
	var frames = min(int(duration * sample_rate), generator.get_frames_available())
	var phase = 0.0
	var increment = freq / sample_rate
	for i in range(frames):
		var sample = sin(phase * TAU) * volume
		if i < 200:
			sample *= i / 200.0
		if i > frames - 200:
			sample *= float(frames - i) / 200.0
		generator.push_frame(Vector2(sample, sample))
		phase = fmod(phase + increment, 1.0)

func _play_error():
	_resume_audio()
	if not generator:
		return
	var frames = min(int(0.4 * sample_rate), generator.get_frames_available())
	for i in range(frames):
		var env = float(frames - i) / float(frames)
		generator.push_frame(Vector2(randf_range(-0.4, 0.4) * env, randf_range(-0.4, 0.4) * env))

# ---------- Persistence ----------

func _save_best():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_32(best)

func _load_best():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			best = file.get_32()
