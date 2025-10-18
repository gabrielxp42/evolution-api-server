# Dockerfile FINAL - Resolve todos os problemas
FROM node:20-alpine

# Instalar dependências do sistema
RUN apk update && \
    apk add --no-cache \
    git \
    ffmpeg \
    wget \
    curl \
    bash \
    openssl \
    python3 \
    make \
    g++ \
    chromium \
    nss \
    freetype \
    freetype-dev \
    harfbuzz \
    ca-certificates \
    ttf-freefont

# Configurar Chromium
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

# Configurar variáveis de ambiente
ENV NODE_ENV=production
ENV DOCKER_ENV=true
ENV TZ=America/Sao_Paulo
ENV HUSKY=0

# Criar diretório da aplicação
WORKDIR /evolution

# Limpar cache do npm
RUN npm cache clean --force

# Copiar arquivos de dependências
COPY package*.json ./
COPY tsconfig.json ./
COPY tsup.config.ts ./

# Instalar dependências SEM husky e com flags corretas
RUN npm install --omit=dev --legacy-peer-deps --ignore-scripts

# Instalar dependências de desenvolvimento necessárias para build
RUN npm install --save-dev typescript tsup --legacy-peer-deps

# Copiar código fonte
COPY src ./src
COPY public ./public
COPY prisma ./prisma
COPY manager ./manager
COPY Docker ./Docker
COPY runWithProvider.js ./

# Dar permissões aos scripts
RUN chmod +x ./Docker/scripts/* && dos2unix ./Docker/scripts/*

# Executar script de geração do banco
RUN ./Docker/scripts/generate_database.sh

# Compilar TypeScript
RUN npm run build

# Remover dependências de desenvolvimento após build
RUN npm prune --production

# Expor porta
EXPOSE 8080

# Comando de inicialização
CMD ["npm", "run", "start:prod"]
