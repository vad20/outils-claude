# Outils Claude de Vadim

## Installer sur un nouveau PC (en un clic)

1. Sur GitHub (dépôt privé `vad20/outils-claude`) : **Code → Download ZIP**, puis extraire le zip.
2. Double-cliquer sur **`INSTALLER.bat`**. Il installe les programmes, les skills, la note permanente, Chatterbox et les serveurs MCP. Il peut être relancé sans risque.
3. Faire les connexions personnelles qu'il liste à la fin (GitHub, Google, clés). Elles ne sont jamais stockées dans le dépôt.

Pour garder les PC synchronisés : sur ce PC, après chaque nouvel outil, double-cliquer sur **`SAUVEGARDER.bat`** (envoie les skills et la note sur GitHub). Sur un autre PC, préférer `gh repo clone vad20/outils-claude "$HOME\outils-claude"` plutôt que le zip, pour pouvoir sauvegarder depuis lui aussi.

Le dépôt contient : `config/skills/` (copie de `~\.claude\skills`), `config/CLAUDE.md` (note permanente), `chatterbox/voix.py`, ce README et les scripts. Il ne contient **aucune clé ni mot de passe** (voir `.gitignore`).

Index de tous les outils installés. Les outils n'ont **aucun rapport entre eux**.
Les dépôts GitHub complets (téléchargés le 2026-11-19, sans git) sont dans `depots\<nom>`.
Pour mettre un outil à jour : retélécharger `https://github.com/<repo>/archive/HEAD.zip`.

## 1. Skills (chargés automatiquement dans chaque session)

Installés dans `C:\Users\vadim\.claude\skills\`. Rien à faire pour les utiliser.

| Skill(s) | Dépôt | À quoi ça sert | Prérequis |
|---|---|---|---|
| `humanizer` | blader/humanizer | Réécrire un texte qui « sonne IA » pour qu'il paraisse humain | aucun |
| `watch` | bradautomates/claude-video | Regarder une vidéo (URL ou fichier) : images + transcription | Python, yt-dlp, ffmpeg (clé Gemini optionnelle) |
| `hyperframes`, `hyperframes-cli`, `hyperframes-registry`, `media-use`, `figma`, `remotion-to-hyperframes`, `reverse-any-video`, `slideshow`, `style-sampling` | heygen-com/hyperframes | Créer des vidéos en HTML (HyperFrames de HeyGen) | Node 22+, FFmpeg. ⚠ envoie une télémétrie d'usage (désactivable) |
| `21st-ui` | 21st-dev/magic-mcp | Trouver/générer des composants UI React (21st.dev) | serveur MCP 21st + clé API (voir §2) |
| `reverse-engineer-anything` | morluto/rea | Rétro-ingénierie de binaires/apps | serveur MCP REA (voir §2) |
| `gws-shared`, `gws-gmail`, `gws-drive`, `gws-docs`, `gws-sheets`, `gws-calendar`, `gws-slides`, `gws-tasks`, `gws-chat`, `gws-forms`, `gws-people`, `gws-meet`, `gws-keep`, `gws-workflow` | googleworkspace/cli | Piloter Google Workspace via la CLI `gws` | `npm i -g @googleworkspace/cli` puis `gws auth login` |
| `find-skills` | vercel-labs/skills | Chercher et installer de nouveaux skills (`npx skills add ...`) | Node 22.20+ |

Non installés mais disponibles : 81 autres skills gws (recettes `recipe-*`, personas `persona-*`, variantes) dans `depots\cli\skills\`. Les copier dans `.claude\skills\` si besoin.

## 2. Serveurs MCP

État au 2026-11-19 : Playwright ✅, Apify ✅ (OAuth au 1er usage), 21st ✅ (clé dans la config), REA ✅ (via `npx rea-agents setup`). `claude` CLI installé dans `C:\Users\vadim\.local\bin` (ajouté au PATH).

**Google Workspace (gws) ✅** : installé (`npm -g`) et connecté au compte Gmail de Vadim (projet Google Cloud `gws-claude`, client OAuth « bureau », mode Test). Scopes : drive, sheets, gmail.modify, calendar, documents, presentations, tasks. Identifiants chiffrés dans `~\.config\gws\`.

**Vérifié le 2026-11-19 (`claude mcp list`)** : playwright, 21st, rea ✅ connectés ; apify ⚠ « Needs authentication » (faire `/mcp` dans une session Claude Code → apify → se connecter). Connecteurs claude.ai aussi actifs : Gmail, Drive, Docs, Sheets, Slides, Calendar, Gamma, Claude Docs.

**Dev ✅** : git 2.56 + GitHub CLI `gh` 2.105 (connecté au compte GitHub `vad20`, HTTPS). Orca installé et connecté à Claude.

**watch ✅** : prérequis installés via winget (Python 3.12.10 = `python` par défaut, ffmpeg 9.0.2, yt-dlp 2026.10.26, deno 2.9.8). Mettre à jour yt-dlp avec `winget upgrade --id yt-dlp.yt-dlp --exact`.

**⚠ Windows : PowerShell bloque les scripts `.ps1`** → toujours appeler `gws.cmd`, `npx.cmd`, `npm.cmd` (pas `gws`, `npx`, `npm`).

Commandes à lancer dans un terminal où `claude` est installé (`--scope user` = toutes les sessions) :

| Serveur | Dépôt | Commande | Remarque |
|---|---|---|---|
| Playwright | microsoft/playwright-mcp | `claude mcp add --scope user playwright -- cmd /c npx -y @playwright/mcp@latest` | Pilote un navigateur. Aucune clé |
| Apify | apify/apify-mcp-server | `claude mcp add --scope user apify https://mcp.apify.com -t http` | Scraping web. Connexion OAuth au 1er usage |
| 21st.dev Magic | 21st-dev/magic-mcp | `npx @21st-dev/cli@latest init --client claude` | Clé gratuite sur 21st.dev/mcp (`API_KEY_21ST`) |
| REA | morluto/rea | `npx rea-agents setup` | Assistant d'installation interactif |

## 2b. Voix off (TTS)

**Moteur par défaut : Chatterbox Multilingual** (Resemble AI, licence **MIT** → usage commercial OK, aucune mention obligatoire). Tourne en local sur le GPU (RTX 4070 Ti).
- Dossier : `C:\Users\vadim\outils-claude\chatterbox\` (venv Python 3.12 dans `.venv`, PyTorch 2.6 CUDA 12.4, chatterbox-tts 0.1.7)
- Commande : `C:\Users\vadim\outils-claude\chatterbox\.venv\Scripts\python.exe C:\Users\vadim\outils-claude\chatterbox\voix.py "Texte" sortie.wav [--ref voix.wav] [--exag 0.5] [--cfg 0.5]`
- `--ref` = clonage d'une voix depuis un enregistrement de 10-20 s. Les sorties portent un filigrane audio inaudible (Perth).
- Préférences de Vadim : voix **naturelle et fluide** (Kokoro jugé trop robotique → ne pas l'utiliser). **Aucune mention/pub d'un service** dans les vidéos → éviter le plan gratuit ElevenLabs et les modèles CC-BY (ex. Thomcles/Chatterbox-TTS-French).
- Alternative si besoin : Qwen3-TTS (Apache 2.0). Kokoro (`hyperframes tts`) reste installé mais déconseillé.
- Dépôt évalué et non retenu : Bricesodini/Vocalie-TTS (interface lourde, 1 seul auteur ; on utilise son moteur directement).

## 3. Applications / autres (ni skill ni MCP directement)

| Outil | Dépôt | Description |
|---|---|---|
| Orca | stablyai/orca | Appli de bureau qui orchestre plusieurs agents (Claude Code, Codex…) en parallèle. À installer depuis https://orca.dev/download. Ses skills (`depots\orca\skills\`) ne servent que si Orca est installé. |
| gws (CLI) | googleworkspace/cli | Le programme derrière les skills `gws-*` (voir §1). |
| skills (CLI) | vercel-labs/skills | Le programme `npx skills` derrière `find-skills`. |
