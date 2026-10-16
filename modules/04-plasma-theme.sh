#!/usr/bin/env bash
# ==============================================================================
# Módulo 04: Ajustes Visuais e Atalhos Cirúrgicos no KDE Plasma 6
# Repositório: SG-EndevourOS
# ==============================================================================

set -euo pipefail

echo "==> [04-Plasma-Theme] Injetando preferências cirúrgicas no KDE Plasma 6..."

if ! command -v kwriteconfig6 >/dev/null 2>&1; then
    echo "  [AVISO] 'kwriteconfig6' não encontrado. Pulando injeção direta de atalhos."
    exit 0
fi

# 1. Configurar KRunner Flutuante (estilo Spotlight do macOS)
echo "  -> Configurando KRunner como janela flutuante centralizada..."
kwriteconfig6 --file krunnerrc --group General --key FreeFloating true

# 2. Mapear atalho do KRunner para Meta + Espaço
echo "  -> Mapeando atalho do KRunner para Meta + Espaço..."
kwriteconfig6 --file kglobalshortcutsrc --group org.kde.krunner.desktop --key _launch "Meta+Space,Meta+Space,KRunner"

echo "==> [04-Plasma-Theme] Atalhos e configurações de interface injetados com sucesso!"
