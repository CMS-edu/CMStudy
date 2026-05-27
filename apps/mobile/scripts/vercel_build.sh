#!/usr/bin/env bash
set -euo pipefail

FLUTTER_DIR="${FLUTTER_DIR:-/tmp/flutter}"
API_BASE_URL="${API_BASE_URL:-https://cmstudy-server.onrender.com}"

if ! command -v flutter >/dev/null 2>&1; then
  if [ ! -x "$FLUTTER_DIR/bin/flutter" ]; then
    git clone https://github.com/flutter/flutter.git -b stable --depth 1 "$FLUTTER_DIR"
  fi
  export PATH="$PATH:$FLUTTER_DIR/bin"
fi

flutter config --enable-web
flutter pub get
flutter build web \
  --release \
  --no-source-maps \
  -O4 \
  --no-wasm-dry-run \
  --dart-define=API_BASE_URL="$API_BASE_URL"
