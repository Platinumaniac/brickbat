extends TileMapLayer
class_name Stage

const TILESET_DAY = preload("res://assets/tilesets/tileset0_day.png")
const TILESET_NIGHT = preload("res://assets/tilesets/tileset0_night.png")

@export var spawn_marker: Marker2D
@export var animation_player: AnimationPlayer

var can_advance = false

func _ready() -> void:
	SignalBus.building_finished.connect(_on_building_finished)
	SignalBus.building_destroyed.connect(_on_building_destroyed)

func set_tileset() -> void:
	var source := tile_set.get_source(4) as TileSetAtlasSource
	if source == null:
		return
	if source.texture == TILESET_DAY:
		source.texture = TILESET_NIGHT
	else:
		source.texture = TILESET_DAY

func free_all_enemies() -> void:
	for enemy_spawner in get_tree().current_scene.find_children("*", "EnemySpawner", true, false):
		enemy_spawner.queue_free()
		print("1")
	for enemy in get_tree().current_scene.find_children("*", "Enemy", true, false):
		enemy.queue_free()

func _on_building_finished(building: Building) -> void:
	if animation_player == null:
		return
	get_tree().call_group("shake_camera", "add_trauma", 1.2)
	animation_player.play("WinAnim")
	get_tree().paused = true
	## win screen, next stage here

func _on_building_destroyed(building: Building) -> void:
	get_tree().call_group("shake_camera", "add_trauma", 1.2)

func get_player_spawn() -> Vector2:
	if spawn_marker != null:
		return spawn_marker.global_position
	return Vector2.ZERO
	
func _input(event: InputEvent) -> void:
	if can_advance and Input.is_action_just_pressed("space"):
		for preview in get_tree().current_scene.find_children("TrajectoryPreview*", "Line2D", true, false):
			preview.visible = false
		get_tree().paused = false
		$TerrainGenerator.extend_terrain()
		can_advance = false

func get_building_map() -> Dictionary[Vector2i, Building]:
	var building_map: Dictionary[Vector2i, Building] = {}

	for child in get_children():
		if child is Building:
			for cell in child.get_used_cells():
				var stage_cell = local_to_map(child.map_to_local(cell) + child.position)
				building_map.set(stage_cell, child)

	return building_map


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "WinAnim":
		can_advance = true
