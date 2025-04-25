extends Label


var rocket
var label 
var world_env
var prev_speed = 0

var countdown_time := -10.0  # Start 10 seconds before launch
var launch_started := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rocket = get_node("%Rocket") #assign rocket node to rocket var
	world_env = get_node("/root/Main/WorldEnvironment")
	label = world_env.get_node("Label")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	countdown_time += delta
	var velocity = rocket.get_velocityY()
	var time = rocket.get_time()
	var distance = velocity * time
	var speed = 0
	var acceleration = 0

	if time != 0:
		speed = (distance/time)
		acceleration = -1 * round((speed - prev_speed) / time)
		if speed < 5:
			speed = round(speed)
			acceleration = round((speed - prev_speed) / time)
			prev_speed = speed
		else:
			speed = round(speed) * 100 
			acceleration = round((speed - prev_speed) / time)
			prev_speed = speed
	
	if speed != 0:
		label.text = "Speed: " + str(speed) + " km/h \n" + "Acceleration: " + str(acceleration) + " m/s\n"

	# Format countdown or count-up label
	var time_prefix = "T - 00:00:"
	var display_time = max(countdown_time, 0.0)
	if countdown_time >= 0:
		time_prefix = "T + "
		launch_started = true  # Optionally trigger stuff here

	var time_display = format_countdown(countdown_time)

	# Update the label
	label.text = time_display + "\nSpeed: " + str(speed) + " km/h\nAcceleration: " + str(acceleration) + " m/s²"
	
func format_countdown(seconds: float) -> String:
	var prefix = "T - "
	if seconds >= 0:
		prefix = "T + "
	
	var abs_time = abs(seconds)
	var hours = int(abs_time) / 3600
	var minutes = (int(abs_time) % 3600) / 60
	var secs = int(abs_time) % 60

	return prefix + str("%02d" % hours) + ":" + str("%02d" % minutes) + ":" + str("%02d" % secs)
