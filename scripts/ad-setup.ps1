Import-Module ActiveDirectory

# Root domain DN
$root = "DC=LeonardLab,DC=com"

# === Create Top-Level OUs ===
$topLevelOUs = @(
    "HQ",
    "Lab",
    "Sales",
    "LA",
    "NY",
    "CEO",
    "Board",
    "ServiceAccounts"
)

$topLevelOUs | ForEach-Object {
    New-ADOrganizationalUnit -Name $_ -Path $root -ProtectedFromAccidentalDeletion $true -ErrorAction SilentlyContinue
}

# === Create Sub-OUs ===
$subOUs = @{
    "HQ" = @("Finance", "IT")
    "Finance" = @("Users", "Computers")
    "IT" = @("Users", "Computers")
    "Lab" = @("Users", "Computers")
    "Sales" = @("Users", "Computers")
    "CEO" = @("Users", "Computers")
}

foreach ($parent in $subOUs.Keys) {
    foreach ($child in $subOUs[$parent]) {
        $path = "OU=$parent,$root"
        New-ADOrganizationalUnit -Name $child -Path $path -ProtectedFromAccidentalDeletion $true -ErrorAction SilentlyContinue
    }
}

# === Create Security Groups ===
$groups = @(
    @{ Name = "IT-Admin"; OU = "IT"; Scope = "Global" },
    @{ Name = "IT-Standard"; OU = "IT"; Scope = "Global" },
    @{ Name = "Developers"; OU = "IT"; Scope = "Global" },
    @{ Name = "DBA"; OU = "IT"; Scope = "Global" },
    @{ Name = "CEO"; OU = "CEO"; Scope = "Global" }
)

foreach ($group in $groups) {
    $path = "OU=" + $group.OU + ",OU=HQ," + $root
    if ($group.OU -eq "CEO") { $path = "OU=CEO,$root" }
    New-ADGroup -Name $group.Name -GroupScope $group.Scope -GroupCategory Security -Path $path -ErrorAction SilentlyContinue
}

# === Create Sample Users (just a few from each OU) ===
$users = @(
    @{ Name = "Robert J. Leonard"; Sam = "rjleonard"; OU = "IT" },
    @{ Name = "Jim J. Thurgood"; Sam = "jjthurgood"; OU = "IT" },
    @{ Name = "Xi Yang"; Sam = "xyang"; OU = "IT" },
    @{ Name = "C.D. Powers"; Sam = "cdpowers"; OU = "CEO" },
    @{ Name = "M Dilbert"; Sam = "mdilbert"; OU = "IT" }
)

foreach ($user in $users) {
    $path = if ($user.OU -eq "CEO") { "OU=Users,OU=CEO,$root" } else { "OU=Users,OU=" + $user.OU + ",OU=HQ," + $root }
    New-ADUser -Name $user.Name -SamAccountName $user.Sam -UserPrincipalName "$($user.Sam)@leonardlab.com" `
        -AccountPassword (ConvertTo-SecureString "P@ssw0rd123" -AsPlainText -Force) `
        -Enabled $true -Path $path -ChangePasswordAtLogon $true -ErrorAction SilentlyContinue
}
