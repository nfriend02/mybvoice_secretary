#!/usr/bin/env bash
# Github → Vercel: install Flutter, inject env, build web.
set -euo pipefail

FLUTTER_VERSION="${FLUTTER_VERSION:-stable}"
FLUTTER_DIR="${HOME}/flutter"

if [ ! -d "$FLUTTER_DIR" ]; then
  git clone https://github.com/flutter/flutter.git -b "$FLUTTER_VERSION" --depth 1 "$FLUTTER_DIR"
fi

export PATH="$FLUTTER_DIR/bin:$PATH"
flutter --version
flutter precache --web

SITE_URL="${VERCEL_PROJECT_PRODUCTION_URL:-}"
if [ -n "$SITE_URL" ] && [[ "$SITE_URL" != http* ]]; then
  SITE_URL="https://${SITE_URL}"
fi

mkdir -p assets/config
cat > assets/config/app.env <<EOF
FIREBASE_API_KEY=${FIREBASE_API_KEY:-AIzaSyBEuX4P4LqXxPjty8jFsg07FDqH5KeIN04}
FIREBASE_AUTH_DOMAIN=${FIREBASE_AUTH_DOMAIN:-mybvoicesecretary.firebaseapp.com}
FIREBASE_PROJECT_ID=${FIREBASE_PROJECT_ID:-mybvoicesecretary}
FIREBASE_STORAGE_BUCKET=${FIREBASE_STORAGE_BUCKET:-mybvoicesecretary.firebasestorage.app}
FIREBASE_MESSAGING_SENDER_ID=${FIREBASE_MESSAGING_SENDER_ID:-571265659624}
FIREBASE_APP_ID=${FIREBASE_APP_ID:-1:571265659624:web:e4a946b2f2ec46d7900f5d}
FIREBASE_MEASUREMENT_ID=${FIREBASE_MEASUREMENT_ID:-G-5VZQXB0CFB}
APP_TITLE=${APP_TITLE:-MYB Voice Secretary}
APP_DESCRIPTION=${APP_DESCRIPTION:-음성 대화, PDF 요약, 대화 요약, RAG 검색을 담은 밝고 즐거운 파스텔 톤 음성 비서. 웹과 모바일을 함께 씁니다.}
APP_AUTHOR=${APP_AUTHOR:-MyBranch Team}
APP_ICON_URL=${APP_ICON_URL:-/icons/Icon-512.png}
GITHUB_BRANCH_URL=${GITHUB_BRANCH_URL:-https://github.com/nfriend02/mybvoice_secretary}
VERCEL_SITE_URL=${VERCEL_SITE_URL:-${SITE_URL:-https://mybvoice-secretary.vercel.app}}
EOF
cp assets/config/app.env assets/config/app_config.env
cp assets/config/app.env .env

flutter pub get
flutter build web --release
