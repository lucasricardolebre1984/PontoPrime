#!/bin/bash
# Migration helper script - PontoPrime Database Migrations

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🗄️  PontoPrime - Database Migration Tool${NC}"
echo ""

# Função de ajuda
show_help() {
    echo "Uso: ./migrate.sh [comando]"
    echo ""
    echo "Comandos disponíveis:"
    echo "  init          - Inicializa o Alembic (primeira vez)"
    echo "  current       - Mostra a revisão atual do banco"
    echo "  history       - Mostra histórico de migrations"
    echo "  upgrade       - Aplica todas as migrations pendentes"
    echo "  downgrade     - Reverte a última migration"
    echo "  revision      - Cria nova migration (com autogenerate)"
    echo "  reset         - Reseta o banco (CUIDADO: apaga tudo)"
    echo ""
    echo "Exemplos:"
    echo "  ./migrate.sh upgrade          # Aplica migrations"
    echo "  ./migrate.sh revision         # Cria nova migration"
    echo ""
}

# Verifica se está no diretório correto
if [ ! -f "alembic.ini" ]; then
    echo -e "${RED}❌ Erro: alembic.ini não encontrado!${NC}"
    echo "Execute este script de dentro de src/backend/"
    exit 1
fi

# Processa comando
case "$1" in
    init)
        echo -e "${YELLOW}📦 Inicializando Alembic...${NC}"
        alembic upgrade head
        echo -e "${GREEN}✅ Alembic inicializado!${NC}"
        ;;

    current)
        echo -e "${YELLOW}📍 Revisão atual:${NC}"
        alembic current
        ;;

    history)
        echo -e "${YELLOW}📜 Histórico de migrations:${NC}"
        alembic history --verbose
        ;;

    upgrade)
        echo -e "${YELLOW}⬆️  Aplicando migrations...${NC}"
        alembic upgrade head
        echo -e "${GREEN}✅ Migrations aplicadas com sucesso!${NC}"
        ;;

    downgrade)
        echo -e "${YELLOW}⬇️  Revertendo última migration...${NC}"
        alembic downgrade -1
        echo -e "${GREEN}✅ Migration revertida!${NC}"
        ;;

    revision)
        if [ -z "$2" ]; then
            echo -e "${RED}❌ Erro: mensagem da migration é obrigatória${NC}"
            echo "Uso: ./migrate.sh revision \"descrição da mudança\""
            exit 1
        fi
        echo -e "${YELLOW}📝 Criando nova migration...${NC}"
        alembic revision --autogenerate -m "$2"
        echo -e "${GREEN}✅ Migration criada!${NC}"
        ;;

    reset)
        echo -e "${RED}⚠️  ATENÇÃO: Isso vai apagar TODOS os dados!${NC}"
        read -p "Tem certeza? (digite 'yes' para confirmar): " confirm
        if [ "$confirm" = "yes" ]; then
            echo -e "${YELLOW}🔄 Resetando banco de dados...${NC}"
            alembic downgrade base
            alembic upgrade head
            echo -e "${GREEN}✅ Banco resetado!${NC}"
        else
            echo -e "${YELLOW}❌ Operação cancelada${NC}"
        fi
        ;;

    help|--help|-h|"")
        show_help
        ;;

    *)
        echo -e "${RED}❌ Comando desconhecido: $1${NC}"
        echo ""
        show_help
        exit 1
        ;;
esac
