# Dezactivăm cursorul pentru o experiență curată
[Console]::CursorVisible = $false
Clear-Host

# Pre-încărcăm datele reale ale sistemului pentru a le afișa în meniu
$os = (Get-CimInstance Win32_OperatingSystem).Caption
$cpu = (Get-CimInstance Win32_Processor | Select-Object -First 1).Name
$ram = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB)
$gpuInfo = Get-CimInstance Win32_VideoController | Select-Object -First 1
$gpu = if ($gpuInfo) { $gpuInfo.Name } else { "Unknown GPU" }

# Inițializare coduri de culori ANSI
$ESC = [char]27
$RST = "$ESC[0m"

# Paleta de culori inspirată din imaginea ta (Roz, Magenta, Alb, Gri)
$Pink  = "$ESC[38;2;240;50;100m"
$DPink = "$ESC[38;2;180;30;80m"
$White = "$ESC[38;2;255;255;255m"
$Gray  = "$ESC[38;2;170;170;170m"
$DGray = "$ESC[38;2;100;100;100m"

# --- ANIMAȚIA DIN STÂNGA (Logo stil Swirl / Debian) ---
# Cadrul 1
$Swirl1 = @(
    "           $Pink.▄▄▄▄▄▄▄▄▄▄▄▄▄▄.           ",
    "        $Pink▄████████████████████▄        ",
    "      $Pink▄████████████████████████▄      ",
    "     $Pink████████████████████████████     ",
    "    $Pink████████████$White▀▀▀▀▀▀$Pink███████████    ",
    "   $Pink██████████▀          ▀█████████   ",
    "   $Pink█████████    $DPink▄▄▄▄▄▄$Pink    ████████   ",
    "  $Pink█████████   $DPink▄████████▄$Pink   ████████  ",
    "  $Pink████████   $DPink████████████$Pink  ███████  ",
    "  $Pink███████   $DPink████████████$Pink   ██████  ",
    "   $Pink███████   $DPink██████████$Pink   ██████   ",
    "    $Pink███████   $DPink▀██████▀$Pink   ██████    ",
    "     $Pink███████▄          ▄██████     ",
    "       $Pink████████▄▄▄▄▄▄███████       ",
    "         $Pink▀████████████████▀         ",
    "            $Pink▀▀████████▀▀            "
)

# Cadrul 2 (Pulsul animației - se schimbă culorile highlight-urilor)
$Swirl2 = @(
    "           $Pink.▄▄▄▄▄▄▄▄▄▄▄▄▄▄.           ",
    "        $Pink▄████████████████████▄        ",
    "      $Pink▄████████████████████████▄      ",
    "     $Pink████████████████████████████     ",
    "    $Pink████████████$White▀▀▀▀▀▀$Pink███████████    ",
    "   $Pink██████████▀          ▀█████████   ",
    "   $Pink█████████    $White▄▄▄▄▄▄$Pink    ████████   ",
    "  $Pink█████████   $White▄████████▄$Pink   ████████  ",
    "  $Pink████████   $White████████████$Pink  ███████  ",
    "  $Pink███████   $White████████████$Pink   ██████  ",
    "   $Pink███████   $White██████████$Pink   ██████   ",
    "    $Pink███████   $White▀██████▀$Pink   ██████    ",
    "     $Pink███████▄          ▄██████     ",
    "       $Pink████████▄▄▄▄▄▄███████       ",
    "         $Pink▀████████████████▀         ",
    "            $Pink▀▀████████▀▀            "
)

# --- MENIUL DIN DREAPTA (Stil System Fetch) ---
$MeniuDreapta = @(
    "$White╭──────$Pink script-installer $White──────",
    "$White│ $Pink System Information",
    "$White│ $DPink 💻 OS $White     $os",
    "$White│ $DPink 🖥️ RAM $White    $ram GB Memory",
    "$White│",
    "$White│ $Pink Hardware Information",
    "$White│ $DPink 🧠 CPU $White    $cpu",
    "$White│ $DPink 🎮 GPU $White    $gpu",
    "$White│",
    "$White│ $Pink Interactive Menu",
    "$White│ $DPink [1]$White 👉 Instalează Pachetele",
    "$White│ $DPink [2]$White ⚡ Optimizare Windows",
    "$White│ $DPink [3]$White 🛑 Ieșire",
    "$White╰$DPink ─ $Pink• $White─ $Pink• $White─ $Pink• $White─ $Pink• $White─ $Pink• $White─ $Pink•",
    "",
    "$Gray> Alege o opțiune [1-3]: "
)

# Desenăm doar textul din dreapta o singură dată (nu trebuie să pâlpâie)
for ($y = 0; $y -lt $MeniuDreapta.Count; $y++) {
    [Console]::SetCursorPosition(40, 2 + $y)
    Write-Host $MeniuDreapta[$y] -NoNewline
}

# --- BUCLA DE ANIMAȚIE ---
$count = 0
try {
    # Cât timp nu s-a apăsat nicio tastă, facem efectul de puls pe logo
    while (-not [Console]::KeyAvailable) {
        $CadruCurent = if ($count % 2 -eq 0) { $Swirl1 } else { $Swirl2 }
        
        # Desenăm logoul pe partea stângă
        for ($y = 0; $y -lt $CadruCurent.Count; $y++) {
            [Console]::SetCursorPosition(2, 2 + $y)
            Write-Host $CadruCurent[$y] -NoNewline
        }
        
        $count++
        # Pauză mică pentru efectul de breathing
        Start-Sleep -Milliseconds 500 
    }

    # Utilizatorul a apăsat o tastă, o citim
    $optiune = [Console]::ReadKey($true).KeyChar
    Clear-Host

    # Executăm opțiunea aleasă
    switch ($optiune) {
        "1" { 
            Write-Host "🚀 Pornim instalarea pachetelor..." -ForegroundColor Green
            Start-Sleep -Seconds 2 
        }
        "2" { 
            Write-Host "⚡ Aplicăm scripturile de optimizare..." -ForegroundColor Cyan
            Start-Sleep -Seconds 2 
        }
        "3" { 
            Write-Host "Ieșire din script. O zi bună!" -ForegroundColor Gray
            Exit 
        }
        default { 
            Write-Host "❌ Opțiune invalidă!" -ForegroundColor Red
            Exit 
        }
    }
}
finally {
    # Reactivăm cursorul la finalul programului
    [Console]::CursorVisible = $true
}