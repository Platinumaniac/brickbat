extends Area2D
class_name Brick

## how good the brick is at building and killing
@export var power: float = 10

const ADDED_VELOCITY = Vector2(0, 10)

## the direction the brick is moving in
var velocity: Vector2

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	position += velocity * delta

	# had to make it a constant so it can share with the preview
	velocity += ADDED_VELOCITY

	rotation = atan2(velocity.y, velocity.x)

## called when brick is broken
func _shatter() -> void:
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body is Stage:
		get_tree().call_group("shake_camera", "add_trauma", 0.4)
		_shatter()

func _on_area_entered(area: Area2D) -> void:
	if area is Building:
		area.build(power)
		get_tree().call_group("shake_camera", "add_trauma", 0.5)
		queue_free()
	elif area is Enemy:
		area.attack(power)
		queue_free()
