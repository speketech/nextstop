#!/usr/bin/env bash

# ─────────────────────────────────────────────────────────
# NextStop – Render.com Build Script
# 
# HOW THE API KEY WORKS (secure, no key in git):
#   1. web/index.html is in .gitignore (never pushed to GitHub)
#   2. render_build.sh IS pushed to GitHub (it has a placeholder only)
#   3. On Render dashboard → Environment → add:
#        Maps_API_KEY = AIzaSyCEJDXVlQfMxWbvmttYBI8Aex4lth-g7Qw
#   4. This script injects $Maps_API_KEY into index.html at build time
# ─────────────────────────────────────────────────────────

set -e

echo "🚀 Starting NextStop Web Build on Render..."

# ── 1. Setup Flutter ────────────────────────────────────
if [ ! -f "flutter/bin/flutter" ]; then
  echo "Cloning Flutter SDK (stable)..."
  rm -rf flutter
  git clone --depth 1 https://github.com/flutter/flutter.git -b stable
fi

export PATH="$PWD/flutter/bin:$PATH"

# ── 2. Enable web ────────────────────────────────────────
flutter config --enable-web

# ── 3. Create .env for asset bundling ───────────────────
# The .env is not in git — create it here from Render env vars
echo "Creating .env from Render environment variables..."
cat > .env << EOF
Maps_API_KEY=${Maps_API_KEY:-}
GEMINI_API_KEY=${GEMINI_API_KEY:-}
ISW_MERCHANT_ID=${ISW_MERCHANT_ID:-MX276440}
ISW_PAY_ITEM_ID=${ISW_PAY_ITEM_ID:-Default_Payable_MX276440}
ISW_CLIENT_ID=${ISW_CLIENT_ID:-}
ISW_SECRET_KEY=${ISW_SECRET_KEY:-}
API_URL=https://nextstop-api-ua95.onrender.com/api
SOCKET_URL=https://nextstop-api-ua95.onrender.com
EOF

# ── 4. Build web/index.html from template ───────────────
# web/index.html is NOT in git (it's in .gitignore).
# We always generate it fresh here, injecting the API key
# from the Render environment variable $Maps_API_KEY.

echo "Generating web/index.html with Maps API key..."

if [ -z "${Maps_API_KEY}" ]; then
  echo "⚠️  WARNING: Maps_API_KEY env var is not set on Render."
  echo "   Go to Render Dashboard → Your Service → Environment"
  echo "   and add: Maps_API_KEY = <your-google-maps-key>"
  MAPS_SCRIPT_TAG="<!-- Maps API key not configured -->"
else
  MAPS_SCRIPT_TAG="<script src=\"https://maps.googleapis.com/maps/api/js?key=${Maps_API_KEY}\"></script>"
fi

cat > web/index.html << HTMLEOF
<!DOCTYPE html>
<html>
<head>
  <base href="\$FLUTTER_BASE_HREF">
  <meta charset="UTF-8">
  <meta content="IE=Edge" http-equiv="X-UA-Compatible">
  <meta name="description" content="NextStop – Your Professional Commute, Reimagined.">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="apple-mobile-web-app-capable" content="yes">
  <meta name="apple-mobile-web-app-status-bar-style" content="black">
  <meta name="apple-mobile-web-app-title" content="NextStop">
  <link rel="apple-touch-icon" href="icons/Icon-192.png">
  <link rel="icon" type="image/png" href="favicon.png"/>
  <title>NextStop</title>
  <link rel="manifest" href="manifest.json">
  ${MAPS_SCRIPT_TAG}
</head>
<body>
  <script src="flutter_bootstrap.js" async></script>
</body>
</html>
HTMLEOF

echo "✅ web/index.html generated."

# ── 5. Get dependencies & build ─────────────────────────
echo "Fetching dependencies..."
flutter pub get

echo "Building Flutter Web (release)..."
flutter build web --release --no-wasm-dry-run

echo "✅ Build complete! Output is in build/web"