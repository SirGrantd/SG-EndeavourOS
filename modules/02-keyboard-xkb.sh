#!/usr/bin/env bash
# ==============================================================================
# Módulo 02: Teclado XKB, Compose e Overrides Wayland/Electron
# Repositório: SG-EndevourOS
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "==> [02-Keyboard-XKB] Aplicando arquitetura de teclado e compatibilidade..."

# 1. Instalar layout XKB customizado em espaço de usuário
echo "  -> Instalando layout XKB 'us_custom' (Shift: aspas literais; AltGr: trema)..."
mkdir -p "$HOME/.config/xkb/symbols"
cp -a "$REPO_ROOT/configs/home/.config/xkb/symbols/us_custom" "$HOME/.config/xkb/symbols/us_custom"

# 2. Configurar KDE Plasma para carregar o us_custom
echo "  -> Aplicando configuração no kxkbrc..."
mkdir -p "$HOME/.config"
cp -a "$REPO_ROOT/configs/home/.config/kxkbrc" "$HOME/.config/kxkbrc"

# 3. Instalar tabela de composição .XCompose estilo Windows
echo "  -> Instalando tabela ~/.XCompose..."
cp -a "$REPO_ROOT/configs/home/.XCompose" "$HOME/.XCompose"

# 4. Instalar lançadores com isolamento Wayland/Electron
echo "  -> Instalando lançadores protegidos em ~/.local/share/applications/..."
mkdir -p "$HOME/.local/share/applications"
cp -a "$REPO_ROOT/configs/home/.local/share/applications/"* "$HOME/.local/share/applications/"

# 5. Atualizar base de dados do KDE
echo "  -> Atualizando cache de aplicativos (kbuildsycoca6)..."
kbuildsycoca6 2>/dev/null || true

echo "==> [02-Keyboard-XKB] Configuração de teclado e atalhos concluída com sucesso!"
