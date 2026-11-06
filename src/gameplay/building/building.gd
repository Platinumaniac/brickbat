extends Area2D
class_name Building

@export var build_cost: float = 200
@export var progress_label: Label

var _build_progress: float

func build(amount: float) -> void:
	_build_progress = clamp(_build_progress + amount, 0, build_cost)

	if progress_label != null:
		var format_string = "%d%%"
		progress_label.text = format_string % (_build_progress / build_cost * 100)

	if _build_progress == build_cost:
		SignalBus.building_finished.emit(self)
