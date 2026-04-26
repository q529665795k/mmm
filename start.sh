#!/bin/bash
set -euo pipefail

# 1. 自动找目录
OLLAMA_BIN_DIR="$HOME/.local/bin"
if [ ! -d "$OLLAMA_BIN_DIR" ] || [ ! -w "$OLLAMA_BIN_DIR" ]; then
  OLLAMA_BIN_DIR="./bin"
fi
mkdir -p "$OLLAMA_BIN_DIR"
export PATH="$OLLAMA_BIN_DIR:$PATH"
OLLAMA="$OLLAMA_BIN_DIR/ollama"

# 2. 多地址下载Ollama（你之前已经成功过的版本）
URLS=(
"https://github.com/ollama/ollama/releases/download/v0.1.38/ollama-linux-amd64"
"https://github.com/ollama/ollama/releases/download/v0.1.42/ollama-linux-amd64"
)
for u in "${URLS[@]}"; do
  echo "尝试下载: $u"
  if curl -L --fail "$u" -o "$OLLAMA"; then
    echo "✅ Ollama下载完成"
    break
  fi
done
chmod +x "$OLLAMA"

# 3. 先拉模型，再启动服务（避免启动瞬间内存双高峰）
echo "📦 拉取 qwen:0.2b 模型..."
ollama pull qwen:0.2b

# 4. 后台启动Ollama，加内存限制参数
echo "🚀 启动Ollama服务..."
OLLAMA_NUM_PARALLEL=1 OLLAMA_MAX_LOADED_MODELS=1 ollama serve > ollama.log 2>&1 &
OLLAMA_PID=$!

# 5. 等待服务就绪
for i in {1..30}; do
  if curl -s http://127.0.0.1:11434/api/tags > /dev/null; then
    echo "✅ Ollama服务就绪"
    break
  fi
  echo "⏳ 等待中 ($i/30)..."
  sleep 1
done

# 6. 启动Node.js服务（最后一步，保证不被挤掉）
echo "▶️ 启动Node服务..."
node server.js

kill $OLLAMA_PID 2>/dev/null || true
