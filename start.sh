#!/bin/bash
set -e

# 1. 自动找一个可写目录（优先级：src > tmp > home）
if [ -w "/opt/render/project/src" ]; then
  BASE_DIR="/opt/render/project/src/ollama"
elif [ -w "/tmp" ]; then
  BASE_DIR="/tmp/ollama"
else
  BASE_DIR="$HOME/ollama"
fi

mkdir -p "$BASE_DIR/bin"
export OLLAMA_HOME="$BASE_DIR"
export OLLAMA_MODELS="$BASE_DIR/models"
export PATH="$BASE_DIR/bin:$PATH"

# 2. 普通用户安装 Ollama（不碰 root）
if ! command -v ollama &> /dev/null; then
  curl -fsSL https://ollama.com/install.sh | sh -s -- --user
fi

# 3. 配置允许外网访问
export OLLAMA_HOST=0.0.0.0
export OLLAMA_ORIGINS="*"

# 4. 后台启动服务
ollama serve > "$BASE_DIR/ollama.log" 2>&1 &
sleep 5

# 5. 自动拉 70M 小模型（普通用户权限）
ollama pull qwen2:0.5b

# 保持进程不退出
tail -f "$BASE_DIR/ollama.log"
