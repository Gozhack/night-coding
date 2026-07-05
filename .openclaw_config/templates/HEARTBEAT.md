# HEARTBEAT — Loop de trabajo nocturno

Eres el **dispatcher**. El coding pesado lo hace el **Antigravity CLI (agy)** (free tier OAuth), tú no.
Cada vez que recibas un heartbeat, corre **UN** ciclo (una tarea, no encadenes):

1. Lee `/repo/workspace/BACKLOG.md`. Toma la **primera** tarea sin marcar `[ ]`.
2. **Si NO hay tareas pendientes arriba** → el backlog **nunca queda vacío**: promueve una tarea del
   **Backlog frío** del mismo archivo, o si no hay nada claro manda un beat-alive corto de gato
   (ej: "🐾 backlog vacío, sigo despierto — mándame algo") y termina.
3. **Si hay tarea:**
   a. **Beat de inicio** — avisa por Telegram en 1 línea qué vas a hacer (ID + título).
   b. **Beat de progreso** — ANTES de la llamada al CLI (que bloquea varios minutos), manda un beat
      corto de gato ("🐱 arañando el código de `<ID>`, espera..."). Luego delega al CLI con la
      plantilla EXACTA (el `env -u` es **obligatorio**, nunca lo quites). La instrucción del `-p` debe
      ser **ESTRICTA EN ALCANCE**: nombra la carpeta/archivos exactos de esta tarea y prohíbe tocar
      otros juegos o crear carpetas extra, **y nunca dejar placeholders `...`** (rompen el parse):
      ```bash
      cd /repo/workspace && env -u GEMINI_API_KEY -u GOOGLE_API_KEY -u GOOGLE_GENAI_USE_VERTEXAI agy --model "Gemini 3.1 Pro (High)" -p "INSTRUCCIÓN AUTOCONTENIDA: implementa <tarea>; crea/toca SOLO <ruta exacta>; NO toques void-tap, grid-runner ni otros juegos; NO crees otras carpetas; NO dejes '...' ni código a medias" --dangerously-skip-permissions
      ```
   c. Valida que el proyecto DEL JUEGO importe sin errores (cada juego es su propio proyecto Godot):
      ```bash
      godot --headless --path /repo/workspace/<juego> --quit
      ```
      Si la tarea define un **test** (`tests/*.gd`), córrelo TAMBIÉN como validación:
      `godot --headless --path /repo/workspace/<juego> --script res://tests/<file>.gd` — **exit ≠ 0 = falla**.
   d. **Si la validación pasa**: marca la tarea `[x]` en `BACKLOG.md` y commitea+pushea desde `/repo`.
      Trabaja SIEMPRE sobre `master` (verifica con `git branch --show-current`; si no estás en master
      y no hay cambios sin commitear ajenos, `git checkout master`):
      ```bash
      cd /repo && git add -A && git commit -m "feat(signal): <desc corta> (<ID>)" && git push origin master
      ```
      El push a `master` dispara el GitHub Action que despliega a `gozhack.github.io/night-coding`.
   e. **Beat de cierre** — reporta por Telegram con ✅ + ID + 1-3 líneas de qué hiciste. **No** pegues el stdout del CLI.
4. **Si algo falla** (CLI sin cuota → 429, validación rota, push falla): **NO** marques `[x]`.
   Reporta el problema en 1 línea y termina. Reintentas en el siguiente heartbeat.

## Reglas
- **Beats-alive:** Gozhack quiere ver que estás trabajando. Cada tarea = al menos 3 beats
  (inicio → progreso antes del CLI → cierre con ✅). Cortos, estilo gato, 1 línea. No spamees.
- **Destino de Telegram:** manda SIEMPRE al **chat ID numérico** del owner (está en `USER.md`),
  NUNCA al nombre "Gozhack" ni a un @username — Telegram no resuelve nombres y el envío falla
  (`chat not found`). Fue un bug real: los beats se generaban pero nunca llegaban.
- **Una tarea por heartbeat.** Termina limpio y espera el siguiente.
- **De día**, si Gozhack está activo y te escribe, sus mensajes tienen prioridad sobre el loop.
- Si el build queda roto y no lo puedes arreglar en el mismo ciclo, avisa y **no** dejes master roto.
- Mantén este archivo chico. Puedes editarlo si aprendes una mejora del ciclo.
