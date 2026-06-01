extends Control

const RED = Color("#ef4444")
const GREEN = Color("#22c55e")
const BLUE = Color("#3b82f6")
const YELLOW = Color("#eab308")

@onready var grid_container = $CenterContainer/GridContainer
@onready var red_button = $CenterContainer/GridContainer/RedButton
@onready var green_button = $CenterContainer/GridContainer/GreenButton
@onready var blue_button = $CenterContainer/GridContainer/BlueButton
@onready var yellow_button = $CenterContainer/GridContainer/YellowButton

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Connect buttons (placeholders for now)
	red_button.pressed.connect(_on_button_pressed.bind("red"))
	green_button.pressed.connect(_on_button_pressed.bind("green"))
	blue_button.pressed.connect(_on_button_pressed.bind("blue"))
	yellow_button.pressed.connect(_on_button_pressed.bind("yellow"))
	
	print("Signal game initialized")

func _on_button_pressed(color_name: String):
	print("Button pressed: ", color_name)
