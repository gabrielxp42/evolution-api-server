#!/bin/bash
# Script para executar migrações antes de iniciar o servidor

echo "🚀 Iniciando Evolution API com migrações..."

# Executar migrações do banco de dados
echo "📦 Executando migrações do Prisma..."
npm run db:deploy || echo "⚠️ Aviso: Migrações podem já estar aplicadas"

# Iniciar o servidor
echo "✅ Iniciando servidor..."
npm run start:prod

