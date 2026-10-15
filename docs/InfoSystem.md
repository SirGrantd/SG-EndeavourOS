# Registo de Instalação e Configuração: EndeavourOS (Versão 2.0)

Este documento reflete o estado consolidado, atualizado e auditado do sistema operacional EndeavourOS após a instalação limpa inicial e as consecutivas fases de otimização, correções de persistência e ajustes de usabilidade.

---

## 0. Resumo de Evolução e Registro de Mudanças (v1.0 → v2.0)

| Área / Componente | Versão 1.0 (Instalação Limpa) | Versão 2.0 (Estado Consolidado Atual) |
|---|---|---|
| **Disco Secundário (SATA)** | `/dev/sda2` (~447 GiB, NTFS) | `/dev/sda1` (~447 GiB, `ext4`, LABEL: `Armazenamento`) montado em `/mnt/armazenamento` via `/etc/fstab` com `noatime`. |
| **Sistema Temporário** | Padrão | `/tmp` configurado explicitamente em `tmpfs` via `/etc/fstab` (`defaults,noatime,mode=1777`). |
| **Arquitetura de Teclado** | Teclado US Int'l padrão + hooks no `/etc/pacman.d/hooks/fix-cedilla.hook` + `fix-cedilla.sh`. | Layout customizado em espaço de usuário (`~/.config/xkb/symbols/us_custom` sob `us_custom(basic)`), sem hooks no root. |
| **Aspas e Tremas** | Aspas duplas agindo como tecla morta nativa. | Aspas duplas geradas imediatamente no `Shift` (`quotedbl`); trema (`dead_diaeresis`) movido exclusivamente para `AltGr`. |
| **Aplicações Wayland / Electron** | Variável `XCOMPOSEFILE` global em `environment.d/` + flags globais. | Lançadores individuais em `~/.local/share/applications/` (Brave, Discord, VS Code) forçando `--ozone-platform=x11`, imunes a updates do sistema. |
| **Comportamento Compose** | Suporte básico a cedilha e repetição de teclas mortas. | `~/.XCompose` completo estilo Windows (teclas mortas seguidas de consoantes não acentuáveis emitem caractere literal + letra). |
| **Terminal e Shell** | Konsole padrão com Bash. | Adoção do **Kitty** (aceleração por GPU, abas e dotfile único) com **Zsh** (`/usr/bin/zsh`), Oh My Zsh e plugin `zsh-edit-select` (seleção estilo Windows via Shift+Setas). |
| **Stack de Desenvolvimento** | Versões genéricas pós-instalação. | Versões exatas mapeadas: Node.js 26.11, pnpm 11.28, Python 3.14.8, uv 0.13.0, Go 1.27.2, Rust 1.98.1, OpenJDK 21 LTS, Docker 29.9. |
| **Novos Pacotes & Ferramentas** | Base inicial de produtividade. | Inclusão de `kitty`, `wl-clipboard`, `anydesk-bin`, `tldr`, `agy` (Antigravity CLI) e `quillvore`. Desinstalação de pacotes obsoletos (`powershell-bin`, `win11-icon-theme-git`). |
| **Serviços de Manutenção & Backup** | Padrão inicial. | Ativação do `fstrim.timer` para SSDs, `docker.socket` sob demanda e rotina de backup em `~/backup_configs_.../restaurar_tudo.sh`. |

---

## 1. Mídia e Controladores
* **Imagem ISO:** EndeavourOS *Titan Nova*
* **Opção de arranque:** `EndeavourOS with open source drivers: All GPUs`
* **Drivers Gráficos:** Stack de código aberto nativa (`amdgpu` + Mesa 26.x) para placa gráfica AMD com aceleração Vulkan (RADV) e Wayland nativo.

---

## 2. Localização e Idioma
* **Fuso Horário:** `America/Sao_Paulo` (sincronização de relógio de rede ativa via `systemd-timesyncd.service`).
* **Idioma do Sistema:** Português (Brasil) — `pt_BR.UTF-8`.
* **Formatos Numéricos e Datas:** Português (Brasil).

---

## 3. Disposição do Teclado (Layout & Mapeamento XKB)

### Hardware Físico:
* **Modelo físico:** ANSI (teclado mecânico compacto, sem tecla `ç` dedicada, tecla Enter horizontal em barra).
* **Modelo de hardware:** `Generic 105-key PC`.
* **Console TTY:** `us-acentos`.

### Nova Arquitetura XKB em Espaço de Usuário (`~/.config/xkb/symbols/us_custom`):
A gestão de layout foi desacoplada de arquivos de sistema (`/usr/share/X11/xkb/`) e transferida para a configuração do usuário, ativada nativamente no KDE Plasma via `~/.config/kxkbrc`:
* **Layout ativo:** `us_custom`
* **Variante ativa:** `basic`
* **Definição de Modificadores e Tecla de Aspas (`<AC11>`):**
  * **Nível 1 (Sem modificador):** Emite `dead_acute` (agudo / apóstrofo).
  * **Nível 2 (`Shift`):** Emite `quotedbl` (aspas duplas literais instantâneas). Digitar `Shift + '` seguido de `e` produz `"e`, eliminando a inserção involuntária de `ë`.
  * **Níveis 3 e 4 (`AltGr` / Alt Direito):** Emite `dead_diaeresis` através de `level3(ralt_switch)`. O trema só é ativado quando o usuário pressiona conscientemente `AltGr + '`.

### Tabela de Composição Avançada (`~/.XCompose`):
Comportamento idêntico ao Windows com suporte abrangente:
* **Geração de Cedilha:**
  * `'` + `c` → `ç` (`ccedilla`)
  * `'` + `C` → `Ç` (`Ccedilla`)
* **Repetição Rápida de Teclas Mortas (Par Literal Imediato):**
  * `<dead_acute>` duas vezes → `''`
  * `<dead_diaeresis>` duas vezes → `""`
  * `<dead_grave>` duas vezes → ````
  * `<dead_tilde>` duas vezes → `~~`
  * `<dead_circumflex>` duas vezes → `^^`
* **Resolução Inteligente de Letras Não Acentuáveis:**
  * Pressionar `'`, `"`, `` ` ``, `~` ou `^` seguido de qualquer consoante ou dígito que não forme caractere acentuado emite imediatamente o símbolo literal acompanhado da letra (ex.: `'` + `s` resulta diretamente em `'s`).
* **Regras Explícitas de Trema (via `AltGr`):**
  * `<dead_diaeresis>` + vogal gera trema (`ä`, `ë`, `ï`, `ö`, `ü`, `ÿ`, `Ä`, `Ë`, `Ï`, `Ö`, `Ü`, `Ÿ`).

### Isolamento Persistente para Aplicações Electron / Chromium:
Para prevenir o bug upstream do motor de composição do Chromium sob Wayland nativo e evitar que atualizações de pacotes quebrem atalhos:
* Os arquivos `.desktop` foram instanciados em `~/.local/share/applications/`:
  * `brave-browser.desktop` → `Exec=brave --ozone-platform=x11 %U`
  * `discord.desktop` → `Exec=/usr/bin/discord --ozone-platform=x11 --url -- %u`
  * `com.microsoft.VSCode.desktop` → `Exec=code --ozone-platform=x11 %F`
* Eliminação total de dependência de hooks de pacman ou scripts em `/etc/pacman.d/hooks/`.

---

## 4. Ambiente Gráfico e Sessão
* **Ambiente de Trabalho:** KDE Plasma `6.7.5`
* **Frameworks do KDE:** `6.30.0`
* **Plataforma Gráfica:** `Wayland` nativo (com suporte a fallback X11 via `plasma-x11-session`)
* **Qt Runtime:** `6.12.0`
* **Gestor de Ecrã de Login (Display Manager):** `plasmalogin.service` (`plasma-login-manager` ativo nativamente).

---

## 5. Gestor de Arranque (Bootloader) e Kernels
* **Bootloader:** `systemd-boot` (versão 261.x, montado em `/efi`).
* **Kernel em Execução Padrão:** `linux-lts` (`6.18.55-1-lts`) com `linux-lts-headers`.
* **Kernel Alternativo Instalado:** `linux` (`7.2.9.arch1-1`) com `linux-headers`.
* **Alternância:** Suporte direto no menu UEFI do `systemd-boot`.

---

## 6. Armazenamento e Particionamento

### Disco Principal — SSD NVMe (~500 GB — Crucial P3):
* **Dispositivo:** `/dev/nvme0n1` (Tabela GPT)
* **Partição EFI:** `/dev/nvme0n1p1` (2,00 GiB, FAT32) montada em `/efi`.
* **Partição do Sistema:** `/dev/nvme0n1p2` (~463,76 GiB, Btrfs, UUID `818821d2-f9bc-419d-8ea6-29a2a77e39db`).
* **Opções de Montagem:** `rw,noatime,compress=zstd:3,ssd,discard=async,space_cache=v2`.
* **Subvolumes Btrfs:**
  * `/@` montado em `/`
  * `/@home` montado em `/home`
  * `/@swap` montado em `/swap` (arquivo de troca `/swap/swapfile` de 512 MiB ativo)
  * `/@cache` montado em `/var/cache`
  * `/@log` montado em `/var/log`

### Disco Secundário — SSD SATA (~480 GB — Western Digital Green):
* **Dispositivo:** `/dev/sda` (Tabela GPT)
* **Partição de Armazenamento:** `/dev/sda1` (~447 GiB, formatado em `ext4`, UUID `4a3c8e25-c731-42a9-9aab-cd6681f4b208`, LABEL `Armazenamento`).
* **Ponto de Montagem:** `/mnt/armazenamento` configurado no `/etc/fstab` com `defaults,noatime 0 2`.

### Sistema de Arquivos Temporário:
* `/tmp` montado em memória RAM via `tmpfs` (`defaults,noatime,mode=1777 0 0`).
* Serviço de descarte periódico `fstrim.timer` habilitado para manutenção dos SSDs.

---

## 7. Especificações de Hardware e Controle de GPU
* **Processador (CPU):** AMD Ryzen 5 5600G with Radeon Graphics (6 núcleos / 12 threads, frequência máxima ~4,46 GHz).
* **Memória RAM:** 16 GiB DDR4 (15,4 GiB utilizáveis).
* **Placa Gráfica Dedicada (GPU):** AMD Radeon RX 6600 (Navi 23, 8 GB VRAM, montagem ASRock).
  * Módulo do Kernel: `amdgpu`.
  * Suporte Vulkan: RADV (`vulkan-radeon` e `lib32-vulkan-radeon`).
* **Gerenciador de GPU & Overclock:** `lact` (Linux AMDGPU Controller) com daemon `lactd.service` ativo no boot para controle de curvas de rotação de ventoinhas, clocks e voltagens.
* **RGB:** `openrgb` (v1.0-2) instalado para gestão unificada dos periféricos e iluminação.

---

## 8. Personalização de Interface e Terminal

### Emulador de Terminal & Shell Moderno (Kitty + Zsh):
* **Terminal Principal:** Kitty (`kitty` 0.49.2)
  * Renderizador acelerado por GPU (OpenGL) de baixa latência.
  * Configuração desacoplada e centralizada em arquivo único (`~/.config/kitty/kitty.conf` e `current-theme.conf`).
  * **Comportamento e Atalhos Estilo Windows:**
    * `Ctrl + C`: Cópia rápida via sequência de escape.
    * `Ctrl + Shift + C`: Interrupção de processos (SIGINT padrão Unix).
    * `Ctrl + Shift + Z`: Refazer (Redo).
    * Liberação de manipulação interna de `Shift + Setas` e `Ctrl + Shift + Setas` para permitir a seleção de texto nativa pelo Zsh.
  * **Gerenciamento de Abas e Divisão:** Barra de abas superior em estilo powerline (`tab_bar_edge top`, `tab_bar_style powerline`), criação de novas abas (`Ctrl+Shift+T`) e divisão de painéis verticais/horizontais (`Ctrl+Shift+Enter` / `Ctrl+Shift+N`).
* **Shell Padrão do Sistema:** Zsh 5.9.2 (`/usr/bin/zsh`)
  * Framework: Oh My Zsh (`~/.oh-my-zsh`).
  * Plugin de Seleção de Texto: `zsh-edit-select` (seleção visual de caracteres e palavras via `Shift + Setas` e `Ctrl + Shift + Setas`).
  * Integração com Clipboard Wayland: Suportado pelo utilitário nativo `wl-clipboard` (`wl-copy` e `wl-paste`).
* **Terminal Secundário / Fallback:** Konsole mantido no perfil padrão de fábrica da distribuição (Bash nativo).

### Estilo e Temas do Desktop:
* **Tema Visual Global:** Breeze Dark nativo (`org.kde.breezedark.desktop`).
* **Tema de Ícones:** `breeze-dark` (nativo do KDE Plasma; pacote não utilizado `win11-icon-theme-git` foi removido).
* **Cursor do Sistema:** `Bibata-Modern-Classic` (tamanho 20, preservado em `~/.local/share/icons/`).
* **Barra de Tarefas:** Painel centralizado estilo Windows 11 (Kickoff e `icontasks` centralizados através de espaçadores inteligentes; bandeja do sistema com Ethernet, Volume e Bluetooth visíveis).
* **Tipografia:** JetBrains Mono e JetBrains Mono Nerd Font, acompanhadas da fonte `ttf-roboto` instalada recentemente.

---

## 9. Ambiente de Desenvolvimento (Dev Stack)

| Tecnologia / Ferramenta | Versão Instalada | Pacote / Origem |
|---|---|---|
| **Shell Principal** | Zsh 5.9.2 + Oh My Zsh | Nativo (`zsh`) |
| **Terminal Emulator** | Kitty 0.49.2 | Nativo (`kitty`) |
| **Clipboard Wayland** | wl-clipboard 2.3.0 | Nativo (`wl-clipboard`) |
| **Node.js** | `v26.11.1` | Nativo (`nodejs`) |
| **pnpm** | `11.28.5` / `12.12.0` | Nativo (`pnpm`) |
| **Python** | `3.14.8` | Nativo (`python`) |
| **uv** | `0.13.0` | Nativo (`uv`) |
| **Go** | `go1.27.2` | Nativo (`go`) |
| **Rust** | `rustc 1.98.1` | Toolchain (`rustup` / `rust`) |
| **Java** | `OpenJDK 21.0.12.1 LTS` | Nativo (`jdk21-openjdk`, `jdk25-openjdk`) |
| **Shell Secundário** | GNU Bash (`/bin/bash`) | Nativo (`bash`) |
| **Docker Engine** | `29.9.0` | Nativo (`docker`, ativado via `docker.socket`) |
| **Docker Compose** | `5.6.0` | Nativo (`docker-compose`) |
| **Git** | `2.56.0` | Nativo (`git`) |
| **Editor Principal** | `VS Code 1.141.0` | AUR (`visual-studio-code-bin`) |
| **Banco de Dados** | `Beekeeper Studio 6.1.6` | AUR (`beekeeper-studio-bin`) |
| **Testes de API** | `Postman 12.31.7` | AUR (`postman-bin`) |
| **CLI de IA (Antigravity)** | `agy` | Binário local (`~/.local/bin/agy`) |

---

## 10. Ecossistema de Aplicações e Serviços

### Internet, Comunicação e Acesso Remoto:
* **Navegador Padrão:** Brave Browser (`brave-bin` 1:1.97.56-1).
* **Comunicação:** Discord (`discord` 1:1.0.161-1).
* **Acesso Remoto:** AnyDesk (`anydesk-bin` 8.1.0-1).

### Jogos e Modpacks:
* **Steam:** Cliente oficial com bibliotecas 32-bit (`lib32-vulkan-radeon`, `lib32-mesa`).
* **Minecraft & Mods:** `minecraft-launcher` e `curseforge`.

### Multimídia e Criação:
* **Gravação e Transmissão:** OBS Studio (`obs-studio` 32.2.2-1).
* **Reprodutor de Vídeo:** Haruna Video Player (`haruna` 1.8.1-2).
* **Pixel Art:** LibreSprite (`libresprite` 1.3-1).

### Diagnóstico, Manutenção e Utilitários:
* **Monitores do Sistema:** `mission-center` (1.2.0-1), `glances` (4.5.7-1) e `duf` (0.9.1-1).
* **Terminal e Clipboard:** `kitty` (0.49.2), `wl-clipboard` (1:2.3.0), `wayland-protocols` (1.49).
* **Gerenciamento e Recompilação:** `yay` (helper AUR), `downgrade`, `rebuild-detector`.
* **Utilitários de Linha de Comando:** `tldr` (manual resumido), `kcalc`, `kate`, `ark`.

### Daemons e Serviços Ativos no Sistema:
* **Hardware & Energia:** `lactd.service`, `lm_sensors.service`, `power-profiles-daemon.service`, `fstrim.timer`.
* **Rede & Segurança:** `NetworkManager.service`, `firewalld.service`, `systemd-timesyncd.service`, `avahi-daemon.service`, `bluetooth.service`.
* **Áudio:** `pipewire.socket`, `pipewire-pulse.socket`, `wireplumber.service`.

---

## 11. Garantia de Recuperação e Backup de Configurações
* **Diretório do Backup Consolidado:** `/home/grantd/backup_configs_20261014_232108/`
* **Script de Restauração Automatizada:** `/home/grantd/backup_configs_20261014_232108/restaurar_tudo.sh`
* **Finalidade:** Permite reverter instantaneamente qualquer redefinição de interface, recuperando atalhos, painéis e preferências em caso de necessidade.
