#!/usr/bin/env bash
# ==============================================================================
# Módulo 04: Ajustes Visuais, Tema de Ícones SG-Icons e Atalhos no KDE Plasma 6
# Repositório: SG-EndeavourOS
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "==> [04-Plasma-Theme] Injetando preferências visuais e tema SG-Icons no KDE Plasma 6..."

# 1. Instalar Tema de Ícones SG-Icons
echo "  -> Instalando tema de ícones SG-Icons em ~/.local/share/icons/..."
mkdir -p "$HOME/.local/share/icons"
rm -rf "$HOME/.local/share/icons/SG-Icons" "$HOME/.local/share/icons/SG-Icones"
cp -a "$REPO_ROOT/configs/home/.local/share/icons/SG-Icons" "$HOME/.local/share/icons/SG-Icons"
# Link de compatibilidade
ln -sfn "$HOME/.local/share/icons/SG-Icons" "$HOME/.local/share/icons/SG-Icones"

# Atualizar cache de ícones do KDE
if command -v kbuildsycoca6 >/dev/null 2>&1; then
    echo "  -> Reconstruindo cache de ícones do KDE Plasma 6 (kbuildsycoca6)..."
    kbuildsycoca6 --noincremental >/dev/null 2>&1 || true
fi

if ! command -v kwriteconfig6 >/dev/null 2>&1; then
    echo "  [AVISO] 'kwriteconfig6' não encontrado. Pulando injeção direta de configurações do Plasma."
    exit 0
fi

# 2. Ativar Tema de Ícones SG-Icons no Plasma
echo "  -> Ativando SG-Icons como tema de ícones ativo..."
kwriteconfig6 --file kdeglobals --group Icons --key Theme "SG-Icons"

# 3. Configurar KRunner Flutuante (estilo Spotlight do macOS)
echo "  -> Configurando KRunner como janela flutuante centralizada..."
kwriteconfig6 --file krunnerrc --group General --key FreeFloating true

# 4. Mapear atalho do KRunner para Meta + Espaço
echo "  -> Mapeando atalho do KRunner para Meta + Espaço..."
kwriteconfig6 --file kglobalshortcutsrc --group org.kde.krunner.desktop --key _launch "Meta+Space,Meta+Space,KRunner"

echo "==> [04-Plasma-Theme] Tema de ícones SG-Icons e atalhos configurados com sucesso!"
