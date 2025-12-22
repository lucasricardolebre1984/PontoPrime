#!/bin/bash
# Script para fazer deploy do PontoPrime no FTP KingHost

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}   PontoPrime - Script de Deploy FTP${NC}"
echo -e "${GREEN}============================================${NC}"
echo

# Configurações FTP
FTP_HOST="ftp.automaniaai.com.br"
FTP_USER="automaniaai"
FTP_PASS="L@leli99"
FTP_PATH="/public_html/propostas/andre"

# Verificar se lftp está instalado
if ! command -v lftp &> /dev/null; then
    echo -e "${YELLOW}lftp não está instalado. Instalando...${NC}"
    sudo apt-get update && sudo apt-get install -y lftp
fi

# Função para testar conexão FTP
test_ftp_connection() {
    echo -e "${YELLOW}Testando conexão FTP...${NC}"
    lftp -u "$FTP_USER","$FTP_PASS" "$FTP_HOST" << EOF
set ssl:verify-certificate no
ls
bye
EOF

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Conexão FTP OK${NC}"
        return 0
    else
        echo -e "${RED}✗ Erro na conexão FTP${NC}"
        return 1
    fi
}

# Função para descobrir estrutura do FTP
explore_ftp() {
    echo -e "${YELLOW}Explorando estrutura do FTP...${NC}"
    echo
    echo "=== Diretório raiz ==="
    lftp -u "$FTP_USER","$FTP_PASS" "$FTP_HOST" << EOF
set ssl:verify-certificate no
ls
bye
EOF

    echo
    echo "=== Tentando acessar public_html ==="
    lftp -u "$FTP_USER","$FTP_PASS" "$FTP_HOST" << EOF
set ssl:verify-certificate no
cd public_html 2>/dev/null || cd www
ls
bye
EOF
}

# Função para upload de arquivos web
upload_web_files() {
    echo -e "${YELLOW}Fazendo upload dos arquivos do painel web...${NC}"

    lftp -u "$FTP_USER","$FTP_PASS" "$FTP_HOST" << EOF
set ssl:verify-certificate no
cd public_html || cd www
mkdir -p propostas
cd propostas
mkdir -p andre
cd andre

# Upload de arquivos
lcd src/web
put painel.html
put index.html

# Upload de assets
mkdir -p assets/js
cd assets/js
lcd assets/js
put config.js
put app.js
cd ../..

mkdir -p assets/css
cd assets/css
lcd ../css
put style.css
cd ../..

mkdir -p assets/img
cd assets/img
lcd ../img
put logo-automaniaai.svg
put logo-andre-engenharia.svg
cd ../..

ls -la
bye
EOF

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Arquivos web enviados com sucesso${NC}"
        return 0
    else
        echo -e "${RED}✗ Erro no upload dos arquivos web${NC}"
        return 1
    fi
}

# Função para upload do APK
upload_apk() {
    echo -e "${YELLOW}Fazendo upload do APK...${NC}"

    # Procurar APK
    APK_PATH=""
    if [ -f ~/pontoprime.apk ]; then
        APK_PATH=~/pontoprime.apk
    elif [ -f pontoprime.apk ]; then
        APK_PATH=pontoprime.apk
    elif [ -f src/android/app/build/outputs/apk/release/app-release-unsigned.apk ]; then
        APK_PATH=src/android/app/build/outputs/apk/release/app-release-unsigned.apk
    fi

    if [ -z "$APK_PATH" ]; then
        echo -e "${RED}✗ APK não encontrado!${NC}"
        echo "Compile o APK primeiro com:"
        echo "cd src/android && ./gradlew assembleRelease"
        return 1
    fi

    echo "APK encontrado: $APK_PATH"

    lftp -u "$FTP_USER","$FTP_PASS" "$FTP_HOST" << EOF
set ssl:verify-certificate no
cd public_html || cd www
cd propostas/andre
binary
put "$APK_PATH" -o pontoprime.apk
ls -lh pontoprime.apk
bye
EOF

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ APK enviado com sucesso${NC}"
        return 0
    else
        echo -e "${RED}✗ Erro no upload do APK${NC}"
        return 1
    fi
}

# Função para verificar URLs públicas
verify_urls() {
    echo -e "${YELLOW}Verificando URLs públicas...${NC}"

    echo -e "\n📄 Painel Web:"
    curl -I https://automaniaai.com.br/propostas/andre/painel.html 2>&1 | head -1

    echo -e "\n📱 APK Download:"
    curl -I https://automaniaai.com.br/propostas/andre/pontoprime.apk 2>&1 | head -1

    echo -e "\n🔌 Backend API:"
    curl -I http://54.207.172.193:9000/docs 2>&1 | head -1

    echo
}

# Menu principal
echo "Escolha uma opção:"
echo "1) Testar conexão FTP"
echo "2) Explorar estrutura do FTP"
echo "3) Upload completo (painel web + APK)"
echo "4) Upload apenas painel web"
echo "5) Upload apenas APK"
echo "6) Verificar URLs públicas"
echo "0) Sair"
echo

read -p "Opção: " option

case $option in
    1)
        test_ftp_connection
        ;;
    2)
        explore_ftp
        ;;
    3)
        test_ftp_connection && upload_web_files && upload_apk && verify_urls
        ;;
    4)
        upload_web_files && verify_urls
        ;;
    5)
        upload_apk && verify_urls
        ;;
    6)
        verify_urls
        ;;
    0)
        echo "Saindo..."
        exit 0
        ;;
    *)
        echo -e "${RED}Opção inválida${NC}"
        exit 1
        ;;
esac

echo
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}Deploy concluído!${NC}"
echo -e "${GREEN}============================================${NC}"
echo
echo "URLs do projeto:"
echo "  📄 Painel: https://automaniaai.com.br/propostas/andre/painel.html"
echo "  📱 APK: https://automaniaai.com.br/propostas/andre/pontoprime.apk"
echo "  🔌 API: http://54.207.172.193:9000/docs"
echo
