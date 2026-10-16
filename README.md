# SG-Endeavour (v2.0)

> **Suíte Universal e Modular de Pré-Personalização de Desktop no KDE Plasma 6 (Wayland)**  
> *Base EndeavourOS / Arch Linux*

---

## 🌟 O Conceito: O Triângulo Híbrido

O **SG-Endeavour** foi desenvolvido para unificar os pontos mais fortes dos três principais ecossistemas em uma instalação de desktop limpa, fluida e de alto desempenho:

* 🐧 **Motor & Base (Linux):** Desempenho nativo com Wayland, drivers abertos AMDGPU/Mesa com aceleração Vulkan (RADV) de baixa latência e flexibilidade Arch Linux.
* 🪟 **Ergonomia & Navegação (Windows):** Barra de tarefas centralizada, navegação intuitiva focada no mouse, alternador de janelas (`Alt + Tab`), clipboard nativo (`Meta + V`) e gerenciador de processos nativo (`Ctrl + Esc`).
* 🍏 **Acabamento Visual (macOS):** Busca universal flutuante centralizada (KRunner em `Meta + Espaço`), janelas em cápsula com desfoque suave (*blur*) e tipografia moderna (JetBrains Mono).

O projeto é **100% genérico, não opinativo e agnóstico a hardware**. Ele não impõe partições de disco fixas nem serviços de desenvolvimento em segundo plano: se você deseja apenas **jogar na Steam/Proton** ou ter um sistema refinado para o dia a dia, ele entrega um ambiente pronto sem poluição.

---

## ⚡ Principais Recursos

### 1. Arquitetura de Teclado `us_br` & Compose Estilo Windows
Projetado especificamente para teclados no padrão **ANSI (US International)**, eliminando frustrações históricas de digitação sob Wayland:
* **Aspas Duplas Imediatas:** `Shift + '` produz `"` instantaneamente (sem agir como tecla morta e sem gerar `ë` acidental ao digitar letras como `"e`).
* **Trema Consciente:** O trema (`dead_diaeresis`) foi realocado exclusivamente para `AltGr + '`.
* **Cedilha Direta de Hardware (XKB):** Pressionar `AltGr + c` gera diretamente `ç` (e `AltGr + Shift + c` gera `Ç`) no nível do compositor KWin, garantindo funcionamento em 100% dos apps (Chromium Wayland nativo, jogos, emuladores e Flatpaks).
* **Tabela `~/.XCompose` Completa:** Comportamento idêntico ao Windows com suporte a:
  * `'` + `c` $\rightarrow$ `ç`
  * Repetição rápida de teclas mortas (dois toques em `'` geram `''`, dois toques em `~` geram `~~`).
  * Emissão literal automática para consoantes não acentuáveis (ex.: `'` + `s` resulta diretamente em `'s`).

### 2. Terminal Moderno (Kitty) & Tipografia
* **Aceleração por GPU:** Renderização ultrarrápida via OpenGL de baixa latência.
* **Atalhos Familiares:** `Ctrl + C` para cópia de texto e `Ctrl + Shift + C` para envio de sinal de interrupção (SIGINT).
* **Organização em Abas:** Barra de abas superior no estilo *powerline* e imagem sutil de fundo.
* **Tipografia:** Pacote de fontes padronizado com `ttf-jetbrains-mono`, `ttf-jetbrains-mono-nerd` e `ttf-roboto`.

### 3. Experiência de Interface (KDE Plasma 6)
* **KRunner Estilo Spotlight:** Busca flutuante centralizada na tela ativada com o atalho universal `Meta + Espaço`.
* **Injeção Não Destrutiva:** Todas as preferências do KDE são aplicadas via `kwriteconfig6`, sem sobrescrever arquivos inteiros e sem apagar configurações prévias do usuário.
* **Respeito aos Atalhos Nativos:** O atalho de monitoramento de processos do Plasma (`Ctrl + Esc`) permanece original e intocado.

### 4. Gestão de Contingências (`overrides/`)
Para aplicativos Electron/Chromium legados que ainda apresentem inconsistências de composição sob Wayland nativo puro, o repositório disponibiliza contornos opcionais em `overrides/applications/` (`brave-browser.desktop`, `discord.desktop`, `com.microsoft.VSCode.desktop`), que podem ser instalados de forma seletiva diretamente pelo assistente interativo.

---

## 🚀 Instalação Rápida

### Pré-requisitos
* **Sistema:** EndeavourOS ou Arch Linux.
* **Interface Gráfica:** KDE Plasma 6 em sessão Wayland.
* **Gerenciador de Pacotes:** `pacman` (suporte a `yay` detectado automaticamente).

### Como Executar

Clone o repositório e inicie o assistente:

```bash
git clone https://github.com/SeuUsuario/SG-EndevourOS.git
cd SG-EndevourOS
./install.sh
```

---

## 🛠️ Modos de Instalação no Assistente

O [`install.sh`](file:///home/grantd/Documents/github/MyProjects/SG-EndevourOS/install.sh) funciona como um roteiro interativo guiado (estilo *Oh My Zsh / Powerlevel10k*):

1. **Roteiro Guiado (Recomendado):** Faz perguntas claras para cada componente com valores padrão amigáveis `[S/n]`. Permite escolher se deseja ativar o layout `us_br`, quais aplicativos de contingência deseja configurar (seleção granular), o terminal Kitty e o KRunner flutuante. Exibe um resumo antes de aplicar.
2. **Instalação Express:** Aplica todos os ajustes recomendados de desktop de forma rápida e silenciosa.
3. **Menu Avançado:** Permite disparar módulos individuais isoladamente a qualquer momento para manutenção ou reaplicação.

---

## 📂 Estrutura do Repositório

```text
SG-EndevourOS/
├── install.sh                  # Orquestrador interativo principal
├── modules/                    # Módulos especializados e idempotentes
│   ├── 00-preflight.sh         # Diagnóstico (EndeavourOS/Arch, Plasma 6 Wayland, rede)
│   ├── 01-packages.sh          # Instalação de fontes JetBrains, Kitty e wl-clipboard
│   ├── 02-keyboard-xkb.sh      # Layout us_br, injeção no kxkbrc e ~/.XCompose
│   ├── 03-terminal-kitty.sh    # Dotfiles do Kitty (GPU, abas powerline, atalhos)
│   └── 04-plasma-theme.sh      # KRunner flutuante centralizado (Meta + Espaço)
├── configs/                    # Dotfiles versionados
│   └── home/
│       ├── .config/
│       │   ├── kitty/          # Configurações desacopladas do Kitty
│       │   └── xkb/symbols/    # Arquivo do layout físico us_br
│       └── .XCompose           # Tabela universal estilo Windows
├── overrides/                  # Contornos opcionais de compatibilidade
│   └── applications/           # Lançadores XWayland para Brave, Discord e VS Code
├── assets/                     # Wallpapers e recursos visuais
├── LICENSE                     # Licença do projeto
└── README.md                   # Documentação única consolidada
```

---

## 📄 Licença

Distribuído sob a licença [MIT](file:///home/grantd/Documents/github/MyProjects/SG-EndevourOS/LICENSE).
