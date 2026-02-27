# Imagen base con ComfyUI + comfy-cli + manager
FROM runpod/worker-comfyui:5.5.1-base

# Instalar herramientas básicas para descargas
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl wget && \
    rm -rf /var/lib/apt/lists/*
    

# Crear las carpetas de modelos si no existen
RUN mkdir -p /comfyui/models/checkpoints \
    && mkdir -p /comfyui/models/vae

# Descargar Moody Porn Mix - ZIT V9 (ZImageTurbo Checkpoint)
# https://civitai.com/models/620406/moody-porn-mix
RUN curl -L \
    -o /comfyui/models/checkpoints/moodyPornMix_zitV9.safetensors \
    "https://civitai.com/api/download/models/2708928?token=6dad8c346283f3f0023ebc9245848383"

# Verificación al final del build (para debuggear si algo falló)
RUN echo "=== Checkpoints descargados ===" && \
    ls -lh /comfyui/models/checkpoints/ && \
    echo "=== VAEs descargados ===" && \
    ls -lh /comfyui/models/vae/