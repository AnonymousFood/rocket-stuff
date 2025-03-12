extends Node3D

var active_camera = null
var camera_rotation_speed = 1.0
var camera_move_speed = 2.0
var camera_zoom_speed = 1.0  # Add zoom speed variable
var min_fov = 20.0  # Minimum field of view (more zoomed in)
var max_fov = 90.0  # Maximum field of view (more zoomed out)

func _ready():
	print("Setting up control room...")
	
	# Set up each monitor with a different view
	var monitor_setups = [
		["NoseViewport", "Monitor1", Vector3(0, 15, 0)],      # Nose camera
		["SideViewport", "Monitor2", Vector3(20, 10, 20)],    # Side view near windmill
		["BottomViewport", "Monitor3", Vector3(0, 2, 0)]      # Under thrusters
	]
	
	# Set up each monitor and store their cameras
	for setup in monitor_setups:
		var viewport_name = setup[0]
		var monitor_name = setup[1]
		var camera_pos = setup[2]
		
		var camera = await setup_monitor(viewport_name, monitor_name, camera_pos)
		setup_monitor_click_area(monitor_name, camera)
	
	print("Control room setup complete")

func setup_monitor(viewport_name: String, monitor_name: String, camera_position: Vector3) -> Camera3D:
	var viewport = get_node(viewport_name)
	viewport.size = Vector2(1920, 1080)  # Increased from 800x500 to 1080p
	viewport.transparent_bg = false
	viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	
	# Create a separate world for the viewport
	var world = World3D.new()
	viewport.world_3d = world
	
	# Create environment for the viewport world
	var environment = Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.2, 0.2, 0.2)
	
	var world_environment = WorldEnvironment.new()
	world_environment.environment = environment
	viewport.add_child(world_environment)
	
	# Create main scene instead of test scene
	var main_scene = preload("res://main.tscn").instantiate()
	viewport.add_child(main_scene)
	
	# Add camera with specific positioning
	var camera = Camera3D.new()
	camera.name = viewport_name + "Camera"
	
	# Handle different camera setups
	match viewport_name:
		"NoseViewport":
			# Find the rocket node and attach camera to it
			var rocket = main_scene.get_node("Rocket")
			rocket.add_child(camera)
			# Position camera relative to rocket (slightly above and in front)
			camera.position = Vector3(0, 2, 2)
			camera.rotation = Vector3(-0.4, PI, 0)  # Look slightly down at rocket
		"BottomViewport":
			viewport.add_child(camera)
			camera.position = Vector3(0, 2, 0)
			camera.look_at(Vector3(0, 10, 0))
		"SideViewport":
			viewport.add_child(camera)
			camera.position = Vector3(20, 10, 20)
			camera.look_at(Vector3(0, 10, 0))
	
	camera.current = true
	
	# Add light
	var light = DirectionalLight3D.new()
	light.transform = Transform3D(Basis.from_euler(Vector3(-0.5, 0.5, 0)), Vector3(0, 10, 10))
	viewport.add_child(light)
	
	await get_tree().process_frame
	
	# Set up monitor screen material
	var screen = get_node(monitor_name + "/Screen")
	var material = StandardMaterial3D.new()
	
	# Material settings
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(1, 1, 1)
	material.metallic = 0.0
	material.roughness = 1.0
	
	# Assign viewport texture
	material.albedo_texture = viewport.get_texture()
	
	# UV settings
	material.uv1_scale = Vector3(1, -1, 1)
	material.uv1_offset = Vector3(0, 0, 0)
	
	# Apply material to screen
	screen.set_surface_override_material(0, material)
	
	return camera  # Return the camera for click area setup

func setup_monitor_click_area(monitor_name: String, camera: Camera3D):
	var area = Area3D.new()
	var collision_shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(0.8, 0.5, 0.1)  # Match monitor screen size
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
				print("Activated camera for " + monitor_name)
	)

func _process(delta):
	if active_camera:
		var rotated = false
		var zoomed = false
		
		# Vertical rotation (looking up/down)
		if Input.is_action_pressed("ui_up"):
			active_camera.rotate_x(-camera_rotation_speed * delta)
			rotated = true
		if Input.is_action_pressed("ui_down"):
			active_camera.rotate_x(camera_rotation_speed * delta)
			rotated = true
			
		# Horizontal rotation (looking left/right)
		if Input.is_action_pressed("ui_left"):
			active_camera.rotate_y(camera_rotation_speed * delta)
			rotated = true
		if Input.is_action_pressed("ui_right"):
			active_camera.rotate_y(-camera_rotation_speed * delta)
			rotated = true
			
		# Zoom in/out with - and =
		if Input.is_action_pressed("zoom_in"):  # = key
			active_camera.fov = clamp(active_camera.fov - camera_zoom_speed, min_fov, max_fov)
			zoomed = true
		if Input.is_action_pressed("zoom_out"):  # - key
			active_camera.fov = clamp(active_camera.fov + camera_zoom_speed, min_fov, max_fov)
			zoomed = true
			
		if rotated:
			# Clamp vertical rotation to prevent over-rotation
			var rotation = active_camera.rotation_degrees
			rotation.x = clamp(rotation.x, -89, 89)
			active_camera.rotation_degrees = rotation
			print("Camera rotation: ", active_camera.rotation_degrees)
			
		if zoomed:
			print("Camera FOV: ", active_camera.fov)
		
		# Reset camera when ESC is pressed
		if Input.is_action_just_pressed("ui_cancel"):
			# Reset rotation and zoom
			active_camera.look_at(Vector3(0, 1, 0))
			active_camera.fov = 75  # Reset to default FOV
			active_camera = null
			print("Camera control deactivated") 
