# =====================================================================
#  Menu.ps1  -  Lanzador central de todos los scripts de mantenimiento
#  Ejecuta este archivo (clic derecho > Ejecutar con PowerShell)
#  y elige la opcion que quieras.
# =====================================================================
. "$PSScriptRoot\_Comun.ps1"

function Mostrar-Menu {
    Clear-Host
    Write-Host "==============================================" -ForegroundColor Cyan
    Write-Host "   MANTENIMIENTO Y OPTIMIZACION DEL PC" -ForegroundColor Cyan
    Write-Host "   Equipo: $env:COMPUTERNAME   Usuario: $env:USERNAME" -ForegroundColor DarkGray
    Write-Host "==============================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  1. Diagnostico completo (solo lee, no cambia nada)"
    Write-Host "  2. Limpieza de archivos temporales"
    Write-Host "  3. Desinstalar programas (interactivo)"
    Write-Host "  4. Optimizar rendimiento (modo seguro)"
    Write-Host "  5. Dar permisos de Administrador a un usuario"
    Write-Host ""
    Write-Host "  9. TODO EN UNO (1 + 2 + 4)"
    Write-Host "  0. Salir"
    Write-Host ""
}

do {
    Mostrar-Menu
    $op = Read-Host "Elige una opcion"
    switch ($op) {
        "1" { & "$PSScriptRoot\1-Diagnostico.ps1" }
        "2" { & "$PSScriptRoot\2-Limpieza.ps1" }
        "3" { & "$PSScriptRoot\3-Desinstalar.ps1" }
        "4" { & "$PSScriptRoot\4-Optimizar.ps1" }
        "5" { & "$PSScriptRoot\5-Permisos-Admin.ps1" }
        "9" {
            & "$PSScriptRoot\1-Diagnostico.ps1"
            & "$PSScriptRoot\2-Limpieza.ps1"
            & "$PSScriptRoot\4-Optimizar.ps1"
        }
        "0" { break }
        default { Write-Aviso "Opcion no valida"; Start-Sleep 1 }
    }
} while ($op -ne "0")

Write-Host "Hasta luego!" -ForegroundColor Green
