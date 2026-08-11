#!/usr/bin/env python3
"""
ForgeFPV city_generator.py
Offline procedural urban block generator for FPV training maps.

Outputs JSON building footprints (x, z, w, d, h, color) consumable by Godot
map scripts or external tooling. No network required.

Usage:
  python city_generator.py --size 200 --count 40 --seed 7 --out urban_blocks.json
  python city_generator.py --preset dense --out dense_city.json
"""

from __future__ import annotations

import argparse
import json
import math
import random
from pathlib import Path
from typing import Any


PRESETS = {
    "sparse": {"count": 20, "size": 220.0, "h_min": 6.0, "h_max": 18.0},
    "urban": {"count": 40, "size": 200.0, "h_min": 8.0, "h_max": 35.0},
    "dense": {"count": 70, "size": 180.0, "h_min": 12.0, "h_max": 48.0},
    "port": {"count": 35, "size": 240.0, "h_min": 6.0, "h_max": 22.0},
}


def _rand_color(rng: random.Random) -> list[float]:
    return [
        round(rng.uniform(0.2, 0.45), 3),
        round(rng.uniform(0.2, 0.4), 3),
        round(rng.uniform(0.25, 0.5), 3),
    ]


def generate(
    count: int = 40,
    size: float = 200.0,
    seed: int = 7,
    h_min: float = 8.0,
    h_max: float = 35.0,
    keepout: float = 20.0,
) -> dict[str, Any]:
    rng = random.Random(seed)
    buildings: list[dict[str, Any]] = []
    half = size * 0.5
    for i in range(count):
        w = rng.uniform(4.0, 12.0)
        d = rng.uniform(4.0, 12.0)
        h = rng.uniform(h_min, h_max)
        x = rng.uniform(-half, half)
        z = rng.uniform(-half, half)
        if math.hypot(x, z) < keepout:
            x += 30.0 if x >= 0 else -30.0
        buildings.append(
            {
                "id": i,
                "x": round(x, 2),
                "z": round(z, 2),
                "w": round(w, 2),
                "d": round(d, 2),
                "h": round(h, 2),
                "y": round(h * 0.5, 2),
                "color": _rand_color(rng),
            }
        )
    return {
        "generator": "ForgeFPV city_generator",
        "seed": seed,
        "map_size": size,
        "keepout": keepout,
        "building_count": len(buildings),
        "buildings": buildings,
    }


def main() -> None:
    p = argparse.ArgumentParser(description="ForgeFPV procedural city block generator")
    p.add_argument("--preset", choices=list(PRESETS.keys()), default=None)
    p.add_argument("--count", type=int, default=40)
    p.add_argument("--size", type=float, default=200.0)
    p.add_argument("--seed", type=int, default=7)
    p.add_argument("--h-min", type=float, default=8.0)
    p.add_argument("--h-max", type=float, default=35.0)
    p.add_argument("--keepout", type=float, default=20.0)
    p.add_argument("--out", type=str, default="urban_blocks.json")
    args = p.parse_args()

    if args.preset:
        cfg = PRESETS[args.preset]
        data = generate(
            count=cfg["count"],
            size=cfg["size"],
            seed=args.seed,
            h_min=cfg["h_min"],
            h_max=cfg["h_max"],
            keepout=args.keepout,
        )
        data["preset"] = args.preset
    else:
        data = generate(
            count=args.count,
            size=args.size,
            seed=args.seed,
            h_min=args.h_min,
            h_max=args.h_max,
            keepout=args.keepout,
        )

    out = Path(args.out)
    out.write_text(json.dumps(data, indent=2), encoding="utf-8")
    print(f"Wrote {data['building_count']} buildings -> {out.resolve()}")


if __name__ == "__main__":
    main()
