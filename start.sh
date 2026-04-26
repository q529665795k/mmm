#!/bin/bash
set -e

# 1. 锁定Render普通用户唯一有权限的路径（就是你截图里的）
BIN_DIR="/opt/render/.local/bin"
mkdir -p "$BIN_DIR"
export PATH="$BIN_DIR:$PATH"

# 2. 无root安装Ollama（直接下载二进制，不碰系统目录）
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
  curl -sL https://ollama.com/download/ollama-linux-amd64 -o "$BIN_DIR/ollama"
else
  curl -sL https://ollama.com/download/ollama-linux-arm64 -o "$BIN_DIR/ollama"
fi
chmod +x "$BIN_DIR/ollama"

# 3. 全网开放配置
export OLLAMA_HOST=0.0.0.0
export OLLAMA_ORIGINS=*

# 4. 后台启动Ollama
ollama serve &
sleep 10

# 5. 创建模型（不会再报找不到命令）
ollama create girl -f girl.Modelfile

# 保持Render容器不退出
tail -f /dev/null
