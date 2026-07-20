from PIL import Image, ImageDraw
import math

def draw_logo(size):
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    cx, cy = size // 2, size // 2
    r = int(size * 0.38)
    
    bg_r = int(size * 0.46)
    draw.ellipse([cx - bg_r, cy - bg_r, cx + bg_r, cy + bg_r],
                 fill=(20, 20, 32, 255))
    
    orbit_w = max(1, size // 24)
    draw.ellipse([cx - r, cy - r, cx + r, cy + r],
                 outline=(100, 100, 120, 200), width=orbit_w)
    
    dot_r = max(1, size // 16)
    draw.ellipse([cx - dot_r, cy - dot_r, cx + dot_r, cy + dot_r],
                 fill=(255, 255, 255, 255))
    
    angle = math.pi * 0.25
    obj_x = cx + r * math.cos(angle)
    obj_y = cy + r * math.sin(angle)
    obj_r = max(2, size // 10)
    draw.ellipse([int(obj_x - obj_r), int(obj_y - obj_r),
                  int(obj_x + obj_r), int(obj_y + obj_r)],
                 fill=(255, 255, 0, 255))
    
    arrow_len = r * 0.6
    ax = obj_x + (cx - obj_x) / r * arrow_len
    ay = obj_y + (cy - obj_y) / r * arrow_len
    aw = max(1, size // 20)
    draw.line([int(obj_x), int(obj_y), int(ax), int(ay)],
              fill=(0, 128, 255, 255), width=aw)
    
    vx = obj_x + math.sin(angle) * arrow_len * 0.7
    vy = obj_y - math.cos(angle) * arrow_len * 0.7
    draw.line([int(obj_x), int(obj_y), int(vx), int(vy)],
              fill=(0, 200, 0, 255), width=aw)
    
    return img

sizes = [16, 32, 48, 64, 128, 256]
images = []
for s in sizes:
    img = draw_logo(s)
    images.append(img)

ico_path = r"C:\Users\hacker\AppData\Local\Temp\opencode\3D-Centripetal-Centrifugal-Force-Simulation\windows\runner\resources\app_icon.ico"

# Save ICO with proper multi-size support
images[-1].save(ico_path, format='ICO', sizes=[(s, s) for s in sizes],
                append_images=images[:-1])

print("Done")
