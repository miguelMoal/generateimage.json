# clean base image containing only comfyui, comfy-cli and comfyui-manager
FROM runpod/worker-comfyui:5.5.1-base

# Instalar herramientas de descarga (curl + wget por seguridad)
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl wget && \
    rm -rf /var/lib/apt/lists/*

# Copia el script de inicio personalizado
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Usamos ENTRYPOINT para que ejecute nuestro script al iniciar el contenedor
ENTRYPOINT ["/start.sh"]