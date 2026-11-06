extends Area2D
class_name Enemy

@export var max_health: float = 100
@export var power: float = 10
@export var attack_cooldown: float = 1

var _health: float = max_health
var _start_position: Vector2
var _target: Building
var _is_at_target: bool
var _current_cooldown: float = 0

func _ready() -> void:
	_start_position = position

	SignalBus.stage_initiated.connect(_on_stage_initiated)
	SignalBus.building_path_calculated.connect(_on_building_path_calculated)

func _process(delta: float) -> void:
	if _target && _is_at_target:
		if _target.build_progress > 0 && _current_cooldown == 0:
			_target.attack(power)
			_current_cooldown = attack_cooldown
		elif _current_cooldown > 0:
			_current_cooldown = clamp(_current_cooldown - delta, 0, attack_cooldown)

func attack(damage: float) -> void:
	_health = clamp(_health - damage, 0, max_health)
	if _health == 0:
		queue_free()

func _on_stage_initiated(_stage) -> void:
	SignalBus.building_path_requested.emit(_start_position)

func _on_building_path_calculated(start: Vector2, path: NavigationSystem.BuildingPath) -> void:
	_target = path.building
	if start == _start_position:
		while len(path.path) > 0:
			var tween = create_tween()
			tween.tween_property(self, "position", path.path.get(0), .5)
			await tween.finished
			path.path.remove_at(0)
		_is_at_target = true
