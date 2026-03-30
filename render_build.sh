#!/usr/bin/env bash

# 1. Exit immediately on any error
set -e

echo "Starting NextStop Full Web Build..."

# 2. Setup Flutter (Fresh clone if missing)
if [ ! -f "flutter/bin/flutter" ]; then
  echo "Cloning Flutter SDK..."
  rm -rf flutter
  git clone --depth 1 https://github.com/flutter/flutter.git -b stable
fi

export PATH="$PWD/flutter/bin:$PATH"

# 3. HANDLE ASSETS: Create placeholder .env
# This prevents the "No file or variants found for asset: .env" error
if [ ! -f ".env" ]; then
  echo "Creating placeholder .env for asset bundling..."
  touch .env
  echo "API_URL=https://nextstop-api-ua95.onrender.com/api" > .env
fi

# 4. WEB CONFIGURATION
flutter config --enable-web
# Ensures the web folder and index.html exist
flutter create . --platforms web 

# 5. THE INJECTION: Swap Google Maps API Key
# Extract the key from your .env file
MAP_KEY=$(grep GOOGLE_MAPS_API_KEY .env | cut -d '=' -f2)

if [ -z "$MAP_KEY" ]; then
  echo "WARNING: GOOGLE_MAPS_API_KEY not found in .env. Map will be blank."
else
  echo "Injecting API Key into index.html..."
  # Replaces the placeholder in web/index.html with the actual key
  sed -i "s/GOOGLE_MAPS_PLACEHOLDER/$MAP_KEY/g" web/index.html
fi

# 6. BUILD PROCESS
echo "Fetching dependencies..."
flutter pub get

echo "Building for Web (Release)..."
# Using --no-wasm-dry-run to bypass incompatible package warnings
flutter build web --release --no-wasm-dry-run

echo "Build Complete! Files are in build/web"