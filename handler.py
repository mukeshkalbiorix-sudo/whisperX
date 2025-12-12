import os
import json
import runpod  # RunPod SDK for endpoints
import whisperx
import torch
from pyannote.audio import Pipeline  # For diarization

# Env vars (set in RunPod)
HF_TOKEN = os.getenv("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")
WHISPER_MODEL = os.getenv("WHISPER_MODEL", "large-v3")
BATCH_SIZE = int(os.getenv("BATCH_SIZE", 16))
DEVICE = "cuda" if torch.cuda.is_available() else "cpu"

def handler(event):
    try:
        input_data = event["input"]
        audio_url = input_data.get("audio")  # Public URL
        language = input_data.get("language", "en")
        diarize_flag = input_data.get("enable_diarization", True)
        align_flag = input_data.get("enable_timestamps", True)
        task = input_data.get("task", "transcribe")  # Or "translate"

        # Load WhisperX model
        model = whisperx.load_model(WHISPER_MODEL, device=DEVICE, compute_type="float16")

        # Transcribe with VAD
        audio = whisperx.load_audio(audio_url)
        result = model.transcribe(audio, batch_size=BATCH_SIZE, language=language)

        # VAD filter
        vad_model, utils = whisperx.load_vad_model()
        result = whisperx.vad_filter(result, len(audio)/16000, vad_model, utils)

        # Alignment for word timestamps
        if align_flag:
            align_model, metadata = whisperx.load_align_model(language_code=language, device=DEVICE)
            result = whisperx.align(result, align_model, metadata, audio, DEVICE)

        # Diarization
        if diarize_flag and HF_TOKEN:
            diarization_pipeline = Pipeline.from_pretrained("pyannote/speaker-diarization-3.1", use_auth_token=HF_TOKEN)
            diarization = diarization_pipeline(audio_url)
            result = whisperx.assign_word_speakers(diarization, result)

        return {"output": result, "status": "success"}
    except Exception as e:
        return {"error": str(e), "status": "error"}

# RunPod entrypoint
runpod.serverless.start({"handler": handler})
