extends TileMapLayer
class_name Stage

const TILESET_DAY = preload("res://assets/tilesets/tileset0_day.png")
const stage_theme = preload("res://audio/Music/BB_Construction Jam 2026_Main Theme_V1.mp3")
const TILESET_NIGHT = preload("res://assets/tilesets/tileset0_night.png")

@export var spawn_marker: Marker2D
@export var animation_player: AnimationPlayer
@export var GameMusic: AudioStreamPlayer

var can_advance := false
var can_restart := false
var _total_buildings := 0
var _results: Dictionary = {}

func _ready() -> void:
	var GameMusic := get_tree().current_scene.find_child("AudioStreamPlayer", true, false) as AudioStreamPlayer
	GameMusic.stream = stage_theme
	GameMusic.play()
	SignalBus.building_finished.connect(_on_building_finished)
	SignalBus.building_destroyed.connect(_on_building_destroyed)
	_spawn_extra_towers()
	_total_buildings = _get_buildings().size()

var _level_over := false

func _on_building_finished(building: Building) -> void:
	get_tree().call_group("shake_camera", "add_trauma", 1.2)
	_check_level_end()

func _on_building_destroyed(building: Building) -> void:
	get_tree().call_group("shake_camera", "add_trauma", 1.2)
	_check_level_end()

func _check_level_end() -> void:
	if _level_over:
		return
	var any_destroyed := false
	for b in _get_buildings():
		if not (b.finished or b.destroyed):
			return
		if b.destroyed:
			any_destroyed = true
	_level_over = true
	if any_destroyed:
		_lose()
	else:
		_win()

func _win() -> void:
	get_tree().paused = true
	if animation_player != null and animation_player.has_animation("WinAnim"):
		animation_player.play("WinAnim")
	else:
		can_advance = true

func _lose() -> void:
	get_tree().paused = true
	$Label2.fade_in(0.4)
	can_restart = true

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"WinAnim":
			$Label2.fade_in(0.4)
			can_advance = true
@export var building_scene: PackedScene
@onready var terrain: TerrainGenerator = $TerrainGenerator

func _spawn_extra_towers() -> void:
	var existing := _get_buildings()
	if existing.is_empty() or building_scene == null:
		return
	for col in terrain.get_extra_spot_offsets():
		var b := building_scene.instantiate() as Building
		add_child(b)
		b.position = existing[0].position + Vector2(col * tile_set.tile_size.x, 0)

func _get_buildings() -> Array[Building]:
	var result: Array[Building] = []
	for child in get_children():
		if child is Building:
			result.append(child)
	return result

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
	for dumb_enemy_spawner in get_tree().current_scene.find_children("*", "DumbEnemySpawner", true, false):
		dumb_enemy_spawner.queue_free()
	for enemy in get_tree().current_scene.find_children("*", "Enemy", true, false):
		enemy.queue_free()
	for dumb_enemy in get_tree().current_scene.find_children("*", "DumbEnemy", true, false):
		dumb_enemy.queue_free()

func get_player_spawn() -> Vector2:
	if spawn_marker != null:
		return spawn_marker.global_position
	return Vector2.ZERO

func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("space"):
		return
	if can_advance:
		_next_level()
	elif can_restart:
		_restart()

func _next_level() -> void:
	can_advance = false
	SignalBus.level += 1
	Transition.change_level("Level %d" % SignalBus.level, false)

func _restart() -> void:
	can_restart = false
	SignalBus.score = 0
	SignalBus.level = 1
	Transition.change_level("He needed to keep going...", true)

func get_building_map() -> Dictionary[Vector2i, Building]:
	var building_map: Dictionary[Vector2i, Building] = {}

	for child in get_children():
		if child is Building:
			for cell in child.get_used_cells():
				var stage_cell = local_to_map(child.map_to_local(cell) + child.position)
				building_map.set(stage_cell, child)

	return building_map
