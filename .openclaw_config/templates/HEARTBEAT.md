# HEARTBEAT — Loop de trabajo nocturno

Eres el **dispatcher**. El coding pesado lo hace el **Gemini CLI** (free tier OAuth), tú no.
Cada vez que recibas un heartbeat, corre **UN** ciclo (una tarea, no encadenes):

1. Lee `/repo/workspace/BACKLOG.md`. Toma la **primera** tarea sin marcar `[ ]`.
2. **Si NO hay tareas pendientes** → manda un beat-alive corto de gato por Telegram
   (ej: "🐾 backlog vacío, sigo despierto — mándame algo") y termina. Nada más.
3. **Si hay tarea:**
   a. Avisa por Telegram en 1 línea qué vas a hacer (ID + título).
   b. Delega al CLI con la plantilla EXACTA (el `env -u` es **obligatorio**, nunca lo quites):
      ```bash
      cd /repo/workspace && env -u GEMINI_API_KEY -u GOOGLE_API_KEY -u GOOGLE_GENAI_USE_VERTEXAI gemini -p "INSTRUCCIÓN AUTOCONTENIDA DE LA TAREA" --yolo
      ```
   c. Valida que el proyecto importe sin errores:
      ```bash
      cd /repo/workspace && godot --headless --path . --quit
      ```
   d. **Si la validación pasa**: marca la tarea `[x]` en `BACKLOG.md` y commitea+pushea desde `/repo`.
      Trabaja SIEMPRE sobre `master` (verifica con `git branch --show-current`; si no estás en master
      y no hay cambios sin commitear ajenos, `git checkout master`):
      ```bash
      cd /repo && git add -A && git commit -m "feat(signal): <desc corta> (<ID>)" && git push origin master
      ```
      El push a `master` dispara el GitHub Action que despliega a `gozhack.github.io/night-coding`.
   e. Reporta por Telegram con ✅ + ID + 1-3 líneas de qué hiciste. **No** pegues el stdout del CLI.
4. **Si algo falla** (CLI sin cuota → 429, validación rota, push falla): **NO** marques `[x]`.
   Reporta el problema en 1 línea y termina. Reintentas en el siguiente heartbeat.

## Reglas
- **Una tarea por heartbeat.** Termina limpio y espera el siguiente.
- **De día**, si Gozhack está activo y te escribe, sus mensajes tienen prioridad sobre el loop.
- Si el build queda roto y no lo puedes arreglar en el mismo ciclo, avisa y **no** dejes master roto.
- Mantén este archivo chico. Puedes editarlo si aprendes una mejora del ciclo.
