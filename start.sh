#!/bin/bash
set -e

# 先创建目录，再下载，避免路径不存在的问题
mkdir -p ~/.local/bin
export PATH=$PATH:~/.local/bin

# 下载Ollama到用户目录
curl -L https://ollama.com/download/ollama-linux-amd64 -o ~/.local/bin/ollama
chmod +x ~/.local/bin/ollama

# 后台启动Ollama服务
ollama serve > ollama.log 2>&1 &
OLLAMA_PID=$!

# 等服务启动
sleep 20

# 拉取超小模型
ollama pull qwen:0.2b

# 启动Node.js服务
node server.js

# 退出时杀掉后台进程
kill $OLLAMA_PID || true
