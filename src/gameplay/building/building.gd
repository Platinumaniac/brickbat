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

func build(amount: float) -> void:
	build_progress = clamp(build_progress + amount, 0, build_cost)

	_update_label()

	if build_progress == build_cost:
		SignalBus.building_finished.emit(self)

func attack(damage: float) -> void:
	build_progress = clamp(build_progress - damage, 0, build_cost)

	_update_label()

	if build_progress == damage:
		SignalBus.building_destroyed.emit(self)
