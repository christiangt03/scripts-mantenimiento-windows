# Scripts de Mantenimiento y Optimización de PC (Windows 11)

Conjunto de scripts en PowerShell para revisar, limpiar, optimizar y
administrar tu equipo. Todo comentado en español y pensado para ser
**seguro** (nada irreversible sin confirmación).

## Archivos

| Script | Qué hace | Modifica el sistema |
|--------|----------|:---:|
| `Menu.ps1` | Menú central para lanzar todo | — |
| `1-Diagnostico.ps1` | Informe a fondo del PC (discos, RAM, programas, arranque, basura recuperable, salud de disco). Genera un `.txt` | No (solo lee) |
| `2-Limpieza.ps1` | Borra temporales, caché de Windows Update, miniaturas, papelera, caché de navegadores, DISM | Sí |
| `3-Desinstalar.ps1` | Lista los programas instalados y **eliges** cuáles quitar | Sí (con confirmación) |
| `4-Optimizar.ps1` | Plan de energía alto rendimiento, TRIM/optimizar discos, Storage Sense, flush DNS | Sí (reversible) |
| `5-Permisos-Admin.ps1` | Hace administrador a un usuario local de este PC | Sí |
| `_Comun.ps1` | Funciones compartidas (no se ejecuta solo) | — |

## Cómo se usan

1. Abre la carpeta donde hayas descargado/clonado este repositorio.
2. Clic derecho en **`Menu.ps1`** → **Ejecutar con PowerShell**.
3. Elige la opción del menú.

Los scripts que modifican el sistema piden permisos de Administrador
automáticamente (aparecerá el aviso de UAC).

### Si Windows bloquea la ejecución

Abre PowerShell **como Administrador** una vez y ejecuta:

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

O bien lanza cualquier script directamente sin cambiar la política:

```powershell
powershell -ExecutionPolicy Bypass -File "C:\ruta\donde\este\el\repo\Menu.ps1"
```

## Orden recomendado la primera vez

1. **1-Diagnostico** → mira qué hay que mejorar y cuánto espacio puedes recuperar.
2. **2-Limpieza** → libera espacio.
3. **3-Desinstalar** → quita lo que ya no uses.
4. **4-Optimizar** → mejora rendimiento.
5. Reinicia el equipo.

## Permisos en varios equipos

El script `5-Permisos-Admin.ps1` actúa sobre **este PC**. Al final del
archivo hay una **plantilla comentada** (Opción A: grupo de trabajo /
Opción B: dominio) lista para aplicar los permisos por red cuando
tengas más equipos. Ser miembro del grupo *Administradores* ya da
lectura, escritura e instalación de programas en ese equipo.

## Notas de seguridad

- La limpieza **nunca** toca documentos personales, solo carpetas de temporales y caché.
- La desinstalación es interactiva: nada se quita sin que lo elijas y confirmes.
- La optimización usa solo ajustes seguros y reversibles (no deshabilita servicios ni telemetría).
- El diagnóstico es de solo lectura: puedes ejecutarlo siempre sin riesgo.
