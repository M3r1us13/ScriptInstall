# Terminal animation + Windows Toolkit
# Compatibil cu Windows PowerShell 5.1 si PowerShell 7

$ErrorActionPreference = 'SilentlyContinue'

$logoColor = [ConsoleColor]::DarkYellow
$textColor = [ConsoleColor]::Gray
$labelColor = [ConsoleColor]::DarkGray
$accentColor = [ConsoleColor]::Yellow
$commandColor = [ConsoleColor]::Gray

$logo = @(
    '                 .o+'
    '                `ooo/'
    '               `+oooo:'
    '              `+oooooo:'
    '              -+oooooo+:'
    '            `/:-:++oooo+:'
    '           `/++++/+++++++:'
    '          `/++++++++++++++:'
    '         `/+++ooooooooooooo/'
    '        ./ooosssso++osssssso+'
    '       .oossssso-````/ossssss+'
    '      -osssssso.      :ssssssso.'
    '     :osssssss/        osssso++.'
    '    /ossssssss/        +ssssooo-'
    '  `/ossssso+/:-        -:/+osssso+'
    ' `+sso+:-`                 `.-/+oso:'
    '`++:.                           `-/+/'
    '.`                                 `/'
)

function Get-SafeConsoleSize {
    try { return @([Console]::WindowWidth, [Console]::WindowHeight) }
    catch { return @(120, 30) }
}

function Set-SafeCursor {
    param([int]$X, [int]$Y)
    try {
        $size = Get-SafeConsoleSize
        $width = [int]$size[0]
        $height = [int]$size[1]
        if ($width -lt 1 -or $height -lt 1) { return }
        if ($X -lt 0) { $X = 0 }
        if ($Y -lt 0) { $Y = 0 }
        if ($X -ge $width) { $X = $width - 1 }
        if ($Y -ge $height) { $Y = $height - 1 }
        [Console]::SetCursorPosition($X, $Y)
    }
    catch { }
}

function Write-At {
    param(
        [int]$X,
        [int]$Y,
        [string]$Text,
        [ConsoleColor]$Color = [ConsoleColor]::Gray
    )
    Set-SafeCursor -X $X -Y $Y
    try {
        [Console]::ForegroundColor = $Color
        [Console]::Write($Text)
    }
    catch { Write-Host -NoNewline $Text }
}

$computerName = if ($env:COMPUTERNAME) { $env:COMPUTERNAME } else { 'Computer' }
$userName = if ($env:USERNAME) { $env:USERNAME } else { 'User' }
$os = Get-CimInstance Win32_OperatingSystem
$computer = Get-CimInstance Win32_ComputerSystem
$processor = Get-CimInstance Win32_Processor | Select-Object -First 1
$osName = if ($os.Caption) { $os.Caption } else { 'Windows' }
$osVersion = if ($os.Version) { $os.Version } else { 'Unknown' }
$cpuName = if ($processor.Name) { $processor.Name.Trim() } else { 'Unknown' }
$memoryGB = if ($computer.TotalPhysicalMemory) { [math]::Round($computer.TotalPhysicalMemory / 1GB, 1) } else { 'Unknown' }

$info = @(
    "$userName@$computerName"
    '------------------------'
    "OS: $osName"
    "Version: $osVersion"
    "Host: $computerName"
    'Kernel: Windows'
    'Shell: PowerShell'
    "CPU: $cpuName"
    "Memory: $memoryGB GB"
    ''
    'Theme: Dark Terminal'
    'Animation: Enabled'
)

Clear-Host
try {
    [Console]::BackgroundColor = [ConsoleColor]::Black
    [Console]::ForegroundColor = $textColor
    [Console]::CursorVisible = $false
}
catch { }

$leftX = 2
$topY = 2
$rightX = 42

for ($index = 0; $index -lt $info.Count; $index++) {
    $color = if ($index -lt 2) { $accentColor } else { $textColor }
    Write-At -X $rightX -Y ($topY + $index) -Text $info[$index] -Color $color
}

for ($lineIndex = 0; $lineIndex -lt $logo.Count; $lineIndex++) {
    $line = $logo[$lineIndex]
    for ($length = 1; $length -le $line.Length; $length++) {
        Write-At -X $leftX -Y ($topY + $lineIndex) -Text $line.Substring(0, $length) -Color $logoColor
        Start-Sleep -Milliseconds 10
    }
}

$barY = $topY + $info.Count + 1
$barX = $rightX
$barColors = @(
    [ConsoleColor]::DarkRed, [ConsoleColor]::Red,
    [ConsoleColor]::DarkYellow, [ConsoleColor]::Yellow,
    [ConsoleColor]::DarkGreen, [ConsoleColor]::Green,
    [ConsoleColor]::DarkCyan, [ConsoleColor]::Cyan,
    [ConsoleColor]::DarkBlue, [ConsoleColor]::Blue,
    [ConsoleColor]::DarkMagenta, [ConsoleColor]::Magenta
)
for ($index = 0; $index -lt $barColors.Count; $index++) {
    Write-At -X ($barX + ($index * 4)) -Y $barY -Text '    ' -Color $barColors[$index]
}

$promptY = $barY + 3
$prompt = "$userName@$computerName ~\projects\neofetch > "
Write-At -X $leftX -Y $promptY -Text $prompt -Color $labelColor
$command = ' powershell.exe -NoProfile'
$commandX = $leftX + $prompt.Length
for ($index = 1; $index -le $command.Length; $index++) {
    Write-At -X $commandX -Y $promptY -Text $command.Substring(0, $index) -Color $commandColor
    Start-Sleep -Milliseconds 25
}
$cursorX = $commandX + $command.Length
for ($index = 1; $index -le 4; $index++) {
    $cursor = if (($index % 2) -eq 1) { '_' } else { ' ' }
    Write-At -X $cursorX -Y $promptY -Text $cursor -Color $accentColor
    Start-Sleep -Milliseconds 200
}
try { [Console]::CursorVisible = $true } catch { }

# ==============================
# Windows Toolkit GUI
# ==============================
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

function Show-Status {
    param([string]$Message)
    if ($script:statusLabel) { $script:statusLabel.Text = $Message }
}

function Install-WingetPackage {
    param([string]$Id, [string]$Name)
    if (-not (Get-Command winget.exe -ErrorAction SilentlyContinue)) {
        [System.Windows.Forms.MessageBox]::Show('winget nu este instalat. Instaleaza App Installer din Microsoft Store.','Windows Toolkit')
        return
    }
    Show-Status "Se instaleaza $Name..."
    Start-Process winget.exe -ArgumentList "install --id $Id --exact --accept-package-agreements --accept-source-agreements" -Wait
}

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Windows Toolkit'
$form.Size = New-Object System.Drawing.Size(620, 545)
$form.StartPosition = 'CenterScreen'
$form.MaximizeBox = $false
$form.FormBorderStyle = 'FixedSingle'

$tabs = New-Object System.Windows.Forms.TabControl
$tabs.Location = New-Object System.Drawing.Point(10, 10)
$tabs.Size = New-Object System.Drawing.Size(585, 450)
$form.Controls.Add($tabs)

# 1. Install Apps
$tabApps = New-Object System.Windows.Forms.TabPage
$tabApps.Text = 'Install Apps'
[void]$tabs.TabPages.Add($tabApps)
$appList = @(
    @('Google Chrome','Google.Chrome'),
    @('Brave','Brave.Brave'),
    @('Adobe Acrobat Reader','Adobe.Acrobat.Reader.64-bit'),
    @('TeamViewer','TeamViewer.TeamViewer'),
    @('AnyDesk','AnyDeskSoftwareGmbH.AnyDesk'),
    @('WinRAR','RARLab.WinRAR'),
    @('VLC Media Player','VideoLAN.VLC'),
    @('7-Zip','7zip.7zip'),
    @('Spotify','Spotify.Spotify'),
    @('Notepad++','Notepad++.Notepad++')
)
$appChecks = @()
for ($i = 0; $i -lt $appList.Count; $i++) {
    $check = New-Object System.Windows.Forms.CheckBox
    $check.Text = $appList[$i][0]
    $check.Tag = $appList[$i][1]
    $check.Location = New-Object System.Drawing.Point(25, (15 + ($i * 29)))
    $check.AutoSize = $true
    $tabApps.Controls.Add($check)
    $appChecks += $check
}
$installButton = New-Object System.Windows.Forms.Button
$installButton.Text = 'Install Selected'
$installButton.Size = New-Object System.Drawing.Size(160, 38)
$installButton.Location = New-Object System.Drawing.Point(205, 325)
$tabApps.Controls.Add($installButton)
$installButton.Add_Click({
    $selected = @($appChecks | Where-Object { $_.Checked })
    if ($selected.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show('Selecteaza cel putin o aplicatie.','Windows Toolkit')
        return
    }
    foreach ($item in $selected) { Install-WingetPackage -Id $item.Tag -Name $item.Text }
    Show-Status 'Instalarea aplicatiilor s-a terminat.'
})
# 2. System
$tabSystem = New-Object System.Windows.Forms.TabPage
$tabSystem.Text = 'System'
[void]$tabs.TabPages.Add($tabSystem)

# ==============================
# Curatare fisiere temporare
# ==============================

$tempCheck = New-Object System.Windows.Forms.CheckBox
$tempCheck.Text = 'Remove Temporary Files'
$tempCheck.Location = New-Object System.Drawing.Point(25, 25)
$tempCheck.AutoSize = $true
$tabSystem.Controls.Add($tempCheck)

$cleanButton = New-Object System.Windows.Forms.Button
$cleanButton.Text = 'Clean Temp'
$cleanButton.Location = New-Object System.Drawing.Point(25, 60)
$cleanButton.Size = New-Object System.Drawing.Size(130, 35)
$tabSystem.Controls.Add($cleanButton)

$cleanButton.Add_Click({
    if (-not $tempCheck.Checked) {
        [System.Windows.Forms.MessageBox]::Show(
            'Bifeaza Remove Temporary Files mai intai.',
            'Windows Toolkit'
        )
        return
    }

Show-Status 'Se curata fisierele temporare...'

Remove-Item `
        -Path "$env:TEMP\*" `
        -Recurse `
        -Force `
        -ErrorAction SilentlyContinue

Remove-Item `
        -Path "$env:WINDIR\Temp\*" `
        -Recurse `
        -Force `
        -ErrorAction SilentlyContinue

Show-Status 'Fisierele temporare au fost curatate.'
})

# ==============================
# Dark Mode
# ==============================

$darkCheck = New-Object System.Windows.Forms.CheckBox
$darkCheck.Text = 'Dark Mode'
$darkCheck.Location = New-Object System.Drawing.Point(25, 120)
$darkCheck.AutoSize = $true
$tabSystem.Controls.Add($darkCheck)

$darkButton = New-Object System.Windows.Forms.Button
$darkButton.Text = 'Apply Dark Mode'
$darkButton.Location = New-Object System.Drawing.Point(25, 155)
$darkButton.Size = New-Object System.Drawing.Size(140, 35)
$tabSystem.Controls.Add($darkButton)

$darkButton.Add_Click({
    if (-not $darkCheck.Checked) {
        [System.Windows.Forms.MessageBox]::Show(
            'Bifeaza Dark Mode mai intai.',
            'Windows Toolkit'
        )
        return
    }

$darkPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize'

New-Item `
        -Path $darkPath `
        -Force `
        -ErrorAction SilentlyContinue | Out-Null

Set-ItemProperty `
        -Path $darkPath `
        -Name 'AppsUseLightTheme' `
        -Value 0 `
        -Type DWord

Set-ItemProperty `
        -Path $darkPath `
        -Name 'SystemUsesLightTheme' `
        -Value 0 `
        -Type DWord

Show-Status 'Dark Mode a fost aplicat.'
})

# ==============================
# Functie pentru restart Explorer
# ==============================

# ==============================
# Restart Explorer fara fereastra File Explorer
# ==============================

$script:explorerRestartInProgress = $false

function Restart-ExplorerInstant {
    if ($script:explorerRestartInProgress) {
        return
    }

$script:explorerRestartInProgress = $true

try {
        Show-Status 'Se aplica modificarea meniului...'

# Inchide procesul Explorer
        Stop-Process `
            -Name 'explorer' `
            -Force `
            -ErrorAction SilentlyContinue

# Asteapta inchiderea completa a procesului
        $waitCount = 0

while (
            (Get-Process -Name 'explorer' -ErrorAction SilentlyContinue) `
            -and ($waitCount -lt 50)
        ) {
            Start-Sleep -Milliseconds 100
            $waitCount++
        }

Start-Sleep -Milliseconds 500

# Reporneste shell-ul Windows fara fereastra Home
        $explorerPath = Join-Path $env:WINDIR 'explorer.exe'

Start-Process `
            -FilePath $explorerPath `
            -ArgumentList '/restart' `
            -WindowStyle Hidden `
            -ErrorAction SilentlyContinue

Start-Sleep -Milliseconds 1200

Show-Status 'Modificarea meniului contextual a fost aplicata.'
    }
    finally {
        $script:explorerRestartInProgress = $false
    }
}


# ==============================
# Meniu contextual vechi
# ==============================

$oldMenuLabel = New-Object System.Windows.Forms.Label
$oldMenuLabel.Text = 'Context Menu:'
$oldMenuLabel.Location = New-Object System.Drawing.Point(25, 215)
$oldMenuLabel.AutoSize = $true
$tabSystem.Controls.Add($oldMenuLabel)

$oldMenuButton = New-Object System.Windows.Forms.Button
$oldMenuButton.Text = 'Enable Old Menu'
$oldMenuButton.Location = New-Object System.Drawing.Point(25, 245)
$oldMenuButton.Size = New-Object System.Drawing.Size(150, 38)
$tabSystem.Controls.Add($oldMenuButton)

$oldMenuButton.Add_Click({
    if ($script:explorerRestartInProgress) {
        return
    }

try {
        $oldMenuPath = 'HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32'

New-Item `
            -Path $oldMenuPath `
            -Force `
            -ErrorAction Stop | Out-Null

Set-Item `
            -Path $oldMenuPath `
            -Value '' `
            -ErrorAction Stop

Restart-ExplorerInstant

Show-Status 'Meniul contextual vechi a fost activat instant.'
    }
    catch {
        Show-Status 'Activarea meniului vechi a esuat.'

[System.Windows.Forms.MessageBox]::Show(
            $_.Exception.Message,
            'Windows Toolkit - Eroare'
        )
    }
})

$restoreMenuButton = New-Object System.Windows.Forms.Button
$restoreMenuButton.Text = 'Restore Windows 11'
$restoreMenuButton.Location = New-Object System.Drawing.Point(190, 245)
$restoreMenuButton.Size = New-Object System.Drawing.Size(165, 38)
$tabSystem.Controls.Add($restoreMenuButton)

$restoreMenuButton.Add_Click({
    if ($script:explorerRestartInProgress) {
        return
    }

try {
        $oldMenuRoot = 'HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}'

Remove-Item `
            -Path $oldMenuRoot `
            -Recurse `
            -Force `
            -ErrorAction SilentlyContinue

Restart-ExplorerInstant

Show-Status 'Meniul Windows 11 a fost restaurat instant.'
    }
    catch {
        Show-Status 'Restaurarea meniului Windows 11 a esuat.'

[System.Windows.Forms.MessageBox]::Show(
            $_.Exception.Message,
            'Windows Toolkit - Eroare'
        )
    }
})

# 3. Performance
$tabPerformance = New-Object System.Windows.Forms.TabPage
$tabPerformance.Text = 'Performance'
[void]$tabs.TabPages.Add($tabPerformance)

$performanceLabel = New-Object System.Windows.Forms.Label
$performanceLabel.Text = 'Optiuni pentru performanta si alimentare:'
$performanceLabel.Location = New-Object System.Drawing.Point(25, 25)
$performanceLabel.AutoSize = $true
$tabPerformance.Controls.Add($performanceLabel)

# ==================================================
# Backup si utilitare pentru setarile de alimentare
# ==================================================

$powerBackupPath = 'HKCU:\Software\WindowsToolkit\PowerBackup'

function Test-HasBattery {
    return ($null -ne (Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue))
}

function Get-ActiveSchemeGuid {
    $out = (powercfg /getactivescheme 2>$null) -join ' '
    if ($out -match '([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})') {
        return $Matches[1]
    }
    return $null
}

function Get-PowerTimeouts {
    $map = @{
        Monitor   = @('SUB_VIDEO', 'VIDEOIDLE')
        Standby   = @('SUB_SLEEP', 'STANDBYIDLE')
        Disk      = @('SUB_DISK', 'DISKIDLE')
        Hibernate = @('SUB_SLEEP', 'HIBERNATEIDLE')
    }

$result = @{}

foreach ($key in $map.Keys) {
        $out = (powercfg /q SCHEME_CURRENT $map[$key][0] $map[$key][1] 2>$null) -join ' '
        $ac = '0x00000000'
        $dc = '0x00000000'

if ($out -match 'AC.*?(0x[0-9a-fA-F]+)') { $ac = $Matches[1] }
        if ($out -match 'DC.*?(0x[0-9a-fA-F]+)') { $dc = $Matches[1] }

$result[$key] = @($ac, $dc)
    }

return $result
}

function Save-PowerBackup {
    if (Test-Path $powerBackupPath) { return }

New-Item -Path $powerBackupPath -Force -ErrorAction SilentlyContinue | Out-Null

$scheme = Get-ActiveSchemeGuid
    if ($scheme) {
        Set-ItemProperty -Path $powerBackupPath -Name 'ActiveScheme' -Value $scheme
    }

$timeouts = Get-PowerTimeouts

Set-ItemProperty -Path $powerBackupPath -Name 'MonitorAC'   -Value $timeouts.Monitor[0]
    Set-ItemProperty -Path $powerBackupPath -Name 'MonitorDC'   -Value $timeouts.Monitor[1]
    Set-ItemProperty -Path $powerBackupPath -Name 'StandbyAC'   -Value $timeouts.Standby[0]
    Set-ItemProperty -Path $powerBackupPath -Name 'StandbyDC'   -Value $timeouts.Standby[1]
    Set-ItemProperty -Path $powerBackupPath -Name 'DiskAC'      -Value $timeouts.Disk[0]
    Set-ItemProperty -Path $powerBackupPath -Name 'DiskDC'      -Value $timeouts.Disk[1]
    Set-ItemProperty -Path $powerBackupPath -Name 'HibernateAC' -Value $timeouts.Hibernate[0]
    Set-ItemProperty -Path $powerBackupPath -Name 'HibernateDC' -Value $timeouts.Hibernate[1]
}

function Set-PowerTimeouts {
    param([hashtable]$Minutes)

powercfg /change monitor-timeout-ac     $Minutes.Monitor[0]   | Out-Null
    powercfg /change monitor-timeout-dc     $Minutes.Monitor[1]   | Out-Null
    powercfg /change standby-timeout-ac     $Minutes.Standby[0]   | Out-Null
    powercfg /change standby-timeout-dc     $Minutes.Standby[1]   | Out-Null
    powercfg /change disk-timeout-ac        $Minutes.Disk[0]      | Out-Null
    powercfg /change disk-timeout-dc        $Minutes.Disk[1]      | Out-Null
    powercfg /change hibernate-timeout-ac   $Minutes.Hibernate[0] | Out-Null
    powercfg /change hibernate-timeout-dc   $Minutes.Hibernate[1] | Out-Null
}

function Get-Or-Create-UltimateScheme {
    if (Test-Path $powerBackupPath) {
        $existing = (Get-ItemProperty -Path $powerBackupPath -ErrorAction SilentlyContinue).UltimateGuid
        if ($existing) { return $existing }
    }

$ultimateSource = 'e9a42b02-d5df-448d-aa00-03f14749eb61'
    $dupOut = (powercfg /duplicatescheme $ultimateSource 2>$null) -join ' '

if ($dupOut -match '([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})') {
        $guid = $Matches[1]

if (Test-Path $powerBackupPath) {
            Set-ItemProperty -Path $powerBackupPath -Name 'UltimateGuid' -Value $guid
        }

return $guid
    }

return $null
}

function Restore-PowerBackup {
    if (-not (Test-Path $powerBackupPath)) { return $false }

$props = Get-ItemProperty -Path $powerBackupPath -ErrorAction SilentlyContinue

if ($props.ActiveScheme) {
        powercfg /setactive $props.ActiveScheme | Out-Null
    }

$monitorAc   = [int]([Convert]::ToInt64($props.MonitorAC, 16) / 60)
    $monitorDc   = [int]([Convert]::ToInt64($props.MonitorDC, 16) / 60)
    $standbyAc   = [int]([Convert]::ToInt64($props.StandbyAC, 16) / 60)
    $standbyDc   = [int]([Convert]::ToInt64($props.StandbyDC, 16) / 60)
    $diskAc      = [int]([Convert]::ToInt64($props.DiskAC, 16) / 60)
    $diskDc      = [int]([Convert]::ToInt64($props.DiskDC, 16) / 60)
    $hibernateAc = [int]([Convert]::ToInt64($props.HibernateAC, 16) / 60)
    $hibernateDc = [int]([Convert]::ToInt64($props.HibernateDC, 16) / 60)

Set-PowerTimeouts @{
        Monitor   = @($monitorAc, $monitorDc)
        Standby   = @($standbyAc, $standbyDc)
        Disk      = @($diskAc, $diskDc)
        Hibernate = @($hibernateAc, $hibernateDc)
    }

Remove-Item -Path $powerBackupPath -Recurse -Force -ErrorAction SilentlyContinue

return $true
}

# ==================================================
# Maximum Performance
# ==================================================

$maxButton = New-Object System.Windows.Forms.Button
$maxButton.Text = 'Maximum Performance'
$maxButton.Location = New-Object System.Drawing.Point(25, 65)
$maxButton.Size = New-Object System.Drawing.Size(190, 40)
$tabPerformance.Controls.Add($maxButton)

$maxButton.Add_Click({
    try {
        Show-Status 'Se aplica performanta maxima...'

Save-PowerBackup

$ultimate = Get-Or-Create-UltimateScheme

if ($ultimate) {
            powercfg /setactive $ultimate | Out-Null
        }
        else {
            powercfg /setactive SCHEME_MIN | Out-Null
        }

if (Test-HasBattery) {
            Set-PowerTimeouts @{
                Monitor   = @(0, 5)
                Standby   = @(0, 15)
                Disk      = @(0, 10)
                Hibernate = @(0, 180)
            }

Show-Status 'Performanta maxima pe priza. Pe baterie: valori moderate pentru a proteja bateria.'
        }
        else {
            Set-PowerTimeouts @{
                Monitor   = @(0, 0)
                Standby   = @(0, 0)
                Disk      = @(0, 0)
                Hibernate = @(0, 0)
            }

Show-Status 'Performanta maxima activata. Monitorul, sleep-ul si discul nu se opresc.'
        }
    }
    catch {
        Show-Status 'Activarea performantei maxime a esuat.'

[System.Windows.Forms.MessageBox]::Show(
            $_.Exception.Message,
            'Windows Toolkit - Eroare'
        )
    }
})

# ==================================================
# Recommended Settings (Balanced)
# ==================================================

$balancedButton = New-Object System.Windows.Forms.Button
$balancedButton.Text = 'Recommended Settings'
$balancedButton.Location = New-Object System.Drawing.Point(230, 65)
$balancedButton.Size = New-Object System.Drawing.Size(190, 40)
$tabPerformance.Controls.Add($balancedButton)

$balancedButton.Add_Click({
    try {
        Show-Status 'Se aplica setarile recomandate...'

Save-PowerBackup

powercfg /setactive SCHEME_BALANCED | Out-Null

if (Test-HasBattery) {
            Set-PowerTimeouts @{
                Monitor   = @(10, 5)
                Standby   = @(30, 15)
                Disk      = @(20, 10)
                Hibernate = @(360, 180)
            }
        }
        else {
            Set-PowerTimeouts @{
                Monitor   = @(10, 10)
                Standby   = @(30, 30)
                Disk      = @(20, 20)
                Hibernate = @(360, 360)
            }
        }

Show-Status 'Planul Balanced si setarile recomandate au fost activate.'
    }
    catch {
        Show-Status 'Activarea planului Balanced a esuat.'

[System.Windows.Forms.MessageBox]::Show(
            $_.Exception.Message,
            'Windows Toolkit - Eroare'
        )
    }
})

# ==================================================
# Restore Initial Settings
# ==================================================

$restorePowerButton = New-Object System.Windows.Forms.Button
$restorePowerButton.Text = 'Restore Initial Settings'
$restorePowerButton.Location = New-Object System.Drawing.Point(25, 115)
$restorePowerButton.Size = New-Object System.Drawing.Size(190, 40)
$tabPerformance.Controls.Add($restorePowerButton)

$restorePowerButton.Add_Click({
    try {
        Show-Status 'Se restaureaza setarile initiale...'

$restored = Restore-PowerBackup

if ($restored) {
            Show-Status 'Setarile initiale de alimentare au fost restaurate.'
        }
        else {
            [System.Windows.Forms.MessageBox]::Show(
                'Nu exista setari salvate. Nu ai folosit inca Maximum Performance sau Recommended Settings.',
                'Windows Toolkit'
            )

Show-Status 'Nu exista setari salvate de restaurat.'
        }
    }
    catch {
        Show-Status 'Restaurarea setarilor initiale a esuat.'

[System.Windows.Forms.MessageBox]::Show(
            $_.Exception.Message,
            'Windows Toolkit - Eroare'
        )
    }
})


# 4. Office
$tabOffice = New-Object System.Windows.Forms.TabPage
$tabOffice.Text = 'Office'
[void]$tabs.TabPages.Add($tabOffice)
$officeLabel = New-Object System.Windows.Forms.Label
$officeLabel.Text = 'Microsoft Office se descarca numai din surse oficiale:'
$officeLabel.Location = New-Object System.Drawing.Point(25, 25)
$officeLabel.AutoSize = $true
$tabOffice.Controls.Add($officeLabel)
$officeButton = New-Object System.Windows.Forms.Button
$officeButton.Text = 'Open Office.com'
$officeButton.Location = New-Object System.Drawing.Point(25, 65)
$officeButton.Size = New-Object System.Drawing.Size(180, 40)
$tabOffice.Controls.Add($officeButton)
$officeButton.Add_Click({
    Start-Process 'https://www.office.com/'
    Show-Status 'Pagina oficiala Office a fost deschisa.'
})
$microsoft365Button = New-Object System.Windows.Forms.Button
$microsoft365Button.Text = 'Microsoft 365 Download'
$microsoft365Button.Location = New-Object System.Drawing.Point(220, 65)
$microsoft365Button.Size = New-Object System.Drawing.Size(190, 40)
$tabOffice.Controls.Add($microsoft365Button)
$microsoft365Button.Add_Click({
    Start-Process 'https://account.microsoft.com/services/'
    Show-Status 'Pagina oficiala pentru servicii Microsoft a fost deschisa.'
})

# 5. Activare Windows cu licenta proprie
$tabActivation = New-Object System.Windows.Forms.TabPage
$tabActivation.Text = 'Windows Activation'
[void]$tabs.TabPages.Add($tabActivation)
$activationLabel = New-Object System.Windows.Forms.Label
$activationLabel.Text = 'Introdu numai o cheie Windows valida pe care o detii:'
$activationLabel.Location = New-Object System.Drawing.Point(25, 25)
$activationLabel.AutoSize = $true
$tabActivation.Controls.Add($activationLabel)
$keyBox = New-Object System.Windows.Forms.TextBox
$keyBox.Location = New-Object System.Drawing.Point(25, 65)
$keyBox.Size = New-Object System.Drawing.Size(270, 25)
$tabActivation.Controls.Add($keyBox)
$activateButton = New-Object System.Windows.Forms.Button
$activateButton.Text = 'Activate With My Key'
$activateButton.Location = New-Object System.Drawing.Point(25, 105)
$activateButton.Size = New-Object System.Drawing.Size(180, 38)
$tabActivation.Controls.Add($activateButton)
$activateButton.Add_Click({
    $key = $keyBox.Text.Trim()
    if ($key -notmatch '^[A-Za-z0-9]{5}(-[A-Za-z0-9]{5}){4}$') {
        [System.Windows.Forms.MessageBox]::Show('Introdu o cheie in format XXXXX-XXXXX-XXXXX-XXXXX-XXXXX.','Windows Toolkit')
        return
    }
    Show-Status 'Se trimite cheia catre Windows...'
    & cscript.exe //nologo "$env:SystemRoot\System32\slmgr.vbs" /ipk $key | Out-Null
    & cscript.exe //nologo "$env:SystemRoot\System32\slmgr.vbs" /ato | Out-Null
    Show-Status 'Cererea a fost trimisa. Verifica notificarea Windows.'
})

$script:statusLabel = New-Object System.Windows.Forms.Label
$script:statusLabel.Text = 'Gata.'
$script:statusLabel.Location = New-Object System.Drawing.Point(15, 475)
$script:statusLabel.AutoSize = $true
$form.Controls.Add($script:statusLabel)

[void]$form.ShowDialog()
try { [Console]::ForegroundColor = [ConsoleColor]::Gray } catch { }