# Imagen base con ComfyUI + comfy-cli + manager
FROM runpod/worker-comfyui:5.5.1-base

# Instalar herramientas básicas para descargas
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl wget && \
    rm -rf /var/lib/apt/lists/*
    

# Crear carpetas y descargar solo Animagine XL V3.1 (checkpoint + VAE)
RUN mkdir -p /comfyui/models/checkpoints /comfyui/models/vae \
    && curl -L -o /comfyui/models/checkpoints/animagine-xl-v31.safetensors \
    "https://civitai.com/api/download/models/403131?type=Model&format=SafeTensor&size=full&fp=fp16&token=0477087baae314d91716cb4ec3bbfddd" \
    && curl -L -o /comfyui/models/vae/animagine-xl-v31.vae.safetensors \
    "https://civitai.com/api/download/models/403131?type=VAE&format=SafeTensor&token=0477087baae314d91716cb4ec3bbfddd" \
    && echo "=== Modelos descargados ===" && ls -lh /comfyui/models/checkpoints/ && ls -lh /comfyui/models/vae/