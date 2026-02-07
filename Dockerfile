# clean base image containing only comfyui, comfy-cli and comfyui-manager
FROM runpod/worker-comfyui:5.5.1-base

# Instalar solo curl (más ligero y suficiente)
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl ca-certificates && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

# Crear carpetas necesarias (buena práctica, aunque en la base ya existan)
RUN mkdir -p /comfyui/models/checkpoints \
    && mkdir -p /comfyui/models/vae

# CyberRealistic Pony v16.0 (~12.9 GB)
# Pony-based, semi-realistic + estilos flexibles
ARG CIVITAI_API_KEY

# Descarga con token como query parameter (método recomendado por Civitai)
RUN curl -L --fail --retry 3 --retry-delay 5 \
    -o /comfyui/models/checkpoints/CyberRealistic.Pony.safetensors \
    "https://civitai.com/api/download/models/2581228?type=Model&format=SafeTensor&size=full&fp=fp32&token=${CIVITAI_API_KEY}" \
    || { echo "ERROR: Falló la descarga - verifica que CIVITAI_API_KEY sea válido y que el modelo requiera login."; exit 1; }

# Verificación en logs del build (muy útil para depurar)
RUN echo "=========================================" && \
    echo "Modelos en checkpoints:" && \
    ls -lh /comfyui/models/checkpoints/ && \
    echo "=========================================" && \
    echo "VAE (por ahora vacío):" && \
    ls -lh /comfyui/models/vae/ || true