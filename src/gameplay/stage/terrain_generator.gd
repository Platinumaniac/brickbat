extends Node
class_name TerrainGenerator

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

#probability for different tiles
const CHANGE_CHANCE := 0.3

#minimum same level tiles between changable ones
const MIN_RUN := 2

#for the players spawn point and the building
const FLAT_RADIUS := 4

#so two ramps never collide
const MIN_VALLEY := 4


@export var target_layer: TileMapLayer


func _ready() -> void:
	generate_terrain()


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
	var layer: TileMapLayer = target_layer if target_layer else (get_parent() as TileMapLayer)
	if layer == null:
		push_warning("TerrainGenerator needs a TileMapLayer target.")
		return

	var rng := RandomNumberGenerator.new()
	rng.randomize()

	layer.clear()
	var origin: Vector2i = layer.local_to_map(ORIGIN)
	var heights: Array[int] = _build_heights(rng)

	for x in WIDTH:
		var top: int = origin.y - heights[x]
		for y in range(top, origin.y + DEPTH):
			layer.set_cell(Vector2i(origin.x + x, y), SOURCE, GRASS if y == top else DIRT)

	for x in WIDTH - 1:
		var s: int = heights[x + 1] - heights[x]
		if absi(s) != 1:
			continue
		var low_x: int = x if s == 1 else x + 1
		var row: int = origin.y - heights[low_x]
		var cx: int = origin.x + low_x
		var slope_x: int = 21 - s
		layer.set_cell(Vector2i(cx, row), SOURCE, Vector2i(slope_x, 1))
		layer.set_cell(Vector2i(cx, row - 1), SOURCE, Vector2i(slope_x, 0))

		var lx: int = low_x - s
		if lx >= 0 and lx < WIDTH and heights[lx] == heights[low_x]:
			layer.set_cell(Vector2i(origin.x + lx, row - 1), SOURCE, Vector2i(21 - 2 * s, 0))
	for x in WIDTH:
		if absi(x - CENTER) <= FLAT_RADIUS:
			continue #keep the spawn/building area clean and flat
		var top_cell := Vector2i(origin.x + x, origin.y - heights[x])
		if layer.get_cell_atlas_coords(top_cell) != GRASS:
			continue
		if layer.get_cell_source_id(top_cell + Vector2i.UP) != -1:
			continue
		if rng.randf() < GRASS_CHANCE:
			layer.set_cell(top_cell + Vector2i.UP, SOURCE, Vector2i(1, 0))
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
