# Imagen base con ComfyUI + Flux XL (arquitectura NextDiT 3840)
# Necesaria para Moody Porn Mix ZIT V9 que usa dimensiones Flux XL
FROM runpod/worker-comfyui:5.7.1-flux1-dev

# Instalar herramientas básicas para descargas
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl wget && \
    rm -rf /var/lib/apt/lists/*
    

# Crear las carpetas de modelos si no existen
RUN mkdir -p /comfyui/models/checkpoints \
    && mkdir -p /comfyui/models/vae

# Descargar Moody Porn Mix - ZIT V9 (arquitectura Flux XL / NextDiT)
# https://civitai.com/models/620406/moody-porn-mix
RUN curl -L \
    -o /comfyui/models/checkpoints/moodyPornMix_zitV9.safetensors \
    "https://civitai.com/api/download/models/2708928?token=6dad8c346283f3f0023ebc9245848383"

# Verificación al final del build (para debuggear si algo falló)
RUN echo "=== Checkpoints descargados ===" && \
    ls -lh /comfyui/models/checkpoints/ && \
    echo "=== VAEs descargados ===" && \
    ls -lh /comfyui/models/vae/