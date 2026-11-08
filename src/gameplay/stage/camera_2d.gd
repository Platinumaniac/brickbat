extends Camera2D
class_name ShakeCamera
# camera with trauma-based shake. add_trauma() to shake it

# trauma goes from 0 to 1 and decays over time
# shake strength is exponential, so small hits feel smaller and big hits feel bigger

var terrain_generator: TerrainGenerator
var player: Player

var _following := false
##PAININTHEASS
var _stop_x := INF
var _min_x := -INF

@export_group("Shake")
## maximum camera offset (in pixels) at full trauma.
@export var max_offset = Vector2(24, 16)

## maximum camera rotation (in radians) at full trauma.
@export var max_roll = 0.05

## effect decay per second. higher = shorter shake.
@export_range(0.1, 5.0, 0.05) var decay = 1.5

## lower = stronger.[br]
## not the most reliable thing i've written tho haha.
@export_range(1.0, 4.0, 0.1) var trauma_power = 3.0

## higher = more jittery.
@export var noise_speed = 20.0

var _trauma = 0.0
var _time = 0.0
var _noise = FastNoiseLite.new()


func _ready() -> void:
	add_to_group("shake_camera")

	_noise.seed = randi()
	_noise.frequency = 1.0

	_find_nodes()


func _find_nodes() -> void:
	var root := get_tree().current_scene
	if root == null:
		return

	if player == null:
		player = _find_by_class(root, Player) as Player

	if terrain_generator == null:
		terrain_generator = _find_by_class(root, TerrainGenerator) as TerrainGenerator
		if terrain_generator:
			terrain_generator.chunks_extended.connect(_on_chunks_extended)


func _find_by_class(node: Node, type: Variant) -> Node:
	if is_instance_of(node, type):
		return node
	for child in node.get_children():
		var found := _find_by_class(child, type)
		if found:
			return found
	return null


func _on_chunks_extended(center_x: float) -> void:
	if not _following:
		_min_x = global_position.x
	_stop_x = center_x
	_following = true


func _update_follow() -> void:
	if not _following or player == null:
		return
	if _min_x == -INF and terrain_generator:
		_min_x = terrain_generator.get_start_center_x()

	if player.global_position.x >= _stop_x:
		global_position.x = _stop_x  # lock it to the center of the chunk
		_following = false
		for preview in get_tree().current_scene.find_children("TrajectoryPreview*", "Line2D", true, false):
			preview.visible = true
		$GodText/AnimationPlayer.play_backwards("WinAnim")
	else:
		global_position.x = maxf(player.global_position.x, _min_x)


func _process(delta: float) -> void:
	# didn't work without this
	if player == null or terrain_generator == null:
		_find_nodes()

	_update_follow()
	_update_shake(delta)


func _update_shake(delta: float) -> void:
	if _trauma <= 0.0:
		return

	_trauma = maxf(_trauma - decay * delta, 0.0)
	_time += delta * noise_speed

	var shake = pow(_trauma, trauma_power)

	# different offsets so they aren't relevant
	offset = Vector2(
		max_offset.x * shake * _noise.get_noise_2d(_time, 0.0),
		max_offset.y * shake * _noise.get_noise_2d(_time, 100.0)
	)
	rotation = max_roll * shake * _noise.get_noise_2d(_time, 200.0)

	# settle back to rest once the shake ends
	if _trauma <= 0.0:
		offset = Vector2.ZERO
		rotation = 0.0


## adds the shake. around 0.2 is a light bump, 0.5 is solid, 1.0 is the max.
func add_trauma(amount: float) -> void:
	_trauma = minf(_trauma + amount, 1.0)
