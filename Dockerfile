# Moody Porn Mix (ZIT V9) - RunPod Serverless
# Basado en worker-comfyui con modelo de CivitAI
# Modelo: https://civitai.com/models/620406/moody-porn-mix

ARG BASE_IMAGE=runpod/worker-comfyui:latest-z-image-turbo
FROM ${BASE_IMAGE}

# Token de CivitAI para descargar modelos (requerido para NSFW)
ARG CIVITAI_TOKEN=6dad8c346283f3f0023ebc9245848383
ENV CIVITAI_TOKEN=${CIVITAI_TOKEN}

# ID de la versión del modelo en CivitAI (ZIT V9)
ARG CIVITAI_MODEL_VERSION=2708928
ARG MODEL_FILENAME=moodyPornMix_zitV9.safetensors

WORKDIR /comfyui

# Descargar Moody Porn Mix desde CivitAI
# La API redirige a una URL firmada; wget -L sigue redirects
RUN if [ -n "$CIVITAI_TOKEN" ]; then \
    wget -q -L --header="Authorization: Bearer ${CIVITAI_TOKEN}" \
         -O "models/diffusion_models/${MODEL_FILENAME}" \
         "https://civitai.com/api/download/models/${CIVITAI_MODEL_VERSION}?token=${CIVITAI_TOKEN}"; \
    echo "Modelo Moody Porn Mix descargado correctamente"; \
else \
    echo "ERROR: CIVITAI_TOKEN es requerido para descargar el modelo. "; \
    echo "Obtén tu token en https://civitai.com/user/account"; \
    echo "Build con: docker build --build-arg CIVITAI_TOKEN=tu_token ."; \
    exit 1; \
fi
