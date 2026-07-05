extends SceneTree

func _initialize() -> void:
	var scene = load("res://scenes/Main.tscn")
	var instance = scene.instantiate()
	root.add_child(instance)
	
	# Let's run for 5 frames and print positions
	for i in range(5):
		await process_frame
		print("Frame ", i, ": Ship Pos = ", instance.global_position, " Terrain Global Pos = ", instance.get_node("Terrain").global_position)
	quit(0)
