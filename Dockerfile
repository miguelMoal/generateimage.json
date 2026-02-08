# Base oficial liviana (sin modelos baked-in)
FROM runpod/worker-comfyui:5.5.1-base

# Instalar herramientas básicas si las necesitas (curl y wget ya suelen estar, pero por seguridad)
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl wget && \
    rm -rf /var/lib/apt/lists/*

# Crear carpetas de modelos (por si acaso no existen)
RUN mkdir -p /comfyui/models/checkpoints \
             /comfyui/models/vae \
             /comfyui/models/loras \
             /comfyui/models/controlnet \
             /comfyui/models/embeddings

# Copiar nuestro start.sh custom
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Override el entrypoint para usar nuestro script
ENTRYPOINT ["/start.sh"]