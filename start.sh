#!/usr/bin/env bash

echo "Iniciando worker ComfyUI custom con Network Volume..."

# Opcional: imprime info útil en logs para debug
echo "Ruta del volume: /runpod-volume"
ls -la /runpod-volume || echo "No se ve el volume aún..."

# Crea las carpetas locales si no existen (por seguridad)
mkdir -p /comfyui/models/checkpoints \
         /comfyui/models/vae \
         /comfyui/models/loras \
         /comfyui/models/controlnet \
         /comfyui/models/embeddings

# Crea symlinks (enlaces simbólicos) para que ComfyUI vea los archivos en sus rutas normales
echo "Creando symlinks a modelos..."
ln -sf /runpod-volume/models/checkpoints/* /comfyui/models/checkpoints/ 2>/dev/null || echo "No hay checkpoints en el volume"
ln -sf /runpod-volume/models/vae/* /comfyui/models/vae/ 2>/dev/null || echo "No hay VAEs en el volume"
ln -sf /runpod-volume/models/loras/* /comfyui/models/loras/ 2>/dev/null || echo "No hay LoRAs en el volume"

# Muestra qué modelos se han enlazado
echo "Modelos disponibles en /comfyui/models/checkpoints/:"
ls -la /comfyui/models/checkpoints/ 2>/dev/null || echo "Carpeta vacía"

echo "Symlinks creados. Modelos deberían cargarse desde /runpod-volume."

# EJECUTAR EL HANDLER ORIGINAL DEL WORKER DE RUNPOD
# Busca el script original del worker (puede estar en varias ubicaciones)
echo "Buscando handler original de RunPod..."

# Opción 1: Si usas la imagen base runpod/worker-comfyui
if [ -f "/handler.py" ]; then
    echo "Ejecutando handler.py original..."
    exec python /handler.py
elif [ -f "/app/handler.py" ]; then
    echo "Ejecutando /app/handler.py original..."
    exec python /app/handler.py
elif [ -f "/worker/handler.py" ]; then
    echo "Ejecutando /worker/handler.py original..."
    exec python /worker/handler.py
else
    echo "ERROR: No se encontró handler.py. Buscando alternativas..."
    # Busca cualquier handler en el sistema
    find / -name "handler.py" 2>/dev/null | head -5
    exit 1
fi