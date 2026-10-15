#!/usr/bin/env bash
# ==============================================================================
# Módulo 05: Armazenamento e Manutenção de SSDs
# Repositório: SG-EndevourOS
# ==============================================================================

set -euo pipefail

echo "==> [05-Storage] Verificando configurações de armazenamento e manutenção..."

# 1. Ponto de montagem para o disco secundário (/mnt/armazenamento)
if [ ! -d "/mnt/armazenamento" ]; then
    echo "  -> Criando diretório /mnt/armazenamento..."
    sudo mkdir -p /mnt/armazenamento
    sudo chown "$USER:$USER" /mnt/armazenamento
else
    echo "  -> Diretório /mnt/armazenamento já existe."
fi

# 2. Ativar timer de descarte (TRIM) para manutenção dos SSDs
echo "  -> Ativando serviço de fstrim.timer..."
if systemctl is-enabled fstrim.timer >/dev/null 2>&1; then
    echo "  -> fstrim.timer já está habilitado."
else
    sudo systemctl enable --now fstrim.timer
    echo "  -> fstrim.timer habilitado e iniciado com sucesso."
fi

echo "==> [05-Storage] Configuração de armazenamento concluída!"
