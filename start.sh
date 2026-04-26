#!/bin/bash
set -e

# 1. 锁定Render有权限的目录
BIN_DIR="/opt/render/.local/bin"
mkdir -p "$BIN_DIR"
export PATH="$BIN_DIR:$PATH"

# 2. 【修复404！！】全新Ollama官方下载链接
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
    curl -fsSL https://ollama.com/install.sh | sh
else
    curl -fsSL https://ollama.com/install.sh | sh
fi

# 3. 全网开放
export OLLAMA_HOST=0.0.0.0
export OLLAMA_ORIGINS=*

# 4. 启动Ollama
ollama serve &
sleep 15

# 5. 下载你要的73兆中文模型
ollama pull qwen:0.5b

# 6. 创建你的girl模型
ollama create girl -f girl.Modelfile

# 保活
tail -f /dev/null
