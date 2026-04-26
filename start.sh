#!/bin/bash
set -e

# ========== 1. 强制用Render有权限的用户目录，绝不碰系统 ==========
BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"
export PATH="$BIN_DIR:$PATH"

# ========== 2. 【修复404！！】用官方最新正确链接，下载压缩包 ==========
# 旧链接是ollama-linux-amd64（404），新链接是ollama-linux-amd64.tgz！！
curl -fsSL https://ollama.com/download/ollama-linux-amd64.tgz -o ollama.tgz

# ========== 3. 解压到用户目录，全程不用ROOT ==========
tar -xzf ollama.tgz -C "$BIN_DIR" --strip-components 1
chmod +x "$BIN_DIR/ollama"

# ========== 4. 全网开放配置 ==========
export OLLAMA_HOST=0.0.0.0
export OLLAMA_ORIGINS=*

# ========== 5. 后台静默启动 ==========
"$BIN_DIR/ollama" serve &
sleep 15

# ========== 6. 【就这一个！！】全自动下载qwen2:0.5b（70多兆） ==========
"$BIN_DIR/ollama" pull qwen2:0.5b

# ========== 7. 永久保活 ==========
tail -f /dev/null
