extends SceneTree

func _initialize() -> void:
	print("Testing scene initialization...")
	var scene = load("res://scenes/Main.tscn")
	assert(scene != null, "Failed to load Main.tscn")
	var instance = scene.instantiate()
	assert(instance != null, "Failed to instantiate Main.tscn")
	
	root.add_child(instance)
	print("Scene instantiated and added to root. Awaiting a frame...")
	await process_frame
	print("Checking children...")
	
	# Verify that the CollisionPolygon2D exists on the character
	var ship_collision = instance.get_node("CollisionPolygon2D")
	assert(ship_collision is CollisionPolygon2D, "Ship CollisionPolygon2D not found or wrong type")
	assert(ship_collision.polygon.size() > 0, "Ship CollisionPolygon2D has no points")
	
	# Verify Terrain StaticBody2D and its CollisionPolygon2D
	var terrain = instance.get_node("Terrain")
	assert(terrain is StaticBody2D, "Terrain StaticBody2D not found or wrong type")
	
	var terrain_collision = terrain.get_node("CollisionPolygon2D")
	assert(terrain_collision is CollisionPolygon2D, "Terrain CollisionPolygon2D not found or wrong type")
	assert(terrain_collision.polygon.size() > 0, "Terrain CollisionPolygon2D has no points")
	
	print("  ✓ Ship collision points: ", ship_collision.polygon.size())
	print("  ✓ Terrain collision points: ", terrain_collision.polygon.size())
	print("✅ Scene initialization test passed!")
	quit(0)
