# ForgeFPV

**American FPV Tactical Drone Trainer** — SkyForge Dynamics  
**Version:** 0.2.0 (Phase 0+1)

Rate-mode FPV training across multiple theaters, Academy missions, aquatic low-alt practice, and an optional hivemind swarm demo. Built in **Godot 4**.

---

## Play (3 steps)

1. Install [Godot 4.7.x](https://godotengine.org/download) (standard build, not .NET)
2. Download ZIP from this repo → extract
3. Godot → **Import** → select `project.godot` → **F5**

Standalone builds: [docs/RELEASE_BUILD.md](docs/RELEASE_BUILD.md).

---

## Controls

| Action | Keyboard | Gamepad / RC (joy 0) |
|--------|----------|----------------------|
| Pitch / Roll | W A S D | Left stick |
| Yaw | Q / E | Right stick X |
| Throttle | Space / Ctrl | Right stick Y or triggers |
| Pause | Esc | — |
| Help | H | — |
| EW stress | J | — |

Tune rates, expo, invert, FOV under **Pilot Settings**. Fly into **red targets** to score.

**Showcase map:** Donbas Field (Phase 1 art pass).

---

## Hardware (honest guidance)

| | Minimum | Comfortable |
|--|---------|-------------|
| OS | Windows 10 64-bit / modern Linux | Windows 11 |
| CPU | 4-core (e.g. i5-7400 / Ryzen 5 1600) | 6-core or better |
| RAM | 8 GB | 16 GB |
| GPU | OpenGL 3.3 / Vulkan capable, 2 GB VRAM | GTX 1060 / RX 5600 class or better |
| Storage | ~500 MB source project | + space for exports |

Gamepad or FPV radio (mapped as a game controller) strongly recommended for training value.

---

## Documentation

| Doc | Purpose |
|-----|---------|
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Living architecture |
| [docs/CHANGE_POLICY.md](docs/CHANGE_POLICY.md) | Frozen vs open changes |
| [docs/UFDS_COMPETITIVE_ROADMAP.md](docs/UFDS_COMPETITIVE_ROADMAP.md) | Equal/better vs UFDS plan |
| [docs/PRODUCT_ROADMAP.md](docs/PRODUCT_ROADMAP.md) | Product gaps |
| [docs/SMOKE_TEST.md](docs/SMOKE_TEST.md) | Pre-release checklist |
| [docs/RELEASE_BUILD.md](docs/RELEASE_BUILD.md) | Export packaging |
| [CONTRIBUTING.md](CONTRIBUTING.md) | How to contribute |

---

## Development policy

**Flight `step()` dynamics stay frozen** unless approved. Phase 1 only extended **input** (sticks + settings shaping) and **presentation**.

**Repo:** https://github.com/jamest1665/ForgeFPV
