# Proyecto Noctámbulo - OpenClaw Setup

## 🚀 Estado Actual (2026-05-26)
El entorno de desarrollo está completamente configurado y operativo. El agente OpenClaw (Clawbot) está conectado vía Telegram y optimizado para trabajar con el motor Godot.

### 🤖 Arquitectura de IA (Híbrida — todo gratis)
Dos motores con cuotas gratis **separadas**:
- **Chappie (OpenClaw)** = personalidad de gato + canal de Telegram + dispatcher. Corre sobre `google/gemini-2.5-flash` (alias `auto`) con una **API key de free tier SIN billing**. Sin fallback a Pro (se quitó: era caro). Si topa rate limit → 429, nunca cobra.
- **Gemini CLI** = coding pesado, sobre el **free tier de OAuth** (login con tu cuenta Google, cuota aparte). Chappie lo invoca con la key removida del entorno:
  ```bash
  cd /workspace && env -u GEMINI_API_KEY -u GOOGLE_API_KEY gemini -p "..." --yolo
  ```
  El `env -u` es lo que evita que el CLI use (y gaste) la key de pago — fue el bug original.

#### 🔑 Login OAuth del CLI (una sola vez)
El free tier del CLI requiere login con tu cuenta Google. En la lap headless:
```bash
docker compose exec openclaw-agent gemini   # elige "Login with Google", abre la URL que imprime y pega el código
```
Las credenciales quedan en `./.gemini_cli/` (volumen persistente, en `.gitignore`). Después, las llamadas con `-p ... --yolo` corren sin interacción.

> ⚠️ **Trust del workspace (obligatorio en headless):** el Gemini CLI no corre herramientas en un folder "no confiable" y falla con *"not running in a trusted directory"*. Por eso el `docker-compose.yml` setea `GEMINI_CLI_TRUST_WORKSPACE=true`. **No borres esa env var** o las delegaciones de Chappie dejan de funcionar.

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
- **Shared Memory:** This project uses `/home/gozhack/.gemini/tmp/night-coding/memory/MEMORY.md` as the source of truth for all agents (Gemini CLI, OpenClaw/Clawbot).
- **Update Rule:** Every time a major technical shift occurs (e.g., migration, new feature, regression fix), the active agent must update `MEMORY.md`.
- **Bot Instructions:** If OpenClaw seems out of context, ask it to "Read MEMORY.md and GEMINI.md" to catch up.
- **Git Safety:** NEVER run `git init` or modify global git credentials. The repository structure and authentication are managed by the user/Gemini CLI only.

## 📝 Instrucciones para Futuras Sesiones
1. **Verificar Estado:** `docker compose ps` para asegurar que el contenedor está arriba.
2. **Logs del Bot:** `docker compose logs -f openclaw-agent` para monitorear la actividad del bot.
3. **Cambio de Modelo:** Se puede usar `/model <alias>` en Telegram para alternar entre `auto` (Flash) y `gemini` (Pro).
4. **Actualización de Ignorados:** Si se añaden nuevos tipos de archivos pesados, actualizar `workspace/.clawignore`.

---
*Nota: Se resolvió el conflicto inicial con OpenAI/Codex eliminando los archivos de configuración de agente redundantes y forzando los modelos de Google en la configuración global.*
