# 🌙 Project Noctambulo: Autonomous Vibecoding (OpenClaw + Gemini + Godot GDScript)

## 🎯 System Objective
This document defines the autonomous execution environment, infrastructure configuration, and software architecture for a mobile game MVP. The agent (OpenClaw) should read this document to understand its purpose: executing development, compilation, and testing tasks uninterrupted during an 8-hour block without requiring human terminal intervention.

## 1. Infrastructure and Sandbox (Ubuntu)

The execution environment is an isolated Ubuntu sandbox. The agent has full permissions within the Docker container to create, modify, and delete files, as well as install system dependencies required for Godot 4.x.

### Required Technical Stack:
*   **Dispatcher/Persona:** OpenClaw (Chappie) — Telegram + `gemini-2.5-flash` sobre **API key free tier sin billing**.
*   **Coding engine:** Gemini CLI oficial sobre **free tier de OAuth** (cuota aparte), invocado por Chappie.
*   **Engine:** Godot Engine 4.x (Standard version).
*   **Language:** GDScript.
*   **Notification Interface:** Telegram Bot API.

> Setup real, login OAuth y comando de delegación: ver `GEMINI.md`. El `docker-compose.yml` de abajo es ilustrativo; el del repo es la fuente de verdad.

## 2. Agent Configuration (OpenClaw)

The agent should be initialized using the following `docker-compose.yml` to ensure data persistence and network access:

```yaml
version: '3.8'
services:
  openclaw-agent:
    image: openclaw/core:latest
    container_name: openclaw_sandbox
    environment:
      - GEMINI_API_KEY=${GEMINI_API_KEY}
      - TELEGRAM_BOT_TOKEN=${TELEGRAM_BOT_TOKEN}
      - TELEGRAM_CHAT_ID=${TELEGRAM_CHAT_ID}
      - MAX_API_SPEND_USD=5.00 # Strict security limit
      - AUTO_RETRY_LIMIT=5 # Avoid infinite loops on compilation errors
    volumes:
      - ./workspace:/workspace
    working_dir: /workspace
```

## 3. Project Structure

The workspace is organized to support multiple prototypes and shared logic:

*   `workspace/`: Main Godot project folder.
*   `workspace/void-tap/`: Prototype for a simple vertical tapping game.
*   `workspace/grid-runner/`: Prototype for a grid-based movement game.
*   `workspace/scripts/`: Shared logic and base classes.
*   `workspace/scenes/`: Common scenes.

## 4. Development Workflow

The agent follows an autonomous "Plan-Act-Validate" cycle:
1.  **Research:** Analyze existing scripts and scene structure.
2.  **Strategy:** Propose a solution or new feature.
3.  **Implementation:** Write GDScript code and update `.tscn` files.
4.  **Verification:** Run Godot in headless mode to verify no loading errors and trigger CI/CD for Web deployment.

---
*Note: The project was migrated from C# to GDScript to ensure full compatibility with Godot 4 Web (HTML5) exports.*
