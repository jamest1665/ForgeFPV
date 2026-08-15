# ForgeFPV — Change Policy

**Effective:** 2026-08-15  
**Goal:** Protect playable flight/control/gameplay while allowing production hardening.

---

## 1. Frozen without explicit approval

Do **not** change behavior in these areas unless the product owner approves:

| Area | Examples |
|------|----------|
| Flight dynamics | `FlightModel` gains, drag, gravity coupling, battery drain, input expo |
| Control scheme | WASD / QE / Space / Ctrl mappings and rate-mode response |
| Gameplay success rules | Target hit radius, score points per hit, mission complete conditions |
| Aquatic physics contract | Buoyancy, water drag, current application in `WaterPhysicsManager` / `AquaticVehicle` |
| Existing map difficulty baselines | Target counts/placements that define current training difficulty |

**Approval channel:** Product owner (repo owner) must confirm before merge/push of behavioral diffs.

---

## 2. Open without approval (non-breaking)

| Area | Examples |
|------|----------|
| Documentation | `docs/*`, README, CONTRIBUTING |
| Structure | Comments, file headers, folder docs, `.gitignore` |
| Tooling | `tools/*` offline scripts |
| Export / release process | `docs/RELEASE_BUILD.md`, release checklists |
| Additive UI copy | Help text, briefing wording (if controls unchanged) |
| New optional systems | New docs-only modules, new maps that **extend** BaseTrainingScene without editing FlightModel |

---

## 3. Gray zone (ask first)

- Refactors that touch `BaseTrainingScene._process` order but claim “same behavior”
- Autoload additions that run every frame
- Replacing self-contained aquatic loop with BaseTrainingScene inheritance
- Swarm defaults that change Hivemind Demo difficulty feel

Default: treat gray zone as **frozen** until approved.

---

## 4. How to request a behavior change

1. State the problem (player feel, bug, product requirement).
2. Name the files and functions involved.
3. Describe proposed behavior vs current behavior.
4. List regression tests (e.g. “Donbas: 8 targets still score at ~4 m”).
5. Wait for explicit approval, then implement in a focused commit.

---

## 5. Commit hygiene

- Prefer commits that **do not** mix doc-only work with flight code.
- Message prefix ideas: `docs:`, `chore:`, `feat:` (approved), `fix:` (approved behavior).
