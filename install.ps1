# Animated ASCII Fetch - PowerShell
# Inspirat vizual de animatia din postarea Reddit; implementare PowerShell originala.
# Ruleaza in Windows Terminal / PowerShell. Oprire: Ctrl+C.

$ErrorActionPreference = "SilentlyContinue"
try {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    [Console]::CursorVisible = $false
    [Console]::Clear()

    $pink = [ConsoleColor]::Magenta
    $hotPink = [ConsoleColor]::DarkMagenta
    $white = [ConsoleColor]::Gray
    $cyan = [ConsoleColor]::Cyan
    $green = [ConsoleColor]::Green
    $red = [ConsoleColor]::Red
    $yellow = [ConsoleColor]::Yellow

    # Pastreaza animatia in stanga si informatiile in dreapta.
    $consoleWidth = [Math]::Max(80, [Console]::WindowWidth)
    $consoleHeight = [Math]::Max(25, [Console]::WindowHeight)
    $centerX = [Math]::Min(24, [int]($consoleWidth * 0.27))
    $centerY = [int]($consoleHeight / 2)
    $radiusX = [Math]::Min(17, [int]($consoleWidth * 0.19))
    $radiusY = [Math]::Min(9, [int]($consoleHeight * 0.34))
    $innerX = [int]($radiusX * 0.43)
    $innerY = [int]($radiusY * 0.48)
    $panelX = [Math]::Min(($centerX + $radiusX + 5), [int]($consoleWidth * 0.52))
    $panelY = [Math]::Max(1, $centerY - 8)

    $os = (Get-CimInstance Win32_OperatingSystem).Caption
    $cpu = (Get-CimInstance Win32_Processor | Select-Object -First 1).Name
    $gpu = (Get-CimInstance Win32_VideoController | Where-Object { $_.Name -notmatch 'Microsoft Basic' } | Select-Object -First 1).Name
    $ramTotal = [Math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 1)
    $ramUsed = [Math]::Round(($ramTotal - ((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory / 1MB)), 1)
    $uptime = (Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
    $disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='$($env:SystemDrive)'"
    $diskUsed = [Math]::Round(($disk.Size - $disk.FreeSpace) / 1GB, 1)
    $diskTotal = [Math]::Round($disk.Size / 1GB, 1)
    $userName = "$env:USERNAME@$env:COMPUTERNAME"

    function Write-At([int]$X, [int]$Y, [string]$Text, [ConsoleColor]$Color = [ConsoleColor]::Gray) {
        if ($Y -ge 0 -and $Y -lt [Console]::WindowHeight -and $X -ge 0 -and $X -lt [Console]::WindowWidth) {
            [Console]::SetCursorPosition($X, $Y)
            [Console]::ForegroundColor = $Color
            $max = [Console]::WindowWidth - $X
            if ($Text.Length -gt $max) { $Text = $Text.Substring(0, [Math]::Max(0, $max)) }
            [Console]::Write($Text)
        }
    }

    function Draw-Panel {
        $lines = @(
            "System Information",
            "OS       $os",
            "Shell    PowerShell $($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor)",
            "Host     $userName",
            "Uptime   $([int]$uptime.TotalDays)d $($uptime.Hours)h $($uptime.Minutes)m",
            "Packages Windows",
            "",
            "Hardware Information",
            "CPU      $cpu",
            "GPU      $gpu",
            "Memory   $ramUsed / $ramTotal GiB",
            "Disk (C) $diskUsed / $diskTotal GiB"
        )
        $boxWidth = [Math]::Min(58, [Console]::WindowWidth - $panelX - 2)
        if ($boxWidth -lt 20) { return }
        Write-At $panelX ($panelY - 1) ("┌" + ("─" * ($boxWidth - 2)) + "┐") $white
        for ($i = 0; $i -lt $lines.Count; $i++) {
            $line = $lines[$i]
            if ($line.Length -gt ($boxWidth - 4)) { $line = $line.Substring(0, $boxWidth - 4) }
            $color = $white
            if ($i -eq 0 -or $i -eq 7) { $color = $cyan }
            elseif ($line -match '^(OS|CPU|GPU|Memory|Disk|Uptime|Shell|Host|Packages)') { $color = $green }
            Write-At $panelX ($panelY + $i) ("│ " + $line.PadRight($boxWidth - 4) + " │") $color
        }
        Write-At $panelX ($panelY + $lines.Count) ("└" + ("─" * ($boxWidth - 2)) + "┘") $white
        Write-At $panelX ($panelY + $lines.Count + 2) "● ● ● ● ● ● ●" $pink
    }

    $frame = 0
    while ($true) {
        # Sterge doar zona animatiei, pentru a evita palpairea intregului terminal.
        for ($y = [Math]::Max(0, $centerY - $radiusY - 2); $y -le [Math]::Min([Console]::WindowHeight - 1, $centerY + $radiusY + 2); $y++) {
            Write-At 0 $y (" " * [Math]::Min($panelX - 2, [Console]::WindowWidth))
        }

        # Inel exterior punctat, cu un punct luminos care se deplaseaza.
        for ($a = 0; $a -lt 360; $a += 7) {
            $rad = $a * [Math]::PI / 180
            $x = [int][Math]::Round($centerX + $radiusX * [Math]::Cos($rad))
            $y = [int][Math]::Round($centerY + $radiusY * [Math]::Sin($rad))
            $distance = [Math]::Abs((($a - ($frame * 7)) % 360 + 360) % 360)
            if ($distance -lt 12 -or $distance -gt 348) { $c = $pink } else { $c = $hotPink }
            Write-At $x $y "●" $c
        }

        # Inel interior si puncte care dau impresia de miscare/rotatie.
        for ($a = 0; $a -lt 360; $a += 18) {
            $rad = ($a - $frame * 4) * [Math]::PI / 180
            $x = [int][Math]::Round($centerX + $innerX * [Math]::Cos($rad))
            $y = [int][Math]::Round($centerY + $innerY * [Math]::Sin($rad))
            Write-At $x $y "●" $pink
        }

        # Punct orbital care se roteste in interior.
        $orbit = ($frame * 11) * [Math]::PI / 180
        $ox = [int][Math]::Round($centerX + ($innerX * 0.72) * [Math]::Cos($orbit))
        $oy = [int][Math]::Round($centerY + ($innerY * 0.72) * [Math]::Sin($orbit))
        Write-At $ox $oy "●" $white

        Draw-Panel
        Write-At 1 ([Console]::WindowHeight - 2) "Ctrl+C pentru iesire" $white
        $frame++
        Start-Sleep -Milliseconds 75
    }
}
finally {
    [Console]::ResetColor()
    [Console]::CursorVisible = $true
    [Console]::WriteLine()
}