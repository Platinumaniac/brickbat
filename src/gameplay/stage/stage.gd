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
			for cell in child.get_used_cells():
				var stage_cell = local_to_map(child.map_to_local(cell) + child.position)
				building_map.set(stage_cell, child)

	return building_map
