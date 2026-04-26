#!/bin/bash
set -euo pipefail

# 1. 自动选择Render可写目录（绝对不碰系统）
if [ -w "/opt/render/project/src" ]; then
  BASE_DIR="/opt/render/project/src/ollama_env"
elif [ -w "$HOME" ]; then
  BASE_DIR="$HOME/ollama_env"
else
  BASE_DIR="/tmp/ollama_env"
fi

# 创建全隔离目录（所有文件都在这里，不碰系统）
mkdir -p "$BASE_DIR/bin" "$BASE_DIR/models" "$BASE_DIR/logs"

# 2. 强制隔离环境变量（完全不读取系统配置）
export OLLAMA_HOME="$BASE_DIR"
export OLLAMA_MODELS="$BASE_DIR/models"
export OLLAMA_CONFIG="$BASE_DIR/config"
export PATH="$BASE_DIR/bin:$PATH"
export OLLAMA_HOST="0.0.0.0:10000"  # Render强制要求绑定10000端口
export OLLAMA_ORIGINS="*"

# 3. 下载【最新有效】静态二进制（修复404）
OLLAMA_BIN="$BASE_DIR/bin/ollama"
if [ ! -f "$OLLAMA_BIN" ]; then
  curl -fsSL https://github.com/ollama/ollama/releases/latest/download/ollama-linux-amd64 -o "$OLLAMA_BIN"
  chmod +x "$OLLAMA_BIN"
fi

# 4. 后台启动（纯用户权限，不碰任何系统服务）
"$OLLAMA_BIN" serve > "$BASE_DIR/logs/serve.log" 2>&1 &
sleep 8

# 5. 拉70M小模型（qwen2:0.5b，完全本地目录）
"$OLLAMA_BIN" pull qwen2:0.5b

# 保持进程不退出（Render必备）
tail -f "$BASE_DIR/logs/serve.log"
