extends TileMapLayer
class_name Building

@export var size: Vector2i
@export var build_cost: float = 200
@export var progress_label: Label
@export var brick_layer: TileMapLayer
@export var finished = false

@export_group("Quota")

## quota countdown.
@export var time_limit: float = 10.0

@export_subgroup("Blink")

## how long the timer blinks after the quota ends (both win or lose).
@export var blink_duration: float = 5.0

## lower = faster blinking.
@export var blink_interval: float = 0.35

## the minimum goal of the quota, used when it's lower than the minimum threshold.
@export_range(0.0, 1.0, 0.05) var quota_min: float = 0.25

## each quota's goal, current progress * this.
@export var quota_growth: float = 1.5

## remaining time label.
@export var timer_label: Label

const BRICK_CELLS: Array[Vector2i] = [Vector2i(0,1),Vector2i(1,1),Vector2i(2,1),Vector2i(3,1),Vector2i(4,1)]
const HALF_BRICK_CELLS: Array[Vector2i] = [Vector2i(0,0),Vector2i(1,0),Vector2i(2,0)]

## goal of current quota from 0 to 1
var _quota_goal: float

var _build_progress: float
var _time_left: float
var _quota_running = false
var _blink_tween: Tween

func _ready() -> void:
	if timer_label != null:
		timer_label.visible = false

func _process(delta: float) -> void:
	if !finished and !_quota_running and Input.is_action_just_pressed("q"):
		$AudioStreamPlayer2D.play()
		start_quota()

	if not _quota_running:
		return

	_time_left -= delta
	_update_timer_label()

	if _time_left <= 0.0:
		_finish_quota(false)

func start_quota() -> void:
	# if it were to start another quota mid blink
	if _blink_tween != null:
		_blink_tween.kill()

	var current_ratio := _build_progress / build_cost
	var raw_goal := maxf(quota_min, current_ratio * quota_growth)
	_quota_goal = clampf(ceilf(raw_goal * 20.0 - 0.0001) / 20.0, 0.0, 1.0)

	_time_left = time_limit
	_quota_running = true

	if timer_label != null:
		timer_label.visible = true
	_update_timer_label()
	_update_progress_label()

func build(amount: float) -> void:
	if !finished:
		_build_progress = clamp(_build_progress + amount, 0, build_cost)
		_update_progress_label()
		_update_brick_map()

	if !finished and _build_progress == build_cost:
		finished = true
		SignalBus.building_finished.emit(self)

	# quota reached while the timer is still running = win
	if _quota_running and _build_progress >= build_cost * _quota_goal - 0.001:
		_finish_quota(true)

func attack(damage: float) -> void:
	if !finished:
		_build_progress = clamp(_build_progress - damage, 0, build_cost)

		_update_label()
		_update_brick_map()

		if _build_progress == damage:
			$DestroyedAudio.play()
			SignalBus.building_destroyed.emit(self)

func _sort_by_position(a: Vector2i, b: Vector2i) -> bool:
	if a.y == b.y:
		return a.x < b.x
	else:
		return a.y < b.y


func _update_label() -> void:
	if progress_label != null:
		var format_string = "%d%%"
		progress_label.text = format_string % (_build_progress / build_cost * 100)

func _update_progress_label() -> void:
	if progress_label == null:
		return

	var progress_percent = _build_progress / build_cost * 100

	if _quota_running:
		var goal_percent := _quota_goal * 100
		progress_label.text = "%d%% / %d%%" % [progress_percent, goal_percent]
	else:
		progress_label.text = "%d%%" % progress_percent

func _update_brick_map() -> void:
	var outline_cells = get_used_cells()
	outline_cells.sort_custom(_sort_by_position)
	var brick_cells = brick_layer.get_used_cells()
	var build_ratio = _build_progress / build_cost
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	var double_layered_outline_cells: Array = []

	var outline_cell_index: int = 0
	var last_outline_layer_index: int = 0
	for cell in outline_cells:
		if outline_cell_index != 0:
			if outline_cells[outline_cell_index-1].y != cell.y:
				double_layered_outline_cells.append_array(outline_cells.slice(last_outline_layer_index, outline_cell_index))
				double_layered_outline_cells.append_array(outline_cells.slice(last_outline_layer_index, outline_cell_index))

				last_outline_layer_index = outline_cell_index
			elif outline_cell_index == len(outline_cells) - 1:
				double_layered_outline_cells.append_array(outline_cells.slice(last_outline_layer_index))
				double_layered_outline_cells.append_array(outline_cells.slice(last_outline_layer_index))

		outline_cell_index += 1
	var brick_amount = len(outline_cells) * build_ratio * 2


	for i in range(brick_amount):
		if i > brick_amount:
			break

		var cell = double_layered_outline_cells[-(i+1)]

		if cell not in brick_cells:
			brick_layer.set_cell(cell, 1, HALF_BRICK_CELLS.pick_random())
			brick_cells.push_back(cell)
		else:
			brick_layer.set_cell(cell, 1, BRICK_CELLS.pick_random())

		i += 1

	var brick_remove_index: int  = 0
	var bricks_to_remove: int = len(brick_cells) - brick_amount
	while bricks_to_remove > 0:
		var cell = brick_cells[-(brick_remove_index + 1)]

		var brick_coords = brick_layer.get_cell_atlas_coords(cell)

		if brick_coords in BRICK_CELLS:
			if bricks_to_remove >= 2:
				brick_layer.set_cell(cell)
				bricks_to_remove -= 2
			else:
				brick_layer.set_cell(cell, 1, HALF_BRICK_CELLS.pick_random())
				bricks_to_remove -= 1
		else:
			brick_layer.set_cell(cell)
			bricks_to_remove -= 1
		brick_remove_index += 1




# shows the remaining time as m:ss
func _update_timer_label() -> void:
	if timer_label == null:
		return

	var total_seconds = floori(maxf(_time_left, 0.0))
	timer_label.text = "%d:%02d" % [total_seconds / 60, total_seconds % 60]

func _finish_quota(won: bool) -> void:
	_quota_running = false
	_update_progress_label()
	SignalBus.quota_finished.emit(won)

	_blink_timer_label()

func _blink_timer_label() -> void:
	# yeah i know nothing about tweens
	if timer_label == null:
		return

	var loops = maxi(roundi(blink_duration / (blink_interval * 2.0)), 1)

	_blink_tween = create_tween().set_loops(loops)
	_blink_tween.tween_callback(timer_label.set_visible.bind(false))
	_blink_tween.tween_interval(blink_interval)
	_blink_tween.tween_callback(timer_label.set_visible.bind(true))
	_blink_tween.tween_interval(blink_interval)

	await _blink_tween.finished

	timer_label.visible = false
