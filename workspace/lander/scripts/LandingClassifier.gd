class_name LandingClassifier

enum LandingResult {
	SUCCESS = 0,
	CRASH = 1
}

# Pure function: classify landing based on velocity, angle, and platform contact.
# Returns LandingResult.SUCCESS or LandingResult.CRASH.
static func classify_landing(speed: float, angle: float, on_pad: bool) -> int:
	# Thresholds
	var max_speed = 150.0
	var max_angle = 30.0  # degrees
	
	# Must be on platform AND under speed/angle limits
	if on_pad and speed <= max_speed and abs(angle) <= max_angle:
		return LandingResult.SUCCESS
	else:
		return LandingResult.CRASH
