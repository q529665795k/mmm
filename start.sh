#!/bin/bash
apt update -y
apt install -y curl
curl -fsSL https://ollama.com/install.sh | sh
ollama pull qwen2.5:3b
ollama serve &
sleep 30
node server.js
