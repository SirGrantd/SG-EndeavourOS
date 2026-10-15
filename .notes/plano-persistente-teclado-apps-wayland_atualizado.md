# Plano de correção persistente do teclado no Brave, Discord e VS Code

## 1. Objetivo e ambiente considerado

Este plano considera o seguinte ambiente, conforme o diagnóstico anterior:

- **Distribuição:** EndeavourOS, baseada no Arch Linux.
- **Desktop:** KDE Plasma.
- **Sessão:** Wayland.
- **Teclado:** `us(intl)` — US International com teclas mortas.
- **Locale:** `pt_BR.UTF-8`.
- **Personalização Compose:** `~/.XCompose`, incluindo `ç`/`Ç` e repetição de teclas mortas (`''`, `""`, `~~`, `^^`).
- **Personalização adicional XKB:** a tecla física de apóstrofo/aspas deve gerar `dead_acute` sem modificadores, aspas duplas literais com `Shift` e `dead_diaeresis` somente com `AltGr`.
- **Aplicativos afetados:** Brave, Discord e Visual Studio Code.

O objetivo é recuperar a composição de caracteres e fazer com que os ajustes de inicialização **não sejam sobrescritos por atualizações dos pacotes**.

## 2. Diagnóstico: o que provavelmente aconteceu

Uma atualização do Brave, Discord ou VS Code **não deveria apagar o arquivo `~/.XCompose`**, pois ele fica no diretório pessoal do usuário. O que pode mudar durante uma atualização é a versão do Chromium/Electron ou a forma como o aplicativo é iniciado.

Há problemas documentados de composição de teclas no Chromium/Electron quando executados nativamente sobre Wayland. Em alguns casos, `~/.XCompose` funciona em outros aplicativos, mas as sequências são ignoradas ou interpretadas de forma diferente em um aplicativo Chromium/Wayland. Forçar o backend X11, através do XWayland, é uma alternativa conhecida para testar esse cenário.

**Importante:** o plano não presume que essa seja a causa antes dos testes. Se o problema estiver em outro ponto, forçar XWayland pode não resolver.

## 3. Estratégia recomendada

1. Confirmar que `~/.XCompose`, o locale e o layout atual continuam corretos.
2. Aplicar um mapeamento XKB personalizado no diretório do usuário para controlar quando a tecla de aspas é literal e quando ativa o trema.
3. Testar o comportamento geral e, em seguida, testar cada aplicativo.
4. Usar `--ozone-platform=x11` somente nos aplicativos em que o teste demonstrar que isso é necessário.
5. Tornar essas flags persistentes com arquivos `.desktop` locais em `~/.local/share/applications/`, sem editar os arquivos em `/usr/share/applications/`.
6. Revalidar o comportamento após atualizações importantes.

Essa estratégia mantém os demais aplicativos no Wayland nativo e evita alterar variáveis globais do sistema sem necessidade.

## 4. Etapa 1 — Conferir a configuração atual

Execute os comandos de leitura abaixo:

```bash
printf 'Sessão gráfica: %s\n' "$XDG_SESSION_TYPE"
locale | grep -E '^(LANG|LC_CTYPE|LC_ALL)='
printf '\nArquivo Compose:\n'
ls -l ~/.XCompose
grep -nE 'include|dead_acute|dead_diaeresis|dead_tilde|dead_circumflex' ~/.XCompose
```

Confirme que `~/.XCompose` ainda contém as regras desejadas e que `LC_CTYPE` continua em `pt_BR.UTF-8` (ou que o locale brasileiro é o esperado no seu ambiente).

Descubra os comandos e os arquivos `.desktop` realmente instalados. Os nomes variam conforme o pacote usado:

```bash
for app in brave brave-browser discord code; do
  command -v "$app" 2>/dev/null || true
done

find /usr/share/applications ~/.local/share/applications ~/.config/autostart \
  -maxdepth 1 -type f \
  \( -iname '*brave*.desktop' -o -iname '*discord*.desktop' -o -iname '*code*.desktop' -o -iname '*visual-studio-code*.desktop' \) \
  -print 2>/dev/null
```

Se os aplicativos continuarem falhando, não reescreva `~/.XCompose` imediatamente. Primeiro descubra se mudou o backend gráfico.

## 5. Etapa 2 — Personalizar a tecla de aspas no XKB (Shift literal; trema via AltGr)

Este requisito **não deve ser implementado somente no `~/.XCompose`**. O Compose trata sequências de composição; o que se deseja aqui é mudar qual símbolo a tecla entrega em cada nível de modificador. Para isso, crie um layout XKB específico do usuário. O diretório `~/.config/xkb/` é suportado pelo `libxkbcommon` e evita editar arquivos em `/usr/share/X11/xkb/`, que podem ser sobrescritos por atualizações. Consulte a documentação do `libxkbcommon` e do KDE Plasma Wayland nas referências ao final.

### Comportamento desejado

Na tecla física que possui `'` e `"` no layout US:

| Combinação | Ação esperada |
|---|---|
| Tecla sem modificador | `dead_acute`; mantém `'` + `c` → `ç` e `'` + `Shift` + `c` → `Ç` |
| `Shift` + tecla de aspas | Insere imediatamente `"` literal; seguido de `e`, deve resultar em `"e`, nunca `ë` |
| `AltGr` + tecla sem `Shift` | Ativa `dead_diaeresis`; a letra seguinte deve ser composta conforme a tabela Compose (por exemplo, `a` → `ä`, `e` → `ë`, `i` → `ï`, `o` → `ö`, `u` → `ü`, `y` → `ÿ`) |
| `AltGr` + `Shift` + tecla de aspas | Também ativa `dead_diaeresis`; deve produzir as mesmas composições para letras maiúsculas e minúsculas suportadas, como `A` → `Ä` e `E` → `Ë` |
| Duas pressões de `Shift` + tecla de aspas | Emite `""` literalmente |

A combinação de `AltGr` com a tecla de aspas será o acesso intencional ao trema. Neste plano, `AltGr` corresponde normalmente à tecla Alt direita. Se ela estiver configurada como tecla Compose ou tiver outra função no KDE, revise essa opção antes de continuar.

### 5.1. Criar o arquivo de símbolos do usuário

Faça backup do arquivo de configuração do KDE antes de mudar o layout:

```bash
mkdir -p ~/.config/keyboard-layout-fix/backups
if [ -f ~/.config/kxkbrc ]; then
  cp -a ~/.config/kxkbrc \
    ~/.config/keyboard-layout-fix/backups/kxkbrc.$(date +%F-%H%M%S).bak
fi

mkdir -p ~/.config/xkb/symbols
```

Crie `~/.config/xkb/symbols/us_custom` com este conteúdo:

```text
default partial alphanumeric_keys

xkb_symbols "basic" {
    include "us(intl)"

    name[Group1] = "US International (aspas literais; trema via AltGr)";

    // Level 1: dead acute; Level 2 (Shift): aspas literais;
    // Levels 3/4 (AltGr): dead diaeresis.
    key <AC11> {
        type[Group1] = "FOUR_LEVEL",
        [ dead_acute, quotedbl, dead_diaeresis, dead_diaeresis ]
    };

    // Faz AltGr (normalmente Alt direito) selecionar o nível 3.
    include "level3(ralt_switch)"
};
```

`<AC11>` é a tecla de apóstrofo/aspas no mapa US padrão. O arquivo começa a partir de `us(intl)` para preservar o restante do layout e altera apenas essa tecla. Se seu teclado físico não corresponder ao mapa US padrão, valide a tecla antes de aplicar.

### 5.2. Testar a compilação antes de ativar

Se `xkbcli` estiver instalado, rode:

```bash
xkbcli compile-keymap \
  --include "$HOME/.config/xkb" \
  --include-defaults \
  --test \
  --layout us_custom \
  --variant basic
```

Só prossiga se a compilação for concluída sem erros. Se `xkbcli` não estiver disponível, não instale nem altere nada às cegas: confira a disponibilidade do pacote de ferramentas `libxkbcommon` da sua distribuição ou peça uma revisão do arquivo antes de ativá-lo. Um mapa XKB inválido pode impedir a digitação correta até a configuração ser revertida.

### 5.3. Ativar o layout no KDE Plasma Wayland

O KDE Plasma Wayland pode carregar um mapa XKB personalizado a partir dos caminhos do usuário e de `~/.config/kxkbrc`. Edite o arquivo existente:

```bash
kate ~/.config/kxkbrc
```

Na seção `[Layout]`, ajuste o layout e a variante para usar o arquivo acima:

```ini
LayoutList=us_custom
VariantList=basic
Use=true
```

**Não substitua o arquivo `kxkbrc` inteiro.** Preserve `Model`, `Options`, `SwitchMode` e outras configurações que já existam; altere somente `LayoutList` e `VariantList` para corresponder ao layout personalizado, mantendo a contagem de entradas coerente se houver mais de um layout configurado. Se você usa múltiplos layouts, não remova os demais sem decidir conscientemente como deseja alternar entre eles.

Salve e encerre a sessão do KDE; depois entre novamente. Se o KDE voltar a selecionar o layout antigo, consulte as configurações de teclado antes de repetir o processo. O layout personalizado pode não aparecer como opção normal no seletor gráfico, mesmo quando foi carregado pelo arquivo de configuração.

### 5.4. Garantir a composição de trema para as letras comuns

A regra XKB não deve ser específica para `e`: ela apenas emite o símbolo `dead_diaeresis` quando você usa `AltGr`. A letra composta é determinada pela tabela Compose. Portanto, a intenção é que funcione para todas as sequências de trema disponíveis nessa tabela, não apenas para `ë`.

Como a tabela carregada por `include "%L"` pode variar conforme o locale, acrescente as regras abaixo ao `~/.XCompose`, **depois da linha `include "%L"` e mantendo todas as regras personalizadas que já existem**. Elas garantem as vogais latinas comuns, o `y` e as formas maiúsculas:

```text
<dead_diaeresis> <a> : "ä" adiaeresis
<dead_diaeresis> <A> : "Ä" Adiaeresis
<dead_diaeresis> <e> : "ë" ediaeresis
<dead_diaeresis> <E> : "Ë" Ediaeresis
<dead_diaeresis> <i> : "ï" idiaeresis
<dead_diaeresis> <I> : "Ï" Idiaeresis
<dead_diaeresis> <o> : "ö" odiaeresis
<dead_diaeresis> <O> : "Ö" Odiaeresis
<dead_diaeresis> <u> : "ü" udiaeresis
<dead_diaeresis> <U> : "Ü" Udiaeresis
<dead_diaeresis> <y> : "ÿ" ydiaeresis
<dead_diaeresis> <Y> : "Ÿ" U0178
```

Mantenha também a regra já existente para duas teclas mortas consecutivas:

```text
<dead_diaeresis> <dead_diaeresis> : "\"\""
```

Não substitua seu arquivo inteiro por esses trechos; integre-os ao conteúdo existente. `include "%L"` continua disponível para outras composições definidas pela tabela do sistema. Se você precisar de letras menos comuns com trema ou de outros sinais combinados, teste se a tabela do locale já as oferece e acrescente regras explícitas somente para as sequências ausentes.

### 5.5. Validar a composição

Teste em um campo de texto simples e depois nos aplicativos:

| Entrada | Resultado esperado |
|---|---|
| Tecla `'` e depois `c` | `ç` |
| Tecla `'` e depois `Shift` + `c` | `Ç` |
| `Shift` + tecla de aspas e depois qualquer letra | Aspas literais seguidas da letra, por exemplo, `"e` |
| `AltGr` + tecla de aspas e depois `a`, `e`, `i`, `o`, `u` ou `y` | `ä`, `ë`, `ï`, `ö`, `ü` ou `ÿ` |
| `AltGr` + tecla de aspas e depois `Shift` + essas letras | `Ä`, `Ë`, `Ï`, `Ö`, `Ü` ou `Ÿ` |
| `Shift` + tecla de aspas duas vezes | `""` |
| `AltGr` + tecla de aspas duas vezes | `""`, conforme a regra existente de `~/.XCompose` |

O mapa XKB personaliza a saída das teclas para o sistema e não depende de editar arquivos internos do Brave, Discord ou VS Code. A tabela Compose determina as letras compostas. Ainda assim, um aplicativo pode ter limitações próprias no processamento de teclas mortas: se as aspas literais funcionarem, mas alguma composição com `AltGr` falhar, siga a etapa de diagnóstico por aplicativo abaixo.

---

## 6. Etapa 3 — Testar XWayland manualmente

**Feche cada aplicativo completamente**, inclusive pela bandeja do sistema. Iniciar um segundo comando quando já existe uma instância aberta pode apenas reutilizar a instância antiga e não aplicar a nova flag.

Abra cada aplicativo separadamente pelo terminal, usando o nome de comando encontrado na etapa anterior. Exemplos comuns:

```bash
brave --ozone-platform=x11
```

```bash
discord --ozone-platform=x11
```

```bash
code --ozone-platform=x11
```

Se o comando instalado tiver outro nome, use o caminho retornado por `command -v`. Não execute os três ao mesmo tempo: teste um, feche-o, e então passe ao seguinte.

Em cada aplicativo, valide:

| Teste | Resultado esperado |
|---|---|
| `'` seguido de `c` | `ç` |
| `'` seguido de `Shift` + `c` | `Ç` |
| Duas pressões de `'` | `''` |
| Duas pressões de `"` | `""` |
| Duas pressões de `~` | `~~` |
| Duas pressões de `^` | `^^` |

### Interpretação

- **Se a flag corrigir o aplicativo:** prossiga para a etapa 4 somente para esse aplicativo.
- **Se não corrigir:** não torne a flag permanente nele. Remova a flag do teste e investigue versão, método de entrada e backend separadamente.
- **Se apenas parte dos aplicativos falhar:** force XWayland somente nos que realmente precisarem.

A opção `--ozone-platform=x11` faz o aplicativo usar o backend X11. Em uma sessão KDE Wayland, ele normalmente é executado pela camada XWayland. Isso é um contorno de compatibilidade, não uma correção do código interno do Chromium/Electron.

## 7. Etapa 4 — Tornar a alteração persistente sem editar arquivos gerenciados pelo pacote

### Por que usar um `.desktop` local

**Não edite o arquivo original em `/usr/share/applications/`**: o gerenciador de pacotes pode substituí-lo em uma atualização.

O KDE e os ambientes compatíveis com XDG dão preferência ao atalho do usuário, localizado em `~/.local/share/applications/`, quando ele tem o mesmo nome-base do atalho de sistema. O gerenciador de pacotes não gerencia esse arquivo no diretório pessoal, então ele não sobrescreve diretamente a personalização.

### 6.1 Localize o nome correto do arquivo

Use os resultados do `find` da etapa 1. Exemplos frequentes são `brave-browser.desktop`, `discord.desktop` e `code.desktop`, mas **não presuma esses nomes**: utilize os arquivos que realmente existem no seu sistema.

Antes de criar uma cópia, veja se já existe um atalho local com o mesmo nome:

```bash
ls -l ~/.local/share/applications/
```

Se já existir um arquivo personalizado, faça uma cópia de segurança antes de alterá-lo:

```bash
mkdir -p ~/.config/keyboard-layout-fix/backups
cp ~/.local/share/applications/NOME.desktop \
  ~/.config/keyboard-layout-fix/backups/NOME.desktop.$(date +%F-%H%M%S).bak
```

Substitua `NOME.desktop` pelo nome real. Se ainda não houver atalho local, copie o arquivo original correspondente. Exemplo — ajuste o nome de acordo com a etapa anterior:

```bash
mkdir -p ~/.local/share/applications
cp /usr/share/applications/NOME.desktop \
  ~/.local/share/applications/NOME.desktop
```

### 6.2 Edite a cópia local

Abra a cópia em `~/.local/share/applications/` com um editor de texto. **Acrescente `--ozone-platform=x11` a todas as linhas `Exec=` que iniciem o aplicativo**, preservando os demais argumentos e os códigos de arquivo/URL como `%U`, `%u`, `%F` ou `%f`.

Exemplos de transformação:

```ini
# Antes
Exec=brave %U

# Depois
Exec=brave --ozone-platform=x11 %U
```

```ini
# Antes
Exec=/usr/bin/discord %U

# Depois
Exec=/usr/bin/discord --ozone-platform=x11 %U
```

```ini
# Antes
Exec=/usr/bin/code --new-window %F

# Depois
Exec=/usr/bin/code --ozone-platform=x11 --new-window %F
```

Os exemplos são ilustrativos. Preserve exatamente o executável, os argumentos e os campos de substituição do arquivo instalado no seu sistema. Alguns atalhos têm várias linhas `Exec=` para abrir uma janela, modo privado, arquivos ou URLs. Se essas ações também forem usadas, ajuste cada linha que inicia diretamente o aplicativo.

**Não altere o arquivo em `/usr/share/applications/` e não faça um `sed` genérico nele.** A alteração deve ocorrer somente na cópia local, após confirmar o conteúdo real.

Se o KDE não reconhecer o atalho atualizado de imediato, execute:

```bash
update-desktop-database ~/.local/share/applications
```

Se o comando não estiver instalado, feche e reabra o menu de aplicativos ou encerre e inicie a sessão KDE.

### Limite desta persistência

Esse método impede que uma atualização do pacote sobrescreva diretamente o atalho local. Entretanto, como a cópia local é independente do arquivo do pacote, novas alterações de metadados ou de ações introduzidas pelo fornecedor não são mescladas automaticamente. Após uma grande atualização, compare o arquivo local com o original e incorpore manualmente mudanças úteis, preservando a flag.

## 8. Etapa 5 — Conferir atalhos de inicialização automática

Se algum aplicativo for aberto automaticamente ao iniciar a sessão, a inicialização pode usar um arquivo separado em `~/.config/autostart/` e ignorar o atalho ajustado no menu.

Confira:

```bash
grep -RInE '^Exec=.*(brave|discord|code)' ~/.config/autostart 2>/dev/null
```

Se houver um arquivo relevante, verifique seu conteúdo e faça backup antes de editá-lo. Para o Discord, é preferível desativar a inicialização automática nas configurações do próprio aplicativo e configurar uma única entrada de inicialização própria, caso necessário, em vez de manter duas entradas que iniciem o programa.

## 9. Etapa 6 — Verificar o backend depois da mudança

Feche todas as instâncias e abra o programa a partir do menu do KDE. Em seguida, consulte os processos:

```bash
ps -eo pid,args | grep -E '[b]rave|[D]iscord|[c]ode' | grep -E -- '--ozone-platform=(x11|wayland)|--ozone-platform-hint'
```

Esse comando é uma pista, não uma prova isolada para todas as versões. No Brave, `brave://version` também mostra a linha de comando efetiva. Teste os caracteres no campo de texto novamente; o resultado real de digitação é o critério definitivo.

Lembre-se: iniciar manualmente `brave`, `discord` ou `code` pelo terminal sem a flag pode continuar abrindo o aplicativo com o backend padrão. A alteração do `.desktop` afeta o lançamento pelo atalho que foi personalizado, não todas as formas possíveis de iniciar o programa.

## 10. Manutenção após futuras atualizações

Depois de atualizações relevantes do Brave, Discord ou VS Code:

1. Teste `ç`, `Ç`, `''`, `""`, `~~` e `^^` nos aplicativos afetados.
2. Teste também `Shift` + tecla de aspas seguido de várias letras (`"a`, `"e`, `"i`, `"o`, `"u`) e `AltGr` + tecla de aspas seguido de `a`, `e`, `i`, `o`, `u`, `y`, incluindo as formas maiúsculas.
3. Se algum aplicativo voltar a falhar, confira se ainda está sendo iniciado com `--ozone-platform=x11`.
4. Confirme que o arquivo local em `~/.local/share/applications/` continua existindo.
5. Compare o atalho local com o novo atalho do pacote e incorpore manualmente eventuais mudanças úteis sem perder a flag.
6. Não remova atualizações nem congele pacotes como método de persistência.

A personalização do usuário não é apagada diretamente pelo gerenciador de pacotes, mas nenhuma configuração pode garantir compatibilidade eterna se um aplicativo mudar o mecanismo de entrada ou deixar de aceitar a opção de inicialização. Por isso, a validação após uma grande atualização continua necessária.

## 11. Reversão

Para reverter um aplicativo, feche-o e remova **somente o atalho local correspondente**. Por exemplo:

```bash
rm ~/.local/share/applications/NOME.desktop
```

Substitua `NOME.desktop` pelo arquivo criado para aquele aplicativo. O KDE voltará a usar o atalho de sistema. Isso não remove o aplicativo nem modifica `~/.XCompose`.

Se você tinha um atalho local anterior, restaure o backup em vez de removê-lo.

Para reverter também o layout XKB personalizado:

1. Abra `~/.config/kxkbrc` e restaure os valores anteriores de `LayoutList` e `VariantList` (ou restaure o backup de `kxkbrc` criado na etapa 5.1).
2. Remova apenas o arquivo personalizado `~/.config/xkb/symbols/us_custom`.
3. Encerre e inicie novamente a sessão KDE.

Se o layout impedir a digitação na sessão gráfica, entre em um TTY com `Ctrl` + `Alt` + `F3`, faça login e restaure o backup de `kxkbrc` a partir do terminal antes de voltar à sessão gráfica. Não remova nem edite arquivos em `/usr/share/X11/xkb/`.

## 12. Critérios de conclusão

Considere o plano concluído quando:

- `~/.XCompose`, o locale e o layout XKB personalizado continuam corretos;
- `Shift` + tecla de aspas gera `"` literal, e o trema é acionado somente com `AltGr` para as letras e sequências Compose previstas;
- os caracteres esperados funcionam nos aplicativos testados;
- somente os aplicativos que precisarem usam XWayland;
- iniciar pelo menu do KDE mantém a flag depois de sair e entrar na sessão;
- os atalhos personalizados ficam em `~/.local/share/applications/`, e não em arquivos do pacote;
- o layout XKB está em `~/.config/xkb/`, sem modificações em `/usr/share/X11/xkb/`;
- a reversão está documentada e os backups foram preservados.

## Referências técnicas

- KDE Plasma Wayland — mapas XKB personalizados no escopo do usuário: https://community.kde.org/Plasma/Wayland
- libxkbcommon — configuração XKB personalizada, localização dos arquivos e teste: https://xkbcommon.org/doc/current/custom-configuration.html
- libxkbcommon — suporte a Compose e teclas mortas: https://xkbcommon.org/doc/current/group__compose.html
- ArchWiki — personalização de arquivos `.desktop` sem alterar os arquivos de sistema: https://wiki.archlinux.org/title/Desktop_entries
- Relato do Electron sobre teclas mortas e `.XCompose` em Wayland: https://github.com/electron/electron/issues/46823
- Relato do Chromium sobre sequências Compose em Wayland e contorno por XWayland: https://issues.chromium.org/issues/455147428
- Documentação do Brave sobre flags de linha de comando: https://support.brave.com/hc/en-us/articles/360044860011-How-Do-I-Use-Command-Line-Flags-in-Brave
- Documentação do Electron sobre `--ozone-platform=x11`: https://www.electronjs.org/docs/latest/api/environment-variables
