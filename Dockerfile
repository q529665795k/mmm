FROM ollama/ollama:latest
RUN apt update && apt install -y nodejs npm curl
WORKDIR /app
COPY . .

# 1. 构建时强制拉模型，不拉完不往下走（阻塞式）
RUN ollama pull tinyllama:1.1b-chat-v0.4-q2_K
# 2. 生成小姐姐人设
RUN ollama create girl -f girl.Modelfile
# 3. 装Node依赖
RUN npm install

EXPOSE 3000

# 启动逻辑：先启Ollama→循环检测就绪→再启接口
CMD ["sh","-c","\
ollama serve & \
sleep 8 && \
for i in {1..15}; do \
  if curl -s http://127.0.0.1:11434/api/tags >/dev/null; then \
    echo '✅ 模型加载完成，接口启动'; \
    break; \
  fi; \
  echo '⏳ 等待模型加载...'; \
  sleep 4; \
done; \
node server.js\
"]
