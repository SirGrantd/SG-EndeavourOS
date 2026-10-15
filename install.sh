#!/usr/bin/env bash
# ==============================================================================
# Orquestrador Principal de Instalação: SG-EndevourOS (v2.0)
# Desktop Híbrido: Linux + Windows + macOS no KDE Plasma 6 Wayland
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULES_DIR="$SCRIPT_DIR/modules"

# Cores para feedback visual
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

clear 2>/dev/null || true

cat << "EOF"
  ____   ____        ______           _                               ___  ____  
 / ___| / ___|      | ____|_ __   __| | _____   _____  _   _ _ __    / _ \/ ___| 
 \___ \| |  _____   |  _| | '_ \ / _` |/ _ \ \ / / _ \| | | | '__|  | | | \___ \ 
  ___) | | |_____|  | |___| | | | (_| |  __/\ V / (_) | |_| | |     | |_| |___) |
 |____/ \____|      |_____|_| |_|\__,_|\___| \_/ \___/ \__,_|_|      \___/|____/ 
                                                                                  
  Instalador Modular de Ambiente e Dotfiles (Versão 2.0)
EOF

echo -e "${CYAN}----------------------------------------------------------------------${NC}"
echo -e "Diretório do instalador: ${YELLOW}$SCRIPT_DIR${NC}"
echo -e "${CYAN}----------------------------------------------------------------------${NC}"
echo ""

run_module() {
    local mod="$1"
    if [ -f "$MODULES_DIR/$mod" ]; then
        echo -e "\n${YELLOW}>>> Executando: $mod <<<${NC}"
        bash "$MODULES_DIR/$mod"
    else
        echo -e "${RED}[ERRO] Módulo '$mod' não encontrado em $MODULES_DIR.${NC}"
        return 1
    fi
}

echo "Selecione o modo de execução:"
echo "  1) Instalação Completa (Todos os módulos 00 ao 06)"
echo "  2) Apenas Teclado, Compose e Overrides Wayland (Módulo 02)"
echo "  3) Apenas Terminal Kitty e Dotfiles (Módulo 03)"
echo "  4) Apenas Ajustes de Interface do KDE Plasma 6 (Módulo 04)"
echo "  5) Apenas Armazenamento e Dev Stack (Módulos 05 e 06)"
echo "  0) Sair"
echo ""

read -rp "Opção [1-5, 0]: " OPTION

case "$OPTION" in
    1)
        echo -e "\n${GREEN}Iniciando Instalação Completa...${NC}"
        run_module "00-preflight.sh"
        run_module "01-packages.sh"
        run_module "02-keyboard-xkb.sh"
        run_module "03-terminal-kitty.sh"
        run_module "04-plasma-theme.sh"
        run_module "05-storage.sh"
        run_module "06-dev-stack.sh"
        ;;
    2)
        run_module "02-keyboard-xkb.sh"
        ;;
    3)
        run_module "03-terminal-kitty.sh"
        ;;
    4)
        run_module "04-plasma-theme.sh"
        ;;
    5)
        run_module "05-storage.sh"
        run_module "06-dev-stack.sh"
        ;;
    0)
        echo "Operação cancelada."
        exit 0
        ;;
    *)
        echo -e "${RED}Opção inválida.${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}======================================================================${NC}"
echo -e "${GREEN}   Operação concluída com sucesso! Configurações aplicadas.          ${NC}"
echo -e "${GREEN}======================================================================${NC}"
