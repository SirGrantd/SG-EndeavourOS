# Plano de Ação: Correção do Layout de Teclado, Cedilha e Compatibilidade de Apps/Jogos

Este documento detalha o plano prático para eliminar os conflitos de digitação, restauração de ações em apps Electron/Chromium (Brave, Discord) e falhas de caracteres em jogos, mantendo a digitação de cedilha (`' + c = ç`) e aspas no padrão esperado.

---

## 1. Objetivo

- Remover módulos legados de método de entrada (`GTK_IM_MODULE` / `QT_IM_MODULE`) que interceptam chamadas e quebram jogos, Brave e Discord no Wayland.
- Manter o suporte nativo e consistente para `' + c = ç` e acentuação via Compose / Wayland nativo.
- Preservar o atalho de repetição rápida de aspas/caracteres no `~/.XCompose` sem conflitar com o pipeline gráfico do KDE Plasma.

---

## 2. Etapas do Plano de Ação

### Etapa 1: Limpeza das Variáveis Conflitantes em `/etc/environment`
Remover as linhas `GTK_IM_MODULE=cedilla` e `QT_IM_MODULE=cedilla` do arquivo `/etc/environment`.

- **Motivo:** No Wayland com KDE Plasma, forçar esses módulos obriga apps GTK/Qt/Electron a tentarem usar bibliotecas legadas de input do X11, causando perda de buffer em jogos e falhas de foco/desfazimento em apps como Brave e Discord.
- **Ação:** Deixar `/etc/environment` limpo (ou sem essas duas variáveis).

---

### Etapa 2: Ajuste e Validação do `~/.XCompose`
Garantir que as regras de composição sejam lidas de forma limpa pelo `libxkbcommon` (nativo do Wayland) e clientes XWayland.

- **Arquivo:** `~/.XCompose`
- **Estrutura recomendada:**
  ```text
  include "%L"

  # Mapeia ' + c para ç e Ç
  <dead_acute> <c> : "ç" ccedilla
  <dead_acute> <C> : "Ç" Ccedilla

  # Dupla batida para emitir o caractere individual sem esperar tecla morta
  <dead_acute> <dead_acute> : "'" apostrophe
  <dead_diaeresis> <dead_diaeresis> : "\"" quotedbl
  <dead_tilde> <dead_tilde> : "~" asciitilde
  <dead_circumflex> <dead_circumflex> : "^" asciicircum
  ```
  *(Nota: no arquivo atual estava configurado para emitir aspas duplas repetidas como `""` e `''`; o ajuste para emitir o caractere individual padroniza a digitação idêntica ao Windows).*

---

### Etapa 3: Manter a Declaração de `XCOMPOSEFILE`
- O arquivo `~/.config/environment.d/cedilla.conf` já aponta para:
  ```ini
  XCOMPOSEFILE=%h/.XCompose
  ```
- Isso garante que a sessão systemd do usuário passe a tabela de Compose para qualquer app iniciado via interface gráfica (Wayland, Flatpaks, etc.).

---

### Etapa 4: Aplicação e Recarregamento da Sessão
Como as variáveis de `/etc/environment` são carregadas no login (via PAM):

1. Salvar as alterações nos arquivos.
2. Fazer **Logout** e **Login** na sessão do KDE Plasma (ou reiniciar o sistema).
3. Testar o comportamento em:
   - Jogos (Steam / Proton / SDL).
   - Navegadores / Electron (Brave, Discord).
   - Terminal e editores de código.

---

## 3. Comandos Previstos para Execução

Quando autorizado, os comandos a serem executados serão:

1. **Backup e remoção das variáveis em `/etc/environment`:**
   ```bash
   sudo cp /etc/environment /etc/environment.bak
   sudo sed -i '/IM_MODULE=cedilla/d' /etc/environment
   ```
   *Explicação:*
   - `cp /etc/environment /etc/environment.bak`: Cria uma cópia de segurança antes de qualquer edição.
   - `sed -i '/IM_MODULE=cedilla/d' /etc/environment`: Remove qualquer linha contendo `IM_MODULE=cedilla` diretamente no arquivo.

2. **Atualização do `~/.XCompose`:**
   Aplicação das regras ajustadas sem necessidade de privilégios de `sudo`.
