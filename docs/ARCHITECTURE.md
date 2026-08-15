# ForgeFPV — Living Architecture

**Status:** Living document  
**Last updated:** 2026-08-15  
**Owner:** SkyForge Dynamics (ForgeFPV)  
**Rule:** Flight, control, and gameplay behavior are **frozen** unless explicitly approved. See [CHANGE_POLICY.md](CHANGE_POLICY.md).

---

## 1. Purpose

ForgeFPV is an American FPV tactical trainer built in **Godot 4**. It provides:

- Rate-mode single-pilot flight training across multiple theaters
- Academy mission loop (select → brief → fly → complete)
- Optional hivemind / swarm demo
- Aquatic low-altitude training with water interaction

This document describes how the system is structured so engineers can extend it without breaking the playable core.

---

## 2. Runtime entry & high-level flow

```
project.godot
  main_scene → scenes/ui/MainMenu.tscn
  autoloads  → GameState, MissionManager

MainMenu
  ├─ Free-play maps (1–7)
  ├─ Academy Missions → MissionSelection → MissionBriefing → map → MissionComplete
  ├─ Select Airframe / Scenario / Pilot Brief
  └─ Hivemind Demo → AutonomyDemo.tscn
```

**Land maps** extend `BaseTrainingScene` (shared flight, wind, weather, audio, HUD, pause, missions).  
**Aquatic** uses `AquaticVehicle` + `WaterPhysicsManager` (separate physics path by design).

---

## 3. Layer model

| Layer | Responsibility | Primary location |
|-------|----------------|------------------|
| **Presentation** | Menus, HUD, pause, briefing, complete | `godot_prototype/scripts/ui/`, `scenes/ui/` |
| **Session / mission** | Run state, mission catalog, start/finish | `GameState` (autoload), `MissionManager` (autoload), `Mission*.gd` |
| **Training maps** | World build, targets, map-specific props | `scripts/maps/*TestScene.gd`, `scenes/maps/` |
| **Shared training core** | Flight loop, scoring, objectives, FX | `scripts/maps/BaseTrainingScene.gd`, `scripts/core/` |
| **Flight model** | Rate-mode dynamics (frozen behavior) | `scripts/core/FlightModel.gd` |
| **Aquatic** | Water surface, buoyancy, current | `scripts/aquatic/` |
| **Swarm** | AI drones, boids, ring formation | `scripts/swarm/` |
| **Tools (offline)** | City JSON gen, polar formation math | `tools/` |

---

## 4. Core systems (reference)

### 4.1 Flight (do not change without approval)

- **`FlightModel`** (`RefCounted`): position, velocity, yaw/pitch/roll, throttle, battery, wind input, `read_input` / `step`.
- **Controls:** WASD pitch/roll, Q/E yaw, Space/Ctrl throttle (also mirrored in `project.godot` input map).
- **`BaseTrainingScene`**: owns player node, applies `FlightModel`, feeds wind, updates HUD/audio, pause (ESC), EW toggle (J), help (H).

### 4.2 Environment

- **`WindManager`**: base wind + turbulence presets.
- **`WeatherSystem`**: clear → typhoon presets; fog/ambient; syncs wind when present.
- **`WindParticleSystem`**: visual dust/streaks.
- **`MapLighting`**: shared sun/fill helpers (optional use in map builders).

### 4.3 Mission loop

- **`Mission`**: resource fields (id, map, scene_path, targets, time limit, scenario).
- **`MissionDatabase`**: built-in Academy catalog.
- **`MissionManager`**: start, telemetry to debrief, complete/fail → `MissionComplete.tscn`.
- **`ScenarioManager`**: score/wind multipliers by scenario id.

### 4.4 Aquatic

- **`WaterPhysicsManager`**: surface height, depth, current, buoyancy/drag.
- **`AquaticVehicle`**: `FlightModel` + water forces + FPV camera.
- **`AquaticTestScene`**: flood map wiring (not on `BaseTrainingScene`).

### 4.5 Swarm

- **`SimpleDrone` / `SwarmAgent` / `SwarmManager` / `HivemindSwarm`**
- **`TangentialController`**: ring orbits; Python twin under `tools/swarm/`.

---

## 5. Directory map (what belongs where)

```
ForgeFPV/
├── project.godot                 # Godot project + autoloads + input
├── export_presets.cfg            # Windows/Linux export
├── README.md                     # Product + play entry
├── CONTRIBUTING.md               # How to change safely
├── docs/
│   ├── ARCHITECTURE.md           # This file (living)
│   ├── CHANGE_POLICY.md          # Frozen vs open zones
│   ├── PRODUCT_ROADMAP.md        # Sellable readiness
│   ├── DIRECTORY_MAP.md          # File ownership
│   └── RELEASE_BUILD.md          # Export / release packaging
├── scenes/
│   ├── ui/                       # Menus & mission UI scenes
│   ├── maps/                     # Runnable map .tscn entry points
│   └── player/                   # Optional player scene assets
├── godot_prototype/scripts/
│   ├── core/                     # Flight, wind, weather, scoring, state
│   ├── maps/                     # BaseTrainingScene + per-map scripts
│   ├── aquatic/                  # Water path
│   ├── swarm/                    # Hivemind
│   ├── drone/                    # Visual + trail
│   ├── ui/                       # UI controllers
│   ├── scenarios/                # Scenario modifiers
│   └── weather/                  # Typhoon helper
└── tools/                        # Offline Python utilities (not required at runtime)
```

---

## 6. Extension patterns (safe)

### New land map (preferred)

1. Create `scripts/maps/<Name>TestScene.gd` extending `BaseTrainingScene`.
2. Set `map_name`, `wind_preset`, `weather_preset`, `body_color` in `_init()`.
3. Implement `_build_world()` and `_build_targets()` only.
4. Add `scenes/maps/<Name>Test.tscn` pointing at that script.
5. Wire a MainMenu button + optional `MissionDatabase` entry.

### New Academy mission

- Add via `MissionDatabase._register_defaults()` (or future data file).
- Point `scene_path` at an existing playable map scene.

### New weather preset

- Prefer extending `WeatherSystem.set_preset` match arms + `list_presets()`.
- Extreme coastal: `TyphoonPreset` or preset id `"typhoon"`.

---

## 7. Autoloads

| Name | Script | Role |
|------|--------|------|
| `GameState` | `scripts/core/GameState.gd` | Selected map/drone, score, telemetry snapshot |
| `MissionManager` | `scripts/MissionManager.gd` | Active mission lifecycle |

Do not add autoloads that own per-frame flight logic without architecture review.

---

## 8. Frozen behavior zones

Unless approved in writing (see CHANGE_POLICY):

- `FlightModel.read_input` / `step` dynamics and default gains
- Land map control bindings and rate-mode feel
- Target proximity scoring success conditions for existing missions
- Aquatic buoyancy/current integration contract with `FlightModel`

Documentation, folder hygiene, menus copy, export docs, and **additive** systems are open.

---

## 9. Document maintenance

Update this file when:

- A new layer or autoload is introduced
- Map ownership pattern changes (e.g. all maps on BaseTrainingScene including aquatic)
- A frozen zone is explicitly unfrozen and behavior ships

Keep sections short; link out to PRODUCT_ROADMAP for backlog, not architecture history novels.
