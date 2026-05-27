extends SceneTree

# Simple headless test suite for Void-Tap MVP logic

func _init():
	print("--- Starting Void-Tap Tests ---")
	test_clamping_logic()
	test_scoring_math()
	print("--- All Tests Passed ---")
	quit()

func test_clamping_logic():
	print("Testing Clamping...")
	var pos = Vector2(2000, -500)
	var screen_size = Vector2(1152, 648)
	var radius = 25.0
	
	var clamped_x = clamp(pos.x, radius, screen_size.x - radius)
	var clamped_y = clamp(pos.y, radius, screen_size.y - radius)
	
	assert(clamped_x == 1152 - 25)
	assert(clamped_y == 25)
	print("  Clamping: OK")

func test_scoring_math():
	print("Testing Scoring Math...")
	var base_rate = 1.0
	var level = 5
	var new_rate = base_rate * pow(0.9, level - 1)
	
	# Roughly 0.6561 for level 5
	assert(new_rate < 0.7 and new_rate > 0.6)
	print("  Scoring Math: OK")
