#!/usr/bin/env bash

set -e

# ────────────────────────────────────────────────
# Configuración del modelo (ajústalo si cambias de modelo)
# ────────────────────────────────────────────────
MODEL_DIR="/comfyui/models/checkpoints"
MODEL_FILENAME="cyberrealistic_pony_v16.safetensors"   # Nombre que tendrá el archivo (puedes cambiarlo)
MODEL_PATH="${MODEL_DIR}/${MODEL_FILENAME}"

# URL de descarga directa (la que proporcionaste)
DOWNLOAD_URL="https://civitai.com/api/download/models/2581228?type=Model&format=SafeTensor&size=pruned&fp=fp16"

# Crea el directorio si no existe
mkdir -p "${MODEL_DIR}"

# ────────────────────────────────────────────────
# Descarga solo si el archivo NO existe
# ────────────────────────────────────────────────
if [ ! -f "${MODEL_PATH}" ]; then
    echo "=============================================================="
    echo "Modelo no encontrado. Iniciando descarga desde Civitai..."
    echo "=============================================================="

    if [ -z "${CIVITAI_TOKEN}" ]; then
        echo "ERROR: La variable de entorno CIVITAI_TOKEN no está definida."
        echo "Ve a RunPod → tu Endpoint → Settings → Environment Variables"
        echo "y agrega: CIVITAI_TOKEN = tu-api-key-de-civitai"
        exit 1
    fi

    echo "Usando CIVITAI_TOKEN para autenticación..."

    # Intentamos con header Authorization (más confiable en algunos casos)
    wget --content-disposition \
         --header="Authorization: Bearer ${CIVITAI_TOKEN}" \
         -O "${MODEL_PATH}" \
         "${DOWNLOAD_URL}" && {
        echo "Descarga exitosa usando Bearer token"
    } || {
        # Fallback: método más común (?token=...)
        echo "Bearer falló, intentando con ?token=..."
        wget --content-disposition \
             -O "${MODEL_PATH}" \
             "${DOWNLOAD_URL}&token=${CIVITAI_TOKEN}" && {
            echo "Descarga exitosa con ?token="
        } || {
            echo "ERROR: Falló la descarga. Verifica:"
            echo "1. Que el CIVITAI_TOKEN sea correcto"
            echo "2. Que el modelo requiera login (prueba manual en navegador)"
            exit 1
        }
    }

    echo "Descarga completada. Tamaño del archivo:"
    ls -lh "${MODEL_PATH}"
else
    echo "El modelo ya existe: ${MODEL_PATH}"
    echo "Saltando descarga."
fi

# Opcional: mostrar qué hay en la carpeta para debug
echo "Contenido de checkpoints:"
ls -lh "${MODEL_DIR}"

# ────────────────────────────────────────────────
# Ejecuta el entrypoint original de la imagen base
# (esto inicia ComfyUI + el worker de RunPod)
# ────────────────────────────────────────────────
echo "Iniciando ComfyUI / RunPod worker..."
exec /start.sh