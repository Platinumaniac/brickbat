extends Node
class_name TerrainGenerator

signal chunks_extended(center_x: float)

const SOURCE := 4
const GRASS := Vector2i(21, 0)
const DIRT := Vector2i(21, 2)
const WIDTH := 44
const CENTER := 22
const DEPTH := 3
const ORIGIN := Vector2(-360, 144)
const MAX_RISE := 7
const MAX_DROP := 2
const GRASS_CHANCE := 0.75
const FOLLIAGE_GRASS := Vector2i(1, 0)

const SPAWNER_ATLAS_ID: int = 1
const GROUND_ENEMY_SPAWNER_ID: int = 1
const FLYER_SPAWNER_ID: int = 2

#probability for different tiles
const CHANGE_CHANCE := 0.3

#minimum same level tiles between changable ones
const MIN_RUN := 2

#for the players spawn point and the building
const FLAT_RADIUS := 4

#so two ramps never collide
const MIN_VALLEY := 4

#flats next to the seam of a new chunk
const SEAM_FLAT := 2

#how many chunks one press adds
const CHUNKS_PER_PRESS := 2


@export var target_layer: TileMapLayer

var _origin_cell: Vector2i
var _right_chunks := 0
var _left_height := 0
var _right_height := 0
var _spawner_cells: Array[Vector2i] = []
var _covered_tiles: Dictionary = {}


func _ready() -> void:
	generate_terrain()


func _get_layer() -> TileMapLayer:
	var layer: TileMapLayer = target_layer if target_layer else (get_parent() as TileMapLayer)
	if layer == null:
		push_warning("TerrainGenerator needs a TileMapLayer target.")
	return layer


func _fill_narrow_valleys(heights: Array[int]) -> void:
	var changed := true
	while changed:
		changed = false
		var i := 1
		while i < WIDTH - 1:
			var j := i
			while j + 1 < WIDTH and heights[j + 1] == heights[i]:
				j += 1
			if j < WIDTH - 1 and heights[i - 1] > heights[i] and heights[j + 1] > heights[i] and j - i + 1 < MIN_VALLEY:
				var fill: int = mini(heights[i - 1], heights[j + 1])
				for k in range(i, j + 1):
					heights[k] = fill
				changed = true
			i = j + 1


func generate_terrain() -> void:
	var layer := _get_layer()
	if layer == null:
		return

	var rng := RandomNumberGenerator.new()
	rng.randomize()

	layer.clear()
	_spawner_cells.clear()
	_covered_tiles.clear()
	_right_chunks = 0

	_origin_cell = layer.local_to_map(ORIGIN)
	var heights: Array[int] = _build_heights(rng)
	_left_height = heights[0]
	_right_height = heights[WIDTH - 1]

	_draw_chunk(layer, _origin_cell, heights)
	_generate_enemy_spawners(layer)


func extend_terrain() -> void:
	var layer := _get_layer()
	if layer == null:
		return

	var rng := RandomNumberGenerator.new()
	rng.randomize()

	_clear_spawners(layer)

	var last_chunk_origin := _origin_cell
	for i in CHUNKS_PER_PRESS:
		_right_chunks += 1
		last_chunk_origin = Vector2i(_origin_cell.x + _right_chunks * WIDTH, _origin_cell.y)
		var heights: Array[int] = _build_edge_heights(rng, _right_height)
		_draw_chunk(layer, last_chunk_origin, heights)
		_right_height = heights[WIDTH - 1]

	_generate_enemy_spawners(layer)

	var center_cell := Vector2i(last_chunk_origin.x + CENTER, last_chunk_origin.y)
	var center_x: float = layer.to_global(layer.map_to_local(center_cell)).x
	chunks_extended.emit(center_x)


func _draw_chunk(layer: TileMapLayer, chunk_origin: Vector2i, heights: Array[int]) -> void:
	for x in WIDTH:
		var top: int = chunk_origin.y - heights[x]
		for y in range(top, chunk_origin.y + DEPTH):
			layer.set_cell(Vector2i(chunk_origin.x + x, y), SOURCE, GRASS if y == top else DIRT)

	for x in WIDTH - 1:
		var s: int = heights[x + 1] - heights[x]
		if absi(s) != 1:
			continue
		var low_x: int = x if s == 1 else x + 1
		var row: int = chunk_origin.y - heights[low_x]
		var cx: int = chunk_origin.x + low_x
		var slope_x: int = 21 - s
		layer.set_cell(Vector2i(cx, row), SOURCE, Vector2i(slope_x, 1))
		layer.set_cell(Vector2i(cx, row - 1), SOURCE, Vector2i(slope_x, 0))

		var lx: int = low_x - s
		if lx >= 0 and lx < WIDTH and heights[lx] == heights[low_x]:
			layer.set_cell(Vector2i(chunk_origin.x + lx, row - 1), SOURCE, Vector2i(21 - 2 * s, 0))

	#TODO: add grass to a foreground layer
	#for x in WIDTH:
	#	if absi(x - CENTER) <= FLAT_RADIUS:
	#		continue #keep the spawn/building area clean and flat
	#	var top_cell := Vector2i(origin.x + x, origin.y - heights[x])
	#	if layer.get_cell_atlas_coords(top_cell) != GRASS:
	#		continue
	#	if layer.get_cell_source_id(top_cell + Vector2i.UP) != -1:
	#		continue
	#	if rng.randf() < GRASS_CHANCE:
	#		layer.set_cell(top_cell + Vector2i.UP, SOURCE, Vector2i(1, 0))

func _build_heights(rng: RandomNumberGenerator) -> Array[int]:
	var heights: Array[int] = []
	heights.resize(WIDTH)
	heights.fill(0)
	for dir: int in [1, -1]:
		var h := 0
		var run := 0
		var x: int = CENTER + dir
		while x >= 0 and x < WIDTH:
			run += 1
			if absi(x - CENTER) > FLAT_RADIUS and run >= MIN_RUN and rng.randf() < CHANGE_CHANCE:
				h = clampi(h + rng.randi_range(-1, 1), -MAX_DROP, MAX_RISE)
				run = 0
			heights[x] = h
			x += dir
	_fill_narrow_valleys(heights)
	return heights


func _build_edge_heights(rng: RandomNumberGenerator, seam_height: int) -> Array[int]:
	var heights: Array[int] = []
	heights.resize(WIDTH)
	heights.fill(seam_height)

	var h := seam_height
	var run := 0
	for x in WIDTH:
		run += 1
		if x >= SEAM_FLAT and run >= MIN_RUN and rng.randf() < CHANGE_CHANCE:
			h = clampi(h + rng.randi_range(-1, 1), -MAX_DROP, MAX_RISE)
			run = 0
		heights[x] = h

	_fill_narrow_valleys(heights)
	return heights


func _clear_spawners(layer: TileMapLayer) -> void:
	for cell in _spawner_cells:
		var old: Array = _covered_tiles.get(cell, [])
		if old.size() == 3 and old[0] != -1:
			layer.set_cell(cell, old[0], old[1], old[2])
		else:
			layer.erase_cell(cell)
	_spawner_cells.clear()
	_covered_tiles.clear()


func _place_spawner(layer: TileMapLayer, cell: Vector2i, spawner_id: int) -> void:
	_covered_tiles[cell] = [
		layer.get_cell_source_id(cell),
		layer.get_cell_atlas_coords(cell),
		layer.get_cell_alternative_tile(cell),
	]
	_spawner_cells.append(cell)
	layer.set_cell(cell, SPAWNER_ATLAS_ID, Vector2i.ZERO, spawner_id)

func _generate_enemy_spawners(layer: TileMapLayer) -> void:
	var left_x: int = _origin_cell.x
	var right_x: int = _origin_cell.x + (_right_chunks + 1) * WIDTH

	_place_spawner(layer, Vector2i(left_x, _origin_cell.y - _left_height), GROUND_ENEMY_SPAWNER_ID)
	_place_spawner(layer, Vector2i(right_x, _origin_cell.y - _right_height), GROUND_ENEMY_SPAWNER_ID)
	_place_spawner(layer, Vector2i(left_x, -5), FLYER_SPAWNER_ID)
	_place_spawner(layer, Vector2i(right_x, -5), FLYER_SPAWNER_ID)
