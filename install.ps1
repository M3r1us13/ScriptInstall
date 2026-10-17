Clear-Host

# Culori
$gold   = "`e[38;5;220m"
$cyan   = "`e[38;5;51m"
$green  = "`e[38;5;82m"
$red    = "`e[38;5;196m"
$gray   = "`e[38;5;245m"
$reset  = "`e[0m"

# Banner
Write-Host ""
Write-Host "$gold                 ▲$reset" 
Write-Host "$gold                ▲ ▲$reset"
Write-Host "$gold               ▲   ▲$reset"
Write-Host "$gold              ▲  ◉  ▲$reset"
Write-Host "$gold             ▲       ▲$reset"
Write-Host "$gold            ▲▲▲▲▲▲▲▲▲$reset"
Write-Host ""

Write-Host "$gold  I L L U M I N A T I   C O N S O L E$reset"
Write-Host "$gray  ───────────────────────────────────────$reset"
Write-Host ""

Write-Host "$cyan  [SYSTEM STATUS]$reset"
Write-Host "  Network integrity      $green 100%$reset"
Write-Host "  Surveillance nodes     $green 13 online$reset"
Write-Host "  Global influence       $gold 87.4%$reset"
Write-Host "  Threat level            $red ELEVATED$reset"
Write-Host ""

Write-Host "$cyan  [ACTIVE OPERATIONS]$reset"
Write-Host "  ◈ Operation: NIGHTFALL       $green ACTIVE$reset"
Write-Host "  ◈ Operation: EYEWATCH        $green ACTIVE$reset"
Write-Host "  ◈ Operation: BLACK SUN       $gold STANDBY$reset"
Write-Host ""

Write-Host "$gray  ───────────────────────────────────────$reset"
Write-Host "$gold  [1] Access Archives$reset"
Write-Host "$gold  [2] View Global Map$reset"
Write-Host "$gold  [3] Encrypt Channel$reset"
Write-Host "$gold  [Q] Exit$reset"
Write-Host ""

$choice = Read-Host "$cyan  illuminati@console:~$reset"

switch ($choice.ToUpper()) {
    "1" { Write-Host "$gold  Accessing classified archives...$reset" }
    "2" { Write-Host "$cyan  Loading global influence map...$reset" }
    "3" { Write-Host "$green  Secure channel established.$reset" }
    "Q" { Write-Host "$gray  Session terminated.$reset" }
    default { Write-Host "$red  Unknown command.$reset" }
}
