#!/usr/bin/env bash
# Gera o .aab de release. Exige as variáveis de ambiente (nenhum ID fica no código).
set -euo pipefail
cd "$(dirname "$0")/../frontend"
: "${ADMOB_APP_ID:?defina ADMOB_APP_ID}"
: "${ADMOB_BANNER_ANDROID:?defina ADMOB_BANNER_ANDROID}"
: "${ADMOB_INTERSTITIAL_ANDROID:?defina ADMOB_INTERSTITIAL_ANDROID}"
[ -f android/key.properties ] || { echo "Falta android/key.properties (rode scripts/gerar-keystore.sh)"; exit 1; }
flutter pub get
flutter analyze --no-fatal-infos
flutter test
flutter build appbundle --release \
  --dart-define=ADMOB_BANNER_ANDROID="$ADMOB_BANNER_ANDROID" \
  --dart-define=ADMOB_INTERSTITIAL_ANDROID="$ADMOB_INTERSTITIAL_ANDROID" \
  --dart-define=IAP_REMOVE_ADS_ID="${IAP_REMOVE_ADS_ID:-remove_ads}" \
  -PADMOB_APP_ID="$ADMOB_APP_ID"
echo "AAB: frontend/build/app/outputs/bundle/release/app-release.aab"
