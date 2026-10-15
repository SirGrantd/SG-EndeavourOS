# Plano de correção — US-International com comportamento próximo ao Windows

**Sistema-alvo:** EndeavourOS (base Arch Linux), KDE Plasma, Wayland  
**Configuração atual conhecida:** layout `us` / variante `intl`, locale `pt_BR.UTF-8`, console virtual `us-acentos`, regras personalizadas em `~/.XCompose` e variáveis `GTK_IM_MODULE=cedilla` / `QT_IM_MODULE=cedilla` relatadas em `/etc/environment`.

## 1. Objetivo e resultado esperado

Reproduzir, tanto quanto o Linux permite, o comportamento do teclado **English (US, International)** do Windows:

- `'` seguido de vogal continua produzindo acentos, como `´ + e → é`.
- `'` seguido de `c` produz `ç`; com `Shift+C`, produz `Ç`.
- `'` seguido de uma consoante comum deve resultar em apóstrofo literal + letra. Por exemplo, `don't`, `I'm` e `it's` não devem virar `don´t`, `Iḿ` ou perder caracteres.
- `"` seguido de uma consoante deve resultar em aspas duplas literais + letra, em vez de produzir um caractere acentuado inesperado ou descartar uma tecla.
- Duas pressões consecutivas da tecla morta devem continuar produzindo dois caracteres literais, conforme a preferência atual: `''`, `""`, `~~` e `^^`.
- A configuração deve ser por usuário sempre que possível, fácil de reverter e não depender de editar arquivos fornecidos por pacotes.

**Limite importante:** não há garantia de identidade absoluta com o Windows em todos os programas. `~/.XCompose` é usado por aplicativos que integram o mecanismo Compose; alguns aplicativos Wayland nativos, navegadores Chromium/Electron e jogos podem usar outro caminho de entrada. O plano prevê teste e alternativa por aplicativo, não promete compatibilidade universal.

## 2. Estratégia recomendada

1. Manter o locale atual `pt_BR.UTF-8` e o layout KDE `us` + variante `intl` no primeiro ciclo de testes.
2. Fazer backup das configurações existentes.
3. Remover de `/etc/environment` as definições globais `GTK_IM_MODULE=cedilla` e `QT_IM_MODULE=cedilla`, como **teste controlado**, não como causa comprovada dos problemas.
4. Consolidar em `~/.XCompose` as regras Windows-like para apóstrofo, cedilha, aspas e repetição de teclas mortas.
5. Não usar `XCOMPOSEFILE=%h/.XCompose` em `environment.d`. Para o arquivo no local padrão, normalmente não é necessário definir `XCOMPOSEFILE`; `%h` não é um formato de expansão aceito pelo `environment.d`.
6. Testar separadamente aplicativos GTK, Qt, Brave/Discord e jogos. Se um programa não respeitar Compose, tratar esse caso individualmente.

## 3. Etapa 0 — Registrar o estado e criar backups

Execute os comandos abaixo no terminal. Eles apenas registram o estado e criam cópias de segurança:

```bash
mkdir -p "$HOME/.local/state/keyboard-fix-backup"
BACKUP="$HOME/.local/state/keyboard-fix-backup/$(date +%F-%H%M%S)"
mkdir -p "$BACKUP"
printf 'Backup em: %s\n' "$BACKUP"

locale > "$BACKUP/locale.txt"
localectl status > "$BACKUP/localectl-status.txt" 2>&1
printf 'XDG_SESSION_TYPE=%s\n' "$XDG_SESSION_TYPE" > "$BACKUP/session.txt"

[ -f "$HOME/.XCompose" ] && cp -a "$HOME/.XCompose" "$BACKUP/XCompose.original"
[ -f "$HOME/.config/environment.d/cedilla.conf" ] && cp -a "$HOME/.config/environment.d/cedilla.conf" "$BACKUP/cedilla.conf.original"
sudo cp -a /etc/environment "$BACKUP/environment.original"
```

Confirme que o resultado de `locale` contém `LANG=pt_BR.UTF-8` e `LC_CTYPE="pt_BR.UTF-8"` ou valores equivalentes. **Não altere `LANG`/`LC_CTYPE` neste plano**, pois o locale brasileiro já está ativo.

> Guarde o caminho de `BACKUP` exibido no terminal. Ele será usado se for necessário reverter as alterações.

## 4. Etapa 1 — Remover os módulos globais legados como teste

Edite o arquivo global com:

```bash
sudoedit /etc/environment
```

Remova somente estas entradas, caso estejam presentes:

```text
GTK_IM_MODULE=cedilla
QT_IM_MODULE=cedilla
```

Não apague outras variáveis do arquivo. Não use um `sed` genérico sem revisar o conteúdo: edição manual reduz o risco de remover configurações não relacionadas.

A remoção é um teste de compatibilidade; não é uma afirmação de que essas variáveis necessariamente causaram as falhas. Se o teste piorar um aplicativo GTK específico, registre o caso e avalie restaurar apenas a variável comprovadamente necessária.

## 5. Etapa 2 — Consolidar `~/.XCompose`

Crie o arquivo temporário abaixo, revise-o e só então instale-o como `~/.XCompose`. **Faça isso depois do backup da Etapa 0.** A linha `include "%L"` preserva as regras padrão do locale, inclusive as composições de acentos sobre vogais. As regras posteriores corrigem as diferenças mais frequentes em relação ao Windows.

```text
include "%L"

# Manter o comportamento de repetição desejado para teclas mortas.
<dead_acute> <dead_acute> : "''"
<dead_diaeresis> <dead_diaeresis> : "\"\""
<dead_tilde> <dead_tilde> : "~~"
<dead_circumflex> <dead_circumflex> : "^^"

# Windows US-International: cedilha com apóstrofo + C.
<dead_acute> <c> : "ç" ccedilla
<dead_acute> <C> : "Ç" Ccedilla

# Apóstrofo literal antes de consoantes (ambas as caixas).
# As regras padrão de vogais permanecem disponíveis por causa de include "%L".
<dead_acute> <b> : "'b"
<dead_acute> <B> : "'B"
<dead_acute> <d> : "'d"
<dead_acute> <D> : "'D"
<dead_acute> <f> : "'f"
<dead_acute> <F> : "'F"
<dead_acute> <g> : "'g"
<dead_acute> <G> : "'G"
<dead_acute> <h> : "'h"
<dead_acute> <H> : "'H"
<dead_acute> <j> : "'j"
<dead_acute> <J> : "'J"
<dead_acute> <k> : "'k"
<dead_acute> <K> : "'K"
<dead_acute> <l> : "'l"
<dead_acute> <L> : "'L"
<dead_acute> <m> : "'m"
<dead_acute> <M> : "'M"
<dead_acute> <n> : "'n"
<dead_acute> <N> : "'N"
<dead_acute> <p> : "'p"
<dead_acute> <P> : "'P"
<dead_acute> <q> : "'q"
<dead_acute> <Q> : "'Q"
<dead_acute> <r> : "'r"
<dead_acute> <R> : "'R"
<dead_acute> <s> : "'s"
<dead_acute> <S> : "'S"
<dead_acute> <t> : "'t"
<dead_acute> <T> : "'T"
<dead_acute> <v> : "'v"
<dead_acute> <V> : "'V"
<dead_acute> <w> : "'w"
<dead_acute> <W> : "'W"
<dead_acute> <x> : "'x"
<dead_acute> <X> : "'X"
<dead_acute> <z> : "'z"
<dead_acute> <Z> : "'Z"

# Aspas duplas literais antes de consoantes.
# Preserve os padrões do locale para vogais e, se suportado, y/ÿ.
<dead_diaeresis> <b> : "\"b"
<dead_diaeresis> <B> : "\"B"
<dead_diaeresis> <c> : "\"c"
<dead_diaeresis> <C> : "\"C"
<dead_diaeresis> <d> : "\"d"
<dead_diaeresis> <D> : "\"D"
<dead_diaeresis> <f> : "\"f"
<dead_diaeresis> <F> : "\"F"
<dead_diaeresis> <g> : "\"g"
<dead_diaeresis> <G> : "\"G"
<dead_diaeresis> <h> : "\"h"
<dead_diaeresis> <H> : "\"H"
<dead_diaeresis> <j> : "\"j"
<dead_diaeresis> <J> : "\"J"
<dead_diaeresis> <k> : "\"k"
<dead_diaeresis> <K> : "\"K"
<dead_diaeresis> <l> : "\"l"
<dead_diaeresis> <L> : "\"L"
<dead_diaeresis> <m> : "\"m"
<dead_diaeresis> <M> : "\"M"
<dead_diaeresis> <n> : "\"n"
<dead_diaeresis> <N> : "\"N"
<dead_diaeresis> <p> : "\"p"
<dead_diaeresis> <P> : "\"P"
<dead_diaeresis> <q> : "\"q"
<dead_diaeresis> <Q> : "\"Q"
<dead_diaeresis> <r> : "\"r"
<dead_diaeresis> <R> : "\"R"
<dead_diaeresis> <s> : "\"s"
<dead_diaeresis> <S> : "\"S"
<dead_diaeresis> <t> : "\"t"
<dead_diaeresis> <T> : "\"T"
<dead_diaeresis> <v> : "\"v"
<dead_diaeresis> <V> : "\"V"
<dead_diaeresis> <w> : "\"w"
<dead_diaeresis> <W> : "\"W"
<dead_diaeresis> <x> : "\"x"
<dead_diaeresis> <X> : "\"X"
<dead_diaeresis> <z> : "\"z"
<dead_diaeresis> <Z> : "\"Z"

# Pontuação comum após aspas mortas: preservar o caractere digitado.
<dead_diaeresis> <period> : "\"."
<dead_diaeresis> <comma> : "\","
```

### Antes de aplicar o arquivo

- Revise com atenção as regras de aspas; a barra invertida é usada para escapar `"` dentro da string Compose.
- O arquivo acima é uma base de correção para as combinações mais comuns, não uma réplica matemática de cada sequência da implementação da Microsoft. Combinações pouco usuais, teclas numéricas/símbolos e sequências de duas teclas mortas diferentes ainda podem variar.
- Se já houver outras regras pessoais no arquivo atual, mescle-as conscientemente; não as descarte sem verificar.

Para aplicar depois de revisar e salvar o conteúdo em `~/.XCompose`, confirme permissões e sintaxe:

```bash
chmod 644 "$HOME/.XCompose"
command -v xkbcli >/dev/null && xkbcli compile-compose --file "$HOME/.XCompose"
```

Se `xkbcli` não estiver instalado, instale a ferramenta de diagnóstico disponível no repositório da distribuição ou prossiga para os testes manuais. Se o comando apontar erro de sintaxe, **não prossiga para o teste dos aplicativos** até corrigir o arquivo.

## 6. Etapa 3 — Remover a variável `XCOMPOSEFILE` redundante/incorreta

O arquivo atual `~/.config/environment.d/cedilla.conf` contém `XCOMPOSEFILE=%h/.XCompose`. O formato `%h` não é uma expansão documentada para arquivos `environment.d`. Para o caminho padrão, deixe a biblioteca localizar `~/.XCompose` automaticamente.

Se `cedilla.conf` contiver somente essa variável, remova-o:

```bash
rm "$HOME/.config/environment.d/cedilla.conf"
```

Se ele tiver outras configurações, edite-o e remova **somente** a linha `XCOMPOSEFILE=%h/.XCompose`.

Não substitua a linha por outra configuração global sem necessidade comprovada. Algumas implementações de Compose respeitam `XCOMPOSEFILE`, mas nem todos os aplicativos o usam; exportar a variável não força um aplicativo a implementar Compose.

## 7. Etapa 4 — Conferir o layout do KDE e recarregar a sessão

Em **Configurações do Sistema → Dispositivos de entrada → Teclado → Layouts** (o nome exato pode variar por versão):

- manter English (US), variante **English (US, international with dead keys)** (`us` + `intl`), salvo se já estiver selecionada uma variante equivalente;
- não adicionar layouts redundantes, pois alternar layouts pode parecer uma falha de composição;
- manter `us-acentos` apenas para o console virtual/TTY, se esse é o comportamento desejado fora do desktop.

Encerre a sessão completa do KDE Plasma e entre novamente. Um simples fechamento de terminal não atualiza o ambiente herdado por todos os aplicativos.

## 8. Etapa 5 — Testes de aceitação

Execute primeiro os testes em um editor simples (por exemplo, Kate) e no Konsole. Depois repita nos aplicativos problemáticos. Registre o resultado por aplicativo.

| Sequência | Resultado-alvo |
|---|---|
| `'` + `e` | `é` |
| `'` + `Shift` + `e` | `É` |
| `'` + `c` | `ç` |
| `'` + `Shift` + `c` | `Ç` |
| Digitar `don't` | `don't` |
| Digitar `I'm` | `I'm` |
| Duas teclas de apóstrofo | `''` |
| Duas teclas de aspas | `""` |
| Duas teclas de til | `~~` |
| Duas teclas de circunflexo | `^^` |
| `"` + `c` | `"c` |
| `"` + `m` | `"m` |

Faça os testes em:

1. Kate/KWrite ou outro editor Qt.
2. Um aplicativo GTK.
3. Brave e Discord.
4. Os jogos que apresentavam falha (Steam/Proton/SDL).
5. Um TTY, se for importante validar o console virtual.

**Critério:** primeiro confirmar se a composição está correta num editor; depois verificar estabilidade e entrada nos programas problemáticos. Um resultado correto no editor não comprova que todos os jogos e navegadores usarão o mesmo mecanismo.

## 9. Etapa 6 — Tratamento de exceções por aplicativo

### Brave/Chromium e aplicativos Electron

Se a composição funcionar no Kate/GTK/Qt, mas não no Brave ou num aplicativo Electron executado como cliente Wayland nativo, isso pode ser uma limitação do caminho de entrada do próprio aplicativo. Teste primeiro um lançamento temporário via XWayland, sem alterar ainda o atalho permanente:

```bash
brave --ozone-platform=x11
```

O nome do executável pode variar. Encerre antes todas as instâncias do navegador, pois uma instância já aberta pode ignorar o novo argumento.

Se o teste resolver o problema, pode-se aplicar o argumento ao atalho específico. Para Flatpak, o aplicativo também pode precisar de acesso de leitura ao arquivo `~/.XCompose`; conceda somente o acesso necessário, usando o ID correto do aplicativo. Não altere permissões de todo o diretório pessoal sem necessidade.

### Jogos Steam/Proton/SDL

Teste cada jogo separadamente. Jogos podem ler teclas físicas, usar APIs próprias ou ignorar a camada Compose. Se o problema estiver limitado a um jogo, investigue suas opções de entrada/compatibilidade antes de mudar variáveis globais novamente. Não há como garantir que `~/.XCompose` corrija todos os jogos.

## 10. Reversão

Se a alteração piorar o comportamento, encerre a sessão e restaure os arquivos salvos na Etapa 0. Use os caminhos reais informados por `BACKUP`; não copie um exemplo de caminho sem conferir.

Exemplo para restaurar o `~/.XCompose` original:

```bash
cp -a "/caminho/real/do/backup/XCompose.original" "$HOME/.XCompose"
```

Para `/etc/environment`, restaure o arquivo original com `sudo cp -a` usando o caminho de backup correspondente. Se `cedilla.conf` existia antes e precisar ser recuperado, restaure também a cópia original. Depois, encerre e inicie a sessão novamente.

## 11. Fontes técnicas

- [libxkbcommon — Compose e teclas mortas](https://xkbcommon.org/doc/current/group__compose.html): formato Compose, localização da tabela e diferenças no tratamento de sequências canceladas.
- [libxkbcommon — ferramentas de diagnóstico](https://xkbcommon.org/doc/current/debugging.html): `xkbcli compile-compose` e ferramentas de teste.
- [systemd — `environment.d`](https://man7.org/linux/man-pages/man5/environment.d.5.html): sintaxe e expansão de variáveis aceita nos arquivos `environment.d`.
- [US-International Windows-like para Linux](https://github.com/T-21/us-intl-windows-like): implementação de referência para apóstrofo literal antes de consoantes, cedilha e limitações de aplicações Wayland/Chromium.

## Veredito

A combinação **locale `pt_BR.UTF-8` + layout `us/intl` + regras Windows-like em `~/.XCompose` + remoção controlada dos módulos globais desnecessários** é uma abordagem prática para aproximar o Linux do comportamento do Windows. A parte decisiva é testar programa por programa: se um aplicativo não respeitar Compose, a solução precisa ser aplicada no caminho de entrada desse aplicativo ou aceita como limitação, em vez de adicionar mais variáveis globais sem diagnóstico.
