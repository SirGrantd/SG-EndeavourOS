#!/usr/bin/env bash
# ==============================================================================
# Módulo 03: Terminal Kitty (Aceleração GPU, Temas e Atalhos Windows)
# Repositório: SG-EndeavourOS
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

# 3. Definir Kitty como terminal padrão no KDE Plasma (se kwriteconfig6 estiver disponível)
if command -v kwriteconfig6 >/dev/null 2>&1; then
    echo "  -> Definindo Kitty como emulador de terminal padrão do KDE Plasma..."
    kwriteconfig6 --file kdeglobals --group General --key TerminalApplication "kitty"
    kwriteconfig6 --file kdeglobals --group General --key TerminalService "kitty.desktop"
fi

echo "==> [03-Terminal-Kitty] Configuração do terminal Kitty concluída!"
