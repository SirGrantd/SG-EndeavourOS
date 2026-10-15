#!/usr/bin/env bash
# ==============================================================================
# Módulo 06: Stack de Desenvolvimento e Contêineres
# Repositório: SG-EndevourOS
# ==============================================================================

set -euo pipefail

echo "==> [06-Dev-Stack] Configurando serviços da pilha de desenvolvimento..."

# 1. Ativar Docker Socket (ativação sob demanda sem consumir recursos contínuos)
if command -v docker >/dev/null 2>&1; then
    echo "  -> Habilitando docker.socket (ativação sob demanda)..."
    if systemctl is-enabled docker.socket >/dev/null 2>&1; then
        echo "  -> docker.socket já está habilitado."
    else
        sudo systemctl enable --now docker.socket
        echo "  -> docker.socket ativado com sucesso."
    fi
    
    # Garantir que o usuário pertença ao grupo docker (se o grupo existir)
    if getent group docker >/dev/null 2>&1; then
        if ! id -nG "$USER" | grep -qw "docker"; then
            echo "  -> Adicionando usuário '$USER' ao grupo docker..."
            sudo usermod -aG docker "$USER"
            echo "  [INFO] É necessário reiniciar a sessão para que as permissões de grupo façam efeito."
        fi
    fi
else
    echo "  [INFO] Docker não está instalado. Pulando configuração do daemon."
fi

echo "==> [06-Dev-Stack] Configurações de desenvolvimento concluídas!"
