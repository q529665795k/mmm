#!/bin/bash
set -euo pipefail

# ========== 自动找可写目录 ==========
if [ -w "/opt/render/project/src" ]; then
  BASE=/opt/render/project/src/ollama
elif [ -w "$HOME" ]; then
  BASE="$HOME/ollama"
else
  BASE="/tmp/ollama"
fi

BIN="$BASE/bin"
MODELS="$BASE/models"
mkdir -p "$BIN" "$MODELS"

# 环境变量全部指向项目内，绝不碰系统
export OLLAMA_HOME="$BASE"
export OLLAMA_MODELS="$MODELS"
export PATH="$BIN:$PATH"
export OLLAMA_HOST=0.0.0.0
export OLLAMA_ORIGINS="*"

# ========== 下载纯静态二进制（无安装、无root） ==========
if [ ! -f "$BIN/ollama" ]; then
  curl -fsSL https://github.com/ollama/ollama/releases/download/v0.1.48/ollama-linux-amd64 -o "$BIN/ollama"
  chmod +x "$BIN/ollama"
fi

# ========== 启动服务 ==========
"$BIN/ollama" serve > "$BASE/serve.log" 2>&1 &
sleep 5

# ========== 拉70M小模型（本地目录，不碰系统） ==========
"$BIN/ollama" pull qwen2:0.5b

# 保持进程
tail -f "$BASE/serve.log"
