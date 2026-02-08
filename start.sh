#!/usr/bin/env bash

set -euo pipefail  # Mejora la robustez: error en variables no definidas y pipes

# ────────────────────────────────────────────────────────────────
# CONFIGURACIÓN - Rutas y nombre del modelo
# ────────────────────────────────────────────────────────────────
readonly VOLUME_BASE="/runpod-volume"
readonly VOLUME_MODELS_DIR="${VOLUME_BASE}/models/checkpoints"
readonly COMFY_MODELS_DIR="/comfyui/models/checkpoints"

readonly MODEL_FILENAME="cyberRealisticPony_v160.safetensors"
readonly VOLUME_MODEL_PATH="${VOLUME_MODELS_DIR}/${MODEL_FILENAME}"
readonly COMFY_MODEL_PATH="${COMFY_MODELS_DIR}/${MODEL_FILENAME}"

readonly DOWNLOAD_URL="https://civitai.com/api/download/models/2581228?type=Model&format=SafeTensor&size=pruned&fp=fp16"

# ────────────────────────────────────────────────────────────────
# Preparar directorios
# ────────────────────────────────────────────────────────────────
mkdir -p "${COMFY_MODELS_DIR}" "${VOLUME_MODELS_DIR}"

echo "[START] Iniciando script de arranque - $(date '+%Y-%m-%d %H:%M:%S')"

# ────────────────────────────────────────────────────────────────
# Verificar / Descargar modelo (solo la primera vez)
# ────────────────────────────────────────────────────────────────
if [ -f "${VOLUME_MODEL_PATH}" ]; then
    echo "[INFO] Modelo ya existe en Network Volume"
    echo "       → ${VOLUME_MODEL_PATH}"
    echo "       → Tamaño: $(du -h "${VOLUME_MODEL_PATH}" | cut -f1)"
else
    echo "[INFO] Modelo NO encontrado en Network Volume"
    echo "       → Descargando una sola vez a: ${VOLUME_MODEL_PATH}"

    if [ -z "${CIVITAI_API_KEY:-}" ]; then
        echo "[ERROR] Variable CIVITAI_API_KEY no está definida"
        echo "        → Agrega en RunPod Serverless > Settings > Environment Variables"
        echo "        → Key: CIVITAI_API_KEY    Value: tu-api-key-de-civitai"
        exit 1
    fi

    echo "[INFO] Iniciando descarga autenticada..."

    # Intento 1: usando header Authorization Bearer (recomendado)
    if wget --content-disposition \
            --header="Authorization: Bearer ${CIVITAI_API_KEY}" \
            --show-progress \
            -O "${VOLUME_MODEL_PATH}" \
            "${DOWNLOAD_URL}"; then
        echo "[SUCCESS] Descarga completada (método Bearer)"
    else
        # Intento 2: fallback con parámetro ?token=
        echo "[WARN] Método Bearer falló → intentando con ?token=..."
        if wget --content-disposition \
                --show-progress \
                -O "${VOLUME_MODEL_PATH}" \
                "${DOWNLOAD_URL}&token=${CIVITAI_API_KEY}"; then
            echo "[SUCCESS] Descarga completada (método ?token=)"
        else
            echo "[ERROR] Falló la descarga en ambos métodos"
            echo "        → Verifica tu API key y conexión"
            echo "        → Tamaño esperado: ~2-8 GB (pruned fp16)"
            exit 1
        fi
    fi

    echo "[INFO] Archivo descargado:"
    ls -lh "${VOLUME_MODEL_PATH}"
fi

# ────────────────────────────────────────────────────────────────
# Crear symlink para que ComfyUI lo encuentre
# ────────────────────────────────────────────────────────────────
ln -sfn "${VOLUME_MODEL_PATH}" "${COMFY_MODEL_PATH}"

if [ -L "${COMFY_MODEL_PATH}" ] && [ "$(readlink -f "${COMFY_MODEL_PATH}")" = "${VOLUME_MODEL_PATH}" ]; then
    echo "[SUCCESS] Symlink creado correctamente"
    echo "          ${COMFY_MODEL_PATH} → ${VOLUME_MODEL_PATH}"
else
    echo "[ERROR] Falló al crear el symlink"
    exit 1
fi

# Debug rápido
echo "[DEBUG] Contenido de checkpoints en ComfyUI:"
ls -lh "${COMFY_MODELS_DIR}"

# ────────────────────────────────────────────────────────────────
# Iniciar el worker de RunPod / ComfyUI
# ────────────────────────────────────────────────────────────────
echo "[INFO] Finalizando script de arranque - iniciando ComfyUI..."
echo "────────────────────────────────────────────────────────────────"

exec /start.sh