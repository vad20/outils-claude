# Envoie l'état actuel des skills, de la note et du dossier d'outils sur le dépôt GitHub privé.
# Lancer via SAUVEGARDER.bat après avoir ajouté ou modifié un outil.
$ErrorActionPreference = "Stop"
$Repo = $PSScriptRoot
$ClaudeDir = Join-Path $HOME ".claude"

# Sur un autre PC, le dossier peut être ailleurs : on remet les chemins sous la forme de référence
function Copie-Normalisee($from, $to) {
    $txt = [IO.File]::ReadAllText($from, [Text.Encoding]::UTF8)
    $txt = $txt.Replace($HOME, "C:\Users\vadim")
    [IO.File]::WriteAllText($to, $txt, (New-Object Text.UTF8Encoding($false)))
}

New-Item -ItemType Directory -Force "$Repo\config\skills" | Out-Null
# Miroir des skills (sauf "synced", géré par l'appli Claude)
robocopy "$ClaudeDir\skills" "$Repo\config\skills" /MIR /XD synced /NFL /NDL /NJH /NJS /NP | Out-Null
Copie-Normalisee "$ClaudeDir\CLAUDE.md" "$Repo\config\CLAUDE.md"

Set-Location $Repo
# L'antivirus bloque parfois brièvement l'écriture : on réessaie
$ok = $false
for ($i = 1; $i -le 5 -and -not $ok; $i++) {
    git add -A 2>$null
    if ($LASTEXITCODE -eq 0) { $ok = $true } else { Start-Sleep -Seconds 3 }
}
if (-not $ok) { Write-Host "Echec de git add (fichiers bloques). Relance SAUVEGARDER.bat dans un instant." -ForegroundColor Red; exit 1 }
git diff --cached --quiet
if ($LASTEXITCODE -eq 0) { Write-Host "Rien de nouveau a sauvegarder."; exit 0 }
git commit -q -m "Sauvegarde du $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
git push -q
Write-Host "Sauvegarde envoyee sur GitHub." -ForegroundColor Green
