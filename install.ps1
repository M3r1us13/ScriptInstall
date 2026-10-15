# Dezactivăm cursorul pentru o experiență impecabilă
[Console]::CursorVisible = $false
Clear-Host

# Pre-încărcăm datele reale ale sistemului
$os = (Get-CimInstance Win32_OperatingSystem).Caption
$cpu = (Get-CimInstance Win32_Processor | Select-Object -First 1).Name
$ram = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB)
$gpuInfo = Get-CimInstance Win32_VideoController | Select-Object -First 1
$gpu = if ($gpuInfo) { $gpuInfo.Name } else { "Unknown GPU" }

# Inițializare coduri de culori ANSI
$ESC = [char]27
$RST = "$ESC[0m"

# Paleta de culori inspirată din estetica retro/hacker (Verde Neon, Gri Închis, Alb)
$Green  = "$ESC[38;2;50;255;50m"
$DGreen = "$ESC[38;2;20;150;20m"
$White  = "$ESC[38;2;255;255;255m"
$Gray   = "$ESC[38;2;170;170;170m"
$DGray  = "$ESC[38;2;80;80;80m"
$Cyan   = "$ESC[38;2;0;255;255m"

# --- MENIUL DIN DREAPTA (Informații Sistem) ---
$MeniuDreapta = @(
    "$DGray┌──────$Green THE WATCHER $DGray──────",
    "$DGray│ $Green System Analysis",
    "$DGray│ $DGreen 💻 OS $White     $os",
    "$DGray│ $DGreen 🖥️ RAM $White    $ram GB Memory",
    "$DGray│",
    "$DGray│ $Green Hardware Scan",
    "$DGray│ $DGreen 🧠 CPU $White    $cpu",
    "$DGray│ $DGreen 🎮 GPU $White    $gpu",
    "$DGray│",
    "$DGray│ $Green Execution Protocols",
    "$DGray│ $DGreen [1]$White 👉 Initiate Install Sequence",
    "$DGray│ $DGreen [2]$White ⚡ Override System Optimizations",
    "$DGray│ $DGreen [3]$White 🛑 Terminate Connection",
    "$DGray└$DGreen ─ $Green• $White─ $Green• $White─ $Green• $White─ $Green• $White─ $Green• $White─ $Green•",
    "",
    "$Gray> Awaiting command [1-3]: "
)

# Desenăm meniul fix o singură dată
for ($y = 0; $y -lt $MeniuDreapta.Count; $y++) {
    [Console]::SetCursorPosition(42, 3 + $y)
    Write-Host $MeniuDreapta[$y] -NoNewline
}

# --- ANIMAȚIA OCHIULUI MISTIC ---
# Definim piramida statică (structura de bază, fără ochi)
$PiramidaBase = @(
    "            $Green.$RST",
    "           $Green/ \$RST",
    "          $Green/   \$RST",
    "         $Green/     \$RST",
    "        $Green/       \$RST",
    "       $Green/  $DGreen.---.$Green  \$RST",
    "      $Green/  $DGreen/     \$Green  \$RST",
    "     $Green/  $DGreen|       |$Green  \$RST",
    "    $Green/   $DGreen\     /$Green   \$RST",
    "   $Green/     $DGreen'---'$Green     \$RST",
    "  $Green/                 \$RST",
    " $Green/                   \$RST",
    "$Green/_____________________\$RST"
)

# Desenăm baza piramidei
for ($y = 0; $y -lt $PiramidaBase.Count; $y++) {
    [Console]::SetCursorPosition(10, 5 + $y)
    Write-Host $PiramidaBase[$y] -NoNewline
}

# Coordonatele pentru interiorul ochiului (unde vom desena pupila)
$OchiY_Start = 11  # Rândul 6 din piramidă (0-indexed) este rândul 11 pe ecran (5 + 6)
$OchiY_Middle = 12 # Rândul 12 pe ecran
$OchiY_End = 13    # Rândul 13 pe ecran

# Definim stările ochiului (Pupila privește: Centru, Stânga, Dreapta)
$Ochi_Centru = @(
    "$DGreen/ $White.-. $DGreen\$RST",
    "$DGreen| $White( $CyanO $White) $DGreen|$RST",
    "$DGreen\ $White'-' $DGreen/$RST"
)

$Ochi_Stanga = @(
    "$DGreen/ $White.-. $DGreen\$RST",
    "$DGreen| $White($CyanO  $White) $DGreen|$RST",
    "$DGreen\ $White'-' $DGreen/$RST"
)

$Ochi_Dreapta = @(
    "$DGreen/ $White.-. $DGreen\$RST",
    "$DGreen| $White(  $CyanO$White) $DGreen|$RST",
    "$DGreen\ $White'-' $DGreen/$RST"
)

# Secvența de animație (stările ochiului)
$SecventaAnimatie = @($Ochi_Centru, $Ochi_Stanga, $Ochi_Centru, $Ochi_Dreapta)
$count = 0

try {
    # Bucla principală: Cât timp nu se apasă nicio tastă, ochiul se mișcă
    while (-not [Console]::KeyAvailable) {
        # Selectăm starea curentă din secvență
        $StareCurenta = $SecventaAnimatie[$count % $SecventaAnimatie.Count]
        
        # Redesenăm DOAR interiorul ochiului pentru a evita pâlpâirea
        # Poziția X=19 este calculată pentru a se potrivi exact în interiorul piramidei
        [Console]::SetCursorPosition(19, $OchiY_Start)
        Write-Host $StareCurenta[0] -NoNewline
        
        [Console]::SetCursorPosition(19, $OchiY_Middle)
        Write-Host $StareCurenta[1] -NoNewline
        
        [Console]::SetCursorPosition(19, $OchiY_End)
        Write-Host $StareCurenta[2] -NoNewline
        
        $count++
        
        # Viteza cu care ochiul scrutează încăperea
        Start-Sleep -Milliseconds 700
    }

    # Citim comanda utilizatorului
    $optiune = [Console]::ReadKey($true).KeyChar
    Clear-Host

    # Executăm opțiunea
    switch ($optiune) {
        "1" { 
            Write-Host "🚀 Initiating Install Sequence..." -ForegroundColor Green
            # Aici pui comenzile tale winget/choco
            Start-Sleep -Seconds 2 
        }
        "2" { 
            Write-Host "⚡ Overriding System Optimizations..." -ForegroundColor Cyan
            Start-Sleep -Seconds 2 
        }
        "3" { 
            Write-Host "Connection Terminated." -ForegroundColor Gray
            Exit 
        }
        default { 
            Write-Host "❌ Invalid Command. Connection Terminated." -ForegroundColor Red
            Exit 
        }
    }
}
finally {
    # Reactivăm cursorul la ieșire
    [Console]::CursorVisible = $true
}