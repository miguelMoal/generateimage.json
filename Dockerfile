# Moody Porn Mix ZIT V9 usa arquitectura Z-Image (2560 dim), NO Flux (4096 dim).
# Requiere CLIP Qwen (qwen_3_4b), no DualCLIPLoader con clip_l + t5xxl.
FROM runpod/worker-comfyui:5.7.1-flux1-dev

# Instalar herramientas básicas para descargas
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl wget && \
    rm -rf /var/lib/apt/lists/*

# Crear carpetas de modelos
RUN mkdir -p /comfyui/models/unet /comfyui/models/text_encoders

# Moody Porn Mix - ZIT V9 (solo UNet, sin CLIP)
# https://civitai.com/models/620406/moody-porn-mix
RUN curl -L \
    -o /comfyui/models/unet/moodyPornMix_zitV9.safetensors \
    "https://civitai.com/api/download/models/2708928?token=6dad8c346283f3f0023ebc9245848383"

# Text encoder Qwen 3 4B para Z-Image (2560 dim - compatible con Moody ZIT)
# Usar versión BF16 estándar: fp8_mixed puede usar nvfp4 no soportado por flux1-dev
# https://huggingface.co/Comfy-Org/z_image_turbo
RUN curl -L \
    -o /comfyui/models/text_encoders/qwen_3_4b.safetensors \
    "https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/text_encoders/qwen_3_4b.safetensors"

# VAE ae.safetensors ya incluido en la imagen base (compatible Flux/Z-Image)

# Verificación
RUN echo "=== UNET ===" && ls -lh /comfyui/models/unet/ && \
    echo "=== Text encoders (Z-Image) ===" && ls -lh /comfyui/models/text_encoders/