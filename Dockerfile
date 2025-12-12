FROM runpod/pytorch:2.3.0-py3.10-cuda12.1.1-devel-ubuntu22.04

WORKDIR /app
COPY . /app

# Install deps (from WhisperX requirements.txt)
RUN pip install --no-cache-dir torch torchaudio --index-url https://download.pytorch.org/whl/cu121
RUN pip install --no-cache-dir git+https://github.com/m-bain/whisperx.git
RUN pip install --no-cache-dir pyannote.audio

# Expose port
EXPOSE 8000

CMD ["python", "handler.py"]
