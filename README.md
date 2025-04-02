# Script d'Importation d'Utilisateurs dans Active Directory

Ce script PowerShell permet d'importer des utilisateurs et des administrateurs dans Active Directory à partir de fichiers CSV. Il crée des comptes AD avec des noms d'utilisateur générés automatiquement (première lettre du prénom + nom de famille) et les place dans des unités d'organisation (OU) prédéfinies.

## Prérequis
- **Windows Server** avec le rôle **Active Directory Domain Services (ADDS)** installé et configuré.
- Module PowerShell **ActiveDirectory** installé (`Install-Module -Name ActiveDirectory` si nécessaire).
- Droits d'**administrateur** pour exécuter le script et créer des utilisateurs dans AD.
- Deux fichiers CSV :
  - `users.csv` : Liste des utilisateurs standards.
  - `admin.csv` : Liste des administrateurs.

### Structure des fichiers CSV
Les fichiers CSV doivent avoir les colonnes suivantes :
- `first_name` : Prénom de l'utilisateur.
- `last_name` : Nom de famille de l'utilisateur.
- `password` : Mot de passe initial de l'utilisateur.

Exemple de `users.csv` :
```
first_name,last_name,password
Jean,Dupont,Pass123!
Marie,Durand,Secure456!
```

Exemple de `admin.csv` :
```
first_name,last_name,password
Admin,System,Admin789!
```

## Utilisation
1. Placez le script (`ImportADUsers.ps1`) dans un dossier avec les fichiers `users.csv` et `admin.csv`.
2. Ouvrez PowerShell en mode administrateur.
3. Naviguez vers le dossier du script :
   ```powershell
   cd C:\chemin\vers\le\dossier
   ```
4. Exécutez le script :
   ```powershell
   .\ImportADUsers.ps1
   ```

## Fonctionnement
- **Vérification des fichiers** : Le script vérifie que `users.csv` et `admin.csv` existent dans le même dossier que le script.
- **Validation des données** : Chaque utilisateur est validé pour s'assurer que les champs obligatoires (`first_name`, `last_name`, `password`) sont présents.
- **Création des comptes** :
  - Les utilisateurs standards sont placés dans `OU=Utilisateurs,DC=thor,DC=lan`.
  - Les administrateurs sont placés dans `OU=Admin,DC=thor,DC=lan`.
  - Le `SamAccountName` est généré comme suit : première lettre du prénom + nom de famille (en minuscules, ex. `jdupont` pour Jean Dupont).
  - Si un utilisateur existe déjà, il est ignoré.
- **Sortie colorée** : Messages d'état en
