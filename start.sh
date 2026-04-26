#!/bin/bash
cd /opt/render/project/src
chmod +x ./ollama
export OLLAMA_MODELS=$(pwd)/ollama-models
./ollama serve
