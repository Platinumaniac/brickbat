extends CharacterBody2D
class_name Player

var _speed = 5000

func _physics_process(delta: float) -> void:
	var move_input = Input.get_axis("move_left", "move_right")

	# no jumping for now, maybe later
	velocity = Vector2( move_input * _speed * delta,0)

	move_and_slide()
