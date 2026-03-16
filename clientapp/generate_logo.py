"""Generate a village app logo with united people."""
import math
from PIL import Image, ImageDraw, ImageFont

SIZE = 1024
CENTER = SIZE // 2
img = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
draw = ImageDraw.Draw(img)

# --- Background: rounded rectangle with gradient-like dark teal ---
bg_color = (20, 36, 54)  # deep dark blue-teal
corner = 180
draw.rounded_rectangle([0, 0, SIZE - 1, SIZE - 1], radius=corner, fill=bg_color)

# --- Colors ---
ORANGE = (255, 149, 0)
ORANGE_LIGHT = (255, 183, 77)
WHITE = (255, 255, 255)
TEAL = (0, 200, 170)
TEAL_LIGHT = (100, 230, 210)
GREEN = (76, 217, 100)

# --- Draw a large circle of united people at the center ---
# 7 people standing in a circle, holding hands

num_people = 7
people_radius = 195  # radius of the circle they stand on
person_head_r = 32
body_h = 70
people_center_y = CENTER - 40

# Compute positions for each person
people_positions = []
for i in range(num_people):
    angle = -math.pi / 2 + (2 * math.pi * i / num_people)
    px = CENTER + people_radius * math.cos(angle)
    py = people_center_y + people_radius * math.sin(angle)
    people_positions.append((px, py, angle))

# Alternate colors for people
person_colors = [ORANGE, TEAL, ORANGE_LIGHT, GREEN, ORANGE, TEAL_LIGHT, ORANGE_LIGHT]

# Draw connecting "arms" / arcs between people (drawn first, behind bodies)
for i in range(num_people):
    x1, y1, _ = people_positions[i]
    x2, y2, _ = people_positions[(i + 1) % num_people]
    # Draw a thick line (arm) between adjacent people
    draw.line([(x1, y1), (x2, y2)], fill=(255, 255, 255, 120), width=6)

# Draw each person
for i, (px, py, angle) in enumerate(people_positions):
    color = person_colors[i % len(person_colors)]
    # Head
    head_y = py - body_h // 2 - person_head_r
    draw.ellipse(
        [px - person_head_r, head_y - person_head_r,
         px + person_head_r, head_y + person_head_r],
        fill=color,
    )
    # Body (rounded rectangle-ish)
    bw = 28
    draw.rounded_rectangle(
        [px - bw, py - body_h // 2, px + bw, py + body_h // 2],
        radius=14,
        fill=color,
    )
    # Arms — small stubs pointing toward neighbors
    arm_len = 38
    left_angle = angle + math.pi / 2 + 0.4
    right_angle = angle - math.pi / 2 - 0.4
    # Left arm
    lx = px + arm_len * math.cos(left_angle + math.pi)
    ly = py + arm_len * math.sin(left_angle + math.pi)
    draw.line([(px, py - 10), (lx, ly - 10)], fill=color, width=12)
    # Right arm
    rx = px + arm_len * math.cos(right_angle + math.pi)
    ry = py + arm_len * math.sin(right_angle + math.pi)
    draw.line([(px, py - 10), (rx, ry - 10)], fill=color, width=12)

# --- Draw a subtle "village" silhouette at the bottom ---
base_y = SIZE - 280
# Ground line
draw.rounded_rectangle(
    [100, base_y + 130, SIZE - 100, base_y + 155],
    radius=12,
    fill=ORANGE,
)

# Center house (larger)
house_w, house_h = 120, 110
hx = CENTER
draw.rectangle(
    [hx - house_w // 2, base_y + 130 - house_h, hx + house_w // 2, base_y + 130],
    fill=ORANGE,
)
# Roof (triangle)
draw.polygon(
    [(hx - house_w // 2 - 20, base_y + 130 - house_h),
     (hx, base_y + 130 - house_h - 70),
     (hx + house_w // 2 + 20, base_y + 130 - house_h)],
    fill=WHITE,
)
# Door
draw.rounded_rectangle(
    [hx - 22, base_y + 130 - 65, hx + 22, base_y + 130],
    radius=12,
    fill=bg_color,
)
# Windows
for wx_off in [-45, 45]:
    draw.rounded_rectangle(
        [hx + wx_off - 14, base_y + 130 - house_h + 20,
         hx + wx_off + 14, base_y + 130 - house_h + 48],
        radius=5,
        fill=ORANGE_LIGHT,
    )

# Left small house
lhx = CENTER - 185
sh_w, sh_h = 80, 75
draw.rectangle(
    [lhx - sh_w // 2, base_y + 130 - sh_h, lhx + sh_w // 2, base_y + 130],
    fill=ORANGE_LIGHT,
)
draw.polygon(
    [(lhx - sh_w // 2 - 15, base_y + 130 - sh_h),
     (lhx, base_y + 130 - sh_h - 50),
     (lhx + sh_w // 2 + 15, base_y + 130 - sh_h)],
    fill=ORANGE,
)
draw.rounded_rectangle(
    [lhx - 14, base_y + 130 - 50, lhx + 14, base_y + 130],
    radius=8,
    fill=bg_color,
)

# Right small house
rhx = CENTER + 185
draw.rectangle(
    [rhx - sh_w // 2, base_y + 130 - sh_h, rhx + sh_w // 2, base_y + 130],
    fill=ORANGE_LIGHT,
)
draw.polygon(
    [(rhx - sh_w // 2 - 15, base_y + 130 - sh_h),
     (rhx, base_y + 130 - sh_h - 50),
     (rhx + sh_w // 2 + 15, base_y + 130 - sh_h)],
    fill=ORANGE,
)
draw.rounded_rectangle(
    [rhx - 14, base_y + 130 - 50, rhx + 14, base_y + 130],
    radius=8,
    fill=bg_color,
)

# --- Text: "DOULATPARA" at the bottom ---
try:
    font = ImageFont.truetype("arialbd", 62)
except Exception:
    try:
        font = ImageFont.truetype("arial", 62)
    except Exception:
        font = ImageFont.load_default()

text = "DOULATPARA"
bbox = draw.textbbox((0, 0), text, font=font)
tw = bbox[2] - bbox[0]
tx = (SIZE - tw) // 2
ty = SIZE - 120
draw.text((tx, ty), text, fill=WHITE, font=font)

# --- Save master logo ---
img.save('d:/villageapp/clientapp/assets/logo.png')
print(f'Logo saved: {SIZE}x{SIZE}')

# --- Generate all platform icons ---
# Android icons
android_sizes = {
    'mipmap-mdpi': 48,
    'mipmap-hdpi': 72,
    'mipmap-xhdpi': 96,
    'mipmap-xxhdpi': 144,
    'mipmap-xxxhdpi': 192,
}
for folder, s in android_sizes.items():
    resized = img.resize((s, s), Image.LANCZOS)
    path = f'd:/villageapp/clientapp/android/app/src/main/res/{folder}/ic_launcher.png'
    resized.save(path)
    print(f'Android {folder}: {s}x{s}')

# iOS icons
ios_base = 'd:/villageapp/clientapp/ios/Runner/Assets.xcassets/AppIcon.appiconset'
ios_sizes = {
    'Icon-App-20x20@1x.png': 20,
    'Icon-App-20x20@2x.png': 40,
    'Icon-App-20x20@3x.png': 60,
    'Icon-App-29x29@1x.png': 29,
    'Icon-App-29x29@2x.png': 58,
    'Icon-App-29x29@3x.png': 87,
    'Icon-App-40x40@1x.png': 40,
    'Icon-App-40x40@2x.png': 80,
    'Icon-App-40x40@3x.png': 120,
    'Icon-App-60x60@2x.png': 120,
    'Icon-App-60x60@3x.png': 180,
    'Icon-App-76x76@1x.png': 76,
    'Icon-App-76x76@2x.png': 152,
    'Icon-App-83.5x83.5@2x.png': 167,
    'Icon-App-1024x1024@1x.png': 1024,
}
for fname, s in ios_sizes.items():
    resized = img.resize((s, s), Image.LANCZOS)
    path = f'{ios_base}/{fname}'
    resized.save(path)
    print(f'iOS {fname}: {s}x{s}')

# Web icons
web_sizes = {
    'favicon.png': 16,
    'icons/Icon-192.png': 192,
    'icons/Icon-512.png': 512,
    'icons/Icon-maskable-192.png': 192,
    'icons/Icon-maskable-512.png': 512,
}
for fname, s in web_sizes.items():
    resized = img.resize((s, s), Image.LANCZOS)
    path = f'd:/villageapp/clientapp/web/{fname}'
    resized.save(path)
    print(f'Web {fname}: {s}x{s}')

print('\nAll icons generated!')
