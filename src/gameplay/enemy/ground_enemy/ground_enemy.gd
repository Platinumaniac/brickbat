extends Enemy

@onready var sprite: Sprite2D = %Sprite2D
@onready var animation_tree: AnimationTree = %AnimationTree

func _flip(flipped: bool) -> void:
	sprite.flip_h = flipped
	if flipped:
		sprite.offset.x = -16.5
	else:
		sprite.offset.x = 16.5

func _move_anim(next_position: Vector2) -> void:
	_flip((next_position - position).x < 0)

func _attack_anim() -> void:
	animation_tree.get("parameters/playback").travel("attack")
	await animation_tree.animation_finished

func _death_anim() -> void:
	animation_tree.get("parameters/playback").travel("death")
	await animation_tree.animation_finished
