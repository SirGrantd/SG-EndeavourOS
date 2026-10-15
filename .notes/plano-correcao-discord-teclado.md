# Plano de correção: cedilha, aspas e teclas mortas no Discord

## 1. Objetivo

Corrigir a composição de caracteres no Discord sem alterar novamente a configuração geral do teclado, que já funciona no restante do sistema. A primeira tentativa será executar o Discord pelo XWayland. Essa mudança será mantida **somente se o teste comprovar que resolve o problema**.

## 2. Ambiente considerado

- **Distribuição:** EndeavourOS, baseada no Arch Linux e com atualizações contínuas (*rolling release*).
- **Ambiente gráfico:** KDE Plasma.
- **Sessão:** Wayland (`XDG_SESSION_TYPE=wayland`).
- **Layout:** US International com teclas mortas.
- **Compose:** `~/.XCompose`; segundo o diagnóstico fornecido, funciona no Brave e nos jogos testados.
- **Discord instalado:** pacote `discord` gerenciado por `pacman`.
- **Dados registrados no diagnóstico:** pacote `discord 1:1.0.159-1`, binário de aplicativo em `~/.config/discord/app-1.0.161/Discord`, Electron `42.11.10` e processo iniciado com `--ozone-platform=wayland`.

> **Nota sobre versões:** o relatório registra versões diferentes para o pacote e para o aplicativo iniciado. Isso não prova, por si só, que exista um defeito, mas vale conferir a versão instalada antes dos testes. O repositório oficial do Arch lista o pacote `discord 1:1.0.161-1` no momento desta verificação. Consulte a versão local com `pacman -Q discord` e evite atualizações parciais em uma distribuição rolling release.

## 3. Hipótese de trabalho

O Discord parece ser o único aplicativo testado que não respeita a composição de teclas esperada na sessão Wayland. Uma hipótese verificável é uma incompatibilidade entre a versão do Electron/Chromium usada pelo Discord e o caminho de entrada do Wayland.

Isso ainda **não é uma causa raiz comprovada**. Forçar XWayland é um teste de isolamento: se os caracteres funcionarem nesse modo, fica mais provável que o problema esteja relacionado ao caminho Wayland do aplicativo. O XWayland não garante a correção em todos os cenários, portanto o resultado precisa ser testado.

## 4. Etapa A — Verificar pacote e comando usados

Execute estes comandos sem alterar a configuração:

```bash
pacman -Q discord
pacman -Qo /usr/bin/discord
printf 'Sessão gráfica: %s\n' "$XDG_SESSION_TYPE"
```

Confirme também se o Discord está realmente sendo iniciado com Wayland:

```bash
ps -eo pid,args | grep -E '[D]iscord.*--ozone-platform=(wayland|x11)'
```

Se o pacote ainda estiver na versão `1:1.0.159-1`, verifique as atualizações disponíveis. Em Arch/EndeavourOS, atualize o sistema de forma completa (`sudo pacman -Syu`), não apenas um pacote isolado, e depois repita o teste. Se o pacote já estiver atualizado, prossiga.

## 5. Etapa B — Testar XWayland temporariamente

### 5.1 Fechar todas as instâncias

Encerre o Discord pela opção **Sair/Quit** do próprio aplicativo, inclusive pela bandeja do sistema. Depois confirme que não ficou um processo antigo em execução:

```bash
pgrep -af 'Discord|discord'
```

Se ainda houver uma instância aberta, encerre-a antes de continuar. Não inicie a nova sessão sobre uma instância existente, pois o processo antigo pode reutilizá-la e invalidar o teste.

### 5.2 Abrir explicitamente pelo backend X11

Execute:

```bash
/usr/bin/discord --ozone-platform=x11
```

O comando é apenas um teste; não modifica arquivos de configuração. Na sessão KDE Wayland, o backend X11 normalmente é fornecido pelo XWayland.

### 5.3 Confirmar o modo e testar os caracteres

Confira os argumentos do processo:

```bash
ps -eo pid,args | grep -E '[D]iscord.*--ozone-platform=(x11|wayland)'
```

Confirme que a instância de teste está usando `--ozone-platform=x11`. Depois teste **na caixa de mensagem do Discord**:

| Sequência | Resultado esperado |
|---|---|
| `'` e depois `c` | `ç` |
| `'` e depois `Shift` + `c` | `Ç` |
| Duas pressões consecutivas da tecla morta de apóstrofo | `''` |
| Duas pressões consecutivas da tecla morta de trema/aspas, conforme o layout | `""` |
| Demais combinações de teclas mortas usadas no dia a dia | O mesmo resultado esperado nos outros aplicativos |

Registre também se a digitação normal, atalhos, voz e compartilhamento de tela continuam adequados. O XWayland pode ter diferenças funcionais em relação ao Wayland nativo.

## 6. Etapa C — Tornar permanente somente se o teste funcionar

### Opção recomendada: atalho local do KDE

O caminho mais reversível é criar uma cópia do atalho do Discord no perfil do usuário. Antes de copiar, verifique se já existe uma personalização local:

```bash
ls -l ~/.local/share/applications/discord.desktop
```

Se já existir, faça uma cópia de segurança antes de editá-lo. Em seguida:

```bash
mkdir -p ~/.local/share/applications
cp /usr/share/applications/discord.desktop \
   ~/.local/share/applications/discord.desktop
kate ~/.local/share/applications/discord.desktop
```

Na cópia aberta no Kate, localize a linha `Exec=` e acrescente `--ozone-platform=x11` logo depois de `/usr/bin/discord`, preservando todos os argumentos que já existirem.

Por exemplo, transforme:

```ini
Exec=/usr/bin/discord %U
```

em:

```ini
Exec=/usr/bin/discord --ozone-platform=x11 %U
```

A linha real pode ter outros argumentos. Não substitua a linha inteira por este exemplo se ela for diferente. Salve o arquivo e inicie o Discord pelo lançador do KDE. Verifique novamente o processo e repita os testes de caracteres.

### Sobre `~/.config/discord-flags.conf`

**Não use esse arquivo como método principal sem confirmar que o launcher instalado o lê.** O suporte a `discord-flags.conf` é documentado pelo pacote AUR `discord_arch_electron`, que é diferente do pacote oficial `discord` instalado pelo `pacman`. O cliente oficial também não usa simplesmente as flags globais do Electron (`electron-flags.conf`). Para a instalação descrita neste documento, o atalho local torna a passagem da flag explícita e verificável.

## 7. Reversão

Se XWayland não corrigir a digitação, ou se provocar outros problemas:

1. Feche o Discord.
2. Remova `--ozone-platform=x11` do `Exec=` do atalho local ou remova o atalho local para voltar ao do sistema:
   ```bash
   rm ~/.local/share/applications/discord.desktop
   ```
   **Atenção:** execute o `rm` apenas se esse arquivo tiver sido criado para este teste e você não precisar preservar personalizações anteriores.
3. Inicie normalmente o Discord e confirme que voltou ao comportamento original.

Não modifique o `~/.XCompose`, o locale ou as variáveis globais do sistema como parte desta investigação: eles já funcionam nos outros aplicativos e não precisam ser alterados para testar o Discord.

## 8. Se XWayland não resolver

Se os caracteres continuarem errados:

1. Confirme que o processo realmente está usando `--ozone-platform=x11`.
2. Confirme a versão local do pacote (`pacman -Q discord`) e, se estiver desatualizada, atualize o sistema por completo antes de repetir o teste.
3. Teste o Discord Web no Brave, onde o teclado já funciona, para verificar se o problema é específico do aplicativo instalado.
4. Se o problema existir apenas no cliente instalado, mantenha o modo original até haver um diagnóstico mais específico; não adicione flags aleatórias nem altere os arquivos globais de teclado.

## 9. Critério de conclusão

A correção só deve ser considerada concluída quando:

- `' + c` produz `ç` e `' + Shift + c` produz `Ç` no campo de mensagem;
- as teclas mortas repetidas geram os caracteres literais desejados (`''`, `""`, `~~` e `^^`), conforme a configuração atual;
- a instância aberta pelo lançador do KDE usa o backend testado;
- o funcionamento permanece correto depois de fechar e abrir o Discord novamente.

Se XWayland não resolver, o resultado é útil: ele descarta essa hipótese simples e evita manter uma mudança que não trouxe benefício.

## Referências

- Arch Linux — arquivos do pacote oficial Discord: https://archlinux.org/packages/extra/x86_64/discord/files/
- ArchWiki — Discord (inclui notas sobre Electron, Wayland e diferenças entre o pacote oficial e `discord_arch_electron`): https://wiki.archlinux.org/title/Discord
- AUR — `discord_arch_electron` (documenta especificamente o suporte a `discord-flags.conf` nesse pacote): https://aur.archlinux.org/packages/discord_arch_electron
- libxkbcommon — Compose e teclas mortas: https://xkbcommon.org/doc/current/group__compose.html
