# =====================================================================
#  4-Optimizar.ps1
#  Mejoras de rendimiento SEGURAS y reversibles.
#  No deshabilita servicios ni toca telemetria.
# =====================================================================
. "$PSScriptRoot\_Comun.ps1"
Assert-Admin $PSCommandPath

Write-Titulo "OPTIMIZACION DE RENDIMIENTO (modo seguro)"

# --- 1. Plan de energia: Alto rendimiento ---
try {
    $alto = "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c" # GUID estandar Alto rendimiento
    powercfg /setactive $alto 2>$null
    if ($LASTEXITCODE -ne 0) {
        # Si no existe, activamos el plan "Maximo rendimiento" si esta disponible
        powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 | Out-Null
        powercfg /setactive e9a42b02-d5df-448d-aa00-03f14749eb61 2>$null
    }
    Write-Ok "Plan de energia de alto rendimiento activado"
} catch { Write-Aviso "No se pudo cambiar el plan de energia" }

# --- 2. Optimizar/TRIM de discos (equivalente a desfragmentar) ---
Write-Host "  Optimizando discos (TRIM en SSD / desfragmentacion en HDD)..."
Get-Volume | Where-Object { $_.DriveLetter -and $_.FileSystemType -eq "NTFS" } | ForEach-Object {
    try {
        Optimize-Volume -DriveLetter $_.DriveLetter -Verbose:$false -ErrorAction Stop
        Write-Ok "Disco $($_.DriveLetter): optimizado"
    } catch { Write-Aviso "No se pudo optimizar $($_.DriveLetter):" }
}

# --- 3. Activar Sensor de almacenamiento (limpieza automatica) ---
try {
    $sk = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy"
    if (-not (Test-Path $sk)) { New-Item -Path $sk -Force | Out-Null }
    Set-ItemProperty $sk -Name "01" -Value 1 -Type DWord    # activar Storage Sense
    Set-ItemProperty $sk -Name "2048" -Value 1 -Type DWord  # frecuencia
    Write-Ok "Sensor de almacenamiento activado (limpieza automatica)"
} catch { Write-Aviso "No se pudo configurar el Sensor de almacenamiento" }

# --- 4. Vaciar cache DNS ---
ipconfig /flushdns | Out-Null
Write-Ok "Cache DNS vaciada"

# --- 5. Revisar integridad del sistema (solo comprobacion) ---
Write-Host "  Comprobando integridad del sistema (DISM CheckHealth)..."
try {
    Dism.exe /Online /Cleanup-Image /CheckHealth | Out-Null
    Write-Ok "Comprobacion de integridad realizada"
} catch { Write-Aviso "No se pudo ejecutar la comprobacion DISM" }

# --- 6. Mostrar programas de arranque para revision manual ---
Write-Titulo "PROGRAMAS EN EL ARRANQUE (revisa cuales no necesitas)"
Write-Host "  Puedes desactivarlos en: Administrador de tareas > Inicio"
$claves = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
)
foreach ($c in $claves) {
    if (Test-Path $c) {
        (Get-ItemProperty $c).PSObject.Properties |
            Where-Object { $_.Name -notmatch "^PS" } |
            ForEach-Object { Write-Host "    - $($_.Name)" }
    }
}

Write-Titulo "OPTIMIZACION COMPLETADA"
Write-Aviso "Recomendado: reiniciar el equipo para aplicar todos los cambios."
Write-Host "`nPulsa una tecla para cerrar..." -ForegroundColor DarkGray
[void][System.Console]::ReadKey($true)
