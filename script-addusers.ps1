# === CONFIGURATION ===
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$csvUsers = "$scriptDir\users.csv"
$csvAdmins = "$scriptDir\admin.csv"

$defaultUserOU = "OU=Utilisateurs,DC=thor,DC=lan"
$defaultAdminOU = "OU=Admin,DC=thor,DC=lan"

# === FONCTIONS ===

# Vérifie si un fichier existe
function Check-FileExists {
    param ($filePath)
    if (!(Test-Path $filePath)) {
        Write-Host "❌ ERREUR : Le fichier $filePath est introuvable !" -ForegroundColor Red
        exit 1
    }
}

# Valide les champs obligatoires d'un utilisateur
function Validate-User {
    param ($user)
    if (-not $user.SamAccountName -or -not $user.Prenom -or -not $user.Nom) {
        Write-Host "❌ ERREUR : Champs manquants pour l'utilisateur : $($user | Out-String)" -ForegroundColor Red
        return $false
    }
    return $true
}

# Importe un utilisateur dans Active Directory
function Import-User {
    param ($user, $ou)

    if (-not (Validate-User $user)) { return }

    if (Get-ADUser -Filter { SamAccountName -eq $user.SamAccountName } -ErrorAction SilentlyContinue) {
        Write-Host "⚠️ Utilisateur $($user.SamAccountName) existe déjà, saut..." -ForegroundColor Yellow
        return
    }

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
        Write-Host "✅ Utilisateur $($user.SamAccountName) importé avec succès !" -ForegroundColor Green
    } catch {
        Write-Host "❌ Échec de l'importation pour $($user.SamAccountName) : $_" -ForegroundColor Red
    }
}

# === EXÉCUTION ===

# Vérifie les fichiers CSV
Check-FileExists $csvUsers
Check-FileExists $csvAdmins

# Charge les utilisateurs depuis les fichiers CSV
$usersList = Import-Csv $csvUsers
$adminsList = Import-Csv $csvAdmins

Write-Host "📥 Début de l'importation des utilisateurs..." -ForegroundColor Blue

# Importe les utilisateurs et les administrateurs
foreach ($user in $usersList) { Import-User $user $defaultUserOU }
foreach ($admin in $adminsList) { Import-User $admin $defaultAdminOU }

Write-Host "🎉 Importation terminée !" -ForegroundColor Magenta