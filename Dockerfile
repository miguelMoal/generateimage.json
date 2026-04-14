# Imagen base con ComfyUI + comfy-cli + manager
FROM runpod/worker-comfyui:5.5.1-base

# Instalar herramientas básicas para descargas
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl wget && \
    rm -rf /var/lib/apt/lists/*
    

# Animagine XL 3.1: checkpoint + VAE (Diffusers) desde Hugging Face (mig1234/animagine-xl-3.1)
RUN mkdir -p /comfyui/models/checkpoints /comfyui/models/vae \
    && curl -fL -o /comfyui/models/checkpoints/animagine-xl-3.1.safetensors \
    "https://huggingface.co/mig1234/animagine-xl-3.1/resolve/main/animagine-xl-3.1.safetensors" \
    && curl -fL -o /comfyui/models/vae/diffusion_pytorch_model.safetensors \
    "https://huggingface.co/mig1234/animagine-xl-3.1/resolve/main/vae/diffusion_pytorch_model.safetensors" \
    && echo "=== Modelos descargados ===" && ls -lh /comfyui/models/checkpoints/ && ls -lh /comfyui/models/vae/