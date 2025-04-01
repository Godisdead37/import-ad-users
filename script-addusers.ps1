# === CONFIGURATION ===
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$csvUsers = "$scriptDir\users.csv"
$csvAdmins = "$scriptDir\admin.csv"

# OU par défaut (MODIFIE ICI avec tes propres OUs !)
$defaultUserOU = "OU=Utilisateurs,DC=thor,DC=lan"
$defaultAdminOU = "OU=Admin,DC=thor,DC=lan"

# === FONCTIONS ===
function Check-FileExists {
    param ($filePath)
    if (!(Test-Path $filePath)) {
        Write-Host "❌ ERREUR : Le fichier $filePath est introuvable !" -ForegroundColor Red
        exit 1
    }
}

function Validate-User {
    param ($user)
    if (-not $user.SamAccountName -or -not $user.Prenom -or -not $user.Nom) {
        Write-Host "❌ ERREUR : L'utilisateur a des champs manquants ou vides (SamAccountName, Prenom, Nom)." -ForegroundColor Red
        return $false
    }
    return $true
}

function Import-User {
    param ($user, $ou)
    
    if (-not (Validate-User $user)) {
        return
    }

    Write-Host "📥 Importation de : $($user.SamAccountName) dans $ou" -ForegroundColor Cyan

    # Vérifie si l'utilisateur existe déjà
    if (Get-ADUser -Filter { SamAccountName -eq $user.SamAccountName } -ErrorAction SilentlyContinue) {
        Write-Host "⚠️ Utilisateur $($user.SamAccountName) existe déjà, saut..." -ForegroundColor Yellow
        return
    }

    # Création de l'utilisateur AD avec gestion des erreurs
    try {
        New-ADUser `
            -SamAccountName $user.SamAccountName `
            -UserPrincipalName "$($user.SamAccountName)@thor.lan" `
            -Name "$($user.Prenom) $($user.Nom)" `
            -GivenName $user.Prenom `
            -Surname $user.Nom `
            -Path $ou `
            -AccountPassword (ConvertTo-SecureString "P@ssword123" -AsPlainText -Force) `
            -Enabled $true
        Write-Host "✅ Utilisateur $($user.SamAccountName) importé !" -ForegroundColor Green
    } catch {
        Write-Host "❌ Échec pour $($user.SamAccountName) : $_" -ForegroundColor Red
    }
}

# === VÉRIFICATION DES FICHIERS ===
Check-FileExists $csvUsers
Check-FileExists $csvAdmins

# === IMPORTATION DES UTILISATEURS (TEST 3 UTILISATEURS) ===
$usersList = Import-Csv $csvUsers | Select-Object -First 3
$adminsList = Import-Csv $csvAdmins | Select-Object -First 3

Write-Host "🔍 Test d'importation de 3 utilisateurs..." -ForegroundColor Blue

foreach ($user in $usersList) { Import-User $user $defaultUserOU }
foreach ($admin in $adminsList) { Import-User $admin $defaultAdminOU }

Write-Host "🎉 Test terminé ! Vérifiez si les utilisateurs sont bien importés." -ForegroundColor Magenta
Write-Host "Appuyez sur Entrée pour quitter..." -ForegroundColor Yellow
Read-Host | Out-Null