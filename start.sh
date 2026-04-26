#!/bin/bash
set -e

# 1. 下载 Ollama 二进制到当前目录
echo "下载 Ollama..."
curl -L https://github.com/ollama/ollama/releases/download/v0.1.38/ollama-linux-amd64 -o ollama
chmod +x ollama

# 2. 启动 Ollama（用本地文件，不用全局安装）
./ollama serve &
OLLAMA_PID=$!

# 3. 等待端口就绪
echo "等待 Ollama 启动..."
for i in {1..60}; do
  if curl -s http://127.0.0.1:11434/api/tags >/dev/null 2>&1; then
    echo "✅ Ollama 已就绪"
    break
  fi
  echo "等待中... ($i/60)"
  sleep 1
done

# 4. 拉取模型（用本地的 ollama 命令）
./ollama pull qwen:0.2b

# 5. 额外等待模型加载
sleep 30

# 6. 启动 Node 服务
node server.js
