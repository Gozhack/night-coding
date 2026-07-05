extends SceneTree

# Test suite for landing classification: boundary conditions for speed, angle, and platform.

func _initialize() -> void:
	var exit_code = run_tests()
	quit(exit_code)

func run_tests() -> int:
	var LandingClassifier = preload("res://scripts/LandingClassifier.gd")
	
	# Test 1: Success case - on platform, under thresholds
	print("Test 1: Success case (on platform, speed 100, angle 20°)")
	assert(LandingClassifier.classify_landing(100.0, 20.0, true) == LandingClassifier.LandingResult.SUCCESS,
		"Should succeed: on platform with safe speed/angle")
	print("  ✓ Success verified")
	
	# Test 2: Speed boundary - exactly at threshold (150)
	print("Test 2: Speed at threshold (150 px/s)")
	assert(LandingClassifier.classify_landing(150.0, 15.0, true) == LandingClassifier.LandingResult.SUCCESS,
		"Should succeed at exactly 150 px/s")
	print("  ✓ Speed at threshold passes")
	
	# Test 3: Speed over threshold
	print("Test 3: Speed over threshold (151 px/s)")
	assert(LandingClassifier.classify_landing(151.0, 15.0, true) == LandingClassifier.LandingResult.CRASH,
		"Should crash when speed exceeds 150 px/s")
	print("  ✓ Over-speed triggers crash")
	
	# Test 4: Angle boundary - exactly at threshold (30°)
	print("Test 4: Angle at threshold (±30°)")
	assert(LandingClassifier.classify_landing(100.0, 30.0, true) == LandingClassifier.LandingResult.SUCCESS,
		"Should succeed at exactly 30° angle")
	assert(LandingClassifier.classify_landing(100.0, -30.0, true) == LandingClassifier.LandingResult.SUCCESS,
		"Should succeed at exactly -30° angle")
	print("  ✓ Angle at threshold passes")
	
	# Test 5: Angle over threshold
	print("Test 5: Angle over threshold (31°)")
	assert(LandingClassifier.classify_landing(100.0, 31.0, true) == LandingClassifier.LandingResult.CRASH,
		"Should crash when angle exceeds 30°")
	assert(LandingClassifier.classify_landing(100.0, -31.0, true) == LandingClassifier.LandingResult.CRASH,
		"Should crash when angle exceeds -30°")
	print("  ✓ Over-angle triggers crash")
	
	# Test 6: Off platform (crash regardless of speed/angle)
	print("Test 6: Off platform always crashes")
	assert(LandingClassifier.classify_landing(100.0, 20.0, false) == LandingClassifier.LandingResult.CRASH,
		"Should crash when not on platform")
	assert(LandingClassifier.classify_landing(50.0, 10.0, false) == LandingClassifier.LandingResult.CRASH,
		"Should crash off-platform even with good speed/angle")
	print("  ✓ Off-platform triggers crash")
	
	# Test 7: Edge case - zero speed and angle on platform
	print("Test 7: Perfect landing (0 speed, 0° angle, on platform)")
	assert(LandingClassifier.classify_landing(0.0, 0.0, true) == LandingClassifier.LandingResult.SUCCESS,
		"Should succeed with perfect conditions")
	print("  ✓ Perfect landing verified")
	
	# Test 8: High speed, bad angle, off platform (all failures combined)
	print("Test 8: Multiple failures (high speed + bad angle + off platform)")
	assert(LandingClassifier.classify_landing(300.0, 60.0, false) == LandingClassifier.LandingResult.CRASH,
		"Should crash with multiple violations")
	print("  ✓ Multiple violations trigger crash")
	
	print("\n✅ All landing classification tests passed!")
	return 0
