from pathlib import Path

from PIL import Image

SRC = Path(r"C:\Users\mursh\Downloads\Gemini_Generated_Image_swcea4swcea4swce.png")
ROOT = Path(r"D:\villageapp\clientapp")

if not SRC.exists():
    raise FileNotFoundError(f"Source image not found: {SRC}")

img = Image.open(SRC).convert("RGBA")
w, h = img.size
side = min(w, h)
left = (w - side) // 2
top = (h - side) // 2
cropped = img.crop((left, top, left + side, top + side))

# Save master icon source
assets_logo = ROOT / "assets" / "logo.png"
assets_logo.parent.mkdir(parents=True, exist_ok=True)
cropped.save(assets_logo)

# Android launcher icons
android_sizes = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}
for folder, size in android_sizes.items():
    out = ROOT / "android" / "app" / "src" / "main" / "res" / folder / "ic_launcher.png"
    out.parent.mkdir(parents=True, exist_ok=True)
    cropped.resize((size, size), Image.Resampling.LANCZOS).save(out)

# iOS app icons
ios_sizes = {
    "Icon-App-20x20@1x.png": 20,
    "Icon-App-20x20@2x.png": 40,
    "Icon-App-20x20@3x.png": 60,
    "Icon-App-29x29@1x.png": 29,
    "Icon-App-29x29@2x.png": 58,
    "Icon-App-29x29@3x.png": 87,
    "Icon-App-40x40@1x.png": 40,
    "Icon-App-40x40@2x.png": 80,
    "Icon-App-40x40@3x.png": 120,
    "Icon-App-60x60@2x.png": 120,
    "Icon-App-60x60@3x.png": 180,
    "Icon-App-76x76@1x.png": 76,
    "Icon-App-76x76@2x.png": 152,
    "Icon-App-83.5x83.5@2x.png": 167,
    "Icon-App-1024x1024@1x.png": 1024,
}
ios_base = ROOT / "ios" / "Runner" / "Assets.xcassets" / "AppIcon.appiconset"
for filename, size in ios_sizes.items():
    out = ios_base / filename
    out.parent.mkdir(parents=True, exist_ok=True)
    cropped.resize((size, size), Image.Resampling.LANCZOS).save(out)

# macOS app icons
mac_sizes = {
    "app_icon_16.png": 16,
    "app_icon_32.png": 32,
    "app_icon_64.png": 64,
    "app_icon_128.png": 128,
    "app_icon_256.png": 256,
    "app_icon_512.png": 512,
    "app_icon_1024.png": 1024,
}
mac_base = ROOT / "macos" / "Runner" / "Assets.xcassets" / "AppIcon.appiconset"
for filename, size in mac_sizes.items():
    out = mac_base / filename
    out.parent.mkdir(parents=True, exist_ok=True)
    cropped.resize((size, size), Image.Resampling.LANCZOS).save(out)

# Web icons
web_sizes = {
    "favicon.png": 16,
    "icons/Icon-192.png": 192,
    "icons/Icon-512.png": 512,
    "icons/Icon-maskable-192.png": 192,
    "icons/Icon-maskable-512.png": 512,
}
for relative_path, size in web_sizes.items():
    out = ROOT / "web" / relative_path
    out.parent.mkdir(parents=True, exist_ok=True)
    cropped.resize((size, size), Image.Resampling.LANCZOS).save(out)

# Windows icon
windows_icon = ROOT / "windows" / "runner" / "resources" / "app_icon.ico"
windows_icon.parent.mkdir(parents=True, exist_ok=True)
cropped.resize((1024, 1024), Image.Resampling.LANCZOS).save(
    windows_icon,
    format="ICO",
    sizes=[(16, 16), (24, 24), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)],
)

print(f"Cropped {SRC.name}: {w}x{h} -> {side}x{side}, offset=({left},{top})")
print("Updated assets/logo.png and platform app icons.")
