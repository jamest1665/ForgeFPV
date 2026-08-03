# ForgeFPV — Release Build Instructions

Goal: Produce standalone Windows + Linux builds with the fewest possible steps after the one-time setup.

## One-Time Setup (Godot 4.3+)

1. Open Godot 4.3+
2. Go to **Editor → Manage Export Templates**
3. Download and install the templates that match your Godot version
4. Open this project (`project.godot`)

Export presets are already configured in `export_presets.cfg`.

## Export (After Setup)

### Windows
1. **Project → Export**
2. Select **Windows Desktop**
3. Click **Export Project**
4. Save as `ForgeFPV.exe` (Godot will also write the `.pck`)

### Linux
1. **Project → Export**
2. Select **Linux/X11**
3. Click **Export Project**
4. Save as `ForgeFPV.x86_64`

## Package for GitHub Releases

Create two ZIPs:

**ForgeFPV-Windows.zip**
```
ForgeFPV.exe
ForgeFPV.pck
```

**ForgeFPV-Linux.zip**
```
ForgeFPV.x86_64
ForgeFPV.pck
(optional) run.sh  ← simple launcher if desired
```

Upload both ZIPs to a new GitHub Release.

## Player Experience After Release
1. Go to Releases
2. Download the correct ZIP
3. Extract → double-click executable

No installers. No Godot. No extra dependencies for the player.

## Notes
- Keep `export_presets.cfg` in the repo so every developer has the same settings.
- Do not commit the large exported binaries into the main source tree.
- Only attach them to GitHub Releases.