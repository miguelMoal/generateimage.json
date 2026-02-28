# Qwen-Image-Edit-Rapid-AIO v23 para RunPod Serverless
# Modelo: https://huggingface.co/Phr00t/Qwen-Image-Edit-Rapid-AIO/tree/main/v23
# Basado en runpod/worker-comfyui

ARG WORKER_VERSION=5.7.1
FROM runpod/worker-comfyui:${WORKER_VERSION}-base AS base

# Variables para modelo SFW o NSFW
ARG QWEN_MODEL_VARIANT=nsfw
# sfw = Qwen-Rapid-AIO-SFW-v23.safetensors
# nsfw = Qwen-Rapid-AIO-NSFW-v23.safetensors

WORKDIR /comfyui

# Crear directorios para modelos
RUN mkdir -p models/checkpoints models/input

# Descargar modelo Qwen-Rapid-AIO v23
RUN if [ "$QWEN_MODEL_VARIANT" = "nsfw" ]; then \
    wget -q -O models/checkpoints/Qwen-Rapid-AIO-v23.safetensors \
    https://huggingface.co/Phr00t/Qwen-Image-Edit-Rapid-AIO/resolve/main/v23/Qwen-Rapid-AIO-NSFW-v23.safetensors; \
  else \
    wget -q -O models/checkpoints/Qwen-Rapid-AIO-v23.safetensors \
    https://huggingface.co/Phr00t/Qwen-Image-Edit-Rapid-AIO/resolve/main/v23/Qwen-Rapid-AIO-SFW-v23.safetensors; \
  fi

# Instalar custom nodes para Qwen Image Edit (TextEncodeQwenImageEditPlus)
# El modelo Rapid-AIO usa CheckpointLoaderSimple + TextEncodeQwenImageEditPlus
RUN comfy node install --mode=remote Comfyui-QwenEditUtils 2>/dev/null || \
    (cd /comfyui/custom_nodes && git clone --depth 1 https://github.com/lrzjason/Comfyui-QwenEditUtils.git Comfyui-QwenEditUtils)

WORKDIR /
