FROM ollama/ollama:latest

# 构建阶段就预拉好 gemma3:270m 模型
RUN ollama pull gemma3:270m

# 复制启动脚本到容器里
COPY start.sh /start.sh
RUN chmod +x /start.sh

# 启动脚本
CMD ["/start.sh"]
