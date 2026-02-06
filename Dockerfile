# clean base image containing only comfyui, comfy-cli and comfyui-manager
FROM runpod/worker-comfyui:5.5.1-base

# Instalar herramientas de descarga (curl + wget por seguridad)
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl wget && \
    rm -rf /var/lib/apt/lists/*

# Crear carpetas necesarias
RUN mkdir -p /comfyui/models/checkpoints \
    && mkdir -p /comfyui/models/vae

# VAE recomendado para SDXL / Pony (mejora colores y detalles)
RUN curl -L -o /comfyui/models/vae/sdxl_vae.safetensors \
    https://huggingface.co/madebyollin/sdxl-vae-fp16-fix/resolve/main/sdxl_vae.safetensors

# Flux.1-dev (modelo top para calidad general, cine, arte y realismo premium)
# Archivo oficial ~23.8 GB - requiere mucho espacio y VRAM
RUN curl -L -o /comfyui/models/checkpoints/flux1-dev.safetensors \
    https://huggingface.co/Comfy-Org/flux1-dev/resolve/main/flux1-dev-fp8.safetensors || \
    wget -O /comfyui/models/checkpoints/flux1-dev.safetensors \
    https://huggingface.co/Comfy-Org/flux1-dev/resolve/main/flux1-dev-fp8.safetensors

# Modelo 1: Juggernaut XL Ragnarok (cine / realismo dramático)
RUN curl -L -o /comfyui/models/checkpoints/juggernautXL_ragnarokBy.safetensors \
    https://huggingface.co/xxiaogui/hongchao/resolve/main/juggernautXL_ragnarokBy.safetensors || \
    wget -O /comfyui/models/checkpoints/juggernautXL_ragnarokBy.safetensors \
    https://huggingface.co/xxiaogui/hongchao/resolve/main/juggernautXL_ragnarokBy.safetensors

# Modelo 4: DreamShaper XL (artístico, ilustración, fantasía, versátil)
RUN curl -L -o /comfyui/models/checkpoints/dreamshaper_xl.safetensors \
    https://huggingface.co/Lykon/dreamshaper-xl-v2-turbo/resolve/main/DreamShaperXL_Turbo_v2.safetensors || \
    wget -O /comfyui/models/checkpoints/dreamshaper_xl.safetensors \
    https://huggingface.co/Lykon/dreamshaper-xl-v2-turbo/resolve/main/DreamShaperXL_Turbo_v2.safetensors

# Chequeo final (aparece en logs del build para verificar que todo se descargó bien)
RUN echo "Modelos descargados en checkpoints:" && \
    ls -lh /comfyui/models/checkpoints/ && \
    echo "VAE descargado:" && \
    ls -lh /comfyui/models/vae/