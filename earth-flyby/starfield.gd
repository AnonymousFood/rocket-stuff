extends MultiMeshInstance3D

@export var star_count := 300
@export var distance := 3000.0
@export var star_radius := 5.0

func _ready():
	randomize()

	# Create white unshaded material
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color.WHITE
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	material_override = mat

	# Star mesh (now smaller, true spheres)
	var star_mesh := SphereMesh.new()
	star_mesh.radius = star_radius
	star_mesh.height = star_radius * 2.0
	star_mesh.radial_segments = 12
	star_mesh.rings = 8

	# MultiMesh config
	var mm := MultiMesh.new()
	mm.mesh = star_mesh
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.instance_count = star_count
	multimesh = mm

	# Scatter stars far away
	for i in star_count:
		var dir = Vector3(randf() * 2.0 - 1.0, randf() * 2.0 - 1.0, randf() * 2.0 - 1.0).normalized()
		var pos = dir * distance
		var xform = Transform3D(Basis(), pos)
		multimesh.set_instance_transform(i, xform)
