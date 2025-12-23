#!/bin/bash
# Script para gerar PDF da proposta comercial PontoPrime

echo "🎨 Gerando PDF da Proposta Comercial PontoPrime..."

# Verificar se wkhtmltopdf está instalado
if ! command -v wkhtmltopdf &> /dev/null; then
    echo "📦 Instalando wkhtmltopdf..."
    sudo apt-get update
    sudo apt-get install -y wkhtmltopdf
fi

# Gerar PDF
wkhtmltopdf \
    --page-size A4 \
    --margin-top 0 \
    --margin-bottom 0 \
    --margin-left 0 \
    --margin-right 0 \
    --enable-local-file-access \
    --print-media-type \
    --no-stop-slow-scripts \
    --javascript-delay 1000 \
    PROPOSTA_COMERCIAL_PONTOPRIME.html \
    PROPOSTA_COMERCIAL_PONTOPRIME.pdf

if [ $? -eq 0 ]; then
    echo "✅ PDF gerado com sucesso!"
    echo "📄 Arquivo: PROPOSTA_COMERCIAL_PONTOPRIME.pdf"
    ls -lh PROPOSTA_COMERCIAL_PONTOPRIME.pdf
else
    echo "❌ Erro ao gerar PDF"
    echo ""
    echo "💡 Alternativa: Abra o arquivo HTML no navegador e use 'Imprimir > Salvar como PDF'"
    echo "   Arquivo HTML: PROPOSTA_COMERCIAL_PONTOPRIME.html"
fi
