# 🚀 Quick Start - Deploy Final

## ✅ Status Atual

- **Backend API**: ✅ Rodando em `http://54.207.172.193:9000`
- **Firewall UFW**: ✅ Configurado e ativo
- **Painel Web**: ⚠️ Aguardando upload para FTP
- **APK Android**: ⚠️ Aguardando upload para FTP

## 📋 O que falta fazer

Você precisa fazer upload dos seguintes arquivos para o FTP do KingHost:

1. **Painel Web** (src/web/*)
   - painel.html
   - assets/ (CSS, JS, imagens)

2. **APK Android**
   - pontoprime.apk (precisa compilar primeiro)

## 🎯 Opção Mais Simples: Script Automático

**No servidor AWS Ubuntu**, execute:

```bash
cd /caminho/para/PontoPrime
./deploy-ftp.sh
```

Escolha a opção **3** para fazer upload completo (painel + APK).

## 📝 Opção Manual

Se preferir fazer passo a passo, siga: [DEPLOY_INSTRUCTIONS.md](./DEPLOY_INSTRUCTIONS.md)

## 🔍 Depois do Upload

Verifique se tudo está acessível:

1. **Painel Web**: https://automaniaai.com.br/propostas/andre/painel.html
2. **APK Download**: https://automaniaai.com.br/propostas/andre/pontoprime.apk
3. **API Docs**: http://54.207.172.193:9000/docs

## ⚠️ Problema Atual

Este ambiente (Claude Code) tem restrições de rede que impedem:
- Conexão com o FTP do KingHost (domínio não está na whitelist do proxy)
- Download de dependências Gradle para compilar o APK

**Solução**: Execute o script `deploy-ftp.sh` diretamente no seu **servidor AWS Ubuntu** onde o backend está rodando, pois ele tem acesso total à internet.

## 🆘 Suporte

Se tiver dúvidas sobre:
- Caminho do FTP: Consulte a documentação do KingHost ou suporte
- Credenciais: Verifique em DEPLOY_INSTRUCTIONS.md
- Erros de conexão: Tente opção 1 do script para testar FTP

## 📞 Contato

- **Desenvolvedor**: AutoManiaAI
- **Cliente**: André Engenharia
- **Prazo Demo**: 7 dias
