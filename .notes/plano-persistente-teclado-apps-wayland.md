# Plano de correção persistente do teclado no Brave, Discord e VS Code

## 1. Objetivo e ambiente considerado

Este plano considera o seguinte ambiente, conforme o diagnóstico anterior:

- **Distribuição:** EndeavourOS, baseada no Arch Linux.
- **Desktop:** KDE Plasma.
- **Sessão:** Wayland.
- **Teclado:** `us(intl)` — US International com teclas mortas.
- **Locale:** `pt_BR.UTF-8`.
- **Personalização:** `~/.XCompose`, incluindo `ç`/`Ç` e repetição de teclas mortas (`''`, `""`, `~~`, `^^`).
- **Aplicativos afetados:** Brave, Discord e Visual Studio Code.

O objetivo é recuperar a composição de caracteres e fazer com que os ajustes de inicialização **não sejam sobrescritos por atualizações dos pacotes**.

## 2. Diagnóstico: o que provavelmente aconteceu

Uma atualização do Brave, Discord ou VS Code **não deveria apagar o arquivo `~/.XCompose`**, pois ele fica no diretório pessoal do usuário. O que pode mudar durante uma atualização é a versão do Chromium/Electron ou a forma como o aplicativo é iniciado.

Há problemas documentados de composição de teclas no Chromium/Electron quando executados nativamente sobre Wayland. Em alguns casos, `~/.XCompose` funciona em outros aplicativos, mas as sequências são ignoradas ou interpretadas de forma diferente em um aplicativo Chromium/Wayland. Forçar o backend X11, através do XWayland, é uma alternativa conhecida para testar esse cenário.

**Importante:** o plano não presume que essa seja a causa antes dos testes. Se o problema estiver em outro ponto, forçar XWayland pode não resolver.

## 3. Estratégia recomendada

1. Confirmar que `~/.XCompose` e o locale continuam corretos.
2. Testar cada aplicativo manualmente com `--ozone-platform=x11`.
3. Aplicar a flag apenas nos aplicativos em que o teste funcionar.
4. Tornar a alteração persistente com arquivos `.desktop` locais em `~/.local/share/applications/`, sem editar os arquivos instalados em `/usr/share/applications/`.
5. Revalidar o comportamento após atualizações importantes.

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

## 5. Etapa 2 — Testar XWayland manualmente

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

- **Se a flag corrigir o aplicativo:** prossiga para a etapa 3 somente para esse aplicativo.
- **Se não corrigir:** não torne a flag permanente nele. Remova a flag do teste e investigue versão, método de entrada e backend separadamente.
- **Se apenas parte dos aplicativos falhar:** force XWayland somente nos que realmente precisarem.

A opção `--ozone-platform=x11` faz o aplicativo usar o backend X11. Em uma sessão KDE Wayland, ele normalmente é executado pela camada XWayland. Isso é um contorno de compatibilidade, não uma correção do código interno do Chromium/Electron.

## 6. Etapa 3 — Tornar a alteração persistente sem editar arquivos gerenciados pelo pacote

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

## 7. Etapa 4 — Conferir atalhos de inicialização automática

Se algum aplicativo for aberto automaticamente ao iniciar a sessão, a inicialização pode usar um arquivo separado em `~/.config/autostart/` e ignorar o atalho ajustado no menu.

Confira:

```bash
grep -RInE '^Exec=.*(brave|discord|code)' ~/.config/autostart 2>/dev/null
```

Se houver um arquivo relevante, verifique seu conteúdo e faça backup antes de editá-lo. Para o Discord, é preferível desativar a inicialização automática nas configurações do próprio aplicativo e configurar uma única entrada de inicialização própria, caso necessário, em vez de manter duas entradas que iniciem o programa.

## 8. Etapa 5 — Verificar o backend depois da mudança

Feche todas as instâncias e abra o programa a partir do menu do KDE. Em seguida, consulte os processos:

```bash
ps -eo pid,args | grep -E '[b]rave|[D]iscord|[c]ode' | grep -E -- '--ozone-platform=(x11|wayland)|--ozone-platform-hint'
```

Esse comando é uma pista, não uma prova isolada para todas as versões. No Brave, `brave://version` também mostra a linha de comando efetiva. Teste os caracteres no campo de texto novamente; o resultado real de digitação é o critério definitivo.

Lembre-se: iniciar manualmente `brave`, `discord` ou `code` pelo terminal sem a flag pode continuar abrindo o aplicativo com o backend padrão. A alteração do `.desktop` afeta o lançamento pelo atalho que foi personalizado, não todas as formas possíveis de iniciar o programa.

## 9. Manutenção após futuras atualizações

Depois de atualizações relevantes do Brave, Discord ou VS Code:

1. Teste `ç`, `Ç`, `''`, `""`, `~~` e `^^` nos aplicativos afetados.
2. Se algum deles voltar a falhar, confira se ainda está sendo iniciado com `--ozone-platform=x11`.
3. Confirme que o arquivo local em `~/.local/share/applications/` continua existindo.
4. Compare o atalho local com o novo atalho do pacote e incorpore manualmente eventuais mudanças úteis sem perder a flag.
5. Não remova atualizações nem congele pacotes como método de persistência.

A personalização do usuário não é apagada diretamente pelo gerenciador de pacotes, mas nenhuma configuração pode garantir compatibilidade eterna se um aplicativo mudar o mecanismo de entrada ou deixar de aceitar a opção de inicialização. Por isso, a validação após uma grande atualização continua necessária.

## 10. Reversão

Para reverter um aplicativo, feche-o e remova **somente o atalho local correspondente**. Por exemplo:

```bash
rm ~/.local/share/applications/NOME.desktop
```

Substitua `NOME.desktop` pelo arquivo criado para aquele aplicativo. O KDE voltará a usar o atalho de sistema. Isso não remove o aplicativo nem modifica `~/.XCompose`.

Se você tinha um atalho local anterior, restaure o backup em vez de removê-lo.

## 11. Critérios de conclusão

Considere o plano concluído quando:

- `~/.XCompose` e o locale continuam corretos;
- os caracteres esperados funcionam nos aplicativos testados;
- somente os aplicativos que precisarem usam XWayland;
- iniciar pelo menu do KDE mantém a flag depois de sair e entrar na sessão;
- os atalhos personalizados ficam em `~/.local/share/applications/`, e não em arquivos do pacote;
- a reversão está documentada e os backups foram preservados.

## Referências técnicas

- ArchWiki — personalização de arquivos `.desktop` sem alterar os arquivos de sistema: https://wiki.archlinux.org/title/Desktop_entries
- Relato do Electron sobre teclas mortas e `.XCompose` em Wayland: https://github.com/electron/electron/issues/46823
- Relato do Chromium sobre sequências Compose em Wayland e contorno por XWayland: https://issues.chromium.org/issues/455147428
- Documentação do Brave sobre flags de linha de comando: https://support.brave.com/hc/en-us/articles/360044860011-How-Do-I-Use-Command-Line-Flags-in-Brave
- Documentação do Electron sobre `--ozone-platform=x11`: https://www.electronjs.org/docs/latest/api/environment-variables
