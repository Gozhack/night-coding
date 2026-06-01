# BACKLOG — night-coding

Naru trabaja este backlog de noche (ver `HEARTBEAT.md`). **Una tarea = un commit = un deploy.**
Toma siempre la **primera** tarea `[ ]` de arriba hacia abajo. Al terminarla y validarla,
márcala `[x]`, commitea con el ID en el mensaje (p.ej. `feat(signal): ... (SG-01)`) y pushea a `master`.

> 🔴 **Regla: el backlog NUNCA queda vacío.** Si terminas todo lo de arriba, baja al **Backlog frío**
> y promueve una tarea, o manda un beat-alive pidiéndole trabajo a Gozhack. Nunca te quedes sin TODO.

Convenciones (mira `void-tap/` y `grid-runner/` como referencia):
- Cada juego vive en `workspace/<juego>/` con `scenes/`, `scripts/`, `assets/`.
- GDScript (no C#), inglés en el código. Validar con `godot --headless --path . --quit`.
- **Jugable en móvil:** todo juego debe responder a **touch** (no solo teclado).
- **Nunca dejes placeholders** tipo `...` en el código — rompen el parse (pasó en void-tap).
- Para publicar un juego: export preset en `export_presets.cfg` (nombre exacto) apuntando a
  `../build/web/<juego>/index.html`, y una card en `web-hub/index.html`. El CD exporta y deploya a gh-pages.

---

## ✅ Epic 0 — Estabilización (juegos funcionales)
Los dos juegos estaban "rotos" (no se pasaba de la pantalla de start). Causas y fixes:

- [x] **FX-01 — grid-runner: desatascar el start.** El botón "START RUN" se creaba sin
  `process_mode = ALWAYS` con el árbol pausado → no emitía `pressed`. Arreglado + botón "← Menu" persistente.
- [x] **FX-02 — grid-runner: input touch/swipe.** Solo leía flechas de teclado → injugable en móvil.
  Agregado swipe (touch + mouse) manteniendo el teclado.
- [x] **FX-03 — grid-runner: limpiar `Main.tscn`.** Quitada la UI huérfana (`Msg`/`MenuButton`) que no usaba el script.
- [x] **FX-04 — void-tap: quitar placeholders rotos.** Había `...` literales en `Main.gd` y `Player.gd`
  (dejados por el CLI) que rompían el parse → `_on_play_pressed` no existía → Play no hacía nada.
- [ ] **FX-05 — Verificar el loop en vivo (ambos).** Tras el deploy, confirmar en el hub:
  menú → Start → mover (teclado **y** touch) → choque → game over → restart → "← Menu" regresa al hub.

---

## 🎯 Epic 1 — Signal (memoria de colores, estilo Simón)
Juego: aparece una secuencia de colores que se ilumina; el jugador la repite tocando.
Cada ronda agrega un color. Falla = game over. Objetivo: llegar lo más lejos posible.

- [ ] **SG-01 — Scaffold de la escena.**
  Crea `workspace/signal/scenes/Main.tscn` y `workspace/signal/scripts/Main.gd`. Una grilla 2x2
  con 4 botones de color (rojo, verde, azul, amarillo), centrada y responsive. Sin gameplay aún:
  solo que la escena corra sin errores en `godot --headless --path . --quit`. Layout limpio y
  fondo oscuro acorde al estilo "noctámbulo" de los otros juegos.

- [ ] **SG-02 — Reproducir la secuencia.**
  Genera una secuencia de colores (empieza con largo 1) y reprodúcela iluminando cada botón por
  turno (highlight + apagado, con timing legible). Estado de juego claro (IDLE / PLAYING_SEQUENCE).

- [ ] **SG-03 — Input del jugador.**
  Tras reproducir, el jugador toca los botones. Compara cada tap contra la secuencia esperada.
  Si acierta toda la secuencia → ronda superada. Si falla un color → señal de error.

- [ ] **SG-04 — Progresión de dificultad.**
  Al superar la ronda, agrega un color nuevo a la secuencia y repite. Pequeña pausa + feedback
  visual entre rondas. La velocidad de reproducción puede subir levemente con el nivel.

- [ ] **SG-05 — Game over + reinicio.**
  Si el jugador falla, muestra pantalla de Game Over con el score (nivel/rondas alcanzadas) y
  opción de reiniciar. Estilo consistente con void-tap/grid-runner.

- [ ] **SG-06 — Audio procedural.**
  Un tono distinto por color (mira `void-tap/scripts/AudioManager.gd` como referencia de audio
  procedural). Suena tanto en la reproducción de la secuencia como en los taps del jugador.

- [ ] **SG-07 — Récord persistente + back to menu.**
  Guarda el mejor score en `user://` y muestra indicador "new best" al superarlo (como void-tap).
  Agrega botón "Back to Menu" (`PROCESS_MODE_ALWAYS`) y la lógica de redirección como en los otros juegos.

- [ ] **SG-08 — Publicar Signal.**
  Agrega el export preset **"Signal"** en `workspace/export_presets.cfg` apuntando a
  `../build/web/signal/index.html`, y una card de Signal en `web-hub/index.html` (href
  `signal/index.html`). Agrega `godot --headless ... --export-release "Signal" ...` en `cd.yml`.
  **Verifica** que el nombre del preset sea exactamente `Signal`.

---

## 💤 Backlog frío (pulido — promover cuando Epic 1 esté listo)
- [ ] Pulido void-tap: balancear curva de dificultad.
- [ ] Pulido grid-runner: variedad de hazards + una condición de meta/objetivo (hoy es endless; la card dice "reach the goal").
- [ ] Hub: actualizar el footer de `web-hub/index.html` (dice "Gemini 2.0/3.0").
- [ ] Juego nuevo #4 (a definir con Gozhack).
