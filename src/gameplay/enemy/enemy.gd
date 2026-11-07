extends Area2D
class_name Enemy

@export var max_health: float = 100
@export var power: float = 10
@export var attack_cooldown: float = 1
@export var move_time: float = .5

var navigation_path: PackedVector2Array
var target_building: Building

var _health: float = max_health
var _current_cooldown: float = 0

func _ready() -> void:
	_march()

func _process(delta: float) -> void:

	if target_building && len(navigation_path) == 0:
		if _current_cooldown == 0:
			target_building.attack(power)
			_current_cooldown = attack_cooldown
		elif _current_cooldown > 0:
			_current_cooldown = clamp(_current_cooldown - delta, 0, attack_cooldown)

func _march() -> void:
	while len(navigation_path) > 0:
		var tween = create_tween()
		tween.tween_property(self, "position", navigation_path[0], move_time)
		await tween.finished
		navigation_path.remove_at(0)

func attack(damage: float) -> void:
	_health = clamp(_health - damage, 0, max_health)
	if _health == 0:
		queue_free()
