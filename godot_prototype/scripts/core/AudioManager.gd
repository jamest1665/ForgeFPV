# AudioManager.gd
# ForgeFPV — motor, wind, and EW audio layers driven by flight telemetry
# Works without external samples (silent until optional .ogg/.wav placed under res://audio/)

extends Node
class_name AudioManager

@export var master_volume_db: float = -6.0
@export var motor_volume_db: float = -8.0
@export var wind_volume_db: float = -14.0
@export var ew_volume_db: float = -10.0

var motor_player: AudioStreamPlayer
var wind_player: AudioStreamPlayer
var ew_player: AudioStreamPlayer

var _motor_level: float = 0.0
var _wind_level: float = 0.0
var _ew_level: float = 0.0
var _enabled: bool = true

const MOTOR_PATHS := ["res://audio/motor_loop.ogg", "res://audio/motor_loop.wav"]
const WIND_PATHS := ["res://audio/wind_loop.ogg", "res://audio/wind_loop.wav"]
const EW_PATHS := ["res://audio/ew_static.ogg", "res://audio/ew_static.wav"]

func _ready() -> void:
	motor_player = _make_player("Motor")
	wind_player = _make_player("Wind")
	ew_player = _make_player("EW")
	_try_load(motor_player, MOTOR_PATHS)
	_try_load(wind_player, WIND_PATHS)
	_try_load(ew_player, EW_PATHS)
	print("AudioManager ready (samples optional under res://audio/)")

func _make_player(p_name: String) -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	p.name = p_name
	p.bus = "Master"
	p.volume_db = -80.0
	add_child(p)
	return p

func _try_load(player: AudioStreamPlayer, paths: Array) -> void:
	for path in paths:
		if ResourceLoader.exists(path):
			var stream = load(path)
			if stream:
				if stream is AudioStream:
					# loop if supported
					if stream.has_method("set_loop"):
						stream.set_loop(true)
					elif "loop" in stream:
						stream.loop = true
				player.stream = stream
				print("AudioManager: loaded ", path)
				return
	print("AudioManager: no sample for ", player.name, " (place file under res://audio/)")

func set_enabled(on: bool) -> void:
	_enabled = on
	if not on:
		_stop_all()

func _stop_all() -> void:
	for p in [motor_player, wind_player, ew_player]:
		if p and p.playing:
			p.stop()
		if p:
			p.volume_db = -80.0

## Call each frame from map/flight with telemetry dictionary
## Expected keys: throttle (0-1), speed (m/s), battery (0-100)
## Optional: ew_active (bool), wind_strength (float)
func update_from_telemetry(t: Dictionary) -> void:
	if not _enabled:
		return
	var throttle := float(t.get("throttle", 0.0))
	var speed := float(t.get("speed", 0.0))
	var battery := float(t.get("battery", 100.0))
	var ew_active := bool(t.get("ew_active", false))
	var wind_strength := float(t.get("wind_strength", 0.0))

	# Motor: scales with throttle, drops when battery dead
	var motor_target := throttle
	if battery <= 0.0:
		motor_target = 0.0
	_motor_level = move_toward(_motor_level, motor_target, 0.08)
	_apply_layer(motor_player, _motor_level, motor_volume_db, 0.85 + _motor_level * 0.35)

	# Wind: airspeed + ambient wind field
	var wind_target := clampf(speed / 40.0 + wind_strength * 0.15, 0.0, 1.0)
	_wind_level = move_toward(_wind_level, wind_target, 0.05)
	_apply_layer(wind_player, _wind_level, wind_volume_db, 0.9 + _wind_level * 0.2)

	# EW static: on/off with slight intensity ramp
	var ew_target := 1.0 if ew_active else 0.0
	_ew_level = move_toward(_ew_level, ew_target, 0.1)
	_apply_layer(ew_player, _ew_level, ew_volume_db, 1.0)

func _apply_layer(player: AudioStreamPlayer, level: float, base_db: float, pitch: float) -> void:
	if player == null or player.stream == null:
		return
	if level < 0.02:
		if player.playing:
			player.stop()
		player.volume_db = -80.0
		return
	if not player.playing:
		player.play()
	player.volume_db = base_db + master_volume_db + linear_to_db(clampf(level, 0.02, 1.0))
	player.pitch_scale = clampf(pitch, 0.7, 1.4)

func play_one_shot(path: String, volume_db: float = 0.0) -> void:
	if not ResourceLoader.exists(path):
		return
	var stream = load(path)
	if stream == null:
		return
	var p := AudioStreamPlayer.new()
	p.stream = stream
	p.volume_db = volume_db + master_volume_db
	add_child(p)
	p.play()
	p.finished.connect(p.queue_free)

func set_ew_active(active: bool) -> void:
	# convenience when telemetry dict not available
	update_from_telemetry({"throttle": _motor_level, "speed": _wind_level * 40.0, "ew_active": active})
