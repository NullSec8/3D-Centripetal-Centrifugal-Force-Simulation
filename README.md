# 3D-Centripetal-Centrifugal-Force-Simulation

This is a **3D interactive simulation** demonstrating **centripetal and centrifugal forces** using C++ and OpenGL (GLFW).  
It is designed for educational purposes, ideal for high school physics students.

---

## Features

- **Centripetal Force (Blue Arrow)**: Pulls the object towards the center.
- **Centrifugal Force (Red Arrow)**: Apparent outward force in a rotating frame.
- **Velocity (Green Arrow)**: Tangential velocity of the object.
- **Orbit Visualization**: Shows the object's path.
- Adjustable parameters: mass, radius, angular velocity.
- Interactive camera rotation and zoom.
- Pause and reset functionality.

---

## Controls

| Key          | Action                                     |
|--------------|-------------------------------------------|
| UP / DOWN    | Increase / Decrease angular velocity (ω)  |
| LEFT / RIGHT | Increase / Decrease radius (r)            |
| W / S        | Increase / Decrease mass (m)              |
| + / -        | Adjust arrow scale                         |
| A / D        | Rotate camera horizontally                 |
| Q / E        | Rotate camera vertically                   |
| Z / X        | Zoom in / out                              |
| 1            | Toggle centripetal force (Blue)           |
| 2            | Toggle centrifugal force (Red)            |
| 3            | Toggle velocity arrow (Green)             |
| 4            | Toggle orbit display                       |
| 5            | Toggle 3D / 2D view                        |
| P            | Pause / Resume simulation                  |
| SPACE        | Reset simulation                           |
| ESC          | Exit program                               |

---

## How to Run

1. Install [GLFW](https://www.glfw.org/) on your system.
2. Compile the project (Linux example):

```bash
g++ main.cpp -o simulation -lglfw -lGL -lm
./simulation
```

(For Windows or MacOS, adjust libraries accordingly.)

---

## Windows Prebuilt Binary

A statically linked 64-bit Windows executable is included in this repository:

- `simulation-windows-x64.exe`

You can run it directly on Windows without installing GLFW separately.
