# SG-Icones — Tema de Ícones para KDE Plasma

Tema de ícones flat e minimalista exclusivo para o KDE Plasma no SG-Endeavour, projetado com foco em leveza, formas geométricas limpas e herança nativa do Breeze.

---

## 1. Características Técnicas
* **Formato:** SVG vetorial puro (`viewBox="0 0 128 128"`).
* **Local de Instalação:** `~/.local/share/icons/SG-Icones/` (escopo estritamente do usuário).
* **Tema Herdado (Fallback):** `breeze,hicolor` (qualquer ícone não personalizado continua sendo suprido pelo Breeze).
* **Escalabilidade:** Suporta renderização nítida de 16px até 512px sem distorção ou perda de foco óptico.

---

## 2. Estrutura de Diretórios e Ícones Criados

```text
SG-Icones/
├── index.theme
├── README.md
└── scalable/
    ├── apps/
    │   ├── ark.svg -> org.kde.ark.svg
    │   ├── hwinfo.svg -> org.kde.kinfocenter.svg
    │   ├── kitty.svg
    │   ├── org.kde.dolphin.svg -> system-file-manager.svg
    │   ├── podman.svg -> podman-desktop.svg
    │   └── preferences-system.svg -> org.kde.systemsettings.svg
    └── places/
        ├── folder.svg
        ├── folder-desktop.svg
        ├── folder-documents.svg
        ├── folder-download.svg -> folder-downloads.svg
        ├── folder-home.svg -> user-home.svg
        ├── folder-music.svg -> folder-sound.svg
        ├── folder-pictures.svg -> folder-images.svg, folder-image.svg
        ├── folder-publicshare.svg -> folder-public.svg
        ├── folder-templates.svg
        ├── folder-videos.svg -> folder-video.svg
        └── start-here-kde.svg -> start-here-kde-plasma.svg
```

---

## 3. Mapeamento de Nomes Auditados do Sistema
Os nomes foram verificados diretamente nos arquivos `.desktop` instalados no sistema para garantir funcionamento nativo imediato:

| Aplicativo / Local | Arquivo SVG Primário | Aliases / Links Simbólicos |
| :--- | :--- | :--- |
| **Ark (Compactador)** | `ark.svg` | `org.kde.ark.svg` |
| **KDE Info Center** | `hwinfo.svg` | `org.kde.kinfocenter.svg` |
| **Dolphin** | `org.kde.dolphin.svg` | `system-file-manager.svg` |
| **Kitty Terminal** | `kitty.svg` | — |
| **Podman** | `podman.svg` | `podman-desktop.svg` |
| **Configurações do Sistema**| `preferences-system.svg` | `org.kde.systemsettings.svg` |
| **Lançador Kickoff** | `start-here-kde.svg` | `start-here-kde-plasma.svg` |
| **Pasta Pessoal** | `folder-home.svg` | `user-home.svg` |
| **Área de Trabalho** | `folder-desktop.svg` | — |
| **Documentos** | `folder-documents.svg` | — |
| **Downloads** | `folder-download.svg` | `folder-downloads.svg` |
| **Imagens** | `folder-pictures.svg` | `folder-images.svg`, `folder-image.svg` |
| **Músicas** | `folder-music.svg` | `folder-sound.svg` |
| **Vídeos** | `folder-videos.svg` | `folder-video.svg` |
| **Público** | `folder-publicshare.svg`| `folder-public.svg` |
| **Modelos** | `folder-templates.svg` | — |

---

## 4. Paleta de Cores Adotada
* **Pastas:**
  * Corpo frontal: `#3daee9` (Azul Breeze clássico)
  * Aba superior: `#2980b9` (Azul de acento)
  * Fundo interior: `#3498db` (Azul médio)
  * Emblemas: `#ffffff`
* **Aplicativos:**
  * Kitty: `#1e2227` (Fundo escuro), `#00d7af` (Verde-água) e `#ffffff`
  * Dolphin: `#1d99f3` (Azul Plasma) e `#ffffff`
  * Ark: `#e67e22` (Laranja/Âmbar) e `#ffffff`
  * Info Center: `#27ae60` (Verde esmeralda) e `#ffffff`
  * System Settings: `#34495e` (Cinza ardósia), `#ecf0f1` e `#1abc9c`
  * Podman: `#894b9d` (Roxo Podman) e `#ffffff`
  * Kickoff: `#232629` com nós orbitais `#1d99f3`, `#2ecc71` e `#e67e22`

---

## 5. Como Ativar ou Recarregar no KDE Plasma
1. Atualizar o cache de ícones do KDE:
   ```bash
   kbuildsycoca6
   ```
2. Abra as **Configurações do Sistema** (`systemsettings`).
3. Vá em **Cores e Temas** $\rightarrow$ **Ícones**.
4. Selecione **SG-Icones** e clique em **Aplicar**.
