# ForgeFPV — Product Readiness Roadmap

**Product:** American FPV Tactical Trainer  
**Engine:** Godot 4.x  
**Company context:** SkyForge Dynamics  
**Doc updated:** 2026-08-15

This roadmap separates **what already ships in-repo** from **what a sellable SKU still needs**. It does not authorize gameplay changes by itself—see CHANGE_POLICY.md.

---

## 1. Current product capabilities (as implemented)

| Capability | Status |
|------------|--------|
| Main menu + 7 free-play maps | Live |
| Rate-mode FPV flight (land, shared core) | Live |
| Academy missions (select / brief / complete) | Live |
| Airframe selection via GameState | Live |
| Pause menu, help overlay, path trail | Live |
| Wind / weather / audio hooks | Live |
| Aquatic flood training path | Live |
| Hivemind demo (multi-team swarm) | Live |
| Windows/Linux export presets documented | Live |
| Offline city + formation tools | Live |

---

## 2. Sellable product gaps (priority order)

### P0 — Trust & distribution

1. **Signed Windows builds** — SmartScreen friction kills conversion; code-signing cert + release pipeline.
2. **One-click player package** — GitHub Release ZIPs with README-PLAY inside the archive; optional Steam/itch page.
3. **Version stamp** — Visible in-menu version string tied to git tag / `application/config/version`.
4. **Smoke-test checklist** — Manual QA script per release (menu, one land map, aquatic, mission complete, pause).

### P1 — Training value

5. **Controller / stick input** — Many FPV pilots will not train on keyboard long-term (behavior change → needs approval).
6. **Debrief persistence** — Save last N runs (high score already partial).
7. **Mission data externalization** — JSON/CSV catalog instead of only hard-coded database.
8. **Audio asset pack** — Motor/wind/EW loops under `res://audio/` (system already degrades silently).

### P2 — Presentation & polish

9. **Art pass** — Replace procedural boxes with authored kits per theater (non-behavioral if collision/target logic unchanged).
10. **Main menu visual identity** — Logo, consistent typography, trailer loop.
11. **Settings screen** — Sensitivity, invert, volume (settings that alter feel need approval).

### P3 — Scale

12. **Aquatic on shared mission complete path** — Optional unification (architecture change; approve first).
13. **Swarm vs player scenarios** — Training modes beyond demo.
14. **Store compliance** — Privacy policy, EULA, age rating questionnaire for Steam.

---

## 3. Non-goals (near term)

- Full aerodynamics CFD fidelity
- Multiplayer networking
- Real ITAR-controlled content or classified procedures in the public repo

---

## 4. Suggested release channels

| Channel | Fit |
|---------|-----|
| GitHub Releases | Dev / early access builds |
| itch.io | Indie trainer distribution |
| Steam | Primary commercial SKU once P0–P1 solid |

---

## 5. Success metrics (product)

- Time-to-first-flight from download &lt; 5 minutes
- Crash-free session rate on target hardware (document min spec in README)
- Pilot can complete one Academy mission without reading source

---

## 6. Next documentation-only actions

- Keep ARCHITECTURE.md updated when structure changes
- Tag releases (`v0.x.y`) and paste smoke-test results into release notes
