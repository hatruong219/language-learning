#!/usr/bin/env bash
# Build Kotoba (Flutter web) và chép vào public/kotoba-app/app. Chạy trên Vercel trước `next build`.
set -euo pipefail

FLUTTER_VERSION="3.32.0"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

find_flutter() {
  if [ -n "${FLUTTER_BIN:-}" ] && [ -x "$FLUTTER_BIN" ]; then echo "$FLUTTER_BIN"; return; fi
  if command -v flutter >/dev/null 2>&1; then command -v flutter; return; fi
  if [ -x "$HOME/sdk/flutter/bin/flutter" ]; then echo "$HOME/sdk/flutter/bin/flutter"; return; fi
  if [ ! -x "$ROOT/.flutter-sdk/bin/flutter" ]; then
    echo "Flutter not found, cloning $FLUTTER_VERSION into .flutter-sdk" >&2
    rm -rf "$ROOT/.flutter-sdk"
    git clone --depth 1 --branch "$FLUTTER_VERSION" https://github.com/flutter/flutter.git "$ROOT/.flutter-sdk" >&2
  fi
  echo "$ROOT/.flutter-sdk/bin/flutter"
}

# Flutter cần unzip để giải nén dart-sdk.
if ! command -v unzip >/dev/null 2>&1 && command -v dnf >/dev/null 2>&1; then
  dnf install -y unzip
fi

FLUTTER="$(find_flutter)"
# Vercel chạy root: Flutter từ chối root trừ khi bật cờ này.
export FLUTTER_ALLOW_ROOT=1 CI=true

version_line="$("$FLUTTER" --version 2>/dev/null | head -n 1 || true)"
case "$version_line" in
  *"Flutter $FLUTTER_VERSION"*) ;;
  *) echo "WARNING: expected Flutter $FLUTTER_VERSION, got: ${version_line:-unknown}" >&2 ;;
esac

"$FLUTTER" config --no-analytics >/dev/null 2>&1 || true

(
  cd "$ROOT/kotoba"
  "$FLUTTER" pub get
  "$FLUTTER" build web --release --base-href /kotoba-app/app/ --no-web-resources-cdn
)

rm -rf "$ROOT/public/kotoba-app/app"
mkdir -p "$ROOT/public/kotoba-app"
cp -r "$ROOT/kotoba/build/web" "$ROOT/public/kotoba-app/app"
echo "Kotoba web copied to public/kotoba-app/app"
