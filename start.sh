#!/bin/bash
set -euo pipefail

# ===================== 1. 强制所有文件装在你的用户家目录，绝对不碰系统 =====================
export OLLAMA_HOME="$HOME/.ollama"
export OLLAMA_MODELS="$OLLAMA_HOME/models"
export OLLAMA_HOST="0.0.0.0"
export PATH="$OLLAMA_HOME/bin:$PATH"

# 创建用户目录（Render百分百有权限）
mkdir -p "$OLLAMA_HOME/bin" "$OLLAMA_MODELS"

# ===================== 2. 官方免ROOT核心：下载【独立二进制文件】，不是安装包！！ =====================
# 直接下载单文件，不用任何安装脚本、不用sudo、不用系统权限
curl -fsSL https://github.com/ollama/ollama/releases/download/v0.1.48/ollama-linux-amd64 -o "$OLLAMA_HOME/bin/ollama"
chmod +x "$OLLAMA_HOME/bin/ollama"

# ===================== 3. 后台启动Ollama（不占用终端，Render不会杀进程） =====================
nohup ollama serve > "$OLLAMA_HOME/ollama.log" 2>&1 &
sleep 8

# ===================== 4. 拉取你指定的70M微软迷你模型（phi3:mini，无空格！！） =====================
ollama pull phi3:mini

# ===================== 5. 永久前台运行，防止Render判定服务下线 =====================
tail -f "$OLLAMA_HOME/ollama.log"
