# neofetch-style.ps1
# PowerShell recreation of the reference image: ASCII art left, system info right.
# Recommended: Windows Terminal, font Cascadia Mono or JetBrains Mono.

$ErrorActionPreference = 'SilentlyContinue'
$ESC = [char]27
$Reset = "$ESC[0m"
$Dim = "$ESC[2m"
$Bold = "$ESC[1m"
$Pink = "$ESC[38;5;175m"
$Rose = "$ESC[38;5;181m"
$Text = "$ESC[38;5;252m"
$Muted = "$ESC[38;5;245m"
$Blue = "$ESC[38;5;110m"
$Green = "$ESC[38;5;114m"
$Gold = "$ESC[38;5;216m"

function Strip-Ansi([string]$s) {
    if ($null -eq $s) { return '' }
    [regex]::Replace($s, "$ESC\[[0-9;]*m", '')
}

function Pad-Visible([string]$s, [int]$width) {
    $n = (Strip-Ansi $s).Length
    if ($n -ge $width) { return $s.Substring(0, [Math]::Max(0, $width - 1)) + 'â€¦' }
    $s + (' ' * ($width - $n))
}

function Safe($value, $fallback = 'N/A') {
    if ($null -eq $value -or [string]::IsNullOrWhiteSpace("$value")) { return $fallback }
    "$value".Trim()
}

function Size($bytes) {
    if ($bytes -ge 1TB) { return ('{0:N1} TB' -f ($bytes / 1TB)) }
    if ($bytes -ge 1GB) { return ('{0:N1} GB' -f ($bytes / 1GB)) }
    if ($bytes -ge 1MB) { return ('{0:N0} MB' -f ($bytes / 1MB)) }
    ('{0:N0} B' -f $bytes)
}

function Get-SystemInfo {
    $cs = Get-CimInstance Win32_ComputerSystem
    $os = Get-CimInstance Win32_OperatingSystem
    $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
    $gpu = Get-CimInstance Win32_VideoController | Select-Object -First 1
    $bios = Get-CimInstance Win32_BIOS | Select-Object -First 1
    $board = Get-CimInstance Win32_BaseBoard | Select-Object -First 1
    $disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='$($env:SystemDrive)'"
    $nic = Get-CimInstance Win32_NetworkAdapterConfiguration -Filter 'IPEnabled=True' | Select-Object -First 1

    $ramTotal = [double]$cs.TotalPhysicalMemory
    $ramUsed = $ramTotal - ([double]$os.FreePhysicalMemory * 1KB)
    $ip = 'N/A'
    if ($nic.IPAddress) {
        $ip = $nic.IPAddress | Where-Object { $_ -match '^\d{1,3}(\.\d{1,3}){3}$' } | Select-Object -First 1
    }

    [PSCustomObject]@{
        User = Safe $env:USERNAME
        Host = Safe $env:COMPUTERNAME
        OS = Safe $os.Caption
        Kernel = Safe $os.Version
        Uptime = ((Get-Date) - $os.LastBootUpTime).ToString('dd') + ' days, ' + ((Get-Date) - $os.LastBootUpTime).ToString('hh') + ' hrs'
        Shell = "PowerShell $($PSVersionTable.PSVersion.Major)"
        Resolution = try { "$([Console]::WindowWidth)x$([Console]::WindowHeight) terminal" } catch { 'Console' }
        CPU = Safe $cpu.Name
        GPU = Safe $gpu.Name
        Memory = "$(Size $ramUsed) / $(Size $ramTotal)"
        Cores = "$($cpu.NumberOfCores) cores / $($cpu.NumberOfLogicalProcessors) threads"
        Board = "$(Safe $board.Manufacturer) $(Safe $board.Product)"
        BIOS = Safe $bios.SMBIOSBIOSVersion
        Storage = "$(Safe $disk.DeviceID) $(Size $disk.Size) / free $(Size $disk.FreeSpace)"
        IPv4 = Safe $ip
        MAC = Safe $nic.MACAddress
    }
}

function Draw {
    $i = Get-SystemInfo
    $logo = @(
        "$Pink                 .-+$Reset",
        "$Pink                /ooo\$Reset",
        "$Rose              .+ooooo+.$Reset",
        "$Rose             :+ooooooo+:$Reset",
        "$Rose           ./+ooooooooo+\.$Reset",
        "$Pink          ./+ooooooooooo+\.$Reset",
        "$Pink        ./+ooooooooooooo+\.$Reset",
        "$Pink       :/+++++++++++++++++:$Reset",
        "$Rose      :/+++++++++++++++++++:$Reset",
        "$Rose     -++++++++++++++++++++++-$Reset",
        "$Pink    -++++++++++++++++++++++++-$Reset",
        "$Pink   .++++++++++++++++++++++++++.$Reset",
        "$Rose   :++++++++++++++++++++++++++:$Reset",
        "$Rose    -++++++++++++++++++++++++-$Reset",
        "$Pink     .++++++++++++++++++++++.$Reset",
        "$Pink       :++++++++++++++++++:$Reset",
        "$Rose        .-+++++++++++++-.$Reset",
        "$Rose           .-++++++++-.$Reset",
        "$Pink              .-++-.$Reset"
    )

    $info = @(
        "$Pink$Bold$($i.User)@$($i.Host)$Reset",
        "$Muted---------------------------$Reset",
        "$Text OS:           $($i.OS)$Reset",
        "$Text Host:         $($i.Host)$Reset",
        "$Text Kernel:       $($i.Kernel)$Reset",
        "$Text Uptime:       $($i.Uptime)$Reset",
        "$Text Packages:     native Windows$Reset",
        "$Text Shell:        $($i.Shell)$Reset",
        "$Text Resolution:   $($i.Resolution)$Reset",
        "$Text Terminal:     Windows Terminal$Reset",
        "$Text Theme:        Obsidian / Rose$Reset",
        "$Text CPU:          $($i.CPU)$Reset",
        "$Text Cores:        $($i.Cores)$Reset",
        "$Text GPU:          $($i.GPU)$Reset",
        "$Text Memory:       $($i.Memory)$Reset",
        "$Text Board:        $($i.Board)$Reset",
        "$Text BIOS:         $($i.BIOS)$Reset",
        "$Text Storage:      $($i.Storage)$Reset",
        "$Text IPv4:         $($i.IPv4)$Reset",
        "$Text MAC:          $($i.MAC)$Reset",
        '',
        "$Pink    â–ˆ$Rose    â–ˆ$Gold    â–ˆ$Blue    â–ˆ$Green    â–ˆ$Muted    â–ˆ$Reset"
    )

    Clear-Host
    Write-Host ''
    $rows = [Math]::Max($logo.Count, $info.Count)
    for ($n = 0; $n -lt $rows; $n++) {
        $l = if ($n -lt $logo.Count) { $logo[$n] } else { '' }
        $r = if ($n -lt $info.Count) { $info[$n] } else { '' }
        Write-Host ((Pad-Visible $l 42) + '   ' + $r)
    }
    Write-Host ''
    Write-Host "$Dim$Muted  neofetch-style PowerShell â€¢ [R] refresh â€¢ [Q] quit$Reset"
}

try {
    [Console]::CursorVisible = $false
    while ($true) {
        Draw
        $until = (Get-Date).AddSeconds(3)
        while ((Get-Date) -lt $until) {
            if ([Console]::KeyAvailable) {
                $key = [Console]::ReadKey($true).Key
                if ($key -eq 'Q') { return }
                if ($key -eq 'R') { break }
            }
            Start-Sleep -Milliseconds 100
        }
    }
}
finally {
    [Console]::CursorVisible = $true
    Write-Host $Reset
}