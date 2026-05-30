#!/usr/bin/env bash
# container-init.sh — arranque del contenedor OpenClaw.
# Configura git para que Chappie pueda commitear/pushear a night-coding DESDE el
# contenedor (el repo se monta completo en /repo), siembra los archivos de
# continuidad del bot si faltan, y luego arranca el gateway.
#
# OJO: esto lo hace el BOOT del contenedor, no el agente. La red line de "el bot
# nunca toca git config/credenciales" sigue vigente para las acciones del agente.
set -u

REPO=/repo
AGENT_WS=/root/.openclaw/workspace

echo "[container-init] configurando git para $REPO ..."

# Identidad + safe.directory (el mount es de otro uid -> git lo marca "dubious ownership").
git config --global --add safe.directory "$REPO" 2>/dev/null || true
git config --global user.name  "${GIT_USER_NAME:-Chappie}"  2>/dev/null || true
git config --global user.email "${GIT_USER_EMAIL:-chappie@night-coding.local}" 2>/dev/null || true
git config --global credential.helper store 2>/dev/null || true

# Credenciales de push HTTPS, SIN incrustar el token en la URL del remoto.
if [ -n "${GITHUB_TOKEN:-}" ]; then
  printf 'https://x-access-token:%s@github.com\n' "$GITHUB_TOKEN" > /root/.git-credentials
  chmod 600 /root/.git-credentials
  echo "[container-init] credenciales github.com listas (push habilitado)"
else
  echo "[container-init] WARNING: GITHUB_TOKEN vacio -> Chappie podra commit local pero NO push"
fi

# Sembrar continuidad del bot en el volumen persistente, solo si falta (el bot
# luego los evoluciona y sus ediciones persisten).
mkdir -p "$AGENT_WS/memory" 2>/dev/null || true
for f in HEARTBEAT.md USER.md; do
  if [ ! -f "$AGENT_WS/$f" ] && [ -f "$REPO/.openclaw_config/templates/$f" ]; then
    cp "$REPO/.openclaw_config/templates/$f" "$AGENT_WS/$f" && echo "[container-init] seed $f"
  fi
done

# Arrancar el gateway (equivalente al command original de la imagen base).
echo "[container-init] arrancando gateway ..."
cd /app
exec node openclaw.mjs gateway --allow-unconfigured --password "${OPENCLAW_PASSWORD:-sandbox}"
