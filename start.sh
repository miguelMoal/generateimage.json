#!/usr/bin/env bash

echo "=== CONFIGURACIÓN DE MODELOS ==="

# 1. Configurar modelos (tus symlinks)
mkdir -p /comfyui/models/{checkpoints,vae,loras,controlnet,embeddings}
ln -sf /runpod-volume/models/* /comfyui/models/ 2>/dev/null || true

echo "Modelos configurados:"
ls -la /comfyui/models/checkpoints/ 2>/dev/null | head -5

# 2. INICIAR COMFYUI EN SEGUNDO PLANO
echo "=== INICIANDO COMFYUI SERVER ==="
cd /comfyuiß
# Iniciar ComfyUI en background con los parámetros CORRECTOS
python main.py \
  --listen 127.0.0.1 \
  --port 8188 \
  --enable-cors-header \
  --disable-auto-launch \
  > /tmp/comfyui.log 2>&1 &

# Guardar el PID de ComfyUI
COMFY_PID=$!
echo "ComfyUI PID: $COMFY_PID"

# 3. ESPERAR QUE COMFYUI ESTÉ LISTO
echo "Esperando que ComfyUI inicie (máx 60 segundos)..."
for i in {1..60}; do
    if curl -s http://127.0.0.1:8188/ > /dev/null; then
        echo "✅ ComfyUI listo en http://127.0.0.1:8188/"
        break
    fi
    if [ $i -eq 60 ]; then
        echo "❌ ComfyUI no inició. Logs:"
        tail -50 /tmp/comfyui.log
        exit 1
    fi
    sleep 1
done

# 4. INICIAR EL HANDLER DE RUNPOD (que se conectará a ComfyUI)
echo "=== INICIANDO HANDLER DE RUNPOD ==="
exec python /handler.py