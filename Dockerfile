# Imagen base con ComfyUI + Flux XL (arquitectura NextDiT 3840)
# Necesaria para Moody Porn Mix ZIT V9 que usa dimensiones Flux XL
FROM runpod/worker-comfyui:5.7.1-flux1-dev

# Instalar herramientas básicas para descargas
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl wget && \
    rm -rf /var/lib/apt/lists/*
    

# Crear carpetas de modelos (unet para modelos sin CLIP)
RUN mkdir -p /comfyui/models/unet

# Descargar Moody Porn Mix - ZIT V9 (solo difusión, sin CLIP)
# Debe cargarse con UNETLoader + DualCLIPLoader + VAELoader por separado
# https://civitai.com/models/620406/moody-porn-mix
RUN curl -L \
    -o /comfyui/models/unet/moodyPornMix_zitV9.safetensors \
    "https://civitai.com/api/download/models/2708928?token=6dad8c346283f3f0023ebc9245848383"

# Verificación
RUN echo "=== UNET/Diffusion models ===" && ls -lh /comfyui/models/unet/ && \
    echo "=== CLIP (Flux encoders) ===" && ls -lh /comfyui/models/clip/ 2>/dev/null || true