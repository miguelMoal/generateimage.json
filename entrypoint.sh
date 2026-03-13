#!/bin/bash
set -e

# Descargar modelos solo si no existen (en /runpod-volume por defecto en RunPod serverless)
/download-models.sh

# Ejecutar el comando original del worker
exec "$@"
