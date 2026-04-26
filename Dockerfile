FROM ollama/ollama:latest

# 构建阶段就预拉好 gemma3:270m 模型，不用运行时再拉
RUN ollama pull gemma3:270m

# 把我们的启动脚本复制进去
COPY start.sh /start.sh
RUN chmod +x /start.sh

# 用脚本启动
CMD ["/start.sh"]
