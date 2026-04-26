#!/bin/bash
set -e

# 把Ollama装到用户目录，不需要root权限
export PATH=$PATH:~/.local/bin
curl -L https://ollama.com/download/ollama-linux-amd64 -o ~/.local/bin/ollama
chmod +x ~/.local/bin/ollama

# 后台启动Ollama服务
ollama serve > ollama.log 2>&1 &
OLLAMA_PID=$!

# 等服务启动
sleep 15

# 拉取超小模型（qwen:0.2b，最低配置，Render免费机能跑）
ollama pull qwen:0.2b

# 启动Node.js服务
node server.js

# 退出时杀掉后台进程
kill $OLLAMA_PID || true
