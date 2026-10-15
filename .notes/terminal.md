Preparei um passo a passo em Markdown para configurar o Kitty + Zsh + Oh My Zsh + seleção de texto, no EndeavourOS com KDE Plasma.

# Guia de configuração: Kitty + Zsh

## 1. Instalar o Kitty

No terminal atual, execute:

```
sudo pacman -S --needed kitty zsh git curl
```

Abra o Kitty pelo menu de aplicativos do KDE e confirme:

```
kitty --version
zsh --version
```

## 2. Configurar o Zsh como shell padrão

```
chsh -s "$(which zsh)"
```

Encerre a sessão do KDE e entre novamente. Confirme:

```
echo $SHELL
```

O caminho deverá terminar em `/zsh`.

## 3. Instalar o Oh My Zsh

Execute:

```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

O Oh My Zsh cria uma configuração inicial em `~/.zshrc` e facilita a instalação de temas e plugins.&#x20;

[image](https://www.google.com/s2/favicons?domain=https://github.com\&sz=32)

GitHub



## 4. Configurar as abas do Kitty

Abra o arquivo de configuração:

```
mkdir -p ~/.config/kitty
nano ~/.config/kitty/kitty.conf
```

Adicione:

```
# Abas na parte superior
tab_bar_edge top
tab_bar_style powerline

# Abrir e fechar abas
map ctrl+shift+t new_tab
map ctrl+shift+q close_tab

# Navegar entre abas
map ctrl+shift+right next_tab
map ctrl+shift+left previous_tab

# Mover abas
map ctrl+shift+. move_tab_forward
map ctrl+shift+, move_tab_backward

# Dividir o terminal
map ctrl+shift+enter launch --location=vsplit
map ctrl+shift+n launch --location=hsplit
```

Salve com `Ctrl + O`, pressione Enter e saia com `Ctrl + X`.

O Kitty permite personalizar a posição da barra de abas e os atalhos pelo arquivo `kitty.conf`.&#x20;

[image](https://www.google.com/s2/favicons?domain=https://github.com\&sz=32)

GitHub

+1



## 5. Configurar o Zsh Edit-Select

Execute o instalador oficial:

```
bash <(curl -fsSL https://raw.githubusercontent.com/Michael-Matta1/zsh-edit-select/main/assets/auto-install/install.sh)
```

Escolha `1` para a instalação completa, conforme a tela que você mostrou anteriormente.

Depois, abra uma nova sessão do Kitty e teste:

- `Shift` + setas para selecionar caracteres.
- `Ctrl` + `Shift` + setas para selecionar palavras.

Se não funcionar, verifique a configuração do plugin antes de adicionar outros atalhos.

## 6. Personalizar o Oh My Zsh

Abra:

```
nano ~/.zshrc
```

Procure a variável `ZSH_THEME`. Um tema simples para começar é:

```
ZSH_THEME="robbyrussell"
```

Salve e recarregue:

```
source ~/.zshrc
```

## 7. Conferência final

- Kitty instalado e abrindo normalmente.
- Zsh definido como shell padrão.
- Oh My Zsh instalado.
- Abas e atalhos funcionando.
- Zsh Edit-Select instalado e testado.

Documentação: [Kitty](https://sw.kovidgoyal.net/kitty/) · [Oh My Zsh](https://ohmyz.sh/) · [Zsh Edit-Select](https://github.com/Michael-Matta1/zsh-edit-select).

Observação: os atalhos de seleção dependem do plugin e da compatibilidade com o Kitty; não presuma que estarão funcionando só porque a instalação terminou. Teste antes de ajustar outras configurações.
