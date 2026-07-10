# =====================================================================
#  5-Permisos-Admin.ps1
#  Convierte a un usuario local en ADMINISTRADOR de este equipo.
#  Uso legitimo: administrar tu propio PC. Requiere UAC (admin).
#
#  NOTA sobre "varios equipos": mas abajo, en la seccion comentada
#  ADMIN EN VARIOS EQUIPOS, tienes la plantilla lista para cuando
#  quieras aplicarlo por red (grupo de trabajo o dominio).
# =====================================================================
. "$PSScriptRoot\_Comun.ps1"
Assert-Admin $PSCommandPath

Write-Titulo "ASIGNAR PERMISOS DE ADMINISTRADOR"

# --- Elegir usuario ---
Write-Host "Usuarios locales disponibles:"
Get-LocalUser | Where-Object { $_.Enabled } | ForEach-Object { Write-Host "  - $($_.Name)" }
$actual = $env:USERNAME
Write-Host ""
$usuario = Read-Host "Nombre del usuario a hacer administrador (Enter = $actual)"
if ([string]::IsNullOrWhiteSpace($usuario)) { $usuario = $actual }

# --- Verificar que existe ---
try { $u = Get-LocalUser -Name $usuario -ErrorAction Stop }
catch { Write-ErrLn "El usuario '$usuario' no existe en este equipo."; exit }

# --- El grupo Administradores puede tener nombre local distinto (idioma) ---
$grupoAdmin = (Get-LocalGroup | Where-Object {
    $_.SID -eq "S-1-5-32-544"          # SID universal del grupo Administrators
}).Name

# --- Anadir al grupo ---
try {
    $yaEsta = Get-LocalGroupMember -Group $grupoAdmin -ErrorAction SilentlyContinue |
              Where-Object { $_.Name -like "*\$usuario" -or $_.Name -eq $usuario }
    if ($yaEsta) {
        Write-Ok "'$usuario' YA es administrador de este equipo."
    } else {
        Add-LocalGroupMember -Group $grupoAdmin -Member $usuario -ErrorAction Stop
        Write-Ok "'$usuario' ahora es ADMINISTRADOR de '$env:COMPUTERNAME'."
    }
} catch {
    Write-ErrLn "No se pudo anadir al grupo: $($_.Exception.Message)"
    exit
}

# --- (Opcional) Cuenta sin caducidad de contrasena para admin fijo ---
$fija = Read-Host "Marcar la contrasena como que nunca caduca? (S/N)"
if ($fija -in @("S","s")) {
    try {
        Set-LocalUser -Name $usuario -PasswordNeverExpires $true
        Write-Ok "Contrasena configurada para no caducar."
    } catch { Write-Aviso "No se pudo cambiar la caducidad de contrasena." }
}

Write-Titulo "LISTO"
Write-Host "Miembros actuales del grupo '$grupoAdmin':"
Get-LocalGroupMember -Group $grupoAdmin | ForEach-Object { Write-Host "  - $($_.Name)" }
Write-Aviso "Cierra sesion y vuelve a entrar para que los permisos surtan efecto."


# =====================================================================
#  ADMIN EN VARIOS EQUIPOS  (plantilla - actualmente DESACTIVADA)
#  ---------------------------------------------------------------
#  Cuando tengas mas equipos en la misma red, elige UNA opcion:
#
#  OPCION A) GRUPO DE TRABAJO (sin dominio)
#  ----------------------------------------
#  1. En CADA equipo remoto, habilita WinRM una sola vez (como admin):
#         Enable-PSRemoting -Force
#  2. En este equipo, define la lista y ejecuta:
#
#     $equipos  = @("PC-SALON","PC-OFICINA","PC-PORTATIL")
#     $usuario  = "chris"
#     $cred     = Get-Credential   # admin valido en los equipos remotos
#     foreach ($eq in $equipos) {
#         Invoke-Command -ComputerName $eq -Credential $cred -ScriptBlock {
#             param($u)
#             $g = (Get-LocalGroup | Where-Object { $_.SID -eq "S-1-5-32-544" }).Name
#             Add-LocalGroupMember -Group $g -Member $u -ErrorAction SilentlyContinue
#         } -ArgumentList $usuario
#     }
#
#  OPCION B) DOMINIO ACTIVE DIRECTORY
#  ----------------------------------
#  Lo habitual es una GPO de "Grupos restringidos" o "Preferencias
#  de GPO > Usuarios y grupos locales" que anada tu usuario del
#  dominio (DOMINIO\usuario) al grupo Administradores de los equipos.
#  Alternativa por script (requiere RSAT y permisos de dominio):
#
#     $equipos = Get-ADComputer -Filter * | Select-Object -Expand Name
#     foreach ($eq in $equipos) {
#         Invoke-Command -ComputerName $eq -ScriptBlock {
#             param($u)
#             $g = (Get-LocalGroup | Where-Object { $_.SID -eq "S-1-5-32-544" }).Name
#             Add-LocalGroupMember -Group $g -Member $u -ErrorAction SilentlyContinue
#         } -ArgumentList "DOMINIO\chris"
#     }
#
#  Nota: pertenecer al grupo Administradores ya concede lectura,
#  escritura e instalacion de programas en ese equipo. No hace falta
#  tocar permisos NTFS carpeta por carpeta.
# =====================================================================

Write-Host "`nPulsa una tecla para cerrar..." -ForegroundColor DarkGray
[void][System.Console]::ReadKey($true)
