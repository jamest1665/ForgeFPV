# ForgeFPV — Release Build Instructions

Goal: Produce standalone Windows + Linux builds with the fewest possible steps after one-time setup.

## Versioning

- Tag releases as `vMAJOR.MINOR.PATCH` (example: `v0.1.0`).
- Note Godot editor version used in the release notes (e.g. 4.7.1-stable).
- Do not commit exported binaries into the source tree.

## One-Time Setup (Godot 4.3+)

1. Open Godot 4.3+ (match team standard; document in release notes).
2. **Editor → Manage Export Templates** — install templates for that exact version.
3. Open this project (`project.godot`).

Export presets live in `export_presets.cfg`.

## Export

### Windows

1. **Project → Export**
2. Select **Windows Desktop**
3. **Export Project** → `ForgeFPV.exe` (Godot also writes `.pck`)

### Linux

1. **Project → Export**
2. Select **Linux/X11**
3. **Export Project** → `ForgeFPV.x86_64`

## Package for GitHub Releases

**ForgeFPV-Windows.zip**
```
ForgeFPV.exe
ForgeFPV.pck
README-PLAY.md
```

**ForgeFPV-Linux.zip**
```
ForgeFPV.x86_64
ForgeFPV.pck
README-PLAY.md
```

Upload ZIPs to a new GitHub Release. Prefer attaching artifacts only to Releases, not to `main`.

## Smoke test (before publishing)

- [ ] Main menu loads
- [ ] Donbas free-play: flight + at least one target score
- [ ] ESC pause → Resume / Main Menu
- [ ] Academy: one mission briefing → launch → complete or quit cleanly
- [ ] Aquatic map loads and returns to menu via ESC
- [ ] Hivemind Demo loads (optional if tagged pre-release)

## Player experience after release

1. Open Releases
2. Download platform ZIP
3. Extract → run executable

No installer required for early builds. SmartScreen may warn on unsigned Windows binaries—signing is a product P0 (see PRODUCT_ROADMAP.md).

## Notes

- Keep `export_presets.cfg` in the repo for consistent settings.
- Flight/control changes are not part of “export polish”; see CHANGE_POLICY.md.
