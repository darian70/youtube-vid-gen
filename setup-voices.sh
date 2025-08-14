#!/bin/bash
set -e

echo "Setting up Piper TTS voices..."

# Create piper_data directory if it doesn't exist
mkdir -p piper_data

# Download the en_US-lessac-medium voice model and config
echo "Downloading en_US-lessac-medium voice..."
curl -L -o piper_data/en_US-lessac-medium.onnx \
  "https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US/lessac/medium/en_US-lessac-medium.onnx"

curl -L -o piper_data/en_US-lessac-medium.onnx.json \
  "https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US/lessac/medium/en_US-lessac-medium.onnx.json"

# Download a backup voice (amy-low for faster processing)
echo "Downloading en_US-amy-low backup voice..."
curl -L -o piper_data/en_US-amy-low.onnx \
  "https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US/amy/low/en_US-amy-low.onnx"

curl -L -o piper_data/en_US-amy-low.onnx.json \
  "https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US/amy/low/en_US-amy-low.onnx.json"

echo "Voice setup complete!"
echo "Available voices:"
ls -la piper_data/*.onnx
