# MapLighting.gd — shared lighting presets for training maps
extends Node
class_name MapLighting

static func add_sun(parent: Node, energy: float = 1.3, rot_deg: Vector3 = Vector3(-55, 30, 0), shadows: bool = true) -> DirectionalLight3D:
	var light := DirectionalLight3D.new()
	light.name = "Sun"
	light.light_energy = energy
	light.shadow_enabled = shadows
	light.rotation_degrees = rot_deg
	parent.add_child(light)
	return light

static func add_fill(parent: Node, energy: float = 0.25, color: Color = Color(0.6, 0.7, 0.9)) -> OmniLight3D:
	var fill := OmniLight3D.new()
	fill.name = "Fill"
	fill.light_energy = energy
	fill.light_color = color
	fill.omni_range = 200.0
	fill.position = Vector3(0, 40, 0)
	parent.add_child(fill)
	return fill

static func apply_preset(parent: Node, preset: String) -> void:
	match preset:
		"field":
			add_sun(parent, 1.4, Vector3(-55, 30, 0), true)
		"urban":
			add_sun(parent, 1.2, Vector3(-48, 20, 0), true)
			add_fill(parent, 0.2, Color(0.5, 0.55, 0.7))
		"arctic":
			add_sun(parent, 0.95, Vector3(-35, 10, 0), false)
			add_fill(parent, 0.35, Color(0.7, 0.8, 0.95))
		"coastal":
			add_sun(parent, 1.35, Vector3(-52, 15, 0), true)
		"desert":
			add_sun(parent, 1.55, Vector3(-60, 25, 0), true)
		_:
			add_sun(parent, 1.3, Vector3(-55, 30, 0), true)
