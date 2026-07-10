# =====================================================================
#  3-Desinstalar.ps1
#  Muestra los programas instalados y deja ELEGIR cuales desinstalar.
#  Modo interactivo (seguro): nada se quita sin tu confirmacion.
# =====================================================================
. "$PSScriptRoot\_Comun.ps1"
Assert-Admin $PSCommandPath

Write-Titulo "DESINSTALADOR INTERACTIVO DE PROGRAMAS"

# --- Reunir programas desde el registro (32 y 64 bits) ---
$rutas = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
)
$prog = foreach ($r in $rutas) {
    Get-ItemProperty $r -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName -and $_.UninstallString -and -not $_.SystemComponent }
}
$prog = $prog | Sort-Object DisplayName -Unique

if (-not $prog) { Write-Aviso "No se encontraron programas."; exit }

# --- Mostrar lista numerada ---
$i = 0
$indice = @{}
$prog | ForEach-Object {
    $i++
    $indice[$i] = $_
    $mb = if ($_.EstimatedSize) { "{0} MB" -f [math]::Round($_.EstimatedSize/1024,0) } else { "-" }
    $nombre = ($_.DisplayName -replace '\s+',' ').Trim()
    if ($nombre.Length -gt 45) { $nombre = $nombre.Substring(0,45) }
    Write-Host ("  {0,3}. {1,-45} {2,-14} {3}" -f $i, $nombre, ($_.DisplayVersion), $mb)
}

Write-Host ""
Write-Host "Escribe los numeros a desinstalar separados por coma (ej: 3,7,12)" -ForegroundColor Cyan
Write-Host "o pulsa Enter para salir sin hacer nada." -ForegroundColor Cyan
$sel = Read-Host "Seleccion"
if ([string]::IsNullOrWhiteSpace($sel)) { Write-Host "Cancelado."; exit }

$elegidos = $sel -split "," | ForEach-Object { $_.Trim() } | Where-Object { $_ -match '^\d+$' } | ForEach-Object { [int]$_ }

# --- Confirmacion final ---
Write-Titulo "VAS A DESINSTALAR:"
foreach ($n in $elegidos) { if ($indice[$n]) { Write-Host "  - $($indice[$n].DisplayName)" -ForegroundColor Yellow } }
$ok = Read-Host "Confirmar desinstalacion? (S/N)"
if ($ok -notin @("S","s")) { Write-Host "Cancelado."; exit }

# --- Desinstalar uno a uno ---
foreach ($n in $elegidos) {
    $app = $indice[$n]
    if (-not $app) { continue }
    Write-Host "`nDesinstalando: $($app.DisplayName)" -ForegroundColor Cyan
    $cmd = $app.UninstallString
    try {
        if ($cmd -match "msiexec") {
            # Instalador MSI: forzamos modo silencioso
            $code = ($cmd -replace '(?i)msiexec(\.exe)?','' -replace '/I','/X').Trim()
            Start-Process "msiexec.exe" -ArgumentList "$code /quiet /norestart" -Wait
            Write-Ok "Desinstalado: $($app.DisplayName)"
        } else {
            # Instalador EXE (Steam, NSIS, Inno...): suele abrir su PROPIA ventana.
            Write-Aviso "Se abrira la ventana del desinstalador. Completala (Finalizar/Cerrar)."
            Write-Host  "         Mientras siga abierta, este script espera aqui (no esta colgado)." -ForegroundColor DarkGray
            $p = Start-Process "cmd.exe" -ArgumentList "/c", $cmd -PassThru
            # Espera hasta 3 min a que el desinstalador termine; si no, sigue sin bloquear
            if (-not $p.WaitForExit(180000)) {
                Write-Aviso "El desinstalador sigue abierto tras 3 min; continuo con el siguiente."
            } else {
                Write-Ok "Desinstalado: $($app.DisplayName)"
            }
        }
    } catch {
        Write-ErrLn "Fallo al desinstalar $($app.DisplayName): $($_.Exception.Message)"
    }
}

Write-Titulo "PROCESO TERMINADO"
Write-Host "`nPulsa una tecla para cerrar..." -ForegroundColor DarkGray
[void][System.Console]::ReadKey($true)
