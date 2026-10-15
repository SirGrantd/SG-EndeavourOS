#!/usr/bin/env bash
# ==============================================================================
# Módulo 01: Instalação e Verificação de Pacotes Base
# Repositório: SG-EndevourOS
# ==============================================================================

set -euo pipefail

echo "==> [01-Packages] Verificando e instalando pacotes fundamentais..."

# Lista de pacotes oficiais prioritários
OFFICIAL_PKGS=(
    kitty
    wl-clipboard
    zsh
    ttf-jetbrains-mono
    ttf-jetbrains-mono-nerd
    ttf-roboto
    duf
    glances
    mission-center
    tldr
)

MISSING_OFFICIAL=()

for pkg in "${OFFICIAL_PKGS[@]}"; do
    if ! pacman -Qi "$pkg" >/dev/null 2>&1; then
        MISSING_OFFICIAL+=("$pkg")
    fi
done

if [ ${#MISSING_OFFICIAL[@]} -gt 0 ]; then
    echo "  -> Pacotes a instalar via pacman: ${MISSING_OFFICIAL[*]}"
    sudo pacman -S --needed --noconfirm "${MISSING_OFFICIAL[@]}"
else
    echo "  -> Todos os pacotes oficiais essenciais já estão instalados."
fi

# Verificar se o yay está disponível
if ! command -v yay >/dev/null 2>&1; then
    echo "  [AVISO] 'yay' (auxiliar AUR) não encontrado. Recomenda-se instalá-lo para pacotes como brave-bin e visual-studio-code-bin."
else
    echo "  -> Auxiliar AUR 'yay' detectado."
fi

echo "==> [01-Packages] Instalação de pacotes base concluída!"
