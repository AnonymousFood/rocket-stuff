extends Camera3D

var shake_time := 0.0
var shake_duration := 5.0
var shake_intensity := 0.3
var noise := FastNoiseLite.new()
var is_shaking := false
var original_position : Vector3

func _ready():
	noise.seed = randi()
	noise.frequency = 4.0
	original_position = position
	start_shake()

func _process(delta):
	if is_shaking:
		if shake_time < shake_duration:
			shake_time += delta
			
			# Calculate shake intensity (fade out over duration)
			var current_intensity = shake_intensity * (1.0 - (shake_time / shake_duration))
			
			# Apply shake
			var shake = Vector3(
				noise.get_noise_2d(Time.get_ticks_msec() * 0.01, 0.0),
				noise.get_noise_2d(0.0, Time.get_ticks_msec() * 0.01),
				0.0
			) * current_intensity
			
			position = original_position + shake
		else:
			is_shaking = false
			shake_time = 0.0
			position = original_position

func start_shake():
	is_shaking = true
	shake_time = 0.0
