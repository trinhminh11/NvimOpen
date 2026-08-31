#!/bin/zsh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
APP="$ROOT/dist/NvimOpen.app"
CONTENTS="$APP/Contents"
MACOS="$CONTENTS/MacOS"

rm -rf "$APP"
mkdir -p "$MACOS"

echo "Building NvimOpen..."

# Keep each terminal adapter in Sources/terms/*.swift.
xcrun swiftc \
  -O \
  -framework AppKit \
  "$ROOT"/Sources/terms/*.swift \
  "$ROOT"/Sources/main.swift \
  -o "$MACOS/NvimOpen"

cp "$ROOT/Info.plist" "$CONTENTS/Info.plist"
plutil -lint "$CONTENTS/Info.plist" >/dev/null

# Ad-hoc signing is sufficient for a local personal app.
codesign --force --deep --sign - "$APP"

echo
echo "Built:"
echo "  $APP"
echo
echo "Install:"
echo "  cp -R \"$APP\" /Applications/"
