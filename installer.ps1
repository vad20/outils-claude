# Installateur des outils Claude de Vadim (Windows 10/11)
# Lancer via INSTALLER.bat. Peut être relancé sans risque : ce qui est déjà installé est ignoré.
$ErrorActionPreference = "Continue"
$Src  = $PSScriptRoot
$Dest = Join-Path $HOME "outils-claude"
$ClaudeDir = Join-Path $HOME ".claude"
$Manuel = New-Object System.Collections.ArrayList

function Titre($t) { Write-Host ""; Write-Host "=== $t ===" -ForegroundColor Cyan }
function Ok($t)    { Write-Host "  [OK] $t" -ForegroundColor Green }
function Info($t)  { Write-Host "  $t" }
function Refresh-Path {
    $env:Path = [Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [Environment]::GetEnvironmentVariable("Path","User") + ";$HOME\.local\bin"
}
function A-Commande($c) { [bool](Get-Command $c -ErrorAction SilentlyContinue) }

# ---------------------------------------------------------------- 1. Programmes
Titre "1/7 Programmes (winget)"
if (-not (A-Commande winget)) {
    Write-Host "  winget est absent. Installe 'App Installer' depuis le Microsoft Store puis relance." -ForegroundColor Red
    exit 1
}
$paquets = @(
    @{ id = "Git.Git";             cmd = "git"    },
    @{ id = "GitHub.cli";          cmd = "gh"     },
    @{ id = "OpenJS.NodeJS.LTS";   cmd = "node"   },
    @{ id = "Python.Python.3.12";  cmd = $null    },
    @{ id = "Gyan.FFmpeg";         cmd = "ffmpeg" },
    @{ id = "yt-dlp.yt-dlp";       cmd = "yt-dlp" },
    @{ id = "DenoLand.Deno";       cmd = "deno"   }
)
foreach ($p in $paquets) {
    if ($p.cmd -and (A-Commande $p.cmd)) { Ok "$($p.id) deja present"; continue }
    Info "Installation de $($p.id)..."
    winget install --id $p.id --exact --silent --accept-source-agreements --accept-package-agreements | Out-Null
}
Refresh-Path

# Python 3.12 précis (Chatterbox en a besoin)
$py = $null
try { $py = (& py -3.12 -c "import sys;print(sys.executable)" 2>$null) } catch {}
if (-not $py) { $cand = "$env:LOCALAPPDATA\Programs\Python\Python312\python.exe"; if (Test-Path $cand) { $py = $cand } }
if ($py) { Ok "Python 3.12 : $py" } else { Write-Host "  Python 3.12 introuvable : ferme et relance INSTALLER.bat." -ForegroundColor Yellow }

# ---------------------------------------------------------------- 2. Claude Code
Titre "2/7 Claude Code (ligne de commande)"
if (-not (A-Commande claude)) {
    Invoke-RestMethod https://claude.ai/install.ps1 | Invoke-Expression
}
$userPath = [Environment]::GetEnvironmentVariable("Path","User")
if ($userPath -notlike "*\.local\bin*") {
    [Environment]::SetEnvironmentVariable("Path", "$userPath;$HOME\.local\bin", "User")
}
Refresh-Path
if (A-Commande claude) { Ok "claude $(claude --version)" }

# Raccourci bureau « Claude Code »
$desk = [Environment]::GetFolderPath("Desktop")
$wt = (Get-Command wt.exe -ErrorAction SilentlyContinue).Source
$lnk = (New-Object -ComObject WScript.Shell).CreateShortcut("$desk\Claude Code.lnk")
if ($wt) { $lnk.TargetPath = $wt; $lnk.Arguments = "-d `"$HOME`" powershell -NoExit -Command claude" }
else     { $lnk.TargetPath = "powershell.exe"; $lnk.Arguments = "-NoExit -Command claude" }
$lnk.WorkingDirectory = $HOME; $lnk.IconLocation = "$HOME\.local\bin\claude.exe,0"; $lnk.Description = "Ouvrir Claude Code"; $lnk.Save()
Ok "Raccourci bureau 'Claude Code'"

# ---------------------------------------------------------------- 3. Fichiers
Titre "3/7 Skills, note permanente et dossier d'outils"
New-Item -ItemType Directory -Force "$ClaudeDir\skills" | Out-Null
Copy-Item "$Src\config\skills\*" "$ClaudeDir\skills\" -Recurse -Force
Ok "$((Get-ChildItem "$Src\config\skills" -Directory).Count) skills copies dans $ClaudeDir\skills"

# Les chemins sont écrits pour C:\Users\vadim : on les adapte à ce PC
function Copie-Adaptee($from, $to) {
    $txt = [IO.File]::ReadAllText($from, [Text.Encoding]::UTF8)
    $txt = $txt.Replace("C:\Users\vadim", $HOME)
    [IO.File]::WriteAllText($to, $txt, (New-Object Text.UTF8Encoding($false)))
}
$noteCible = "$ClaudeDir\CLAUDE.md"
if ((Test-Path $noteCible) -and -not (Select-String -Path $noteCible -Pattern "outils-claude" -Quiet)) {
    Copy-Item $noteCible "$noteCible.avant-installateur" -Force
    Info "Ancienne note sauvegardee : CLAUDE.md.avant-installateur"
}
Copie-Adaptee "$Src\config\CLAUDE.md" $noteCible
Ok "Note permanente installee"

if ($Src -ne $Dest) {
    New-Item -ItemType Directory -Force "$Dest\chatterbox" | Out-Null
    Copy-Item "$Src\chatterbox\voix.py" "$Dest\chatterbox\" -Force
    Copy-Item "$Src\*.bat","$Src\*.ps1","$Src\.gitignore" $Dest -Force -ErrorAction SilentlyContinue
    if (-not (Test-Path "$Dest\config")) { Copy-Item "$Src\config" $Dest -Recurse -Force }
}
Copie-Adaptee "$Src\README.md" "$Dest\README.md"
Ok "Dossier d'outils : $Dest"

# ---------------------------------------------------------------- 4. Google Workspace CLI
Titre "4/7 Google Workspace (gws)"
if (-not (A-Commande gws)) { npm.cmd install -g @googleworkspace/cli | Out-Null; Refresh-Path }
if (A-Commande gws) { Ok "gws installe" }
if (-not (Test-Path "$HOME\.config\gws\client_secret.json")) {
    [void]$Manuel.Add("Google Workspace : copie ton fichier client_secret.json (console.cloud.google.com > projet gws-claude > Clients) dans $HOME\.config\gws\ puis lance : gws.cmd auth login")
}

# ---------------------------------------------------------------- 5. Chatterbox (voix off)
Titre "5/7 Chatterbox - voix off (plusieurs Go, patience)"
$venv = "$Dest\chatterbox\.venv"
if ($py -and -not (Test-Path "$venv\Scripts\python.exe")) { & $py -m venv $venv }
$vpy = "$venv\Scripts\python.exe"
if (Test-Path $vpy) {
    $dejaOk = $false
    try { & $vpy -c "import chatterbox" 2>$null; $dejaOk = ($LASTEXITCODE -eq 0) } catch {}
    if ($dejaOk) { Ok "Chatterbox deja installe" }
    else {
        & $vpy -m pip install -q --upgrade pip
        $nvidia = [bool](Get-CimInstance Win32_VideoController | Where-Object Name -like "*NVIDIA*")
        if ($nvidia) {
            Info "Carte NVIDIA detectee : PyTorch GPU"
            & $vpy -m pip install -q torch==2.6.0 torchaudio==2.6.0 --index-url https://download.pytorch.org/whl/cu124
        } else {
            Info "Pas de carte NVIDIA : PyTorch CPU (la voix sera plus lente a generer)"
            & $vpy -m pip install -q torch==2.6.0 torchaudio==2.6.0 --index-url https://download.pytorch.org/whl/cpu
        }
        & $vpy -m pip install -q chatterbox-tts==0.1.7
        Ok "Chatterbox installe"
    }
}

# ---------------------------------------------------------------- 5b. SkillSpector (scanner de securite des skills)
Titre "5b SkillSpector"
if (-not (Test-Path "$HOME\.local\bin\skillspector.exe") -and $py) {
    & $py -m pip install --user -q uv
    $uv = & $py -c "import sysconfig,os;print(os.path.join(sysconfig.get_path('scripts','nt_user'),'uv.exe'))"
    if (Test-Path $uv) { & $uv tool install --python 3.13 "skillspector[mcp] @ git+https://github.com/NVIDIA/skillspector.git" 2>$null | Out-Null }
}
if (Test-Path "$HOME\.local\bin\skillspector.exe") { Ok "SkillSpector" } else { [void]$Manuel.Add("SkillSpector : voir la section 7 du README") }

# ---------------------------------------------------------------- 6. Serveurs MCP et plugins
Titre "6/7 Serveurs MCP et plugins"
if (A-Commande claude) {
    $plugins = (claude plugin list 2>$null) -join "`n"
    if ($plugins -notmatch "cli-anything@cli-anything") {
        claude plugin marketplace add HKUDS/CLI-Anything 2>$null | Out-Null
        claude plugin install cli-anything@cli-anything --scope user 2>$null | Out-Null
    }
    Ok "plugin CLI-Anything"
    $existants = (claude mcp list 2>$null) -join "`n"
    if ($existants -notmatch "playwright:") { claude mcp add --scope user playwright -- cmd /c npx -y "@playwright/mcp@latest" | Out-Null }
    Ok "playwright"
    if ($existants -notmatch "apify:") { claude mcp add --scope user apify https://mcp.apify.com -t http | Out-Null }
    Ok "apify (connexion au premier usage, ou /mcp dans Claude Code)"
    if ($existants -notmatch "21st:") {
        Write-Host ""
        Write-Host "  Cle API 21st.dev (sur https://21st.dev/mcp). Laisse vide pour passer :" -ForegroundColor Yellow
        $cle = Read-Host "  Cle"
        if ($cle) {
            claude mcp add 21st --scope user -e "API_KEY_21ST=$cle" -- cmd /c npx -y "@21st-dev/magic@latest" | Out-Null
            Ok "21st"
        } else { [void]$Manuel.Add("21st.dev : relance INSTALLER.bat quand tu as ta cle (https://21st.dev/mcp)") }
        Remove-Variable cle -ErrorAction SilentlyContinue
    } else { Ok "21st" }
    if ($existants -notmatch "rea:") { [void]$Manuel.Add("REA : lance  npx.cmd rea-agents setup  et coche uniquement Claude Code (Espace puis Entree)") }
    else { Ok "rea" }
}

# ---------------------------------------------------------------- 7. Connexions
Titre "7/7 Connexions"
if (A-Commande gh) {
    gh auth status 2>$null | Out-Null
    if ($LASTEXITCODE -ne 0) { [void]$Manuel.Add("GitHub : lance  gh auth login  (GitHub.com, HTTPS, Yes, Login with a web browser)") } else { Ok "GitHub connecte" }
}
if (-not (git config --global user.name)) {
    [void]$Manuel.Add("Git : git config --global user.name ""vad20""  puis  git config --global user.email ""ton@adresse""")
}
[void]$Manuel.Add("Orca (optionnel) : telecharge-le sur https://orca.dev/download")

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Installation terminee." -ForegroundColor Green
if ($Manuel.Count) {
    Write-Host "  A faire toi-meme (connexions personnelles) :" -ForegroundColor Yellow
    $i = 1; foreach ($m in $Manuel) { Write-Host "   $i. $m"; $i++ }
}
Write-Host "  Ferme et rouvre PowerShell et l'appli Claude pour tout prendre en compte."
Write-Host "============================================" -ForegroundColor Cyan
