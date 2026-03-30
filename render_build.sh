#!/usr/bin/env bash

# 1. Exit on any error
set -e

echo "Starting NextStop Build Process..."

# 2. Check if Flutter binary exists. If not, delete the folder and re-clone.
# This fixes the "command not found" error from corrupted previous builds
if [ ! -f "flutter/bin/flutter" ]; then
  echo "Flutter not found or corrupted. Cleaning and Cloning..."
  rm -rf flutter
  git clone --depth 1 https://github.com/flutter/flutter.git -b stable
else
  echo "Existing Flutter installation found."
fi

# 3. Use absolute path for reliability
export PATH="$PWD/flutter/bin:$PATH"

# 4. Final verification of the command
if ! command -v flutter &> /dev/null
then
    echo "FATAL: Flutter still not found. Check Render disk space."
    exit 1
fi

echo "Flutter is ready: $(flutter --version | head -n 1)"

# 5. Build for Web
flutter config --enable-web
flutter pub get
flutter build web --release --web-renderer canvaskit

echo "Build Complete! Files are in build/web"