extends Camera2D
class_name ShakeCamera
# camera with trauma-based shake. add_trauma() to shake it

# trauma goes from 0 to 1 and decays over time
# shake strength is exponential, so small hits feel smaller and big hits feel bigger

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


func _process(delta: float) -> void:
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


## adds the shake. around 0.2 is a light bump, 0.5 is solid, 1.0 is the max.
func add_trauma(amount: float) -> void:
	_trauma = minf(_trauma + amount, 1.0)
