# Dezactivăm cursorul pentru o experiență impecabilă
[Console]::CursorVisible = \$false
Clear-Host

# Pre-încărcăm datele reale ale sistemului
\$os = (Get-CimInstance Win32_OperatingSystem).Caption
\(cpu = (Get-CimInstance Win32_Processor \vert{} Select-Object -First 1).Name\)ram = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB)
\(gpuInfo = Get-CimInstance Win32_VideoController \vert{} Select-Object -First 1\)gpu = if (gpuInfo) gpuInfo.Name } else { "Unknown GPU" }

# Inițializare coduri de culori ANSI
\$ESC = [char]27
RST = "ESC[0m"

# Paleta de culori inspirată din estetica retro/hacker
Green = "ESC[38;2;50;255;50m"
DGreen = "ESC[38;2;20;150;20m"
White = "ESC[38;2;255;255;255m"
Gray = "ESC[38;2;170;170;170m"
DGray = "ESC[38;2;80;80;80m"
Cyan = "ESC[38;2;0;255;255m"

# --- MENIUL DIN DREAPTA (Informații Sistem) ---
\$MeniuDreapta = @(
    "\$DGray┌──────Green THE WATCHER DGray──────",
    "DGray│ Green System Analysis",
    "DGray│ DGreen 💻 OS White os",
    "DGray│ DGreen 🖥️ RAM White ram GB Memory",
    "\$DGray│",
    "DGray│ Green Hardware Scan",
    "DGray│ DGreen 🧠 CPU White cpu",
    "DGray│ DGreen 🎮 GPU White gpu",
    "\$DGray│",
    "DGray│ Green Execution Protocols",
    "\$DGray│ \(DGreen [1]\)White 👉 Initiate Install Sequence",
    "\$DGray│ \(DGreen [2]\)White ⚡ Override System Optimizations",
    "\$DGray│ \(DGreen [3]\)White 🛑 Terminate Connection",
    "\$DGray└DGreen ─ Green• White─ Green• White─ Green• White─ Green• White─ Green• White─ Green•",
    "",
    "\$Gray> Awaiting command [1-3]: "
)

# Desenăm meniul fix o singură dată (mutat puțin mai la dreapta: X=48 pentru a nu se suprapune cu piramida lată)
for (y = 0; y -lt MeniuDreapta.Count; y++) {
    [Console]::SetCursorPosition(48, 3 + \$y)
    Write-Host \(MeniuDreapta[\)y] -NoNewline
}

# --- ANIMAȚIA OCHIULUI MISTIC (Din Imaginea Ta) ---
# Definim structura de bază a piramidei din poza ta (cu spațiu gol în mijloc pentru animație)
\$PiramidaBase = @(
    "               GreenJ:RST",
    "             Green' J88;RST      '",
    "            GreenJIiiii;RST",
    "           GreenJIi;;ii;RST",
    "      \({DGray}\"-\){RST}   \({Green}JIiiiii`\)\$`$;$RST   ${DGray}-\"$RST",
    "          ${Green}J`\$`$   `\$`$;$RST",
    "         ${Green}J`\$F'RST {Green}`$:$RST",
    "        ${Green}J8'.$RST           ${Green}.`;RST",
    "  \${DGray}_.._RST {Green}JI8b.RST {Green}.d`$`\$`$:$RST ${DGray}_.._$RST",
    "      ${Green}JiIiI8`\$`$888`\$`$`\$iiii`$;$RST",
    "     ${Green}Jii;;;iiiiiiiii;;;;i`;RST",
    "    \${Green}J88iiiiiiiiiiilli;iiii`$`;RST",
    "    \({Green}\nnnnnnnnnnnnnnnnnnnnnn/\)RST",
    "               DGreen;RST",
    "               DGreen;RST         '",
    "               DGreen;RST"
)

# Desenăm baza piramidei complete
for (y = 0; y -lt PiramidaBase.Count; y++) {
    [Console]::SetCursorPosition(2, 2 + \$y)
    Write-Host \(PiramidaBase[\)y] -NoNewline
}

# Coordonatele exacte pe ecran unde decupăm și inserăm mișcarea ochiului
\$OchiY_Start = 7   # Corespunde liniei cu "J\$F'..."
\$OchiY_Middle = 8  # Corespunde liniei cu "J8'..."
\$OchiY_End = 9     # Corespunde liniei cu "JI8b..."

# Cele 3 stări de animație fidele textului original din imaginea ta
\$Ochi_Centru = @(
    "\({DGreen}.._.._\)RST",
    "\${DGreen}`JL$RST  ${Cyan}:;$RST${DGreen}`.\$RST",
    " \${White}`\"\"`\$RST "
)

\$Ochi_Stanga = @(
    "\({DGreen}.._.._\)RST",
    "\${Cyan}:;RST{DGreen}`JL  `.\$RST",
    " \${White}`\"\"`\$RST "
)

\$Ochi_Dreapta = @(
    "\({DGreen}.._.._\)RST",
    "\${DGreen}`JL  `.\$RSTCyan:;RST",
    " \${White}`\"\"`\$RST "
)

# Secvența de animație (Centru -> Stânga -> Centru -> Dreapta)
\(SecventaAnimatie = @(\)Ochi_Centru, \(Ochi_Stanga,\)Ochi_Centru, \(Ochi_Dreapta)\)count = 0

try {
    # Bucla principală: Ochiul se mișcă până când utilizatorul apasă o tastă
    while (-not [Console]::KeyAvailable) {
        StareCurenta = SecventaAnimatie[\(count \%\)SecventaAnimatie.Count]
        
        # Inserăm dinamic pupila în mijlocul piramidei text (Poziția X=19 este aliniată perfect)
        [Console]::SetCursorPosition(19, \$OchiY_Start)
        Write-Host \$StareCurenta[0] -NoNewline
        
        [Console]::SetCursorPosition(19, \$OchiY_Middle)
        Write-Host \$StareCurenta[1] -NoNewline
        
        [Console]::SetCursorPosition(19, \$OchiY_End)
        Write-Host \(StareCurenta[2] -NoNewline\)count++
        Start-Sleep -Milliseconds 750
    }

    # Citim comanda introdusă (1, 2 sau 3)
    \(optiune = [Console]::ReadKey(\)true).KeyChar
    Clear-Host

    # Executăm instrucțiunea selectată
    switch (\$optiune) {
        "1" { 
            Write-Host "🚀 Initiating Install Sequence..." -ForegroundColor Green
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
    # Resetăm cursorul la starea inițială în caz de închidere
    [Console]::CursorVisible = \$true
}
