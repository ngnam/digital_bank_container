#!/usr/bin/env bash
set -euo pipefail

# --- Config ---
TAG="app-dev-release"
TITLE="Mock Development Release"
NOTES="Draft release with mock development APK for testing purposes."
APK_PATH="build/app/outputs/flutter-apk/app-dev-release.apk"
REPO="namthuviec/digital_bank_container"   # TODO: thay bằng repo của bạn, ví dụ: myuser/myapp

# --- Check token ---
if [[ -z "${GITHUB_TOKEN:-}" && -z "${GH_TOKEN:-}" ]]; then
  echo "❌ GITHUB_TOKEN hoặc GH_TOKEN chưa được set. Vui lòng export trước:"
  echo "   export GITHUB_TOKEN=ghp_xxxYourTokenHere"
  exit 1
fi

# --- Create draft release + upload file ---
echo "🚀 Tạo Draft Release $TAG cho repo $REPO ..."
gh release create "$TAG" \
  --repo "$REPO" \
  --title "$TITLE" \
  --notes "$NOTES" \
  --draft \
  "$APK_PATH"

echo "✅ Hoàn tất: Release $TAG đã được tạo với file $APK_PATH"