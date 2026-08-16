# PilotSettings.gd — persistent pilot prefs (rates, expo, invert, sticks)
# Autoload. Does not change FlightModel.step dynamics — only input shaping.
extends Node

const CONFIG_PATH := "user://forgefpv_pilot.cfg"

var rate_pitch: float = 1.0
var rate_roll: float = 1.0
var rate_yaw: float = 1.0
var expo: float = 0.4
var deadzone: float = 0.05
var invert_pitch: bool = false
var invert_roll: bool = false
var invert_yaw: bool = false
var invert_throttle: bool = false
var fov: float = 100.0
var use_gamepad: bool = true
var throttle_axis_centered: bool = false  # false = stick up = more throttle (common gamepad)

func _ready() -> void:
	load_settings()
	print("PilotSettings ready v-config")

func load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(CONFIG_PATH) != OK:
		return
	rate_pitch = float(cfg.get_value("pilot", "rate_pitch", rate_pitch))
	rate_roll = float(cfg.get_value("pilot", "rate_roll", rate_roll))
	rate_yaw = float(cfg.get_value("pilot", "rate_yaw", rate_yaw))
	expo = float(cfg.get_value("pilot", "expo", expo))
	deadzone = float(cfg.get_value("pilot", "deadzone", deadzone))
	invert_pitch = bool(cfg.get_value("pilot", "invert_pitch", invert_pitch))
	invert_roll = bool(cfg.get_value("pilot", "invert_roll", invert_roll))
	invert_yaw = bool(cfg.get_value("pilot", "invert_yaw", invert_yaw))
	invert_throttle = bool(cfg.get_value("pilot", "invert_throttle", invert_throttle))
	fov = float(cfg.get_value("pilot", "fov", fov))
	use_gamepad = bool(cfg.get_value("pilot", "use_gamepad", use_gamepad))

func save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("pilot", "rate_pitch", rate_pitch)
	cfg.set_value("pilot", "rate_roll", rate_roll)
	cfg.set_value("pilot", "rate_yaw", rate_yaw)
	cfg.set_value("pilot", "expo", expo)
	cfg.set_value("pilot", "deadzone", deadzone)
	cfg.set_value("pilot", "invert_pitch", invert_pitch)
	cfg.set_value("pilot", "invert_roll", invert_roll)
	cfg.set_value("pilot", "invert_yaw", invert_yaw)
	cfg.set_value("pilot", "invert_throttle", invert_throttle)
	cfg.set_value("pilot", "fov", fov)
	cfg.set_value("pilot", "use_gamepad", use_gamepad)
	cfg.save(CONFIG_PATH)

func apply_expo(v: float) -> float:
	var x := clampf(v, -1.0, 1.0)
	var dz := deadzone
	if absf(x) < dz:
		return 0.0
	var sign := 1.0 if x >= 0.0 else -1.0
	var mag := (absf(x) - dz) / maxf(1.0 - dz, 0.001)
	var e := clampf(expo, 0.0, 0.95)
	return sign * (e * mag * mag * mag + (1.0 - e) * mag)

func shape_axis(raw: float, rate: float, invert: bool) -> float:
	var v := -raw if invert else raw
	return apply_expo(v) * rate
