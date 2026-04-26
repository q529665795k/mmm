FROM ollama/ollama:latest

RUN ollama pull gemma3:270m

COPY Modelfile /Modelfile
RUN ollama create npxj -f /Modelfile

COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
