# Proven stable RunPod base for WhisperX/pyannote (PyTorch 2.3.0, CUDA 12.1)
FROM runpod/pytorch:2.3.0-py3.10-cuda12.1.1-devel-ubuntu22.04

WORKDIR /app

# Install ffmpeg for audio handling
RUN apt-get update && apt-get install -y ffmpeg && rm -rf /var/lib/apt/lists/*

# Upgrade pip and install compatible versions
RUN pip install --no-cache-dir --upgrade pip

# Install matching torch/torchaudio (from base) + explicit torchvision
RUN pip install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121

# Install WhisperX from git + pyannote + runpod
RUN pip install --no-cache-dir git+https://github.com/m-bain/whisperx.git
RUN pip install --no-cache-dir pyannote.audio runpod flask  # Flask for health checks

# Copy files
COPY handler.py .
COPY requirements.txt .  # If you have one

EXPOSE 8000

CMD ["python", "handler.py"]
