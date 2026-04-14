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

# Checkpoint: https://huggingface.co/mig1234/Juggernaut-XL (juggernautXL_version2.safetensors)
download_if_missing "$CHECKPOINTS_DIR/juggernautXL.safetensors" \
    "https://huggingface.co/mig1234/Juggernaut-XL/resolve/main/juggernautXL_version2.safetensors"

# RunPod serverless: extra_model_paths.yaml ya apunta a /runpod-volume/models/
echo "=== Modelos listos ==="
