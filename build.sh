#!/bin/bash

# Instalar o Flutter (stable branch)
git clone https://github.com/flutter/flutter.git -b stable

# Adicionar Flutter ao PATH
export PATH="$PATH:`pwd`/flutter/bin"

# Verificar instalação do Flutter
flutter doctor

# Instalar dependências
flutter pub get

# Compilar o projeto para web
flutter build web --release