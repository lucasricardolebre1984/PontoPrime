#!/bin/bash
# Script de Deploy para AWS - PontoPrime
# Porta: 9000
# Servidor: 54.207.172.193

set -e

echo "🚀 Deploy PontoPrime - AWS"
echo "=========================="

# Configurações
SERVER_IP="54.207.172.193"
SERVER_USER="ubuntu"  # Ajuste conforme seu usuário SSH
SERVER_PORT="22"
DEPLOY_PATH="/var/www/pontoprime"
API_PORT="9000"

echo "📦 Configurações:"
echo "   Servidor: $SERVER_IP"
echo "   Usuário: $SERVER_USER"
echo "   Path: $DEPLOY_PATH"
echo "   Porta API: $API_PORT"
echo ""

# Função para executar comando no servidor
run_remote() {
    ssh -p $SERVER_PORT $SERVER_USER@$SERVER_IP "$1"
}

# 1. Criar diretório no servidor (se não existir)
echo "📁 Criando diretório de deploy..."
run_remote "sudo mkdir -p $DEPLOY_PATH/{backend,web}"
run_remote "sudo chown -R $SERVER_USER:$SERVER_USER $DEPLOY_PATH"

# 2. Copiar backend
echo "📤 Enviando backend..."
scp -P $SERVER_PORT -r src/backend/* $SERVER_USER@$SERVER_IP:$DEPLOY_PATH/backend/

# 3. Copiar painel web
echo "📤 Enviando painel web..."
scp -P $SERVER_PORT -r src/web/* $SERVER_USER@$SERVER_IP:$DEPLOY_PATH/web/

# 4. Instalar dependências Python no servidor
echo "🐍 Instalando dependências Python..."
run_remote "cd $DEPLOY_PATH/backend && python3 -m venv venv"
run_remote "cd $DEPLOY_PATH/backend && source venv/bin/activate && pip install -r requirements.txt"

# 5. Matar processo antigo na porta 9000 (se existir)
echo "🔄 Parando processo anterior..."
run_remote "sudo fuser -k $API_PORT/tcp || true"
sleep 2

# 6. Iniciar API em background com nohup
echo "🚀 Iniciando API na porta $API_PORT..."
run_remote "cd $DEPLOY_PATH/backend && nohup python3 main_production.py > api.log 2>&1 &"

# 7. Aguardar 3 segundos
sleep 3

# 8. Verificar se está rodando
echo "✅ Verificando status..."
if run_remote "curl -f http://localhost:$API_PORT/health"; then
    echo ""
    echo "✅ Deploy concluído com sucesso!"
    echo ""
    echo "📍 URLs de Acesso:"
    echo "   API: http://$SERVER_IP:$API_PORT"
    echo "   Docs: http://$SERVER_IP:$API_PORT/docs"
    echo "   Health: http://$SERVER_IP:$API_PORT/health"
    echo ""
    echo "📂 Painel Web: Copie os arquivos de src/web para:"
    echo "   /var/www/automaniaai.com.br/pontoprime/andre/"
    echo ""
else
    echo "❌ Erro ao iniciar a API. Verifique os logs:"
    echo "   ssh $SERVER_USER@$SERVER_IP 'tail -50 $DEPLOY_PATH/backend/api.log'"
    exit 1
fi
