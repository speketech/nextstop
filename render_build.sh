#!/usr/bin/env bash

# 1. Exit on error
set -e

echo "Starting NextStop Build Process..."

# 2. Setup Flutter
if [ ! -f "flutter/bin/flutter" ]; then
  echo "Fresh Clone of Flutter..."
  rm -rf flutter
  git clone --depth 1 https://github.com/flutter/flutter.git -b stable
fi

export PATH="$PWD/flutter/bin:$PATH"

# 3. Prepare Environment
flutter config --enable-web
echo "Fetching dependencies..."
flutter pub get

# 4. Build for Web (Simplified Command)
echo "Building for Web..."
flutter build web --release

echo "Build successfully!"