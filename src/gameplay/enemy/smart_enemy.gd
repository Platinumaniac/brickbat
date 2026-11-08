extends Enemy
class_name SmartEnemy

var navigation_path: PackedVector2Array

func _ready() -> void:
	_march()

func _march() -> void:
	while len(navigation_path) > 0 && !_is_dead:
		_move_anim(navigation_path[0])
		var tween = create_tween()
		tween.tween_property(self, "position", navigation_path[0], move_time)
		await tween.finished
		navigation_path.remove_at(0)


func _is_at_target() -> bool:
	return target_building && len(navigation_path)
