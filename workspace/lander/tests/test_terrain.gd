extends SceneTree

# Test suite for terrain generation: determinism, coverage, and platform validity.

func _initialize() -> void:
	var exit_code = run_tests()
	quit(exit_code)

func run_tests() -> int:
	var viewport_size = Vector2(1280, 720)
	var terrain_gen = preload("res://scripts/TerrainGenerator.gd").new()
	
	# Test 1: Determinism - same seed produces same terrain
	print("Test 1: Determinism (same seed → same terrain)")
	var terrain_a = terrain_gen.generate_terrain(42, viewport_size)
	var terrain_b = terrain_gen.generate_terrain(42, viewport_size)
	
	assert(terrain_a["terrain_points"].size() == terrain_b["terrain_points"].size(), "Terrain point count mismatch")
	for i in range(terrain_a["terrain_points"].size()):
		var pa = terrain_a["terrain_points"][i]
		var pb = terrain_b["terrain_points"][i]
		assert(pa.is_equal_approx(pb), "Terrain point %d mismatch: %s vs %s" % [i, pa, pb])
	print("  ✓ Determinism verified")
	
	# Test 2: Variance - different seeds produce different terrains
	print("Test 2: Variance (different seeds → different terrains)")
	var terrain_c = terrain_gen.generate_terrain(123, viewport_size)
	var different = false
	for i in range(min(terrain_a["terrain_points"].size(), terrain_c["terrain_points"].size())):
		if not terrain_a["terrain_points"][i].is_equal_approx(terrain_c["terrain_points"][i]):
			different = true
			break
	assert(different, "Different seeds produced identical terrain (failed variance test)")
	print("  ✓ Variance verified")
	
	# Test 3: Coverage - terrain points span the full viewport width
	print("Test 3: Coverage (terrain spans full viewport width)")
	var min_x = viewport_size.x
	var max_x = 0.0
	for point in terrain_a["terrain_points"]:
		min_x = min(min_x, point.x)
		max_x = max(max_x, point.x)
	
	assert(min_x <= 10.0, "Terrain left edge too far from 0: %f" % min_x)
	assert(max_x >= viewport_size.x - 10.0, "Terrain right edge too far from viewport: %f" % max_x)
	print("  ✓ Coverage verified (x: %.1f to %.1f)" % [min_x, max_x])
	
	# Test 4: Height bounds - all points within screen height
	print("Test 4: Height bounds (all points within valid range)")
	var min_y = viewport_size.y
	var max_y = 0.0
	for point in terrain_a["terrain_points"]:
		min_y = min(min_y, point.y)
		max_y = max(max_y, point.y)
	
	assert(min_y >= viewport_size.y * 0.1, "Terrain Y min out of bounds: %f" % min_y)
	assert(max_y <= viewport_size.y, "Terrain Y max out of bounds: %f" % max_y)
	print("  ✓ Height bounds verified (y: %.1f to %.1f)" % [min_y, max_y])
	
	# Test 5: Platform existence and size
	print("Test 5: Platform (exists and meets minimum width)")
	var platform = terrain_a["platform_points"]
	assert(platform.size() == 2, "Platform should have exactly 2 points (start and end)")
	var platform_width = platform[1].x - platform[0].x
	assert(platform_width >= 100.0, "Platform width too small: %.1f" % platform_width)
	assert(platform[0].y == platform[1].y, "Platform should be flat (y should match)")
	print("  ✓ Platform verified (width: %.1f)" % platform_width)
	
	print("\n✅ All tests passed!")
	return 0
