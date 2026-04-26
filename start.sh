#!/bin/bash
set -e

# 1. 固定Render有权限的用户目录（绝对不报权限错）
BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"
export PATH="$BIN_DIR:$PATH"

# 2. 下载Ollama本体（官方正确链接）
curl -fsSL https://ollama.com/download/ollama-linux-amd64 -o "$BIN_DIR/ollama"
chmod +x "$BIN_DIR/ollama"

# 3. 开放外网访问
export OLLAMA_HOST=0.0.0.0
export OLLAMA_ORIGINS=*

# 4. 启动Ollama服务
"$BIN_DIR/ollama" serve &
sleep 15

# 5. 【唯一核心】下载你确认过能用的这个模型
"$BIN_DIR/ollama" pull gemma:2b-instruct-v1.1-q2_K

# 保活，防止Render关闭
tail -f /dev/null
