#!/usr/bin/env bash
# naru-watchdog.sh — destraba el gateway de OpenClaw (Naru) cuando se cuelga.
#
# Problema que resuelve (incidente 2026-06-03): el proceso `openclaw` sigue VIVO
# y el healthcheck del contenedor queda "healthy", pero su scheduler interno se
# wedgea (un fetch de Telegram se queda pegado) y deja de disparar heartbeats:
# no hay logs, no avanza el backlog. Este watchdog detecta el silencio del stream
# de logs y reinicia el servicio con `docker compose restart` (NO recreate, para
# no perder el pairing de Telegram).
#
# Diseño anti-falsos-positivos:
#  - Solo es agresivo en la ventana nocturna (23:00–08:00 MX), cuando el heartbeat
#    cada 25m DEBE producir logs. De día los huecos de inactividad son normales
#    (vimos gaps legítimos de ~50 min), así que el umbral es mucho más laxo.
#  - Si hay un proceso `agy` corriendo dentro del contenedor = está delegando
#    código de verdad (la llamada bloquea minutos): NO reinicia, salvo que lleve
#    colgado demasiado (probable CLI hung).
#  - Rate-limit: no reinicia más de una vez cada 15 min (evita tormentas).
#
# Instálalo en cron del usuario (cada 10 min):
#   */10 * * * * /home/gozhack/Documents/night-coding/scripts/naru-watchdog.sh >/dev/null 2>&1

set -euo pipefail
export PATH="/usr/local/bin:/usr/bin:/bin:${PATH:-}"

CONTAINER="openclaw_sandbox"
SERVICE="openclaw-agent"
COMPOSE_DIR="/home/gozhack/Documents/night-coding"
TZ_BOT="America/Mexico_City"

LOG="$COMPOSE_DIR/.naru-watchdog.log"            # gitignored
LAST_RESTART_FILE="$COMPOSE_DIR/.naru-watchdog.last"

NIGHT_THRESHOLD=2100   # 35 min  (ventana 23:00–08:00: el heartbeat de 25m debe loguear)
DAY_THRESHOLD=5400     # 90 min  (de día los huecos son normales)
GEMINI_HUNG=2700       # 45 min  (si hay agy corriendo PERO los logs llevan >esto, está colgado)
MIN_RESTART_GAP=900    # 15 min entre reinicios

log() { echo "$(date -Iseconds) $*" >> "$LOG"; }

do_restart() {
  local reason="$1" now; now=$(date +%s)
  if [ -f "$LAST_RESTART_FILE" ]; then
    local prev; prev=$(cat "$LAST_RESTART_FILE" 2>/dev/null || echo 0)
    if [ $((now - prev)) -lt "$MIN_RESTART_GAP" ]; then
      log "restart SUPRIMIDO ($reason) — el último fue hace $((now - prev))s (<${MIN_RESTART_GAP}s)"
      exit 0
    fi
  fi
  echo "$now" > "$LAST_RESTART_FILE"
  if (cd "$COMPOSE_DIR" && docker compose restart "$SERVICE" >/dev/null 2>&1); then
    log "✅ REINICIADO ($reason)"
  else
    log "❌ FALLÓ el restart ($reason)"
  fi
  exit 0
}

# 1) ¿El contenedor existe y corre? Si está caído, levántalo.
state=$(docker inspect -f '{{.State.Running}}' "$CONTAINER" 2>/dev/null || echo "missing")
if [ "$state" != "true" ]; then
  log "contenedor no corriendo (state=$state) — docker compose up -d"
  (cd "$COMPOSE_DIR" && docker compose up -d "$SERVICE" >/dev/null 2>&1) && log "✅ levantado" || log "❌ up -d falló"
  exit 0
fi

# 2) Umbral según la hora del bot (MX).
hour=$(TZ="$TZ_BOT" date +%H); hour=$((10#$hour))
if [ "$hour" -ge 23 ] || [ "$hour" -lt 8 ]; then THRESHOLD=$NIGHT_THRESHOLD; else THRESHOLD=$DAY_THRESHOLD; fi

# 3) Antigüedad de la última línea de log (timestamp que pone docker con -t).
last_ts=$(docker logs -t --tail 1 "$CONTAINER" 2>&1 | tail -1 | awk '{print $1}')
if [ -z "$last_ts" ]; then
  do_restart "sin ninguna salida de log"
fi
last_epoch=$(date -d "$last_ts" +%s 2>/dev/null || echo 0)
if [ "$last_epoch" -eq 0 ]; then
  log "no pude parsear el timestamp del último log ('$last_ts') — sin acción"
  exit 0
fi
age=$(( $(date +%s) - last_epoch ))

# Logs frescos → todo bien.
if [ "$age" -lt "$THRESHOLD" ]; then
  exit 0
fi

# 4) Logs viejos. ¿Hay una delegación al CLI en curso? No mates trabajo real.
if docker exec "$CONTAINER" pgrep -f '[a]gy' >/dev/null 2>&1; then
  if [ "$age" -lt "$GEMINI_HUNG" ]; then
    log "logs viejos (${age}s) PERO agy está delegando — no reinicio (trabajando)"
    exit 0
  fi
  do_restart "agy corriendo pero logs >${GEMINI_HUNG}s (CLI colgado)"
fi

# 5) Sin delegación y logs viejos en ventana activa → wedge. Reinicia.
do_restart "logs estancados ${age}s (umbral ${THRESHOLD}s, hora ${hour} MX)"
