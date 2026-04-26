FROM ollama/ollama:latest

# 构建阶段就把模型拉好，避免启动时下载超时
RUN ollama pull gemma3:270m

# 复制启动脚本并给执行权限
COPY start.sh /start.sh
RUN chmod +x /start.sh

# 容器启动时运行脚本
CMD ["/start.sh"]
