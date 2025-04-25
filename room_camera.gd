extends Camera3D

var shake_intensity := 0.3
var noise := FastNoiseLite.new()
var original_position : Vector3
var time_elapsed: float = 0.0

var shake_start: float = 5.0
var shake_end: float = 20.0

func _ready():
	noise.seed = randi()
	noise.frequency = 4.0
	original_position = position

func _process(delta):
	time_elapsed += delta
	
	if time_elapsed > shake_start and time_elapsed < shake_end:
		
		# Calculate shake intensity (fades out over duration)
		var current_intensity = shake_intensity * (1.0 - (time_elapsed / shake_end))
		
		# apply shake
		var shake = Vector3(
			noise.get_noise_2d(Time.get_ticks_msec() * 0.01, 0.0),
			noise.get_noise_2d(0.0, Time.get_ticks_msec() * 0.01),
			0.0
		) * current_intensity
		
		position = original_position + shake
	else:
		position = original_position
