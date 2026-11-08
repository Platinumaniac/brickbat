extends DumbEnemy

@onready var _sprite: Sprite2D = %Sprite2D
@onready var _animation_tree: AnimationTree = %AnimationTree
@onready var _building_box: Area2D = %BuildingBox

var is_at_building: bool

func _ready() -> void:
	_building_box.body_entered.connect(_on_building_collision)

func _flip(flipped: bool) -> void:
	_sprite.flip_h = flipped
	if flipped:
		_sprite.offset.x = -16.5
	else:
		_sprite.offset.x = 16.5

func _is_at_target() -> bool:
	return is_at_building

func _move_anim(next_position: Vector2) -> void:
	_flip((next_position - position).x < 0)

func _attack_anim() -> void:
	_animation_tree.get("parameters/playback").travel("attack")
	await _animation_tree.animation_finished

func _death_anim() -> void:
	_animation_tree.get("parameters/playback").travel("death")
	await _animation_tree.animation_finished

func _on_building_collision(building: Node2D):
	is_at_building = true
