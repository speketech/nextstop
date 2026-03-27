#!/usr/bin/env bash

# 1. Clone Flutter into a local folder
if [ ! -d "flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b stable
fi

# 2. Add Flutter to the path
export PATH="$PATH:`pwd`/flutter/bin"

# 3. Enable web support and build
flutter config --enable-web
flutter pub get
flutter build web --release