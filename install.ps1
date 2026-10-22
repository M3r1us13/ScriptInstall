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
        throw "Eroare la descarcare: $($_.Exception.Message)"
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
        throw "Nu s-a putut crea shortcut-ul pentru ${AppName}: $($_.Exception.Message)"
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

        Invoke-RemoteFileDownload `
            -Url 'https://aka.ms/getwinget' `
            -Destination $installerPath | Out-Null

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

        $shortcutCreated = $false
        $shortcutCreationFailed = $false
        try {
            $shortcutCreated = New-DesktopShortcutFromStartMenu `
                -AppName $Name
        }
        catch {
            $shortcutCreationFailed = $true
            Show-Status "$Name a fost instalat, dar shortcut-ul nu a putut fi creat."
            [System.Windows.Forms.MessageBox]::Show(
                $_.Exception.Message,
                'Shortcut - Windows Toolkit',
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Warning
            ) | Out-Null
        }

        if ($shortcutCreated) {
            Show-Status `
                -Message "$Name a fost instalat si shortcut-ul a fost creat pe Desktop."
        }
        elseif (-not $shortcutCreationFailed) {
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
    [PSCustomObject]@{ Name = 'Google Chrome'; Id = 'Google.Chrome'; Architecture = ''; Description = 'Browser web pentru site-uri, conturi si aplicatii online.' },
    [PSCustomObject]@{ Name = 'Brave'; Id = 'Brave.Brave'; Architecture = ''; Description = 'Browser web axat pe confidentialitate, cu blocarea integrata a reclamelor si trackerelor.' },
    [PSCustomObject]@{ Name = 'Adobe Acrobat Reader'; Id = 'Adobe.Acrobat.Reader.64-bit'; Architecture = ''; Description = 'Deschide, citeste, semneaza si adnoteaza documente PDF.' },
    [PSCustomObject]@{ Name = 'TeamViewer'; Id = 'TeamViewer.TeamViewer'; Architecture = ''; Description = 'Acces si asistenta la distanta pentru conectarea la alte calculatoare. Foloseste-l doar cu persoane de incredere.' },
    [PSCustomObject]@{ Name = 'UltraViewer'; Id = 'DucFabulous.UltraViewer'; Architecture = ''; Description = 'Aplicatie de control si asistenta la distanta pentru calculatoare Windows.' },
    [PSCustomObject]@{ Name = 'AnyDesk'; Id = 'AnyDeskSoftwareGmbH.AnyDesk'; Architecture = ''; Description = 'Acces la distanta si suport tehnic pentru alte dispozitive. Acorda acces numai persoanelor de incredere.' },
    [PSCustomObject]@{ Name = 'WinRAR'; Id = 'RARLab.WinRAR'; Architecture = ''; Description = 'Deschide si creeaza arhive, inclusiv RAR si ZIP.' },
    [PSCustomObject]@{ Name = 'VLC Media Player'; Id = 'VideoLAN.VLC'; Architecture = ''; Description = 'Reda majoritatea formatelor video si audio fara pachete suplimentare de codec-uri.' },
    [PSCustomObject]@{ Name = '7-Zip'; Id = '7zip.7zip'; Architecture = ''; Description = 'Arhiveaza si extrage fisiere, inclusiv formate 7z si ZIP.' },
    [PSCustomObject]@{ Name = 'Spotify'; Id = 'Spotify.Spotify'; Architecture = ''; Description = 'Reda muzica, podcasturi si alte continuturi audio online.' },
    [PSCustomObject]@{ Name = 'Notepad++'; Id = 'Notepad++.Notepad++'; Architecture = ''; Description = 'Editor de text si cod sursa cu evidentierea sintaxei si functii pentru programare.' },
    [PSCustomObject]@{ Name = 'Java 8 x64 (Temurin / AdoptOpenJDK)'; Id = 'EclipseAdoptium.Temurin.8.JRE'; Architecture = 'x64'; Description = 'Mediu Java 8 pe 64 de biti, necesar aplicatiilor care ruleaza pe Java. Include JRE, nu unelte de dezvoltare JDK.' },
    [PSCustomObject]@{ Name = 'Google Earth Pro'; Id = 'Google.EarthPro'; Architecture = ''; Description = 'Exploreaza globul cu imagini satelitare, harti si instrumente geografice.' },
    [PSCustomObject]@{ Name = 'Winamp'; Id = 'Winamp.Winamp'; Architecture = ''; Description = 'Player audio pentru colectii muzicale si redare de fisiere locale.' },
    [PSCustomObject]@{ Name = 'Malwarebytes'; Id = 'Malwarebytes.Malwarebytes'; Architecture = ''; Description = 'Scaneaza si ajuta la eliminarea malware-ului si a altor programe nedorite.' },
    [PSCustomObject]@{ Name = 'Steam'; Id = 'Valve.Steam'; Architecture = ''; Description = 'Platforma pentru cumpararea, descarcarea si lansarea jocurilor pentru PC.' }
)

$appToolTip = New-Object System.Windows.Forms.ToolTip
$appToolTip.AutoPopDelay = 15000
$appToolTip.InitialDelay = 400
$appToolTip.ReshowDelay = 100
$appToolTip.ShowAlways = $true

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
    $appToolTip.SetToolTip($check, $app.Description)
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
    catch {
        Show-Status 'Instalarea aplicatiilor s-a oprit din cauza unei erori neasteptate.'
        [System.Windows.Forms.MessageBox]::Show(
            $_.Exception.Message,
            'Windows Toolkit - Eroare',
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        ) | Out-Null
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

$cleanupErrors = New-Object 'System.Collections.Generic.List[string]'
$processedPaths = @()
$tempDirectories = @(
    $env:TEMP
    (Join-Path $env:WINDIR 'Temp')
)

foreach ($tempDirectory in $tempDirectories) {
    if ([string]::IsNullOrWhiteSpace($tempDirectory)) {
        continue
    }

    try {
        $resolvedDirectory = [System.IO.Path]::GetFullPath($tempDirectory)
        if ($processedPaths -contains $resolvedDirectory) {
            continue
        }
        $processedPaths += $resolvedDirectory

        $rootPath = [System.IO.Path]::GetPathRoot($resolvedDirectory)
        if ($resolvedDirectory.TrimEnd('\') -eq $rootPath.TrimEnd('\')) {
            throw "Calea temporara nu este sigura pentru curatare: $resolvedDirectory"
        }

        if (-not (Test-Path -LiteralPath $resolvedDirectory -PathType Container)) {
            continue
        }

        $tempItems = Get-ChildItem `
            -LiteralPath $resolvedDirectory `
            -Force `
            -ErrorAction Stop

        foreach ($tempItem in $tempItems) {
            try {
                Remove-Item `
                    -LiteralPath $tempItem.FullName `
                    -Recurse `
                    -Force `
                    -ErrorAction Stop
            }
            catch {
                $cleanupErrors.Add("$($tempItem.FullName): $($_.Exception.Message)")
            }
        }
    }
    catch {
        $cleanupErrors.Add("$tempDirectory`: $($_.Exception.Message)")
    }
}

if ($cleanupErrors.Count -gt 0) {
    Show-Status "Curatare partiala. Elemente cu erori: $($cleanupErrors.Count)."
    [System.Windows.Forms.MessageBox]::Show(
        ($cleanupErrors -join [Environment]::NewLine),
        'Curatare partiala - Windows Toolkit',
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Warning
    ) | Out-Null
}
else {
    Show-Status 'Fisierele temporare au fost curatate.'
}
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

New-ItemProperty `
            -Path $darkPath `
            -Name 'AppsUseLightTheme' `
            -PropertyType DWord `
            -Value 0 `
            -Force `
            -ErrorAction Stop | Out-Null

New-ItemProperty `
            -Path $darkPath `
            -Name 'SystemUsesLightTheme' `
            -PropertyType DWord `
            -Value 0 `
            -Force `
            -ErrorAction Stop | Out-Null

        $refreshProcess = Start-Process `
            -FilePath "$env:WINDIR\System32\rundll32.exe" `
            -ArgumentList 'user32.dll,UpdatePerUserSystemParameters' `
            -WindowStyle Hidden `
            -Wait `
            -PassThru `
            -ErrorAction Stop

        if ($refreshProcess.ExitCode -ne 0) {
            throw "Reimprospatarea temei a esuat (cod $($refreshProcess.ExitCode))."
        }

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
    $batteries = @(
        Get-CimInstance `
            -ClassName Win32_Battery `
            -ErrorAction Stop
    )
    return ($batteries.Count -gt 0)
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
        $out = (& powercfg /q SCHEME_CURRENT $map[$key][0] $map[$key][1] 2>$null) -join ' '
        if ($LASTEXITCODE -ne 0) {
            throw "Nu s-au putut citi valorile de alimentare pentru $key (cod $LASTEXITCODE)."
        }

        if ($out -notmatch 'AC.*?(0x[0-9a-fA-F]+)') {
            throw "Valoarea AC pentru $key nu a putut fi citita din powercfg."
        }
        $ac = $Matches[1]

        if ($out -notmatch 'DC.*?(0x[0-9a-fA-F]+)') {
            throw "Valoarea DC pentru $key nu a putut fi citita din powercfg."
        }
        $dc = $Matches[1]

        $result[$key] = @($ac, $dc)
    }

return $result
}

function Save-PowerBackup {
    if (Test-Path -LiteralPath $powerBackupPath) {
        $existingBackup = Get-ItemProperty `
            -Path $powerBackupPath `
            -ErrorAction Stop

        $requiredValues = @(
            'ActiveScheme', 'MonitorAC', 'MonitorDC',
            'StandbyAC', 'StandbyDC', 'DiskAC', 'DiskDC',
            'HibernateAC', 'HibernateDC'
        )
        $isComplete = $null -ne $existingBackup
        foreach ($name in $requiredValues) {
            if ($null -eq $existingBackup -or
                $null -eq $existingBackup.PSObject.Properties[$name] -or
                $null -eq $existingBackup.PSObject.Properties[$name].Value) {
                $isComplete = $false
                break
            }
        }

        if ($isComplete) {
            return
        }

        Remove-Item `
            -LiteralPath $powerBackupPath `
            -Recurse `
            -Force `
            -ErrorAction Stop
    }

    New-Item `
        -Path $powerBackupPath `
        -Force `
        -ErrorAction Stop | Out-Null

    $scheme = Get-ActiveSchemeGuid
    if (-not $scheme) {
        throw 'Nu s-a putut salva planul de alimentare activ.'
    }
    Set-ItemProperty `
        -Path $powerBackupPath `
        -Name 'ActiveScheme' `
        -Value $scheme `
        -ErrorAction Stop

    $timeouts = Get-PowerTimeouts

    $backupValues = @{
        MonitorAC   = $timeouts.Monitor[0]
        MonitorDC   = $timeouts.Monitor[1]
        StandbyAC   = $timeouts.Standby[0]
        StandbyDC   = $timeouts.Standby[1]
        DiskAC      = $timeouts.Disk[0]
        DiskDC      = $timeouts.Disk[1]
        HibernateAC = $timeouts.Hibernate[0]
        HibernateDC = $timeouts.Hibernate[1]
    }

    foreach ($name in $backupValues.Keys) {
        Set-ItemProperty `
            -Path $powerBackupPath `
            -Name $name `
            -Value $backupValues[$name] `
            -ErrorAction Stop
    }
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

function Restore-PowerTimeoutValues {
    param(
        [Parameter(Mandatory = $true)]
        [psobject]$Backup
    )

    $settings = @(
        [PSCustomObject]@{ Name = 'Monitor'; Subgroup = 'SUB_VIDEO'; Setting = 'VIDEOIDLE' }
        [PSCustomObject]@{ Name = 'Standby'; Subgroup = 'SUB_SLEEP'; Setting = 'STANDBYIDLE' }
        [PSCustomObject]@{ Name = 'Disk'; Subgroup = 'SUB_DISK'; Setting = 'DISKIDLE' }
        [PSCustomObject]@{ Name = 'Hibernate'; Subgroup = 'SUB_SLEEP'; Setting = 'HIBERNATEIDLE' }
    )

    foreach ($setting in $settings) {
        foreach ($powerType in @('AC', 'DC')) {
            $propertyName = '{0}{1}' -f $setting.Name, $powerType
            $rawValue = [string]$Backup.$propertyName
            if ($rawValue -notmatch '^0x[0-9a-fA-F]{1,8}$') {
                throw "Valoarea salvata pentru $propertyName nu este valida."
            }

            $seconds = [Convert]::ToUInt64($rawValue.Substring(2), 16)
            $command = if ($powerType -eq 'AC') { '/setacvalueindex' } else { '/setdcvalueindex' }
            & powercfg $command $Backup.ActiveScheme $setting.Subgroup $setting.Setting $seconds | Out-Null
            if ($LASTEXITCODE -ne 0) {
                throw "Nu s-a putut restaura valoarea $propertyName (cod $LASTEXITCODE)."
            }
        }
    }

    & powercfg /setactive $Backup.ActiveScheme | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Nu s-au putut aplica setarile de alimentare restaurate (cod $LASTEXITCODE)."
    }
}

function Get-Or-Create-UltimateScheme {
    if (Test-Path $powerBackupPath) {
        $existing = (Get-ItemProperty -Path $powerBackupPath -ErrorAction Stop).UltimateGuid
        if ($existing) { return $existing }
    }

$ultimateSource = 'e9a42b02-d5df-448d-aa00-03f14749eb61'
    $dupOut = (powercfg /duplicatescheme $ultimateSource 2>$null) -join ' '
if ($LASTEXITCODE -ne 0) {
    throw "Nu s-a putut crea planul Ultimate Performance (cod $LASTEXITCODE)."
}

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
    if (-not (Test-Path -LiteralPath $powerBackupPath)) { return $false }

    $props = Get-ItemProperty `
        -Path $powerBackupPath `
        -ErrorAction Stop

    if (-not $props.ActiveScheme) {
        throw 'Backup-ul nu contine planul de alimentare initial.'
    }

Restore-PowerTimeoutValues -Backup $props

    if ($props.UltimateGuid -and $props.UltimateGuid -ne $props.ActiveScheme) {
        & powercfg /delete $props.UltimateGuid | Out-Null
        if ($LASTEXITCODE -ne 0) {
            throw "Setarile au fost restaurate, dar planul Ultimate creat de toolkit nu a putut fi sters (cod $LASTEXITCODE)."
        }
    }

    Remove-Item `
        -LiteralPath $powerBackupPath `
        -Recurse `
        -Force `
        -ErrorAction Stop

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
    $activePerformancePlan = 'Ultimate Performance'
}
else {
    & powercfg /setactive SCHEME_MIN | Out-Null
    $activePerformancePlan = 'High Performance'
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

Show-Status "$activePerformancePlan este activ. La priza nu se opreste ecranul sau PC-ul; pe baterie, oprirea automata ramane activa."
        }
        else {
            Set-PowerTimeouts @{
                Monitor   = @(0, 0)
                Standby   = @(0, 0)
                Disk      = @(0, 0)
                Hibernate = @(0, 0)
            }

Show-Status "$activePerformancePlan este activ. Oprirea automata a ecranului si a PC-ului este dezactivata."
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

$tabService = New-Object System.Windows.Forms.TabPage
$tabService.Text = 'Service'
[void]$tabs.TabPages.Add($tabService)

$serviceInfoLabel = New-Object System.Windows.Forms.Label
$serviceInfoLabel.Text = 'Verificare si reparare Windows. Comenzile se deschid intr-o fereastra separata pentru a afisa rezultatele.'
$serviceInfoLabel.Location = New-Object System.Drawing.Point(20, 20)
$serviceInfoLabel.Size = New-Object System.Drawing.Size(535, 38)
$tabService.Controls.Add($serviceInfoLabel)

function Start-ServiceCheck {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Title,

        [Parameter(Mandatory = $true)]
        [string]$CommandScript,

        [Parameter(Mandatory = $true)]
        [string]$Confirmation,

        [bool]$RequiresAdministrator = $false
    )

    $confirmationResult = [System.Windows.Forms.MessageBox]::Show(
        $Confirmation,
        "Windows Toolkit - $Title",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Question,
        [System.Windows.Forms.MessageBoxDefaultButton]::Button2
    )
    if ($confirmationResult -ne [System.Windows.Forms.DialogResult]::Yes) {
        return
    }

    try {
        $isAdministrator = [Security.Principal.WindowsPrincipal]::new(
            [Security.Principal.WindowsIdentity]::GetCurrent()
        ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

        $consoleScript = @"
`$ErrorActionPreference = 'Stop'
`$Host.UI.RawUI.WindowTitle = 'Windows Toolkit - $Title'
Write-Host 'Windows Toolkit - $Title' -ForegroundColor Cyan
Write-Host 'La final, apasa Enter pentru a inchide aceasta fereastra.'
Write-Host ''
try {
$CommandScript
}
catch {
    Write-Host ("`r`nOperatiunea a esuat: " + `$_.Exception.Message) -ForegroundColor Red
}
Write-Host ''
Read-Host 'Gata'
"@
        $encodedCommand = [Convert]::ToBase64String(
            [Text.Encoding]::Unicode.GetBytes($consoleScript)
        )
        $arguments = @(
            '-NoProfile'
            '-ExecutionPolicy'
            'Bypass'
            '-EncodedCommand'
            $encodedCommand
        )

        $startParameters = @{
            FilePath = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
            ArgumentList = $arguments
            ErrorAction = 'Stop'
        }
        if ($RequiresAdministrator -and -not $isAdministrator) {
            $startParameters.Verb = 'RunAs'
        }

        Start-Process @startParameters | Out-Null
        Show-Status "$Title a fost pornit intr-o fereastra separata."
    }
    catch {
        Show-Status "Nu s-a putut porni $Title."
        [System.Windows.Forms.MessageBox]::Show(
            $_.Exception.Message,
            'Windows Toolkit - Eroare',
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        ) | Out-Null
    }
}

$dismButton = New-Object System.Windows.Forms.Button
$dismButton.Text = 'Reparare Windows (DISM)'
$dismButton.Location = New-Object System.Drawing.Point(20, 75)
$dismButton.Size = New-Object System.Drawing.Size(245, 42)
$tabService.Controls.Add($dismButton)
$dismButton.Add_Click({
    Start-ServiceCheck `
        -Title 'DISM RestoreHealth' `
        -CommandScript '& dism.exe /Online /Cleanup-Image /RestoreHealth; if ($LASTEXITCODE -ne 0) { throw "DISM s-a incheiat cu codul $LASTEXITCODE." }' `
        -Confirmation 'DISM va verifica si repara imaginea Windows folosind Windows Update. Poate dura mult. Continui?' `
        -RequiresAdministrator $true
})

$sfcButton = New-Object System.Windows.Forms.Button
$sfcButton.Text = 'Verificare fisiere (SFC)'
$sfcButton.Location = New-Object System.Drawing.Point(290, 75)
$sfcButton.Size = New-Object System.Drawing.Size(245, 42)
$tabService.Controls.Add($sfcButton)
$sfcButton.Add_Click({
    Start-ServiceCheck `
        -Title 'SFC Scannow' `
        -CommandScript '& sfc.exe /scannow; if ($LASTEXITCODE -ne 0) { throw "SFC s-a incheiat cu codul $LASTEXITCODE." }' `
        -Confirmation 'SFC va verifica si incerca sa repare fisierele de sistem Windows. Operatiunea poate dura. Continui?' `
        -RequiresAdministrator $true
})

$diskCheckButton = New-Object System.Windows.Forms.Button
$diskCheckButton.Text = 'Verificare disc (CHKDSK)'
$diskCheckButton.Location = New-Object System.Drawing.Point(20, 135)
$diskCheckButton.Size = New-Object System.Drawing.Size(245, 42)
$tabService.Controls.Add($diskCheckButton)
$diskCheckButton.Add_Click({
    $systemDriveForCheck = $env:SystemDrive
    $diskCommand = '& chkdsk.exe "{0}" /scan; if ($LASTEXITCODE -ne 0) {{ throw "CHKDSK s-a incheiat cu codul $LASTEXITCODE." }}' -f $systemDriveForCheck
    Start-ServiceCheck `
        -Title 'CHKDSK Scan' `
        -CommandScript $diskCommand `
        -Confirmation "CHKDSK va scana discul $systemDriveForCheck online fara reparare automata sau programare la repornire. Continui?" `
        -RequiresAdministrator $true
})

$windowsUpdateButton = New-Object System.Windows.Forms.Button
$windowsUpdateButton.Text = 'Verificare Windows Update'
$windowsUpdateButton.Location = New-Object System.Drawing.Point(290, 135)
$windowsUpdateButton.Size = New-Object System.Drawing.Size(245, 42)
$tabService.Controls.Add($windowsUpdateButton)
$windowsUpdateButton.Add_Click({
    $updateSearchScript = @'
$session = New-Object -ComObject Microsoft.Update.Session
$searcher = $session.CreateUpdateSearcher()
Write-Host 'Se cauta actualizari disponibile. Aceasta operatiune poate dura...' -ForegroundColor Yellow
$result = $searcher.Search("IsInstalled=0 and Type='Software'")
Write-Host ("Actualizari disponibile: {0}" -f $result.Updates.Count) -ForegroundColor Green
for ($index = 0; $index -lt $result.Updates.Count; $index++) {
    Write-Host ("- {0}" -f $result.Updates.Item($index).Title)
}
'@
    Start-ServiceCheck `
        -Title 'Windows Update' `
        -CommandScript $updateSearchScript `
        -Confirmation 'Se va cauta actualizari Windows disponibile, fara a le instala. Continui?' `
        -RequiresAdministrator $false
})

$wingetListButton = New-Object System.Windows.Forms.Button
$wingetListButton.Text = 'Aplicatii instalate (winget)'
$wingetListButton.Location = New-Object System.Drawing.Point(20, 195)
$wingetListButton.Size = New-Object System.Drawing.Size(245, 42)
$tabService.Controls.Add($wingetListButton)
$wingetListButton.Add_Click({
    $wingetCommand = Get-Command -Name 'winget.exe' -ErrorAction SilentlyContinue
    if ($null -eq $wingetCommand) {
        [System.Windows.Forms.MessageBox]::Show(
            'winget nu este disponibil. Foloseste mai intai Install Apps pentru a configura Microsoft App Installer.',
            'Windows Toolkit',
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        ) | Out-Null
        return
    }

    $wingetListScript = '& winget.exe list --accept-source-agreements; if ($LASTEXITCODE -ne 0) { throw "winget list s-a incheiat cu codul $LASTEXITCODE." }'
    Start-ServiceCheck `
        -Title 'Aplicatii instalate' `
        -CommandScript $wingetListScript `
        -Confirmation 'Se va afisa lista aplicatiilor instalate recunoscute de winget. Continui?' `
        -RequiresAdministrator $false
})

$serviceNoteLabel = New-Object System.Windows.Forms.Label
$serviceNoteLabel.Text = 'Recomandare: ruleaza DISM inainte de SFC daca Windows are probleme. Unele comenzi cer confirmarea UAC.'
$serviceNoteLabel.Location = New-Object System.Drawing.Point(20, 255)
$serviceNoteLabel.Size = New-Object System.Drawing.Size(535, 42)
$tabService.Controls.Add($serviceNoteLabel)

$tabAppService = New-Object System.Windows.Forms.TabPage
$tabAppService.Text = 'App Service'
[void]$tabs.TabPages.Add($tabAppService)

$appServiceInfo = New-Object System.Windows.Forms.Label
$appServiceInfo.Text = 'Unelte pentru diagnostic si mentenanta PC. Selecteaza aplicatii pentru instalare, reparare sau dezinstalare.'
$appServiceInfo.Location = New-Object System.Drawing.Point(20, 18)
$appServiceInfo.Size = New-Object System.Drawing.Size(535, 36)
$tabAppService.Controls.Add($appServiceInfo)

$appServiceNote = New-Object System.Windows.Forms.Label
$appServiceNote.Text = 'Treci cu mouse-ul peste o aplicatie pentru a vedea ce face.'
$appServiceNote.Location = New-Object System.Drawing.Point(20, 280)
$appServiceNote.Size = New-Object System.Drawing.Size(535, 45)
$tabAppService.Controls.Add($appServiceNote)

$serviceAppList = @(
    [PSCustomObject]@{ Name = 'Hard Disk Sentinel Standard'; Id = 'JanosMathe.HardDiskSentinel.Standard'; Architecture = ''; Description = 'Monitorizeaza sanatatea si performanta HDD-urilor si SSD-urilor folosind date SMART si teste de diagnostic. Versiunea Standard este shareware.' },
    [PSCustomObject]@{ Name = 'CrystalDiskInfo'; Id = 'CrystalDewWorld.CrystalDiskInfo'; Architecture = ''; Description = 'Afiseaza starea de sanatate, temperatura si informatiile SMART ale HDD-urilor si SSD-urilor.' },
    [PSCustomObject]@{ Name = 'HWiNFO'; Id = 'REALiX.HWiNFO'; Architecture = ''; Description = 'Afiseaza informatii detaliate despre componente si senzori, inclusiv temperaturi, tensiuni si turatii.' },
    [PSCustomObject]@{ Name = 'CPU-Z'; Id = 'CPUID.CPU-Z'; Architecture = ''; Description = 'Identifica procesorul, placa de baza si memoria RAM; poate afisa frecvente si temporizari.' },
    [PSCustomObject]@{ Name = 'GPU-Z'; Id = 'TechPowerUp.GPU-Z'; Architecture = ''; Description = 'Afiseaza modelul placii video, memoria, frecventele si datele senzorilor GPU.' },
    [PSCustomObject]@{ Name = 'CrystalDiskMark'; Id = 'CrystalDewWorld.CrystalDiskMark'; Architecture = ''; Description = 'Masuratori de viteza pentru HDD-uri si SSD-uri. Testele pot solicita discul; evita-le pe dispozitive cu probleme sau date nesalvate.' },
    [PSCustomObject]@{ Name = 'Rufus'; Id = 'Rufus.Rufus'; Architecture = ''; Description = 'Creeaza stick-uri USB bootabile pentru instalarea sau recuperarea sistemelor. Scrierea imaginii sterge continutul stick-ului selectat.' },
    [PSCustomObject]@{ Name = 'Everything'; Id = 'voidtools.Everything'; Architecture = ''; Description = 'Cauta rapid fisiere si foldere dupa nume pe volumele NTFS indexate.' },
    [PSCustomObject]@{ Name = 'TreeSize Free'; Id = 'JAMSoftware.TreeSize.Free'; Architecture = ''; Description = 'Analizeaza utilizarea spatiului pe disc si arata folderele si fisierele care ocupa cel mai mult.' },
    [PSCustomObject]@{ Name = 'Revo Uninstaller'; Id = 'RevoUninstaller.RevoUninstaller'; Architecture = ''; Description = 'Dezinstaleaza aplicatii si poate cauta fisiere si intrari de registru ramase dupa dezinstalare.' }
)
$serviceAppChecks = @()
$serviceAppChecks = @()
$serviceAppLeftColumnCount = [int][Math]::Ceiling($serviceAppList.Count / 2)
for ($i = 0; $i -lt $serviceAppList.Count; $i++) {
    if ($i -lt $serviceAppLeftColumnCount) {
        $columnX = 20
        $row = $i
    }
    else {
        $columnX = 300
        $row = $i - $serviceAppLeftColumnCount
    }

    $check = New-Object System.Windows.Forms.CheckBox
    $check.Text = $serviceAppList[$i].Name
    $check.Tag = $serviceAppList[$i]
    $check.Location = New-Object System.Drawing.Point($columnX, (55 + ($row * 30)))
    $check.Size = New-Object System.Drawing.Size(265, 24)
    $check.UseVisualStyleBackColor = $true
    $tabAppService.Controls.Add($check)
    $appToolTip.SetToolTip($check, $serviceAppList[$i].Description)
    $descriptionLabel = $appServiceNote
    $description = $serviceAppList[$i].Description
    $check.Add_MouseEnter({
        $descriptionLabel.Text = $description
    }.GetNewClosure())
    $check.Add_MouseLeave({
        $descriptionLabel.Text = 'Treci cu mouse-ul peste o aplicatie pentru a vedea ce face.'
    }.GetNewClosure())
    $serviceAppChecks += $check
}

function Invoke-AppServiceWinget {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments,

        [Parameter(Mandatory = $true)]
        [string]$Operation
    )

    $wingetCommand = Get-Command -Name 'winget.exe' -ErrorAction SilentlyContinue
    if ($null -eq $wingetCommand) {
        throw 'winget nu este disponibil. Configureaza Microsoft App Installer din fila Install Apps.'
    }

    Show-Status "$Operation..."
    $process = Start-Process `
        -FilePath $wingetCommand.Source `
        -ArgumentList $Arguments `
        -Wait `
        -PassThru `
        -ErrorAction Stop

    if ($process.ExitCode -ne 0 -and $process.ExitCode -ne 3010) {
        throw "$Operation a esuat. Cod winget: $($process.ExitCode)."
    }
    return $process.ExitCode
}

function Get-SelectedServiceApps {
    return @(
        $serviceAppChecks |
            Where-Object { $_.Checked } |
            ForEach-Object { $_.Tag }
    )
}

$appServiceInstallButton = New-Object System.Windows.Forms.Button
$appServiceInstallButton.Text = 'Install'
$appServiceInstallButton.Location = New-Object System.Drawing.Point(20, 225)
$appServiceInstallButton.Size = New-Object System.Drawing.Size(100, 38)
$tabAppService.Controls.Add($appServiceInstallButton)
$appServiceInstallButton.Add_Click({
    $selectedApps = @(Get-SelectedServiceApps)
    if ($selectedApps.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show(
            'Selecteaza cel putin o aplicatie.',
            'App Service'
        ) | Out-Null
        return
    }

    $appServiceInstallButton.Enabled = $false
    try {
        Ensure-WingetAvailable | Out-Null
        $failed = @()
        foreach ($app in $selectedApps) {
            if (-not (Install-WingetPackage -Id $app.Id -Name $app.Name -Architecture $app.Architecture)) {
                $failed += $app.Name
            }
        }
        if ($failed.Count -gt 0) {
            Show-Status "Instalare terminata cu erori: $($failed -join ', ')"
        }
        else {
            Show-Status 'Aplicatiile selectate au fost instalate.'
        }
    }
    catch {
        Show-Status 'Instalarea aplicatiilor de service a esuat.'
        [System.Windows.Forms.MessageBox]::Show(
            $_.Exception.Message,
            'App Service - Eroare',
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        ) | Out-Null
    }
    finally {
        $appServiceInstallButton.Enabled = $true
    }
})

$appServiceCheckUpdatesButton = New-Object System.Windows.Forms.Button
$appServiceCheckUpdatesButton.Text = 'Check Updates'
$appServiceCheckUpdatesButton.Location = New-Object System.Drawing.Point(130, 225)
$appServiceCheckUpdatesButton.Size = New-Object System.Drawing.Size(105, 38)
$tabAppService.Controls.Add($appServiceCheckUpdatesButton)
$appServiceCheckUpdatesButton.Add_Click({
    try {
        Invoke-AppServiceWinget `
            -Arguments @('upgrade', '--accept-source-agreements', '--disable-interactivity') `
            -Operation 'Se verifica actualizarile aplicatiilor' | Out-Null
        Show-Status 'Verificarea actualizarilor s-a incheiat.'
    }
    catch {
        Show-Status 'Verificarea actualizarilor a esuat.'
        [System.Windows.Forms.MessageBox]::Show(
            $_.Exception.Message,
            'App Service - Eroare',
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        ) | Out-Null
    }
})

$appServiceUpdateAllButton = New-Object System.Windows.Forms.Button
$appServiceUpdateAllButton.Text = 'Update All'
$appServiceUpdateAllButton.Location = New-Object System.Drawing.Point(245, 225)
$appServiceUpdateAllButton.Size = New-Object System.Drawing.Size(100, 38)
$tabAppService.Controls.Add($appServiceUpdateAllButton)
$appServiceUpdateAllButton.Add_Click({
    $confirmation = [System.Windows.Forms.MessageBox]::Show(
        'Aceasta actiune incearca sa actualizeze toate aplicatiile recunoscute de winget, nu doar cele bifate. Continui?',
        'Confirma actualizarea tuturor aplicatiilor',
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Warning,
        [System.Windows.Forms.MessageBoxDefaultButton]::Button2
    )
    if ($confirmation -ne [System.Windows.Forms.DialogResult]::Yes) {
        return
    }

    try {
        Invoke-AppServiceWinget `
            -Arguments @('upgrade', '--all', '--silent', '--accept-source-agreements', '--accept-package-agreements', '--disable-interactivity') `
            -Operation 'Se actualizeaza toate aplicatiile' | Out-Null
        Show-Status 'Actualizarea tuturor aplicatiilor s-a incheiat.'
    }
    catch {
        Show-Status 'Actualizarea aplicatiilor a esuat.'
        [System.Windows.Forms.MessageBox]::Show(
            $_.Exception.Message,
            'App Service - Eroare',
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        ) | Out-Null
    }
})

$appServiceRepairButton = New-Object System.Windows.Forms.Button
$appServiceRepairButton.Text = 'Repair'
$appServiceRepairButton.Location = New-Object System.Drawing.Point(355, 225)
$appServiceRepairButton.Size = New-Object System.Drawing.Size(90, 38)
$tabAppService.Controls.Add($appServiceRepairButton)
$appServiceRepairButton.Add_Click({
    $selectedApps = @(Get-SelectedServiceApps)
    if ($selectedApps.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show(
            'Selecteaza aplicatiile pe care vrei sa incerci repararea.',
            'App Service'
        ) | Out-Null
        return
    }

    $confirmation = [System.Windows.Forms.MessageBox]::Show(
        'Winget poate repara doar instalatoarele care implementeaza aceasta functie. Unele aplicatii vor raporta ca repararea nu este disponibila. Continui?',
        'Reparare aplicatii selectate',
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Warning,
        [System.Windows.Forms.MessageBoxDefaultButton]::Button2
    )
    if ($confirmation -ne [System.Windows.Forms.DialogResult]::Yes) {
        return
    }

    $failed = @()
    foreach ($app in $selectedApps) {
        try {
            Invoke-AppServiceWinget `
                -Arguments @('repair', '--id', $app.Id, '--exact', '--silent', '--accept-source-agreements', '--accept-package-agreements', '--disable-interactivity') `
                -Operation "Se repara $($app.Name)" | Out-Null
        }
        catch {
            $failed += "$($app.Name): $($_.Exception.Message)"
        }
    }
    if ($failed.Count -gt 0) {
        Show-Status "Unele reparatii nu au reusit: $($failed.Count)."
        [System.Windows.Forms.MessageBox]::Show(
            ($failed -join [Environment]::NewLine),
            'App Service - Rezultatul repararii',
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        ) | Out-Null
    }
    else {
        Show-Status 'Repararea aplicatiilor selectate s-a incheiat.'
    }
})

$appServiceUninstallButton = New-Object System.Windows.Forms.Button
$appServiceUninstallButton.Text = 'Uninstall'
$appServiceUninstallButton.Location = New-Object System.Drawing.Point(455, 225)
$appServiceUninstallButton.Size = New-Object System.Drawing.Size(100, 38)
$tabAppService.Controls.Add($appServiceUninstallButton)
$appServiceUninstallButton.Add_Click({
    $selectedApps = @(Get-SelectedServiceApps)
    if ($selectedApps.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show(
            'Selecteaza aplicatiile pe care vrei sa le dezinstalezi.',
            'App Service'
        ) | Out-Null
        return
    }

    $names = ($selectedApps | ForEach-Object { $_.Name }) -join ', '
    $confirmation = [System.Windows.Forms.MessageBox]::Show(
        "Se vor dezinstala urmatoarele aplicatii:`r`n$names`r`n`r`nContinui?",
        'Confirma dezinstalarea',
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Warning,
        [System.Windows.Forms.MessageBoxDefaultButton]::Button2
    )
    if ($confirmation -ne [System.Windows.Forms.DialogResult]::Yes) {
        return
    }

    $failed = @()
    foreach ($app in $selectedApps) {
        try {
            Invoke-AppServiceWinget `
                -Arguments @('uninstall', '--id', $app.Id, '--exact', '--silent', '--accept-source-agreements', '--disable-interactivity') `
                -Operation "Se dezinstaleaza $($app.Name)" | Out-Null
        }
        catch {
            $failed += "$($app.Name): $($_.Exception.Message)"
        }
    }
    if ($failed.Count -gt 0) {
        Show-Status "Unele dezinstalari nu au reusit: $($failed.Count)."
        [System.Windows.Forms.MessageBox]::Show(
            ($failed -join [Environment]::NewLine),
            'App Service - Rezultatul dezinstalarii',
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        ) | Out-Null
    }
    else {
        Show-Status 'Dezinstalarea aplicatiilor selectate s-a incheiat.'
    }
})

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

        $installerName = 'OfficeSetup_{0}.exe' -f [Guid]::NewGuid().ToString('N')
        $installerPath = Join-Path -Path $downloadsPath -ChildPath $installerName

        Invoke-RemoteFileDownload `
            -Url 'https://c2rsetup.officeapps.live.com/c2r/download.aspx?ProductreleaseID=O365ProPlusRetail&platform=x64&language=en-us&version=O16GA' `
            -Destination $installerPath | Out-Null

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