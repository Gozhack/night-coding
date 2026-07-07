extends SceneTree

func _initialize() -> void:
	print("Testing ResultScreen initialization...")
	var scene = load("res://scenes/ResultScreen.tscn")
	assert(scene != null, "Failed to load ResultScreen.tscn")
	var instance = scene.instantiate()
	assert(instance != null, "Failed to instantiate ResultScreen.tscn")
	
	root.add_child(instance)
	await process_frame
	
	instance.setup_success(1, 100.0, 10.0)
	print("Success setup test passed.")
	
	instance.setup_crash(1)
	print("Crash setup test passed.")
	
	print("✅ ResultScreen test passed!")
	quit(0)
