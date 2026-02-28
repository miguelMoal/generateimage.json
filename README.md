# generateimage.json

Dockerized ComfyUI workflow con Moody Porn Mix ZIT V9.

## Estructura del workflow requerida

Moody Porn Mix **no incluye CLIP/text encoder**. El workflow debe usar nodos separados:

| Nodo | Función | Parámetros |
|------|---------|------------|
| **UNETLoader** (o Load Diffusion Model) | Cargar el modelo de difusión | `unet_name`: `moodyPornMix_zitV9.safetensors` |
| **DualCLIPLoader** | Cargar encoders de texto Flux | clip_l + t5xxl (incluidos en la imagen) |
| **VAELoader** | Cargar VAE | `ae.safetensors` |
| **CLIPTextEncodeFlux** | Codificar prompts | Conectar ambos CLIP del DualCLIPLoader |

**No usar** CheckpointLoaderSimple con Moody — devolvería CLIP = None y provocará el error "clip input is invalid: None".

Guía para Flux: 7–15 guidance, 25–35 steps, DPM++ 2M, hi-res fix 2x recomendado.

## Contents

- `Dockerfile` - Docker container configuration for running this ComfyUI workflow
- `example-request.json` - Example API request payload for testing

## Usage

```bash
# Build the Docker image
docker build -t generateimage.json .

# Run the container
docker run -p 8188:8188 generateimage.json
```

## API Request Example

See `example-request.json` for a ready-to-use API request payload.
