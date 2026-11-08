extends Area2D
class_name Enemy

@export var max_health: float = 20
@export var power: float = 10
@export var attack_cooldown: float = 1
@export var move_time: float = .5

var target_building: Building

var _health: float = max_health
var _current_cooldown: float = 0
var _is_attacking: bool
var _is_dead: bool

func _process(delta: float) -> void:
	if _is_at_target() && !_is_dead:
		if _current_cooldown == 0 && !_is_attacking:
			_is_attacking = true
			await _attack_anim()
			_current_cooldown = attack_cooldown
			_is_attacking = false
		elif _current_cooldown > 0:
			_current_cooldown = clamp(_current_cooldown - delta, 0, attack_cooldown)

func _is_at_target() -> bool:
	return false

func _move_anim(next_position: Vector2) -> void:
	pass

func attack_target() -> void:
	target_building.attack(power)

func _attack_anim() -> void:
	pass

func _death_anim() -> void:
	await get_tree().create_timer(1.0).timeout

func attack(damage: float) -> void:
	_health = clamp(_health - damage, 0, max_health)
	if _health == 0:
		_is_dead = true
		set_deferred("monitorable", false)
		await _death_anim()
		queue_free()
