# Guia de Pastas e Elementos Restantes — SG-Icons

Este diretório reúne referências visuais oficiais (extraídas do tema Breeze nativo do sistema) para criação e expansão do tema **SG-Icons** no Figma.

---

## 1. Diagnóstico da Sidebar do Dolphin (`sidebar.png`)

Comparando os itens exibidos na barra lateral do Dolphin com os ícones já implementados no **SG-Icons**:

| Seção na Sidebar | Item / Nome | Ícone Utilizado pelo KDE | Status no SG-Icons | Ação Necessária |
| :--- | :--- | :--- | :--- | :--- |
| **Locais** | **Início** | `user-home` | ✅ **Ativo** | Nenhuma (perfeito) |
| **Locais** | **Área de trabalho** | `user-desktop` | ✅ **Ativo** | Nenhuma (perfeito) |
| **Locais** | **Documentos** | `folder-documents` | ✅ **Ativo** | Nenhuma (perfeito) |
| **Locais** | **Downloads** | `folder-downloads` | ✅ **Ativo** | Nenhuma (perfeito) |
| **Locais** | **Música** | `folder-music` | ✅ **Ativo** | Nenhuma (perfeito) |
| **Locais** | **Imagens** | `folder-pictures` | ✅ **Ativo** | Nenhuma (perfeito) |
| **Locais** | **Vídeos** | `folder-videos` | ✅ **Ativo** | Nenhuma (perfeito) |
| **Locais** | **Lixeira** | `user-trash` | ⚠️ *Fallback Breeze* | Criar em `01-Lixeira/` |
| **Remoto** | **Rede** | `folder-network` | ⚠️ *Fallback Breeze* | Criar em `02-Rede/` |
| **Recentes** | **Arquivos recentes** | `document-open-recent` | ⚠️ *Fallback Breeze* | Criar em `09-Recentes/` |
| **Recentes** | **Locais recentes** | `folder-open-recent` / `folder-recent` | ⚠️ *Fallback Breeze* | Criar em `09-Recentes/` |
| **Dispositivos** | **endeavouros** | `drive-harddisk-root` | ⚠️ *Fallback Breeze* | Criar em `14-Dispositivos-Armazenamento/` |
| **Dispositivos** | **Armazenamento** | `drive-harddisk` | ⚠️ *Fallback Breeze* | Criar em `14-Dispositivos-Armazenamento/` |

---

## 2. Estrutura de Pastas de Referência Disponíveis

```text
.notes/Pastas-Restantes/
├── 01-Lixeira/                      -> user-trash.svg, user-trash-full.svg, folder-trash.svg
├── 02-Rede/                         -> folder-network.svg, network-workgroup.svg, folder-remote.svg
├── 03-Desenvolvimento/              -> folder-development.svg, folder-git.svg, folder-docker.svg
├── 04-Jogos/                        -> folder-games.svg
├── 05-Nuvem/                        -> folder-cloud.svg, folder-gdrive.svg, folder-dropbox.svg
├── 06-Cofre-Seguranca/              -> folder-locked.svg, folder-encrypted.svg, folder-unlocked.svg
├── 07-Sistema-Raiz/                 -> folder-root.svg
├── 08-Favoritos/                    -> folder-favorites.svg, folder-bookmark.svg
├── 09-Recentes/                     -> document-open-recent.svg, folder-open-recent.svg, folder-recent.svg
├── 10-Anotacoes-Leituras/           -> folder-notes.svg, folder-book.svg
├── 11-Temporarios-Logs/             -> folder-temp.svg, folder-log.svg
├── 12-Importante/                   -> folder-important.svg
├── 13-Cores-de-Pastas/              -> 11 cores oficiais do KDE Plasma (ver tabela abaixo)
└── 14-Dispositivos-Armazenamento/   -> drive-harddisk-root.svg, drive-harddisk.svg, drive-removable-media.svg
```

---

## 3. Cores de Pastas no Dolphin (`13-Cores-de-Pastas`)

No Dolphin, ao clicar com o botão direito em qualquer pasta e ir em **Propriedades** ou menu de contexto, o KDE permite escolher cores personalizadas para as pastas.

Como você já tem o molde perfeito da pasta base (`Foulder.svg` em `128x128` com Inner Shadow), **criar as cores no Figma é extremamente simples e rápido**: basta duplicar a pasta base e trocar o tom de cor (preenchimento da aba traseira e do corpo frontal)!

| Arquivo SVG | Cor de Referência | Sugestão para o Estilo SG-Icons |
| :--- | :--- | :--- |
| `folder-blue.svg` | Azul | Já utilizado em Templates / Documentos (`#3A66A0` / `#5882BA`) |
| `folder-yellow.svg` | Amarelo / Dourado | Cor da pasta padrão `folder.svg` (`#FEBE17` / `#FFD666`) |
| `folder-orange.svg` | Laranja / Pêssego | Cor da pasta de Músicas (`#FF8551` / `#EF9169`) |
| `folder-red.svg` | Vermelho / Coral | Cor da pasta Home (`#E74C3C` / `#FF6B6B`) |
| `folder-green.svg` | Verde / Menta | Cor da pasta de Downloads ou Público (`#6FC4B3` / `#95DDCE`) |
| `folder-cyan.svg` | Ciano / Turquesa | Tom azul piscina (`#00BCD4` / `#4DD0E1`) |
| `folder-violet.svg` | Roxo / Lavanda | Cor da pasta de Vídeos (`#8E7AE5` / `#A295DD`) |
| `folder-magenta.svg`| Rosa / Magenta | Tom fúcsia elegante (`#E91E63` / `#F06292`) |
| `folder-grey.svg`   | Cinza Neutro | Tom ardósia / neutro (`#607D8B` / `#90A4AE`) |
| `folder-black.svg`  | Preto / Dark | Cinza escuro profundo (`#263238` / `#37474F`) |
| `folder-brown.svg`  | Marrom / Café | Tom couro / madeira (`#795548` / `#A1887F`) |

---

## 4. Dispositivos e Drives (`14-Dispositivos-Armazenamento`)

Na barra lateral do Dolphin (seção **Dispositivos**):
1. **`drive-harddisk-root.svg`**: Representa a partição `/` do sistema onde o EndeavourOS está instalado.
   * *Sugestão:* Pode ser um disco rígido minimalista em squircle com o logo/símbolo do EndeavourOS (ou uma raiz `/`).
2. **`drive-harddisk.svg`**: Representa discos de dados, partições secundárias ("Armazenamento") ou discos rígidos internos.
   * *Sugestão:* Um ícone de SSD/HD flat minimalista em `128x128`.
3. **`drive-removable-media.svg`**: Unidades USB removíveis e pendrives plugados.
