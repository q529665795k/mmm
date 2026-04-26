#!/bin/bash
# 1. 先装Ollama
curl -fsSL https://ollama.com/install.sh | sh
# 2. 拉70M模型（不拉完不走下一步）
ollama pull tinyllama:1.1b-chat-v0.4-q2_K
# 3. 创建小姐姐人设
ollama create girl -f girl.Modelfile
# 4. 后台跑Ollama
ollama serve &
# 5. 等10秒，确保模型加载完
sleep 10
# 6. 最后启动你的Node接口
node server.js
