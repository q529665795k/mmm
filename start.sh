#!/bin/bash
set -e

# 延迟 60 秒，给系统留缓冲
sleep 60

# 锁死 Ollama 资源，禁用自动更新/修复
export OLLAMA_NUM_THREADS=1
export OLLAMA_NUM_PARALLEL=1
export OLLAMA_DISABLE_AUTO_UPDATE=1
export OLLAMA_NO_AUTO_PULL=1

# 启动 Ollama 服务
ollama serve
