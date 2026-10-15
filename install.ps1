# Dezactivăm cursorul pentru ca animația să fie curată
[Console]::CursorVisible = $false
Clear-Host

# Inițializare coduri de culori ANSI
$ESC = [char]27
$C_RESET = "$ESC[0m"

# Culori Gradient Tobi / Cyber (Roz-Violet la bază, Portocaliu-Roșu sus)
$O1 = "$ESC[38;2;255;100;0m"   # Portocaliu închis
$O2 = "$ESC[38;2;255;140;40m"  # Portocaliu deschis
$R1 = "$ESC[38;2;220;30;60m"   # Roșu
$P1 = "$ESC[38;2;140;60;180m"  # Violet/Roz inchis
$P2 = "$ESC[38;2;200;100;230m" # Roz deschis
$W  = "$ESC[38;2;250;250;255m" # Alb / Highlight

# Cele două cadre ale animației (Tobi cu mască / Mișcare ușoară de umeri și ochi)
$Cadru1 = @(
    "         $O1.▄▄▀▀▀▀▀▀▄▄.$C_RESET",
    "       $O1.▄▀  ▄▄▄  ▄▄  ▀▄.$C_RESET",
    "      $O2/  ▄▀▀$W █ $O2▀▀  ▀▄  \.$C_RESET",
    "     $O2|  /   $W▄$O2    ▀▄  ▀  |.$C_RESET",
    "     $O2| |   $W█▀$R1▄$O1 ▀▄  ▀▄  ▀|$C_RESET",
    "     $O1| |   $R1█▄█$O1   █   █  |.$C_RESET",
    "     $O1\  \   $O2▀$O1   ▄▀  ▄▀  /.$C_RESET",
    "      $R1\  ▀▄▄▄▄▄▄▀▀  ▄▀  /.$C_RESET",
    "     $P1▄▀▀▀▄▄$R1▀▀▀▀▀▀▀▀▀$P1▄▄▄▄▄▄.$C_RESET",
    "   $P1▄▀    /  ▀▀▀▀▀▀▀▀▀▀   \   ▀▄.$C_RESET",
    "  $P2/     /  █▀▀▀▀█ █▀▀▀▀█  \    \.$C_RESET",
    " $P2|     |   █    █ █    █   |    |.$C_RESET",
    " $P1|     |   █▄▄▄▄█ █▄▄▄▄█   |    |.$C_RESET",
    "  $P1\     \                 /    /.$C_RESET",
    "   $P1▀▄    ▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▀    ▄▀.$C_RESET",
    "     $R1▀▀▀▀▀$P1               $R1▀▀▀▀▀.$C_RESET"
)

$Cadru2 = @(
    "         $O1.▄▄▀▀▀▀▀▀▄▄.$C_RESET",
    "       $O1.▄▀  ▄▄▄  ▄▄  ▀▄.$C_RESET",
    "      $O2/  ▄▀▀$R1 █ $O2▀▀  ▀▄  \.$C_RESET",
    "     $O2|  /   $R1▄$O2    ▀▄  ▀  |.$C_RESET",
    "     $O2| |   $R1█▀$W▄$O1 ▀▄  ▀▄  ▀|$C_RESET",
    "     $O1| |   $W█▄█$O1   █   █  |.$C_RESET",
    "     $O1\  \   $O2▀$O1   ▄▀  ▄▀  /.$C_RESET",
    "      $R1\  ▀▄▄▄▄▄▄▀▀  ▄▀  /.$C_RESET",
    "     $P1 ▄▀▀▀▄▄$R1▀▀▀▀▀▀▀▀$P1▄▄▄▄▄▄.$C_RESET",
    "   $P1 ▄▀    /  ▀▀▀▀▀▀▀▀▀▀   \   ▀▄.$C_RESET",
    "  $P2 /     /  █▀▀▀▀█ █▀▀▀▀█  \    \.$C_RESET",
    " $P2 |     |   █    █ █    █   |    |.$C_RESET",
    " $P1 |     |   █▄▄▄▄█ █▄▄▄▄█   |    |.$C_RESET",
    "  $P1 \     \                 /    /.$C_RESET",
    "   $P1 ▀▄    ▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▀    ▄▀.$C_RESET",
    "     $R1 ▀▀▀▀▀$P1              $R1▀▀▀▀▀.$C_RESET"
)

# Textul și Meniul din partea stângă (Fix, nu se mișcă)
Function AfiseazaMeniuStanga {
    [Console]::SetCursorPosition(0, 1)
    Write-Host " (marius@marius-PC)-[C:\Install\mine]" -ForegroundColor DarkGray
    Write-Host " $ " -ForegroundColor Green -NoNewline; Write-Host "./ultimate.ps1" -ForegroundColor White
    Write-Host ""
    Write-Host " Hmm, aşa cum mă aşteptam..." -ForegroundColor Gray
    Write-Host " Văd că ai nevoie de nişte valoare în sistem." -ForegroundColor DarkCyan
    Write-Host " Să-ţi punem Windows-ul pe picioare." -ForegroundColor DarkMagenta
    Write-Host ""
    Write-Host " Am adus tot ce e mai bun, nu ghici cine sunt..." -ForegroundColor DarkRed
    Write-Host " ...eu sunt doar un script de instalare." -ForegroundColor Gray
    Write-Host ""
    Write-Host " ╔═══════════════════════════════════════════╗" -ForegroundColor DarkGray
    Write-Host " ║  🔥 ALEGE O OPȚIUNE (Apasă 1, 2, 3 sau 4) ║" -ForegroundColor Yellow
    Write-Host " ╚═══════════════════════════════════════════╝" -ForegroundColor DarkGray
    Write-Host "  [1] 👉 Forță Maximă (Toate Utilitarele)" -ForegroundColor Green
    Write-Host "  [2] 👉 Modul Bombardier (Optimizare Windows)" -ForegroundColor Cyan
    Write-Host "  [3] 👉 RGB Style (Teme & Vizual)" -ForegroundColor Yellow
    Write-Host "  [4] 🛑 Ieșire din script" -ForegroundColor Red
    Write-Host ""
    Write-Host " Alege opţiunea [1-4]: " -ForegroundColor White -NoNewline
}

# Desenăm meniul fix o singură dată la început
AfiseazaMeniuStanga

# Buclă de animație pentru Tobi pe partea dreaptă
$count = 0
try {
    # Cât timp utilizatorul nu apasă o tastă, Tobi se mișcă
    while (-not [Console]::KeyAvailable) {
        $CadruCurent = if ($count % 2 -eq 0) { $Cadru1 } else { $Cadru2 }
        
        # Desenăm animația rând cu rând pe partea dreaptă
        for ($y = 0; $y -lt $CadruCurent.Count; $y++) {
            # Ne poziționăm la coordonata X: 47 (să nu se suprapună cu textul din stânga)
            [Console]::SetCursorPosition(48, 2 + $y)
            Write-Host $CadruCurent[$y]
        }
        
        $count++
        Start-Sleep -Milliseconds 250 # Viteza de clipire / mișcare
    }

    # Citim opțiunea apăsată de utilizator
    $optiune = [Console]::ReadKey($true).KeyChar

    # Executăm ce a ales omul
    switch ($optiune) {
        "1" {
            Clear-Host
            Write-Host "🚀 Se instalează utilitarele de forță, boss..." -ForegroundColor Green
            Start-Sleep -Seconds 3
        }
        "2" {
            Clear-Host
            Write-Host "⚡ Se aplică optimizarea de mare viteză pe Windows..." -ForegroundColor Cyan
            Start-Sleep -Seconds 3
        }
        "3" {
            Clear-Host
            Write-Host "🌈 Se descarcă culorile RGB..." -ForegroundColor Yellow
            Start-Sleep -Seconds 3
        }
        "4" {
            Clear-Host
            Write-Host "Baftă, boss! Să ne auzim cu bine și fără erori!" -ForegroundColor Red
            Exit
        }
        default {
            Clear-Host
            Write-Host "❌ Opțiune greșită! Ai apăsat altceva. Ieșire..." -ForegroundColor Red
        }
    }
}
finally {
    # Ne asigurăm că terminalul revine la starea normală la final
    [Console]::CursorVisible = $true
}