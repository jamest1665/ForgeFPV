# ForgeFPV vs UFDS — Competitive Analysis & Execution Roadmap

**Living document**  
**Updated:** 2026-08-16  
**Benchmark:** Ukrainian Fight Drone Simulator (UFDS) Starter Edition (Steam)  
**Policy:** Flight/control/gameplay behavior changes require explicit approval (CHANGE_POLICY.md).

This roadmap is the **execution plan** to reach **equal or better** product value than UFDS for an American tactical FPV trainer (hobby / commercial training SKU—not a copy of restricted military map content).

---

## 1. Repo state (honest snapshot)

### What ForgeFPV has today

| Area | State |
|------|--------|
| Engine | Godot 4, runnable from `project.godot` |
| Flight | Simplified rate-mode `FlightModel` (accel/drag/gravity/wind/battery) |
| Maps | 7 theaters (mostly procedural boxes) |
| Academy | Select → brief → fly → complete (basic) |
| Airframes | Profile dictionary (speed/accel/color), not real FC models |
| Aquatic | Separate water path |
| Swarm | Hivemind demo (seek/ring/hold) |
| UX | Menu, pause, help, path trail |
| Audio/VFX | Hooks; limited real assets |
| Distribution | Source + export docs; not a polished Steam SKU |
| Docs | Architecture, change policy, smoke test |

### What it does **not** have yet (critical vs UFDS)

| Gap | Impact |
|-----|--------|
| Blockout-only visuals | First impression fails vs Steam peers |
| No RC / gamepad-first control path | Cannot train real muscle memory |
| No motor-level / PID-style model | Feels arcade vs “sim” |
| No crash / soft-kill consequences | Low training pressure |
| No real payloads (drop / terminal dive) | Missing combat-role training |
| No structured courses (Basic → Kamikaze → Bomber → Interceptor) | Weak progression |
| No dense authored environments | Poor target-search skill transfer |
| No day/night + signal degradation as first-class systems | Incomplete “combat conditions” |
| No multiplayer | Behind UFDS on social/training-with-peers |
| No signed retail build pipeline | Distribution friction |

**Bottom line:** ForgeFPV is a **working prototype + systems skeleton**. UFDS is a **shipping training product** with deep physics claims, real airframe identities, Academy depth, multiplayer, and commercial packaging (~28 GB content class).

---

## 2. UFDS capability model (what “equal or better” means)

UFDS sells on:

1. **Physics fidelity** — weight, thrust, battery thermal/drain, aerodynamics; PID tuning; ~“black box” matching of real quads (their claim).
2. **Control hardware** — RC recommended; gamepad supported; keyboard secondary.
3. **Combat roles** — recon, bomber, kamikaze, interceptor; modular payloads.
4. **Training structure** — Academy courses + Battleground pressure mode.
5. **Environment stress** — weather, day/night, EW / signal limits, navigation discipline (MGRS in their stack).
6. **Presentation** — dense maps, real-looking drones/targets, FPV HUD.
7. **Multiplayer** — PvP + co-op (live on Steam).
8. **Credibility** — operator-informed design; clear “trainer not arcade” positioning.

ForgeFPV **equal or better** means matching those *outcomes* for American training use—not cloning Ukrainian military maps or restricted TTPs.

**Where ForgeFPV can legitimately exceed UFDS (if executed):**

- Modular open architecture (Godot + documented systems)
- Hivemind / multi-agent training (already started; UFDS is weaker here publicly)
- Aquatic / flood low-alt lane (differentiator)
- Multi-theater American-relevant training sets (border, port, littoral, arctic)
- Cleaner civilian commercial licensing path if productized carefully
- Swarm + single-pilot hybrid scenarios

---

## 3. Gap matrix (priority)

| # | Capability | UFDS | ForgeFPV now | Priority |
|---|------------|------|--------------|----------|
| G1 | Visual fidelity (drone + world) | High | Blockout | **P0** |
| G2 | RC / stick input | First-class | Keyboard-first | **P0** |
| G3 | Flight model depth (motors, mass, PID) | Deep | Simple rate model | **P0** |
| G4 | Crash / fail states | Strong | Soft floor clamp | **P0** |
| G5 | Academy curriculum depth | Multi-course | Thin mission list | **P1** |
| G6 | Payloads / terminal attack | Bombs, configs | Score-on-proximity | **P1** |
| G7 | Environment stress (EW, night, weather) | Core | Partial weather/EW toggle | **P1** |
| G8 | Authored maps / target density | Dense | Sparse primitives | **P1** |
| G9 | FPV camera realism (latency, noise, FOV) | Strong | Basic cam | **P1** |
| G10 | Audio (motors, wind, impact) | Present | Mostly hooks | **P2** |
| G11 | Battleground / endless pressure mode | Yes | No | **P2** |
| G12 | Multiplayer | Live | None | **P2** |
| G13 | Retail packaging / Steam | Live | Docs only | **P2** |
| G14 | Swarm / hivemind training | Weak publicly | Demo exists | **P2 (advantage)** |
| G15 | Analytics / debrief | Stronger | Basic | **P2** |

---

## 4. Execution roadmap (follow in order)

### Phase 0 — Product baseline (1–2 weeks)
**Goal:** Trustworthy build + measurable quality bar. No flight-feel changes required.

| Step | Work | Done when |
|------|------|-----------|
| 0.1 | Version stamp in menu + `project.godot` | Version visible |
| 0.2 | Smoke test every commit/tag (`docs/SMOKE_TEST.md`) | Checklist archived per tag |
| 0.3 | GitHub Release ZIP (Win/Linux) + README-PLAY | Fresh user flies in &lt;5 min |
| 0.4 | Min/rec hardware note in README | Matches honest performance |

**Exit:** `v0.2.0` tagged prototype people can install without cloning chaos.

---

### Phase 1 — First impression & controls (3–6 weeks)
**Goal:** Stop looking like a student project; enable real training input.

| Step | Work | Notes |
|------|------|-------|
| 1.1 | **Drone visual kit** | One production mesh + materials for default 5" trainer; keep hit logic |
| 1.2 | **One showcase map art pass** | Donbas or Urban: terrain, 20–40 authored props, ground texture |
| 1.3 | **Lighting/post** | Shadows, exposure, mild film grain; no gameplay change |
| 1.4 | **RC + gamepad input layer** | Map sticks to rate axes; keyboard remains fallback (**approve feel**) |
| 1.5 | **Settings: rates, expo, invert, deadzone** | Persist to user config (**approve**) |
| 1.6 | **FPV camera pack** | FOV presets, optional noise/chromatic when EW on |

**Exit criteria:** Screenshot test—stranger cannot tell it’s “only boxes.” Pilot can fly full session on Radiomaster / Xbox pad.

---

### Phase 2 — Simulation core (6–10 weeks) ⚠️ behavior changes need approval
**Goal:** Close the physics credibility gap.

| Step | Work |
|------|------|
| 2.1 | **Mass / thrust / drag model** | Per-airframe mass, max thrust, linear+quad drag |
| 2.2 | **Per-motor abstraction** | 4 thrust vectors; simple RPM proxy for audio |
| 2.3 | **Battery model v2** | C-rate style drain, low-voltage sag, hard cutoff |
| 2.4 | **PID / rate profiles** | User-selectable rate tables (or simplified Betaflight-like rates) |
| 2.5 | **Crash system** | Impact speed thresholds → soft damage / hard fail / respawn rules |
| 2.6 | **Ground interaction** | Bounce/slide, not only `min_alt` clamp |
| 2.7 | **Wind v2** | Gusts, shear near buildings (uses existing WindManager extension) |
| 2.8 | **Validation harness** | Offline tests: hover budget, max speed, battery endurance per airframe |

**Exit criteria:** Side-by-side checklist vs UFDS marketing claims on *feel* categories (not identical numbers). Documented airframe cards.

---

### Phase 3 — Combat training content (6–8 weeks)
**Goal:** Match Academy / Battleground *structure*.

| Step | Work |
|------|------|
| 3.1 | **Course tracks** | Basic Pilot → Precision Strafe → Terminal Dive → Low-Alt Corridor → Night/EW |
| 3.2 | **Payload roles** | Practice “terminal” (camera dive to target), optional drop marker (training-safe) |
| 3.3 | **Moving targets** | Simple ground movers; intercept geometry |
| 3.4 | **Fail conditions** | Battery, crash, timeout, signal loss |
| 3.5 | **Battleground mode** | Wave pressure, limited “sorties,” scoreboard |
| 3.6 | **Debrief v2** | Path trail review, time-on-target, crash cause |
| 3.7 | **Mission data files** | JSON missions (externalize MissionDatabase) |

**Exit criteria:** New pilot path of ≥8 progressive missions with clear skill gates.

---

### Phase 4 — Environment & theaters (ongoing, parallel after 1.2)
**Goal:** Density and readability of real FPV ops—not polygon count for its own sake.

| Step | Work |
|------|------|
| 4.1 | Theater kits: Field, Urban ruin, Port, Littoral, Arctic, Border |
| 4.2 | Target kit: vehicle proxies, emplacement markers, window/door openings |
| 4.3 | Day/night cycle + landing light / exposure |
| 4.4 | EW zones (signal noise, control latency optional) |
| 4.5 | Weather presets tied to mission defs (incl. typhoon already sketched) |
| 4.6 | Navigation aids (grid overlay option—civilian training grids, not sensitive real coords) |

**Exit criteria:** Each theater has distinct silhouette + ≥1 signature training problem.

---

### Phase 5 — Differentiator: swarm & multi-agent (4–6 weeks)
**Goal:** Be *better* than UFDS in a lane they don’t own publicly.

| Step | Work |
|------|------|
| 5.1 | Player + friendly AI wingmen |
| 5.2 | Hostile intercept swarm scenarios |
| 5.3 | Ring defense / flanking using existing tangential controller |
| 5.4 | Scalability LOD (MultiMesh) for 50–100 agents |
| 5.5 | Hivemind training missions in Academy |

**Exit criteria:** Marketable “swarm tactics trainer” bullet that UFDS Starter lacks.

---

### Phase 6 — Multiplayer & retail (8–14 weeks)
**Goal:** Peer training + sellable SKU.

| Step | Work |
|------|------|
| 6.1 | Co-op mission skeleton (Godot multiplayer API or dedicated relay) |
| 6.2 | PvP race / time-trial |
| 6.3 | Anti-cheat light + dedicated server notes |
| 6.4 | Steam page, depots, achievements, cloud settings |
| 6.5 | Code signing (Windows) |
| 6.6 | EULA, privacy, age rating, store caps |
| 6.7 | Trailer + screenshot pipeline |

**Exit criteria:** Paid Early Access or 1.0 store listing with signed builds.

---

## 5. Suggested sequencing (critical path)

```
Phase 0 ──► Phase 1 (art + sticks)
               │
               ├──► Phase 2 (physics) ──► Phase 3 (courses/payloads)
               │                              │
               └──► Phase 4 (theaters, parallel)
                                              │
                                    Phase 5 (swarm advantage)
                                              │
                                    Phase 6 (MP + Steam)
```

**Do not** start multiplayer before Phase 1–2. **Do not** expand to 20 maps before one map looks and flies credible.

---

## 6. Resource model (order-of-magnitude)

| Role | Need |
|------|------|
| Flight model engineer | Phase 2 owner |
| 3D generalist | Phases 1 + 4 |
| Godot gameplay | Phases 3, 5 |
| Audio | Phase 1–3 part-time |
| Producer / QA | Smoke tests, curriculum design |
| Optional: network eng | Phase 6 |

Solo + AI-assisted: expect **9–18 months** to true UFDS-competitive retail bar.  
Small team (3–5): **6–12 months** to strong Early Access.

---

## 7. Success metrics (equal or better)

| Metric | Target |
|--------|--------|
| Time to first flight (installed build) | &lt; 5 minutes |
| RC session without keyboard | Full Academy Basic course |
| Visual credibility | External tester: “not a blockout” on showcase map |
| Physics credibility | Pilots rate “trainable” ≥ 4/5 on survey |
| Content depth | ≥ 8 structured missions + 1 Battleground mode |
| Differentiator | ≥ 2 swarm scenarios unique vs UFDS |
| Stability | Crash-free rate on smoke suite ≥ 95% |
| Commercial | Signed Win build + store page live |

---

## 8. Explicit non-copy rules

- Do **not** reproduce restricted real military terrain datasets or sensitive TTPs in a public repo.
- Do **not** claim “frontline identical” without measured validation data.
- Position ForgeFPV as **American tactical FPV trainer** (training value, theaters, swarm), not a UFDS clone.

---

## 9. Immediate next actions (this week)

1. Approve Phase 1 scope (art-only vs art + stick input).
2. Choose showcase map for first art pass (recommend **Urban** or **Donbas**).
3. Acquire or commission one drone GLB + ground texture set.
4. Keep CHANGE_POLICY: any FlightModel edit only with written approval + regression checklist.

---

## 10. Document maintenance

Update this file when a phase exits or priority order changes. Link releases (`vX.Y.Z`) to phase exit criteria in release notes.
