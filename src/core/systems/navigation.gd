extends Node
class_name NavigationSystem


var _stage: Stage
var _nav_grid: AStarGrid2D = AStarGrid2D.new()
var _building_map: Dictionary[Vector2i, Building]

func _ready() -> void:

	_nav_grid.cell_size = Vector2i(16, 16)
	_nav_grid.region = Rect2i(-20, -12, 40, 24)
	_nav_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	_nav_grid.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	_nav_grid.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	_nav_grid.update()

	SignalBus.stage_initiated.connect(_on_stage_initiated)
	SignalBus.building_path_requested.connect(_on_building_path_requested)

func _sort_distance_to(a: Vector2i, b: Vector2i, reference: Vector2i):
	return a.distance_squared_to(reference) < b.distance_squared_to(reference)

class BuildingPath:
	func _init(new_path: PackedVector2Array, new_building: Building) -> void:
		path = new_path
		building = new_building

	var path: PackedVector2Array
	var building: Building

func _get_path_to_building(start_position: Vector2) -> BuildingPath:
	var building_positions = _building_map.keys()

	building_positions.sort_custom(_sort_distance_to.bind(start_position))

	var path: PackedVector2Array = _nav_grid.get_point_path(_stage.local_to_map(start_position), building_positions[0], true)
	var point_index: int = 0
	for point in path:
		path.set(point_index, point + Vector2(8, 8))
		point_index += 1


	return BuildingPath.new(path, _building_map[building_positions[0]])

func _on_stage_initiated(stage: Stage) -> void:
	_stage = stage
	_building_map = _stage.get_building_map()
	for cell in _stage.get_used_cells():
		if _stage.get_cell_source_id(cell) != 1:
			_nav_grid.set_point_solid(cell)

	for cell in _building_map.keys():
		_nav_grid.set_point_solid(cell)

func _on_building_path_requested(start_position: Vector2) -> void:
	SignalBus.building_path_calculated.emit(start_position, _get_path_to_building(start_position))
