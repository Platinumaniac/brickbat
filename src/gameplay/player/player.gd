extends CharacterBody2D
class_name Player

@export var brick_scene: PackedScene

@onready var _brick_root: Node2D = %BrickRoot
@onready var _animation_tree: AnimationTree = %AnimationTree
@onready var _sprite: Sprite2D = %Sprite2D

var _speed: float = 5000
var _throw_speed: float = 400
var _mouse_position: Vector2
var _is_throwing: bool = false
var _last_direction: float = 0

func _ready() -> void:
	_animation_tree.animation_finished.connect(_on_animation_finished)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_mouse_position = event.global_position

	elif event.is_action_pressed("throw_brick") && !_is_throwing:
		var throw_velocity = get_throw_velocity()
		_flip(throw_velocity.x > 0)
		_animation_tree.get("parameters/playback").travel("throw")
		_throw_brick(throw_velocity)
		_is_throwing = true


# moved here so the preview can read it
func get_throw_velocity() -> Vector2:
	var viewport_rect = get_viewport().get_visible_rect()
	var centered_mouse_position: Vector2 = _mouse_position - viewport_rect.size / 2
	return (centered_mouse_position - global_position).normalized() * _throw_speed

func play_footstep() -> void:
	$FootstepAudio.stop()
	$FootstepAudio.play()

func _physics_process(delta: float) -> void:
	var move_input = Input.get_axis("move_left", "move_right")

	if move_input != 0:
		_last_direction = move_input

	if !_is_throwing:
		_flip(_last_direction > 0)

	_animation_tree.set("parameters/walk_space/blend_position", move_input)

	# no jumping for now, maybe later
	velocity = Vector2( move_input * _speed * delta,0)

	if _is_throwing:
		velocity = Vector2.ZERO

	move_and_slide()

func _throw_brick(velocity: Vector2) -> void:
	if brick_scene == null:
		push_error("brick scene not chosen")
		return

	var brick_instance = brick_scene.instantiate()
	if brick_instance == null:
		push_error("brick could not be instantiated")
		return

	var typed_brick_instance = brick_instance as Brick
	if typed_brick_instance == null:
		push_error("brick instance not of Brick type")
		return

	typed_brick_instance.velocity = velocity
	typed_brick_instance.global_position = _brick_root.global_position

	_brick_root.add_child(typed_brick_instance)

func _flip(flipped: bool) -> void:
	_sprite.flip_h = flipped
	if flipped:
		_sprite.offset.x = -3
	else:
		_sprite.offset.x = 0

func _on_animation_finished(animation_name) -> void:
	if animation_name == "throw":
		_is_throwing = false
