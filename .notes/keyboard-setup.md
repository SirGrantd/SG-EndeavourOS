# Configuração e Estado Atual do Teclado (Cedilha e Layout US-Intl)

Este documento registra o estado atual, os arquivos modificados e as configurações ativas no sistema para suporte ao layout de teclado e cedilha.

---

## 1. Ambiente do Sistema

- **Distribuição:** EndeavourOS (base Arch Linux)
- **Ambiente Desktop:** KDE Plasma
- **Servidor Gráfico:** Wayland (`XDG_SESSION_TYPE=wayland`)
- **Layout de Teclado:** US International (`X11 Layout: us`, `X11 Variant: intl`)
- **Keymap Virtual Console:** `us-acentos`

---

## 2. Locais Onde as Configurações Estão Implementadas

### A. Escopo Global do Sistema (`/etc/environment`)
Arquivo de variáveis de ambiente lido pelo PAM na inicialização de sessões de usuário:

- **Arquivo:** `/etc/environment`
- **Valores configurados:**
  ```text
  GTK_IM_MODULE=cedilla
  QT_IM_MODULE=cedilla
  ```

---

### B. Escopo de Ambiente do Usuário (`systemd environment.d`)
Configuração para carregamento automático do arquivo de compose na sessão gráfica:

- **Arquivo:** `~/.config/environment.d/cedilla.conf`
- **Conteúdo ativo:**
  ```ini
  # Configuração de suporte ao XCompose para sessões de usuário
  XCOMPOSEFILE=%h/.XCompose
  ```

---

### C. Mapeamento de Teclas e Regras Customizadas (`~/.XCompose`)
Arquivo responsável pela sobrescrita de teclas mortas na pasta pessoal do usuário:

- **Arquivo:** `~/.XCompose`
- **Conteúdo ativo:**
  ```text
  include "%L"

  # Mapeia ' + c para ç e Ç (com identificadores canônicos ccedilla/Ccedilla)
  <dead_acute> <c> : "ç" ccedilla
  <dead_acute> <C> : "Ç" Ccedilla

  # Faz duas batidas na tecla gerarem aspas duplas/simples normais (estilo Windows)
  <dead_diaeresis> <dead_diaeresis> : "\"\""
  <dead_acute> <dead_acute> : "''"
  <dead_tilde> <dead_tilde> : "~~"
  <dead_circumflex> <dead_circumflex> : "^^"
  ```

---

## 3. Estado Atual dos Locales (`locale`)

Valores retornados pelo subsistema do sistema operacional:

```text
LANG=pt_BR.UTF-8
LC_CTYPE="pt_BR.UTF-8"
LC_NUMERIC=pt_BR.UTF-8
LC_TIME=pt_BR.UTF-8
LC_COLLATE="pt_BR.UTF-8"
LC_MONETARY=pt_BR.UTF-8
LC_MESSAGES="pt_BR.UTF-8"
LC_PAPER=pt_BR.UTF-8
LC_NAME=pt_BR.UTF-8
LC_ADDRESS=pt_BR.UTF-8
LC_TELEPHONE=pt_BR.UTF-8
LC_MEASUREMENT=pt_BR.UTF-8
LC_IDENTIFICATION=pt_BR.UTF-8
LC_ALL=
```
