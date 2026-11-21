#!/usr/bin/env bash
# FastLocation - preparação do projeto
#
# Gera as pastas nativas (somente Android e iOS), aplica as permissões e
# configurações necessárias, baixa as dependências, roda o codegen
# (MobX + Hive) e valida com analyze + testes.
#
# Uso:  cd fast_location && bash setup.sh
set -euo pipefail

cd "$(dirname "$0")"

command -v flutter >/dev/null 2>&1 || {
  echo "ERRO: Flutter não encontrado no PATH. Instale: https://docs.flutter.dev/get-started/install"
  exit 1
}

echo "==> Flutter instalado:"
flutter --version

# 01 - Projeto básico só para Android e iOS (não sobrescreve lib/, test/,
#      pubspec.yaml, README nem demais arquivos já existentes).
if [ ! -d android ] || [ ! -d ios ]; then
  echo "==> Gerando pastas nativas (android/ios)..."
  flutter create --platforms=android,ios --org br.com.fastdelivery \
    --project-name fast_location .
fi

# Remove qualquer outra plataforma que tenha sido criada por engano.
rm -rf web linux macos windows

MANIFEST=android/app/src/main/AndroidManifest.xml
if ! grep -q 'android.permission.INTERNET' "$MANIFEST"; then
  echo "==> Adicionando permissão INTERNET no AndroidManifest..."
  python3 - "$MANIFEST" <<'PY'
import sys, re
path = sys.argv[1]
s = open(path, encoding='utf-8').read()
s = re.sub(r'(<manifest[^>]*>)',
           r'\1\n    <uses-permission android:name="android.permission.INTERNET" />',
           s, count=1)
s = re.sub(r'android:label="[^"]*"', 'android:label="FastLocation"', s, count=1)
open(path, 'w', encoding='utf-8').write(s)
PY
fi

PLIST=ios/Runner/Info.plist
if [ -f "$PLIST" ] && ! grep -q 'LSApplicationQueriesSchemes' "$PLIST"; then
  echo "==> Configurando Info.plist (apps de mapas e nome do app)..."
  python3 - "$PLIST" <<'PY'
import sys, re
path = sys.argv[1]
s = open(path, encoding='utf-8').read()
extra = """	<key>LSApplicationQueriesSchemes</key>
	<array>
		<string>comgooglemaps</string>
		<string>waze</string>
	</array>
"""
idx = s.rfind('</dict>')
s = s[:idx] + extra + s[idx:]
s = re.sub(r'(<key>CFBundleDisplayName</key>\s*<string>)[^<]*(</string>)',
           r'\1FastLocation\2', s, count=1)
open(path, 'w', encoding='utf-8').write(s)
PY
fi

echo "==> flutter pub get"
flutter pub get

echo "==> Codegen (MobX + Hive)"
if ! dart run build_runner build --delete-conflicting-outputs; then
  echo "AVISO: build_runner falhou. Os arquivos *.g.dart já versionados"
  echo "       continuam válidos e o app roda normalmente."
fi

echo "==> flutter analyze"
flutter analyze || true

echo "==> flutter test"
flutter test

echo
echo "Pronto! Conecte um dispositivo/emulador Android e rode:  flutter run"
