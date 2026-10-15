# Dezactivăm cursorul
[Console]::CursorVisible = $false
Clear-Host

# Inițializare coduri de culori ANSI pentru a recrea tema Catppuccin / Mocha
$ESC = [char]27
$C_RESET = "$ESC[0m"

# Paleta de culori inspirată din tema Pain (Violet, Roz-Praf, Albastru Închis, Portocaliu stins)
$C1 = "$ESC[38;2;180;160;220m" # Mov deschis (Titlu)
$C2 = "$ESC[38;2;240;180;150m" # Portocaliu prăfuit
$C3 = "$ESC[38;2;130;130;180m" # Albastru-violet
$C4 = "$ESC[38;2;100;100;140m" # Gri-albastru închis
$W  = "$ESC[38;2;220;220;230m" # Alb-gri (Highlight)
$Txt = "$ESC[38;2;160;160;180m" # Text principal
$TxtH = "$ESC[38;2;230;170;140m" # Text Highlight (Portocaliu)

# --- TITLUL MASIV (PAIN-TENDO) ---
Function AfiseazaTitlu {
    [Console]::SetCursorPosition(2, 1)
    Write-Host "$C1 ▄▄▄▄▄▄▄ $C2▄▄▄▄▄▄▄ $C1▄▄▄ $C4▄▄    ▄ $C3▄▄▄▄▄▄▄ $C1▄▄▄▄▄▄▄ $C2▄▄    ▄ $C1▄▄▄▄▄▄  $C4▄▄▄▄▄▄▄ $C_RESET"
    [Console]::SetCursorPosition(2, 2)
    Write-Host "$C1 █       █$C2       █$C1   █$C4  █  █ $C3       █$C1       █$C2  █  █ $C1      █ $C4       █$C_RESET"
    [Console]::SetCursorPosition(2, 3)
    Write-Host "$C1 █    ▄  █$C2   ▄   █$C1   █$C4   █▄█ $C3▄▄▄▄   █$C1▄▄▄▄   █$C2   █▄█ $C1  ▄    █$C4   ▄   █$C_RESET"
    [Console]::SetCursorPosition(2, 4)
    Write-Host "$C3 █   █▄█ █$C1  █▄█  █$C2   █$C1       $C4    █  █$C3    █  █$C1       $C2 █ █   █$C1  █ █  █$C_RESET"
    [Console]::SetCursorPosition(2, 5)
    Write-Host "$C3 █    ▄▄▄█$C1       █$C2   █$C1  ▄    $C4    █  █$C3    █  █$C1  ▄    $C2 █▄█   █$C1  █▄█  █$C_RESET"
    [Console]::SetCursorPosition(2, 6)
    Write-Host "$C4 █   █   $C3 █   ▄   █$C1   █$C2 █ █  $C1    █  █$C4    █  █$C3 █ █   $C1       █$C2       █$C_RESET"
    [Console]::SetCursorPosition(2, 7)
    Write-Host "$C4 █▄▄▄█   $C3 █▄▄▄█ █▄▄▄█$C1 █▄█  █$C2    █▄▄█$C1    █▄▄█$C4 █▄█  █$C3 ▄▄▄▄▄▄█$C1 ▄▄▄▄▄▄▄█$C_RESET"
    
    # Bara colorată de sub titlu
    [Console]::SetCursorPosition(4, 9)
    Write-Host "$C2████████████████$C1████████████████$C3████████████████$C4████████████████$C_RESET"
}

# --- TEXTUL POETIC (Stânga) ---
Function AfiseazaTextStanga {
    [Console]::SetCursorPosition(4, 12)
    Write-Host "$Txt However, what about my family, my friends,"
    [Console]::SetCursorPosition(4, 13)
    Write-Host "$Txt my village? They suffer the same fate"
    [Console]::SetCursorPosition(4, 14)
    Write-Host "$Txt as this village at the hands of you"
    [Console]::SetCursorPosition(4, 15)
    Write-Host "$TxtH Hidden Leaf Ninja. How is it fair to let"
    [Console]::SetCursorPosition(4, 16)
    Write-Host "$TxtH only you people preach about peace"
    [Console]::SetCursorPosition(4, 17)
    Write-Host "$TxtH and justice?"

    [Console]::SetCursorPosition(4, 19)
    Write-Host "$Txt There is a point in life where loss changes"
    [Console]::SetCursorPosition(4, 20)
    Write-Host "$Txt the shape of your vision forever."
    
    [Console]::SetCursorPosition(4, 22)
    Write-Host "$Txt I have lost too much, friends, dreams,"
    [Console]::SetCursorPosition(4, 23)
    Write-Host "$TxtH the warmth that once guided my steps."
    
    [Console]::SetCursorPosition(4, 25)
    Write-Host "$Txt I did not choose this path because"
    [Console]::SetCursorPosition(4, 26)
    Write-Host "$Txt I wanted to change. I chose it because"
    [Console]::SetCursorPosition(4, 27)
    Write-Host "$TxtH I could no longer see the world through"
    [Console]::SetCursorPosition(4, 28)
    Write-Host "$TxtH untouched eyes."

    [Console]::SetCursorPosition(4, 32)
    Write-Host "$C4 - Pain, $Txt Naruto Shippuden"
    
    # Meniul mic de jos
    [Console]::SetCursorPosition(4, 35)
    Write-Host "$C1 [1]$Txt Instalare Completa   $C1[2]$Txt Curatare Sistem   $C1[3]$Txt Exit"
    [Console]::SetCursorPosition(4, 36)
    Write-Host "$Txt Astept decizia... " -NoNewline
}

# --- ANIMAȚIA PAIN (Dreapta) ---
# Două cadre subtile care simulează vântul prin părul lui Pain și o sclipire în ochiul Rinnegan.
$CadruPain1 = @(
    "                $C4.▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄.$C_RESET",
    "            $C4.▄▀▀                  ▀▀▄.$C_RESET",
    "          $C4.▄▀      $C3.▄▄▄▄▄▄▄▄▄.$C4       ▀▄.$C_RESET",
    "         $C4/     $C3▄▀▀▀         ▀▀▀▄$C4      \.$C_RESET",
    "        $C4|     $C3/                 \$C4     |.$C_RESET",
    "       $C4/     $C3|  $C1▄▄▄▄▄$C3     $C1▄▄▄▄▄$C3  |$C4     \.$C_RESET",
    "       $C4|     $C3| $C1/     \$C3   $C1/     \$C3 |$C4     |.$C_RESET",
    "       $C4\   $C4.▄▄$C3| $W(  ●  )$C3   $W(  ●  )$C3 |$C4▄▄.$C4   /.$C_RESET",
    "        $C4▀▄$C3/   \ $C1\▄▄▄▄/$C3   $C1\▄▄▄▄/$C3 /   \$C4▄▀.$C_RESET",
    "          $C3\    ▀▄▄▄▄   $C4|$C3   ▄▄▄▄▀    /.$C_RESET",
    "           $C3\       /   $C4|$C3   \       /.$C_RESET",
    "            $C3▀▄▄▄▄▄/ $C2▄▄▄▄▄▄▄$C3 \▄▄▄▄▄▀.$C_RESET",
    "                 $C3/ $C2/       \$C3 \.$C_RESET",
    "                $C3| $C2| ▄▄▄▄▄▄▄ |$C3 |.$C_RESET",
    "                $C3\ $C2\  ▀▀▀▀▀  /$C3 /.$C_RESET",
    "                 $C3▀▄ $C2▀▀▀▀▀▀▀ $C3▄▀.$C_RESET",
    "            $C1▄▄▄▄▄▄▄$C3▀▀▄▄▄▄▄▀▀$C1▄▄▄▄▄▄▄.$C_RESET",
    "          $C1▄▀                       ▀▄.$C_RESET",
    "         $C1/▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄\.$C_RESET",
    "        $C2/▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄\.$C_RESET",
    "       $C3/▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄\.$C_RESET",
    "      $C4/▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄\.$C_RESET"
)

$CadruPain2 = @(
    "                $C4.▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄.$C_RESET",
    "            $C4.▄▀▀                  ▀▀▄.$C_RESET",
    "          $C4.▄▀      $C3.▄▄▄▄▄▄▄▄▄.$C4       ▀▄.$C_RESET",
    "         $C4/     $C3▄▀▀▀         ▀▀▀▄$C4      \.$C_RESET",
    "        $C4|     $C3/                 \$C4     |.$C_RESET",
    "       $C4/     $C3|  $C1▄▄▄▄▄$C3     $C1▄▄▄▄▄$C3  |$C4     \.$C_RESET",
    "       $C4|     $C3| $C1/     \$C3   $C1/     \$C3 |$C4     |.$C_RESET",
    "       $C4\   $C4.▄▄$C3| $C1(  $W●$C1  )$C3   $C1(  $W●$C1  )$C3 |$C4▄▄.$C4   /.$C_RESET",
    "        $C4▀▄$C3/   \ $C1\▄▄▄▄/$C3   $C1\▄▄▄▄/$C3 /   \$C4▄▀.$C_RESET",
    "          $C3\    ▀▄▄▄▄   $C4|$C3   ▄▄▄▄▀    /.$C_RESET",
    "           $C3\       /   $C4|$C3   \       /.$C_RESET",
    "            $C3▀▄▄▄▄▄/ $C2▄▄▄▄▄▄▄$C3 \▄▄▄▄▄▀.$C_RESET",
    "                 $C3/ $C2/       \$C3 \.$C_RESET",
    "                $C3| $C2| ▄▄▄▄▄▄▄ |$C3 |.$C_RESET",
    "                $C3\ $C2\  ▀▀▀▀▀  /$C3 /.$C_RESET",
    "                 $C3▀▄ $C2▀▀▀▀▀▀▀ $C3▄▀.$C_RESET",
    "            $C1▄▄▄▄▄▄▄$C3▀▀▄▄▄▄▄▀▀$C1▄▄▄▄▄▄▄.$C_RESET",
    "          $C1▄▀                       ▀▄.$C_RESET",
    "         $C1/▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄\.$C_RESET",
    "        $C2/▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄\.$C_RESET",
    "       $C3/▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄\.$C_RESET",
    "      $C4/▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄\.$C_RESET"
)

# Desenăm Titlul și Textul fix
AfiseazaTitlu
AfiseazaTextStanga

# Buclă de animație pentru Pain pe partea dreaptă
$count = 0
try {
    # Cât timp nu se apasă o tastă, portretul pulsează ușor
    while (-not [Console]::KeyAvailable) {
        $CadruCurent = if ($count % 2 -eq 0) { $CadruPain1 } else { $CadruPain2 }
        
        # Desenăm animația rând cu rând pe partea dreaptă, pornind de la X=55, Y=12
        for ($y = 0; $y -lt $CadruCurent.Count; $y++) {
            [Console]::SetCursorPosition(55, 11 + $y)
            Write-Host $CadruCurent[$y]
        }
        
        $count++
        Start-Sleep -Milliseconds 400 # Viteză lentă, melancolică
    }

    # Citim opțiunea
    $optiune = [Console]::ReadKey($true).KeyChar
    Clear-Host

    # Executăm opțiunea aleasă
    switch ($optiune) {
        "1" { Write-Host "$C2> Shinra Tensei! (Instalare pornită...)$C_RESET"; Start-Sleep -Seconds 2 }
        "2" { Write-Host "$C3> Lumea va cunoaște curățarea...$C_RESET"; Start-Sleep -Seconds 2 }
        "3" { Write-Host "$C1> Ieșire...$C_RESET"; Exit }
        default { Write-Host "$C4> Opțiune invalidă.$C_RESET"; Exit }
    }
}
finally {
    [Console]::CursorVisible = $true
}