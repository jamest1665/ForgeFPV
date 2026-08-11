#!/usr/bin/env python3
"""
ForgeFPV polar_tangential_controller.py
Offline polar / tangential formation planner (Python mirror of TangentialController.gd).

Use for prototyping ring radii, angular rates, and slot spacing before tuning Godot.

Usage:
  python polar_tangential_controller.py --n 12 --radius 40 --speed 0.35 --t 10
  python polar_tangential_controller.py --demo
"""

from __future__ import annotations

import argparse
import math
from dataclasses import dataclass
from typing import List, Tuple

Vec3 = Tuple[float, float, float]


@dataclass
class PolarTangentialController:
    center: Vec3 = (0.0, 0.0, 0.0)
    radius: float = 40.0
    height: float = 12.0
    angular_speed: float = 0.35  # rad/s
    clockwise: bool = True

    def set_ring(self, center: Vec3, radius: float, height: float = 12.0) -> None:
        self.center = center
        self.radius = max(radius, 5.0)
        self.height = height

    def _angle(self, phase_offset: float, time_sec: float) -> float:
        angle = time_sec * self.angular_speed + phase_offset
        return -angle if self.clockwise else angle

    def slot_position(self, index: int, total: int, time_sec: float = 0.0) -> Vec3:
        total = max(total, 1)
        step = 2.0 * math.pi / float(total)
        angle = self._angle(step * float(index), time_sec)
        cx, cy, cz = self.center
        return (
            cx + math.cos(angle) * self.radius,
            self.height if self.height else cy,
            cz + math.sin(angle) * self.radius,
        )

    def desired_velocity(
        self, agent_pos: Vec3, phase_offset: float, time_sec: float
    ) -> Vec3:
        angle = self._angle(phase_offset, time_sec)
        cx, _cy, cz = self.center
        on_ring = (
            cx + math.cos(angle) * self.radius,
            self.height,
            cz + math.sin(angle) * self.radius,
        )
        tangent = (-math.sin(angle), 0.0, math.cos(angle))
        if self.clockwise:
            tangent = (-tangent[0], 0.0, -tangent[2])
        to_ring = (
            on_ring[0] - agent_pos[0],
            on_ring[1] - agent_pos[1],
            on_ring[2] - agent_pos[2],
        )
        speed = self.radius * self.angular_speed
        return (
            tangent[0] * speed + to_ring[0] * 0.35,
            tangent[1] * speed + to_ring[1] * 0.35,
            tangent[2] * speed + to_ring[2] * 0.35,
        )

    def formation_slots(self, n: int, time_sec: float = 0.0) -> List[Vec3]:
        return [self.slot_position(i, n, time_sec) for i in range(n)]


def _fmt(v: Vec3) -> str:
    return f"({v[0]:7.2f}, {v[1]:6.2f}, {v[2]:7.2f})"


def main() -> None:
    p = argparse.ArgumentParser(description="ForgeFPV polar tangential formation planner")
    p.add_argument("--n", type=int, default=12, help="drone count")
    p.add_argument("--radius", type=float, default=40.0)
    p.add_argument("--height", type=float, default=12.0)
    p.add_argument("--speed", type=float, default=0.35, help="angular speed rad/s")
    p.add_argument("--t", type=float, default=0.0, help="time seconds")
    p.add_argument("--ccw", action="store_true", help="counter-clockwise")
    p.add_argument("--demo", action="store_true", help="print sample timeline")
    args = p.parse_args()

    ctl = PolarTangentialController(
        radius=args.radius,
        height=args.height,
        angular_speed=args.speed,
        clockwise=not args.ccw,
    )

    if args.demo:
        print("PolarTangentialController demo (n=8, radius=40)")
        for t in (0.0, 2.0, 5.0, 10.0):
            slots = ctl.formation_slots(8, t)
            print(f"t={t:5.1f}s  slot0={_fmt(slots[0])}  slot4={_fmt(slots[4])}")
        pos = (50.0, 10.0, 0.0)
        vel = ctl.desired_velocity(pos, 0.0, 5.0)
        print(f"sample desired_velocity from {pos} -> {_fmt(vel)}")
        return

    slots = ctl.formation_slots(args.n, args.t)
    print(f"n={args.n} radius={args.radius} t={args.t}s clockwise={ctl.clockwise}")
    for i, s in enumerate(slots):
        print(f"  slot[{i:02d}] {_fmt(s)}")


if __name__ == "__main__":
    main()
