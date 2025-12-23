#!/bin/bash
# ==============================================================================
# PONTOPRIME - DEPLOY SCRIPT (DOCKER)
# ==============================================================================
# Script automatizado para deploy da versão Dockerizada
# Uso: ./deploy-docker.sh [start|stop|restart|logs|status]
# ==============================================================================

set -e  # Exit on error

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Diretórios
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKEND_DIR="$PROJECT_ROOT/src/backend"

# Funções de log
log_info() { echo -e "${BLUE}ℹ${NC} $1"; }
log_success() { echo -e "${GREEN}✓${NC} $1"; }
log_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
log_error() { echo -e "${RED}✗${NC} $1"; }

# Banner
print_banner() {
    echo -e "${BLUE}"
    cat << "EOF"
╔═══════════════════════════════════════════╗
║     PONTOPRIME - DEPLOY DOCKER            ║
║     Cliente: PLANTHERM                    ║
╚═══════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Verificar se Docker está instalado
check_docker() {
    if ! command -v docker &> /dev/null; then
        log_error "Docker não está instalado!"
        log_info "Instale com: curl -fsSL https://get.docker.com | sh"
        exit 1
    fi

    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose não está instalado!"
        exit 1
    fi

    log_success "Docker e Docker Compose instalados"
}

# Verificar arquivo .env
check_env() {
    if [ ! -f "$BACKEND_DIR/.env" ]; then
        log_warning "Arquivo .env não encontrado!"
        log_info "Copiando .env.example para .env..."
        cp "$BACKEND_DIR/.env.example" "$BACKEND_DIR/.env"
        log_warning "ATENÇÃO: Edite $BACKEND_DIR/.env com valores reais antes de continuar!"
        exit 1
    fi
    log_success "Arquivo .env encontrado"
}

# Gerar certificado SSL self-signed
generate_ssl() {
    SSL_DIR="$BACKEND_DIR/ssl"

    if [ ! -f "$SSL_DIR/cert.pem" ]; then
        log_info "Gerando certificado SSL self-signed..."
        mkdir -p "$SSL_DIR"

        openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
            -keyout "$SSL_DIR/key.pem" \
            -out "$SSL_DIR/cert.pem" \
            -subj "/C=BR/ST=SP/L=SaoPaulo/O=PLANTHERM/CN=pontoprime.local" \
            2>/dev/null

        log_success "Certificado SSL gerado em $SSL_DIR"
    else
        log_success "Certificado SSL já existe"
    fi
}

# Start containers
start() {
    log_info "Iniciando containers..."
    cd "$BACKEND_DIR"

    docker-compose up -d --build

    log_success "Containers iniciados!"
    log_info "Aguardando backend ficar pronto..."
    sleep 10

    # Verificar saúde
    if docker-compose ps | grep -q "Up"; then
        log_success "Todos os containers estão rodando!"
        show_urls
    else
        log_error "Alguns containers falharam ao iniciar"
        docker-compose logs
        exit 1
    fi
}

# Stop containers
stop() {
    log_info "Parando containers..."
    cd "$BACKEND_DIR"
    docker-compose down
    log_success "Containers parados!"
}

# Restart containers
restart() {
    log_info "Reiniciando containers..."
    stop
    sleep 2
    start
}

# Show logs
show_logs() {
    cd "$BACKEND_DIR"
    docker-compose logs -f --tail=100
}

# Show status
show_status() {
    cd "$BACKEND_DIR"
    echo ""
    log_info "Status dos containers:"
    docker-compose ps
    echo ""
    log_info "Uso de recursos:"
    docker stats --no-stream $(docker-compose ps -q)
}

# Show URLs
show_urls() {
    echo ""
    log_success "=== URLs DE ACESSO ==="
    echo "  📊 API Backend:     http://54.207.172.193:9000"
    echo "  📖 API Docs:        http://54.207.172.193:9000/docs"
    echo "  💚 Health Check:    http://54.207.172.193:9000/health"
    echo "  🌐 Painel Web:      http://54.207.172.193:9000/painel/"
    echo "  🔒 HTTPS (Nginx):   https://54.207.172.193"
    echo ""
}

# Main
main() {
    print_banner
    check_docker
    check_env
    generate_ssl

    case "${1:-start}" in
        start)
            start
            ;;
        stop)
            stop
            ;;
        restart)
            restart
            ;;
        logs)
            show_logs
            ;;
        status)
            show_status
            ;;
        urls)
            show_urls
            ;;
        *)
            log_error "Comando inválido: $1"
            echo "Uso: $0 {start|stop|restart|logs|status|urls}"
            exit 1
            ;;
    esac
}

main "$@"
