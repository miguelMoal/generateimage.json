# Imagen base limpia con ComfyUI, comfy-cli y comfyui-manager
FROM runpod/worker-comfyui:5.5.1-base

# Instalar herramientas de descarga
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl wget && \
    rm -rf /var/lib/apt/lists/*

# Crear carpetas necesarias
RUN mkdir -p /comfyui/models/checkpoints \
    && mkdir -p /comfyui/models/vae

# ────────────────────────────────────────────────
# VAE recomendado para SDXL / Pony (opcional, pero útil)
# ────────────────────────────────────────────────
RUN curl -L -o /comfyui/models/vae/sdxl_vae.safetensors \
    https://huggingface.co/madebyollin/sdxl-vae-fp16-fix/resolve/main/sdxl_vae.safetensors

# ────────────────────────────────────────────────
# Modelo principal: CyberRealistic Pony (pruned fp16)
# Requiere token de Civitai porque está restringido/gated
# ────────────────────────────────────────────────

# Opción recomendada: usar curl con parámetro token en la URL
RUN curl -L \
    -o /comfyui/models/checkpoints/cyberrealistic_pony_v16.safetensors \
    "https://civitai.com/api/download/models/2581228?type=Model&format=SafeTensor&size=pruned&fp=fp16&token=651a2e81cd82f63e22dfb71b51ad4dc2"

# Alternativa con wget (descomenta si prefieres wget)
# RUN wget -O /comfyui/models/checkpoints/cyberrealistic_pony_v16.safetensors \
#     "https://civitai.com/api/download/models/2581228?type=Model&format=SafeTensor&size=pruned&fp=fp16&token=${CIVITAI_TOKEN}"

# Verificación final (útil para depurar el build)
RUN echo "Modelos en checkpoints:" && \
    ls -lh /comfyui/models/checkpoints/ && \
    echo "VAE en vae:" && \
    ls -lh /comfyui/models/vae/