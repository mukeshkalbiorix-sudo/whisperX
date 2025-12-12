# Stable RunPod base for WhisperX/pyannote (PyTorch 2.1.1, CUDA 12.1, Python 3.10—avoids NMS bug)
FROM runpod/pytorch:2.1.1-py3.10-cuda12.1.1-devel-ubuntu22.04

WORKDIR /app

# Install system deps (ffmpeg for audio, git for WhisperX install)
RUN apt-get update && apt-get install -y ffmpeg git && rm -rf /var/lib/apt/lists/*

# Upgrade pip
RUN pip install --no-cache-dir --upgrade pip

# Install compatible torch/torchaudio/torchvision (match base to avoid NMS error)
RUN pip install --no-cache-dir torch==2.1.1 torchvision==0.16.1 torchaudio==2.1.1 --index-url https://download.pytorch.org/whl/cu121

# Install core packages with version pins for compatibility
RUN pip install --no-cache-dir lightning-utilities==0.11.2  # Fixes lightning-fabric import
RUN pip install --no-cache-dir torchmetrics==1.3.1  # Stable version without NMS issues
RUN pip install --no-cache-dir git+https://github.com/m-bain/whisperx.git
RUN pip install --no-cache-dir pyannote.audio==3.1.1 runpod flask

# Copy files
COPY handler.py .
# If you have requirements.txt, uncomment: COPY requirements.txt . && pip install -r requirements.txt

EXPOSE 8000

CMD ["python", "handler.py"]
