#!/bin/bash
# ========== 1. 免ROOT安装Ollama（适配Render普通用户） ==========
curl -fsSL https://ollama.com/install.sh | sh

# ========== 2. 强制刷新环境变量，让ollama命令立马生效 ==========
source /etc/profile
source ~/.bashrc

# ========== 3. 拉模型+创建人设 ==========
ollama pull tinyllama:1.1b-chat-v0.4-q2_K
ollama create girl -f girl.Modelfile

# ========== 4. 后台启动Ollama ==========
ollama serve &

# ========== 5. 等待10秒确保服务就绪 ==========
sleep 10

# ========== 6. 启动Node接口 ==========
node server.js
