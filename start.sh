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
# El * hace que linkee todos los archivos de la carpeta del volume
ln -sfn /runpod-volume/models/checkpoints/* /comfyui/models/checkpoints/ 2>/dev/null || true
ln -sfn /runpod-volume/models/vae/*         /comfyui/models/vae/         2>/dev/null || true
ln -sfn /runpod-volume/models/loras/*       /comfyui/models/loras/       2>/dev/null || true
# Agrega más si usas controlnet, embeddings, unet, etc.
# ln -sfn /runpod-volume/models/controlnet/* /comfyui/models/controlnet/ 2>/dev/null || true

# Opcional: symlink completo de toda la carpeta models (más simple y cubre todo)
# rm -rf /comfyui/models && ln -s /runpod-volume/models /comfyui/models

echo "Symlinks creados. Modelos deberían cargarse desde /runpod-volume."

# Ejecuta el script de inicio original del worker-comfyui base
# (normalmente lanza el handler de RunPod + el server de ComfyUI)
exec /start.sh