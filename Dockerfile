# Imagen base con ComfyUI + comfy-cli + manager (RunPod serverless)
FROM runpod/worker-comfyui:5.5.1-base

# Instalar herramientas básicas para descargas
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*

# Handler y módulos requeridos por RunPod (deploy desde GitHub)
COPY handler.py /handler.py
COPY network_volume.py /network_volume.py

# Script de descarga condicional (solo si no existen en el volumen)
COPY download-models.sh /download-models.sh
RUN chmod +x /download-models.sh

# Crear entrypoint wrapper: descarga modelos -> ejecuta worker
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/start.sh"]
