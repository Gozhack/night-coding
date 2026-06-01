# BACKLOG — night-coding

Naru trabaja este backlog de noche (ver `HEARTBEAT.md`). **Una tarea = un commit = un deploy.**
Toma siempre la **primera** tarea `[ ]` de arriba hacia abajo. Al terminarla y validarla,
márcala `[x]`, commitea con el ID en el mensaje (p.ej. `feat(signal): ... (SG-01)`) y pushea a `master`.

> 🔴 **Regla: el backlog NUNCA queda vacío.** Si terminas todo lo de arriba, baja al **Backlog frío**
> y promueve una tarea, o manda un beat-alive pidiéndole trabajo a Gozhack. Nunca te quedes sin TODO.

Convenciones (mira `void-tap/` y `grid-runner/` como referencia):
- **Cada juego es su PROPIO proyecto Godot** en `workspace/<juego>/`: su `project.godot` (con
  `run/main_scene` y sus autoloads), `scenes/`, `scripts/`, `assets/` y `export_presets.cfg`.
  Rutas internas root-relative (`res://scenes/...`, `res://scripts/...`), **NO** `res://<juego>/...`.
  (Un solo proyecto con varios juegos rompe: todos los exports bootean el mismo `main_scene`.)
- GDScript (no C#), inglés en el código. Validar con `godot --headless --path workspace/<juego> --quit`.
- **Jugable en móvil:** todo juego debe responder a **touch** (no solo teclado).
- **Nunca dejes placeholders** tipo `...` en el código — rompen el parse (pasó en void-tap).
- Para publicar: en el `export_presets.cfg` del juego un preset llamado **"Web"** apuntando a
  `../../build/web/<juego>/index.html`, y una card en `web-hub/index.html`. El CD **auto-descubre**
  cada `workspace/<juego>/project.godot`, exporta el preset "Web" y deploya todo al **mismo hub**.

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

- [x] **SG-01 — Scaffold del proyecto + escena.**
  Crea `workspace/signal/` como **su propio proyecto Godot**: `project.godot` (config/name="Signal",
  `run/main_scene="res://scenes/Main.tscn"`, features 4.3 + gl_compatibility, autoload propio si lo
  necesita) y `export_presets.cfg` con un preset **"Web"** → `../../build/web/signal/index.html`.
  La escena `scenes/Main.tscn` + `scripts/Main.gd`: grilla 2x2 con 4 botones de color (rojo, verde,
  azul, amarillo), centrada y responsive, fondo oscuro estilo "noctámbulo". Sin gameplay aún: solo
  que corra sin errores en `godot --headless --path workspace/signal --quit`. Rutas root-relative.

- [x] **SG-02 — Reproducir la secuencia.**
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
  Agrega una card de Signal en `web-hub/index.html` (href `signal/index.html`). El preset "Web" y el
  `project.godot` ya se crearon en SG-01, así que el **CD lo exporta solo** (auto-descubre
  `workspace/signal/project.godot` — no hay que tocar `cd.yml`). Verifica que el preset se llame
  exactamente **"Web"** y que el `export_path` sea `../../build/web/signal/index.html`.

---

## 💤 Backlog frío (pulido — promover cuando Epic 1 esté listo)
- [ ] Pulido void-tap: balancear curva de dificultad.
- [ ] Pulido grid-runner: variedad de hazards + una condición de meta/objetivo (hoy es endless; la card dice "reach the goal").
- [ ] Hub: actualizar el footer de `web-hub/index.html` (dice "Gemini 2.0/3.0").
- [ ] Juego nuevo #4 (a definir con Gozhack).
