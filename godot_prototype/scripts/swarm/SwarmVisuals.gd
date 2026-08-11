# SwarmVisuals.gd — team colors and simple status markers
extends RefCounted
class_name SwarmVisuals

const TEAM_COLORS := [
	Color(0.3, 0.8, 1.0),
	Color(1.0, 0.4, 0.25),
	Color(0.4, 0.95, 0.45),
	Color(0.95, 0.85, 0.2),
	Color(0.75, 0.45, 0.95),
]

static func color_for_team(team_id: int) -> Color:
	if TEAM_COLORS.is_empty():
		return Color.WHITE
	return TEAM_COLORS[team_id % TEAM_COLORS.size()]

static func apply_team_color(drone: SimpleDrone, team_id: int) -> void:
	if drone == null:
		return
	drone.team_id = team_id
	drone.body_color = color_for_team(team_id)
	for c in drone.get_children():
		if c is MeshInstance3D and c.material_override is StandardMaterial3D:
			(c.material_override as StandardMaterial3D).albedo_color = drone.body_color
