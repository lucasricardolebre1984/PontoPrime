# Instruções de Deploy do PontoPrime - Finalização

## Status Atual
✅ Backend FastAPI rodando em produção (AWS): `http://54.207.172.193:9000`
✅ APK Android compilado com sucesso
⚠️ Falta: Upload do APK para FTP KingHost
⚠️ Falta: Verificar acessibilidade do painel web

## Problema Identificado
O ambiente atual (Claude Code sandbox) tem restrições de rede que impedem:
- Acesso ao FTP do KingHost (automaniaai.com.br não está na lista de hosts permitidos)
- Download de dependências para rebuild do APK

## Solução: Upload Manual do APK

### Opção 1: Upload do Servidor AWS Ubuntu

Se você está no servidor AWS onde o backend está rodando:

```bash
# 1. Verificar se o APK existe
ls -lh ~/pontoprime.apk

# 2. Se não existir, compilar novamente
cd /caminho/para/PontoPrime/src/android
./gradlew clean assembleRelease

# 3. Copiar APK para diretório home
cp app/build/outputs/apk/release/app-release-unsigned.apk ~/pontoprime.apk

# 4. Instalar cliente FTP (se necessário)
sudo apt-get update && sudo apt-get install -y ftp lftp

# 5. Conectar ao FTP KingHost
ftp ftp.automaniaai.com.br
# Usuário: automaniaai
# Senha: L@leli99

# 6. Dentro do FTP, navegar e fazer upload
ftp> cd public_html
ftp> cd propostas
ftp> cd andre
ftp> binary
ftp> put /home/ubuntu/pontoprime.apk
ftp> ls
ftp> bye
```

**Nota sobre o caminho FTP:** Se o caminho `/propostas/andre` não existir, você precisará criar ou usar o caminho correto. Experimente:
- `cd public_html` ou `cd www`
- `mkdir propostas` (se não existir)
- `cd propostas`
- `mkdir andre`
- `cd andre`

### Opção 2: Upload via LFTP (mais fácil)

```bash
# Instalar lftp
sudo apt-get install -y lftp

# Upload direto com comando único
lftp -u automaniaai,L@leli99 ftp.automaniaai.com.br << EOF
set ssl:verify-certificate no
cd public_html/propostas/andre
put ~/pontoprime.apk
ls
bye
EOF
```

### Opção 3: Upload via cURL

```bash
# Tentar diferentes caminhos até encontrar o correto
curl -T ~/pontoprime.apk \
  ftp://ftp.automaniaai.com.br/public_html/propostas/andre/ \
  --user automaniaai:L@leli99 \
  --ftp-create-dirs

# Se falhar, tente sem subdiretórios
curl -T ~/pontoprime.apk \
  ftp://ftp.automaniaai.com.br/public_html/ \
  --user automaniaai:L@leli99
```

### Opção 4: Upload do seu Mac/PC local

Se você tem o APK no seu computador:

1. **Via FileZilla (GUI):**
   - Host: `ftp.automaniaai.com.br`
   - Usuário: `automaniaai`
   - Senha: `L@leli99`
   - Porta: `21`
   - Navegar até `/public_html/propostas/andre/`
   - Arrastar o arquivo `pontoprime.apk`

2. **Via linha de comando (Mac/Linux):**
   ```bash
   curl -T pontoprime.apk \
     ftp://ftp.automaniaai.com.br/public_html/propostas/andre/ \
     --user automaniaai:L@leli99
   ```

## Descobrir a Estrutura de Diretórios do FTP

Para entender onde fazer upload, primeiro liste o FTP:

```bash
# Listar diretório raiz do FTP
curl -l ftp://ftp.automaniaai.com.br/ --user automaniaai:L@leli99

# Listar public_html
curl -l ftp://ftp.automaniaai.com.br/public_html/ --user automaniaai:L@leli99

# Listar propostas
curl -l ftp://ftp.automaniaai.com.br/public_html/propostas/ --user automaniaai:L@leli99
```

## Verificar Painel Web

Depois de fazer upload do APK, verifique se o painel web está acessível:

```bash
# Do servidor AWS ou seu computador
curl -I https://automaniaai.com.br/propostas/andre/painel.html
```

URLs esperadas:
- Painel Web: `https://automaniaai.com.br/propostas/andre/painel.html`
- APK Download: `https://automaniaai.com.br/propostas/andre/pontoprime.apk`
- Backend API: `http://54.207.172.193:9000/docs`

## Testar Integração Completa

Após upload bem-sucedido:

1. **Testar Backend:**
   ```bash
   curl http://54.207.172.193:9000/health
   ```

2. **Verificar Painel Web:**
   - Abrir: `https://automaniaai.com.br/propostas/andre/painel.html`
   - Deve carregar a interface administrativa

3. **Testar APK:**
   - Baixar: `https://automaniaai.com.br/propostas/andre/pontoprime.apk`
   - Instalar no dispositivo Android
   - Abrir app e verificar conexão com backend

## Credenciais FTP

- **Host FTP:** `ftp.automaniaai.com.br`
- **Usuário:** `automaniaai`
- **Senha:** `L@leli99`
- **Caminho provável:** `/public_html/propostas/andre/` ou `/www/propostas/andre/`

## Informações do Backend

- **IP Servidor:** `54.207.172.193`
- **Porta:** `9000`
- **API Docs:** `http://54.207.172.193:9000/docs`
- **Status:** ✅ Rodando com uvicorn em background

## Próximos Passos

1. ✅ Conectar ao servidor AWS via SSH
2. ⬜ Descobrir estrutura do FTP KingHost
3. ⬜ Fazer upload do APK para FTP
4. ⬜ Fazer upload do painel web (painel.html) se ainda não feito
5. ⬜ Verificar URLs públicas (painel e APK)
6. ⬜ Testar aplicativo Android
7. ⬜ Testar fluxo completo de registro de ponto

## Suporte

Se algum comando falhar:
1. Verifique se está no servidor correto
2. Confirme que o arquivo APK existe
3. Teste conexão FTP manualmente com: `ftp ftp.automaniaai.com.br`
4. Verifique com KingHost qual é o caminho correto do FTP
