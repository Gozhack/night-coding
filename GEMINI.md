# Proyecto Noctámbulo - OpenClaw Setup

## 🚀 Estado Actual (2026-05-30)
Arquitectura híbrida free-tier validada y loop nocturno autónomo cableado. Naru (OpenClaw) corre sobre una key de free tier SIN billing, delega el coding al Gemini CLI (OAuth free tier), y de noche trabaja solo el backlog (`workspace/BACKLOG.md`) commiteando a `master` → deploy automático a GitHub Pages.

### 🤖 Arquitectura de IA (Híbrida — todo gratis)
Dos motores con cuotas gratis **separadas**:
- **Naru (OpenClaw)** = personalidad de gato + canal de Telegram + dispatcher/orquestador. Corre sobre `anthropic/claude-haiku-4-5` (alias `auto`) vía **API de Anthropic** (factura por token — con límite de gasto duro en la consola). Haiku solo **orquesta**: lee el backlog, escribe instrucciones precisas y acotadas para el CLI, valida los diffs y decide commit. El código pesado lo escribe el CLI gratis.
- **Gemini CLI** = coding pesado, sobre el **free tier de OAuth** (login con tu cuenta Google, cuota aparte). Naru lo invoca con la key removida del entorno:
  ```bash
  cd /repo/workspace && env -u GEMINI_API_KEY -u GOOGLE_API_KEY -u GOOGLE_GENAI_USE_VERTEXAI gemini -p "..." --yolo
  ```
  El `env -u` es lo que evita que el CLI use (y gaste) la key de pago — fue el bug original.

#### 🔑 Login OAuth del CLI (una sola vez)
El free tier del CLI requiere login con tu cuenta Google. En la lap headless:
```bash
docker compose exec openclaw-agent gemini   # elige "Login with Google", abre la URL que imprime y pega el código
```
Las credenciales quedan en `./.gemini_cli/` (volumen persistente, en `.gitignore`). Después, las llamadas con `-p ... --yolo` corren sin interacción.

> ⚠️ **Trust del workspace (obligatorio en headless):** el Gemini CLI no corre herramientas en un folder "no confiable" y falla con *"not running in a trusted directory"*. Por eso el `docker-compose.yml` setea `GEMINI_CLI_TRUST_WORKSPACE=true`. **No borres esa env var** o las delegaciones de Naru dejan de funcionar.

- **Optimización de Contexto:**
    - `bootstrapMaxChars`: 10,000 (Aumentado para evitar truncamiento de archivos de configuración).
    - `bootstrapTotalMaxChars`: 30,000.
    - Archivo `.clawignore` configurado en `workspace/` para ignorar archivos binarios y metadatos de Godot (`.godot/`, `.import`, `.tscn`, etc.).

### 📱 Comunicación & Pairing
- **Canal:** Telegram (@NaruDev_bot).
- **Usuario Dueño:** (Configurado vía variable de entorno `TELEGRAM_CHAT_ID`).
- **Contraseña del Gateway:** (Configurada vía variable de entorno `OPENCLAW_PASSWORD`).

### 🛠️ Entorno de Desarrollo
- **Docker:** Contenedor `openclaw_sandbox` corriendo Node.js + OpenClaw Gateway.
- **Workspace:** Mapeado a `./workspace` en el host.
- **Tecnología:** Godot 4.x (.NET) con .NET 8 pre-instalado.
- **Source Control:** Repositorio privado en GitHub ([Gozhack/night-coding](https://github.com/Gozhack/night-coding)). Rama principal: `master`.

## 🧠 Agent Synchronization
- **Backlog:** `workspace/BACKLOG.md` es la fuente de verdad de qué trabajar. Una tarea = un commit = un deploy.
- **Memoria del bot:** Naru persiste su continuidad (`MEMORY.md`, `memory/`, `HEARTBEAT.md`) en el volumen `./.openclaw_workspace/` (no version-controlado). Este `GEMINI.md` es el contexto que el CLI ve en cada invocación.
- **Loop nocturno:** ventana y cadencia en `.openclaw_config/openclaw.json > agents.defaults.heartbeat`. La lógica del ciclo está en `HEARTBEAT.md`.
- **Git Safety:** El bot SÍ puede `commit/push` a night-coding (credenciales preparadas por `container-init.sh`). NUNCA `git init`, `git config --global` desde el agente, ni filtrar el `GITHUB_TOKEN`.

## 📝 Instrucciones para Futuras Sesiones
1. **Verificar Estado:** `docker compose ps` para asegurar que el contenedor está arriba.
2. **Logs del Bot:** `docker compose logs -f openclaw-agent` para monitorear la actividad del bot.
3. **Modelo del cerebro:** `auto` = `anthropic/claude-haiku-4-5` (Claude-Haiku orquestador, vía `ANTHROPIC_API_KEY`). El viejo cerebro flash (`gemini-2.5-flash` free tier) se jubiló por topar 429. El obrero sigue siendo el Gemini CLI (OAuth free tier). Si OpenClaw rechaza el slug, corre `openclaw models list --provider anthropic` para el id exacto.
4. **Backlog:** Editar `workspace/BACKLOG.md` para darle trabajo a Naru. Toma la primera tarea `[ ]`.
5. **Login OAuth del CLI:** si Naru reporta fallo de auth del CLI, rehacer el login (ver sección 🔑).

---
*Nota: Se resolvió el conflicto inicial con OpenAI/Codex eliminando los archivos de configuración de agente redundantes y forzando los modelos de Google en la configuración global.*
