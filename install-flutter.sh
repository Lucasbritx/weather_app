#!/bin/bash
set -e

# Baixar e instalar Flutter
FLUTTER_VERSION="3.29.0" # Substitua pela versão desejada
curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_$FLUTTER_VERSION-stable.tar.xz
tar xf flutter_linux_$FLUTTER_VERSION-stable.tar.xz
export PATH="$PATH:$PWD/flutter/bin"
flutter --version