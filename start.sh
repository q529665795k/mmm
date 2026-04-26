#!/bin/bash
# 先给容器初始化时间
sleep 30

# 后台启动 Ollama，固定 11434 端口
export OLLAMA_HOST=0.0.0.0:11434
ollama serve &

# 用 Node 跑一个极简的空服务，让 Render 认为进程在运行
node -e "setInterval(() => {}, 1000)"
