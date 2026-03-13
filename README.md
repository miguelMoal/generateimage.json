# generateimage.json

Dockerized ComfyUI workflow para RunPod serverless.

## Contenido

- `Dockerfile` - Configuración del contenedor
- `download-models.sh` - Descarga modelos solo si no existen (en volumen)
- `entrypoint.sh` - Wrapper que ejecuta la descarga antes del worker
- `example-request.json` - Payload de ejemplo para la API

## Despliegue en RunPod Serverless

1. **Crear un Network Volume** en RunPod (para persistir los modelos).

2. **Build y push** de la imagen a un registro accesible por RunPod.

3. **Configurar el endpoint**:
   - Crear un Serverless Endpoint
   - Adjuntar el Network Volume en *Advanced settings → Network Volumes*
   - El volumen se monta automáticamente en `/runpod-volume`

4. **Comportamiento**:
   - Primera ejecución: descarga los modelos a `/runpod-volume/models/`
   - Siguientes ejecuciones: detecta modelos existentes y omite la descarga
   - Sin volumen adjunto: usa `/comfyui/models` (sin persistencia)

## Uso local

```bash
docker build -t generateimage.json .
docker run -p 8188:8188 -v mi-volumen:/runpod-volume generateimage.json
```

## API

Ver `example-request.json` para un ejemplo de payload.
