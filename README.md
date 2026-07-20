# 3D Centripetal & Centrifugal Force Simulation

Interactive 3D physics simulation of centripetal and centrifugal force for an object undergoing uniform circular motion. Built with Flutter/Dart.

## Platforms
- **Windows** (primary)
- **Linux**

## Features
- Real-time 3D rendering with software rasterizer
- Centripetal force visualization (blue arrow, toward center)
- Centrifugal force visualization (red arrow, away from center)
- Tangential velocity vector (green arrow)
- Adjustable parameters: angular velocity, radius, mass
- Camera controls: rotation, zoom
- Toggle views with keyboard shortcuts

## Controls
| Key | Action |
|-----|--------|
| UP/DOWN | Change angular velocity (\u03C9) |
| LEFT/RIGHT | Change radius (r) |
| W/S | Change mass (m) |
| A/D | Rotate camera horizontally |
| Q/E | Rotate camera vertically |
| Z/X | Zoom in/out |
| 1 | Toggle centripetal force |
| 2 | Toggle centrifugal force |
| 3 | Toggle velocity vector |
| 4 | Toggle trail/orbit |
| 5 | Toggle 3D perspective |
| P | Pause/Resume |
| Space | Reset |
| +/- | Change arrow scale |

## Build & Run
```bash
flutter run -d windows   # Windows
flutter run -d linux     # Linux
```
