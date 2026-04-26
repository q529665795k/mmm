# 用 Ollama 官方镜像作为基础
FROM ollama/ollama:latest

# 安装 Node.js（适配 Render 的 Node 环境）
RUN apt-get update && apt-get install -y curl
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
RUN apt-get install -y nodejs

# 拉基础模型
RUN ollama pull gemma3:270m

# 复制你的人设配置并生成模型
COPY Modelfile /Modelfile
RUN ollama create npxj -f /Modelfile

# 复制项目文件
COPY package.json ./
COPY start.sh ./
RUN chmod +x start.sh

# 安装依赖（其实只是为了过构建）
RUN npm install

CMD ["npm", "start"]
