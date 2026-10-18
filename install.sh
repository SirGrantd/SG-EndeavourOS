#!/usr/bin/env bash
# ==============================================================================
# Orquestrador Principal de Instalação: SG-EndeavourOS (v2.0)
# Desktop Híbrido: Linux + Windows + macOS no KDE Plasma 6 Wayland
# Assistente Interativo e Modular
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULES_DIR="$SCRIPT_DIR/modules"

# Cores para feedback visual
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m' # No Color

clear 2>/dev/null || true

cat << "EOF"
  ____   ____        ______           _                               ___  ____  
 / ___| / ___|      | ____|_ __   __| | _____   _____  _   _ _ __    / _ \/ ___| 
 \___ \| |  _____   |  _| | '_ \ / _` |/ _ \ \ / / _ \| | | | '__|  | | | \___ \ 
  ___) | | |_____|  | |___| | | | (_| |  __/\ V / (_) | |_| | |     | |_| |___) |
 |____/ \____|      |_____|_| |_|\__,_|\___| \_/ \___/ \__,_|_|      \___/|____/ 
                                                                                  
  Assistente Interativo de Personalização de Desktop (KDE Plasma 6 / Wayland)
EOF

echo -e "${CYAN}----------------------------------------------------------------------${NC}"
echo -e "Diretório do instalador: ${YELLOW}$SCRIPT_DIR${NC}"
echo -e "${CYAN}----------------------------------------------------------------------${NC}"
echo ""

run_module() {
    local mod="$1"
    shift || true
    if [ -f "$MODULES_DIR/$mod" ]; then
        echo -e "\n${YELLOW}>>> Executando: $mod <<<${NC}"
        bash "$MODULES_DIR/$mod" "$@"
    else
        echo -e "${RED}[ERRO] Módulo '$mod' não encontrado em $MODULES_DIR.${NC}"
        return 1
    fi
}

# ------------------------------------------------------------------------------
# ROTEIRO GUIADO (PASSO A PASSO / ESTILO WIZARD)
# ------------------------------------------------------------------------------
guided_wizard() {
    echo -e "${BOLD}Iniciando Roteiro de Instalação Personalizado...${NC}\n"
    
    # 1. Pré-verificação
    run_module "00-preflight.sh"

    local DO_KEYBOARD=false
    local DO_KITTY=false
    local DO_PLASMA=false
    local OVERRIDE_ARGS=()
    local OVERRIDE_NAMES=()

    echo -e "\n${CYAN}----------------------------------------------------------------------${NC}"
    echo -e "${BOLD}[Passo 1/3: Teclado e Digitação US-BR]${NC}"
    echo -e "  • Shift + ': aspas duplas (\") instantâneas"
    echo -e "  • AltGr + ': trema (dead_diaeresis)"
    echo -e "  • AltGr + c: ç / Ç direto no nível de hardware (XKB)"
    echo -e "  • ~/.XCompose completo estilo Windows (cedilha e repetição de teclas)"
    echo -e "${CYAN}----------------------------------------------------------------------${NC}"
    read -rp "Deseja configurar o layout de teclado US-BR e a tabela ~/.XCompose? [S/n]: " RESP_KB
    if [[ ! "$RESP_KB" =~ ^[nN]$ ]]; then
        DO_KEYBOARD=true
        
        echo ""
        read -rp "  ↳ Deseja instalar configurações extras de compatibilidade (contingência) para apps Electron? [s/N]: " RESP_OVR
        if [[ "$RESP_OVR" =~ ^[sS]$ ]]; then
            echo ""
            echo "    Selecione os aplicativos que deseja configurar:"
            echo "      1) Brave Browser (brave-browser.desktop)"
            echo "      2) Discord (discord.desktop)"
            echo "      3) Visual Studio Code (com.microsoft.VSCode.desktop)"
            echo "      4) Todos os anteriores"
            echo "      0) Pular / Nenhum"
            echo ""
            read -rp "    Opção [1-4 ou múltiplos ex: 1 2]: " OVR_CHOICES
            
            for ch in $OVR_CHOICES; do
                case "$ch" in
                    1) OVERRIDE_ARGS+=("--brave"); OVERRIDE_NAMES+=("Brave Browser") ;;
                    2) OVERRIDE_ARGS+=("--discord"); OVERRIDE_NAMES+=("Discord") ;;
                    3) OVERRIDE_ARGS+=("--vscode"); OVERRIDE_NAMES+=("VS Code") ;;
                    4) 
                        OVERRIDE_ARGS=("--all-overrides")
                        OVERRIDE_NAMES=("Todos (Brave, Discord, VS Code)")
                        break
                        ;;
                    0) break ;;
                esac
            done
        fi
        if [ ${#OVERRIDE_ARGS[@]} -eq 0 ]; then
            OVERRIDE_ARGS=("--no-overrides")
        fi
    fi

    echo -e "\n${CYAN}----------------------------------------------------------------------${NC}"
    echo -e "${BOLD}[Passo 2/3: Terminal Moderno Kitty & Fontes JetBrains]${NC}"
    echo -e "  • Aceleração por GPU (OpenGL) de baixa latência"
    echo -e "  • Fontes JetBrains Mono e Roboto"
    echo -e "  • Abas powerline e atalhos amigáveis (Ctrl+C para copiar)"
    echo -e "${CYAN}----------------------------------------------------------------------${NC}"
    read -rp "Deseja configurar o Kitty como seu terminal acelerado com dotfiles e fontes? [S/n]: " RESP_KITTY
    if [[ ! "$RESP_KITTY" =~ ^[nN]$ ]]; then
        DO_KITTY=true
    fi

    echo -e "\n${CYAN}----------------------------------------------------------------------${NC}"
    echo -e "${BOLD}[Passo 3/3: Experiência KDE Plasma 6 & Tema SG-Icons]${NC}"
    echo -e "  • Tema de ícones minimalista SG-Icons instalado e ativado"
    echo -e "  • KRunner centralizado e flutuante estilo Spotlight do macOS"
    echo -e "  • Atalho de busca universal em Meta + Espaço"
    echo -e "  • Preserva atalhos nativos do sistema (Ctrl + Esc intocado)"
    echo -e "${CYAN}----------------------------------------------------------------------${NC}"
    read -rp "Deseja aplicar os ajustes visuais do Plasma 6 (Tema SG-Icons e KRunner)? [S/n]: " RESP_PLASMA
    if [[ ! "$RESP_PLASMA" =~ ^[nN]$ ]]; then
        DO_PLASMA=true
    fi

    # Tela de Resumo
    echo -e "\n${GREEN}======================================================================${NC}"
    echo -e "${BOLD}                      RESUMO DA SUA CONFIGURAÇÃO                      ${NC}"
    echo -e "${GREEN}======================================================================${NC}"
    if [ "$DO_KEYBOARD" = true ]; then
        echo -e "  ${GREEN}[✓]${NC} Layout de Teclado US-BR e ~/.XCompose"
        if [ ${#OVERRIDE_NAMES[@]} -gt 0 ]; then
            echo -e "      ↳ Contingências selecionadas: ${YELLOW}${OVERRIDE_NAMES[*]}${NC}"
        else
            echo -e "      ↳ Contingências: ${CYAN}Nenhuma (base limpa)${NC}"
        fi
    else
        echo -e "  ${RED}[✗]${NC} Layout de Teclado US-BR (ignorado)"
    fi

    if [ "$DO_KITTY" = true ]; then
        echo -e "  ${GREEN}[✓]${NC} Terminal Kitty (Aceleração GPU, Fontes JetBrains e Dotfiles)"
    else
        echo -e "  ${RED}[✗]${NC} Terminal Kitty (ignorado)"
    fi

    if [ "$DO_PLASMA" = true ]; then
        echo -e "  ${GREEN}[✓]${NC} Ajustes Visuais Plasma 6 (Tema de Ícones SG-Icons e KRunner)"
    else
        echo -e "  ${RED}[✗]${NC} Ajustes Visuais Plasma 6 (ignorado)"
    fi
    echo -e "${GREEN}======================================================================${NC}"
    echo ""

    read -rp "Deseja aplicar as configurações selecionadas agora? [S/n]: " CONFIRM_APPLY
    if [[ "$CONFIRM_APPLY" =~ ^[nN]$ ]]; then
        echo "Operação cancelada pelo usuário."
        exit 0
    fi

    echo -e "\n${GREEN}Iniciando aplicação cirúrgica das configurações...${NC}"

    # Instalação de pacotes necessários
    if [ "$DO_KITTY" = true ] || [ "$DO_KEYBOARD" = true ]; then
        run_module "01-packages.sh"
    fi

    if [ "$DO_KEYBOARD" = true ]; then
        run_module "02-keyboard-xkb.sh" "${OVERRIDE_ARGS[@]}"
    fi

    if [ "$DO_KITTY" = true ]; then
        run_module "03-terminal-kitty.sh"
    fi

    if [ "$DO_PLASMA" = true ]; then
        run_module "04-plasma-theme.sh"
    fi
}

# ------------------------------------------------------------------------------
# MENU PRINCIPAL
# ------------------------------------------------------------------------------
echo "Selecione o modo de execução:"
echo "  1) [Recomendado] Roteiro Guiado Passo a Passo (escolha cada componente)"
echo "  2) Instalação Express (aplica todos os recursos do Desktop de uma vez)"
echo "  3) Menu Avançado (executar módulo isolado)"
echo "  0) Sair"
echo ""

read -rp "Opção [1-3, 0] [Padrão: 1]: " OPTION
OPTION="${OPTION:-1}"

case "$OPTION" in
    1)
        guided_wizard
        ;;
    2)
        echo -e "\n${GREEN}Iniciando Instalação Express do Desktop...${NC}"
        run_module "00-preflight.sh"
        run_module "01-packages.sh"
        run_module "02-keyboard-xkb.sh" "--no-overrides"
        run_module "03-terminal-kitty.sh"
        run_module "04-plasma-theme.sh"
        ;;
    3)
        echo ""
        echo "Módulos disponíveis:"
        echo "  1) 00-preflight.sh     (Diagnóstico do Sistema e Wayland)"
        echo "  2) 01-packages.sh      (Pacotes Essenciais e Fontes)"
        echo "  3) 02-keyboard-xkb.sh   (Layout US-BR e ~/.XCompose)"
        echo "  4) 03-terminal-kitty.sh (Dotfiles e Terminal Kitty)"
        echo "  5) 04-plasma-theme.sh   (Tema SG-Icons e KRunner Meta+Espaço)"
        echo "  0) Voltar"
        echo ""
        read -rp "Selecione o módulo [1-5, 0]: " SUB_OPT
        case "$SUB_OPT" in
            1) run_module "00-preflight.sh" ;;
            2) run_module "01-packages.sh" ;;
            3) run_module "02-keyboard-xkb.sh" ;;
            4) run_module "03-terminal-kitty.sh" ;;
            5) run_module "04-plasma-theme.sh" ;;
            0) exit 0 ;;
            *) echo -e "${RED}Opção inválida.${NC}"; exit 1 ;;
        esac
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
