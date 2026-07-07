extends CanvasLayer

signal restart_requested
signal menu_requested
signal next_level_requested

@onready var title_label = $Control/TitleLabel
@onready var level_label = $Control/LevelLabel
@onready var stats_label = $Control/StatsLabel
@onready var next_level_button = $Control/NextLevelButton
@onready var restart_button = $Control/RestartButton
@onready var menu_button = $Control/MenuButton

func _ready():
	restart_button.pressed.connect(_on_restart_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	next_level_button.pressed.connect(_on_next_level_pressed)
	
func setup_success(level: int, fuel_remaining: float, landing_speed: float):
	title_label.text = "SUCCESS"
	title_label.add_theme_color_override("font_color", Color(0.2, 0.8, 0.2))
	level_label.text = "Level Reached: %d" % level
	
	var fuel_points = int(fuel_remaining * 10)
	var bonus = 0
	if landing_speed < 50.0:
		bonus = 500
		
	var total_score = fuel_points + bonus
	
	var stats_text = "Fuel Remaining: %d pts\n" % fuel_points
	if bonus > 0:
		stats_text += "Soft Landing Bonus: %d pts\n" % bonus
	stats_text += "\nTotal Score: %d" % total_score
	
	stats_label.text = stats_text
	stats_label.show()
	next_level_button.show()

func setup_crash(level: int):
	title_label.text = "CRASH"
	title_label.add_theme_color_override("font_color", Color(0.8, 0.2, 0.2))
	level_label.text = "Level Reached: %d" % level
	stats_label.hide()
	next_level_button.hide()

func _on_restart_pressed():
	restart_requested.emit()

func _on_menu_pressed():
	menu_requested.emit()

func _on_next_level_pressed():
	next_level_requested.emit()
