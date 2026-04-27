#!/bin/bash
set -e

# ========== 1. 强制限定：所有文件全装在用户目录，绝不碰系统 ==========
export OLLAMA_HOME="$HOME/ollama"
export OLLAMA_MODELS="$OLLAMA_HOME/models"
export PATH="$OLLAMA_HOME/bin:$PATH"
mkdir -p "$OLLAMA_HOME/bin" "$OLLAMA_MODELS"

# ========== 2. 直接下载二进制文件（不用官方脚本，彻底避开root） ==========
curl -sL https://github.com/ollama/ollama/releases/download/v0.1.48/ollama-linux-amd64 -o "$OLLAMA_HOME/bin/ollama"
chmod +x "$OLLAMA_HOME/bin/ollama"

# ========== 3. 全网开放配置 ==========
export OLLAMA_HOST=0.0.0.0

# ========== 4. 拉取70M phi3:mini（模型名绝对正确，无空格） ==========
ollama pull phi3:mini

# ========== 5. 启动服务 ==========
ollama serve
