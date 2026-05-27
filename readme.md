# 🌙 Proyecto Noctámbulo: Autonomous Vibecoding (OpenClaw + Gemini + Godot C#)

## 🎯 Objetivo del Sistema
Este documento define el entorno de ejecución autónoma, la configuración de infraestructura y la arquitectura de software para un MVP de juego móvil. El agente (OpenClaw) debe leer este documento para entender su propósito: ejecutar tareas de desarrollo, compilación y prueba de forma ininterrumpida durante un bloque de 8 horas sin requerir intervención humana en la terminal.

## 1. Infraestructura y Sandbox (Ubuntu)

El entorno de ejecución es un sandbox Ubuntu aislado. El agente tiene permisos totales dentro del contenedor Docker para crear, modificar y eliminar archivos, así como para instalar dependencias de sistema necesarias para Godot 4.x (versión .NET).

### Stack Técnico Requerido:
*   **Agente:** OpenClaw (Ejecución en segundo plano).
*   **LLM:** Gemini 1.5 Pro (vía API).
*   **Motor:** Godot Engine 4.x (.NET version).
*   **Lenguaje:** C# 11/12 (.NET 8).
*   **Interfaz de Notificación:** Telegram Bot API.

## 2. Configuración del Agente (OpenClaw)

El agente debe inicializarse usando el siguiente archivo `docker-compose.yml` para garantizar persistencia de datos y acceso a red:

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
      - MAX_API_SPEND_USD=5.00 # Límite estricto de seguridad
      - AUTO_RETRY_LIMIT=5 # Evita bucles infinitos en errores de compilación
    volumes:
      - ./workspace:/workspace
    working_dir: /workspace