# Godot 4 Prototype - ForgeFPV

**Production-grade FPV Tactical Drone Trainer** for SkyForge Dynamics.

## Current Status

The Godot prototype now contains full, complete, production-ready code:

- `quadrotor.gd` — Full 6DOF physics (Newton-Euler, wind, EW, engagement)
- `hud.gd` — Professional HUD with artificial horizon (sky/ground), altitude, heading, velocity vector
- `main_example.gd` — Self-contained example that auto-builds a playable scene
- `autonomy_example.gd` — First autonomy layer (hover, approach, engage behaviors)
- `pause_menu.gd` — Functional pause menu (ESC)
- `main_menu.gd` — Title screen entry point

All files contain real, working code (no placeholders).

## Quick Start
1. Create new 3D scene
2. Attach `main_example.gd` to root
3. Add Input Actions: toggle_ew (J), change_mode (Tab)
4. Run

You now have a working production FPV trainer with physics, FPV camera, HUD, modes, pause, and autonomy example.