#!/usr/bin/env bash
set -euo pipefail

# --- Config ---
TAG="v15-mock"
TITLE="Mock release v15"
NOTES="Draft release with app-debug-mockv15.apk"
APK_PATH="app/test/app-debug-mockv15.apk"
REPO="ngnam/digital_bank_container"   # TODO: thay bằng repo của bạn, ví dụ: myuser/myapp

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
