#!/bin/bash
set -euo pipefail

# 1. 自动找可用的目录（先试 ~/.local/bin，不行就用当前目录）
OLLAMA_BIN_DIR="$HOME/.local/bin"
if [ ! -d "$OLLAMA_BIN_DIR" ] || [ ! -w "$OLLAMA_BIN_DIR" ]; then
  echo "⚠️ ~/.local/bin 不可用，改用当前目录"
  OLLAMA_BIN_DIR="./bin"
fi

# 2. 强制创建目录，不存在就新建
mkdir -p "$OLLAMA_BIN_DIR"
export PATH="$OLLAMA_BIN_DIR:$PATH"
OLLAMA_PATH="$OLLAMA_BIN_DIR/ollama"

echo "📁 最终Ollama路径：$OLLAMA_PATH"

# 3. 下载Ollama，最多重试3次
download_ollama() {
  echo "🔽 开始下载Ollama..."
  for i in {1..3}; do
    if curl -L --fail https://ollama.com/download/ollama-linux-amd64 -o "$OLLAMA_PATH"; then
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

# 4. 启动Ollama服务，后台运行
echo "🚀 启动Ollama服务..."
ollama serve > ollama.log 2>&1 &
OLLAMA_PID=$!

# 5. 等待服务启动，最多等30秒
for i in {1..30}; do
  if curl -s http://127.0.0.1:11434/api/tags > /dev/null; then
    echo "✅ Ollama服务已就绪"
    break
  fi
  echo "⏳ 等待Ollama启动 ($i/30)..."
  sleep 1
done

# 6. 拉取最小模型（qwen:0.2b）
echo "📦 拉取模型 qwen:0.2b..."
ollama pull qwen:0.2b

# 7. 启动Node.js服务
echo "▶️ 启动Node.js服务..."
node server.js

# 8. 退出时清理后台进程
kill $OLLAMA_PID 2>/dev/null || true
