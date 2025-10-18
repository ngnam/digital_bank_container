#!/usr/bin/env bash
# Script: generate_icons.sh
# Mục đích: Tạo các icon chuẩn cho Android (mipmap) và iOS (AppIcon.appiconset)
# Yêu cầu: ImageMagick (`convert`) được cài sẵn. Trên Ubuntu: sudo apt install imagemagick
# Sử dụng: ./tools/generate_icons.sh
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SRC_ICON="$ROOT_DIR/assets/images/lauchIcon.png"
# Optional adaptive icon layers (foreground/background). If not provided, use SRC_ICON for both.
FG_ICON="$ROOT_DIR/assets/images/lauchIcon_foreground.png"
BG_ICON="$ROOT_DIR/assets/images/lauchIcon_background.png"
if [ ! -f "$SRC_ICON" ]; then
  echo "Không tìm thấy nguồn icon: $SRC_ICON"
  exit 1
fi
# Android mipmap sizes (in px) and target folder names
declare -A ANDROID_SIZES=(
  [mipmap-mdpi]=48
  [mipmap-hdpi]=72
  [mipmap-xhdpi]=96
  [mipmap-xxhdpi]=144
  [mipmap-xxxhdpi]=192
)
# iOS AppIcon sizes and filenames (as in AppIcon.appiconset)
# Reference sizes (point sizes * scale)
IOS_ICONS=(
  "20@1x:Icon-App-20x20@1x.png"
  "20@2x:Icon-App-20x20@2x.png"
  "20@3x:Icon-App-20x20@3x.png"
  "29@1x:Icon-App-29x29@1x.png"
  "29@2x:Icon-App-29x29@2x.png"
  "29@3x:Icon-App-29x29@3x.png"
  "40@1x:Icon-App-40x40@1x.png"
  "40@2x:Icon-App-40x40@2x.png"
  "40@3x:Icon-App-40x40@3x.png"
  "60@2x:Icon-App-60x60@2x.png"
  "60@3x:Icon-App-60x60@3x.png"
  "76@1x:Icon-App-76x76@1x.png"
  "76@2x:Icon-App-76x76@2x.png"
  "83.5@2x:Icon-App-83.5x83.5@2x.png"
  "1024@1x:Icon-App-1024x1024@1x.png"
)
# Backup function
backup_file() {
  local f="$1"
  if [ -f "$f" ] && [ ! -f "$f.bak" ]; then
    cp "$f" "$f.bak"
    echo "Backup: $f -> $f.bak"
  fi
}

# Generate Android icons
for folder in "${!ANDROID_SIZES[@]}"; do
  size=${ANDROID_SIZES[$folder]}
  dst_folder="$ROOT_DIR/android/app/src/main/res/$folder"
  mkdir -p "$dst_folder"
  dst_file="$dst_folder/ic_launcher.png"
  backup_file "$dst_file"
  convert "$SRC_ICON" -resize ${size}x${size} "$dst_file"
  echo "Generated Android: $dst_file (${size}x${size})"
done

# Generate adaptive icon layers for Android (foreground/background)
ADAPTIVE_DIR="$ROOT_DIR/android/app/src/main/res/mipmap-anydpi-v26"
mkdir -p "$ADAPTIVE_DIR"

# Determine which images to use for fg/bg
USE_FG="$SRC_ICON"
USE_BG="$SRC_ICON"
if [ -f "$FG_ICON" ]; then
  USE_FG="$FG_ICON"
fi
if [ -f "$BG_ICON" ]; then
  USE_BG="$BG_ICON"
fi

# Sizes for adaptive icon layers (in px) - use 108dp as baseline for xxxhdpi 432px; but we'll generate common scales
declare -A ADAPTIVE_SIZES=(
  [mdpi]=48
  [hdpi]=72
  [xhdpi]=96
  [xxhdpi]=144
  [xxxhdpi]=192
)

for density in "mdpi" "hdpi" "xhdpi" "xxhdpi" "xxxhdpi"; do
  size=${ADAPTIVE_SIZES[$density]}
  fg_folder="$ROOT_DIR/android/app/src/main/res/mipmap-${density}"
  bg_folder="$fg_folder"
  mkdir -p "$fg_folder"
  fg_dst="$fg_folder/ic_launcher_foreground.png"
  bg_dst="$bg_folder/ic_launcher_background.png"
  backup_file "$fg_dst"
  backup_file "$bg_dst"
  convert "$USE_FG" -resize ${size}x${size} "$fg_dst"
  convert "$USE_BG" -resize ${size}x${size} "$bg_dst"
  echo "Generated adaptive layers: $fg_dst and $bg_dst (${size}x${size})"
done

# Create adaptive icon xml (ic_launcher.xml) in mipmap-anydpi-v26
IC_XML="$ADAPTIVE_DIR/ic_launcher.xml"
backup_file "$IC_XML"
cat > "$IC_XML" <<EOF
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@mipmap/ic_launcher_background" />
    <foreground android:drawable="@mipmap/ic_launcher_foreground" />
</adaptive-icon>
EOF
echo "Generated adaptive icon xml: $IC_XML"

# Generate iOS icons
IOS_APPICON_DIR="$ROOT_DIR/ios/Runner/Assets.xcassets/AppIcon.appiconset"
mkdir -p "$IOS_APPICON_DIR"
for entry in "${IOS_ICONS[@]}"; do
  size_label=${entry%%:*}
  filename=${entry#*:}
  # size_label like 20@2x or 83.5@2x or 1024@1x
  point=${size_label%@*}
  scale=${size_label#*@}
  # calculate pixel size; handle decimal points
  pixels=$(awk "BEGIN{printf \"%d\", $point * $scale}")
  dst_file="$IOS_APPICON_DIR/$filename"
  backup_file "$dst_file"
  convert "$SRC_ICON" -resize ${pixels}x${pixels} "$dst_file"
  echo "Generated iOS: $dst_file (${pixels}x${pixels})"
done

# Update Contents.json to ensure required keys exist (basic merge)
CONTENTS_JSON="$IOS_APPICON_DIR/Contents.json"
if [ -f "$CONTENTS_JSON" ]; then
  cp "$CONTENTS_JSON" "$CONTENTS_JSON.bak" || true
fi
cat > "$CONTENTS_JSON" <<EOF
{
  "images" : [
    { "size" : "20x20", "idiom" : "iphone", "filename" : "Icon-App-20x20@1x.png", "scale" : "1x" },
    { "size" : "20x20", "idiom" : "iphone", "filename" : "Icon-App-20x20@2x.png", "scale" : "2x" },
    { "size" : "20x20", "idiom" : "iphone", "filename" : "Icon-App-20x20@3x.png", "scale" : "3x" },
    { "size" : "29x29", "idiom" : "iphone", "filename" : "Icon-App-29x29@1x.png", "scale" : "1x" },
    { "size" : "29x29", "idiom" : "iphone", "filename" : "Icon-App-29x29@2x.png", "scale" : "2x" },
    { "size" : "29x29", "idiom" : "iphone", "filename" : "Icon-App-29x29@3x.png", "scale" : "3x" },
    { "size" : "40x40", "idiom" : "iphone", "filename" : "Icon-App-40x40@1x.png", "scale" : "1x" },
    { "size" : "40x40", "idiom" : "iphone", "filename" : "Icon-App-40x40@2x.png", "scale" : "2x" },
    { "size" : "40x40", "idiom" : "iphone", "filename" : "Icon-App-40x40@3x.png", "scale" : "3x" },
    { "size" : "60x60", "idiom" : "iphone", "filename" : "Icon-App-60x60@2x.png", "scale" : "2x" },
    { "size" : "60x60", "idiom" : "iphone", "filename" : "Icon-App-60x60@3x.png", "scale" : "3x" },
    { "size" : "76x76", "idiom" : "ipad", "filename" : "Icon-App-76x76@1x.png", "scale" : "1x" },
    { "size" : "76x76", "idiom" : "ipad", "filename" : "Icon-App-76x76@2x.png", "scale" : "2x" },
    { "size" : "83.5x83.5", "idiom" : "ipad", "filename" : "Icon-App-83.5x83.5@2x.png", "scale" : "2x" },
    { "size" : "1024x1024", "idiom" : "ios-marketing", "filename" : "Icon-App-1024x1024@1x.png", "scale" : "1x" }
  ],
  "info" : {
    "version" : 1,
    "author" : "xcode"
  }
}
EOF

echo "Hoàn thành: Icons đã được tạo và cập nhật cho Android/iOS."

echo "Ghi chú: Nếu bạn muốn tạo adaptive icon cho Android hoặc tinh chỉnh nội dung AppIcon set, vui lòng chỉnh sửa script hoặc cung cấp các layer foreground/background riêng."