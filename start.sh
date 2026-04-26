#!/bin/bash
set -e

# 1. 先延迟 60 秒，给系统留缓冲
echo "等待 60 秒..."
sleep 60

# 2. 锁死 Ollama 资源，禁用自动修复/更新
export OLLAMA_NUM_THREADS=1
export OLLAMA_NUM_PARALLEL=1
export OLLAMA_DISABLE_AUTO_UPDATE=1
export OLLAMA_NO_AUTO_PULL=1

# 3. 直接用系统自带的 ollama 命令启动服务
echo "启动 Ollama..."
ollama serve &
OLLAMA_PID=$!

# 4. 等待端口就绪（最多60秒）
echo "等待 Ollama 就绪..."
for i in {1..60}; do
  if curl -s http://127.0.0.1:11434/api/tags > /dev/null; then
    echo "✅ Ollama 已就绪"
    break
  fi
  sleep 1
done

# 5. 再等 30 秒让模型加载完成
echo "等待模型加载..."
sleep 30

# 6. 前台运行，防止 Render 误判退出
echo "保持进程运行..."
wait $OLLAMA_PID
