#!/bin/bash
set -e

# === 1. 预拉取模型（提前在构建阶段就完成，不用运行时再拉） ===
# 注：真正部署时，ollama pull 应该写在 Dockerfile 里，这里只是兜底

# === 2. 延迟启动，给系统缓冲时间（你要的 1 分钟延时） ===
echo "等待 60 秒，给系统留缓冲..."
sleep 60

# === 3. 后台启动 Ollama 服务，不抢主进程 ===
echo "启动 Ollama 服务..."
./ollama serve &
OLLAMA_PID=$!

# === 4. 等待 Ollama 端口就绪（最多等60秒） ===
echo "等待 Ollama 服务就绪..."
for i in {1..60}; do
  if curl -s http://127.0.0.1:11434/api/tags > /dev/null; then
    echo "✅ Ollama 服务已就绪"
    break
  fi
  echo "等待中... ($i/60)"
  sleep 1
done

# === 5. 额外给模型加载留缓冲（再等30秒） ===
echo "等待模型加载完成..."
sleep 30

# === 6. 启动 Node.js 服务（作为主进程，防止 Render 误判服务挂了） ===
echo "启动 Node 服务..."
exec node server.js
