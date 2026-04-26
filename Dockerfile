FROM ollama/ollama:latest
RUN ollama pull gemma3:270m
COPY start.sh .
COPY server.js .
CMD ["./start.sh"]
