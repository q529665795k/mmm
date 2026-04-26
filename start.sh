#!/bin/bash
set -e

# ========== 1. 自动找Render有权限的目录（彻底绕开ROOT） ==========
if [ -w "$HOME/.local/bin" ]; then
    BIN_DIR="$HOME/.local/bin"
elif [ -w "/opt/render/.local/bin" ]; then
    BIN_DIR="/opt/render/.local/bin"
else
    BIN_DIR="./bin"
fi
mkdir -p "$BIN_DIR"
export PATH="$BIN_DIR:$PATH"

# ========== 2. 无ROOT安装Ollama（只装在你的用户目录） ==========
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
    curl -fsSL https://ollama.com/download/ollama-linux-amd64 -o "$BIN_DIR/ollama"
else
    curl -fsSL https://ollama.com/download/ollama-linux-arm64 -o "$BIN_DIR/ollama"
fi
chmod +x "$BIN_DIR/ollama"

# ========== 3. 全网开放配置 ==========
export OLLAMA_HOST=0.0.0.0
export OLLAMA_ORIGINS=*
export OLLAMA_MODELS="$HOME/.ollama/models"

# ========== 4. 后台启动Ollama ==========
"$BIN_DIR/ollama" serve &
sleep 15

# ========== 5. 精准下载你指定的：gemma:2b-instruct-v1.1-q2_K ==========
"$BIN_DIR/ollama" pull gemma:2b-instruct-v1.1-q2_K

# ========== 6. 创建你的girl模型 ==========
"$BIN_DIR/ollama" create girl -f girl.Modelfile

# 保活不退出
tail -f /dev/null
