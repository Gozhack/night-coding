extends CharacterBody2D

const GRAVITY = 100.0
const THRUST = 250.0
const LATERAL_SPEED = 150.0

var screen_size: Vector2
var is_thrusting = false

# --- Child Nodes ---
@onready var terrain_polygon: Polygon2D = $TerrainPolygon
@onready var platform_line: Line2D = $PlatformLine

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
	position = screen_size / 2
	
	# --- Generate and draw terrain ---
	var terrain_generator = TerrainGenerator.new()
	var terrain_data = terrain_generator.generate_terrain(1, screen_size)
	var terrain_points = terrain_data["terrain_points"]
	var platform_points = terrain_data["platform_points"]
	
	# Set the points for the green platform line
	platform_line.points = platform_points
	
	# Add points to make the terrain a closed polygon for filling
	var polygon_points = PackedVector2Array(terrain_points)
	polygon_points.append(Vector2(screen_size.x, screen_size.y))
	polygon_points.append(Vector2(0, screen_size.y))
	terrain_polygon.polygon = polygon_points


func _draw():
	# Draw ship body and border
	draw_colored_polygon(ship_points, ship_color)
	draw_polyline(ship_points, ship_border_color, 1.0, true)
	
	if is_thrusting:
		# Draw flame body and border
		draw_colored_polygon(flame_points, flame_color)
		draw_polyline(flame_points, flame_border_color, 1.0, true)


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
	
	# Apply thrust
	if is_thrusting:
		velocity.y -= THRUST * delta

	# Apply lateral movement
	velocity.x = lateral_direction * LATERAL_SPEED
	
	# --- Finalization ---
	
	# Integrate motion
	move_and_slide()
	
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
