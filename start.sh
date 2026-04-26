#!/bin/bash
set -euo pipefail

# 自动找可用目录
OLLAMA_BIN_DIR="$HOME/.local/bin"
if [ ! -d "$OLLAMA_BIN_DIR" ] || [ ! -w "$OLLAMA_BIN_DIR" ]; then
  echo "⚠️ ~/.local/bin 不可用，改用当前目录"
  OLLAMA_BIN_DIR="./bin"
fi

mkdir -p "$OLLAMA_BIN_DIR"
export PATH="$OLLAMA_BIN_DIR:$PATH"
OLLAMA_PATH="$OLLAMA_BIN_DIR/ollama"

echo "📁 最终Ollama路径：$OLLAMA_PATH"

# 用GitHub的稳定备用地址下载
download_ollama() {
  echo "🔽 开始下载Ollama..."
  for i in {1..3}; do
    if curl -L --fail https://github.com/ollama/ollama/releases/download/v0.1.38/ollama-linux-amd64 -o "$OLLAMA_PATH"; then
      echo "✅ 下载成功"
      return 0
    else
      echo "❌ 第 $i 次下载失败，重试..."
      sleep 3
    fi
  done
  echo "❌ 下载失败3次，退出"
  exit 1
}

download_ollama
chmod +x "$OLLAMA_PATH"

echo "🚀 启动Ollama服务..."
ollama serve > ollama.log 2>&1 &
OLLAMA_PID=$!

# 等待服务启动
for i in {1..30}; do
  if curl -s http://127.0.0.1:11434/api/tags > /dev/null; then
    echo "✅ Ollama服务已就绪"
    break
  fi
  echo "⏳ 等待Ollama启动 ($i/30)..."
  sleep 1
done

#
