#!/bin/bash
# Script de inicialização que executa migrações antes de iniciar o servidor

set -e

echo "🚀 Iniciando Evolution API..."

# Verificar se DATABASE_PROVIDER está definido
if [ -z "$DATABASE_PROVIDER" ]; then
  echo "⚠️ DATABASE_PROVIDER não definido, usando postgresql como padrão"
  export DATABASE_PROVIDER=postgresql
fi

# Verificar se DATABASE_CONNECTION_URI está definido
if [ -z "$DATABASE_CONNECTION_URI" ]; then
  echo "❌ ERRO: DATABASE_CONNECTION_URI não está definido!"
  exit 1
fi

echo "📦 Executando migrações do banco de dados ($DATABASE_PROVIDER)..."

# Executar migrações
npm run db:deploy || {
  echo "⚠️ Aviso: Erro ao executar migrações, mas continuando..."
}

echo "✅ Migrações concluídas (ou já aplicadas)"
echo "🚀 Iniciando servidor..."

# Iniciar servidor
exec npm run start:prod

