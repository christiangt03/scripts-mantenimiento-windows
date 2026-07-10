# =====================================================================
#  1-Diagnostico.ps1
#  Revisa el PC a fondo y genera un INFORME (no modifica nada).
#  Solo lectura: seguro de ejecutar siempre.
# =====================================================================
. "$PSScriptRoot\_Comun.ps1"

$reporte = Join-Path $PSScriptRoot ("Informe_Diagnostico_{0}.txt" -f (Get-Date -Format "yyyy-MM-dd_HHmm"))
Start-Transcript -Path $reporte -Append | Out-Null

Write-Titulo "DIAGNOSTICO DEL SISTEMA - $(Get-Date)"

# ---------- Info general ----------
$os  = Get-CimInstance Win32_OperatingSystem
$cs  = Get-CimInstance Win32_ComputerSystem
$cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
Write-Host "Equipo   : $($cs.Name)"
Write-Host "Windows  : $($os.Caption) $($os.Version)"
Write-Host "CPU      : $($cpu.Name.Trim())"
Write-Host "RAM total: $(Format-Tamano $cs.TotalPhysicalMemory)"
$ramLibre = $os.FreePhysicalMemory * 1KB
Write-Host "RAM libre: $(Format-Tamano $ramLibre)"
$up = (Get-Date) - $os.LastBootUpTime
Write-Host "Encendido desde hace: $([int]$up.TotalHours) h"

# ---------- Discos ----------
Write-Titulo "DISCOS"
Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" | ForEach-Object {
    $libre = $_.FreeSpace; $total = $_.Size
    $pct = if ($total) { [math]::Round(($libre/$total)*100,1) } else { 0 }
    $estado = if ($pct -lt 10) { "  <-- POCO ESPACIO" } else { "" }
    Write-Host ("  {0}  Libre: {1,-10} / {2,-10} ({3}% libre){4}" -f `
        $_.DeviceID, (Format-Tamano $libre), (Format-Tamano $total), $pct, $estado)
}

# ---------- Estimacion de basura limpiable ----------
Write-Titulo "ESPACIO RECUPERABLE (estimado)"
$objetivos = @{
    "Temp usuario"        = $env:TEMP
    "Temp Windows"        = "$env:WINDIR\Temp"
    "Prefetch"            = "$env:WINDIR\Prefetch"
    "Windows Update cache"= "$env:WINDIR\SoftwareDistribution\Download"
    "Cache miniaturas"    = "$env:LOCALAPPDATA\Microsoft\Windows\Explorer"
}
$totalBasura = 0
foreach ($k in $objetivos.Keys) {
    $t = Get-TamanoCarpeta $objetivos[$k]
    $totalBasura += $t
    Write-Host ("  {0,-24}: {1}" -f $k, (Format-Tamano $t))
}
try {
    $papelera = (New-Object -ComObject Shell.Application).Namespace(0xA).Items() |
        Measure-Object -Property Size -Sum
    if ($papelera.Sum) { $totalBasura += $papelera.Sum }
    Write-Host ("  {0,-24}: {1}" -f "Papelera de reciclaje", (Format-Tamano $papelera.Sum))
} catch {}
Write-Ok ("Total aproximado recuperable: {0}" -f (Format-Tamano $totalBasura))

# ---------- Programas de inicio ----------
Write-Titulo "PROGRAMAS EN EL ARRANQUE"
$claves = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
)
foreach ($c in $claves) {
    if (Test-Path $c) {
        (Get-ItemProperty $c).PSObject.Properties |
            Where-Object { $_.Name -notmatch "^PS" } |
            ForEach-Object { Write-Host "  - $($_.Name)" }
    }
}

# ---------- Procesos que mas consumen ----------
Write-Titulo "TOP 10 PROCESOS POR MEMORIA"
Get-Process | Sort-Object WorkingSet64 -Descending | Select-Object -First 10 |
    ForEach-Object { Write-Host ("  {0,-30} {1}" -f $_.ProcessName, (Format-Tamano $_.WorkingSet64)) }

# ---------- Programas instalados y su tamano ----------
Write-Titulo "PROGRAMAS INSTALADOS (top 20 por tamano)"
$rutasUninst = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
)
$prog = foreach ($r in $rutasUninst) {
    Get-ItemProperty $r -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName } |
        Select-Object DisplayName, DisplayVersion,
            @{N="MB";E={ if ($_.EstimatedSize) { [math]::Round($_.EstimatedSize/1024,1) } else { 0 } }},
            @{N="Instalado";E={ $_.InstallDate }}
}
$prog | Sort-Object MB -Descending | Select-Object -First 20 |
    Format-Table DisplayName, DisplayVersion, @{N="Tamano(MB)";E={$_.MB}}, Instalado -AutoSize | Out-Host
Write-Host ("  Total de programas detectados: {0}" -f ($prog | Sort-Object DisplayName -Unique).Count)

# ---------- Salud del disco (SMART) ----------
Write-Titulo "SALUD DE DISCOS FISICOS"
try {
    Get-PhysicalDisk | ForEach-Object {
        Write-Host ("  {0,-30} Estado: {1}" -f $_.FriendlyName, $_.HealthStatus)
    }
} catch { Write-Aviso "No se pudo leer el estado SMART." }

Write-Titulo "FIN DEL DIAGNOSTICO"
Write-Ok "Informe guardado en: $reporte"
Stop-Transcript | Out-Null
Write-Host "`nPulsa una tecla para cerrar..." -ForegroundColor DarkGray
[void][System.Console]::ReadKey($true)
