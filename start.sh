#!/bin/bash
set -e

# 1. 自动选可写目录（Render 专属路径优先级）
if [ -w "/opt/render/project/src" ]; then
  BASE_DIR="/opt/render/project/src/ollama"
elif [ -w "$HOME" ]; then
  BASE_DIR="$HOME/ollama"
else
  BASE_DIR="/tmp/ollama"
fi

mkdir -p "$BASE_DIR/bin" "$BASE_DIR/models"
export OLLAMA_HOME="$BASE_DIR"
export OLLAMA_MODELS="$BASE_DIR/models"
export PATH="$BASE_DIR/bin:$PATH"

# 2. 下载 Linux 单文件二进制（不碰 root）
if [ ! -f "$BASE_DIR/bin/ollama" ]; then
  curl -fsSL https://ollama.com/install.sh | sh -s -- --no-install
  mv ./ollama "$BASE_DIR/bin/"
  chmod +x "$BASE_DIR/bin/ollama"
fi

# 3. 开放外网访问
export OLLAMA_HOST=0.0.0.0
export OLLAMA_ORIGINS="*"

# 4. 后台启动服务
ollama serve > "$BASE_DIR/ollama.log" 2>&1 &
sleep 6

# 5. 拉 70M 级小模型（普通用户权限）
ollama pull qwen2:0.5b

# 保持容器不退出
tail -f "$BASE_DIR/ollama.log"
