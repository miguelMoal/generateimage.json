# clean base image containing only comfyui, comfy-cli and comfyui-manager
FROM runpod/worker-comfyui:5.5.1-base

# install custom nodes into comfyui (first node with --mode remote to fetch updated cache)
# Could not resolve unknown_registry node CheckpointLoaderSimple (no aux_id provided) - skipped

# download models into comfyui
RUN comfy model download --url https://huggingface.co/modelzpalace/juggernautXL_ragnarok/blob/main/juggernautXL_ragnarokBy.safetensors --relative-path models/checkpoints --filename juggernautXL_ragnarokBy.safetensors

# copy all input data (like images or videos) into comfyui (uncomment and adjust if needed)
# COPY input/ /comfyui/input/
