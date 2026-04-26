FROM ollama/ollama:latest
RUN ollama pull qwen:0.5b
CMD ["ollama", "serve"]
