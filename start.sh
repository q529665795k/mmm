#!/bin/bash
# 加长延时，给容器足够初始化时间
sleep 60

# 固定 Ollama 端口为 11434，绑定所有地址
export OLLAMA_HOST=0.0.0.0:11434
export OLLAMA_NUM_THREADS=1
export OLLAMA_NUM_PARALLEL=1

# 启动 Ollama 服务
ollama serve
