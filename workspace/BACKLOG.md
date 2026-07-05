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
- [x] **FX-05 — Verificar el loop en vivo (ambos).** Tras el deploy, confirmar en el hub:
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

- [x] **SG-03 — Input del jugador.**
  Tras reproducir, el jugador toca los botones. Compara cada tap contra la secuencia esperada.
  Si acierta toda la secuencia → ronda superada. Si falla un color → señal de error.

- [x] **SG-04 — Progresión de dificultad.**
  Al superar la ronda, agrega un color nuevo a la secuencia y repite. Pequeña pausa + feedback
  visual entre rondas. La velocidad de reproducción puede subir levemente con el nivel.

- [x] **SG-05 — Game over + reinicio.**
  Si el jugador falla, muestra pantalla de Game Over con el score (nivel/rondas alcanzadas) y
  opción de reiniciar. Estilo consistente con void-tap/grid-runner.

- [x] **SG-06 — Audio procedural.**
  Un tono distinto por color (mira `void-tap/scripts/AudioManager.gd` como referencia de audio
  procedural). Suena tanto en la reproducción de la secuencia como en los taps del jugador.

- [x] **SG-07 — Récord persistente + back to menu.**
  Guarda el mejor score en `user://` y muestra indicador "new best" al superarlo (como void-tap).
  Agrega botón "Back to Menu" (`PROCESS_MODE_ALWAYS`) y la lógica de redirección como en los otros juegos.

- [x] **SG-08 — Publicar Signal.**
  Agrega una card de Signal en `web-hub/index.html` (href `signal/index.html`). El preset "Web" y el
  `project.godot` ya se crearon en SG-01, así que el **CD lo exporta solo** (auto-descubre
  `workspace/signal/project.godot` — no hay que tocar `cd.yml`). Verifica que el preset se llame
  exactamente **"Web"** y que el `export_path` sea `../../build/web/signal/index.html`.

---

## 🚀 Epic 2 — Lander (estilo Lunar Lander, gráficos vectoriales)
Aterriza una cápsula en una plataforma entre riscos: gravedad constante te jala, controlas el
**thrust** (potencia del motor) y el movimiento lateral. Aterrizar **suave y derecho** = éxito;
muy rápido o muy inclinado = choque. Arte **100% vectorial dibujado por código** (como void-tap:
`_draw()` / `Polygon2D`), **NO** sprites/PNG — el CLI no genera imágenes. Estilo oscuro noctámbulo.

> **🧪 Este epic SÍ lleva tests headless.** La lógica sin pantalla (generación de terreno,
> clasificación de aterrizaje) se valida con scripts en `workspace/lander/tests/` corridos con
> `godot --headless --path workspace/lander --script res://tests/<file>.gd`. El script hace `assert`
> y **debe salir con código ≠ 0 si falla** (`OS.set_exit_code(1)` antes de `quit()`, o `assert` que
> aborte). **NADA de addons externos (GUT)** — scripts autocontenidos. Razón: el CLI codea a ciegas;
> los invariantes verificables sin ver la pantalla se testean, lo demás (feel, estética) lo pruebas tú.

- [x] **LD-01 — Scaffold del proyecto + escena.**
  Crea `workspace/lander/` como **su propio proyecto Godot**: `project.godot` (config/name="Lander",
  `run/main_scene="res://scenes/Main.tscn"`, features 4.3 + gl_compatibility, autoload propio si lo
  necesita) y `export_presets.cfg` con un preset **"Web"** → `../../build/web/lander/index.html`.
  La escena `scenes/Main.tscn` + `scripts/Main.gd`: fondo oscuro, responsive. Sin gameplay aún: solo
  que corra sin errores en `godot --headless --path workspace/lander --quit`. Rutas root-relative
  (`res://scenes/...`, `res://scripts/...`). NO toques void-tap, grid-runner ni signal.

- [x] **LD-02 — Nave vectorial + física básica.**
  La cápsula es un `CharacterBody2D` dibujada en `_draw()`: triángulo relleno (`draw_colored_polygon`)
  + borde (`draw_polyline`), estilo del orbe de void-tap. Gravedad constante hacia abajo; **thrust**
  hacia arriba mientras se mantiene presionado (teclado **y** touch); control lateral izquierda/derecha.
  Integra velocidad manualmente. Una llamita/partícula simple dibujada bajo la nave al acelerar. Sin
  terreno aún (se sale por abajo y reaparece, o límites de pantalla). Solo `scripts/`+`scenes/` de lander.

- [x] **LD-03 — Terreno PROCEDURAL (generación por semilla).**
  Una función `generate_terrain(seed: int)` que produce el **perfil del terreno** a partir de una semilla
  usando `RandomNumberGenerator` con `rng.seed = seed` (NO `randi()` global): riscos irregulares
  **distintos en cada partida**, garantizando **al menos una zona plana** (la plataforma) de ancho mínimo.
  Pura geometría/datos (devuelve los puntos; SIN crear nodos visuales dentro de la función) para que sea
  testeable headless. Dibuja el resultado como polígono/`Line2D` con la plataforma marcada visualmente.
  Sin colisión todavía. Solo lander.

- [x] **LD-04 — Tests del terreno procedural (headless).**
  `tests/test_terrain.gd`: probando varias semillas, afirma que (a) el terreno cubre todo el ancho de la
  pantalla, (b) existe ≥1 plataforma plana del ancho mínimo, (c) todos los puntos caen dentro de límites,
  (d) **misma semilla → mismo terreno** (determinismo) y (e) **semillas distintas → terrenos distintos**.
  Falla = exit ≠ 0. Validar con `godot --headless --path workspace/lander --script res://tests/test_terrain.gd`.

- [ ] **LD-05 — Colisión nave-terreno.**
  Construye la colisión (`StaticBody2D` + `CollisionPolygon2D`) a partir del terreno de LD-03 y haz que la
  nave colisione: choca contra los riscos y se posa sobre la plataforma. Solo lander.

- [ ] **LD-06 — Clasificación aterrizaje vs choque (lógica pura).**
  Función pura `classify_landing(speed, angle, on_pad) -> int` (enum SUCCESS/CRASH) con umbrales claros de
  velocidad e inclinación. Conéctala al contacto: en la plataforma y bajo umbral = éxito; demasiado rápido,
  muy inclinado, o sobre riscos = choque. Feedback visual claro de cada caso.

- [ ] **LD-07 — Tests de la clasificación de aterrizaje (headless).**
  `tests/test_landing.gd`: afirma SUCCESS/CRASH en valores límite — justo bajo y justo sobre el umbral de
  velocidad y de ángulo, dentro y fuera de la plataforma. Falla = exit ≠ 0. Validar con
  `godot --headless --path workspace/lander --script res://tests/test_landing.gd`.

- [ ] **LD-08 — Combustible + HUD.**
  El thrust consume combustible (barra/lectura en pantalla). Muestra velocidad vertical y combustible
  restante. Sin combustible = no hay thrust. HUD legible, responsive, estilo consistente con los otros.

- [ ] **LD-09 — Variedad y dificultad por nivel.**
  Cada aterrizaje exitoso **regenera el terreno** (nueva semilla, vía LD-03) y sube la dificultad de forma
  legible: plataforma más angosta y/o terreno más escarpado y/o menos combustible inicial. Muestra el nivel
  actual. (Esto es lo que pidió Gozhack: que no sean siempre los mismos riscos.)

- [ ] **LD-10 — Game over / victoria + reinicio.**
  Pantalla de éxito (score: combustible restante + bonus por aterrizaje suave + nivel alcanzado) y de choque,
  ambas con opción de reiniciar. Estilo consistente con void-tap/grid-runner/signal.

- [ ] **LD-11 — Audio procedural.**
  Rumor del motor mientras se acelera + sfx de aterrizaje y de choque (mira `void-tap/scripts/AudioManager.gd`
  como referencia — nada de samples externos).

- [ ] **LD-12 — Récord persistente + back to menu.**
  Guarda el mejor score en `user://` con indicador "new best" al superarlo (como void-tap). Agrega botón
  "Back to Menu" (`PROCESS_MODE_ALWAYS`) y la redirección al hub como en los otros juegos.

- [ ] **LD-13 — Publicar Lander.**
  Agrega una card de Lander en `web-hub/index.html` (href `lander/index.html`). El preset "Web" y el
  `project.godot` ya se crearon en LD-01, así que el **CD lo exporta solo** (auto-descubre
  `workspace/lander/project.godot` — no hay que tocar `cd.yml`). Verifica que el preset se llame
  exactamente **"Web"** y que el `export_path` sea `../../build/web/lander/index.html`.

---

## 💤 Backlog frío (pulido — promover cuando Epic 2 esté listo)
- [ ] Pulido void-tap: balancear curva de dificultad.
- [ ] Pulido grid-runner: variedad de hazards + una condición de meta/objetivo (hoy es endless; la card dice "reach the goal").
- [ ] Hub: actualizar el footer de `web-hub/index.html` (dice "Gemini 2.0/3.0").
- [x] ~~Juego nuevo #4~~ → **definido: Epic 2 — Lander** (arriba).
