extends Area2D
class_name Brick

@export var enemy_hit: AudioStreamRandomizer
@export var ground_hit: AudioStreamRandomizer
@export var building_hit: AudioStreamRandomizer

## how good the brick is at building and killing
@export var power: float = 20

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
	set_physics_process(false)
	set_deferred("monitoring", false)
	hide()
	await %BrickHitAudio.finished
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body is Stage:
		get_tree().call_group("shake_camera", "add_trauma", 0.4)
		play_hit_sound("ground")
		_shatter()
	elif body is Building:
		body.build(power)
		get_tree().call_group("shake_camera", "add_trauma", 0.5)
		play_hit_sound("building")
		_shatter()
	elif body is DumbEnemy:
		body.attack(power)
		play_hit_sound("enemy")
		SignalBus.score_changed.emit(+10)
		_shatter()

func _on_area_entered(area: Area2D) -> void:

	if area is Enemy:
		area.attack(power)
		play_hit_sound("enemy")
		_shatter()

func play_hit_sound(target_type: String) -> void:
	%BrickHitAudio.stop()

	match target_type:
		"enemy":
			%BrickHitAudio.stream = enemy_hit
		"ground":
			%BrickHitAudio.stream = ground_hit
		"building":
			%BrickHitAudio.stream = building_hit
		_:
			push_warning("Hit sound not found for: " + target_type)
			return
	%BrickHitAudio.play()
