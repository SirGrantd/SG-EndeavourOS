# Guia Definitivo: Cedilha (`ç`) no Teclado US-International com Linux em Inglês

Quando o sistema operacional está configurado com o idioma em inglês (`en_US.UTF-8`), o atalho de teclado morto `'` + `c` resulta por padrão em **`ć`** (C com acento agudo), seguindo o padrão tipográfico internacional.

A solução definitiva e resistente a atualizações consiste em **desacoplar o idioma da interface visual do mapa de caracteres**, mantendo o sistema em inglês (`LANG=en_US.UTF-8`) e direcionando apenas a composição de caracteres para o Brasil (`LC_CTYPE=pt_BR.UTF-8`).

---

## Pré-requisito: Gerar o Locale `pt_BR.UTF-8`

Antes de aplicar a configuração, certifique-se de que o sistema possui os pacotes de localização do Brasil compilados:

### No Ubuntu, Debian e derivados

```bash
sudo locale-gen pt_BR.UTF-8
sudo update-locale

```

### No Fedora, RHEL e derivados

```bash
sudo dnf install glibc-langpack-pt

```

### No Arch Linux

1. Abra o arquivo de locales:
```bash
sudo nano /etc/locale.gen

```


2. Descomente a linha `pt_BR.UTF-8 UTF-8` (remova o `#`).
3. Salve com `Ctrl + O`, saia com `Ctrl + X` e execute:
```bash
sudo locale-gen

```



---

## Método 1: Via Interface Gráfica (Recomendado)

Nas interfaces modernas (GNOME e KDE Plasma), você pode aplicar a separação de variáveis diretamente nas configurações do sistema sem precisar de terminal.

### No GNOME (Ubuntu, Fedora, Pop!_OS)

1. Abra **Settings (Configurações)** $\to$ **System** $\to$ **Region & Language**.
2. Deixe o campo **Language** como `English (United States)`.
3. Altere o campo **Formats** para `Brazil (Português)`.
4. Clique no botão de logout/reiniciar sessão sugerido pela interface.

### No KDE Plasma

1. Abra **System Settings** $\to$ **Regional Settings** $\to$ **Formats**.
2. Mantenha o idioma principal em inglês.
3. No campo de formatos regionais, selecione `Brasil - Português (pt_BR)`.
4. Clique em **Apply** e reinicie a sessão.

---

## Método 2: Via Terminal (Nível de Sistema, Persistente a Atualizações)

Esta configuração atua diretamente nos arquivos lidos pelo `systemd` e pelo gerenciador de login durante a inicialização, garantindo funcionamento em Wayland, X11, navegadores, jogos e contêineres Flatpak.

### No Fedora, Arch Linux, CentOS e openSUSE

Edite o arquivo `/etc/locale.conf`:

```bash
sudo nano /etc/locale.conf

```

Mantenha o conteúdo exatamente assim:

```text
LANG=en_US.UTF-8
LC_CTYPE=pt_BR.UTF-8

```

### No Ubuntu, Debian e Pop!_OS

Edite o arquivo `/etc/default/locale`:

```bash
sudo nano /etc/default/locale

```

Adicione ou ajuste a linha do `LC_CTYPE`:

```text
LANG=en_US.UTF-8
LC_CTYPE=pt_BR.UTF-8

```

---

## Método 3: Fallback por Usuário via `~/.XCompose`

Caso você não tenha permissão de administrador (`sudo`) na máquina ou use uma distribuição minimalista/Window Manager puro (i3, bspwm, Sway), use o arquivo de Compose na sua pasta pessoal. Ele fica isolado na sua `$HOME` e **nunca é apagado por atualizações de pacotes**.

1. Crie o arquivo `~/.XCompose`:
```bash
nano ~/.XCompose

```


2. Cole as seguintes regras de sobrescrita:
```text
include "%L"

<dead_acute> <c> : "ç" Ccedilla
<dead_acute> <C> : "Ç" Ccedilla

```


3. Salve com `Ctrl + O` e feche com `Ctrl + X`.

---

## Validação

Após alterar as configurações, encerre a sessão do usuário (Logout) e faça login novamente (ou reinicie o computador).

Abra o terminal e execute:

```bash
locale

```

Verifique se a variável `LC_CTYPE` está apontando para o Brasil:

```text
LANG=en_US.UTF-8
LC_CTYPE="pt_BR.UTF-8"
...

```

Pressione `'` seguido de `c` em qualquer aplicativo (terminal, navegador ou editor de texto); o caractere gerado será **`ç`**.

---

# Solução Definitiva: Cedilha (`ç`) no Layout US-International com Linux em Inglês

Este guia documenta o método moderno e definitivo para obter o comportamento padrão de teclas mortas (`' + c = ç`) no Linux ao utilizar o layout **US-International with dead keys** com o sistema operacional configurado no idioma inglês (`en_US`), sem recorrer a gambiarras que quebram em atualizações de pacotes ou sessões Wayland.

---

## 1. O Diagnóstico Técnico

No Linux, o layout US-International emite o sinal de acento agudo morto (`dead_acute`) ao pressionar a tecla `'`. A combinação do caractere seguinte é processada pela tabela de composição (**Compose**) atrelada ao locale do sistema:

* Em sistemas configurados como **Português (`pt_BR`)**, a regra de composição padrão é `' + c = ç`.
* Em sistemas configurados como **Inglês (`en_US`)**, a regra estrita do Unicode interpreta acento agudo sobre $C$ como a letra eslava **C com agudo (`ć`)**.

### Por que as soluções antigas falham:

| Método Antigo | Problema Técnico |
| --- | --- |
| **Editar `/usr/share/X11/locale/...**` | É sobrescrito silenciosamente a cada atualização do pacote `libx11-data`. |
| **`GTK_IM_MODULE=cedilla`** | Obsoleto no GTK4/libadwaita; falha em Wayland puro e é ignorado por Flatpaks e Snaps. |
| **Scripts no `.bashrc**` | Aplicam variáveis apenas a shells interativos, não a aplicativos gráficos iniciados via systemd/desktop. |

A solução correta consiste em manter o idioma visual da interface em inglês (`LANG=en_US.UTF-8`), mas instruir o subsistema de caracteres a adotar as regras tipográficas brasileiras através da variável **`LC_CTYPE=pt_BR.UTF-8`**.

---

## 2. Método 1: Via Interface Gráfica (Sem Terminal)

Os ambientes de desktop modernos (GNOME e KDE Plasma) permitem desacoplar a língua da interface dos formatos regionais diretamente pelo painel de controle.

### No GNOME (Ubuntu, Fedora, Debian)

1. Abra as **Configurações** (*Settings*) $\to$ **Região e Idioma** (*Region & Language*).
2. Deixe o campo **Idioma** (*Language*) como `English (United States)`.
3. Altere o campo **Formatos** (*Formats*) para `Brasil (Português)`.
4. Encerre a sessão do usuário (*Log out*) e entre novamente.

### No KDE Plasma

1. Abra as **Configurações do Sistema** (*System Settings*) $\to$ **Regional Settings**.
2. Em **Language**, mantenha `American English` no topo.
3. Na aba **Formats**, marque a região como `Brasil - português (pt_BR)`.
4. Reinicie a sessão gráfica.

---

## 3. Método 2: Configuração Global Persistente (Via Terminal)

Para instalações de servidor, ambientes mínimos, window managers (i3, bspwm) ou compositores Wayland (Sway, Hyprland), configure o locale na raiz do sistema. Arquivos sob `/etc/` **nunca são sobrescritos** por atualizações de gerenciadores de pacotes (`apt`, `dnf`, `pacman`).

### Passo 1: Garantir que o locale brasileiro está gerado

Verifique se o locale `pt_BR.UTF-8` está presente no sistema:

```bash
locale -a | grep pt_BR

```

Se não retornar nada, gere o locale:

* **No Debian / Ubuntu:**
```bash
sudo locale-gen pt_BR.UTF-8
sudo update-locale

```


* **No Arch Linux / Fedora:**
Descomente a linha `pt_BR.UTF-8 UTF-8` no arquivo `/etc/locale.gen` e execute:
```bash
sudo locale-gen

```



### Passo 2: Configurar o desacoplamento de `LC_CTYPE`

Edite o arquivo de configuração de locale da sua distribuição:

* **Arch Linux, Fedora, RHEL e derivados systemd:**
Edite o arquivo `/etc/locale.conf`:
```ini
LANG=en_US.UTF-8
LC_CTYPE=pt_BR.UTF-8

```


* **Debian, Ubuntu e derivados:**
Edite o arquivo `/etc/default/locale`:
```ini
LANG=en_US.UTF-8
LC_CTYPE=pt_BR.UTF-8

```



---

## 4. Método 3: Fallback em Espaço de Usuário (`~/.XCompose`)

Se você não possui privilégios de superusuário (`sudo`) na máquina, pode definir a regra exclusivamente na sua pasta de usuário. Gerenciadores de pacotes nunca alteram o conteúdo da pasta `$HOME`.

Crie ou edite o arquivo `~/.XCompose`:

```text
include "%L"

<dead_acute> <c> : "ç" Ccedilla
<dead_acute> <C> : "Ç" Ccedilla

```

Para garantir que a biblioteca `libxkbcommon` (usada no Wayland) e aplicações X11 leiam o arquivo, adicione a variável ao seu ambiente de usuário em `~/.pam_environment` ou `~/.config/environment.d/envvars.conf`:

```ini
XCOMPOSEFILE=%h/.XCompose

```

---

## 5. Verificação e Testes

Após reiniciar a sessão ou o computador:

1. Abra um terminal e execute o comando:
```bash
locale

```


O resultado esperado deve mostrar `LANG=en_US.UTF-8` e `LC_CTYPE=pt_BR.UTF-8`.
2. Teste a digitação em três ambientes distintos para validar a compatibilidade:
* **Terminal nativo:** Pressione `'` seguido de `c` $\to$ deve gerar `ç`.
* **Navegador web (Chromium/Firefox):** Pressione `'` seguido de `Shift + c` $\to$ deve gerar `Ç`.
* **Aplicativo Flatpak ou Snap (Discord, Slack ou VS Code):** Teste a mesma combinação para confirmar que a variável de sessão foi herdada pelo contêiner.
