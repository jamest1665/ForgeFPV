# TyphoonPreset.gd — extreme coastal storm parameters for WeatherSystem / WindManager
extends RefCounted
class_name TyphoonPreset

const PRESET_ID := "typhoon"

## Apply typhoon conditions onto a WeatherSystem instance
static func apply_to_weather(weather: WeatherSystem) -> void:
	if weather == null:
		return
	# Use internal fields via set_preset if extended, else push values after storm base
	weather.set_preset("storm")
	# Intensify beyond standard storm
	if weather.has_method("get") or true:
		weather.set("current_preset", PRESET_ID)
	# Direct bias push (WeatherSystem stores private vars — use public API where possible)
	weather._wind_bias = Vector3(14.0, 1.2, 9.0)
	weather._turbulence_scale = 3.2
	weather._fog_density = 0.014
	weather._visibility = 0.22
	weather._precip = 1.0
	if weather.env:
		weather.env.fog_enabled = true
		weather.env.fog_density = weather._fog_density
		weather.env.background_color = Color(0.12, 0.14, 0.18)
		weather.env.ambient_light_color = Color(0.25, 0.28, 0.32)
		weather.env.ambient_light_energy = 0.22
		weather.env.fog_light_color = Color(0.3, 0.32, 0.35)
	weather._sync_wind_manager()
	weather.weather_changed.emit(PRESET_ID)
	print("TyphoonPreset applied")

## Apply extreme wind onto WindManager
static func apply_to_wind(wm: WindManager) -> void:
	if wm == null:
		return
	wm.base_wind = Vector3(14.0, 1.2, 9.0)
	wm.turbulence = 2.8
	wm.enabled = true

## Parameter dictionary for missions / UI
static func as_dict() -> Dictionary:
	return {
		"id": PRESET_ID,
		"display_name": "Typhoon",
		"wind": Vector3(14.0, 1.2, 9.0),
		"turbulence": 2.8,
		"fog_density": 0.014,
		"visibility": 0.22,
		"precip": 1.0,
		"notes": "Extreme coastal cyclone — high lateral wind, heavy precip, low visibility."
	}

static func apply_to_scene(root: Node) -> void:
	if root == null:
		return
	var weather = root.find_child("WeatherSystem", true, false)
	if weather is WeatherSystem:
		apply_to_weather(weather)
	var wm = root.find_child("WindManager", true, false)
	if wm is WindManager:
		apply_to_wind(wm)
