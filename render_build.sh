#!/usr/bin/env bash

# 1. Exit immediately if a command exits with a non-zero status
set -e

echo "Starting NextStop Build Process..."

# 2. Setup Flutter (Correct pathing and fresh clone check)
if [ ! -f "flutter/bin/flutter" ]; then
  echo "Flutter not found or corrupted. Cleaning and Cloning..."
  rm -rf flutter
  git clone --depth 1 https://github.com/flutter/flutter.git -b stable
fi

# Add Flutter to the absolute path
export PATH="$PWD/flutter/bin:$PATH"

# 3. THE ASSET FIX: Create a placeholder .env file
# Flutter fails if an asset listed in pubspec.yaml is missing
if [ ! -f ".env" ]; then
  echo "Creating placeholder .env for the asset bundler..."
  touch .env
  # We add a default API URL so the app has a fallback
  echo "API_URL=https://nextstop-api-ua95.onrender.com/api" > .env
fi

# 4. Web Configuration
echo "Configuring project for Web..."
flutter config --enable-web
# Force-create the web folder if it was missing from the repo
flutter create . --platforms web 

# 5. Prepare Dependencies
echo "Fetching dependencies..."
flutter pub get

# 6. Build for Web (Release mode)
# Added --no-wasm-dry-run to silence the warnings about incompatible packages
echo "Building for Web (Release)..."
flutter build web --release --no-wasm-dry-run

echo "Build Complete! Files are in build/web"