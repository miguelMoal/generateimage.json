FROM runpod/worker-comfyui:5.5.1-base

# Instalar curl para health checks
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Crear estructura de carpetas
RUN mkdir -p /comfyui/models/{checkpoints,vae,loras,controlnet,embeddings}

# Copiar nuestro start.sh CORREGIDO
COPY start.sh /start.sh
RUN chmod +x /start.sh

ENTRYPOINT ["/start.sh"]