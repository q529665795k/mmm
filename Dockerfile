FROM ollama/ollama:latest

# 容器构建时 提前下载好模型，永久内置
RUN ollama pull gemma3:270m

COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
