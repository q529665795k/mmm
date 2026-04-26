#!/bin/bash
set -e

# 1. 直接用官方脚本安装 Ollama（自动加到PATH）
curl -fsSL https://ollama.com/install.sh | sh

# 2. 启动 Ollama 后台运行
ollama serve &
OLLAMA_PID=$!

# 3. 等待端口就绪（最多等60秒）
echo "等待 Ollama 服务启动..."
for i in {1..60}; do
  if curl -s http://127.0.0.1:11434/api/tags >/dev/null 2>&1; then
    echo "✅ Ollama 服务已就绪"
    break
  fi
  echo "等待中... ($i/60)"
  sleep 1
done

# 4. 拉取模型
echo "拉取 Qwen 模型..."
ollama pull qwen:0.2b

# 5. 额外等待模型加载
echo "等待模型加载..."
sleep 30

# 6. 启动 Node 服务
echo "启动 Node 服务..."
node server.js
