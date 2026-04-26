#!/bin/bash
set -e

# 1. 先启动 Ollama 后台运行
ollama serve &
OLLAMA_PID=$!

# 2. 等待端口就绪（最多等60秒）
echo "等待 Ollama 端口就绪..."
for i in {1..60}; do
  if curl -s http://127.0.0.1:11434/api/tags >/dev/null 2>&1; then
    echo "✅ Ollama 端口已就绪"
    break
  fi
  echo "等待中... ($i/60)"
  sleep 1
done

# 3. 拉取模型（确保下载完成）
echo "开始拉取模型..."
ollama pull qwen:0.2b
echo "✅ 模型下载完成"

# 4. 关键：给模型加载预留时间（额外等60秒）
echo "等待模型加载完成（额外等待60秒）..."
sleep 60

# 5. 启动你的 Node 服务
echo "启动 Node 服务..."
node server.js
