# Terminal animation + Windows Toolkit
# Compatibil cu Windows PowerShell 5.1 si PowerShell 7

$ErrorActionPreference = 'Continue'


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
$os = Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue
$computer = Get-CimInstance Win32_ComputerSystem -ErrorAction SilentlyContinue
$processor = Get-CimInstance Win32_Processor -ErrorAction SilentlyContinue | Select-Object -First 1
$board = Get-CimInstance Win32_BaseBoard -ErrorAction SilentlyContinue | Select-Object -First 1
$bios = Get-CimInstance Win32_BIOS -ErrorAction SilentlyContinue | Select-Object -First 1
$videoAdapters = @(Get-CimInstance Win32_VideoController -ErrorAction SilentlyContinue)
$systemDrive = if ($os -and $os.SystemDrive) { $os.SystemDrive } else { $env:SystemDrive }
$systemDisk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='$systemDrive'" -ErrorAction SilentlyContinue
$osDetails = Get-ItemProperty `
    -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' `
    -ErrorAction SilentlyContinue

$osName = if ($os -and $os.Caption) { $os.Caption.Trim() } else { 'Unavailable' }
$osVersion = if ($os -and $os.Version) { $os.Version } else { 'Unavailable' }
$osBuild = if ($os -and $os.BuildNumber) { $os.BuildNumber } else { 'Unavailable' }
$osRelease = if ($osDetails -and $osDetails.DisplayVersion) { $osDetails.DisplayVersion } elseif ($osDetails -and $osDetails.ReleaseId) { $osDetails.ReleaseId } else { 'Unavailable' }
$architecture = if ($os -and $os.OSArchitecture) { $os.OSArchitecture } else { 'Unavailable' }
$systemModel = if ($computer -and $computer.Model) { $computer.Model.Trim() } else { 'Unavailable' }
$systemManufacturer = if ($computer -and $computer.Manufacturer) { $computer.Manufacturer.Trim() } else { 'Unavailable' }
$cpuName = if ($processor -and $processor.Name) { $processor.Name.Trim() } else { 'Unavailable' }
$cpuCores = if ($processor -and $processor.NumberOfCores) { $processor.NumberOfCores } else { 'Unavailable' }
$cpuThreads = if ($processor -and $processor.NumberOfLogicalProcessors) { $processor.NumberOfLogicalProcessors } else { 'Unavailable' }
$cpuSpeed = if ($processor -and $processor.MaxClockSpeed) { '{0:N2} GHz' -f ($processor.MaxClockSpeed / 1000) } else { 'Unavailable' }
$memoryTotal = if ($computer -and $computer.TotalPhysicalMemory) { [math]::Round($computer.TotalPhysicalMemory / 1GB, 1) } else { $null }
$memoryFree = if ($os -and $os.FreePhysicalMemory) { [math]::Round($os.FreePhysicalMemory / 1MB, 1) } else { $null }
$memoryInUse = if ($null -ne $memoryTotal -and $null -ne $memoryFree) { [math]::Round($memoryTotal - $memoryFree, 1) } else { $null }
$memoryDetails = if ($null -ne $memoryTotal -and $null -ne $memoryFree) {
    "$memoryInUse GB used / $memoryFree GB free / $memoryTotal GB total"
}
elseif ($null -ne $memoryTotal) {
    "$memoryTotal GB total"
}
else {
    'Unavailable'
}
$gpuNames = @($videoAdapters | Where-Object { $_.Name } | ForEach-Object { $_.Name.Trim() } | Select-Object -Unique)
$gpuDetails = if ($gpuNames.Count -gt 0) { $gpuNames -join ', ' } else { 'Unavailable' }
$boardDetails = if ($board -and ($board.Manufacturer -or $board.Product)) {
    (@($board.Manufacturer, $board.Product) | Where-Object { $_ }) -join ' '
}
else {
    'Unavailable'
}
$biosDetails = if ($bios) {
    $biosValues = @($bios.Manufacturer, $bios.SMBIOSBIOSVersion) | Where-Object { $_ }
    if ($bios.ReleaseDate) {
        $biosValues += ([datetime]$bios.ReleaseDate).ToString('yyyy-MM-dd')
    }
    if ($biosValues.Count -gt 0) { $biosValues -join ' / ' } else { 'Unavailable' }
}
else {
    'Unavailable'
}
$storageDetails = if ($systemDisk -and $systemDisk.Size -gt 0) {
    '{0}: {1:N1} GB free / {2:N1} GB total' -f $systemDrive, ($systemDisk.FreeSpace / 1GB), ($systemDisk.Size / 1GB)
}
else {
    'Unavailable'
}
$uptimeDetails = if ($os -and $os.LastBootUpTime) {
    $uptime = (Get-Date) - $os.LastBootUpTime
    '{0}d {1}h {2}m' -f [math]::Floor($uptime.TotalDays), $uptime.Hours, $uptime.Minutes
}
else {
    'Unavailable'
}
$powerDetails = if ($computer -and $computer.PCSystemType -in @(2, 8)) { 'Laptop' } else { 'Desktop / other' }

$infoEntries = @(
    @{ Label = "$userName@$computerName"; Value = '' }
    @{ Label = '------------------------'; Value = '' }
    @{ Label = 'OS'; Value = $osName }
    @{ Label = 'Release / build'; Value = "$osRelease / $osBuild ($osVersion)" }
    @{ Label = 'Architecture'; Value = $architecture }
    @{ Label = 'Device'; Value = "$systemManufacturer $systemModel" }
    @{ Label = 'Device type'; Value = $powerDetails }
    @{ Label = 'CPU'; Value = "$cpuName ($cpuCores cores / $cpuThreads threads, up to $cpuSpeed)" }
    @{ Label = 'Memory'; Value = $memoryDetails }
    @{ Label = 'GPU'; Value = $gpuDetails }
    @{ Label = 'Motherboard'; Value = $boardDetails }
    @{ Label = 'BIOS'; Value = $biosDetails }
    @{ Label = 'System drive'; Value = $storageDetails }
    @{ Label = 'Uptime'; Value = $uptimeDetails }
    @{ Label = 'Shell'; Value = "PowerShell $($PSVersionTable.PSVersion)" }
    @{ Label = 'Theme'; Value = 'Dark Terminal' }
)

$leftX = 2
$topY = 2
$rightX = 42
$consoleSize = Get-SafeConsoleSize
$maxInfoWidth = [math]::Max(24, [int]$consoleSize[0] - $rightX - 2)
$info = New-Object System.Collections.Generic.List[string]
foreach ($entry in $infoEntries) {
    $text = if ($entry.Value) { '{0}: {1}' -f $entry.Label, $entry.Value } else { $entry.Label }
    while ($text.Length -gt $maxInfoWidth) {
        $breakAt = $text.LastIndexOf(' ', $maxInfoWidth)
        if ($breakAt -lt 1) { $breakAt = $maxInfoWidth }
        $info.Add($text.Substring(0, $breakAt))
        $text = '  ' + $text.Substring($breakAt).TrimStart()
    }
    $info.Add($text)
}

Clear-Host
try {
    [Console]::BackgroundColor = [ConsoleColor]::Black
    [Console]::ForegroundColor = $textColor
    [Console]::CursorVisible = $false
}
catch { }

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

$barY = $topY + [math]::Max($logo.Count, $info.Count) + 1
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

$promptY = $barY + 2
$prompt = "$userName@$computerName ~\projects\scriptinstall > "
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

# ==============================
# Windows Toolkit GUI
# ==============================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

[System.Windows.Forms.Application]::EnableVisualStyles()

# ==============================
# Afisare status
# ==============================

function Show-Status {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

if ($null -ne $script:statusLabel) {
        $script:statusLabel.Text = $Message
        $script:statusLabel.Refresh()
    }
}

# ==============================
# Descarcare fisier
# ==============================

function Invoke-RemoteFileDownload {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Url,

[Parameter(Mandatory = $true)]
        [string]$Destination
    )

try {
        $folder = Split-Path `
            -Path $Destination `
            -Parent

if (-not (Test-Path -LiteralPath $folder)) {
            New-Item `
                -Path $folder `
                -ItemType Directory `
                -Force `
                -ErrorAction Stop | Out-Null
        }

Show-Status `
            -Message "Se descarca $([System.IO.Path]::GetFileName($Destination))..."

$bitsCommand = Get-Command `
            -Name 'Start-BitsTransfer' `
            -ErrorAction SilentlyContinue

if ($null -ne $bitsCommand) {
            try {
                Start-BitsTransfer `
                    -Source $Url `
                    -Destination $Destination `
                    -DisplayName 'Windows Toolkit' `
                    -Description 'Descarcare fisier' `
                    -ErrorAction Stop
            }
            catch {
                Show-Status `
                    -Message 'BITS a esuat. Se foloseste descarcarea alternativa.'

Invoke-WebRequest `
                    -Uri $Url `
                    -OutFile $Destination `
                    -UseBasicParsing `
                    -ErrorAction Stop
            }
        }
        else {
            Invoke-WebRequest `
                -Uri $Url `
                -OutFile $Destination `
                -UseBasicParsing `
                -ErrorAction Stop
        }

if (-not (Test-Path -LiteralPath $Destination)) {
            throw "Fisierul nu a fost gasit dupa descarcare: $Destination"
        }

if ((Get-Item -LiteralPath $Destination -ErrorAction Stop).Length -eq 0) {
            throw "Fisierul descarcat este gol: $Destination"
        }

Show-Status -Message 'Descarcarea s-a terminat.'
        return $true
    }
    catch {
        Show-Status -Message 'Descarcarea a esuat.'

[System.Windows.Forms.MessageBox]::Show(
            "Eroare la descarcare:`r`n$($_.Exception.Message)",
            'Windows Toolkit - Eroare',
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        ) | Out-Null

return $false
    }
}

# ==============================
# Creare shortcut pe Desktop
# ==============================

function New-DesktopShortcutFromStartMenu {
    param(
        [Parameter(Mandatory = $true)]
        [string]$AppName
    )

try {
        $desktopPath = [Environment]::GetFolderPath('Desktop')

if ([string]::IsNullOrWhiteSpace($desktopPath)) {
            return $false
        }

$startMenuPaths = @(
            (
                Join-Path `
                    -Path $env:APPDATA `
                    -ChildPath 'Microsoft\Windows\Start Menu\Programs'
            ),
            (
                Join-Path `
                    -Path $env:ProgramData `
                    -ChildPath 'Microsoft\Windows\Start Menu\Programs'
            )
        )

$shortcut = $null

foreach ($startMenuPath in $startMenuPaths) {
            if (-not (Test-Path -LiteralPath $startMenuPath)) {
                continue
            }

$shortcut = Get-ChildItem `
                -Path $startMenuPath `
                -Filter '*.lnk' `
                -File `
                -Recurse `
                -ErrorAction SilentlyContinue |
                Where-Object {
                    $_.BaseName -like "*$AppName*"
                } |
                Select-Object -First 1

if ($null -ne $shortcut) {
                break
            }
        }

if ($null -eq $shortcut) {
            return $false
        }

$desktopShortcut = Join-Path `
            -Path $desktopPath `
            -ChildPath $shortcut.Name

Copy-Item `
            -Path $shortcut.FullName `
            -Destination $desktopShortcut `
            -Force `
            -ErrorAction Stop

return $true
    }
    catch {
        return $false
    }
}

# ==============================
# Instalare aplicatie prin winget
# ==============================

function Ensure-WingetAvailable {
    $wingetCommand = Get-Command `
        -Name 'winget.exe' `
        -ErrorAction SilentlyContinue

    if ($null -ne $wingetCommand) {
        return $wingetCommand.Source
    }

    $installerPath = Join-Path `
        -Path ([System.IO.Path]::GetTempPath()) `
        -ChildPath ('WindowsToolkit-AppInstaller_{0}.msixbundle' -f [Guid]::NewGuid().ToString('N'))
    $storeUrl = 'https://apps.microsoft.com/detail/9nblggh4nns1'
    $registrationError = $null

    try {
        Show-Status -Message 'Se configureaza Microsoft App Installer...'

        try {
            Add-AppxPackage `
                -RegisterByFamilyName `
                -MainPackage 'Microsoft.DesktopAppInstaller_8wekyb3d8bbwe' `
                -ErrorAction Stop
        }
        catch {
            $registrationError = $_.Exception.Message
        }

        for ($attempt = 0; $attempt -lt 5; $attempt++) {
            $wingetCommand = Get-Command `
                -Name 'winget.exe' `
                -ErrorAction SilentlyContinue

            if ($null -ne $wingetCommand) {
                return $wingetCommand.Source
            }

            Start-Sleep -Seconds 1
        }

        $downloaded = Invoke-RemoteFileDownload `
            -Url 'https://aka.ms/getwinget' `
            -Destination $installerPath

        if (-not $downloaded) {
            throw 'Pachetul Microsoft App Installer nu a putut fi descarcat.'
        }

        Show-Status -Message 'Se instaleaza Microsoft App Installer...'
        Add-AppxPackage `
            -Path $installerPath `
            -ErrorAction Stop

        for ($attempt = 0; $attempt -lt 10; $attempt++) {
            $wingetCommand = Get-Command `
                -Name 'winget.exe' `
                -ErrorAction SilentlyContinue

            if ($null -ne $wingetCommand) {
                break
            }

            Start-Sleep -Seconds 1
        }

        if ($null -eq $wingetCommand) {
            Add-AppxPackage `
                -RegisterByFamilyName `
                -MainPackage 'Microsoft.DesktopAppInstaller_8wekyb3d8bbwe' `
                -ErrorAction Stop

            for ($attempt = 0; $attempt -lt 5; $attempt++) {
                $wingetCommand = Get-Command `
                    -Name 'winget.exe' `
                    -ErrorAction SilentlyContinue

                if ($null -ne $wingetCommand) {
                    break
                }

                Start-Sleep -Seconds 1
            }
        }

        if ($null -eq $wingetCommand) {
            throw 'App Installer a fost instalat, dar winget nu este disponibil in aceasta sesiune.'
        }

        return $wingetCommand.Source
    }
    catch {
        $details = $_.Exception.Message
        if ($registrationError) {
            $details = "$details`r`nInregistrarea initiala: $registrationError"
        }

        throw "Nu s-a putut instala sau configura automat Microsoft App Installer. $details`r`nInstaleaza-l din Microsoft Store: $storeUrl"
    }
    finally {
        if (Test-Path -LiteralPath $installerPath -PathType Leaf) {
            try {
                Remove-Item `
                    -LiteralPath $installerPath `
                    -Force `
                    -ErrorAction Stop
            }
            catch {
                Write-Warning "Nu s-a putut sterge pachetul temporar $installerPath : $($_.Exception.Message)"
            }
        }
    }
}

function Install-WingetPackage {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Id,

        [Parameter(Mandatory = $true)]
        [string]$Name,

        [string]$Architecture = ''
    )

    $wingetCommand = Get-Command `
        -Name 'winget.exe' `
        -ErrorAction SilentlyContinue

    if ($null -eq $wingetCommand) {
        throw 'winget nu este disponibil dupa configurarea Microsoft App Installer.'
    }

    try {
        Show-Status -Message "Se instaleaza $Name..."

        $arguments = @(
            'install'
            '--id'
            $Id
            '--exact'
            '--silent'
            '--accept-package-agreements'
            '--accept-source-agreements'
            '--disable-interactivity'
        )

        if ($Architecture) {
            $arguments += @('--architecture', $Architecture)
        }

        $process = Start-Process `
            -FilePath $wingetCommand.Source `
            -ArgumentList $arguments `
            -Wait `
            -PassThru `
            -WindowStyle Hidden

        if ($process.ExitCode -ne 0 -and $process.ExitCode -ne 3010) {
            Show-Status `
                -Message "Instalarea pentru $Name a esuat. Cod: $($process.ExitCode)"

            return $false
        }

        Show-Status `
            -Message "$Name a fost instalat. Se cauta shortcut-ul..."

        Start-Sleep -Seconds 3

        $shortcutCreated = New-DesktopShortcutFromStartMenu `
            -AppName $Name

        if ($shortcutCreated) {
            Show-Status `
                -Message "$Name a fost instalat si shortcut-ul a fost creat pe Desktop."
        }
        else {
            Show-Status `
                -Message "$Name a fost instalat, dar shortcut-ul nu a fost gasit."
        }

        return $true
    }
    catch {
        Show-Status `
            -Message "Instalarea pentru $Name a esuat."

        [System.Windows.Forms.MessageBox]::Show(
            "Eroare la instalarea aplicatiei ${Name}:`r`n$($_.Exception.Message)",
            'Windows Toolkit - Eroare',
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        ) | Out-Null

        return $false
    }
}


function New-DesktopShortcutFromStartMenu {
    param(
        [Parameter(Mandatory = $true)]
        [string]$AppName
    )

try {
        $desktopPath = [Environment]::GetFolderPath('Desktop')

$startMenuPaths = @(
            "$env:APPDATA\Microsoft\Windows\Start Menu\Programs",
            "$env:ProgramData\Microsoft\Windows\Start Menu\Programs"
        )

$shortcut = $null

foreach ($startMenuPath in $startMenuPaths) {
            if (-not (Test-Path $startMenuPath)) {
                continue
            }

$shortcut = Get-ChildItem `
                -Path $startMenuPath `
                -Filter '*.lnk' `
                -File `
                -Recurse `
                -ErrorAction SilentlyContinue |
                Where-Object {
                    $_.BaseName -like "*$AppName*"
                } |
                Select-Object -First 1

if ($shortcut) {
                break
            }
        }

if (-not $shortcut) {
            return $false
        }

$desktopShortcut = Join-Path `
            $desktopPath `
            ($shortcut.Name)

Copy-Item `
            -Path $shortcut.FullName `
            -Destination $desktopShortcut `
            -Force `
            -ErrorAction Stop

return $true
    }
    catch {
        return $false
    }
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
    [PSCustomObject]@{ Name = 'Google Chrome'; Id = 'Google.Chrome'; Architecture = '' },
    [PSCustomObject]@{ Name = 'Brave'; Id = 'Brave.Brave'; Architecture = '' },
    [PSCustomObject]@{ Name = 'Adobe Acrobat Reader'; Id = 'Adobe.Acrobat.Reader.64-bit'; Architecture = '' },
    [PSCustomObject]@{ Name = 'TeamViewer'; Id = 'TeamViewer.TeamViewer'; Architecture = '' },
    [PSCustomObject]@{ Name = 'UltraViewer'; Id = 'DucFabulous.UltraViewer'; Architecture = '' },
    [PSCustomObject]@{ Name = 'AnyDesk'; Id = 'AnyDeskSoftwareGmbH.AnyDesk'; Architecture = '' },
    [PSCustomObject]@{ Name = 'WinRAR'; Id = 'RARLab.WinRAR'; Architecture = '' },
    [PSCustomObject]@{ Name = 'VLC Media Player'; Id = 'VideoLAN.VLC'; Architecture = '' },
    [PSCustomObject]@{ Name = '7-Zip'; Id = '7zip.7zip'; Architecture = '' },
    [PSCustomObject]@{ Name = 'Spotify'; Id = 'Spotify.Spotify'; Architecture = '' },
    [PSCustomObject]@{ Name = 'Notepad++'; Id = 'Notepad++.Notepad++'; Architecture = '' },
    [PSCustomObject]@{ Name = 'Java 8 x64 (Temurin / AdoptOpenJDK)'; Id = 'EclipseAdoptium.Temurin.8.JRE'; Architecture = 'x64' },
    [PSCustomObject]@{ Name = 'Google Earth Pro'; Id = 'Google.EarthPro'; Architecture = '' },
    [PSCustomObject]@{ Name = 'Winamp'; Id = 'Winamp.Winamp'; Architecture = '' },
    [PSCustomObject]@{ Name = 'Malwarebytes'; Id = 'Malwarebytes.Malwarebytes'; Architecture = '' },
    [PSCustomObject]@{ Name = 'Steam'; Id = 'Valve.Steam'; Architecture = '' }
)

$appChecks = @()
$leftColumnCount = [int][Math]::Ceiling($appList.Count / 2)

for ($i = 0; $i -lt $appList.Count; $i++) {
    if ($i -lt $leftColumnCount) {
        $columnX = 20
        $row = $i
    }
    else {
        $columnX = 300
        $row = $i - $leftColumnCount
    }

    $app = $appList[$i]
    $check = New-Object System.Windows.Forms.CheckBox
    $check.Text = $app.Name
    $check.Tag = $app
    $check.Location = New-Object System.Drawing.Point(
        $columnX,
        (15 + ($row * 32))
    )
    $check.Size = New-Object System.Drawing.Size(260, 24)
    $check.UseVisualStyleBackColor = $true

    $tabApps.Controls.Add($check)
    $appChecks += $check

}

$installButton = New-Object System.Windows.Forms.Button
$installButton.Text = 'Install Selected'
$installButton.Size = New-Object System.Drawing.Size(160, 38)
$installButton.Location = New-Object System.Drawing.Point(205, 320)
$tabApps.Controls.Add($installButton)

$installButton.Add_Click({
    $selected = @(
        $appChecks |
            Where-Object { $_.Checked }
    )

if ($selected.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show(
            'Selecteaza cel putin o aplicatie.',
            'Windows Toolkit'
        )
        return
    }

$installButton.Enabled = $false

try {
        try {
            Ensure-WingetAvailable | Out-Null
        }
        catch {
            Show-Status 'Nu s-a putut pregati Microsoft App Installer.'
            [System.Windows.Forms.MessageBox]::Show(
                $_.Exception.Message,
                'Windows Toolkit - Eroare',
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Error
            ) | Out-Null
            return
        }

        $failedApps = @()
        foreach ($item in $selected) {
            $installed = Install-WingetPackage `
                -Id $item.Tag.Id `
                -Name $item.Tag.Name `
                -Architecture $item.Tag.Architecture

            if (-not $installed) {
                $failedApps += $item.Tag.Name
            }
        }

        if ($failedApps.Count -gt 0) {
            Show-Status "Instalare terminata. Esuate: $($failedApps -join ', ')"
        }
        else {
            Show-Status 'Instalarea aplicatiilor s-a terminat.'
        }
    }
    finally {
        $installButton.Enabled = $true
    }
})

# 2. System
$tabSystem = New-Object System.Windows.Forms.TabPage
$tabSystem.Text = 'System'
[void]$tabs.TabPages.Add($tabSystem)

# ==================================================
# Curatare fisiere temporare
# ==================================================

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

try {
        Show-Status 'Se curata fisierele temporare...'

$userTempPath = Join-Path $env:TEMP '*'
        $windowsTempPath = Join-Path $env:WINDIR 'Temp\*'

Remove-Item `
            -Path $userTempPath `
            -Recurse `
            -Force `
            -ErrorAction SilentlyContinue

Remove-Item `
            -Path $windowsTempPath `
            -Recurse `
            -Force `
            -ErrorAction SilentlyContinue

Show-Status 'Fisierele temporare au fost curatate.'
    }
    catch {
        Show-Status 'Curatarea fisierelor temporare a esuat.'

[System.Windows.Forms.MessageBox]::Show(
            $_.Exception.Message,
            'Windows Toolkit - Eroare'
        )
    }
})

# ==================================================
# Dark Mode
# ==================================================

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

try {
        $darkPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize'

New-Item `
            -Path $darkPath `
            -Force `
            -ErrorAction Stop | Out-Null

Set-ItemProperty `
            -Path $darkPath `
            -Name 'AppsUseLightTheme' `
            -Value 0 `
            -Type DWord `
            -ErrorAction Stop

Set-ItemProperty `
            -Path $darkPath `
            -Name 'SystemUsesLightTheme' `
            -Value 0 `
            -Type DWord `
            -ErrorAction Stop

# Reimprospatare non-destructiva a parametrilor Windows.
        # Nu inchide Explorer si nu afecteaza wallpaper-ul.
        Start-Process `
            -FilePath "$env:WINDIR\System32\rundll32.exe" `
            -ArgumentList 'user32.dll,UpdatePerUserSystemParameters' `
            -WindowStyle Hidden `
            -Wait `
            -ErrorAction SilentlyContinue

Show-Status 'Dark Mode a fost aplicat.'
    }
    catch {
        Show-Status 'Aplicarea Dark Mode a esuat.'

[System.Windows.Forms.MessageBox]::Show(
            $_.Exception.Message,
            'Windows Toolkit - Eroare'
        )
    }
})

# ==============================
# Meniu contextual Windows 11
# ==============================

$oldMenuSubKey = 'Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}'
$oldMenuInprocSubKey = "$oldMenuSubKey\InprocServer32"
$windowsBuild = 0
[void][int]::TryParse([string]$os.BuildNumber, [ref]$windowsBuild)

$oldMenuLabel = New-Object System.Windows.Forms.Label
$oldMenuLabel.Text = 'Windows 11 context menu:'
$oldMenuLabel.Location = New-Object System.Drawing.Point(25, 215)
$oldMenuLabel.AutoSize = $true
$tabSystem.Controls.Add($oldMenuLabel)

$oldMenuInfoLabel = New-Object System.Windows.Forms.Label
$oldMenuInfoLabel.Text = if ($windowsBuild -ge 22000) {
    'Explorer se va reporni. Politicile Windows pot bloca modificarea.'
}
else {
    'Optiunile sunt doar pentru Windows 11; Windows 10 foloseste deja meniul clasic.'
}
$oldMenuInfoLabel.Location = New-Object System.Drawing.Point(25, 235)
$oldMenuInfoLabel.AutoSize = $true
$tabSystem.Controls.Add($oldMenuInfoLabel)

function Restart-ExplorerForMenuChange {
    $currentSessionId = (Get-Process -Id $PID -ErrorAction Stop).SessionId
    $explorerProcesses = @(
        Get-Process -Name explorer -ErrorAction SilentlyContinue |
            Where-Object { $_.SessionId -eq $currentSessionId }
    )
    foreach ($explorerProcess in $explorerProcesses) {
        Stop-Process -Id $explorerProcess.Id -Force -ErrorAction Stop
    }

    foreach ($explorerProcess in $explorerProcesses) {
        try {
            Wait-Process -Id $explorerProcess.Id -Timeout 10 -ErrorAction Stop
        }
        catch {
            if (Get-Process -Id $explorerProcess.Id -ErrorAction SilentlyContinue) {
                throw "Explorer (PID $($explorerProcess.Id)) nu s-a inchis."
            }
        }
    }

    if (-not (
        Get-Process -Name explorer -ErrorAction SilentlyContinue |
            Where-Object { $_.SessionId -eq $currentSessionId }
    )) {
        Start-Process -FilePath "$env:WINDIR\explorer.exe" -ErrorAction Stop
    }

    $deadline = (Get-Date).AddSeconds(15)
    while (-not (
        Get-Process -Name explorer -ErrorAction SilentlyContinue |
            Where-Object { $_.SessionId -eq $currentSessionId }
    )) {
        if ((Get-Date) -ge $deadline) {
            throw 'Explorer nu a repornit in intervalul asteptat.'
        }
        Start-Sleep -Milliseconds 250
    }
}

function Set-Windows11ContextMenu {
    param(
        [Parameter(Mandatory = $true)]
        [bool]$UseClassicMenu
    )

    if ($windowsBuild -lt 22000) {
        throw 'Aceasta setare este doar pentru Windows 11. Windows 10 foloseste deja meniul contextual clasic.'
    }

    $registryKey = $null
    try {
        $registryKey = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey($oldMenuInprocSubKey, $UseClassicMenu)
        $currentlyClassic = $false
        $hasDefaultValue = $false
        if ($null -ne $registryKey) {
            $hasDefaultValue = $registryKey.GetValueNames() -contains ''
            if ($hasDefaultValue) {
                $defaultValue = $registryKey.GetValue('', $null)
                $currentlyClassic = ($defaultValue -is [string] -and $defaultValue -eq '')
            }
            $registryKey.Close()
            $registryKey = $null
        }

        if ($currentlyClassic -eq $UseClassicMenu) {
            return $false
        }

        if ($UseClassicMenu) {
            if ($hasDefaultValue) {
                throw 'Cheia meniului contextual este folosita deja de alta configuratie. Nu am modificat-o.'
            }

            $registryKey = [Microsoft.Win32.Registry]::CurrentUser.CreateSubKey($oldMenuInprocSubKey)
            if ($null -eq $registryKey) {
                throw 'Nu s-a putut crea cheia de registru pentru meniul clasic.'
            }

            $registryKey.SetValue('', '', [Microsoft.Win32.RegistryValueKind]::String)
            $registryKey.Flush()
        }
        else {
            $registryKey = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey($oldMenuInprocSubKey, $true)
            if ($null -eq $registryKey) {
                throw 'Nu s-a mai gasit cheia meniului contextual pentru restaurare.'
            }
            $registryKey.DeleteValue('', $false)
            $registryKey.Flush()
            $registryKey.Close()
            $registryKey = $null

            $registryKey = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey($oldMenuInprocSubKey, $false)
            $inprocIsEmpty = $null -ne $registryKey -and
                $registryKey.GetValueNames().Length -eq 0 -and
                $registryKey.GetSubKeyNames().Length -eq 0
            if ($null -ne $registryKey) {
                $registryKey.Close()
                $registryKey = $null
            }
            if ($inprocIsEmpty) {
                [Microsoft.Win32.Registry]::CurrentUser.DeleteSubKey($oldMenuInprocSubKey, $false)
            }

            $registryKey = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey($oldMenuSubKey, $false)
            $rootIsEmpty = $null -ne $registryKey -and
                $registryKey.GetValueNames().Length -eq 0 -and
                $registryKey.GetSubKeyNames().Length -eq 0
            if ($null -ne $registryKey) {
                $registryKey.Close()
                $registryKey = $null
            }
            if ($rootIsEmpty) {
                [Microsoft.Win32.Registry]::CurrentUser.DeleteSubKey($oldMenuSubKey, $false)
            }
        }

        $registryKey = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey($oldMenuInprocSubKey, $false)
        $classicMenuIsSet = $false
        if ($null -ne $registryKey) {
            if ($registryKey.GetValueNames() -contains '') {
                $defaultValue = $registryKey.GetValue('', $null)
                $classicMenuIsSet = ($defaultValue -is [string] -and $defaultValue -eq '')
            }
            $registryKey.Close()
            $registryKey = $null
        }

        if ($classicMenuIsSet -ne $UseClassicMenu) {
            throw 'Verificarea setarii din registru nu a reusit.'
        }

        return $true
    }
    finally {
        if ($null -ne $registryKey) {
            $registryKey.Close()
        }
    }
}

$oldMenuButton = New-Object System.Windows.Forms.Button
$oldMenuButton.Text = 'Activeaza meniul clasic'
$oldMenuButton.Location = New-Object System.Drawing.Point(25, 265)
$oldMenuButton.Size = New-Object System.Drawing.Size(165, 38)
$oldMenuButton.Enabled = $windowsBuild -ge 22000
$tabSystem.Controls.Add($oldMenuButton)

$oldMenuButton.Add_Click({
    $confirmation = [System.Windows.Forms.MessageBox]::Show(
        'Se va activa meniul contextual clasic si se va reporni Explorer. Ferestrele File Explorer deschise se pot inchide. Continui?',
        'Confirmare - Meniu clasic',
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Question,
        [System.Windows.Forms.MessageBoxDefaultButton]::Button2
    )
    if ($confirmation -ne [System.Windows.Forms.DialogResult]::Yes) {
        return
    }

    $oldMenuButton.Enabled = $false
    $restoreMenuButton.Enabled = $false
    try {
        Show-Status 'Se activeaza meniul contextual clasic...'
        $changed = Set-Windows11ContextMenu -UseClassicMenu $true
        if ($changed) {
            Restart-ExplorerForMenuChange
            Show-Status 'Meniul contextual clasic este activ. Explorer a repornit.'
        }
        else {
            Show-Status 'Meniul contextual clasic este deja activ.'
        }
    }
    catch {
        Show-Status 'Activarea meniului contextual clasic a esuat.'
        [System.Windows.Forms.MessageBox]::Show(
            "Eroare la activarea meniului contextual clasic:`r`n$($_.Exception.Message)",
            'Windows Toolkit - Eroare',
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        ) | Out-Null
    }
    finally {
        $oldMenuButton.Enabled = $true
        $restoreMenuButton.Enabled = $true
    }
})

$restoreMenuButton = New-Object System.Windows.Forms.Button
$restoreMenuButton.Text = 'Meniu nou Windows 11'
$restoreMenuButton.Location = New-Object System.Drawing.Point(190, 265)
$restoreMenuButton.Size = New-Object System.Drawing.Size(175, 38)
$restoreMenuButton.Enabled = $windowsBuild -ge 22000
$tabSystem.Controls.Add($restoreMenuButton)

$restoreMenuButton.Add_Click({
    $confirmation = [System.Windows.Forms.MessageBox]::Show(
        'Se va elimina modificarea meniului clasic si se va reporni Explorer. Ferestrele File Explorer deschise se pot inchide. Continui?',
        'Confirmare - Meniu Windows 11',
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Question,
        [System.Windows.Forms.MessageBoxDefaultButton]::Button2
    )
    if ($confirmation -ne [System.Windows.Forms.DialogResult]::Yes) {
        return
    }

    $oldMenuButton.Enabled = $false
    $restoreMenuButton.Enabled = $false
    try {
        Show-Status 'Se restaureaza meniul contextual Windows 11...'
        $changed = Set-Windows11ContextMenu -UseClassicMenu $false
        if ($changed) {
            Restart-ExplorerForMenuChange
            Show-Status 'Meniul contextual Windows 11 este activ. Explorer a repornit.'
        }
        else {
            Show-Status 'Meniul contextual Windows 11 este deja activ.'
        }
    }
    catch {
        Show-Status 'Restaurarea meniului contextual Windows 11 a esuat.'
        [System.Windows.Forms.MessageBox]::Show(
            "Eroare la restaurarea meniului contextual Windows 11:`r`n$($_.Exception.Message)",
            'Windows Toolkit - Eroare',
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        ) | Out-Null
    }
    finally {
        $oldMenuButton.Enabled = $true
        $restoreMenuButton.Enabled = $true
    }
})




# 3. Performance
$tabPerformance = New-Object System.Windows.Forms.TabPage
$tabPerformance.Text = 'Performance'
[void]$tabs.TabPages.Add($tabPerformance)

$performanceLabel = New-Object System.Windows.Forms.Label
$performanceLabel.Text = 'Alege un profil pentru performanta sau alimentare:'
$performanceLabel.Location = New-Object System.Drawing.Point(25, 25)
$performanceLabel.AutoSize = $true
$tabPerformance.Controls.Add($performanceLabel)

$performanceInfoLabel = New-Object System.Windows.Forms.Label
$performanceInfoLabel.Text = 'Maximum Performance activeaza planul Ultimate (poate consuma mai multa baterie). Never modifica doar setarile la priza.'
$performanceInfoLabel.Location = New-Object System.Drawing.Point(25, 45)
$performanceInfoLabel.Size = New-Object System.Drawing.Size(530, 32)
$tabPerformance.Controls.Add($performanceInfoLabel)

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

function Refresh-PowerSettingsPage {
    $activeScheme = Get-ActiveSchemeGuid
    if (-not $activeScheme) {
        throw 'Nu s-a putut identifica planul de alimentare activ pentru actualizarea setarilor Windows.'
    }

    & powercfg /setactive $activeScheme | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Nu s-a putut reactiva planul de alimentare pentru actualizarea setarilor Windows (cod $LASTEXITCODE)."
    }

    Start-Process `
        -FilePath 'ms-settings:powersleep' `
        -ErrorAction Stop
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

    $settings = @(
        [PSCustomObject]@{ Name = 'monitor-timeout-ac'; Value = $Minutes.Monitor[0] }
        [PSCustomObject]@{ Name = 'monitor-timeout-dc'; Value = $Minutes.Monitor[1] }
        [PSCustomObject]@{ Name = 'standby-timeout-ac'; Value = $Minutes.Standby[0] }
        [PSCustomObject]@{ Name = 'standby-timeout-dc'; Value = $Minutes.Standby[1] }
        [PSCustomObject]@{ Name = 'disk-timeout-ac'; Value = $Minutes.Disk[0] }
        [PSCustomObject]@{ Name = 'disk-timeout-dc'; Value = $Minutes.Disk[1] }
        [PSCustomObject]@{ Name = 'hibernate-timeout-ac'; Value = $Minutes.Hibernate[0] }
        [PSCustomObject]@{ Name = 'hibernate-timeout-dc'; Value = $Minutes.Hibernate[1] }
    )

    foreach ($setting in $settings) {
        & powercfg /change $setting.Name $setting.Value | Out-Null
        if ($LASTEXITCODE -ne 0) {
            throw "powercfg nu a putut modifica setarea $($setting.Name) (cod $LASTEXITCODE)."
        }
    }
}

function Set-PowerTimeoutsNeverOnAc {
    $settings = @(
        'monitor-timeout-ac'
        'standby-timeout-ac'
        'hibernate-timeout-ac'
    )

    foreach ($setting in $settings) {
        & powercfg /change $setting 0 | Out-Null
        if ($LASTEXITCODE -ne 0) {
            throw "powercfg nu a putut seta $setting la Never (cod $LASTEXITCODE)."
        }
    }
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
$maxButton.Location = New-Object System.Drawing.Point(25, 85)
$maxButton.Size = New-Object System.Drawing.Size(190, 40)
$tabPerformance.Controls.Add($maxButton)

$maxButton.Add_Click({
    try {
        Show-Status 'Se aplica performanta maxima...'

Save-PowerBackup

$ultimate = Get-Or-Create-UltimateScheme

if ($ultimate) {
            & powercfg /setactive $ultimate | Out-Null
        }
        else {
            & powercfg /setactive SCHEME_MIN | Out-Null
        }

        if ($LASTEXITCODE -ne 0) {
            throw "Nu s-a putut activa planul de performanta (cod $LASTEXITCODE)."
        }

if (Test-HasBattery) {
            Set-PowerTimeouts @{
                Monitor   = @(0, 5)
                Standby   = @(0, 15)
                Disk      = @(0, 10)
                Hibernate = @(0, 180)
            }

Show-Status 'Planul Ultimate Performance este activ. La priza nu se opreste ecranul sau PC-ul; pe baterie, oprirea automata ramane activa.'
        }
        else {
            Set-PowerTimeouts @{
                Monitor   = @(0, 0)
                Standby   = @(0, 0)
                Disk      = @(0, 0)
                Hibernate = @(0, 0)
            }

Show-Status 'Planul Ultimate Performance este activ. Oprirea automata a ecranului si a PC-ului este dezactivata.'
        }

        Refresh-PowerSettingsPage
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
$balancedButton.Location = New-Object System.Drawing.Point(230, 85)
$balancedButton.Size = New-Object System.Drawing.Size(190, 40)
$tabPerformance.Controls.Add($balancedButton)

$balancedButton.Add_Click({
    try {
        Show-Status 'Se aplica setarile recomandate...'

Save-PowerBackup

        & powercfg /setactive SCHEME_BALANCED | Out-Null
        if ($LASTEXITCODE -ne 0) {
            throw "Nu s-a putut activa planul Balanced (cod $LASTEXITCODE)."
        }

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

        Refresh-PowerSettingsPage
        Show-Status 'Planul Balanced si setarile recomandate au fost activate. Pagina Power & battery a fost actualizata.'
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
# Never turn off while plugged in
# ==================================================

$pluggedNeverButton = New-Object System.Windows.Forms.Button
$pluggedNeverButton.Text = 'Never (plugged in only)'
$pluggedNeverButton.Location = New-Object System.Drawing.Point(25, 140)
$pluggedNeverButton.Size = New-Object System.Drawing.Size(190, 40)
$tabPerformance.Controls.Add($pluggedNeverButton)

$pluggedNeverInfo = New-Object System.Windows.Forms.Label
$pluggedNeverInfo.Text = 'La priza: ecranul, sleep-ul si hibernarea nu se activeaza automat. Pe baterie nu se schimba nimic.'
$pluggedNeverInfo.Location = New-Object System.Drawing.Point(230, 145)
$pluggedNeverInfo.Size = New-Object System.Drawing.Size(330, 40)
$tabPerformance.Controls.Add($pluggedNeverInfo)

$pluggedNeverButton.Add_Click({
    try {
        Show-Status 'Se dezactiveaza oprirea automata doar la priza...'
        Save-PowerBackup
        Set-PowerTimeoutsNeverOnAc
        Refresh-PowerSettingsPage
        Show-Status 'La priza: ecranul, sleep-ul si hibernarea sunt pe Never. Bateria nu a fost modificata; pagina Power & battery a fost actualizata.'
    }
    catch {
        Show-Status 'Setarea Never pentru alimentarea la priza a esuat.'
        [System.Windows.Forms.MessageBox]::Show(
            $_.Exception.Message,
            'Windows Toolkit - Eroare',
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        ) | Out-Null
    }
})

# ==================================================
# Restore Initial Settings
# ==================================================

$restorePowerButton = New-Object System.Windows.Forms.Button
$restorePowerButton.Text = 'Restore Initial Settings'
$restorePowerButton.Location = New-Object System.Drawing.Point(25, 195)
$restorePowerButton.Size = New-Object System.Drawing.Size(190, 40)
$tabPerformance.Controls.Add($restorePowerButton)

$restorePowerButton.Add_Click({
    try {
        Show-Status 'Se restaureaza setarile initiale...'

$restored = Restore-PowerBackup

if ($restored) {
            Refresh-PowerSettingsPage
            Show-Status 'Setarile initiale au fost restaurate. Pagina Power & battery a fost actualizata.'
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


# ==================================================
# 4. Windows / Office
# ==================================================

$tabActivation = New-Object System.Windows.Forms.TabPage
$tabActivation.Text = 'Windows / Office'
[void]$tabs.TabPages.Add($tabActivation)

$activationInfo = New-Object System.Windows.Forms.Label
$activationInfo.Text = 'Porneste PowerShell ca Administrator.'
$activationInfo.Location = New-Object System.Drawing.Point(25, 25)
$activationInfo.AutoSize = $true
$tabActivation.Controls.Add($activationInfo)

$hwidButton = New-Object System.Windows.Forms.Button
$hwidButton.Text = '1. Activeaza Windows'
$hwidButton.Location = New-Object System.Drawing.Point(25, 70)
$hwidButton.Size = New-Object System.Drawing.Size(250, 40)
$tabActivation.Controls.Add($hwidButton)

$ohookButton = New-Object System.Windows.Forms.Button
$ohookButton.Text = '2. Activeaza Office'
$ohookButton.Location = New-Object System.Drawing.Point(270, 70)
$ohookButton.Size = New-Object System.Drawing.Size(250, 40)
$tabActivation.Controls.Add($ohookButton)

$tsforgeButton = New-Object System.Windows.Forms.Button
$tsforgeButton.Text = '3. Activeaza Windows / Office'
$tsforgeButton.Location = New-Object System.Drawing.Point(25, 130)
$tsforgeButton.Size = New-Object System.Drawing.Size(250, 45)
$tabActivation.Controls.Add($tsforgeButton)

$kmsButton = New-Object System.Windows.Forms.Button
$kmsButton.Text = '4. Activare KMS - pana la 180 zile'
$kmsButton.Location = New-Object System.Drawing.Point(270, 130)
$kmsButton.Size = New-Object System.Drawing.Size(250, 45)
$tabActivation.Controls.Add($kmsButton)

$kmsInfo = New-Object System.Windows.Forms.Label
$kmsInfo.Text = 'Pentru organizatii cu server KMS.'
$kmsInfo.Location = New-Object System.Drawing.Point(270, 177)
$kmsInfo.AutoSize = $true
$tabActivation.Controls.Add($kmsInfo)

$officeDownloadButton = New-Object System.Windows.Forms.Button
$officeDownloadButton.Text = '5. Instaleaza Microsoft 365'
$officeDownloadButton.Location = New-Object System.Drawing.Point(25, 210)
$officeDownloadButton.Size = New-Object System.Drawing.Size(300, 42)
$tabActivation.Controls.Add($officeDownloadButton)

$officeDownloadButton.Add_Click({
    $officeDownloadButton.Enabled = $false
    $installerPath = $null
    try {
        $downloadsPath = $null
        $shellFoldersPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders'
        $downloadsProperty = '{374DE290-123F-4565-9164-39C4925E467B}'
        $shellFolders = Get-ItemProperty -Path $shellFoldersPath -ErrorAction SilentlyContinue
        if ($shellFolders) {
            $configuredDownloads = $shellFolders.PSObject.Properties[$downloadsProperty].Value
            if ($configuredDownloads) {
                $downloadsPath = [Environment]::ExpandEnvironmentVariables($configuredDownloads)
            }
        }

        if (-not $downloadsPath) {
            $shell = New-Object -ComObject Shell.Application
            $downloadsFolder = $shell.NameSpace('shell:Downloads')
            if ($downloadsFolder -and $downloadsFolder.Self.Path) {
                $downloadsPath = $downloadsFolder.Self.Path
            }
        }

        if (-not $downloadsPath) {
            throw 'Nu s-a putut determina locatia folderului Downloads.'
        }

        $installerPath = Join-Path -Path $downloadsPath -ChildPath 'OfficeSetup.exe'
        if (Test-Path -LiteralPath $installerPath -PathType Leaf) {
            Remove-Item -LiteralPath $installerPath -Force -ErrorAction Stop
        }

        $downloaded = Invoke-RemoteFileDownload `
            -Url 'https://c2rsetup.officeapps.live.com/c2r/download.aspx?ProductreleaseID=O365ProPlusRetail&platform=x64&language=en-us&version=O16GA' `
            -Destination $installerPath

        if (-not $downloaded) {
            return
        }

        Show-Status 'Se verifica semnatura installerului Microsoft 365...'
        $signature = Get-AuthenticodeSignature -FilePath $installerPath -ErrorAction Stop
        if ($signature.Status -ne [System.Management.Automation.SignatureStatus]::Valid -or
            $signature.SignerCertificate.Subject -notmatch 'Microsoft Corporation') {
            throw 'Semnatura installerului nu este valida sau nu apartine Microsoft. Fisierul nu va fi pornit.'
        }

        Show-Status 'Se porneste instalarea Microsoft 365...'
        Start-Process -FilePath $installerPath -ErrorAction Stop
        Show-Status 'Installerul Microsoft 365 a pornit. Urmeaza pasii din fereastra Office; poate fi necesar un cont cu licenta valida.'
    }
    catch {
        Show-Status 'Descarcarea sau pornirea installerului Microsoft 365 a esuat.'
        [System.Windows.Forms.MessageBox]::Show(
            $_.Exception.Message,
            'Windows Toolkit - Eroare',
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        ) | Out-Null
    }
    finally {
        $officeDownloadButton.Enabled = $true
    }
})

$script:statusLabel = New-Object System.Windows.Forms.Label
$script:statusLabel.Text = 'Ready'
$script:statusLabel.Location = New-Object System.Drawing.Point(15, 470)
$script:statusLabel.Size = New-Object System.Drawing.Size(570, 25)
$form.Controls.Add($script:statusLabel)

function Invoke-MasActivation {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('HWID', 'Ohook', 'TSforge', 'OnlineKMS')]
        [string]$Method
    )

    $isAdmin = [Security.Principal.WindowsPrincipal]::new(
        [Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    if (-not $isAdmin) {
        Show-Status 'Porneste scriptul din PowerShell cu drepturi de Administrator.'
        [System.Windows.Forms.MessageBox]::Show(
            'Pentru a rula in aceeasi consola, inchide aplicatia si porneste PowerShell cu Run as Administrator.',
            'Windows Toolkit',
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        ) | Out-Null
        return
    }

    $activationArguments = @{
        HWID     = '/HWID'
        Ohook    = '/Ohook'
        TSforge  = '/Z-WindowsESUOffice'
        OnlineKMS = '/K-WindowsOffice'
    }
    $urls = @(
        'https://raw.githubusercontent.com/massgravel/Microsoft-Activation-Scripts/05c4f881efec946c0040cdd552d1afa9a519704b/MAS/All-In-One-Version-KL/MAS_AIO.cmd',
        'https://dev.azure.com/massgrave/Microsoft-Activation-Scripts/_apis/git/repositories/Microsoft-Activation-Scripts/items?path=/MAS/All-In-One-Version-KL/MAS_AIO.cmd&versionType=Commit&version=05c4f881efec946c0040cdd552d1afa9a519704b',
        'https://git.activated.win/Microsoft-Activation-Scripts/plain/MAS/All-In-One-Version-KL/MAS_AIO.cmd?id=05c4f881efec946c0040cdd552d1afa9a519704b'
    )
    $expectedHash = '850F979665FB93999ACAE93F4790C1FF8ED2041532060B7966A121C2D29A0BFA'
    $filePath = $null
    $downloadErrors = @()

    try {
        Show-Status "Se descarca scriptul pentru $Method..."
        $response = $null

        foreach ($url in $urls | Sort-Object { Get-Random }) {
            try {
                $response = Invoke-RestMethod -Uri $url -ErrorAction Stop
                if ($response) {
                    break
                }
            }
            catch {
                $downloadErrors += $_
            }
        }

        if (-not $response) {
            $errorDetails = ($downloadErrors | ForEach-Object { $_.Exception.Message }) -join [Environment]::NewLine
            throw "Nu s-a putut descarca scriptul MAS de la niciuna dintre surse. $errorDetails"
        }

        $stream = New-Object IO.MemoryStream
        $writer = New-Object IO.StreamWriter $stream
        $sha256 = [Security.Cryptography.SHA256]::Create()
        try {
            $writer.Write($response)
            $writer.Flush()
            $stream.Position = 0
            $hash = [BitConverter]::ToString(
                $sha256.ComputeHash($stream)
            ) -replace '-'
        }
        finally {
            $sha256.Dispose()
            $writer.Dispose()
            $stream.Dispose()
        }

        if ($hash -ne $expectedHash) {
            throw "Verificarea SHA-256 a esuat. Scriptul nu va fi executat. Hash primit: $hash"
        }

        $fileName = 'MAS_{0}.cmd' -f [Guid]::NewGuid().Guid
        $filePath = Join-Path -Path "$env:SystemRoot\Temp" -ChildPath $fileName
        [System.IO.File]::WriteAllText(
            $filePath,
            "@::: $([Guid]::NewGuid().Guid)`r`n$response",
            [System.Text.Encoding]::Default
        )

        if (-not (Test-Path -LiteralPath $filePath -PathType Leaf)) {
            throw 'Fisierul MAS nu a fost creat in folderul temporar.'
        }

        Show-Status "Ruleaza $Method in consola PowerShell curenta..."
        $script:statusLabel.Refresh()
        $form.Hide()

        $commandLine = '""{0}" -el -qedit {1}"' -f $filePath, $activationArguments[$Method]
        $process = Start-Process `
            -FilePath "$env:SystemRoot\System32\cmd.exe" `
            -ArgumentList "/d /c $commandLine" `
            -Wait `
            -PassThru `
            -NoNewWindow `
            -ErrorAction Stop
        $exitCode = $process.ExitCode

        if ($exitCode -ne 0) {
            throw "MAS s-a incheiat cu codul de iesire $exitCode."
        }

        Show-Status "Comanda $Method s-a incheiat (cod 0). Verifica starea activarii in Windows sau Office."
    }
    catch {
        Show-Status "Operatiunea $Method a esuat."
        [System.Windows.Forms.MessageBox]::Show(
            $_.Exception.Message,
            'Windows Toolkit - Eroare',
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        ) | Out-Null
    }
    finally {
        if ($filePath -and (Test-Path -LiteralPath $filePath -PathType Leaf)) {
            try {
                Remove-Item -LiteralPath $filePath -Force -ErrorAction Stop
            }
            catch {
                [System.Windows.Forms.MessageBox]::Show(
                    "Nu s-a putut sterge fisierul temporar ${filePath}:`r`n$($_.Exception.Message)",
                    'Windows Toolkit - Eroare',
                    [System.Windows.Forms.MessageBoxButtons]::OK,
                    [System.Windows.Forms.MessageBoxIcon]::Error
                ) | Out-Null
            }
        }

        if (-not $form.Visible) {
            $form.Show()
            $form.Activate()
        }
    }
}

$hwidButton.Add_Click({ Invoke-MasActivation -Method 'HWID' })
$ohookButton.Add_Click({ Invoke-MasActivation -Method 'Ohook' })
$tsforgeButton.Add_Click({ Invoke-MasActivation -Method 'TSforge' })
$kmsButton.Add_Click({ Invoke-MasActivation -Method 'OnlineKMS' })

$form.ShowDialog() | Out-Null