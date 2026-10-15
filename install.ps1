# Dezactivăm cursorul pentru ca animația să fie curată
[Console]::CursorVisible = $false
Clear-Host

# Titlul interactiv și colorat
Write-Host "========================================================" -ForegroundColor Magenta
Write-Host " 🔥 INSTALATORUL SUPREM - PETRECEREA IN IT A ÎNCEPUT! 🔥" -ForegroundColor Cyan
Write-Host "      Apasă [CTRL + C] pentru a opri marea valoare.     " -ForegroundColor Yellow
Write-Host "========================================================" -ForegroundColor Magenta
Start-Sleep -Seconds 2

# Cadrele animației (Bombardierul care dansează / Parrot românesc)
$cadre = @(
    # Cadrul 1
    @{
        text = "
     (•_•)   😎
    <) )>⛓️  [SĂ SARĂ BITURILE, BO$$!]
    /   \
        "
        culoare = "Green"
    },
    # Cadrul 2
    @{
        text = "
    \(•_•)  
     (   (> ⛓️ [SE ÎNCARCĂ MAREA FORȚĂ... 99%]
     /   \
        "
        culoare = "Yellow"
    },
    # Cadrul 3
    @{
        text = "
     (•_•)/ 
    <)   )  ⛓️ [FĂRĂ ERORI, DOAR VALOARE!]
     /   \
        "
        culoare = "Cyan"
    },
    # Cadrul 4
    @{
        text = "
    \(•_•)/ 🔥
     (   )  ⛓️ [MARIUS A DAT SYNC DIN VS CODE!]
     /   \
        "
        culoare = "Red"
    },
    # Cadrul 5
    @{
        text = "
     (•_•)   
    <) )>⛓️  [AICI E NEBUNIE PE INSTALARE!]
    /   \
        "
        culoare = "Magenta"
    }
)

# Rulăm bucla la infinit (până la CTRL+C)
try {
    while ($true) {
        foreach ($cadru in $cadre) {
            # Repoziționăm cursorul sus ca să nu pâlpâie ecranul
            [Console]::SetCursorPosition(0, 4)
            
            # Afișăm cadrul cu culoarea lui specifică
            Write-Host $cadru.text -ForegroundColor $cadru.culoare
            
            # Un mic efect sonor de "petrecere" (opțional, poți șterge linia de jos dacă devine enervant)
            # [Console]::Beep(100 + (Get-Random -Maximum 300), 50)
            
            # Viteza animației (0.2 secunde între cadre)
            Start-Sleep -Milliseconds 200
        }
    }
}
finally {
    # Reactivăm cursorul când utilizatorul oprește scriptul
    [Console]::CursorVisible = $true
    Clear-Host
    Write-Host "Gata, șefu'! Ne-am întors la muncă. Trăiască IT-ul!" -ForegroundColor Green
}
```Iată cum va arăta pe ecranul PowerShell-ului tău când vei rula noua comandă:



http://googleusercontent.com/image_generation_content/27_807