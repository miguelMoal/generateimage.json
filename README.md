# Moody Porn Mix (ZIT V9) - RunPod Serverless

Despliegue del modelo [Moody Porn Mix ZIT V9](https://civitai.com/models/620406/moody-porn-mix) en RunPod Serverless con ComfyUI.

## Requisitos

- Cuenta en [RunPod](https://www.runpod.io/)
- Token de CivitAI para descargar el modelo (crear en [CivitAI User Account](https://civitai.com/user/account))
- Repositorio Git (GitHub, GitLab, etc.)

## Despliegue desde Git (RunPod)

1. **Prepara el token de CivitAI**
   - Ve a https://civitai.com/user/account
   - Crea un API token
   - Guárdalo de forma segura

2. **En RunPod Console**
   - Ve a [Serverless → New Endpoint](https://console.runpod.io/serverless/new-endpoint)
   - Selecciona **"GitHub Repo"** como origen
   - Conecta tu cuenta de GitHub y elige este repositorio
   - En **Build Arguments** añade:
     - `CIVITAI_TOKEN`: tu token de CivitAI
   - Configura GPU recomendada: **RTX 4090** o **A100** (24GB+ VRAM)
   - Click **Deploy Endpoint**

3. **Build manual con Docker**

   ```bash
   docker build \
     --build-arg CIVITAI_TOKEN=tu_token_aqui \
     -t moody-zit-runpod:latest .
   ```

   Luego sube la imagen a tu registry y crea el endpoint en RunPod apuntando a esa imagen.

## Uso de la API

El endpoint expone la API estándar de RunPod Serverless. Ejemplo con `test_input.json`:

```bash
curl -X POST https://api.runpod.ai/v2/TU_ENDPOINT_ID/runsync \
  -H "Authorization: Bearer TU_RUNPOD_API_KEY" \
  -H "Content-Type: application/json" \
  -d @test_input.json
```

### Text-to-Image (txt2img)

Modifica el nodo `"27"` (CLIPTextEncode) en el workflow para cambiar el prompt:

```json
"27": {
  "inputs": {
    "clip": ["30", 0],
    "text": "tu prompt aqui, 19 years old woman, photorealistic..."
  },
  ...
}
```

### Image-to-Image (img2img)

Genera variaciones a partir de una imagen de entrada. Usa `test_input_img2img.json`:

```bash
curl -X POST https://api.runpod.ai/v2/TU_ENDPOINT_ID/runsync \
  -H "Authorization: Bearer TU_RUNPOD_API_KEY" \
  -H "Content-Type: application/json" \
  -d @test_input_img2img.json
```

- **Imagen de entrada**: Envía la imagen en `input.images[0]` con `name: "input.png"` y `image` en base64.
- **Denoise**: Controla cuánto cambia la imagen (nodo `"10"`). `0.35` = cambio moderado; `0.1` = cambio suave; `0.5` = cambio fuerte.
- **Prompt**: Edita el nodo `"6"` para el prompt positivo.

### Parámetros recomendados (Z-Image-Turbo)

- **Steps**: 6-8 (no más; es un modelo turbo)
- **CFG**: 1.0
- **Resolución**: hasta 2048x2048
- **Img2img denoise**: 0.1–0.4 (menor = más fiel a la imagen original)

## Archivos

- `Dockerfile`: Imagen basada en `runpod/worker-comfyui:z-image-turbo` + descarga del modelo Moody
- `workflow_zit.json`: Workflow text-to-image
- `workflow_img2img.json`: Workflow image-to-image
- `test_input.json`: Ejemplo txt2img
- `test_input_img2img.json`: Ejemplo img2img (incluye imagen placeholder; reemplaza con tu imagen en base64)

## Modelo

- **Nombre**: Moody Porn Mix ZIT V9
- **Base**: ZImageTurbo
- **CivitAI**: https://civitai.com/models/620406/moody-porn-mix
- **Formato**: SafeTensors (~12GB)
- **NSFW**: El modelo genera contenido adulto. Requiere token de CivitAI para descarga.
