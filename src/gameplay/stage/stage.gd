extends TileMapLayer
class_name Stage

const TILESET_DAY = preload("res://assets/tilesets/tileset0_day.png")

@export var spawn_marker: Marker2D
@export var animation_player: AnimationPlayer

func _ready() -> void:
	SignalBus.building_finished.connect(_on_building_finished)

func set_tileset_day() -> void:
	var source := tile_set.get_source(4) as TileSetAtlasSource
	if source == null:
		return
	source.texture = TILESET_DAY

func _on_building_finished(building: Building) -> void:
	if animation_player == null:
		return
	animation_player.play("WinAnim")
	get_tree().paused = true
	## win screen, next stage here

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
