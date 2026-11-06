extends TileMapLayer
class_name Stage

@export var spawn_marker: Marker2D

func get_player_spawn() -> Vector2:
	if spawn_marker != null:
		return spawn_marker.global_position
	return Vector2.ZERO
