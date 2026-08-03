# ForgeFPV

**American FPV Tactical Drone Trainer** — SkyForge Dynamics

High-fidelity FPV drone training simulator built in Godot 4.  
Rate-mode flight, wind, EW, swarm/hivemind scenarios, multiple battlefields, and an aquatic training module.

---

## Play in 3 Steps (Recommended)

1. Open **[Releases](https://github.com/jamest1665/ForgeFPV/releases)**
2. Download the ZIP for your OS (`ForgeFPV-Windows.zip` or `ForgeFPV-Linux.zip`)
3. Extract → double-click the executable

No Godot install required for players.  
Full details: **[README-PLAY.md](README-PLAY.md)**

---

## Run from Source (Developers)

**Requirements:** Godot 4.3+ (Forward+)

1. Clone or download this repository
2. Open Godot → Import → select `project.godot`
3. Press **F5** (or Play)

Main scene is already set to `res://scenes/ui/MainMenu.tscn`.

### Project Layout
```
project.godot
scenes/
  ui/MainMenu.tscn
  maps/DonbasTest.tscn
  maps/UrbanTest.tscn
  maps/aquatic_flood/AquaticTest.tscn
  player/PlayerDrone.tscn
godot_prototype/scripts/     ← all GDScript
docs/                        ← catalogs & module docs
```

---

## Features (Current)
- 6DoF Newton-Euler rate-mode flight model
- Wind + turbulence + EW jamming
- Hivemind swarm system (MultiMesh path)
- Multiple maps (Donbas, Urban, Taiwan scaffold, Flood Basin, more)
- Mission / scenario system + scoring + debrief
- Aquatic module (surface USV, hybrid, ROV)
- Full HUD, pause menu, help overlay, path trail

---

## Building Standalone Releases

See **[docs/RELEASE_BUILD.md](docs/RELEASE_BUILD.md)** for exact one-time setup and export steps.

Export presets are already included (`export_presets.cfg`).  
Once export templates are installed, generating Windows + Linux builds takes under a minute.

---

## Controls
| Action        | Key / Input              |
|---------------|--------------------------|
| Throttle      | Space / Ctrl or Triggers |
| Roll / Pitch  | WASD or Left Stick       |
| Yaw           | Q / E or Right Stick X   |
| EW Toggle     | J                        |
| Help          | H / F1                   |
| Pause         | ESC                      |

---

## License & Status
Active development. Core systems are production-structured.  
Standalone builds will be published on the Releases page as they are generated.

**Repo:** https://github.com/jamest1665/ForgeFPV