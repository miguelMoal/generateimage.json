#!/usr/bin/env bash

set -e  # Salir si algún comando falla

# ───────────────────────────────────────────────────────────────
# Configuración del modelo (CyberRealistic Pony v16.0)
# ───────────────────────────────────────────────────────────────
MODEL_DIR="/comfyui/models/checkpoints"
MODEL_FILENAME="cyberRealisticPony_v160.safetensors"   # Nombre limpio y descriptivo
MODEL_PATH="${MODEL_DIR}/${MODEL_FILENAME}"

# URL exacta que proporcionaste (incluye parámetros de tipo, formato y precisión)
DOWNLOAD_URL="https://civitai.com/api/download/models/2581228?type=Model&format=SafeTensor&size=pruned&fp=fp16"

# Crea el directorio si no existe
mkdir -p "${MODEL_DIR}"

# ───────────────────────────────────────────────────────────────
# Descarga solo si el archivo NO existe ya
# ───────────────────────────────────────────────────────────────
if [ ! -f "${MODEL_PATH}" ]; then
    echo "=============================================================="
    echo "[INFO] Modelo CyberRealistic Pony v16.0 no encontrado."
    echo "[INFO] Iniciando descarga autenticada desde Civitai..."
    echo "=============================================================="

    if [ -z "${CIVITAI_API_KEY}" ]; then
        echo "[ERROR] La variable CIVITAI_API_KEY no está definida."
        echo "  → Ve a RunPod → tu Endpoint → Settings → Environment Variables"
        echo "  → Agrega: Key = CIVITAI_API_KEY    Value = tu-api-key-de-civitai"
        echo "Genera el key aquí: https://civitai.com/user/account"
        exit 1
    fi

    echo "[INFO] Usando CIVITAI_API_KEY para autenticación..."

    # Método 1: Bearer token (recomendado por Civitai docs)
    echo "[INFO] Intentando con Authorization: Bearer..."
    if wget --content-disposition \
           --header="Authorization: Bearer ${CIVITAI_API_KEY}" \
           -O "${MODEL_PATH}" \
           "${DOWNLOAD_URL}"; then
        echo "[SUCCESS] Descarga completada usando Bearer token"
    else
        # Método 2: fallback con ?token= (muy común y suele funcionar)
        echo "[WARN] Bearer falló → intentando con ?token=..."
        if wget --content-disposition \
               -O "${MODEL_PATH}" \
               "${DOWNLOAD_URL}&token=${CIVITAI_API_KEY}"; then
            echo "[SUCCESS] Descarga completada usando ?token="
        else
            echo "[ERROR] Falló la descarga después de ambos métodos."
            echo "  Verifica:"
            echo "  1. El API key es correcto y tiene permisos"
            echo "  2. El modelo requiere login (prueba manual en tu navegador)"
            echo "  3. Conexión a internet / espacio en disco"
            exit 1
        fi
    fi

    echo "[INFO] Descarga terminada. Tamaño del archivo:"
    ls -lh "${MODEL_PATH}"
else
    echo "[INFO] El modelo ya existe: ${MODEL_PATH}"
    echo "[INFO] Saltando descarga."
fi

# Debug: mostrar contenido de la carpeta
echo "[DEBUG] Contenido actual de checkpoints:"
ls -lh "${MODEL_DIR}"

# ───────────────────────────────────────────────────────────────
# Inicia el worker de RunPod / ComfyUI (entrypoint original)
# ───────────────────────────────────────────────────────────────
echo "[INFO] Iniciando ComfyUI + RunPod worker..."
exec /start.sh