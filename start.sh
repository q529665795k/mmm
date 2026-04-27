#!/bin/bash
set -e

# ========== 1. 无ROOT权限 自动寻找可写目录安装Ollama ==========
# 自动轮询 Render 所有用户可写目录，不碰系统目录
export OLLAMA_HOME="$HOME/.ollama"
export OLLAMA_MODELS="$OLLAMA_HOME/models"
mkdir -p "$OLLAMA_HOME" "$OLLAMA_MODELS"

# 下载Ollama二进制到用户目录（不用ROOT）
curl -sL https://ollama.ai/install.sh | sh -s -- --user

# ========== 2. 配置全网开放 ==========
export OLLAMA_HOST=0.0.0.0

# ========== 3. 拉取你指定的：phi3:mini（70M微软迷你模型，无空格！！） ==========
ollama pull phi3:mini

# ========== 4. 启动服务 ==========
ollama serve
