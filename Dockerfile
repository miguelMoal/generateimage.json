# Moody Porn Mix (ZIT V9) - RunPod Serverless
# Basado en worker-comfyui base + componentes Z-Image-Turbo
# Nota: runpod/worker-comfyui no publica z-image-turbo; usamos 5.7.1-base y añadimos modelos
# Modelo: https://civitai.com/models/620406/moody-porn-mix

ARG BASE_IMAGE=runpod/worker-comfyui:5.7.1-base
FROM ${BASE_IMAGE}

# Token de CivitAI para descargar modelos (requerido para NSFW)
ARG CIVITAI_TOKEN=6dad8c346283f3f0023ebc9245848383
ENV CIVITAI_TOKEN=${CIVITAI_TOKEN}

# Versión FP8 para mejor compatibilidad con UNETLoader (la NF4 puede fallar silenciosamente)
ARG CIVITAI_MODEL_VERSION=2708941
ARG MODEL_FILENAME=moodyPornMix_zitV9FP8.safetensors

WORKDIR /comfyui

# Crear directorios para modelos Z-Image-Turbo
RUN mkdir -p models/diffusion_models models/text_encoders models/vae models/model_patches

# Descargar componentes Z-Image-Turbo desde HuggingFace (text encoder, VAE)
RUN wget -q -O models/text_encoders/qwen_3_4b.safetensors \
    "https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/text_encoders/qwen_3_4b.safetensors" && \
    wget -q -O models/vae/ae.safetensors \
    "https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/vae/ae.safetensors"

# Descargar Moody Porn Mix desde CivitAI
RUN wget -q -L --header="Authorization: Bearer ${CIVITAI_TOKEN}" \
    -O "models/diffusion_models/${MODEL_FILENAME}" \
    "https://civitai.com/api/download/models/${CIVITAI_MODEL_VERSION}?token=${CIVITAI_TOKEN}" && \
    echo "Modelo Moody Porn Mix descargado correctamente"
