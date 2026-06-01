extends Control

enum GameState { IDLE, PLAYING_SEQUENCE }

const RED = Color("#ef4444")
const GREEN = Color("#22c55e")
const BLUE = Color("#3b82f6")
const YELLOW = Color("#eab308")

@onready var grid_container = $CenterContainer/GridContainer
@onready var red_button = $CenterContainer/GridContainer/RedButton
@onready var green_button = $CenterContainer/GridContainer/GreenButton
@onready var blue_button = $CenterContainer/GridContainer/BlueButton
@onready var yellow_button = $CenterContainer/GridContainer/YellowButton

@onready var buttons = [red_button, green_button, blue_button, yellow_button]
var sequence: Array[int] = []
var state: GameState = GameState.IDLE

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Initialize buttons to normal state
	for i in range(buttons.size()):
		unhighlight_button(i)
	
	# Connect buttons (placeholders for now)
	red_button.pressed.connect(_on_button_pressed.bind(0))
	green_button.pressed.connect(_on_button_pressed.bind(1))
	blue_button.pressed.connect(_on_button_pressed.bind(2))
	yellow_button.pressed.connect(_on_button_pressed.bind(3))
	
	print("Signal game initialized")
	
	# SG-02: Start game
	state = GameState.IDLE
	sequence = []
	generate_sequence()
	play_sequence()

func generate_sequence():
	sequence.append(randi() % 4)

func play_sequence():
	state = GameState.PLAYING_SEQUENCE
	for index in sequence:
		highlight_button(index)
		await get_tree().create_timer(0.5).timeout
		unhighlight_button(index)
		await get_tree().create_timer(0.3).timeout
	state = GameState.IDLE

func highlight_button(index: int):
	var btn = buttons[index]
	var color = _get_color_for_index(index)
	# Set to original color but boosted/brightened
	btn.modulate = color
	btn.self_modulate = Color(2.5, 2.5, 2.5, 1.0) # Very bright

func unhighlight_button(index: int):
	var btn = buttons[index]
	var color = _get_color_for_index(index)
	# Restore to original color
	btn.modulate = color
	btn.self_modulate = Color(1.0, 1.0, 1.0, 1.0)

func _get_color_for_index(index: int) -> Color:
	match index:
		0: return RED
		1: return GREEN
		2: return BLUE
		3: return YELLOW
		_: return Color.WHITE

func _on_button_pressed(index: int):
	if state == GameState.PLAYING_SEQUENCE:
		return
	
	print("Button pressed: ", index)
	# Temporary: highlight on press
	highlight_button(index)
	await get_tree().create_timer(0.2).timeout
	unhighlight_button(index)
