#!/usr/bin/env bash

# 1. Clone Flutter into a local folder
if [ ! -d "flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b stable
fi

# 2. Add Flutter to the path
export PATH="$PATH:`pwd`/flutter/bin"

# 3. Enable web support and force-recreate web entry points
# This ensures the 'web/' directory is fully recognized
flutter config --enable-web
flutter create . --platforms web 

# 4. Clean and Build
flutter pub get
flutter build web --release