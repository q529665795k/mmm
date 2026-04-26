#!/bin/bash
set -e

# ========== 第一步：自动找Render有权限的目录，不用root ==========
# 优先找官方给的用户目录，找不到就用当前项目目录
if [ -w "$HOME/.local/bin" ]; then
    BIN_DIR="$HOME/.local/bin"
elif [ -w "/opt/render/.local/bin" ]; then
    BIN_DIR="/opt/render/.local/bin"
else
    BIN_DIR="./bin"
fi
mkdir -p "$BIN_DIR"
export PATH="$BIN_DIR:$PATH"

# ========== 第二步：无root安装Ollama（只装在你的文件夹里） ==========
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
    # 最新官方二进制链接，绝对不404
    curl -fsSL https://ollama.com/download/ollama-linux-amd64 -o "$BIN_DIR/ollama"
else
    curl -fsSL https://ollama.com/download/ollama-linux-arm64 -o "$BIN_DIR/ollama"
fi
chmod +x "$BIN_DIR/ollama"

# ========== 第三步：配置全网可访问 ==========
export OLLAMA_HOST=0.0.0.0
export OLLAMA_ORIGINS=*
export OLLAMA_MODELS="$HOME/.ollama/models" # 模型也装用户目录

# ========== 第四步：启动Ollama ==========
"$BIN_DIR/ollama" serve &
sleep 15

# ========== 第五步：下载你要的73兆中文模型 ==========
"$BIN_DIR/ollama" pull qwen:0.5b

# ========== 第六步：创建你的girl模型 ==========
"$BIN_DIR/ollama" create girl -f girl.Modelfile

# 保活不退出
tail -f /dev/null
