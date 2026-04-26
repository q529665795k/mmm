#!/bin/bash
export PATH=$PATH:/usr/local/bin
apt update -y
apt install -y curl
curl -fsSL https://ollama.com/install.sh | sh
export PATH=$PATH:/usr/local/bin
ollama pull qwen2.5:1.8b
ollama serve &
sleep 30
node server.js
