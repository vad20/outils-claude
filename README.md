# Outils Claude de Vadim

Index de tout ce qui est installé pour Claude. Dernière mise à jour : 2026-11-20.
Dépôt privé : `vad20/outils-claude`. Les outils n'ont pas de rapport entre eux.

## 0. Installer sur un nouveau PC (en un clic)

1. GitHub → dépôt privé `vad20/outils-claude` → **Code → Download ZIP** → extraire.
2. Double-cliquer **`INSTALLER.bat`** (relançable sans risque). Il installe : programmes (git, gh, Node, Python 3.12, ffmpeg, yt-dlp, deno, uv), Claude Code CLI, les skills, la note permanente, Chatterbox (GPU si NVIDIA), SkillSpector, le plugin CLI-Anything et les serveurs MCP.
3. Faire les connexions personnelles qu'il liste à la fin (jamais stockées dans le dépôt).

Synchroniser : après un ajout d'outil sur ce PC → **`SAUVEGARDER.bat`**. Sur un autre PC, préférer `gh repo clone vad20/outils-claude "$HOME\outils-claude"` (permet aussi d'y sauvegarder).
Contenu du dépôt : `config/skills/` (copie de `~\.claude\skills`), `config/CLAUDE.md` (note permanente), `chatterbox/voix.py`, scripts, ce README. **Aucune clé ni mot de passe** (`.gitignore`). `depots/` (dépôts sources complets) reste local.

**⚠ Windows : PowerShell bloque les `.ps1`** → appeler `gws.cmd`, `npx.cmd`, `npm.cmd`.

---

## 1. Vidéo (TikTok / Shorts / Reels)

Règles de Vadim : vertical 1080×1920, 30 s, voix off Chatterbox, aucune pub/mention d'un service, **jamais publier sans accord explicite**.

| Skill(s) | Source | Usage | Prérequis / attention |
|---|---|---|---|
| `editing` (point d'entrée), `studio-setup`, `studio-script`, `short-editing`, `clips`, `broll`, `steal`, `outliers`, `insta-audit`, `publish`, `short-translate`, `vox`, `codex-images` | Melvynx/video-agent-skills (MIT) | Scripts 30-60 s, montage motion design, long → shorts, B-roll, copier un style, vidéos « outliers », publication | `outliers`/`insta-audit`/`publish` via **Treg** (`curl \| sh` → demander avant). `short-translate` = ElevenLabs payant. `codex-images`/`vox` = Codex (forfait ChatGPT → demander avant). |
| `hyperframes`, `hyperframes-cli`, `hyperframes-registry`, `media-use`, `figma`, `remotion-to-hyperframes`, `reverse-any-video`, `slideshow`, `style-sampling` | heygen-com/hyperframes | Vidéos rendues depuis HTML (~450 effets), montage, sous-titres, audio | Node 22+, ffmpeg. Télémétrie (désactivable : `hyperframes telemetry disable`). CLI : `node C:\Users\vadim\.claude\skills\hyperframes\scripts\plugin-cli.mjs <cmd>` |
| `lemo-opuscar` | lemomo-ai/lemo-opuscar | Courts films « en code » dans 99 styles (aquarelle, ukiyo-e, briefing satellite…) | Bibliothèque clonée dans `~\lemo-opuscar` au 1er usage (`setup.sh`, Git Bash). Films produits = à Vadim, usage commercial, sans crédit |
| `watch` | bradautomates/claude-video | Regarder une vidéo (URL/fichier) : images + transcription | ✅ Python 3.12, ffmpeg, yt-dlp, deno installés |

## 2. Voix off

**Moteur par défaut : Chatterbox Multilingual** (Resemble AI, MIT → commercial OK, aucune mention). Local sur GPU RTX 4070 Ti.
- Dossier `C:\Users\vadim\outils-claude\chatterbox\` (venv `.venv`, Python 3.12, PyTorch 2.6 CUDA 12.4, chatterbox-tts 0.1.7)
- `C:\Users\vadim\outils-claude\chatterbox\.venv\Scripts\python.exe C:\Users\vadim\outils-claude\chatterbox\voix.py "Texte" sortie.wav [--ref voix.wav] [--exag 0.5] [--cfg 0.5]`
- `--ref` = clonage d'une voix (10-20 s). Filigrane audio inaudible (Perth).
- Kokoro (`hyperframes tts`) jugé trop robotique → ne pas utiliser. Éviter ElevenLabs gratuit et les modèles CC-BY (mention obligatoire). Alternative : Qwen3-TTS (Apache 2.0).

## 3. Business, marketing, SEO

| Skill(s) | Source | Usage | Prérequis |
|---|---|---|---|
| `founder-board`, `-brand`, `-cfo`, `-competitors`, `-consumer`, `-launch`, `-marketing`, `-offer`, `-ops`, `-plan`, `-pricing` | Jakeschincariol/founder-skill (MIT) | Tester une idée de business : board d'experts, offre, prix, finances, concurrents, marketing, lancement, business plan | Scripts Python hors ligne |
| `seo-coach`, `seo-audit`, `seo-report`, `seo-project-setup`, `keyword-research`, `keyword-clustering`, `competitor-analysis`, `competitive-landscape`, `link-prospecting`, `local-seo`, `ai-prompt-research`, `ai-visibility-audit` | every-app/open-seo (MIT) | SEO et visibilité dans les IA | La plupart demandent le **MCP OpenSEO** (non connecté) |
| `humanizer` | blader/humanizer | Rendre un texte « IA » naturel | aucun |

## 4. Google Workspace et productivité

| Skill(s) | Source | Usage | État |
|---|---|---|---|
| `gws-shared`, `gws-gmail`, `gws-drive`, `gws-docs`, `gws-sheets`, `gws-calendar`, `gws-slides`, `gws-tasks`, `gws-forms`, `gws-people`, `gws-meet`, `gws-workflow` (+ `gws-chat`, `gws-keep` : comptes Workspace pro seulement) | googleworkspace/cli | Piloter Google via la CLI `gws.cmd` | ✅ connecté (projet Google Cloud `gws-claude`, mode Test ; scopes drive, sheets, gmail.modify, calendar, documents, presentations, tasks ; identifiants chiffrés dans `~\.config\gws\`) |

Aussi : connecteurs du compte claude.ai (Gmail, Drive, Docs, Sheets, Slides, Calendar, Gamma, Claude Docs) — suivent le compte, rien à installer. 81 autres skills gws (`recipe-*`, `persona-*`) dans `depots\cli\skills\`.

## 5. Développement

| Outil | Source | Usage | État |
|---|---|---|---|
| `ponytail`, `ponytail-review`, `ponytail-audit`, `ponytail-debt`, `ponytail-gain`, `ponytail-help` | DietrichGebert/ponytail (MIT) | Coder au plus simple, revues et audits de dépôt | skills |
| `firecrawl-build`, `-onboarding`, `-scrape`, `-search`, `-interact` | firecrawl/firecrawl | Intégrer Firecrawl dans une appli | Clé `FIRECRAWL_API_KEY` |
| `21st-ui` + MCP 21st | 21st-dev/magic-mcp | Composants UI React | ✅ clé configurée |
| `reverse-engineer-anything` + MCP REA | morluto/rea | Rétro-ingénierie | ✅ |
| Plugin **CLI-Anything** (`/cli-anything`, `/list`, `/refine`, `/test`, `/validate`) | HKUDS/CLI-Anything (Apache-2.0) | Créer des interfaces en ligne de commande pour piloter n'importe quel logiciel (Blender, Audacity, GIMP, OBS…). 151 harnais prêts sur https://clianything.cc/ | ✅ plugin `cli-anything@cli-anything` (scope user) |
| `find-skills` | vercel-labs/skills | Trouver/installer de nouveaux skills (`npx.cmd skills add …`) | Node 22.20+ |
| git, gh | — | Versionner, GitHub | ✅ compte `vad20`, HTTPS |
| Orca | stablyai/orca | Orchestrer plusieurs agents en parallèle (appli) | ✅ installé, connecté à Claude |

## 6. Web et navigateur

| Serveur MCP | Commande d'installation | État |
|---|---|---|
| Playwright | `claude mcp add --scope user playwright -- cmd /c npx -y @playwright/mcp@latest` | ✅ |
| Apify (scraping, milliers d'« Actors ») | `claude mcp add --scope user apify https://mcp.apify.com -t http` | ⚠ connexion à faire (`/mcp` → apify) |
| 21st | `claude mcp add 21st --scope user -e API_KEY_21ST=<clé> -- cmd /c npx -y @21st-dev/magic@latest` | ✅ |
| REA | `npx.cmd rea-agents setup` (cocher Claude Code) | ✅ |

## 7. Sécurité des skills

- **SkillSpector** (NVIDIA, Apache-2.0) : `skillspector scan <dossier> --no-llm` (`--recursive` pour un dossier de skills). Installé via `uv tool install --python 3.13 "skillspector[mcp] @ git+https://github.com/NVIDIA/skillspector.git"` → `~\.local\bin\skillspector.exe`. Skill `skill-inspector` pour l'utiliser.
- **Règle : scanner tout nouveau skill avant de l'installer.**
- Scan du 2026-11-20 (77 skills, sans LLM) : risque max **36 / MEDIUM**, aucun HIGH réel. Alertes vérifiées et acceptables : `figma` lit `FIGMA_TOKEN`, `firecrawl-build-onboarding` écrit sa clé dans `.env`, `codex-images` lance Codex (facturation ChatGPT). Rapport : `scan-securite\rapport.json` (local).

---

## 8. Catalogue (applis/projets **non installés**, à proposer si utiles)

| Projet | Source | Ce que c'est | Remarque |
|---|---|---|---|
| VoiceStudio | debpalash/VoiceStudio (AGPL-3.0) | Alternative locale à ElevenLabs | Alternative à Chatterbox |
| Vocalie-TTS | Bricesodini/Vocalie-TTS (MIT) | Interface voix off FR | Évalué, non retenu (on utilise Chatterbox directement) |
| Handy | cjpais/Handy (MIT) | Dictée vocale hors ligne | Appli de bureau |
| OpenWhispr | OpenWhispr/openwhispr (MIT) | Dictée vocale | Skills `openwhispr-*` dans le dépôt |
| Cap | CapSoftware/Cap | Enregistrement d'écran (type Loom) | Skill `cap` dans le dépôt |
| Open Higgsfield | wide-trace/open-higgsfield (sans licence) | Studio image/vidéo IA | Modèles payants via API ; pas de licence |
| Open-Generative-AI | Anil-matcha/Open-Generative-AI (MIT) | Studio image/vidéo IA | API externes payantes |
| freellmapi | tashfeenahmed/freellmapi (MIT) | Proxy unifiant ~87 fournisseurs de LLM gratuits | Serveur ; vérifier les CGU de chaque fournisseur |
| OpenJarvis | open-jarvis/OpenJarvis (Apache-2.0) | Assistant IA personnel en local | Appli/serveur |
| JARVIS (HuggingGPT) | microsoft/JARVIS (MIT) | Projet de recherche 2023 (LLM + modèles Hugging Face) | Ancien, non maintenu activement |
| AppFlowy | AppFlowy-IO/AppFlowy (AGPL-3.0) | Espace de travail type Notion | Appli |
| Plane | makeplane/plane (AGPL-3.0) | Gestion de projet | Auto-hébergement |
| OpenProject | opf/openproject (GPL-3.0) | Gestion de projet | Auto-hébergement |
| Chatwoot | chatwoot/chatwoot | Support client | Auto-hébergement |
| Cal.diy | calcom/cal.diy (MIT) | Prise de rendez-vous | Skill `calcom-api` dans le dépôt |
| PostHog | PostHog/posthog | Analytique produit | MCP PostHog possible |
| Composio | ComposioHQ/composio (MIT) | 1000+ intégrations | Service avec clé |
| Playwright | microsoft/playwright | Automatisation navigateur | Couvert par le MCP Playwright |
| ECC | affaan-m/ECC (MIT) | ~1000 skills | Non installé en bloc ; piocher au cas par cas |
| Ruflo | ruvnet/ruflo (MIT) | Essaims d'agents (~400 skills) | Non installé (lourd) |
