#!/bin/bash
# Script para inicializar o backend FastAPI

set -e

echo "🚀 Iniciando PontoPrime Backend (MVP)..."

cd "$(dirname "$0")/../src/backend"

# Verificar se o Python está instalado
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 não encontrado. Instale Python 3.11+"
    exit 1
fi

# Criar ambiente virtual se não existir
if [ ! -d "venv" ]; then
    echo "📦 Criando ambiente virtual..."
    python3 -m venv venv
fi

# Ativar ambiente virtual
echo "🔧 Ativando ambiente virtual..."
source venv/bin/activate

# Instalar dependências
echo "📥 Instalando dependências..."
pip install -r requirements.txt

# Rodar servidor
echo "✅ Servidor iniciando em http://localhost:8000"
echo "📚 Documentação disponível em http://localhost:8000/docs"
python main.py
