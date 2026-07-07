class_name TerrainGenerator

# Generates a terrain profile with a guaranteed flat landing platform.
# The terrain shape is determined by the given seed.
# Returns a Dictionary containing two PackedVector2Arrays:
# {
#   "terrain_points": PackedVector2Array for the main terrain,
#   "platform_points": PackedVector2Array for the landing platform
# }
func generate_terrain(seed: int, viewport_size: Vector2, level: int = 1) -> Dictionary:
	var rng = RandomNumberGenerator.new()
	rng.seed = seed

	var terrain_points = PackedVector2Array()
	var platform_points = PackedVector2Array()

	# --- Define Terrain & Platform Dimensions ---
	var min_platform_width = max(30.0, 120.0 * pow(0.9, level - 1))
	var max_platform_width = max(40.0, 200.0 * pow(0.9, level - 1))
	var platform_width = rng.randf_range(min_platform_width, max_platform_width)
	
	# Position the platform somewhere in the middle 80% of the screen
	var platform_start_x = rng.randf_range(viewport_size.x * 0.1, viewport_size.x * 0.9 - platform_width)
	var platform_end_x = platform_start_x + platform_width
	var platform_y = rng.randf_range(viewport_size.y * 0.6, viewport_size.y * 0.9)

	# --- Generate Terrain Points ---
	var base_variation = 80.0
	var current_variation = min(250.0, base_variation * pow(1.2, level - 1))
	
	var x = 0.0
	var y = rng.randf_range(viewport_size.y * 0.5, viewport_size.y * 0.8)
	terrain_points.append(Vector2(x, y))

	# Part 1: From start of screen to the platform
	while x < platform_start_x:
		x += rng.randf_range(30.0, 70.0)
		x = min(x, platform_start_x)
		var new_y = y + rng.randf_range(-current_variation, current_variation)
		# Clamp Y to prevent it from going off-screen
		new_y = clamp(new_y, viewport_size.y * 0.2, viewport_size.y - 20)
		terrain_points.append(Vector2(x, new_y))
		y = new_y
	
	# Add a point to perfectly connect to the platform
	terrain_points.append(Vector2(platform_start_x, platform_y))

	# Part 2: The platform itself (for separate coloring)
	platform_points.append(Vector2(platform_start_x, platform_y))
	platform_points.append(Vector2(platform_end_x, platform_y))

	# Part 3: From the platform to the end of the screen
	# Add a point to start the next segment from the end of the platform
	terrain_points.append(Vector2(platform_end_x, platform_y))
	x = platform_end_x
	y = platform_y

	while x < viewport_size.x:
		x += rng.randf_range(30.0, 70.0)
		x = min(x, viewport_size.x)
		var new_y = y + rng.randf_range(-current_variation, current_variation)
		# Clamp Y to prevent it from going off-screen
		new_y = clamp(new_y, viewport_size.y * 0.2, viewport_size.y - 20)
		terrain_points.append(Vector2(x, new_y))
		y = new_y

	return {
		"terrain_points": terrain_points,
		"platform_points": platform_points
	}
