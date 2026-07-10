extends CharacterBody2D

const LandingClassifier = preload("res://scripts/LandingClassifier.gd")
const ResultScreen = preload("res://scenes/ResultScreen.tscn")

const GRAVITY = 100.0
const THRUST = 250.0
const LATERAL_SPEED = 150.0

var screen_size: Vector2
var is_thrusting = false
var current_thrust_intensity: float = 0.0
var audio_manager: Node

# --- Game state ---
var level = 1
var is_resetting = false

# --- Landing state ---
var landing_result = -1  # -1 = not landed, 0 = success, 1 = crash
var platform_bounds = PackedVector2Array()  # start and end x of platform
var vertical_speed_at_landing = 0.0

# --- Fuel system ---
var max_fuel = 100.0
var fuel = 100.0
const FUEL_BURN_RATE = 20.0  # fuel units per second while thrusting

# --- Score & Save ---
var total_score = 0
var high_score = 0
const SAVE_PATH = "user://lander_best_score"

# --- Child Nodes ---
@onready var terrain_polygon: Polygon2D = $TerrainPolygon
@onready var platform_line: Line2D = $PlatformLine
@onready var terrain_collision: CollisionPolygon2D = $Terrain/CollisionPolygon2D
@onready var collision_polygon_2d: CollisionPolygon2D = $CollisionPolygon2D
@onready var terrain_collision_polygon: CollisionPolygon2D = $Terrain/CollisionPolygon2D

# --- Scene Resources ---
const TerrainGenerator = preload("res://scripts/TerrainGenerator.gd")

# --- Touch state variables ---
var touch_id = -1
var touch_pos = Vector2.ZERO

# --- Ship drawing assets ---
var ship_points = PackedVector2Array([Vector2(0, -15), Vector2(-10, 10), Vector2(10, 10)])
var ship_color = Color(0.75, 0.75, 0.75)
var ship_border_color = Color(1.0, 1.0, 1.0)

# --- Flame drawing assets ---
var flame_points = PackedVector2Array([Vector2(-5, 12), Vector2(0, 20), Vector2(5, 12)])
var flame_color = Color(1.0, 0.68, 0.2)
var flame_border_color = Color(1.0, 0.94, 0.4)

var result_screen_instance = null

func _ready():
	screen_size = get_viewport_rect().size
	if screen_size.x <= 0 or screen_size.y <= 0:
		screen_size = Vector2(1280, 720)
	print("DEBUG _ready: screen_size is ", screen_size)
	
	audio_manager = preload("res://scripts/AudioManager.gd").new()
	add_child(audio_manager)
	
	# Set the ship's CollisionPolygon2D points
	collision_polygon_2d.polygon = ship_points
	
	load_high_score()
	
	var menu_btn = Button.new()
	menu_btn.text = "Back to Menu"
	menu_btn.process_mode = Node.PROCESS_MODE_ALWAYS
	menu_btn.position = Vector2(screen_size.x - 130, screen_size.y - 50)
	menu_btn.size = Vector2(120, 40)
	menu_btn.pressed.connect(_on_main_menu_btn_pressed)
	add_child(menu_btn)
	
	reset_level()

func reset_level():
	get_tree().paused = false
	is_resetting = false
	landing_result = -1
	position = screen_size / 2
	velocity = Vector2.ZERO
	rotation = 0
	ship_color = Color(0.75, 0.75, 0.75)
	
	if level == 1:
		total_score = 0
	
	# Lower initial fuel per level ~8%
	max_fuel = max(20.0, 100.0 * pow(0.92, level - 1))
	fuel = max_fuel
	
	# --- Generate and draw terrain ---
	var terrain_generator = TerrainGenerator.new()
	var terrain_data = terrain_generator.generate_terrain(level + 1, screen_size, level)
	var terrain_points = terrain_data["terrain_points"]
	var platform_points = terrain_data["platform_points"]
	print("DEBUG reset_level: terrain_points size is ", terrain_points.size(), " platform_points size is ", platform_points.size())
	
	# Set the points for the green platform line
	platform_line.points = platform_points
	
	# Store platform bounds for landing detection
	platform_bounds = platform_points
	
	# Add points to make the terrain a closed polygon for filling
	var polygon_points = PackedVector2Array(terrain_points)
	polygon_points.append(Vector2(screen_size.x, screen_size.y))
	polygon_points.append(Vector2(0, screen_size.y))
	terrain_polygon.polygon = polygon_points
	
	# Set collision polygon for terrain (same points but without the closed bottom)
	terrain_collision.polygon = terrain_points
	
	# Assign the same points to the CollisionPolygon2D of the Terrain StaticBody2D
	terrain_collision_polygon.polygon = polygon_points
	
	queue_redraw()

func _draw():
	# Draw ship body and border
	draw_colored_polygon(ship_points, ship_color)
	draw_polyline(ship_points, ship_border_color, 1.0, true)
	
	if is_thrusting:
		# Draw flame body and border
		draw_colored_polygon(flame_points, flame_color)
		draw_polyline(flame_points, flame_border_color, 1.0, true)
	
	# --- Draw HUD ---
	# Fuel bar (upper left)
	var fuel_bar_width = 100.0
	var fuel_bar_height = 15.0
	var fuel_bar_pos = Vector2(10, 10)
	var fuel_ratio = fuel / max_fuel
	
	# Background (gray)
	draw_rect(Rect2(fuel_bar_pos, Vector2(fuel_bar_width, fuel_bar_height)), Color(0.3, 0.3, 0.3))
	
	# Fuel fill (green if ok, red if low)
	var fuel_color = Color(0.0, 1.0, 0.0) if fuel_ratio > 0.2 else Color(1.0, 0.0, 0.0)
	draw_rect(Rect2(fuel_bar_pos, Vector2(fuel_bar_width * fuel_ratio, fuel_bar_height)), fuel_color)
	
	# Fuel text
	draw_string(ThemeDB.fallback_font, fuel_bar_pos + Vector2(5, 25), "FUEL: %.0f%%" % (fuel_ratio * 100.0), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)
	
	# Velocity text (upper right)
	var velocity_text = "V: %.0f px/s" % abs(velocity.y)
	var text_size = ThemeDB.fallback_font.get_string_size(velocity_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 12)
	draw_string(ThemeDB.fallback_font, Vector2(screen_size.x - text_size.x - 10, 10), velocity_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)

	# Level text (top left corner)
	var level_text = "LEVEL: %d" % level
	draw_string(ThemeDB.fallback_font, Vector2(10, 55), level_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)

	# Score text (top center)
	var score_text = "SCORE: %d" % total_score
	draw_string(ThemeDB.fallback_font, Vector2(screen_size.x/2 - 50, 20), score_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)
	var best_text = "BEST: %d" % high_score
	draw_string(ThemeDB.fallback_font, Vector2(screen_size.x/2 - 50, 40), best_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)


func _input(event):
	# Handle touch start and end
	if event is InputEventScreenTouch:
		if event.pressed and touch_id == -1:
			touch_id = event.index
			touch_pos = event.position
		elif not event.pressed and event.index == touch_id:
			touch_id = -1
	# Handle touch drag
	elif event is InputEventScreenDrag and event.index == touch_id:
		touch_pos = event.position


func _physics_process(delta):
	# --- Input Gathering ---
	var lateral_direction = 0.0
	is_thrusting = false
	
	# Keyboard input
	if Input.is_key_pressed(KEY_D) or Input.is_action_pressed("ui_right"):
		lateral_direction += 1.0
	if Input.is_key_pressed(KEY_A) or Input.is_action_pressed("ui_left"):
		lateral_direction -= 1.0
	
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_SPACE) or Input.is_action_pressed("ui_up"):
		is_thrusting = true
	
	# Touch input (overrides keyboard if active)
	if touch_id != -1:
		is_thrusting = true
		# Lateral control by sliding finger left/right from center
		var screen_center_x = screen_size.x / 2
		if touch_pos.x < screen_center_x - 50:
			lateral_direction = -1.0
		elif touch_pos.x > screen_center_x + 50:
			lateral_direction = 1.0
		else:
			lateral_direction = 0.0

	# --- Physics Calculation ---
	
	# Apply gravity
	velocity.y += GRAVITY * delta
	
	# Apply thrust (consume fuel)
	if is_thrusting and fuel > 0:
		velocity.y -= THRUST * delta
		fuel -= FUEL_BURN_RATE * delta
		fuel = max(fuel, 0.0)
		current_thrust_intensity = min(1.0, current_thrust_intensity + delta * 5.0)
	else:
		if is_thrusting and fuel <= 0:
			is_thrusting = false  # No fuel, no thrust
		current_thrust_intensity = max(0.0, current_thrust_intensity - delta * 5.0)
		
	if audio_manager:
		audio_manager.set_thrust(current_thrust_intensity > 0.0, current_thrust_intensity)

	# Apply lateral movement
	velocity.x = lateral_direction * LATERAL_SPEED
	
	# --- Finalization ---
	
	# Integrate motion
	var prev_position = position
	move_and_slide()
	
	# Detect landing: check if we hit terrain
	var collisions = get_last_slide_collision()
	if collisions and not is_resetting:
		# Calculate ship angle (rotation in degrees)
		var ship_angle = rad_to_deg(rotation)
		
		# Calculate vertical speed (magnitude of y velocity)
		var vertical_speed = abs(velocity.y)
		
		# Check if on platform (x position within platform bounds)
		var on_platform = (position.x >= platform_bounds[0].x and 
		                   position.x <= platform_bounds[1].x)
		
		# Classify landing
		landing_result = LandingClassifier.classify_landing(vertical_speed, ship_angle, on_platform)
		vertical_speed_at_landing = vertical_speed
		
		# Change ship color based on result
		if landing_result == LandingClassifier.LandingResult.SUCCESS:
			ship_color = Color(0.0, 1.0, 0.0)  # Green
			is_resetting = true
			current_thrust_intensity = 0.0
			
			var fuel_points = int(fuel * 10)
			var bonus = 0
			if vertical_speed_at_landing < 50.0:
				bonus = 500
			total_score += fuel_points + bonus
			
			if total_score > high_score:
				high_score = total_score
				save_high_score()
				
			if audio_manager:
				audio_manager.set_thrust(false, 0.0)
				audio_manager.play_success()
			call_deferred("_show_result_screen", true)
		elif landing_result == LandingClassifier.LandingResult.CRASH:
			ship_color = Color(1.0, 0.0, 0.0)  # Red
			is_resetting = true
			current_thrust_intensity = 0.0
			if audio_manager:
				audio_manager.set_thrust(false, 0.0)
				audio_manager.play_crash()
			call_deferred("_show_result_screen", false)
	
	# Trigger redraw to show/hide flame
	queue_redraw()
	
	# Screen wrap logic
	if position.x > screen_size.x:
		position.x = 0
	if position.x < 0:
		position.x = screen_size.x
	if position.y > screen_size.y:
		position.y = 0
	if position.y < 0:
		position.y = screen_size.y

func _show_result_screen(success: bool):
	get_tree().paused = true
	
	result_screen_instance = ResultScreen.instantiate()
	add_child(result_screen_instance)
	
	if success:
		result_screen_instance.setup_success(level, fuel, vertical_speed_at_landing)
	else:
		result_screen_instance.setup_crash(level)
		
		var final_score_label = Label.new()
		final_score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		final_score_label.add_theme_font_size_override("font_size", 32)
		final_score_label.text = "SCORE: " + str(total_score)
		final_score_label.position = Vector2(screen_size.x/2 - 150, screen_size.y/2 - 20)
		final_score_label.size = Vector2(300, 40)
		result_screen_instance.get_node("Control").add_child(final_score_label)
		
		var high_score_label = Label.new()
		high_score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		high_score_label.add_theme_font_size_override("font_size", 32)
		if total_score > 0 and total_score >= high_score:
			high_score_label.text = "NEW BEST: " + str(total_score)
			high_score_label.modulate = Color("#00ffff")
		else:
			high_score_label.text = "BEST: " + str(high_score)
			high_score_label.modulate = Color.WHITE
		
		high_score_label.position = Vector2(screen_size.x/2 - 150, screen_size.y/2 + 20)
		high_score_label.size = Vector2(300, 40)
		result_screen_instance.get_node("Control").add_child(high_score_label)
		
	result_screen_instance.restart_requested.connect(_on_restart_requested)
	result_screen_instance.menu_requested.connect(_on_menu_requested)
	result_screen_instance.next_level_requested.connect(_on_next_level_requested)

func _on_next_level_requested():
	if result_screen_instance:
		result_screen_instance.queue_free()
		result_screen_instance = null
	level += 1
	reset_level()

func _on_restart_requested():
	if result_screen_instance:
		result_screen_instance.queue_free()
		result_screen_instance = null
	level = 1
	reset_level()

func _on_menu_requested():
	get_tree().paused = false
	if ResourceLoader.exists("res://scenes/Main.tscn"):
		get_tree().change_scene_to_file("res://scenes/Main.tscn")
	elif OS.has_feature("web"):
		JavaScriptBridge.eval("window.location.href = '../index.html'")
	else:
		get_tree().quit()

func _on_main_menu_btn_pressed():
	get_tree().paused = false
	if ResourceLoader.exists("res://scenes/Main.tscn"):
		get_tree().change_scene_to_file("res://scenes/Main.tscn")
	elif OS.has_feature("web"):
		JavaScriptBridge.eval("window.location.href = '../index.html'")
	else:
		get_tree().quit()

func load_high_score():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			high_score = file.get_32()

func save_high_score():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_32(high_score)
