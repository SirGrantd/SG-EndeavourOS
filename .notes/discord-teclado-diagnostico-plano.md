# Relatório de Diagnóstico e Plano de Correção: Discord

Este documento consolida a análise técnica sobre a falha de composição do teclado (teclas mortas, cedilha e aspas) especificamente no aplicativo Discord, bem como o plano prático de resolução.

---

## 1. Dados do Sistema Operacional

- **Distribuição:** EndeavourOS (base Arch Linux) `rolling`
- **Ambiente Desktop:** KDE Plasma
- **Sessão Gráfica:** Wayland nativo (`XDG_SESSION_TYPE=wayland`)
- **Layout de Teclado Atual:** English (US, international with dead keys)
- **Status do Compose (`~/.XCompose`):** O arquivo de composição de teclas foi validado, instalado e funciona perfeitamente para navegadores (Brave nativo) e jogos.

---

## 2. Diagnóstico do Aplicativo Discord

Ao inspecionar a árvore de processos (`ps aux`), constatou-se que o Discord está rodando nativamente sobre Wayland com flags explícitas do Chromium Embedded Framework:

- **Pacote Instalado:** `discord 1:1.0.159-1` (gerenciado via `pacman`, executando a versão de binários estáticos 1.0.161 em `~/.config/discord`).
- **Engine subjacente:** Electron 42.11.10.
- **Modo de execução ativo:** `--ozone-platform=wayland` (Wayland Nativo).

### Causa Raiz do Problema

O Electron, em determinadas versões e configurações (especialmente ao rodar nativamente em Wayland sem a camada de abstração X11), possui **bugs e limitações na leitura e processamento do arquivo `~/.XCompose` e do Input Method (IM) do sistema**.

No Wayland, o Discord está recebendo os eventos "crus" (raw events) da tecla morta (ex.: o acento agudo isolado) e ignorando as regras de composição definidas no espaço de usuário do XKB (`libxkbcommon`). Por isso, ele "engole" as aspas e o apóstrofo ou falha ao gerar a cedilha e acentuação customizada.

---

## 3. Plano de Correção (Fallback para XWayland)

Como o problema é uma limitação da engine do Electron no modo Wayland Puro, a solução padrão, consolidada e mais eficaz para restaurar o comportamento do teclado é rodar o Discord utilizando o **XWayland** (a camada de compatibilidade do X11 no Wayland).

O XWayland integra-se perfeitamente às chamadas Xlib clássicas e consome a tabela `~/.XCompose` de forma transparente.

### Etapas do Plano

1. **Validação Temporária:**
   - Encerrar todas as instâncias do Discord (`killall Discord`).
   - Lançar o aplicativo pelo terminal com o modo X11 forçado:
     ```bash
     /usr/bin/discord --ozone-platform=x11
     ```
   - Testar as combinações de teclas (`' + c`, `" + letra`, etc.) dentro do aplicativo.

2. **Aplicação Permanente (Modo Preferencial no Arch Linux):**
   - O pacote `discord` do Arch Linux lê automaticamente argumentos adicionais no arquivo `~/.config/discord-flags.conf`.
   - Se o teste funcionar, criar o arquivo de configuração para forçar essa flag em toda inicialização do aplicativo sem necessidade de alterar atalhos globais do sistema:
     ```bash
     echo "--ozone-platform=x11" > ~/.config/discord-flags.conf
     ```

3. **Aplicação Permanente (Modo Alternativo via Desktop Entry):**
   - Caso o arquivo de flags falhe, o atalho do sistema será copiado e modificado:
     ```bash
     cp /usr/share/applications/discord.desktop ~/.local/share/applications/
     sed -i 's|Exec=/usr/bin/discord|Exec=/usr/bin/discord --ozone-platform=x11|g' ~/.local/share/applications/discord.desktop
     ```

---
