# Blueprint do Projeto: Desktop Híbrido (Linux + Windows + macOS)

Este documento sintetiza a proposta de arquitetura de interface e o plano de desenvolvimento do **instalador modular** para o seu ambiente personalizado, unindo estabilidade para jogos e desenvolvimento com uma experiência de uso refinada.

---

## 1. Manifesto de Design: O Triângulo Híbrido

O objetivo é extrair o ponto mais forte de cada ecossistema sem herdar suas restrições:

| Pilar | Origem de Inspiração | Implementação Prática no Ambiente |
| --- | --- | --- |
| **Motor (Kernel & Base)** | **Linux** (EndeavourOS / Arch) | Gestão de pacotes via `pacman`/`yay`, sistema de arquivos Btrfs com snapshots automáticos e drivers gráficos AMD abertos (`RADV`/`Mesa`). |
| **Ergonomia (Mouse & Fluxo)** | **Windows** | Barra centralizada com ícones, navegação focada no mouse, alternador de janelas (`Alt + Tab`), clipboard nativo (`Meta + V`) e gerenciador de processos (`Ctrl + Shift + Esc`). |
| **Acabamento (UX & Visual)** | **macOS** | Painéis em cápsula flutuante (*pill design*), desfoque suave (*blur*), busca universal flutuante (KRunner em `Meta + Espaço`) e tipografia padronizada (JetBrains Mono). |

---

## 2. Decisão de Engenharia: KDE Plasma 6 vs. Hyprland

Apesar de o Hyprland dominar os vídeos de customização visual, ele é dispensado em favor do **KDE Plasma 6 (Wayland)** pelos seguintes motivos:

* **Foco em Mouse vs. Teclado:** Tiling WMs exigem memorização massiva de atalhos; o Plasma 6 permite arrastar, redimensionar e gerenciar janelas visualmente.
* **Jogos e Wayland:** O Plasma 6 suporta nativamente VRR (FreeSync), HDR, troca de taxa de atualização e controle de integridade gráfica sem scripts manuais.
* **Manutenção Mínima:** Em vez de manter 6 daemons isolados (Waybar, SwayNC, Hyprlock, Wlogout, etc.), o Plasma centraliza tudo em uma única base estável com aceleração Qt6.

---

## 3. Por que um Instalador é Superior a uma ISO Própria

Criar uma imagem `.iso` personalizada (com ferramentas como `archiso` ou Calamares modificado) gera um alto custo de manutenção: a imagem fica desatualizada rapidamente, exige hospedagem de arquivos grandes e obriga a formatação do disco.

O modelo ideal para o projeto é um **Instalador Modular Pós-Instalação** (*Bootstrap Script*):

* **Idempotente:** Pode ser executado em uma instalação limpa ou em um sistema já em uso sem corromper arquivos existentes.
* **Leve e Versionável:** O projeto inteiro cabe em um repositório Git de poucos megabytes.
* **Não Opinativo (Opt-in):** Permite ao usuário ligar ou desligar módulos (ex: instalar apenas a UI sem o stack de Dev/Docker).
* **Base Limpa:** O usuário instala o EndeavourOS ou Arch oficial e executa uma única linha de comando para aplicar o ambiente.

---

## 4. Arquitetura do Repositório do Instalador

```text
SG-EndevourOS/
├── install.sh                # Script orquestrador interativo nativo (Bash/POSIX)
├── modules/                  # Módulos especializados de instalação e configuração
│   ├── 00-preflight.sh       # Verificação de sistema (Arch/EndeavourOS), GPU e rede
│   ├── 01-packages.sh        # Instalação automatizada via pacman e yay (Kitty, Dev, etc.)
│   ├── 02-keyboard-xkb.sh    # Deploy do layout XKB (us_custom), .XCompose e atalhos Electron
│   ├── 03-terminal-kitty.sh  # Deploy do Kitty (kitty.conf, temas, wallpaper e atalhos Windows)
│   ├── 04-plasma-theme.sh    # Injeção cirúrgica no KDE (painel centralizado Win11, KRunner, atalhos)
│   ├── 05-storage.sh         # Ponto de montagem /mnt/armazenamento e fstrim.timer
│   └── 06-dev-stack.sh       # Ativação do Docker, Node, Python/uv, Go e ferramentas
├── configs/                  # Dotfiles versionados
│   └── home/
│       ├── .config/
│       │   ├── kitty/
│       │   │   ├── kitty.conf                  # Atalhos Windows, abas powerline e render OpenGL
│       │   │   ├── current-theme.conf          # Paleta escura e opacidade
│       │   │   └── backgrounds/
│       │   │       └── WallpaperMinecraft.png  # Imagem sutil de fundo do terminal
│       │   ├── xkb/
│       │   │   └── symbols/
│       │   │       └── us_custom               # Layout XKB (Shift: aspas duplas; AltGr: trema)
│       │   ├── kxkbrc                          # Ativação do layout us_custom no KDE Plasma
│       │   └── konsolerc                       # Perfil mantido como terminal secundário/fallback
│       ├── .local/share/
│       │   ├── applications/                   # Overrides locais imunes a updates do sistema
│       │   │   ├── brave-browser.desktop       # Força backend --ozone-platform=x11
│       │   │   ├── discord.desktop             # Força backend --ozone-platform=x11
│       │   │   └── com.microsoft.VSCode.desktop # Força backend --ozone-platform=x11
│       │   └── konsole/                        # Perfis legados preservados para contingência
│       └── .XCompose                           # Tabela completa estilo Windows (cedilha e teclas mortas)
├── assets/                   # Papéis de parede e mídias visuais do ambiente
├── overrides/                # Espaço reservado para o usuário colocar seus próprios ajustes
├── docs/                     # Registros de arquitetura e sistema operacional
│   ├── InfoSystem.md         # Registro consolidado (v2.0) do sistema
│   ├── InfoSystem_v2.md      # Registro detalhado v2.0 com tabela comparativa
│   └── Planejamento.md       # Blueprint de arquitetura e design
└── .notes/                   # Notas operacionais, diagnósticos de teclado e Wayland
```

---

## 5. Fluxo de Execução do Instalador

```
[ Início: ./install.sh ]
   │
   ▼
[ 1. Detecção de Ambiente ] ──▶ Verifica se é Arch/EndeavourOS + KDE Plasma 6
   │
   ▼
[ 2. Menu de Seleção ] ───────▶ Escolha de perfis modulares:
   │                            [x] Pacotes Base & Ferramentas (Kitty, fonts, yay)
   │                            [x] Teclado & Compose (us_custom, .XCompose, overrides Electron)
   │                            [x] Terminal Kitty (OpenGL, abas powerline, atalhos Win)
   │                            [x] Visual Core Plasma 6 (Painel central Win11, KRunner, atalhos)
   │                            [x] Armazenamento (ext4 /mnt/armazenamento, fstrim)
   │                            [x] Dev Stack (Docker, Node, Python/uv, Go, Rust)
   │
   ▼
[ 3. Instalação de Pacotes ] ──▶ pacman / yay sem intervenções manuais repetitivas
   │
   ▼
[ 4. Deploy de Dotfiles & XKB ] ─▶ Cópia cirúrgica para ~/.config, ~/.local e ~/.XCompose
   │
   ▼
[ 5. Injeção de UI KDE ] ─────▶ Aplica atalhos e painel usando 'kwriteconfig6'
   │
   ▼
[ 6. Conclusão ] ─────────────▶ Recarrega o Plasma e exibe resumo de configuração
```

---

## 6. O Segredo Técnico: Injeção Cirúrgica (`kwriteconfig6`)

Para garantir que o instalador **não quebre personalizações prévias do usuário**, as configurações da área de trabalho não devem substituir arquivos inteiros (`~/.config/kwinrc`). O script usará o utilitário nativo do KDE:

```bash
# Define KRunner centralizado e flutuante (estilo Spotlight do macOS)
kwriteconfig6 --file krunnerrc --group General --key FreeFloating true

# Mapeia atalho do KRunner para Meta + Espaço
kwriteconfig6 --file kglobalshortcutsrc --group org.kde.krunner.desktop --key _launch "Meta+Space,Meta+Space,KRunner"

# Mapeia o Mission Center como o Gerenciador de Tarefas padrão (estilo Windows)
kwriteconfig6 --file kglobalshortcutsrc --group "io.missioncenter.MissionCenter.desktop" --key _launch "Ctrl+Shift+Escape,none,Mission Center"

```
