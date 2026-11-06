extends Area2D
class_name Building

@export var size: Vector2i
@export var build_cost: float = 200
@export var progress_label: Label

var build_progress: float

func _update_label() -> void:
	if progress_label != null:
		var format_string = "%d%%"
		progress_label.text = format_string % (build_progress / build_cost * 100)
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

## goal of current quota from 0 to 1
var _quota_goal: float

var _build_progress: float
var _time_left: float
var _quota_running = false
var _blink_tween: Tween

func _ready() -> void:
	if timer_label != null:
		timer_label.visible = false

func start_quota() -> void:
	# if it were to start another quota mid blink
	if _blink_tween != null:
		_blink_tween.kill()

	var current_ratio := _build_progress / build_cost
	var raw_goal := maxf(quota_min, current_ratio * quota_growth)
	_quota_goal = clampf(ceilf(raw_goal / 0.05 - 0.0001) * 0.05, 0.0, 1.0)

	_time_left = time_limit
	_quota_running = true

	if timer_label != null:
		timer_label.visible = true
	_update_timer_label()
	_update_progress_label()

func _process(delta: float) -> void:
	if !_quota_running and Input.is_action_just_pressed("q"):
		$AudioStreamPlayer2D.play()
		start_quota()

	if not _quota_running:
		return

	_time_left -= delta
	_update_timer_label()

	if _time_left <= 0.0:
		_finish_quota(false)


func build(amount: float) -> void:
	_build_progress = clamp(_build_progress + amount, 0, build_cost)

	_update_progress_label()

	if build_progress == build_cost:
		SignalBus.building_finished.emit(self)

	# quota reached while the timer is still running = win
	if _quota_running and _build_progress >= build_cost * _quota_goal:
		_finish_quota(true)

func attack(damage: float) -> void:
	build_progress = clamp(build_progress - damage, 0, build_cost)

	_update_label()

	if build_progress == damage:
		SignalBus.building_destroyed.emit(self)
func _update_progress_label() -> void:
	if progress_label == null:
		return

	var progress_percent = _build_progress / build_cost * 100

	if _quota_running:
		var goal_percent := _quota_goal * 100
		progress_label.text = "%d%% / %d%%" % [progress_percent, goal_percent]
	else:
		progress_label.text = "%d%%" % progress_percent

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
