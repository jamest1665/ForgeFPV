# ForgeFPV — Directory Map

Quick ownership guide. Prefer this over scrolling the full tree.

## Root

| Path | Role |
|------|------|
| `project.godot` | Project name, main scene, autoloads, input map |
| `export_presets.cfg` | Export targets |
| `README.md` | Public entry + play steps |
| `README-PLAY.md` | Minimal player card |
| `CONTRIBUTING.md` | Contribution / change rules |
| `docs/` | Architecture, policy, release, roadmap |
| `scenes/` | Runnable `.tscn` entry points |
| `godot_prototype/scripts/` | All GDScript |
| `tools/` | Offline Python; not loaded by Godot at runtime |

## Scripts by domain

| Path | Domain |
|------|--------|
| `scripts/core/` | FlightModel, GameState, wind, weather, audio, scoring, objectives |
| `scripts/maps/BaseTrainingScene.gd` | Shared land training loop |
| `scripts/maps/*TestScene.gd` | Per-theater land maps |
| `scripts/maps/aquatic/` | Flood map scene script |
| `scripts/aquatic/` | Water physics + aquatic vehicle |
| `scripts/swarm/` | Hivemind stack |
| `scripts/ui/` | Menus, pause, help, mission UI |
| `scripts/drone/` | Mesh visual, path trail |
| `scripts/Mission*.gd` | Mission model, DB, manager, selection |
| `scripts/scenarios/` | Scenario modifiers |
| `scripts/weather/` | Typhoon helper |

## Scenes

| Path | Role |
|------|------|
| `scenes/ui/MainMenu.tscn` | Boot UI |
| `scenes/ui/Mission*.tscn` | Academy flow |
| `scenes/maps/*.tscn` | Map entry points (script-driven worlds) |
| `scenes/maps/AutonomyDemo.tscn` | Swarm demo |

## Rule of thumb

- **Playable entry** always goes through `scenes/`.
- **Logic** lives under `godot_prototype/scripts/`.
- **Do not** put one-off flight math in UI scripts.
