# Proyecto Noctámbulo - OpenClaw Setup

## 🚀 Estado Actual (2026-05-26)
El entorno de desarrollo está completamente configurado y operativo. El agente OpenClaw (Clawbot) está conectado vía Telegram y optimizado para trabajar con el motor Godot.

### 🤖 Configuración de IA (Gemini)
- **Modelo Principal:** `google/gemini-2.5-flash` (Alias: `auto`). Elegido por su alta velocidad y límites de cuota amplios.
- **Modelo de Respaldo (Fallback):** `google/gemini-3.1-pro-preview` (Alias: `gemini`). Se activa automáticamente si Flash falla o para tareas complejas.
- **Optimización de Contexto:**
    - `bootstrapMaxChars`: 1,000 (Reducido para evitar consumo excesivo de tokens).
    - `bootstrapTotalMaxChars`: 5,000.
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

## 📝 Instrucciones para Futuras Sesiones
1. **Verificar Estado:** `docker compose ps` para asegurar que el contenedor está arriba.
2. **Logs del Bot:** `docker compose logs -f openclaw-agent` para monitorear la actividad del bot.
3. **Cambio de Modelo:** Se puede usar `/model <alias>` en Telegram para alternar entre `auto` (Flash) y `gemini` (Pro).
4. **Actualización de Ignorados:** Si se añaden nuevos tipos de archivos pesados, actualizar `workspace/.clawignore`.

---
*Nota: Se resolvió el conflicto inicial con OpenAI/Codex eliminando los archivos de configuración de agente redundantes y forzando los modelos de Google en la configuración global.*
