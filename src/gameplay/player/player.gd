extends CharacterBody2D
class_name Player

@export var brick_scene: PackedScene

@onready var _brick_root: Node2D = %BrickRoot

var _speed: float = 5000
var _throw_speed: float = 400

var _mouse_position: Vector2

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_mouse_position = event.global_position

	elif event.is_action_pressed("throw_brick"):
		var viewport_rect = get_viewport().get_visible_rect()
		var centered_mouse_position: Vector2 = _mouse_position - viewport_rect.size / 2
		_throw_brick((centered_mouse_position - global_position).normalized() * _throw_speed)


func _physics_process(delta: float) -> void:
	var move_input = Input.get_axis("move_left", "move_right")

	# no jumping for now, maybe later
	velocity = Vector2( move_input * _speed * delta,0)

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
