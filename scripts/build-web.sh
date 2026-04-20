#!/bin/bash
#
# Build script for TwoSpace Web version
# Usage: ./scripts/build-web.sh [--clean] [--release]
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${SCRIPT_DIR}/build/web"
CLEAN_BUILD=false
RELEASE_MODE="--release"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --clean)
      CLEAN_BUILD=true
      shift
      ;;
    --debug)
      RELEASE_MODE=""
      shift
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: $0 [--clean] [--debug]"
      exit 1
      ;;
  esac
done

echo "🔨 Building TwoSpace Web version..."
echo "   Release mode: ${RELEASE_MODE:-debug}"
echo "   Clean build: ${CLEAN_BUILD}"

if [ "$CLEAN_BUILD" = true ]; then
  echo "🧹 Cleaning previous build..."
  rm -rf "$BUILD_DIR"
fi

cd "$SCRIPT_DIR"

# Ensure dependencies are up to date
echo "📦 Getting dependencies..."
flutter pub get

# Run code generation if needed
echo "🔄 Running code generation..."
dart run build_runner build -d

# Generate localizations
echo "🌍 Generating localizations..."
flutter gen-l10n

# Build web version
echo "🌐 Building web version..."
flutter build web $RELEASE_MODE --base-href=/

echo "✅ Build completed successfully!"
echo "   Output directory: $BUILD_DIR"
echo ""
echo "📊 Build size:"
du -sh "$BUILD_DIR" || true

# Show information about dist structure
echo ""
echo "📁 Distribution structure:"
ls -lh "$BUILD_DIR" | head -20
