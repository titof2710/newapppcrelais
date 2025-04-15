# Script PowerShell pour nettoyer les caractères de contrôle d'un fichier
$inputFile = "pc_relais_app\lib\screens\admin\users_management_screen.dart"
$outputFile = "pc_relais_app\lib\screens\admin\users_management_screen_clean.dart"

# Lire le contenu du fichier
$content = Get-Content -Path $inputFile -Raw

# Remplacer les caractères de contrôle par des espaces
$cleanContent = $content -replace "[\x00-\x1F]", " "

# Écrire le contenu nettoyé dans le fichier de sortie
$cleanContent | Set-Content -Path $outputFile -NoNewline

Write-Host "Fichier nettoyé créé: $outputFile"
