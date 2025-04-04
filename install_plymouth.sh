#!/bin/bash
#
# install_plymouth.sh
#
# This script automates the installation of a custom animated Plymouth boot splash.
# It copies PNG images from a specified directory (named frame1.png, frame2.png, etc.),
# rotates and optionally scales them, creates the necessary theme files, and activates the theme.
#
# Usage:
#   sudo ./install_plymouth.sh -p /path/to/images [-c image_count] [-r rotation_angle] [-s scale_percentage]
#
# Options:
#   -p  Path to the directory containing your PNG images
#   -c  (Optional) Number of image frames (if omitted, the script counts matching files)
#   -r  (Optional) Rotation angle in degrees (e.g. -r 90 rotates the image clockwise 90 degrees)
#   -s  (Optional) Scaling percentage (e.g. 150 for 150% scaling; if omitted, no scaling is done)

# Check if running as root.
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root (e.g., using sudo)."
  exit 1
fi

# Function for usage message.
usage() {
    echo "Usage: $0 -p /path/to/images [-c image_count] [-r rotation_angle] [-s scale_percentage]"
    exit 1
}

# Parse command-line arguments.
while getopts ":p:c:r:s:" opt; do
  case ${opt} in
    p )
      IMAGE_PATH="$OPTARG"
      ;;
    c )
      IMAGE_COUNT="$OPTARG"
      ;;
    r )
      ROTATION="$OPTARG"
      ;;
    s )
      SCALE="$OPTARG"
      ;;
    \? )
      usage
      ;;
  esac
done

# Check if image path is provided.
if [ -z "$IMAGE_PATH" ]; then
    usage
fi

# Set default rotation if not provided.
if [ -z "$ROTATION" ]; then
    ROTATION=90
fi

# If image count is not provided, count the images in the supplied directory.
if [ -z "$IMAGE_COUNT" ]; then
    IMAGE_COUNT=$(ls "$IMAGE_PATH"/frame*.png 2>/dev/null | wc -l)
    if [ "$IMAGE_COUNT" -eq 0 ]; then
       echo "No images found in $IMAGE_PATH matching frame*.png"
       exit 1
    fi
fi

echo "Using images from: $IMAGE_PATH"
echo "Image count: $IMAGE_COUNT"
echo "Rotation angle: $ROTATION degrees"
if [ -n "$SCALE" ]; then
    echo "Scaling percentage: ${SCALE}%"
fi

# Check if we need ImageMagick for rotation or scaling.
if [ -n "$ROTATION" ] || [ -n "$SCALE" ]; then
    if ! command -v mogrify &> /dev/null; then
        read -p "ImageMagick (mogrify) is required for image processing but is not installed. Install it now? (y/n): " answer
        if [[ "$answer" =~ ^[Yy]$ ]]; then
            apt update && apt install -y imagemagick
        else
            echo "Cannot process images without ImageMagick. Exiting."
            exit 1
        fi
    fi
fi

# Define the Plymouth theme directory.
THEME_DIR="/usr/share/plymouth/themes/myanim"

# Create the theme directory.
mkdir -p "$THEME_DIR"

# Back up any existing theme images (optional)
if [ -d "$THEME_DIR" ]; then
    cp -r "$THEME_DIR" "${THEME_DIR}_backup_$(date +%s)"
fi

# Remove old frame images from the theme directory (if any).
rm -f "$THEME_DIR"/frame*.png

# Copy the images from the user-specified path.
cp "$IMAGE_PATH"/frame*.png "$THEME_DIR"/

# Rotate the images using ImageMagick.
echo "Rotating images by $ROTATION degrees..."
mogrify -rotate "$ROTATION" "$THEME_DIR"/frame*.png

# If scaling was provided, scale the images.
if [ -n "$SCALE" ]; then
    echo "Scaling images by ${SCALE}%..."
    mogrify -resize "${SCALE}%" "$THEME_DIR"/frame*.png
fi

# Create the Plymouth theme descriptor file.
DESCRIPTOR_FILE="$THEME_DIR/myanim.plymouth"
cat <<EOF > "$DESCRIPTOR_FILE"
[Plymouth Theme]
Name=My Animation
Description=Custom animated boot splash
ModuleName=script

[script]
ImageDir=$THEME_DIR
ScriptFile=$THEME_DIR/myanim.script
EOF

# Create the Plymouth script file.
SCRIPT_FILE="$THEME_DIR/myanim.script"
cat <<EOF > "$SCRIPT_FILE"
// Number of frames: $IMAGE_COUNT
frames = $IMAGE_COUNT;
frameImg = [];
for (i = 1; i <= frames; i++) {
    frameImg[i] = Image("frame" + i + ".png");
}
sprite = Sprite(frameImg[1]);
sprite.SetX(Window.GetWidth()/2 - sprite.GetImage().GetWidth()/2);
sprite.SetY(Window.GetHeight()/2 - sprite.GetImage().GetHeight()/2);
counter = 0;
fun refresh_callback() {
    // Adjust "/2" to change the animation speed.
    sprite.SetImage(frameImg[Math.Int(counter / 2) % frames]);
    counter++;
}
Plymouth.SetRefreshFunction(refresh_callback);
EOF

echo "Theme files created in $THEME_DIR."

# Activate the custom theme and rebuild initramfs.
echo "Activating the custom Plymouth theme..."
if plymouth-set-default-theme -R myanim; then
    echo "Theme activated successfully."
else
    echo "Automatic activation failed. Trying manual method..."
    update-alternatives --install /usr/share/plymouth/themes/default.plymouth default.plymouth "$THEME_DIR/myanim.plymouth" 100
    update-alternatives --set default.plymouth "$THEME_DIR/myanim.plymouth"
    update-initramfs -u
fi

echo "Installation complete. Please reboot your system to see the new animated boot splash."
