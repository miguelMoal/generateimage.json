#!/bin/bash
set -e

# RunPod serverless: el volumen de red se monta en /runpod-volume por defecto
# Si no hay volumen, fallback a /comfyui/models (sin persistencia)
if [ -d /runpod-volume ]; then
    MODELS_BASE="${MODELS_PATH:-/runpod-volume/models}"
else
    MODELS_BASE="${MODELS_PATH:-/comfyui/models}"
fi
CHECKPOINTS_DIR="${MODELS_BASE}/checkpoints"
VAE_DIR="${MODELS_BASE}/vae"

download_if_missing() {
    local filepath="$1"
    local url="$2"
    local dir
    dir=$(dirname "$filepath")
    mkdir -p "$dir"
    if [ ! -f "$filepath" ] || [ ! -s "$filepath" ]; then
        echo "Descargando $(basename "$filepath")..."
        curl -L -f -o "$filepath" "$url" || { echo "Error descargando $filepath"; exit 1; }
    else
        echo "Modelo existente, omitiendo: $(basename "$filepath")"
    fi
}

echo "=== Comprobando modelos (volumen: $MODELS_BASE) ==="

# Checkpoints
download_if_missing "$CHECKPOINTS_DIR/juggernautXL.safetensors" \
    "https://civitai.com/api/download/models/1759168?type=Model&format=SafeTensor&size=full&fp=fp16"
download_if_missing "$CHECKPOINTS_DIR/DreamShaper.safetensors" \
    "https://civitai.com/api/download/models/128713?type=Model&format=SafeTensor&size=pruned&fp=fp16"
download_if_missing "$CHECKPOINTS_DIR/RealVisXL.safetensors" \
    "https://civitai.com/api/download/models/798204?type=Model&format=SafeTensor&size=full&fp=fp16"
download_if_missing "$CHECKPOINTS_DIR/animagine-xl-v31.safetensors" \
    "https://civitai.com/api/download/models/403131?type=Model&format=SafeTensor&size=full&fp=fp16&token=33e893cf7d1a8522a05809bd10d6ac55"

# VAE
download_if_missing "$VAE_DIR/animagine-xl-v31.vae.safetensors" \
    "https://civitai.com/api/download/models/403131?type=VAE&format=SafeTensor&token=33e893cf7d1a8522a05809bd10d6ac55"

# RunPod serverless: extra_model_paths.yaml ya apunta a /runpod-volume/models/
echo "=== Modelos listos ==="
