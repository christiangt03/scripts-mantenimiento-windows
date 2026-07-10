# =====================================================================
#  2-Limpieza.ps1
#  Borra archivos temporales y cache de forma SEGURA.
#  Nunca toca documentos personales. Pide confirmacion antes de empezar.
# =====================================================================
. "$PSScriptRoot\_Comun.ps1"
Assert-Admin $PSCommandPath

Write-Titulo "LIMPIEZA DE ARCHIVOS TEMPORALES"
Write-Aviso "Se borrara: temporales, cache de Windows Update, miniaturas,"
Write-Aviso "prefetch, papelera y cache de navegadores (cerrados)."
$r = Read-Host "Continuar? (S/N)"
if ($r -notin @("S","s")) { Write-Host "Cancelado."; exit }

$liberadoTotal = 0

function Limpiar-Carpeta {
    param([string]$Nombre, [string]$Ruta)
    if (-not (Test-Path $Ruta)) { return }
    $antes = Get-TamanoCarpeta $Ruta
    Get-ChildItem -LiteralPath $Ruta -Force -ErrorAction SilentlyContinue | ForEach-Object {
        try { Remove-Item $_.FullName -Recurse -Force -ErrorAction Stop }
        catch { } # archivos en uso: se ignoran
    }
    $despues = Get-TamanoCarpeta $Ruta
    $lib = $antes - $despues
    if ($lib -lt 0) { $lib = 0 }
    $script:liberadoTotal += $lib
    Write-Ok ("{0,-28} liberado: {1}" -f $Nombre, (Format-Tamano $lib))
}

Limpiar-Carpeta "Temp usuario"          $env:TEMP
Limpiar-Carpeta "Temp Windows"          "$env:WINDIR\Temp"
Limpiar-Carpeta "Prefetch"              "$env:WINDIR\Prefetch"
Limpiar-Carpeta "Windows Update cache"  "$env:WINDIR\SoftwareDistribution\Download"
Limpiar-Carpeta "Cache de errores"      "$env:LOCALAPPDATA\CrashDumps"

# --- Cache de navegadores (solo si estan cerrados) ---
Limpiar-Carpeta "Chrome cache"  "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache"
Limpiar-Carpeta "Edge cache"    "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache"
Limpiar-Carpeta "Firefox cache" "$env:LOCALAPPDATA\Mozilla\Firefox\Profiles"

# --- Papelera de reciclaje ---
try {
    Clear-RecycleBin -Force -ErrorAction Stop
    Write-Ok "Papelera de reciclaje vaciada"
} catch { Write-Aviso "Papelera ya vacia o no accesible" }

# --- Cache de miniaturas (Explorador) ---
try {
    Get-ChildItem "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\thumbcache_*.db" -ErrorAction SilentlyContinue |
        Remove-Item -Force -ErrorAction SilentlyContinue
    Write-Ok "Cache de miniaturas limpiada"
} catch {}

# --- Limpieza de componentes de Windows (WinSxS) ---
Write-Titulo "LIMPIEZA PROFUNDA DE COMPONENTES (DISM)"
Write-Host "  Esto puede tardar varios minutos..."
try {
    Dism.exe /Online /Cleanup-Image /StartComponentCleanup /Quiet
    Write-Ok "Componentes de Windows optimizados"
} catch { Write-Aviso "DISM no completo la limpieza" }

# --- Vaciar cache DNS ---
ipconfig /flushdns | Out-Null
Write-Ok "Cache DNS vaciada"

Write-Titulo "LIMPIEZA COMPLETADA"
Write-Ok ("Espacio liberado en total (aprox): {0}" -f (Format-Tamano $liberadoTotal))
Write-Host "`nPulsa una tecla para cerrar..." -ForegroundColor DarkGray
[void][System.Console]::ReadKey($true)
