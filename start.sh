#!/bin/bash

# ===================== 1. 自动查找普通用户可用的安装路径 =====================
# 优先找系统默认PATH里有权限的文件夹
POSSIBLE_PATHS=(
  "$HOME/.local/bin"
  "/usr/local/bin"
  "$HOME/bin"
  "/tmp/bin"
)

# 创建临时可用目录
mkdir -p /tmp/bin
# 遍历找第一个能写、且在PATH里的路径
INSTALL_PATH=""
for p in "${POSSIBLE_PATHS[@]}"; do
  mkdir -p "$p"
  if [ -w "$p" ]; then
    INSTALL_PATH="$p"
    break
  fi
done

# 把找到的路径加入当前脚本环境，永久生效
export PATH="$INSTALL_PATH:$PATH"
echo "✅ 已自动找到可用安装路径：$INSTALL_PATH"

# ===================== 2. 安装Ollama到找到的路径 =====================
# 下载官方二进制文件，直接放到可用路径（不碰root）
curl -fsSL https://ollama.com/install.sh | sh -s -- --install-dir "$INSTALL_PATH"

# ===================== 3. 全网访问配置 =====================
export OLLAMA_HOST=0.0.0.0
export OLLAMA_ORIGINS=*

# ===================== 4. 启动Ollama =====================
ollama serve &
sleep 8

# ===================== 5. 加载模型 =====================
ollama create girl -f girl.Modelfile

# 保持容器存活
tail -f /dev/null
