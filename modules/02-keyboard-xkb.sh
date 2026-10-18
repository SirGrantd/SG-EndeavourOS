#!/usr/bin/env bash
# ==============================================================================
# Módulo 02: Teclado XKB (us_br), Compose e Contingências Opcionais
# Repositório: SG-EndeavourOS
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "==> [02-Keyboard-XKB] Aplicando arquitetura de teclado us_br e Compose..."

# 1. Instalar layout XKB us_br em espaço de usuário
echo "  -> Instalando layout XKB 'us_br' (Shift: aspas literais; AltGr: trema e cedilha)..."
mkdir -p "$HOME/.config/xkb/symbols"
cp -a "$REPO_ROOT/configs/home/.config/xkb/symbols/us_br" "$HOME/.config/xkb/symbols/us_br"

# Validação prévia de sintaxe se xkbcli estiver disponível
if command -v xkbcli >/dev/null 2>&1; then
    echo "  -> Validando compilação do layout com xkbcli..."
    if xkbcli compile-keymap --include "$HOME/.config/xkb" --include-defaults --test --layout us_br --variant basic >/dev/null 2>&1; then
        echo "  -> Compilação do mapa XKB: OK."
    else
        echo "  [AVISO] Houve aviso na compilação do mapa, mas o arquivo foi instalado."
    fi
fi

# 2. Configurar KDE Plasma para carregar o us_br de forma cirúrgica
if command -v kwriteconfig6 >/dev/null 2>&1; then
    echo "  -> Injetando layout us_br no kxkbrc via kwriteconfig6..."
    kwriteconfig6 --file kxkbrc --group Layout --key LayoutList "us_br"
    kwriteconfig6 --file kxkbrc --group Layout --key VariantList "basic"
    kwriteconfig6 --file kxkbrc --group Layout --key Use "true"
else
    echo "  -> kwriteconfig6 não encontrado. Aplicando arquivo kxkbrc estático..."
    mkdir -p "$HOME/.config"
    cp -a "$REPO_ROOT/configs/home/.config/kxkbrc" "$HOME/.config/kxkbrc"
fi

# 3. Instalar tabela de composição .XCompose estilo Windows
echo "  -> Instalando tabela ~/.XCompose..."
cp -a "$REPO_ROOT/configs/home/.XCompose" "$HOME/.XCompose"

# 4. Tratamento de Contingências / Overrides Opcionais
install_override() {
    local app_desktop="$1"
    local src="$REPO_ROOT/overrides/applications/$app_desktop"
    local dest_dir="$HOME/.local/share/applications"
    if [ -f "$src" ]; then
        mkdir -p "$dest_dir"
        cp -a "$src" "$dest_dir/$app_desktop"
        echo "    [✓] Aplicado override: $app_desktop"
    fi
}

handle_overrides_interactive() {
    echo ""
    read -rp "  ↳ Deseja instalar configurações extras de compatibilidade para apps específicos? [s/N]: " WANT_OVERRIDES
    if [[ "$WANT_OVERRIDES" =~ ^[sS]$ ]]; then
        echo ""
        echo "    Selecione os aplicativos que deseja configurar:"
        echo "      1) Brave Browser (brave-browser.desktop)"
        echo "      2) Discord (discord.desktop)"
        echo "      3) Visual Studio Code (com.microsoft.VSCode.desktop)"
        echo "      4) Todos os anteriores"
        echo "      0) Pular / Nenhum"
        echo ""
        read -rp "    Opção [1-4 ou múltiplos separados por espaço, ex: 1 2]: " OVERRIDE_CHOICES

        for choice in $OVERRIDE_CHOICES; do
            case "$choice" in
                1) install_override "brave-browser.desktop" ;;
                2) install_override "discord.desktop" ;;
                3) install_override "com.microsoft.VSCode.desktop" ;;
                4)
                    install_override "brave-browser.desktop"
                    install_override "discord.desktop"
                    install_override "com.microsoft.VSCode.desktop"
                    break
                    ;;
                0) echo "    Nenhum override selecionado." ; break ;;
                *) echo "    Opção '$choice' ignorada." ;;
            esac
        done
    fi
}

# Processamento de parâmetros passados pela linha de comando
APPLIED_CLI=false
for arg in "$@"; do
    case "$arg" in
        --brave) install_override "brave-browser.desktop"; APPLIED_CLI=true ;;
        --discord) install_override "discord.desktop"; APPLIED_CLI=true ;;
        --vscode) install_override "com.microsoft.VSCode.desktop"; APPLIED_CLI=true ;;
        --all-overrides)
            install_override "brave-browser.desktop"
            install_override "discord.desktop"
            install_override "com.microsoft.VSCode.desktop"
            APPLIED_CLI=true
            ;;
        --no-overrides) APPLIED_CLI=true ;;
    esac
done

if [ "$APPLIED_CLI" = false ] && [ -t 0 ]; then
    handle_overrides_interactive
fi

# 5. Atualizar base de dados do KDE
echo "  -> Atualizando cache de aplicativos (kbuildsycoca6)..."
kbuildsycoca6 2>/dev/null || true

echo "==> [02-Keyboard-XKB] Configuração de teclado e atalhos concluída com sucesso!"
