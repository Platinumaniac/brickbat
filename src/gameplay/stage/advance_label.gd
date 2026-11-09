extends Label
class_name AdvanceLabel

@export var fade_time: float = 0.4

var _tween: Tween

func _ready() -> void:
	modulate.a = 0.0
	visible = false

func fade_in(duration: float = fade_time) -> void:
	if _tween and _tween.is_valid():
		_tween.kill()
	visible = true
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 1.0, duration)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func fade_out(duration: float = fade_time) -> void:
	if _tween and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 0.0, duration)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	_tween.tween_callback(func(): visible = false)
