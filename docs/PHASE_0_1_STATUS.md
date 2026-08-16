# Phase 0 + 1 Status

**Completed:** 2026-08-16  
**Version:** 0.2.0

## Phase 0

| Item | Status |
|------|--------|
| Version stamp (`config/version` + menu label) | Done |
| Smoke test doc | Done (`docs/SMOKE_TEST.md`) |
| Release build notes | Done |
| Hardware guidance in README | Done |

## Phase 1

| Item | Status |
|------|--------|
| Drone visual kit (procedural X-frame) | Done |
| Donbas showcase art pass | Done |
| Lighting / tonemap on Donbas | Done |
| Gamepad + keyboard input merge | Done |
| Pilot Settings (rates, expo, invert, FOV, deadzone) | Done |
| FPV camera FOV + EW noise pack | Done |

## Explicitly unchanged

- `FlightModel.step()` force integration (accel/drag/gravity/wind/battery formulas)
- Target hit radii / score values
- Mission complete rules

## How to verify

1. Fresh import `project.godot` — menu shows **v0.2.0**
2. Pilot Settings → save → reopen values persist
3. Donbas — roads, denser structures, quad-shaped drone
4. Plug controller — left stick pitches/rolls
5. H shows updated help

## Next

Phase 2 (physics depth) requires **explicit approval** before `step()` changes.
