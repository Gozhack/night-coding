extends CharacterBody2D

const LandingClassifier = preload("res://scripts/LandingClassifier.gd")

const GRAVITY = 100.0
const THRUST = 250.0
const LATERAL_SPEED = 150.0

var screen_size: Vector2
var is_thrusting = false

# --- Game state ---
var level = 1
var is_resetting = false

# --- Landing state ---
var landing_result = -1  # -1 = not landed, 0 = success, 1 = crash
var platform_bounds = PackedVector2Array()  # start and end x of platform

# --- Fuel system ---
var max_fuel = 100.0
var fuel = 100.0
const FUEL_BURN_RATE = 20.0  # fuel units per second while thrusting

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


func _ready():
	screen_size = get_viewport_rect().size
	if screen_size.x <= 0 or screen_size.y <= 0:
		screen_size = Vector2(1280, 720)
	print("DEBUG _ready: screen_size is ", screen_size)
	
	# Set the ship's CollisionPolygon2D points
	collision_polygon_2d.polygon = ship_points
	
	reset_level()

func reset_level():
	is_resetting = false
	landing_result = -1
	position = screen_size / 2
	velocity = Vector2.ZERO
	rotation = 0
	ship_color = Color(0.75, 0.75, 0.75)
	
	# Lower initial fuel per level
	max_fuel = max(20.0, 100.0 - (level - 1) * 10.0)
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

	# Level text (top center)
	var level_text = "LEVEL: %d" % level
	var level_text_size = ThemeDB.fallback_font.get_string_size(level_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 12)
	draw_string(ThemeDB.fallback_font, Vector2((screen_size.x - level_text_size.x) / 2, 25), level_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)


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
	elif is_thrusting and fuel <= 0:
		is_thrusting = false  # No fuel, no thrust

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
		
		# Change ship color based on result
		if landing_result == LandingClassifier.LandingResult.SUCCESS:
			ship_color = Color(0.0, 1.0, 0.0)  # Green
			is_resetting = true
			level += 1
			get_tree().create_timer(1.5).timeout.connect(reset_level)
		elif landing_result == LandingClassifier.LandingResult.CRASH:
			ship_color = Color(1.0, 0.0, 0.0)  # Red
			is_resetting = true
			level = 1
			get_tree().create_timer(1.5).timeout.connect(reset_level)
	
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
