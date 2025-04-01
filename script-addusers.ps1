# === CONFIGURATION ===
$usersCSV = "C:\Users\louis\Desktop\scripting\import-ad-users\users.csv"
$adminsCSV = "C:\Users\louis\Desktop\scripting\import-ad-users\admin.csv"
$domain = "thor.lan"

# OU dans Active Directory
$OU_Users = "OU=Utilisateurs,DC=thor,DC=lan"
$OU_Admins = "OU=Admin,DC=thor,DC=lan"

# === VÉRIFICATION DES FICHIERS CSV ===
if (!(Test-Path $usersCSV) -or !(Test-Path $adminsCSV)) {
    Write-Host "❌ Fichiers CSV introuvables. Vérifiez les chemins." -ForegroundColor Red
    exit 1
}

Write-Host "✅ Fichiers CSV trouvés. Début de l'import..." -ForegroundColor Green

# === FONCTION POUR IMPORTER LES UTILISATEURS ===
function Import-Users {
    param ($CSVFile, $OU, $Limit)

    $users = Import-Csv $CSVFile | Select-Object -First $Limit
    foreach ($user in $users) {
        $userName = $user.Username
        $fullName = "$($user.FirstName) $($user.LastName)"
        $password = ConvertTo-SecureString $user.Password -AsPlainText -Force
        $UPN = "$userName@$domain"

        # Vérifie si l'utilisateur existe déjà
        if (Get-ADUser -Filter {SamAccountName -eq $userName}) {
            Write-Host "⚠️ Utilisateur $userName existe déjà. Skipping." -ForegroundColor Yellow
        } else {
            New-ADUser -SamAccountName $userName -UserPrincipalName $UPN `
                -Name $fullName -GivenName $user.FirstName -Surname $user.LastName `
                -AccountPassword $password -Path $OU -Enabled $true
            Write-Host "✅ Utilisateur $userName importé avec succès." -ForegroundColor Green
        }
    }
}

# === TEST : Importer 3 utilisateurs de chaque CSV ===
Import-Users -CSVFile $usersCSV -OU $OU_Users -Limit 3
Import-Users -CSVFile $adminsCSV -OU $OU_Admins -Limit 3

Write-Host "🎉 Import de test terminé. Vérifiez dans Active Directory." -ForegroundColor Cyan
