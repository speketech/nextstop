#!/usr/bin/env bash

# 1. Exit on error
set -e

echo "Starting NextStop Build Process..."

# 2. Setup Flutter (Correct pathing)
if [ ! -f "flutter/bin/flutter" ]; then
  echo "Fresh Clone of Flutter..."
  rm -rf flutter
  git clone --depth 1 https://github.com/flutter/flutter.git -b stable
fi

export PATH="$PWD/flutter/bin:$PATH"

# 3. THE FIX: Force-create web configuration
echo "Configuring project for Web..."
flutter config --enable-web
# This creates the missing 'web/' folder that Render is complaining about
flutter create . --platforms web 

# 4. Prepare Dependencies
echo "Fetching dependencies..."
flutter pub get

# 5. Build for Web
echo "Building for Web (Release)..."
flutter build web --release

echo "Build Complete! Files are in build/web"