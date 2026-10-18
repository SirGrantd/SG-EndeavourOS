#!/usr/bin/env bash
# ==============================================================================
# Módulo 00: Preflight (Diagnóstico e Validação do Ambiente)
# Repositório: SG-EndeavourOS
# ==============================================================================

set -euo pipefail

echo "==> [00-Preflight] Verificando compatibilidade do sistema..."

# 1. Verificar distribuição (Arch Linux / EndeavourOS)
if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "  -> Distribuição detectada: $PRETTY_NAME ($ID)"
    if [[ "$ID" != "endeavouros" && "$ID" != "arch" && "$ID_LIKE" != *"arch"* ]]; then
        echo "  [AVISO] Este instalador foi projetado para EndeavourOS / Arch Linux."
        read -rp "  Deseja continuar mesmo assim? [s/N]: " CONFIRM
        if [[ ! "$CONFIRM" =~ ^[sS]$ ]]; then
            echo "  Operação abortada pelo usuário."
            exit 1
        fi
    fi
else
    echo "  [ERRO] Não foi possível identificar /etc/os-release."
    exit 1
fi

# 2. Verificar Sessão e Desktop (KDE Plasma Wayland)
echo "  -> Sessão gráfica: ${XDG_SESSION_TYPE:-desconhecida}"
echo "  -> Desktop: ${XDG_CURRENT_DESKTOP:-desconhecido}"

if [[ "${XDG_CURRENT_DESKTOP:-}" != *"KDE"* ]]; then
    echo "  [AVISO] Ambiente KDE Plasma não detectado ativamente."
fi

# 3. Verificar Conexão com a Internet
echo "  -> Testando conectividade com a internet..."
if ping -c 1 -W 3 archlinux.org >/dev/null 2>&1; then
    echo "  -> Conexão OK."
else
    echo "  [ERRO] Sem conexão com a internet. Verifique sua rede antes de prosseguir."
    exit 1
fi

# 4. Verificar GPU AMD
echo "  -> Verificando adaptador gráfico..."
if lspci -k 2>/dev/null | grep -i "VGA.*AMD" >/dev/null 2>&1; then
    echo "  -> GPU AMD detectada com sucesso."
else
    echo "  [INFO] Placa gráfica AMD dedicada não identificada diretamente via lspci."
fi

echo "==> [00-Preflight] Verificações preliminares concluídas com sucesso!"
