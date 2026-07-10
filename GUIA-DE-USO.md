# Guía de uso — Orden recomendado para ejecutar los scripts

Esta guía explica **en qué orden** ejecutar los scripts y **cada cuánto**,
para sacarle el máximo partido sin riesgos. Todos se lanzan desde
`Menu.ps1` (clic derecho → *Ejecutar con PowerShell*).

---

## Regla de oro

> **Primero diagnostica, luego limpia, después decide, y al final optimiza.**
>
> Nunca empieces borrando o desinstalando a ciegas: mira antes el estado
> real del equipo con el diagnóstico.

---

## Orden recomendado (primera vez)

Sigue estos pasos **en este orden exacto**:

### Paso 1 — Diagnóstico  → opción `1`
- **Qué hace:** revisa todo el PC y genera un informe `.txt` en la carpeta.
- **Por qué primero:** te dice cuánto espacio puedes recuperar, qué
  programas ocupan más, qué arranca con Windows y si algún disco está lleno.
- **Riesgo:** ninguno, solo lee.
- 👉 *Lee el informe antes de continuar.*

### Paso 2 — Limpieza  → opción `2`
- **Qué hace:** borra temporales, cachés, papelera y libera espacio.
- **Por qué aquí:** liberar basura primero hace que el resto vaya más fino
  y evita desinstalar/optimizar sobre archivos que ibas a borrar igualmente.
- **Antes de ejecutar:** cierra los navegadores (Chrome, Edge, Firefox)
  para que se limpie también su caché.

### Paso 3 — Desinstalar programas  → opción `3`
- **Qué hace:** lista lo instalado y **tú eliges** qué quitar.
- **Por qué después de limpiar:** con el informe del Paso 1 delante, ya
  sabes qué programas son grandes o no usas.
- **Consejo:** ve poco a poco. Si dudas de un programa, no lo quites.

### Paso 4 — Optimizar rendimiento  → opción `4`
- **Qué hace:** plan de energía de alto rendimiento, optimiza discos (TRIM),
  activa limpieza automática y refresca la red.
- **Por qué al final:** se aplica sobre un sistema ya limpio y sin lo que
  sobra, así el resultado es mejor.

### Paso 5 — Reiniciar el equipo
- Cierra sesión y reinicia para que **todos** los cambios surtan efecto.

---

## Atajo: "Todo en uno"  → opción `9`

Si tienes prisa y confías en el modo seguro, la opción `9` del menú ejecuta
en cadena **Diagnóstico → Limpieza → Optimizar** (pasos 1, 2 y 4).

> ⚠️ La opción `9` **no** desinstala programas (paso 3), porque eso siempre
> debe ser una decisión manual tuya. Ejecuta la opción `3` aparte cuando
> quieras revisar los programas.

---

## El script de permisos (opción `5`) va aparte

`5-Permisos-Admin.ps1` **no** forma parte de la rutina de mantenimiento.
Es una tarea puntual: solo la ejecutas cuando necesitas convertir a un
usuario en administrador del equipo. No hace falta repetirla.

---

## Cada cuánto ejecutarlos (rutina recomendada)

| Frecuencia | Qué ejecutar | Opción del menú |
|---|---|---|
| **Cada semana** | Limpieza | `2` |
| **Cada mes** | Diagnóstico + Limpieza + Optimizar | `9` |
| **Cada 2–3 meses** | Revisar y desinstalar lo que no uses | `3` |
| **Solo cuando haga falta** | Dar permisos de administrador | `5` |

> Consejo: como la limpieza es lo más frecuente, muchos la programan en el
> *Programador de tareas* de Windows para que se ejecute sola cada semana.

---

## Resumen visual del flujo

```
   ┌─────────────┐
   │ 1. DIAGNOSTICO │  (lee, no cambia nada)
   └──────┬────────┘
          │  lee el informe .txt
          ▼
   ┌─────────────┐
   │ 2. LIMPIEZA    │  (libera espacio)
   └──────┬────────┘
          ▼
   ┌─────────────┐
   │ 3. DESINSTALAR │  (tú eliges qué quitar)
   └──────┬────────┘
          ▼
   ┌─────────────┐
   │ 4. OPTIMIZAR   │  (rendimiento, modo seguro)
   └──────┬────────┘
          ▼
   ┌─────────────┐
   │ 5. REINICIAR   │
   └─────────────┘

   (aparte, solo cuando lo necesites)
   ┌──────────────────────┐
   │ 5-Permisos-Admin.ps1 │  → hacer administrador a un usuario
   └──────────────────────┘
```

---

## Antes de empezar (una sola vez)

Si Windows bloquea la ejecución de scripts, abre PowerShell **como
Administrador** y ejecuta:

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

A partir de ahí ya puedes usar `Menu.ps1` con normalidad.

---

## Consejos finales

- **Haz el diagnóstico siempre primero.** Es gratis y sin riesgo.
- **No desinstales con dudas.** Si no sabes qué es un programa, déjalo.
- **Reinicia tras optimizar** para aplicar los cambios.
- **Guarda los informes `.txt`** que genera el diagnóstico: te sirven para
  comparar el estado del PC de un mes a otro.
