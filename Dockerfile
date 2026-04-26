FROM ollama/ollama:latest
# 预拉取 gemma3:270m 模型（约292MB）
RUN ollama pull gemma3:270m
# 用我们的优化脚本启动
CMD ["./start.sh"]
