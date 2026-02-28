# generateimage.json

Dockerized ComfyUI workflow con Moody Porn Mix ZIT V9.

## Arquitectura: Z-Image (2560 dim), no Flux

Moody Porn Mix ZIT V9 usa arquitectura **Z-Image** con embeddings de **2560 dimensiones**. Es incompatible con Flux (4096 dim). El workflow debe usar el text encoder **Qwen**, no DualCLIPLoader con clip_l + t5xxl.

## Estructura del workflow requerida

Moody Porn Mix **no incluye CLIP/text encoder**. El workflow debe usar nodos separados:

| Nodo | Función | Parámetros |
|------|---------|------------|
| **UNETLoader** | Cargar el modelo de difusión | `unet_name`: `moodyPornMix_zitV9.safetensors` |
| **CLIPLoader** | Cargar text encoder Qwen (Z-Image) | `clip_name`: `qwen_3_4b_fp8_mixed.safetensors`, `type`: `qwen_image` |
| **VAELoader** | Cargar VAE | `ae.safetensors` |
| **CLIPTextEncode** | Codificar prompts | Conectar CLIP del CLIPLoader |

**No usar** DualCLIPLoader + CLIPTextEncodeFlux (Flux) — produce 4096 dim y provoca el error "expected input with shape [*, 2560], but got input of size[1, 256, 4096]".

Guía para Z-Image Turbo: 8–10 steps, CFG 1.0, DPM++ 2M Karras o euler_ancestral.

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
