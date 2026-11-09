extends Marker2D
class_name DumbEnemySpawner

## the enemy that will be spawned
@export var enemy_scene: PackedScene

## the amount of time between each enemy gets spawned
@export var spawn_delay: float = 10.0

var _enemy_instance: DumbEnemy
var _navigation_path: PackedVector2Array
var _target_building: Building

var _time_to_spawn: float

func _ready() -> void:
	spawn_delay /= SignalBus.scale_up(0.08, 40)
	_time_to_spawn = spawn_delay
	var untyped_instance = enemy_scene.instantiate()
	if untyped_instance == null:
		push_error("could not instantiate enemy scene")

	_enemy_instance = untyped_instance as DumbEnemy

	if _enemy_instance == null:
		push_error("enemy instance is not of DumbEnemy type")

	SignalBus.building_path_calculated.connect(_on_building_path_calculated)
	SignalBus.building_path_requested.emit(position)


func _process(delta: float) -> void:
	if _navigation_path != null:
		_time_to_spawn = clamp(_time_to_spawn - delta, 0, spawn_delay)
		if _time_to_spawn == 0:
			_spawn_enemy()
			_time_to_spawn = spawn_delay

func _spawn_enemy() -> void:
	var instance_duplicate = _enemy_instance.duplicate(DUPLICATE_USE_INSTANTIATION)
	instance_duplicate.global_position = global_position
	instance_duplicate.target_building = _target_building

	SignalBus.dummb_enemy_added.emit(instance_duplicate)

func _on_building_path_calculated(start: Vector2, path: NavigationSystem.BuildingPath) -> void:
	if start == global_position:
		_target_building = path.building
