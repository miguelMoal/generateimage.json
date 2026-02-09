# Imagen base con ComfyUI + comfy-cli + manager
FROM runpod/worker-comfyui:5.5.1-base

# Instalar herramientas básicas para descargas
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl wget && \
    rm -rf /var/lib/apt/lists/*
    

# Crear las carpetas de modelos si no existen
RUN mkdir -p /comfyui/models/checkpoints \
    && mkdir -p /comfyui/models/vae

# Descargar checkpoints de ejemplo (tus originales)
RUN curl -L \
    -o /comfyui/models/checkpoints/juggernautXL.safetensors \
    "https://civitai.com/api/download/models/1759168?type=Model&format=SafeTensor&size=full&fp=fp16" \
    && curl -L \
    -o /comfyui/models/checkpoints/DreamShaper.safetensors \
    "https://civitai.com/api/download/models/128713?type=Model&format=SafeTensor&size=pruned&fp=fp16"

# Descargar Animagine XL V3.1 - Checkpoint principal
RUN curl -L \
    -o /comfyui/models/checkpoints/animagine-xl-v31.safetensors \
    "https://civitai.com/api/download/models/403131?type=Model&format=SafeTensor&size=full&fp=fp16&token=33e893cf7d1a8522a05809bd10d6ac55"

# Descargar Animagine XL V3.1 - VAE dedicado (recomendado para mejores colores en anime)
RUN curl -L \
    -o /comfyui/models/vae/animagine-xl-v31.vae.safetensors \
    "https://civitai.com/api/download/models/403131?type=VAE&format=SafeTensor&token=33e893cf7d1a8522a05809bd10d6ac55"

# Verificación al final del build (para debuggear si algo falló)
RUN echo "=== Checkpoints descargados ===" && \
    ls -lh /comfyui/models/checkpoints/ && \
    echo "=== VAEs descargados ===" && \
    ls -lh /comfyui/models/vae/