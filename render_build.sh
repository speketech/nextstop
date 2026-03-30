#!/usr/bin/env bash

# 1. Exit immediately if a command exits with a non-zero status
set -e

# 2. Clone Flutter (Shallow clone to save time and avoid timeouts)
if [ ! -d "flutter" ]; then
  echo "Cloning Flutter..."
  git clone --depth 1 https://github.com/flutter/flutter.git -b stable
fi

# 3. Add Flutter to the FRONT of the path using the absolute PWD
export PATH="$PWD/flutter/bin:$PATH"

# 4. Verify Flutter was installed correctly
if ! command -v flutter &> /dev/null
then
    echo "Error: Flutter command not found even after export."
    exit 1
fi

echo "Flutter found at: $(command -v flutter)"

# 5. Enable web support and ensure web folder exists
flutter config --enable-web
if [ ! -d "web" ]; then
  echo "Generating web platform files..."
  flutter create . --platforms web 
fi

# 6. Build the project
echo "Running pub get..."
flutter pub get

echo "Building Flutter Web (Release mode)..."
flutter build web --release