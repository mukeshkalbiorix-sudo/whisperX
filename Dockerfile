# Use a valid, recent RunPod PyTorch base image (PyTorch 2.4.0, CUDA 12.4.1, Python 3.11, Ubuntu 22.04)
FROM runpod/pytorch:2.4.0-py3.11-cuda12.4.1-devel-ubuntu22.04

# Set working directory
WORKDIR /app

# Copy requirements first for better Docker caching
COPY requirements.txt .

# Install system deps if needed (e.g., for audio handling)
RUN apt-get update && apt-get install -y ffmpeg && rm -rf /var/lib/apt/lists/*

# Install Python packages (no cache to avoid bloat; upgrade pip first)
RUN pip install --no-cache-dir --upgrade pip
RUN pip install --no-cache-dir torch torchaudio --index-url https://download.pytorch.org/whl/cu124
RUN pip install --no-cache-dir git+https://github.com/m-bain/whisperx.git
RUN pip install --no-cache-dir pyannote.audio runpod

# Copy the handler script
COPY handler.py .

# Expose RunPod port
EXPOSE 8000

# Run the handler
CMD ["python", "handler.py"]
