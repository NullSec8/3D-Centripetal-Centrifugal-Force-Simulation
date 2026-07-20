# 3D Centripetal & Centrifugal Force Simulation

An interactive 3D physics simulation demonstrating centripetal and centrifugal forces on an object in uniform circular motion. Built for a physics class project.

> **F = mω²r**

---

## Download

| Platform | File |
|----------|------|
| Windows x64 | [`release-windows-x64.zip`](release-windows-x64.zip) |

Extract the zip and run `centripetal_force_sim.exe`. No installation required.

---

## Features

- **3D rendering** — Custom software rasterizer (no OpenGL/GPU required)
- **Centripetal force** — Blue arrow pointing toward the center of rotation
- **Centrifugal force** — Red arrow pointing outward (fictitious force in rotating frame)
- **Velocity vector** — Green arrow tangential to the orbit
- **Speed-colored trail** — Orbit trail fades from dark (old) to bright (new)
- **Interactive controls** — Mouse drag to rotate, scroll to zoom, keyboard shortcuts
- **UI sliders** — Adjust radius, angular velocity, and mass in real-time
- **Live physics readout** — Force, velocity, acceleration, and period displayed live

---

## Physics

The simulation models a point mass `m` moving in a circle of radius `r` at angular velocity `ω`:

| Quantity | Formula | Description |
|----------|---------|-------------|
| Centripetal force | `F = mω²r` | Net inward force maintaining circular motion |
| Velocity | `v = ωr` | Tangential speed |
| Acceleration | `a = v²/r` | Centripetal acceleration |
| Period | `T = 2π/ω` | Time for one full revolution |

---

## Controls

### Keyboard

| Key | Action |
|-----|--------|
| ↑ / ↓ | Increase / decrease angular velocity (ω) |
| ← / → | Decrease / increase radius (r) |
| W / S | Increase / decrease mass (m) |
| A / D | Rotate camera horizontally |
| Q / E | Rotate camera vertically |
| Z / X | Zoom in / out |
| 1 | Toggle centripetal force (blue) |
| 2 | Toggle centrifugal force (red) |
| 3 | Toggle velocity vector (green) |
| 4 | Toggle trail / orbit ring |
| 5 | Toggle 3D / 2D perspective |
| P | Pause / resume simulation |
| Space | Reset all parameters |
| + / - | Scale force arrows larger / smaller |

### Mouse

| Action | Effect |
|--------|--------|
| Drag | Rotate camera |
| Scroll / Pinch | Zoom in / out |

---

## Build from Source

Requires [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.x+.

```bash
# Clone
git clone https://github.com/NullSec8/3D-Centripetal-Centrifugal-Force-Simulation.git
cd 3D-Centripetal-Centrifugal-Force-Simulation

# Run (development)
flutter run -d windows
flutter run -d linux

# Build release
flutter build windows   # → build/windows/x64/runner/Release/
flutter build linux     # → build/linux/x64/release/bundle/
```

---

## Project Structure

```
lib/
  main.dart               # App entry point
  simulation_page.dart     # UI, keyboard/mouse handling, animation loop
  simulation_painter.dart  # CustomPainter — 3D software renderer
  simulation_state.dart    # Physics state, Vec3 class, simulation math
  math3d.dart              # Mat4, perspective projection, lookAt matrix
  logo_painter.dart        # Programmatic logo renderer
assets/
  logo.svg                 # Vector logo
  logo.png                 # Raster logo
windows/                   # Windows platform runner
linux/                     # Linux platform runner
```

---

## About

Made this for my physics class to visualize centripetal and centrifugal force. Figured I'd share it in case anyone else finds it useful. Feel free to use it however you like.
