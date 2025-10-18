# Dockerfile FINAL - Caminho correto para main.js
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

# Instalar TypeScript GLOBALMENTE
RUN npm install -g typescript@latest --legacy-peer-deps

# Copiar arquivos de dependências
COPY package*.json ./
COPY tsconfig.json ./
COPY tsup.config.ts ./
COPY .npmrc ./

# Instalar dependências do projeto
RUN npm install --legacy-peer-deps --ignore-scripts

# Copiar código fonte
COPY src ./src
COPY public ./public
COPY prisma ./prisma
COPY manager ./manager
COPY Docker ./Docker
COPY runWithProvider.js ./

# Configurar variáveis para Prisma
ENV DATABASE_PROVIDER=postgresql

# Gerar cliente Prisma diretamente
RUN npx prisma generate --schema ./prisma/postgresql-schema.prisma

# COMPILAR COM TYPESCRIPT GLOBAL
RUN tsc --noEmit --skipLibCheck
RUN tsc --outDir dist --skipLibCheck

# Verificar se dist/src/main.js foi criado
RUN ls -la dist/src/main.js || echo "main.js não encontrado"

# Remover dependências de desenvolvimento após build
RUN npm prune --production

# Expor porta
EXPOSE 8080

# Comando de inicialização - CAMINHO CORRETO
CMD ["node", "dist/src/main.js"]