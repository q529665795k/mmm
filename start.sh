#!/bin/bash
set -e

# ========== 1. 强制锁定Render有权限的路径 ==========
BIN_DIR="/opt/render/.local/bin"
mkdir -p "$BIN_DIR"
export PATH="$BIN_DIR:$PATH"

# ========== 2. 无root安装Ollama（只装在你的目录里，不碰系统） ==========
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

# ========== 4. 后台启动Ollama ==========
"$BIN_DIR/ollama" serve &
sleep 12

# ========== 5. 精准下载73兆 qwen:0.5b 模型（你要的那个） ==========
"$BIN_DIR/ollama" pull qwen:0.5b

# ========== 6. 创建你的girl模型 ==========
"$BIN_DIR/ollama" create girl -f girl.Modelfile

# 保活不退出
tail -f /dev/null
