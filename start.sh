#!/bin/bash
set -e

# 1. 下载 Ollama 二进制到当前目录
echo "下载 Ollama 二进制..."
curl -L https://github.com/ollama/ollama/releases/download/v0.1.38/ollama-linux-amd64 -o ollama
chmod +x ollama

# 2. 后台启动 Ollama 服务
./ollama serve &
OLLAMA_PID=$!

# 3. 等待 Ollama 端口就绪（最多等60秒）
echo "等待 Ollama 服务启动..."
for i in {1..60}; do
  if curl -s http://127.0.0.1:11434/api/tags >/dev/null 2>&1; then
    echo "✅ Ollama 服务已就绪"
    break
  fi
  echo "等待中... ($i/60)"
  sleep 1
done

# 4. 拉取模型（改为 Ollama 官方支持的 qwen:0.5b）
echo "拉取 Qwen 模型..."
./ollama pull qwen:0.5b

# 5. 额外等待模型加载完成
echo "等待模型加载..."
sleep 30

# 6. 启动 Node.js 服务
echo "启动 Node 服务..."
node server.js
