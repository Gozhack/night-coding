#!/bin/bash
# agy-wrapper.sh — guard determinístico anti-martilleo de cuota free de Antigravity.
# container-init.sh lo instala como /usr/local/bin/agy (el binario real pasa a agy-real).
# Regla: máx 1 corrida de agy por ventana de cooldown. Si Naru (o quien sea) llama
# antes de tiempo, falla limpio con mensaje claro — Naru lo reporta y espera el
# siguiente heartbeat, igual que con un 429. Convierte la regla de prompt
# "una tarea por heartbeat" en una garantía técnica.
STAMP=/tmp/.agy-last-run
COOLDOWN="${AGY_COOLDOWN_SECONDS:-1200}"   # 20 min; el heartbeat es cada 25

now=$(date +%s)
last=$(cat "$STAMP" 2>/dev/null || echo 0)
elapsed=$(( now - last ))

if [ "$elapsed" -lt "$COOLDOWN" ]; then
  mins=$(( (COOLDOWN - elapsed + 59) / 60 ))
  echo "agy: cooldown de cuota activo — faltan ~${mins} min. NO reintentes ni loopees; espera el siguiente heartbeat." >&2
  exit 75
fi

echo "$now" > "$STAMP"
exec /usr/local/bin/agy-real "$@"
