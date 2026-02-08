#!/usr/bin/env bash

set -e

# Rutas
MODELS_DIR="/comfyui/models/checkpoints"
VOLUME_DIR="/runpod-volume/models/checkpoints"   # crea esta estructura en el volumen
MODEL_FILENAME="cyberRealisticPony_v160.safetensors"
MODEL_PATH="$$   {MODELS_DIR}/   $${MODEL_FILENAME}"
VOLUME_MODEL_PATH="$$   {VOLUME_DIR}/   $${MODEL_FILENAME}"

mkdir -p "${MODELS_DIR}"
mkdir -p "${VOLUME_DIR}"

# Si el modelo NO existe en el volumen → descargar (solo la primera vez)
if [ ! -f "${VOLUME_MODEL_PATH}" ]; then
    echo "[INFO] Modelo no encontrado en Network Volume. Descargando una sola vez..."

    if [ -z "${CIVITAI_API_KEY}" ]; then
        echo "[ERROR] Falta CIVITAI_API_KEY en Environment Variables"
        exit 1
    fi

    # Descarga al volumen (usa los métodos que ya tenías)
    wget --content-disposition \
         --header="Authorization: Bearer ${CIVITAI_API_KEY}" \
         -O "${VOLUME_MODEL_PATH}" \
         "https://civitai.com/api/download/models/2581228?type=Model&format=SafeTensor&size=pruned&fp=fp16" || {
        wget -O "$$   {VOLUME_MODEL_PATH}" "https://civitai.com/api/download/models/2581228?type=Model&format=SafeTensor&size=pruned&fp=fp16&token=   $${CIVITAI_API_KEY}"
    }

    echo "[SUCCESS] Modelo descargado al Network Volume"
else
    echo "[INFO] Modelo ya existe en Network Volume"
fi

# Crea symlink para que ComfyUI lo vea en su ruta normal
ln -sfn "$$   {VOLUME_MODEL_PATH}" "   $${MODEL_PATH}"

echo "[DEBUG] Symlink creado: ${MODEL_PATH} -> ${VOLUME_MODEL_PATH}"
ls -lh "${MODELS_DIR}"

# Inicia ComfyUI
echo "[INFO] Iniciando ComfyUI..."
exec /start.sh