extends Enemy

@onready var _sprite: Sprite2D = %Sprite2D
@onready var _animation_tree: AnimationTree = %AnimationTree

func _flip(flipped: bool) -> void:
	_sprite.flip_h = flipped
	if flipped:
		_sprite.offset.x = -16.5
	else:
		_sprite.offset.x = 16.5

func _move_anim(next_position: Vector2) -> void:
	_flip((next_position - position).x < 0)

func _attack_anim() -> void:
	_animation_tree.get("parameters/playback").travel("attack")
	await _animation_tree.animation_finished

func _death_anim() -> void:
	_animation_tree.get("parameters/playback").travel("death")
	await _animation_tree.animation_finished
