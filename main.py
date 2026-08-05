from __future__ import annotations

import base64
import json
import os
import socket
import subprocess
import time
import uuid
from pathlib import Path

import modal
import requests
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

APP_NAME = "main"
COMFY_HOST = "127.0.0.1:8188"
COMFY_PORT = 8188
COMFY_ROOT = Path("/root/comfy/ComfyUI")
CHECKPOINTS_DIR = COMFY_ROOT / "models" / "checkpoints"
INPUT_DIR = COMFY_ROOT / "input"

GPU_TYPE = os.environ.get("MODAL_GPU", "L40S")
MODEL_FILENAME = "Qwen-Rapid-AIO-v23.safetensors"
MODEL_HF_FILE = "v23/Qwen-Rapid-AIO-NSFW-v23.safetensors"

root_dir = Path(__file__).parent
vol = modal.Volume.from_name("qwen-rapid-aio-cache", create_if_missing=True)


def download_model():
    from huggingface_hub import hf_hub_download

    cached = hf_hub_download(
        repo_id="Phr00t/Qwen-Image-Edit-Rapid-AIO",
        filename=MODEL_HF_FILE,
        cache_dir="/cache",
    )

    CHECKPOINTS_DIR.mkdir(parents=True, exist_ok=True)
    target = CHECKPOINTS_DIR / MODEL_FILENAME
    if target.exists() or target.is_symlink():
        target.unlink()
    target.symlink_to(cached)
    print(f"Model ready at {target}")


image = (
    modal.Image.debian_slim(python_version="3.11")
    .apt_install("git", "git-lfs", "libgl1-mesa-dev", "libglib2.0-0", "wget")
    .pip_install(
        "comfy-cli",
        "huggingface_hub[hf_transfer]",
        "fastapi",
        "websocket-client",
        "requests",
    )
    .env({"HF_HUB_ENABLE_HF_TRANSFER": "1"})
    .run_commands("comfy --skip-prompt install --nvidia --version latest")
    .run_commands(
        "wget -q -O /root/comfy/ComfyUI/comfy_extras/nodes_qwen.py "
        "https://huggingface.co/Phr00t/Qwen-Image-Edit-Rapid-AIO/resolve/main/"
        "fixed-textencode-node/nodes_qwen.v2.py"
    )
    .add_local_file(
        str(root_dir / "workflow_t2i.json"),
        "/root/workflow_api.json",
        copy=True,
    )
    .run_commands("comfy node install-deps --workflow=/root/workflow_api.json")
    .run_function(download_model, volumes={"/cache": vol})
)

app = modal.App(APP_NAME, image=image)
web_app = FastAPI()
web_app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
    expose_headers=["*"],
)


def wait_for_port(port: int, timeout: int = 300) -> None:
    deadline = time.time() + timeout
    while time.time() < deadline:
        try:
            with socket.create_connection(("127.0.0.1", port), timeout=1):
                return
        except OSError:
            time.sleep(0.5)
    raise TimeoutError(f"ComfyUI no respondió en el puerto {port}")


def validate_input(job_input: dict) -> tuple[dict | None, str | None]:
    workflow = job_input.get("workflow")
    if workflow is None:
        return None, "Missing 'workflow' parameter"

    images = job_input.get("images")
    if images is not None:
        if not isinstance(images, list) or not all(
            isinstance(image, dict) and "name" in image and "image" in image
            for image in images
        ):
            return None, "'images' must be a list of objects with 'name' and 'image' keys"

    return {
        "workflow": workflow,
        "images": images,
        "comfy_org_api_key": job_input.get("comfy_org_api_key"),
    }, None


def upload_images(images: list[dict]) -> dict:
    if not images:
        return {"status": "success", "details": []}

    details = []
    for image in images:
        name = image["name"]
        image_data_uri = image["image"]
        if "," in image_data_uri:
            base64_data = image_data_uri.split(",", 1)[1]
        else:
            base64_data = image_data_uri

        blob = base64.b64decode(base64_data)
        response = requests.post(
            f"http://{COMFY_HOST}/upload/image",
            files={"image": (name, blob)},
            data={"overwrite": "true"},
            timeout=60,
        )
        if response.status_code != 200:
            details.append({"name": name, "error": response.text})
        else:
            details.append({"name": name, "status": "success"})

    if any("error" in detail for detail in details):
        return {"status": "error", "details": details}
    return {"status": "success", "details": details}


def queue_workflow(workflow: dict, client_id: str, comfy_org_api_key: str | None = None) -> dict:
    headers = {"Content-Type": "application/json"}
    if comfy_org_api_key:
        headers["X-API-Key"] = comfy_org_api_key

    response = requests.post(
        f"http://{COMFY_HOST}/prompt",
        json={"prompt": workflow, "client_id": client_id},
        headers=headers,
        timeout=60,
    )
    if response.status_code != 200:
        raise ValueError(f"Error queuing workflow: {response.text}")
    return response.json()


def get_history(prompt_id: str) -> dict:
    response = requests.get(f"http://{COMFY_HOST}/history/{prompt_id}", timeout=60)
    response.raise_for_status()
    return response.json()


def wait_for_completion(prompt_id: str, timeout: int = 900) -> tuple[bool, list[str]]:
    deadline = time.time() + timeout
    errors: list[str] = []

    while time.time() < deadline:
        try:
            history = get_history(prompt_id)
        except requests.RequestException:
            time.sleep(1)
            continue

        if prompt_id not in history:
            time.sleep(1)
            continue

        prompt_history = history[prompt_id]
        status = prompt_history.get("status", {})
        if status.get("completed"):
            return True, errors

        for message in status.get("messages", []):
            if (
                isinstance(message, list)
                and len(message) >= 2
                and message[0] == "execution_error"
            ):
                errors.append(str(message[1]))
                return False, errors

        if prompt_history.get("outputs"):
            return True, errors

        time.sleep(1)

    return False, ["Workflow did not finish within timeout"]


def get_image_data(filename: str, subfolder: str, image_type: str) -> bytes | None:
    params = {"filename": filename, "subfolder": subfolder, "type": image_type}
    response = requests.get(f"http://{COMFY_HOST}/view", params=params, timeout=60)
    if response.status_code == 200:
        return response.content
    return None


def run_workflow(job_input: dict) -> dict:
    validated_data, error_message = validate_input(job_input)
    if error_message:
        return {"error": error_message}

    workflow = validated_data["workflow"]
    input_images = validated_data.get("images")

    if input_images:
        upload_result = upload_images(input_images)
        if upload_result["status"] == "error":
            return {
                "error": "Failed to upload one or more input images",
                "details": upload_result["details"],
            }

    client_id = str(uuid.uuid4())

    queued = queue_workflow(
        workflow,
        client_id,
        comfy_org_api_key=validated_data.get("comfy_org_api_key"),
    )
    prompt_id = queued.get("prompt_id")
    if not prompt_id:
        raise ValueError(f"Missing 'prompt_id' in queue response: {queued}")

    execution_done, errors = wait_for_completion(prompt_id)
    if not execution_done:
        if errors:
            return {"error": "Job processing failed", "details": errors}
        return {"error": "Workflow did not finish within timeout"}

    history = get_history(prompt_id)
    if prompt_id not in history:
        if errors:
            return {"error": "Job processing failed", "details": errors}
        return {"error": f"Prompt ID {prompt_id} not found in history"}

    outputs = history[prompt_id].get("outputs", {})
    output_data: list[dict] = []

    for node_output in outputs.values():
        if "images" not in node_output:
            continue
        for image_info in node_output["images"]:
            filename = image_info.get("filename")
            subfolder = image_info.get("subfolder", "")
            img_type = image_info.get("type")
            if img_type == "temp" or not filename:
                continue

            image_bytes = get_image_data(filename, subfolder, img_type)
            if not image_bytes:
                errors.append(f"Failed to fetch image data for {filename}")
                continue

            output_data.append(
                {
                    "filename": filename,
                    "type": "base64",
                    "data": base64.b64encode(image_bytes).decode("utf-8"),
                }
            )

    if not output_data and errors:
        return {"error": "Job processing failed", "details": errors}

    result: dict = {"images": output_data}
    if errors:
        result["errors"] = errors
    if not output_data:
        result["status"] = "success_no_images"
    return result


@app.cls(
    gpu=GPU_TYPE,
    volumes={"/cache": vol},
    scaledown_window=120,
    timeout=1800,
    enable_memory_snapshot=True,
    experimental_options={"enable_gpu_snapshot": True},
)
@modal.concurrent(max_inputs=5)
class QwenComfyWorker:
    @modal.enter(snap=True)
    def start_comfy(self):
        INPUT_DIR.mkdir(parents=True, exist_ok=True)
        self.proc = subprocess.Popen(
            [
                "comfy",
                "launch",
                "--",
                "--listen",
                "0.0.0.0",
                "--port",
                str(COMFY_PORT),
            ],
            cwd=str(COMFY_ROOT),
        )
        wait_for_port(COMFY_PORT, timeout=600)

    @modal.enter(snap=False)
    def restore_comfy(self):
        wait_for_port(COMFY_PORT, timeout=60)

    @modal.method()
    def infer(self, job_input: dict) -> dict:
        return run_workflow(job_input)

    @modal.exit()
    def cleanup(self):
        proc = getattr(self, "proc", None)
        if proc is not None:
            proc.terminate()


@web_app.get("/health")
async def health():
    try:
        response = requests.get(f"http://{COMFY_HOST}/", timeout=5)
        return {"status": "ok", "comfyui": response.status_code == 200}
    except requests.RequestException as exc:
        return JSONResponse(
            status_code=503,
            content={"status": "error", "detail": str(exc)},
        )


@web_app.post("/runsync")
async def runsync(body: dict):
    job_input = body.get("input")
    if job_input is None:
        raise HTTPException(status_code=400, detail="Missing 'input' field")

    try:
        result = QwenComfyWorker().infer.remote(job_input)
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc

    if "error" in result:
        raise HTTPException(status_code=500, detail=result)
    return {"status": "COMPLETED", "output": result}


@web_app.post("/")
async def root(body: dict):
    return await runsync(body)


@app.function(
    image=image,
    volumes={"/cache": vol},
    scaledown_window=60,
)
@modal.asgi_app()
def api():
    return web_app


@app.function(
    image=image,
    gpu=GPU_TYPE,
    volumes={"/cache": vol},
    scaledown_window=120,
    timeout=1800,
)
@modal.concurrent(max_inputs=10)
@modal.web_server(COMFY_PORT, startup_timeout=600)
def ui():
    INPUT_DIR.mkdir(parents=True, exist_ok=True)
    subprocess.Popen(
        [
            "comfy",
            "launch",
            "--",
            "--listen",
            "0.0.0.0",
            "--port",
            str(COMFY_PORT),
        ],
        cwd=str(COMFY_ROOT),
    )
