extends Node3D

var camera_rotation_speed = 0.5
var camera_zoom_speed = 0.2
var min_fov = 20.0
var max_fov = 90.0
var rotation_target := Vector3.ZERO
var current_rotation := Vector3.ZERO
var default_fov = 75.0

# Mouse stuff is WIP
var mouse_sensitivity = 0.3
var enable_mouse_control = false

# Camera orbit bounds
var orbit_center := Vector3.ZERO
var orbit_distance := 5.0
var min_orbit_distance := 2.0
var max_orbit_distance := 10.0

var rocket_node : Node3D = null
var active_camera : Camera3D = null
@onready var room_camera : Camera3D = $RoomCamera
@onready var nose_camera : Camera3D = %RocketNoseCamera
@onready var side_camera : Camera3D = %RocketSideCamera
@onready var ground_camera : Camera3D = %RocketGroundCamera

var initial_camera_pos := Vector3.ZERO
var initial_camera_rot := Vector3.ZERO
var initial_distance := 5.0

func _ready():
	print("Setting up control room...")
	await get_tree().process_frame  # Wait for a frame to ensure all nodes are loaded
	
	# Set up each monitor with a different view
	var monitor_setups = [
		["NoseViewport", "Monitor1", nose_camera],  
		["SideViewport", "Monitor2", side_camera], 
		["BottomViewport", "Monitor3", ground_camera]    
	]

	# Set up each monitor and store their cameras
	for setup in monitor_setups:
		var viewport_name = setup[0]
		var monitor_name = setup[1]
		var camera = setup[2]
		
		camera = await setup_monitor(viewport_name, monitor_name, camera)
		setup_monitor_click_area(monitor_name, camera)

	room_camera.current = true
	
	print("Control room setup complete")

func setup_monitor(viewport_name: String, monitor_name: String, rocket_camera: Camera3D) -> Camera3D:
	var viewport = get_node(viewport_name)
	viewport.size = Vector2(1920, 1080)
	viewport.transparent_bg = false
	viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS

	print("Setting up viewport:", viewport_name)

	# Create a dummy camera in the SubViewport
	var viewport_camera = Camera3D.new()
	viewport.add_child(viewport_camera)
	viewport_camera.current = true

	# Create RemoteTransform3D to sync position/rotation
	var remote = RemoteTransform3D.new()
	remote.remote_path = viewport_camera.get_path()
	rocket_camera.add_child(remote)

	# Apply screen material
	var screen = get_node(monitor_name + "/Screen")
	var material = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(1, 1, 1)
	material.metallic = 0.0
	material.roughness = 1.0

	material.albedo_texture = viewport.get_texture()
	material.uv1_scale = Vector3(1, -1, 1)
	material.uv1_offset = Vector3(0, 0, 0)

	screen.set_surface_override_material(0, material)

	return rocket_camera  # Keep reference to the real camera

# Called when a monitor is clicked on
func setup_monitor_click_area(monitor_name: String, camera: Camera3D):
	var area = Area3D.new()
	var collision_shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(0.8, 0.5, 0.1)  
	collision_shape.shape = box_shape
	area.add_child(collision_shape)
	get_node(monitor_name).add_child(area)
	
	# Store camera reference in area's metadata
	area.set_meta("camera", camera)
	
	# Connect signal
	area.input_event.connect(
		func(camera, event, position, normal, shape_idx):
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				active_camera = area.get_meta("camera")
				rocket_node = active_camera.get_parent()
				 # Store initial camera state
				initial_camera_pos = active_camera.global_position
				initial_camera_rot = active_camera.global_rotation
				# Calculate initial distance and center
				orbit_center = rocket_node.global_position + Vector3.UP * 4
				initial_distance = active_camera.global_position.distance_to(orbit_center)
				orbit_distance = initial_distance
				# Reset rotation targets
				rotation_target = Vector3.ZERO
				current_rotation = Vector3.ZERO
				print("Activated camera for " + monitor_name)
	)
	
func reset_camera():
	if active_camera:
		rotation_target = Vector3.ZERO
		current_rotation = Vector3.ZERO
		active_camera.look_at(orbit_center)
		orbit_distance = 5.0  # Reset to default distance
		active_camera.fov = default_fov
		rocket_node = null
		active_camera = null
		enable_mouse_control = false
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		print("Camera control deactivated")

func _process(delta):
	if active_camera:
		if Input.is_action_pressed("zoom_in"):
			print(orbit_distance)
			orbit_distance = move_toward(orbit_distance, min_orbit_distance, camera_zoom_speed)
			active_camera.look_at(orbit_center)
			
		if Input.is_action_pressed("zoom_out"):
			print(orbit_distance)
			orbit_distance = move_toward(orbit_distance, max_orbit_distance, camera_zoom_speed)
			active_camera.look_at(orbit_center)
			
		# Mouse/keyboard input handling
		if Input.is_action_just_pressed("mouse_middle"):
			enable_mouse_control = !enable_mouse_control
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if enable_mouse_control else Input.MOUSE_MODE_VISIBLE
		
		# Calculate rotation input
		var rotation_input = Vector2.ZERO
		
		# Mouse-based rotation when enabled
		if enable_mouse_control:
			var mouse_motion = Input.get_last_mouse_velocity()
			rotation_input.x = -mouse_motion.x * mouse_sensitivity * delta
			rotation_input.y = -mouse_motion.y * mouse_sensitivity * delta
		
		# Keyboard-based rotation (world-space)
		if Input.is_action_pressed("ui_left"): rotation_input.x += camera_rotation_speed * delta
		if Input.is_action_pressed("ui_right"): rotation_input.x -= camera_rotation_speed * delta
		if Input.is_action_pressed("ui_up"): rotation_input.y -= camera_rotation_speed * delta
		if Input.is_action_pressed("ui_down"): rotation_input.y += camera_rotation_speed * delta
		
		# Update rotation targets (in world space)
		rotation_target.y += rotation_input.x
		rotation_target.x += rotation_input.y
		
		# Clamp vertical rotation to prevent flipping
		#rotation_target.x = clamp(rotation_target.x, -1.2, 1.2)
		
		# Smooth rotation
		#current_rotation = current_rotation.lerp(rotation_target, delta * 10.0) 
		current_rotation = rotation_target
		
		# Update orbit center to follow rocket
		orbit_center = rocket_node.global_position + Vector3.UP * 4
		
		# Calculate world-space orbit position
		var offset = Vector3.BACK * orbit_distance
		
		# Apply world-space rotations
		var basis = Basis()
		basis = basis.rotated(Vector3.UP, current_rotation.y)  # Rotate around world Y first
		basis = basis.rotated(Vector3.RIGHT, current_rotation.x)  # Then around world X
		offset = basis * offset
		
		# Update camera position and look target
		active_camera.global_position = orbit_center + offset
		active_camera.look_at(orbit_center, Vector3.UP)  # Force UP vector to maintain world orientation
		
		# Reset camera when ESC is pressed
		if Input.is_action_just_pressed("ui_cancel"):
			reset_camera()
