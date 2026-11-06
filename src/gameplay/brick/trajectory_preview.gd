extends Line2D
class_name TrajectoryPreview

# higher = longer line, i believe 90 to be sufficient but 
# might need to be altered if it were to be a in a level with many slopes
@export var steps: int = 90

# we should also add the enemies layers if we want that
@export_flags_2d_physics var collision_mask: int = 1

@onready var _player: Player = get_parent() as Player

func _ready() -> void:
	top_level = true
	global_position = Vector2.ZERO

func _process(_delta: float) -> void:
	clear_points()

	var delta = 1.0 / Engine.physics_ticks_per_second
	var pos: Vector2 = _player._brick_root.global_position
	var vel: Vector2 = _player.get_throw_velocity()
	var space = get_world_2d().direct_space_state

	add_point(pos)
	for i in steps:
		var next_pos = pos + vel * delta
		vel += Brick.ADDED_VELOCITY

		var query = PhysicsRayQueryParameters2D.create(pos, next_pos, collision_mask)
		var hit = space.intersect_ray(query)
		if hit:
			add_point(hit.position)
			return

		add_point(next_pos)
		pos = next_pos
# <|:3
