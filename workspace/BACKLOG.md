# BACKLOG — night-coding

Chappie trabaja este backlog de noche (ver `HEARTBEAT.md`). **Una tarea = un commit = un deploy.**
Toma siempre la **primera** tarea `[ ]` de arriba hacia abajo. Al terminarla y validarla,
márcala `[x]`, commitea con el ID en el mensaje (`feat(signal): ... (SG-01)`) y pushea a `master`.

Convenciones (mira `void-tap/` y `grid-runner/` como referencia):
- Cada juego vive en `workspace/<juego>/` con `scenes/`, `scripts/`, `assets/`.
- GDScript (no C#), inglés en el código. Validar con `godot --headless --path . --quit`.
- Para publicar un juego: export preset en `export_presets.cfg` (nombre = "Signal") apuntando a
  `signal/index.html`, y una card en `web-hub/index.html`. El CD exporta y deploya a gh-pages.

---

## 🎯 Juego activo: Signal (memoria de colores, estilo Simón)
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
  Agrega botón "Back to Menu" y la lógica de redirección como en los otros juegos.

- [ ] **SG-08 — Publicar Signal.**
  Agrega el export preset **"Signal"** en `workspace/export_presets.cfg` apuntando a
  `../build/web/signal/index.html`, y una card de Signal en `web-hub/index.html` (href
  `signal/index.html`). Con esto el CD exporta el juego y aparece en el hub. **Verifica** que el
  nombre del preset sea exactamente `Signal` (el workflow `cd.yml` lo invoca por nombre).

---

## 💤 Ideas / Backlog frío (para cuando Signal esté listo)
- [ ] Pulido void-tap: balancear curva de dificultad.
- [ ] Pulido grid-runner: variedad de hazards.
- [ ] Juego nuevo #4 (a definir con Gozhack).
