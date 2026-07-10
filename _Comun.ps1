# =====================================================================
#  _Comun.ps1  -  Funciones compartidas por el resto de scripts
#  No se ejecuta solo; los demas scripts lo cargan con dot-sourcing.
# =====================================================================

# --- Auto-elevacion: relanza el script como Administrador si hace falta ---
function Test-Admin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p  = New-Object Security.Principal.WindowsPrincipal($id)
    return $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Assert-Admin {
    param([string]$ScriptPath)
    if (-not (Test-Admin)) {
        Write-Host "Se necesitan permisos de Administrador. Relanzando (UAC)..." -ForegroundColor Yellow
        $args = "-NoProfile -ExecutionPolicy Bypass -File `"$ScriptPath`""
        Start-Process powershell.exe -ArgumentList $args -Verb RunAs
        exit
    }
}

# --- Utilidades de salida por consola ---
function Write-Titulo { param($t) Write-Host "`n===== $t =====" -ForegroundColor Cyan }
function Write-Ok     { param($t) Write-Host "  [OK] $t"   -ForegroundColor Green }
function Write-Aviso  { param($t) Write-Host "  [!!] $t"   -ForegroundColor Yellow }
function Write-ErrLn  { param($t) Write-Host "  [XX] $t"   -ForegroundColor Red }

# --- Convierte bytes a texto legible ---
function Format-Tamano {
    param([double]$Bytes)
    if ($Bytes -ge 1GB) { return "{0:N2} GB" -f ($Bytes / 1GB) }
    if ($Bytes -ge 1MB) { return "{0:N2} MB" -f ($Bytes / 1MB) }
    if ($Bytes -ge 1KB) { return "{0:N2} KB" -f ($Bytes / 1KB) }
    return "$Bytes B"
}

# --- Suma el tamano de una carpeta de forma segura ---
function Get-TamanoCarpeta {
    param([string]$Ruta)
    if (-not (Test-Path $Ruta)) { return 0 }
    try {
        $suma = (Get-ChildItem -LiteralPath $Ruta -Recurse -Force -ErrorAction SilentlyContinue |
                 Measure-Object -Property Length -Sum).Sum
        if ($null -eq $suma) { return 0 } else { return $suma }
    } catch { return 0 }
}
