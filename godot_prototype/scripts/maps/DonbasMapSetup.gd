# DonbasMapSetup.gd
# Self-contained open-field map with scattered structures

extends Node3D

@export var structure_count: int = 25

func _ready() -> void:
	print("DonbasMapSetup: Building open field...")
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for i in range(structure_count):
		var b := MeshInstance3D.new()
		b.name = "Structure_%d" % i
		var box := BoxMesh.new()
		var h := rng.randf_range(3.0, 12.0)
		box.size = Vector3(rng.randf_range(3, 8), h, rng.randf_range(3, 8))
		b.mesh = box
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.4, 0.35, 0.28)
		b.material_override = mat
		b.position = Vector3(rng.randf_range(-150, 150), h * 0.5, rng.randf_range(-150, 150))
		if Vector2(b.position.x, b.position.z).length() < 15.0:
			b.position.x += 25.0
		add_child(b)
	print("DonbasMapSetup: Done")
