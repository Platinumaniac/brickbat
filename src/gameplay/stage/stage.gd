extends TileMapLayer
class_name Stage

@export var spawn_marker: Marker2D

func get_player_spawn() -> Vector2:
	if spawn_marker != null:
		return spawn_marker.global_position
	return Vector2.ZERO

func get_building_map() -> Dictionary[Vector2i, Building]:
	var building_map: Dictionary[Vector2i, Building] = {}

	for child in get_children():
		if child is Building:
			var building_position = local_to_map(child.position)
			var top_left = building_position - child.size / 2
			for x in range(top_left.x, top_left.x + child.size.x):
				for y in range(top_left.y, top_left.y + child.size.y):
					building_map.set(Vector2i(x, y), child)

	return building_map
