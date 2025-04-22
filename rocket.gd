extends CharacterBody3D

@export var thrust_power: float = 12.0
@export var wobble_strength: float = 0.2
@export var wobble_speed: float = 2.0
@export var parachute_deploy_height: float = 50.0
@export var air_resistance: float = 0.1
@export var parachute_drag: float = 2.0
@export var rotation_smoothing: float = 2.0
@export var parachute : PackedScene
@export var next_scene_path: String = "res://earth-flyby/world.tscn"

var velocity_y: float = 0.0
var gravity: float = -9.8
var time_elapsed: float = 0.0
var is_failing: bool = false
var failure_time: float
var spin_velocity: Vector3 = Vector3.ZERO
var flicker_start: bool = false
var particles_enabled: bool = true
var parachute_deployed: bool = false
var has_landed: bool = false
var engine_sputter_phase: int = 0
var current_parachute: Node3D = null

@onready var particles = $RocketExhaust
@onready var trail = $RocketTrail
@onready var initial_rotation = rotation

func _ready():
	randomize()
	failure_time = randf_range(10.0, 15.0)

func _physics_process(delta):
	time_elapsed += delta
	
	# Start failure sequence 2 seconds before failure
	if time_elapsed >= failure_time - 2.0 and !flicker_start:
		start_comedic_failure()
	
	if time_elapsed >= failure_time and !is_failing:
		start_failure()
	
	if not is_failing:
		normal_flight(delta)
	else:
		failing_flight(delta)
		check_parachute()
	
	move_and_slide()

func check_parachute():
	if global_position.y <= parachute_deploy_height and velocity_y < 0 and !parachute_deployed:
		deploy_parachute()

func deploy_parachute():
	parachute_deployed = true
	# Reduce spin dramatically
	spin_velocity *= 0.2
	
	# Create and position the parachute instance
	if parachute:
		current_parachute = parachute.instantiate()
		add_child(current_parachute)
		# Position and scale the parachute above the rocket
		current_parachute.position = Vector3(0, 11.2, 0)
		current_parachute.scale = Vector3(0.015, 0.015, 0.015)

func start_comedic_failure():
	flicker_start = true
	var comedy_sequence = create_tween()
	
	# Phase 1: Initial sputters (1.0 seconds)
	comedy_sequence.tween_callback(sputter_phase_1)
	comedy_sequence.tween_interval(1.0)
	
	# Phase 2: Longer recovery attempt (1.5 seconds)
	comedy_sequence.tween_callback(sputter_phase_2)
	comedy_sequence.tween_interval(1.5)
	
	# Phase 3: Final desperate attempts (1.0 seconds)
	comedy_sequence.tween_callback(sputter_phase_3)
	comedy_sequence.tween_interval(1.0)
	
	comedy_sequence.tween_callback(final_shutdown)

func sputter_phase_1():
	engine_sputter_phase = 1
	var sputter = create_tween()
	# Slower stuttering pattern
	for i in range(4):
		sputter.tween_callback(func(): set_particles(false))
		sputter.tween_interval(0.3)  # Longer off time
		sputter.tween_callback(func(): set_particles(true))
		sputter.tween_interval(0.4)   # Longer on time
		
func sputter_phase_2():
	engine_sputter_phase = 2
	set_particles(true)
	thrust_power *= 1.5
	wobble_strength *= 0.5

func sputter_phase_3():
	engine_sputter_phase = 3
	var final_sputter = create_tween()
	# More dramatic final coughs
	for i in range(3):
		final_sputter.tween_callback(func(): set_particles(false))
		final_sputter.tween_interval(0.5)  # Longer pauses
		final_sputter.tween_callback(func(): set_particles(true))
		final_sputter.tween_interval(0.6)   # Longer bursts
	
	# One last push
	#final_sputter.tween_callback(func():
		#set_particles(true)
		#thrust_power *= 2.0
	#)
	#final_sputter.tween_interval(0.5)  # Longer final burst

func final_shutdown():
	# Get all tweens and kill them
	var tweens = get_tree().get_processed_tweens()
	for tween in tweens:
		if tween.is_valid():
			tween.kill()
	
	# Force particles off
	set_particles(false)

func set_particles(enabled: bool):
	particles_enabled = enabled
	particles.emitting = enabled
	trail.emitting = enabled

func normal_flight(delta):
	var wobble_multiplier = 1.0
	if engine_sputter_phase == 1:
		wobble_multiplier = 2.0
	elif engine_sputter_phase == 2:
		wobble_multiplier = 0.5
	elif engine_sputter_phase == 3:
		wobble_multiplier = 3.0
	
	var wobble = Vector3(
		sin(time_elapsed * wobble_speed) * wobble_strength * wobble_multiplier,
		0,
		cos(time_elapsed * wobble_speed * 1.3) * wobble_strength * wobble_multiplier
	)
	
	var current_thrust = thrust_power
	if engine_sputter_phase > 0:
		current_thrust *= (1.0 + sin(time_elapsed * 8.0) * 0.5)
	
	velocity_y += current_thrust * delta
	velocity_y += gravity * delta
	velocity = Vector3(wobble.x, velocity_y, wobble.z)
	
	rotation.x = wobble.z * 0.1
	rotation.z = -wobble.x * 0.1

func failing_flight(delta):
	if has_landed:
		velocity = Vector3.ZERO
		return
		
	if parachute_deployed:
		# Smoothly rotate to upright position
		var target_rotation = Vector3(0, rotation.y, 0)  # Keep Y rotation for natural swaying
		rotation = rotation.lerp(target_rotation, delta * rotation_smoothing)
		
		# Apply heavy air resistance when parachute is deployed
		var drag_force = velocity * velocity.length() * parachute_drag
		velocity -= drag_force * delta
		
		# Add gentle swaying motion
		var sway = sin(time_elapsed * 0.5) * 0.1
		rotation.z = sway
	else:
		# Normal failing physics with some air resistance
		spin_velocity.x += randf_range(-2.0, 2.0) * delta
		spin_velocity.y += randf_range(-2.0, 2.0) * delta
		spin_velocity.z += randf_range(-2.0, 2.0) * delta
		
		# Apply spinning motion
		rotate_x(spin_velocity.x * delta)
		rotate_y(spin_velocity.y * delta)
		rotate_z(spin_velocity.z * delta)
		
		velocity -= velocity * air_resistance * delta
	
	# Check for ground contact
	if global_position.y <= 0.1:
		land()
		return
	
	# Apply gravity and terminal velocity
	var target_velocity = -20.0 if !parachute_deployed else -5.0
	velocity_y = move_toward(velocity_y, target_velocity, delta * 5.0)
	
	velocity = Vector3(
		spin_velocity.x * (2.0 if !parachute_deployed else 0.5),
		velocity_y,
		spin_velocity.z * (2.0 if !parachute_deployed else 0.5)
	)

func land():
	has_landed = true
	global_position.y = 0
	velocity = Vector3.ZERO
	spin_velocity = Vector3.ZERO
	
	# Make parachute fall off
	if current_parachute:
		# Remove from rocket and add to scene root
		remove_child(current_parachute)
		get_tree().root.add_child(current_parachute)
		# Set world position slightly behind rocket
		current_parachute.global_position = global_position + Vector3(0, 0, 2)
		# Add some physics to make it fall naturally
		if current_parachute is RigidBody3D:
			current_parachute.freeze = false
		current_parachute = null
	
	# Ensure rocket is perfectly upright
	var final_rotation = Vector3.ZERO
	final_rotation.y = rotation.y  # Keep final Y rotation
	rotation = final_rotation

func start_failure():
	var roll = randf()
	if roll < 0.5:
		is_failing = true
		spin_velocity = Vector3(
			randf_range(-1.0, 1.0),
			randf_range(-1.0, 1.0),
			randf_range(-1.0, 1.0)
		) * 5.0
	else:
		get_tree().change_scene_to_file(next_scene_path)
