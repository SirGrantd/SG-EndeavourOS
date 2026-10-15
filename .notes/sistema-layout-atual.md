# Estado Atual do Sistema: Layout de Teclado e Localização

Este documento resume a configuração ativa e consolidada do sistema após a limpeza e restauração para os padrões oficiais da distribuição.

---

## 1. Ambiente do Sistema

- **Distribuição:** EndeavourOS (base Arch Linux)
- **Ambiente Desktop:** KDE Plasma
- **Sessão Gráfica:** Wayland nativo (`XDG_SESSION_TYPE=wayland`)
- **Layout de Teclado:** US International with dead keys (`us`, variante `intl`)
- **Keymap do Console Virtual (TTY):** `us-acentos`

---

## 2. Configurações de Localização (`locale`)

O sistema está operando nativamente em Português do Brasil:

- **Configuração Global (`/etc/locale.conf`):**
  ```ini
  LANG=pt_BR.UTF-8
  LC_ADDRESS=pt_BR.UTF-8
  LC_IDENTIFICATION=pt_BR.UTF-8
  LC_MEASUREMENT=pt_BR.UTF-8
  LC_MONETARY=pt_BR.UTF-8
  LC_NAME=pt_BR.UTF-8
  LC_NUMERIC=pt_BR.UTF-8
  LC_PAPER=pt_BR.UTF-8
  LC_TELEPHONE=pt_BR.UTF-8
  LC_TIME=pt_BR.UTF-8
  ```

---

## 3. Comportamento Nativo da Cedilha (`ç`)

- **Como Funciona:**
  - Como o subsistema de caracteres opera com `LC_CTYPE=pt_BR.UTF-8`, a biblioteca de composição (`libxkbcommon` / X11) carrega automaticamente a tabela oficial brasileira `/usr/share/X11/locale/pt_BR.UTF-8/Compose`.
  - A combinação `'` + `c` resulta nativamente em **`ç`** sem necessidade de configurações adicionais.

---

## 4. Estado de Limpeza e Integridade (Padrão de Fábrica)

Todas as personalizações e intermediários foram removidos:

| Componente | Estado Atual |
| :--- | :--- |
| **`/etc/environment`** | Limpo (contém apenas comentários do PAM). Módulos `GTK_IM_MODULE` e `QT_IM_MODULE` removidos. |
| **`libx11`** | Pacote oficial íntegro (`0` arquivos modificados). O arquivo `en_US.UTF-8/Compose` está original. |
| **Pacman Hooks** | `/etc/pacman.d/hooks/fix-cedilla.hook` removido. |
| **Scripts de Usuário** | `~/.local/bin/fix-cedilla.sh` removido. |
| **Compose de Usuário** | `~/.XCompose` e `~/.config/environment.d/cedilla.conf` removidos. |

---

## 5. Benefícios da Configuração Atual

1. **Jogos (Steam / Proton / Wine / SDL):** Não há mais interceptação de eventos de teclado por módulos legados de entrada, garantindo detecção correta de teclas.
2. **Navegadores e Apps Electron (Brave, Discord, VS Code):** Funcionamento nativo via Wayland sem quebra de atalhos ou desfazimento de texto.
3. **Resistência a Atualizações:** As atualizações do sistema via `pacman` não quebram o layout nem alteram o comportamento das teclas.
