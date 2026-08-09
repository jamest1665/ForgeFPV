# UrbanMapSetup.gd
# Self-contained urban map builder

extends Node3D

@export var building_count: int = 40
@export var map_size: float = 200.0

func _ready() -> void:
	print("UrbanMapSetup: Building urban block...")
	_generate_buildings()
	print("UrbanMapSetup: Done (", building_count, " buildings)")

func _generate_buildings() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for i in range(building_count):
		var b := MeshInstance3D.new()
		b.name = "Building_%d" % i
		var box := BoxMesh.new()
		var w := rng.randf_range(4.0, 12.0)
		var d := rng.randf_range(4.0, 12.0)
		var h := rng.randf_range(8.0, 35.0)
		box.size = Vector3(w, h, d)
		b.mesh = box
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(rng.randf_range(0.2, 0.45), rng.randf_range(0.2, 0.4), rng.randf_range(0.25, 0.5))
		b.material_override = mat
		b.position = Vector3(rng.randf_range(-map_size * 0.5, map_size * 0.5), h * 0.5, rng.randf_range(-map_size * 0.5, map_size * 0.5))
		if Vector2(b.position.x, b.position.z).length() < 20.0:
			b.position.x += 30.0 if b.position.x >= 0 else -30.0
		add_child(b)
