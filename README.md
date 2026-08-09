# ForgeFPV

**American FPV Tactical Drone Trainer** — SkyForge Dynamics

## Play (3 steps)

1. Install [Godot 4.7.1](https://godotengine.org/download) (standard, not .NET)
2. Download ZIP from this repo → extract
3. Godot → **Import** → `project.godot` → **F5**

## Controls

| Action | Key |
|--------|-----|
| Pitch / Roll | W A S D |
| Yaw | Q / E |
| Throttle | Space / Ctrl |
| Menu | Esc |

Fly into **red targets** to score.

## Maps

1. Donbas Field  
2. Urban Canyon  
3. Aquatic Flood  
4. Taiwan Littoral  
5. Arctic High North  
6. Southern Border  
7. LA Megaport  

## Project layout (what matters)

```
project.godot
scenes/
  ui/MainMenu.tscn
  maps/DonbasTest.tscn
  maps/UrbanTest.tscn
  maps/aquatic_flood/AquaticTest.tscn
  maps/global_06_taiwan_littoral/TaiwanTest.tscn
  maps/arctic/ArcticTest.tscn
  maps/border/BorderTest.tscn
  maps/la_port/LAPortTest.tscn
godot_prototype/scripts/
  ui/MainMenu.gd
  maps/.../*TestScene.gd   ← each map's flight + targets + HUD
```

## Export

See `docs/RELEASE_BUILD.md` and `export_presets.cfg`.

**Repo:** https://github.com/jamest1665/ForgeFPV
