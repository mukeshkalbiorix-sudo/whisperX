# Stable RunPod base (confirmed valid tag)
FROM runpod/pytorch:2.1.1-py3.10-cuda12.1.1-devel-ubuntu22.04

WORKDIR /app

# Install system dependencies for pyannote compilation (libsndfile, blas, g++, etc.)
RUN apt-get update && apt-get install -y \
    ffmpeg \
    git \
    libsndfile1-dev \
    libblas-dev \
    liblapack-dev \
    g++ \
    cmake \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip and install core PyTorch (match base to avoid conflicts)
RUN pip install --no-cache-dir --upgrade pip
RUN pip install --no-cache-dir torch torchaudio --index-url https://download.pytorch.org/whl/cu121

# Install compatible supporting packages first (fixes hmmlearn/soundfile compilation)
RUN pip install --no-cache-dir numpy==1.24.3 scipy==1.10.1  # Stable for pyannote
RUN pip install --no-cache-dir librosa soundfile hmmlearn  # Core audio deps

# Install WhisperX from git
RUN pip install --no-cache-dir git+https://github.com/m-bain/whisperx.git

# Install pyannote.audio from develop branch (recommended for fixes; no pin to avoid build fails)
RUN pip install --no-cache-dir "git+https://github.com/pyannote/pyannote-audio.git"

# Install RunPod and Flask last
RUN pip install --no-cache-dir runpod flask

# Copy handler
COPY handler.py .

EXPOSE 8000

CMD ["python", "handler.py"]
