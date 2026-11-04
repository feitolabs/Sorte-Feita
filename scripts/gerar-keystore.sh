#!/usr/bin/env bash
# Gera a keystore de release e o frontend/android/key.properties (ambos fora do Git).
# Você digita as senhas; elas não ficam neste script.
set -euo pipefail
cd "$(dirname "$0")/.."
if ! command -v keytool >/dev/null 2>&1; then
  for d in "/c/Program Files/Android/Android Studio/jbr/bin" "/c/Program Files/Android/Android Studio/jre/bin" "$JAVA_HOME/bin"; do
    [ -x "$d/keytool.exe" ] || [ -x "$d/keytool" ] && PATH="$d:$PATH" && break
  done
fi
command -v keytool >/dev/null 2>&1 || { echo "keytool não encontrado. Instale o JDK ou o Android Studio."; exit 1; }
KS="$HOME/sorte-feita-release.jks"
[ -e "$KS" ] && { echo "Já existe $KS — abortando para não sobrescrever."; exit 1; }
read -r -s -p "Senha da keystore (mín. 6): " PASS; echo
keytool -genkeypair -v -keystore "$KS" -alias sortefeita -keyalg RSA -keysize 2048 \
  -validity 10000 -storepass "$PASS" -keypass "$PASS" -dname "CN=Feito Labs, O=Feito Labs, C=BR"
cat > frontend/android/key.properties <<EOF
storePassword=$PASS
keyPassword=$PASS
keyAlias=sortefeita
storeFile=$KS
EOF
echo "OK. Faça backup de $KS e das senhas."
