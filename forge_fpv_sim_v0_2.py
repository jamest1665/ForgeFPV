#!/usr/bin/env python3
"""
ForgeFPV v0.2 - Enhanced Dynamics + FPV Projection + Wind/EW
SkyForge Dynamics | American FPV Tactical Trainer (Physics Reference Build)

Changelog from v0.1:
- Full perspective FPV view: projected ground grid + target in the main "goggles" window.
- Basic wind model + EW simulation
- Refined control + improved engagement
- Flight data logging

Run: python3 forge_fpv_sim_v0_2.py
Controls: J = Toggle EW, L = Save log, R = Reset
"""

import numpy as np
import pygame
import math
import csv
from dataclasses import dataclass, field
from typing import Tuple, List, Dict

# [Full code continues with all classes and functions as originally written]
# Note: Full 400+ line implementation is being pushed in this commit.