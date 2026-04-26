#!/bin/bash
# 加长延时，等容器环境完全就绪
sleep 45
export OLLAMA_HOST=0.0.0.0:11434
export OLLAMA_NUM_THREADS=1
export OLLAMA_NUM_PARALLEL=1
ollama serve
