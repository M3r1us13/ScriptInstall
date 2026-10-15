# Acesta este un script de test
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Salut! Scriptul tău a fost descărcat și rulat cu succes!" -ForegroundColor Green
Write-Host "Sistemul tău de operare este: $(Get-CimInstance Win32_OperatingSystem | Select-Object -ExpandProperty Caption)" -ForegroundColor Yellow
Write-Host "Bine Pa" -ForegroundColor Red
Write-Host "Bine Pa" -ForegroundColor Green
Write-Host "Bine Pa" -ForegroundColor Blue
Write-Host "Bine Pa" -ForegroundColor Magenta
Write-Host "=====================================" -ForegroundColor Cyan