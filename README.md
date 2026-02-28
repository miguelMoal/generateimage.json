# Qwen-Image-Edit-Rapid-AIO v23 para RunPod Serverless

Implementación del modelo [Phr00t/Qwen-Image-Edit-Rapid-AIO v23](https://huggingface.co/Phr00t/Qwen-Image-Edit-Rapid-AIO/tree/main/v23) para RunPod Serverless con ComfyUI.

## Características del modelo

- **Text-to-Image** y **Image-to-Image** en un solo checkpoint
- 4 pasos con 1 CFG (optimizado Lightning)
- FP8, ~28 GB por variante
- Variantes: **SFW** (por defecto) y **NSFW**

## Despliegue desde Git (RunPod)

1. Sube este repositorio a GitHub
2. En [RunPod Console](https://www.runpod.io/console/serverless) → **New Endpoint**
3. Elige **Import Git Repository** y enlaza tu repo
4. Configuración recomendada:
   - **GPU**: RTX 4090 o superior (24GB+ VRAM)
   - **Dockerfile path**: `Dockerfile` (raíz)
   - **Container Disk**: 50 GB mínimo

## Build local (opcional)

```bash
# Variante SFW (por defecto)
docker build -t qwen-rapid-aio-runpod .

# Variante NSFW
docker build --build-arg QWEN_MODEL_VARIANT=nsfw -t qwen-rapid-aio-runpod-nsfw .
```

## Uso de la API

### Text-to-Image

Modifica el workflow antes de enviar para cambiar el prompt (nodo `4`) o seed (nodo `7`):

```bash
# Ejemplo: prompt en nodo 4, seed en nodo 7
WORKFLOW=$(jq '. "4".inputs.prompt = "un gato astronauta en Marte" | ."7".inputs.seed = 12345' workflow_t2i.json)

curl -X POST \
  -H "Authorization: Bearer $RUNPOD_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"input\": {\"workflow\": $WORKFLOW}}" \
  https://api.runpod.ai/v2/YOUR_ENDPOINT_ID/runsync
```

### Image-to-Image

Incluye la imagen de entrada en `images`. El workflow espera `input.png`:

```bash
WORKFLOW=$(jq '. "4".inputs.prompt = "cambiar el fondo a una playa"' workflow_img2img.json)

curl -X POST \
  -H "Authorization: Bearer $RUNPOD_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{
    \"input\": {
      \"workflow\": $WORKFLOW,
      \"images\": [{
        \"name\": \"input.png\",
        \"image\": \"data:image/png;base64,...\"
      }]
    }
  }" \
  https://api.runpod.ai/v2/YOUR_ENDPOINT_ID/runsync
```

### Nodos modificables

| Nodo | Inputs | Descripción |
|------|--------|-------------|
| 4 | `prompt` | Prompt principal (positivo) |
| 5 | `width`, `height` | Resolución (1024x1024 por defecto) |
| 7 | `seed`, `steps`, `cfg` | Sampling |

## Estructura de la respuesta

```json
{
  "id": "...",
  "status": "COMPLETED",
  "output": {
    "images": [
      {
        "filename": "Qwen_Rapid_AIO_00001_.png",
        "type": "base64",
        "data": "..."
      }
    ]
  }
}
```

## Referencias

- [Modelo en Hugging Face](https://huggingface.co/Phr00t/Qwen-Image-Edit-Rapid-AIO)
- [RunPod Serverless](https://docs.runpod.io/serverless/)
- [worker-comfyui](https://github.com/runpod-workers/worker-comfyui)
