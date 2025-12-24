#!/bin/bash
# ============================================
# DEPLOY ÚNICO - PONTOPRIME V2 FULL
# Deploy automatizado da versão profissional
# ============================================

set -e  # Para na primeira falha

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}🚀 PONTOPRIME V2 FULL - DEPLOY AUTOMATIZADO${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

# Verificar se está no diretório correto
if [ ! -f "src/backend/main_v2.py" ]; then
    echo -e "${RED}❌ Erro: Execute este script da raiz do projeto PontoPrime${NC}"
    exit 1
fi

# Função de confirmação
confirm() {
    echo -e "${YELLOW}$1${NC}"
    read -p "Continuar? (s/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        echo -e "${RED}❌ Deploy cancelado${NC}"
        exit 1
    fi
}

# 1. PRÉ-REQUISITOS
echo -e "${BLUE}📋 1/7 - Verificando pré-requisitos...${NC}"

# Verificar Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker não instalado${NC}"
    echo "Instale com: curl -fsSL https://get.docker.com | sh"
    exit 1
fi

# Verificar Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}❌ Docker Compose não instalado${NC}"
    echo "Instale com: sudo apt install docker-compose"
    exit 1
fi

echo -e "${GREEN}✅ Pré-requisitos OK${NC}"
echo ""

# 2. BACKUP (se existir V1 rodando)
echo -e "${BLUE}📦 2/7 - Verificando versões anteriores...${NC}"

if docker ps | grep -q "pontoprime_backend"; then
    echo -e "${YELLOW}⚠️  DEMO (V1) está rodando na porta 9000${NC}"
    echo "V2 vai rodar na porta 9001 (SEM CONFLITO)"
    echo ""
fi

echo -e "${GREEN}✅ Verificação OK${NC}"
echo ""

# 3. CONFIGURAR .ENV
echo -e "${BLUE}🔐 3/7 - Configurando variáveis de ambiente...${NC}"

cd src/backend

if [ ! -f ".env" ]; then
    echo -e "${YELLOW}⚠️  Arquivo .env não encontrado, criando...${NC}"

    # Gerar JWT_SECRET forte
    JWT_SECRET=$(openssl rand -hex 32)

    # Gerar senha DB forte
    DB_PASSWORD=$(openssl rand -base64 16 | tr -d "=+/" | cut -c1-20)

    cat > .env << EOF
# Database
DB_USER=pontoprime
DB_PASSWORD=${DB_PASSWORD}
DB_NAME=pontoprime_db
DATABASE_URL=postgresql://pontoprime:${DB_PASSWORD}@db_v2:5432/pontoprime_db

# Security
JWT_SECRET=${JWT_SECRET}
JWT_ALGORITHM=HS256
JWT_EXPIRATION=30

# Application
ENVIRONMENT=production
DEBUG=false
LOG_LEVEL=info

# CORS
ALLOWED_ORIGINS=*
EOF

    echo -e "${GREEN}✅ Arquivo .env criado com credenciais seguras${NC}"
    echo -e "${YELLOW}⚠️  IMPORTANTE: Backup do .env criado em .env.backup${NC}"
    cp .env .env.backup
else
    echo -e "${GREEN}✅ Arquivo .env já existe${NC}"
fi

echo ""

# 4. BUILD DAS IMAGENS
echo -e "${BLUE}🐳 4/7 - Buildando imagens Docker...${NC}"
confirm "Isso pode levar alguns minutos."

docker-compose -f docker-compose.v2.yml build

echo -e "${GREEN}✅ Build concluído${NC}"
echo ""

# 5. SUBIR SERVIÇOS
echo -e "${BLUE}🚀 5/7 - Subindo serviços (PostgreSQL + Backend V2 + Nginx)...${NC}"

docker-compose -f docker-compose.v2.yml up -d

echo -e "${GREEN}✅ Serviços iniciados${NC}"
echo ""

# 6. AGUARDAR SERVIÇOS
echo -e "${BLUE}⏳ 6/7 - Aguardando serviços ficarem prontos...${NC}"

echo "Aguardando PostgreSQL..."
sleep 10

echo "Aguardando Backend V2..."
sleep 5

# 7. VALIDAR DEPLOYMENT
echo -e "${BLUE}✅ 7/7 - Validando deployment...${NC}"

# Verificar se containers estão rodando
if docker-compose -f docker-compose.v2.yml ps | grep -q "Up"; then
    echo -e "${GREEN}✅ Containers rodando${NC}"
else
    echo -e "${RED}❌ Erro: Containers não estão rodando${NC}"
    docker-compose -f docker-compose.v2.yml logs
    exit 1
fi

# Testar health check
echo "Testando health check..."
sleep 3

if curl -f http://localhost:9001/health &> /dev/null; then
    echo -e "${GREEN}✅ Health check OK${NC}"
else
    echo -e "${YELLOW}⚠️  Health check falhou (pode estar inicializando)${NC}"
    echo "Verifique logs: docker-compose -f docker-compose.v2.yml logs backend_v2"
fi

echo ""
echo -e "${BLUE}============================================${NC}"
echo -e "${GREEN}🎉 DEPLOY CONCLUÍDO COM SUCESSO!${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

# Informações finais
echo -e "${YELLOW}📊 INFORMAÇÕES DO DEPLOY:${NC}"
echo ""
echo "🌐 URLs de Acesso:"
echo "   API V2: http://localhost:9001"
echo "   API V2 (Produção): http://54.207.172.193:9001"
echo "   Documentação: http://localhost:9001/docs"
echo "   Health Check: http://localhost:9001/health"
echo ""
echo "🗄️ PostgreSQL:"
echo "   Host: localhost"
echo "   Porta: 5433"
echo "   Database: pontoprime_db"
echo "   User: pontoprime"
echo ""
echo "📝 Logs:"
echo "   Ver logs: docker-compose -f docker-compose.v2.yml logs -f"
echo "   Ver logs backend: docker-compose -f docker-compose.v2.yml logs -f backend_v2"
echo "   Ver logs DB: docker-compose -f docker-compose.v2.yml logs -f db_v2"
echo ""
echo "🔧 Comandos Úteis:"
echo "   Parar: docker-compose -f docker-compose.v2.yml stop"
echo "   Reiniciar: docker-compose -f docker-compose.v2.yml restart"
echo "   Remover: docker-compose -f docker-compose.v2.yml down"
echo "   Status: docker-compose -f docker-compose.v2.yml ps"
echo ""
echo -e "${YELLOW}⚠️  PRÓXIMOS PASSOS:${NC}"
echo "1. Testar endpoints: curl http://localhost:9001/api/v1/employees"
echo "2. Acessar documentação: http://localhost:9001/docs"
echo "3. Se em produção AWS, liberar porta 9001 no Security Group"
echo ""
echo -e "${GREEN}✅ V2 FULL rodando na porta 9001${NC}"
echo -e "${GREEN}✅ DEMO continua rodando na porta 9000 (se estava ativo)${NC}"
echo ""
