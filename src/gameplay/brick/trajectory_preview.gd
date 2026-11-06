extends Line2D
class_name TrajectoryPreview

# higher = longer line, i believe 90 to be sufficient but
# might need to be altered if it were to be a in a level with many slopes
@export var steps: int = 90

# we should also add the enemies layers if we want that
@export_flags_2d_physics var collision_mask: int = 1 | 4 | 8

@export_group("Bubbles")

@export var bubble_texture: Texture2D

@export var frames: int = 3

@export var spacing: float = 24.0

@export var bubble_scale: float = 1.0

## 0 if we want static.
@export var scroll_speed: float = 30.0

## bubblewise :).
@export var biggest_first: bool = false

## bubbles fade out and shrink this many pixels before the impact point. 0 = no fade.
@export var fade_distance: float = 40.0

@onready var _player: Player = get_parent() as Player

var _scroll := 0.0

func _ready() -> void:
	top_level = true
	global_position = Vector2.ZERO

	# don't use visible = false
	width = 0.0

func _process(delta: float) -> void:
	_update_path()

	_scroll = fmod(_scroll + scroll_speed * delta, spacing)
	queue_redraw()


func _update_path() -> void:
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
		query.collide_with_areas = true
		query.hit_from_inside = true
		query.exclude = [_player.get_rid()]
		var hit = space.intersect_ray(query)
		if hit:
			add_point(hit.position)
			return

		add_point(next_pos)
		pos = next_pos


func _draw() -> void:
	if bubble_texture == null or get_point_count() < 2:
		return

	var total_length := 0.0
	for i in range(1, get_point_count()):
		total_length += get_point_position(i - 1).distance_to(get_point_position(i))

	if total_length <= 0.0:
		return

	var frame_size := Vector2(bubble_texture.get_width() / float(frames), bubble_texture.get_height())

	var next_bubble := _scroll
	var travelled := 0.0

	for i in range(1, get_point_count()):
		var a := get_point_position(i - 1)
		var b := get_point_position(i)
		var segment_length := a.distance_to(b)

		while next_bubble <= travelled + segment_length:
			var t := (next_bubble - travelled) / segment_length
			var center := a.lerp(b, t)

			var progress := next_bubble / total_length
			var frame := mini(int(progress * frames), frames - 1)
			if biggest_first:
				frame = frames - 1 - frame

			var fade := 1.0
			if fade_distance > 0.0:
				fade = clampf((total_length - next_bubble) / fade_distance, 0.0, 1.0)

			if fade > 0.0:
				var draw_size := frame_size * bubble_scale * fade  # shrinks with the fade
				var source := Rect2(frame * frame_size.x, 0.0, frame_size.x, frame_size.y)
				draw_texture_rect_region(
					bubble_texture,
					Rect2(center - draw_size / 2.0, draw_size),
					source,
					Color(1, 1, 1, fade)
				)

			next_bubble += spacing

		travelled += segment_length
# <|:3
