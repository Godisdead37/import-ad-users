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

function Import-User {
    param ($user, $ou)
    Write-Host "📥 Importation de : $($user.SamAccountName) dans $ou" -ForegroundColor Cyan

    # Vérifie si l'utilisateur existe déjà
    if (Get-ADUser -Filter {SamAccountName -eq $user.SamAccountName}) {
        Write-Host "⚠️ Utilisateur $($user.SamAccountName) existe déjà, saut..." -ForegroundColor Yellow
        return
    }

    # Création de l'utilisateur AD
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
