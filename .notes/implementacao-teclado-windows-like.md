# Implementação — US-International com comportamento Windows-like

**Base:** [plano-correcao-teclado-windows-like.md](plano-correcao-teclado-windows-like.md) + [sistema-layout-atual.md](sistema-layout-atual.md)
**Sistema:** EndeavourOS · KDE Plasma (Wayland) · `us` + `intl` · `pt_BR.UTF-8`
**Validado em:** 2026-10-09 (libxkbcommon 1.13.2, gtk3 3.24.52, gtk4 4.22.5, qt6-base 6.11.2)

> [!IMPORTANT]
> Toda a implementação é **por usuário**: nenhum passo exige `sudo`, edição de `/etc`, pacman hook nem variável de ambiente. A reversão é apagar um único arquivo (`~/.XCompose`).

---

## 1. Validação do plano contra o estado atual

| Item do plano | Status | Observação |
|---|---|---|
| Manter `pt_BR.UTF-8` + `us/intl` | ✅ Correto | Confirmado em `locale`, `localectl` e `~/.config/kxkbrc` (`LayoutList=us`, `VariantList=intl`). |
| Etapa 0 — backup | ⚠️ Parcialmente obsoleta | `~/.XCompose` e `cedilla.conf` já não existem. `/etc/environment.bak` existe, mas contém a versão **antiga** (com `IM_MODULE=cedilla`) — **não restaurar a partir dele**. |
| Etapa 1 — remover `GTK_IM_MODULE`/`QT_IM_MODULE` | ✅ Já concluída | `/etc/environment` contém apenas comentários. |
| Etapa 2 — `~/.XCompose` com `include "%L"` | ✅ Correto | `%L` resolve para `pt_BR.UTF-8/Compose`, que já inclui o `en_US` e já define `' + c = ç`. |
| Regras `'` + consoantes | ✅ Necessárias | Sem regra, `'t`, `'d`, `'b`, `'f`, `'h`, `'q`, `'x` **cancelam** a composição (o apóstrofo some → `dont`). Outras (`'s`→`ś`, `'m`→`ḿ`, `'n`→`ń`) geram letras acentuadas. Cobrir todas é obrigatório. |
| Regras `"` + consoantes | ✅ Necessárias | Mesmo motivo (`"t`→`ẗ`, `"h`→`ḧ`, demais cancelam). |
| Repetição `''` `""` `~~` `^^` | ✅ Válido | Sobrescreve o padrão (`´`, `¨`, `~`, `^`). Sem conflito com sequências de 3 teclas (verificado). |
| `'`/`"` + **pontuação e dígitos** | ❌ Lacuna | O plano só cobre `".` e `",`. Fechar strings em código (`'abc')`, `"x";`, `"y"]`, `'$HOME'`, `"./dir"`) cancela a composição e **perde a aspa**. Corrigido abaixo. |
| `` ` `` `~` `^` + outras teclas | ❌ Lacuna | No `us(intl)` essas três também são teclas mortas: `~/` perde o `~`, regex `^s` vira `ŝ`, `` `n `` vira `ǹ`. Corrigido abaixo (opcional, recomendado). |
| Etapa 3 — `%h` em `environment.d` inválido | ✅ Correto e já concluída | `environment.d` só expande `$VAR`/`${VAR}`. O arquivo já foi removido. |
| `xkbcli compile-compose --file` | ⚠️ Desatualizado | `--file` está **deprecated** na versão instalada. Usar argumento posicional. `xkbcli` já está instalado (pacote `libxkbcommon`). |
| Seção Flatpak | ℹ️ Não se aplica | Brave (`brave-bin`), Discord (`discord`) e Steam são pacotes nativos. |
| Local do arquivo | ✅ `~/.XCompose` | Lido por libxkbcommon (Qt/Wayland), GTK3/GTK4 e Xlib (XWayland/Wine). Evitar `~/.config/XCompose`: o Xlib não o lê. |

---

## 2. Comportamento-alvo (referência Windows US-International)

| Tecla morta | Compõe (mantido do padrão) | Qualquer outra tecla |
|---|---|---|
| `'` | `á é í ó ú ý` e `ç` (com `c`) | `'` + tecla |
| `"` | `ä ë ï ö ü ÿ` | `"` + tecla |
| `` ` `` | `à è ì ò ù` | `` ` `` + tecla |
| `~` | `ã õ ñ` | `~` + tecla |
| `^` | `â ê î ô û` | `^` + tecla |
| Mesma tecla 2× | — | dois caracteres literais (`''`, `""`, ` `` `, `~~`, `^^`) |
| Tecla + `Espaço` | — | caractere literal (já é padrão do sistema) |

---

## 3. Passo a passo

### Passo 1 — Pré-checagem (somente leitura)

```bash
locale | grep -E '^(LANG|LC_CTYPE)='
grep -E '^[^#]' /etc/environment || echo "/etc/environment limpo"
ls ~/.XCompose ~/.config/environment.d/cedilla.conf 2>&1
printenv | grep -E 'IM_MODULE|XCOMPOSE' || echo "sem variáveis de IM/Compose"
```

- `grep -E '^[^#]'`: mostra apenas linhas que não são comentário.
- `2>&1`: exibe o erro "inexistente" junto da saída, confirmando a ausência dos arquivos.

**Esperado:** `pt_BR.UTF-8`, `/etc/environment limpo`, ambos os arquivos inexistentes e nenhuma variável de IM. Se algo divergir, **pare** e revise antes de seguir.

> Se `printenv` ainda mostrar `GTK_IM_MODULE`/`QT_IM_MODULE`, a sessão atual é anterior à limpeza: faça logout/login antes de continuar.

### Passo 2 — Gerar o arquivo candidato (fora do lugar definitivo)

O gerador evita digitar ~400 regras à mão e garante consistência. Ele **não** altera nada do sistema; apenas escreve um arquivo de rascunho em `~/.local/state/keyboard-fix/`.

Ajuste `TECLAS` se quiser limitar o escopo:
- **Recomendado (Windows-like completo):** `dead_acute dead_diaeresis dead_grave dead_tilde dead_circumflex`
- **Escopo mínimo do plano original:** `dead_acute dead_diaeresis` (as regras de repetição das 5 teclas são geradas em ambos os casos)

```bash
mkdir -p ~/.local/state/keyboard-fix
bash <<'SCRIPT' > ~/.local/state/keyboard-fix/XCompose.candidate
TECLAS="dead_acute dead_diaeresis dead_grave dead_tilde dead_circumflex"

esc() { local s=$1; s=${s//\\/\\\\}; s=${s//\"/\\\"}; printf '%s' "$s"; }
declare -A CH=(   [dead_acute]="'" [dead_diaeresis]='"' [dead_grave]='`' [dead_tilde]='~' [dead_circumflex]='^' )
declare -A KEEP=( [dead_acute]="aeiouyAEIOUY" [dead_diaeresis]="aeiouyAEIOUY" [dead_grave]="aeiouAEIOU" [dead_tilde]="aonAON" [dead_circumflex]="aeiouAEIOU" )
PUNCT="exclam:! at:@ numbersign:# dollar:$ percent:% ampersand:& asterisk:* parenleft:( parenright:) minus:- underscore:_ equal:= plus:+ bracketleft:[ bracketright:] braceleft:{ braceright:} backslash:\\ bar:| semicolon:; colon:: comma:, period:. slash:/ less:< greater:> question:?"

echo '# ~/.XCompose — US-International Windows-like (gerado; ver .notes/implementacao-teclado-windows-like.md)'
echo 'include "%L"'

echo; echo '# ---- repetição da tecla morta: dois caracteres literais ----'
for dk in dead_acute dead_diaeresis dead_grave dead_tilde dead_circumflex; do
  c=${CH[$dk]}; printf '<%s> <%s> : "%s"\n' "$dk" "$dk" "$(esc "$c$c")"
done

for dk in $TECLAS; do
  c=${CH[$dk]}; keep=${KEEP[$dk]}
  echo; echo "# ---- $dk ($c) + letra/dígito/pontuação sem acento => literal ----"
  for l in {a..z} {A..Z}; do
    [[ $keep == *"$l"* ]] && continue
    [[ $dk == dead_acute && ( $l == c || $l == C ) ]] && continue
    printf '<%s> <%s> : "%s"\n' "$dk" "$l" "$(esc "$c$l")"
  done
  for d in {0..9}; do printf '<%s> <%s> : "%s"\n' "$dk" "$d" "$(esc "$c$d")"; done
  for p in $PUNCT; do ks=${p%%:*}; ch=${p#*:}; printf '<%s> <%s> : "%s"\n' "$dk" "$ks" "$(esc "$c$ch")"; done
done

echo; echo '# ---- cedilha (redundante com pt_BR, mantida explícita por segurança) ----'
echo '<dead_acute> <c> : "ç" ccedilla'
echo '<dead_acute> <C> : "Ç" Ccedilla'
SCRIPT
grep -c '^<' ~/.local/state/keyboard-fix/XCompose.candidate
```

- `bash <<'SCRIPT' ... SCRIPT`: executa o gerador num subshell; as aspas em `'SCRIPT'` impedem que o shell atual expanda `$`/`` ` `` no texto.
- `> .../XCompose.candidate`: grava a saída apenas no rascunho.
- `grep -c '^<'`: conta as regras geradas. **Esperado: 400** no escopo completo (159 no escopo mínimo).

### Passo 3 — Validar a sintaxe e o resultado

```bash
F=~/.local/state/keyboard-fix/XCompose.candidate
xkbcli compile-compose --test --locale pt_BR.UTF-8 "$F" && echo "SINTAXE OK"
xkbcli compile-compose --locale pt_BR.UTF-8 "$F" 2>/dev/null | grep -P \
  '^<dead_acute>\s+<(t|a|c|C|parenright|dead_acute)>\s+:|^<dead_diaeresis>\s+<(u|c|dead_diaeresis)>\s+:|^<dead_tilde>\s+<(slash|a|n)>\s+:|^<dead_circumflex>\s+<(1|o)>\s+:|^<dead_grave>\s+<(a|n)>\s+:'
```

- `--test`: compila sem imprimir a tabela; o código de saída indica sucesso/erro.
- `--locale pt_BR.UTF-8`: resolve o `include "%L"` com a tabela brasileira.
- Segundo comando: imprime a tabela final (sistema + suas regras) e filtra amostras.
- Avisos `this compose sequence already exists; overriding` (com `--verbose`) são **esperados**: indicam exatamente as sobrescritas desejadas.

**Esperado (validado nesta máquina):**

```text
<dead_acute> <t>          : "'t"
<dead_acute> <a>          : "á"
<dead_acute> <c>          : "ç"
<dead_acute> <C>          : "Ç"
<dead_acute> <parenright> : "')"
<dead_acute> <dead_acute> : "''"
<dead_diaeresis> <u>      : "ü"
<dead_diaeresis> <c>      : "\"c"
<dead_diaeresis> <dead_diaeresis> : "\"\""
<dead_tilde> <slash>      : "~/"
<dead_tilde> <a>          : "ã"
<dead_tilde> <n>          : "ñ"
<dead_circumflex> <1>     : "^1"
<dead_circumflex> <o>     : "ô"
<dead_grave> <a>          : "à"
<dead_grave> <n>          : "`n"
```

Se aparecer `ERROR` ou faltar alguma linha, **não prossiga**.

### Passo 4 — Instalar

```bash
install -m 644 ~/.local/state/keyboard-fix/XCompose.candidate ~/.XCompose
```

- `install`: copia o arquivo já definindo permissões.
- `-m 644`: leitura para todos, escrita só para o dono (padrão para arquivos de configuração).

**Não fazer:** criar `XCOMPOSEFILE` em `environment.d`, definir `GTK_IM_MODULE`/`QT_IM_MODULE` ou editar `/usr/share/X11/locale/*`. O `~/.XCompose` é encontrado automaticamente.

### Passo 5 — Recarregar

A tabela Compose é carregada quando cada aplicativo inicia. Faça **logout/login** do Plasma para garantir que todos os processos (incluindo XWayland, Steam e serviços em segundo plano) leiam o arquivo novo.

---

## 4. Testes de aceitação

Teste primeiro no **Kate** (Qt/Wayland) e no **Konsole**; depois em um app GTK, **Brave**, **Discord** e no chat de um jogo (Steam/Proton).

| Digitar | Resultado esperado |
|---|---|
| `'` `e` / `'` `Shift+e` | `é` / `É` |
| `'` `c` / `'` `Shift+c` | `ç` / `Ç` |
| `~` `a` / `^` `e` / `` ` `` `a` | `ã` / `ê` / `à` |
| `don't` · `I'm` · `it's` · `we're` | idêntico ao digitado |
| `print('abc')` | `print('abc')` |
| `x = "abc";` · `["a", "b"]` | idêntico ao digitado |
| `cd ~/Documents` | idêntico ao digitado |
| `echo "$HOME"` · `'%s'` · `"\n"` | idêntico ao digitado |
| `grep '^s'` | `grep '^s'` |
| `'` `'` · `"` `"` · `~` `~` · `^` `^` | `''` · `""` · `~~` · `^^` |
| `'` `Espaço` | `'` |

| Aplicativo | Toolkit/caminho | Resultado |
|---|---|---|
| Kate / Konsole | Qt 6 · Wayland | |
| App GTK (ex.: GIMP, gedit) | GTK | |
| Brave | Chromium | |
| Discord | Electron | |
| Jogo (chat) | SDL / Wine (XWayland) | |

---

## 5. Exceções por aplicativo

- **Brave / Discord sem composição correta:** testar temporariamente via XWayland (feche todas as instâncias antes):
  ```bash
  brave --ozone-platform=x11
  discord --ozone-platform=x11
  ```
  - `--ozone-platform=x11`: força o Chromium/Electron a rodar via XWayland, usando o caminho de entrada X11 (que lê `~/.XCompose` via Xlib/GTK).
  - Só tornar permanente (atalho `.desktop` em `~/.local/share/applications/` ou `~/.config/brave-flags.conf`) se o teste resolver.
- **Jogos:** comandos de jogo usam teclas físicas e não passam pelo Compose (não são afetados). Em campos de texto/chat, a tecla morta exige a segunda tecla — mesmo comportamento do Windows. Investigar jogo a jogo; não reintroduzir variáveis globais.

---

## 6. Limitações conhecidas

- **Tecla morta + `Enter`/`Tab`/setas/`Esc`:** a composição é cancelada e o caractere da tecla morta é descartado. Use `tecla morta + Espaço` antes. (Emitir quebra de linha via Compose não é confiável entre aplicativos.)
- **Duas teclas mortas diferentes em sequência** (ex.: `'` seguido de `"`): o sistema aguarda uma 3ª tecla (sequências como `ǘ`). Use `Espaço` entre elas, ex.: `"'"` → `"` `Espaço` `'` `Espaço` `"` `Espaço`.
- **Iguais ao Windows:** `y'all` → `yáll`, `'em` → `ém`, `"apple"` → `äpple"` (vogal após tecla morta sempre compõe).

---

## 7. Reversão

```bash
rm ~/.XCompose
```

- Remove apenas as regras personalizadas; o sistema volta ao estado de [sistema-layout-atual.md](sistema-layout-atual.md) (cedilha continua funcionando via `pt_BR`).
- Depois, logout/login.
- O rascunho em `~/.local/state/keyboard-fix/` pode ser mantido para reaplicar ou apagado com `rm -r ~/.local/state/keyboard-fix`.

> [!WARNING]
> Não restaure `/etc/environment` a partir de `/etc/environment.bak`: esse backup contém as variáveis `GTK_IM_MODULE=cedilla`/`QT_IM_MODULE=cedilla` removidas na limpeza.
