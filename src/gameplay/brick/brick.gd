extends Area2D
class_name Brick

## how good the brick is at building and killing
@export var power: float = 10

## the direction the brick is moving in
var velocity: Vector2

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	position += velocity * delta
	velocity += Vector2(0, 10)

	rotation = atan2(velocity.y, velocity.x)

func _on_body_entered(body: Node2D) -> void:
	if body is TileMapLayer:
		queue_free()
