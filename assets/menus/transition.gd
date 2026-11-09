extends CanvasLayer

@export var fade_time: float = 0.5
@export var hold_time: float = 1.0

@onready var rect: ColorRect = $ColorRect
@onready var label: Label = $ColorRect/Label

var _busy := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 100
	rect.modulate.a = 0.0
	rect.visible = false


func change_level(text: String, restart: bool) -> void:
	if _busy:
		return
	_busy = true

	if restart:
		$ColorRect/Label2.visible = false
	else:
		$ColorRect/Label2.visible = true
	label.text = text
	rect.visible = true
	rect.mouse_filter = Control.MOUSE_FILTER_STOP

	var fade_in := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	fade_in.tween_property(rect, "modulate:a", 1.0, fade_time)
	await fade_in.finished

	get_tree().reload_current_scene()
	await get_tree().process_frame
	await get_tree().process_frame

	await get_tree().create_timer(hold_time).timeout

	get_tree().paused = false

	var fade_out := create_tween()
	fade_out.tween_property(rect, "modulate:a", 0.0, fade_time)
	await fade_out.finished

	rect.visible = false
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_busy = false
