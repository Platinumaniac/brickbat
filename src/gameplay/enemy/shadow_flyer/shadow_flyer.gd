extends Enemy

@onready var _sprite: Sprite2D = %Sprite2D
@onready var _animation_tree: AnimationTree = %AnimationTree
@onready var _fall_box: Area2D = %FallBox

const FALL_SPEED: float = 200
const FALL_TIME: float = 10.0

var _is_falling: bool

func _process(delta: float) -> void:
	super._process(delta)
	if _is_falling:
		position.y += delta * FALL_SPEED

func _flip(flipped: bool) -> void:
	_sprite.flip_h = flipped
	if flipped:
		_sprite.offset.x = -4
	else:
		_sprite.offset.x = 4

func _move_anim(next_position: Vector2) -> void:
	_flip((next_position - position).x < 0)

func _attack_anim() -> void:
	print("flyer attack")
	_animation_tree.get("parameters/playback").travel("attack")
	await _animation_tree.animation_finished

func _death_anim() -> void:
	_animation_tree.get("parameters/playback").travel("death")
	await _animation_tree.animation_finished
	_is_falling = true
	await get_tree().create_timer(FALL_TIME).timeout
