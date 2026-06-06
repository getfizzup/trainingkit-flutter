#!/usr/bin/env bash
set -euo pipefail

# Resolves to the iOS plugin root (the directory that contains the podspec),
# because this script lives in ios/scripts/.
IOS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SDK_REPO_URL="${TRAININGKIT_IOS_SDK_URL:-https://github.com/getfizzup/trainingkit-ios-sdk/archive/refs/heads/main.zip}"
VENDOR_DIR="$IOS_ROOT/Vendor"
FRAMEWORK_DIR="$VENDOR_DIR/TrainingKit.xcframework"
TMP_DIR="$(mktemp -d)"
ARCHIVE_PATH="$TMP_DIR/trainingkit-ios-sdk.zip"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

mkdir -p "$VENDOR_DIR"

printf 'Downloading TrainingKit.xcframework from %s\n' "$SDK_REPO_URL"
curl --fail --location --silent --show-error "$SDK_REPO_URL" --output "$ARCHIVE_PATH"

unzip -q "$ARCHIVE_PATH" -d "$TMP_DIR"

SOURCE_FRAMEWORK="$TMP_DIR/trainingkit-ios-sdk-main/TrainingKit.xcframework"

if [[ ! -d "$SOURCE_FRAMEWORK" ]]; then
  printf 'TrainingKit.xcframework was not found in the downloaded archive.\n' >&2
  exit 1
fi

rm -rf "$FRAMEWORK_DIR"
cp -R "$SOURCE_FRAMEWORK" "$FRAMEWORK_DIR"

printf 'Installed %s\n' "$FRAMEWORK_DIR"
