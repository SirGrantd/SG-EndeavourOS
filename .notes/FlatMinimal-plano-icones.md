# Especificação: tema de ícones FlatMinimal para KDE Plasma

## 1. Objetivo

Criar um tema pequeno de ícones para KDE Plasma, no EndeavourOS, com estilo flat/minimalista. O tema deve substituir apenas os ícones especificados neste documento e herdar os demais do tema Breeze.

O projeto deve ser instalado somente para o usuário atual, sem modificar arquivos do sistema.

- **Nome do tema:** `FlatMinimal`
- **Formato principal:** SVG
- **Estilo:** flat/minimalista, formas simples e legíveis
- **Local de instalação:** `~/.local/share/icons/FlatMinimal/`
- **Tema herdado:** `breeze,hicolor`

## 2. Ícones solicitados

### 2.1 Aplicativos

Criar ícones SVG para os seguintes aplicativos:

| Nome do arquivo | Aplicativo |
|---|---|
| `org.kde.ark.svg` | Ark — compactação e extração de arquivos |
| `org.kde.kinfocenter.svg` | KDE Info Center |
| `org.kde.systemsettings.svg` | KDE System Settings |
| `org.kde.dolphin.svg` | Dolphin — gerenciador de arquivos |
| `kitty.svg` | Kitty — emulador de terminal |
| `podman.svg` | Podman |

**Importante:** antes de definir os nomes finais, verificar os valores reais de `Icon=` nos arquivos `.desktop` instalados. Se o nome solicitado pelo aplicativo for diferente, usar o nome efetivamente utilizado pelo sistema e documentar o mapeamento. Não criar duplicatas desnecessárias.

### 2.2 Lançador de aplicativos do Plasma

Identificar o ícone usado pelo lançador de aplicativos instalado (por exemplo, Kickoff) na versão atual do KDE Plasma.

- Não presumir que o nome seja `start-here`.
- Verificar a configuração, os arquivos do tema Breeze e os recursos do widget.
- Criar o SVG com o nome e no diretório adequados ao contexto real.
- Não modificar arquivos do sistema nem configurações globais sem necessidade.
- Se o lançador não aceitar o ícone pelo tema de ícones, documentar a limitação e indicar a alternativa apropriada, sem alterar o tema do Plasma automaticamente.

### 2.3 Pastas e locais

Criar variantes de pastas no estilo flat:

| Nome pretendido | Finalidade |
|---|---|
| `folder.svg` | Pasta genérica |
| `folder-documents.svg` | Documentos |
| `folder-pictures.svg` | Imagens |
| `folder-download.svg` | Downloads |
| `folder-music.svg` | Músicas |
| `folder-videos.svg` | Vídeos |
| `folder-desktop.svg` | Área de trabalho |
| `folder-home.svg` | Pasta pessoal |
| `folder-publicshare.svg` | Pasta pública/compartilhada |
| `folder-templates.svg` | Modelos |

Verificar os nomes padronizados e os nomes solicitados pelo KDE/Breeze antes de finalizar. Se houver aliases necessários para compatibilidade, adicioná-los somente quando forem úteis e documentá-los.

## 3. Diretrizes visuais

Todos os ícones devem pertencer à mesma família visual.

- Prancheta SVG de `128 × 128` unidades.
- Desenho vetorial limpo, com formas geométricas simples.
- Silhuetas reconhecíveis em tamanhos pequenos.
- Paleta reduzida e consistente.
- Margens internas e alinhamento óptico consistentes.
- Evitar detalhes minúsculos, ruído visual, sombras complexas e gradientes desnecessários.
- Usar transparência no fundo; não adicionar fundo opaco à prancheta inteira.
- Manter os símbolos visualmente centralizados e com peso equilibrado.
- Os ícones de pastas devem compartilhar a mesma silhueta-base; diferenciar categorias com símbolos internos e/ou cores discretas.
- Não copiar diretamente os desenhos protegidos de outros temas. Usar referências apenas para entender convenções e nomes.

Se nenhuma paleta tiver sido definida, escolher uma paleta flat coesa, com cores acessíveis e contraste suficiente em fundos claros e escuros. Registrar as cores escolhidas em um arquivo de documentação.

## 4. Estrutura de diretórios esperada

```text
~/.local/share/icons/FlatMinimal/
├── index.theme
└── scalable/
    ├── apps/
    │   ├── org.kde.ark.svg
    │   ├── org.kde.kinfocenter.svg
    │   ├── org.kde.systemsettings.svg
    │   ├── org.kde.dolphin.svg
    │   ├── kitty.svg
    │   └── podman.svg
    └── places/
        ├── folder.svg
        ├── folder-documents.svg
        ├── folder-pictures.svg
        ├── folder-download.svg
        ├── folder-music.svg
        ├── folder-videos.svg
        ├── folder-desktop.svg
        ├── folder-home.svg
        ├── folder-publicshare.svg
        └── folder-templates.svg
```

A estrutura acima é a base. Ajustar diretórios e nomes se a investigação mostrar que algum ícone pertence a outro contexto ou é solicitado com outro identificador. Incluir o ícone do lançador no local correto, após identificar o mecanismo usado pelo Plasma.

## 5. Arquivo `index.theme`

Criar um arquivo `index.theme` válido para o tema. Ele deve:

- Declarar `Name=FlatMinimal`.
- Descrever brevemente o tema em `Comment`.
- Herdar de `breeze,hicolor`.
- Declarar os diretórios escaláveis usados pelo projeto.
- Configurar cada diretório com `Type=Scalable`, limites de tamanho adequados e o `Context` correspondente.
- Não declarar diretórios que não existam.
- Seguir a especificação FreeDesktop para temas de ícones.

Modelo inicial:

```ini
[Icon Theme]
Name=FlatMinimal
Comment=Tema flat minimalista para KDE Plasma
Inherits=breeze,hicolor
Directories=scalable/apps,scalable/places

[scalable/apps]
Size=128
Type=Scalable
MinSize=16
MaxSize=512
Context=Applications

[scalable/places]
Size=128
Type=Scalable
MinSize=16
MaxSize=512
Context=Places
```

Atualizar `Directories` e as seções correspondentes se forem necessários outros diretórios para o ícone do lançador.

## 6. Passo a passo de implementação

### Etapa 1 — investigar o sistema

1. Confirmar a versão do KDE Plasma.
2. Examinar `/usr/share/icons/breeze/` e `/usr/share/icons/` para identificar nomes e contextos existentes.
3. Localizar os arquivos `.desktop` dos aplicativos instalados.
4. Conferir o valor de `Icon=` para Ark, Info Center, System Settings, Dolphin e Kitty.
5. Investigar como o Podman é usado. Se não houver aplicativo gráfico com arquivo `.desktop`, criar apenas o ícone para uso futuro/atalho, sem afirmar que isso altera o terminal ou os contêineres.
6. Identificar o lançador de aplicativos usado e descobrir como ele obtém seu ícone.
7. Verificar os nomes reais de ícones de pastas usados pelo KDE/Breeze.
8. Registrar os nomes identificados em `README.md`.

### Etapa 2 — preparar o projeto

1. Criar `~/.local/share/icons/FlatMinimal/`.
2. Criar os diretórios necessários.
3. Criar o `index.theme`.
4. Criar um `README.md` contendo instalação, mapeamento de nomes, decisões visuais e limitações conhecidas.
5. Não usar `sudo` para instalar o tema no diretório do usuário.

### Etapa 3 — desenhar os ícones

1. Criar primeiro cinco ícones-piloto: Dolphin, Kitty, System Settings, Ark e pasta genérica.
2. Validar a paleta, as proporções e a legibilidade.
3. Ajustar o estilo antes de desenhar os demais.
4. Criar os ícones restantes de aplicativos.
5. Criar as variantes de pastas com uma silhueta compartilhada.
6. Criar o ícone do lançador somente após confirmar o nome e o mecanismo necessários.
7. Salvar todos os arquivos como SVG válidos, com nomes correspondentes aos identificadores reais.
8. Não rasterizar os SVGs nem converter apenas a extensão do arquivo.

### Etapa 4 — validar os SVGs

1. Verificar se todos os SVGs são XML válidos.
2. Verificar se todos têm `viewBox` coerente, preferencialmente `0 0 128 128`.
3. Verificar se não dependem de imagens externas, fontes não disponíveis ou recursos remotos.
4. Conferir transparência, margens, alinhamento e contraste.
5. Visualizar os ícones em 16, 24, 32, 48 e 128 px.
6. Corrigir erros antes da instalação.

Se `xmllint` estiver instalado, pode ser usado para validar a sintaxe XML. A validação XML, sozinha, não garante que o SVG seja renderizado corretamente.

### Etapa 5 — instalar e testar

1. Confirmar que `index.theme` está diretamente dentro de `FlatMinimal/`.
2. Selecionar **FlatMinimal** em Configurações do Sistema → Aparência → Ícones.
3. Verificar os ícones de aplicativos no lançador, no gerenciador de arquivos e nas listas de aplicativos.
4. Verificar as pastas em Dolphin e nos locais pessoais.
5. Confirmar que os ícones não personalizados continuam aparecendo pelo fallback Breeze.
6. Se um ícone não mudar, verificar o nome `Icon=`, o caminho, o contexto e possíveis caches antes de modificar arquivos do sistema.
7. Testar após encerrar e reabrir os aplicativos; se necessário, encerrar e iniciar a sessão Plasma.
8. Documentar limitações específicas do lançador e do Podman.

## 7. Critérios de aceitação

- [ ] Tema `FlatMinimal` aparece nas configurações de ícones.
- [ ] Todos os SVGs são válidos e renderizados corretamente.
- [ ] Ícones de Ark, Info Center, System Settings, Dolphin e Kitty são substituídos quando seus identificadores correspondem aos arquivos.
- [ ] Ícone do Podman está criado e seu uso pretendido está documentado.
- [ ] Ícone do lançador foi investigado e implementado conforme o mecanismo real, ou a limitação foi documentada.
- [ ] Variantes de pastas aparecem nos contextos correspondentes.
- [ ] O restante dos ícones é herdado do Breeze/hicolor.
- [ ] Nenhum arquivo de `/usr/share/icons/` foi alterado.
- [ ] O tema é instalado somente no diretório do usuário.
- [ ] `README.md` documenta instalação, nomes reais, testes e limitações.

## 8. Restrições para o agente

- Não ampliar o escopo para criar ícones de ações, dispositivos ou tipos MIME, exceto se for indispensável para atender aos itens solicitados.
- Não instalar pacotes ou alterar configurações do sistema sem necessidade.
- Não substituir arquivos do Breeze.
- Não inventar identificadores de ícones: investigar os nomes usados pela instalação.
- Não declarar o trabalho concluído sem testar a estrutura e validar os SVGs.
- Ao terminar, apresentar uma lista dos arquivos criados, comandos de validação executados e qualquer item que não tenha sido possível implementar.
