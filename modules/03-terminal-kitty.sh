#!/usr/bin/env bash
# ==============================================================================
# Módulo 03: Terminal Kitty (Aceleração GPU, Temas e Atalhos Windows)
# Repositório: SG-EndevourOS
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "==> [03-Terminal-Kitty] Configurando emulador de terminal Kitty..."

# 1. Criar diretórios de configuração do Kitty
mkdir -p "$HOME/.config/kitty/backgrounds"

# 2. Copiar dotfiles do Kitty
echo "  -> Copiando kitty.conf, current-theme.conf e imagem de fundo..."
cp -a "$REPO_ROOT/configs/home/.config/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
cp -a "$REPO_ROOT/configs/home/.config/kitty/current-theme.conf" "$HOME/.config/kitty/current-theme.conf"
cp -a "$REPO_ROOT/configs/home/.config/kitty/backgrounds/"* "$HOME/.config/kitty/backgrounds/"

# 3. Preservar perfil de contingência do Konsole
if [ -d "$REPO_ROOT/configs/home/.local/share/konsole" ]; then
    echo "  -> Preservando perfil de contingência do Konsole..."
    mkdir -p "$HOME/.local/share/konsole"
    cp -a "$REPO_ROOT/configs/home/.local/share/konsole/"* "$HOME/.local/share/konsole/"
fi

echo "==> [03-Terminal-Kitty] Configuração do terminal Kitty concluída!"
