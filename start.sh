#!/bin/bash
# 1. 先安装Ollama
curl https://ollama.ai/install.sh | sh
# 2. 配置全网可访问
export OLLAMA_HOST=0.0.0.0
# 3. 精准拉取70M微软迷你模型（无空格！！）
ollama pull phi3:mini
# 4. 启动服务
ollama serve
