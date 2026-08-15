# ForgeFPV

**American FPV Tactical Drone Trainer** — SkyForge Dynamics

Rate-mode FPV training across multiple theaters, Academy missions, aquatic low-alt practice, and an optional hivemind swarm demo. Built in **Godot 4**.

---

## Play (3 steps)

1. Install [Godot 4.7.x](https://godotengine.org/download) (standard build, not .NET)
2. Download ZIP from this repo → extract
3. Godot → **Import** → select `project.godot` → **F5**

Standalone Windows/Linux builds: see [docs/RELEASE_BUILD.md](docs/RELEASE_BUILD.md).

---

## Controls

| Action | Key |
|--------|-----|
| Pitch / Roll | W A S D |
| Yaw | Q / E |
| Throttle | Space / Ctrl |
| Pause | Esc |
| Help (in map) | H |
| EW toggle (training stressor) | J |

Fly into **red targets** to score.

---

## Features

- **7 free-play maps** — Donbas, Urban, Aquatic, Taiwan, Arctic, Border, LA Port
- **Academy Missions** — brief → fly → complete
- **Airframe select** — profiles applied on land training maps
- **Shared land core** — wind, weather, audio hooks, pause, scoring
- **Aquatic path** — buoyancy / current low-alt training
- **Hivemind Demo** — multi-team swarm (seek / ring / hold)

---

## Documentation

| Doc | Purpose |
|-----|---------|
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | **Living architecture** — layers, systems, extension patterns |
| [docs/CHANGE_POLICY.md](docs/CHANGE_POLICY.md) | What may change without approval |
| [docs/PRODUCT_ROADMAP.md](docs/PRODUCT_ROADMAP.md) | Sellable product gaps & priorities |
| [docs/DIRECTORY_MAP.md](docs/DIRECTORY_MAP.md) | Folder ownership |
| [docs/RELEASE_BUILD.md](docs/RELEASE_BUILD.md) | Export & release packaging |
| [CONTRIBUTING.md](CONTRIBUTING.md) | How to contribute safely |

---

## Project layout (short)

```
project.godot
scenes/ui/          → menus & mission UI
scenes/maps/        → runnable map entry points
godot_prototype/scripts/
  core/             → flight, wind, weather, scoring
  maps/             → BaseTrainingScene + theaters
  aquatic/          → water training
  swarm/            → hivemind
  ui/               → UI controllers
tools/              → offline Python utilities
docs/               → architecture & product docs
```

---

## Development policy

**Flight, control, and gameplay behavior are frozen** unless the product owner approves a change. Documentation, structure, and non-breaking production hardening are welcome.

---

## License / commercial use

Copyright © SkyForge Dynamics. All rights reserved unless a separate license file states otherwise. Contact the repository owner for distribution or commercial licensing.

**Repo:** https://github.com/jamest1665/ForgeFPV
