# Guia de Deploy - AWS (Servidor André)

## 📋 Informações do Servidor

- **IP Público:** 54.207.172.193
- **Porta Backend:** 9000
- **Domínio:** automaniaai.com.br
- **Cliente:** André - AutoManiaAI

---

## 🚀 Deploy Automático (Recomendado)

### Pré-requisitos
- Acesso SSH ao servidor AWS
- Chave SSH configurada
- Git instalado localmente

### Passo 1: Configurar SSH (se necessário)

```bash
# Adicionar chave SSH ao ssh-agent
ssh-add ~/.ssh/sua_chave.pem

# Ou especificar a chave no deploy
# Editar scripts/deploy_aws.sh e adicionar: -i ~/.ssh/sua_chave.pem
```

### Passo 2: Executar Deploy

```bash
# No diretório do projeto
cd /home/user/PontoPrime

# Executar script de deploy
./scripts/deploy_aws.sh
```

O script irá:
1. ✅ Criar diretórios no servidor
2. ✅ Enviar backend via SCP
3. ✅ Enviar painel web via SCP
4. ✅ Instalar dependências Python
5. ✅ Iniciar API na porta 9000
6. ✅ Verificar se está funcionando

---

## 📦 Deploy Manual (Alternativa)

### Passo 1: Conectar no Servidor

```bash
ssh ubuntu@54.207.172.193
```

### Passo 2: Criar Diretórios

```bash
sudo mkdir -p /var/www/pontoprime/{backend,web}
sudo chown -R ubuntu:ubuntu /var/www/pontoprime
```

### Passo 3: Enviar Arquivos (do seu computador local)

```bash
# Backend
scp -r src/backend/* ubuntu@54.207.172.193:/var/www/pontoprime/backend/

# Painel Web
scp -r src/web/* ubuntu@54.207.172.193:/var/www/pontoprime/web/
```

### Passo 4: Instalar Dependências (no servidor)

```bash
cd /var/www/pontoprime/backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### Passo 5: Iniciar API

```bash
# Parar processo anterior (se existir)
sudo fuser -k 9000/tcp

# Iniciar em background
cd /var/www/pontoprime/backend
nohup python3 main_production.py > api.log 2>&1 &
```

### Passo 6: Verificar se está rodando

```bash
curl http://localhost:9000/health
```

---

## 🌐 Configurar Painel Web no Apache/Nginx

### Opção 1: Pasta Direta (Recomendado para Demo)

```bash
# Copiar arquivos do painel web para pasta do site
sudo cp -r /var/www/pontoprime/web/* /var/www/automaniaai.com.br/pontoprime/andre/

# Ajustar permissões
sudo chown -R www-data:www-data /var/www/automaniaai.com.br/pontoprime/
sudo chmod -R 755 /var/www/automaniaai.com.br/pontoprime/
```

**URL de Acesso:** https://automaniaai.com.br/pontoprime/andre/

### Opção 2: Subdomínio (Opcional)

Se quiser criar um subdomínio `pontoprime.automaniaai.com.br`:

1. **Configurar DNS:**
   - Criar registro A apontando para 54.207.172.193
   - Nome: `pontoprime`
   - Tipo: A
   - Valor: 54.207.172.193

2. **Configurar Apache/Nginx:**

**Apache** (`/etc/apache2/sites-available/pontoprime.conf`):
```apache
<VirtualHost *:80>
    ServerName pontoprime.automaniaai.com.br
    DocumentRoot /var/www/pontoprime/web

    <Directory /var/www/pontoprime/web>
        Options Indexes FollowSymLinks
        AllowOverride None
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/pontoprime-error.log
    CustomLog ${APACHE_LOG_DIR}/pontoprime-access.log combined
</VirtualHost>
```

Ativar:
```bash
sudo a2ensite pontoprime.conf
sudo systemctl reload apache2
```

---

## 📱 Build do APK Android

### Passo 1: Abrir Projeto no Android Studio

```bash
cd src/android
# Abrir no Android Studio
```

### Passo 2: Atualizar URL da API

Editar `app/build.gradle` e alterar a linha:

```gradle
buildConfigField "String", "API_BASE_URL", "\"http://54.207.172.193:9000/api/v1/\""
```

### Passo 3: Build do APK

**Via Android Studio:**
1. Build > Build Bundle(s) / APK(s) > Build APK(s)
2. Aguardar build
3. Clicar em "locate" quando concluir
4. APK estará em: `app/build/outputs/apk/debug/app-debug.apk`

**Via Terminal:**
```bash
cd src/android
./gradlew assembleDebug

# APK gerado em:
# app/build/outputs/apk/debug/app-debug.apk
```

### Passo 4: Renomear e Copiar APK

```bash
# Renomear
cp app/build/outputs/apk/debug/app-debug.apk pontoprime.apk

# Copiar para pasta web
cp pontoprime.apk /caminho/para/pasta/web/
```

### Passo 5: Upload APK para Servidor

```bash
scp pontoprime.apk ubuntu@54.207.172.193:/var/www/automaniaai.com.br/pontoprime/andre/
```

---

## 🔥 Gerenciar API em Produção

### Ver Logs

```bash
ssh ubuntu@54.207.172.193
tail -f /var/www/pontoprime/backend/api.log
```

### Parar API

```bash
ssh ubuntu@54.207.172.193
sudo fuser -k 9000/tcp
```

### Reiniciar API

```bash
ssh ubuntu@54.207.172.193
cd /var/www/pontoprime/backend
sudo fuser -k 9000/tcp
nohup python3 main_production.py > api.log 2>&1 &
```

### Configurar Systemd (Iniciar Automaticamente)

Criar arquivo `/etc/systemd/system/pontoprime.service`:

```ini
[Unit]
Description=PontoPrime API
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/var/www/pontoprime/backend
ExecStart=/var/www/pontoprime/backend/venv/bin/python3 main_production.py
Restart=always

[Install]
WantedBy=multi-user.target
```

Ativar:
```bash
sudo systemctl daemon-reload
sudo systemctl enable pontoprime
sudo systemctl start pontoprime
sudo systemctl status pontoprime
```

---

## ✅ Checklist Final

- [ ] Backend rodando na porta 9000
- [ ] API acessível em http://54.207.172.193:9000
- [ ] Painel web acessível em https://automaniaai.com.br/pontoprime/andre/
- [ ] APK disponível para download
- [ ] Firewall liberado para porta 9000
- [ ] CORS configurado corretamente
- [ ] Logs sendo gerados

---

## 🐛 Troubleshooting

### API não inicia

```bash
# Verificar se a porta está em uso
sudo lsof -i :9000

# Verificar logs
tail -50 /var/www/pontoprime/backend/api.log

# Verificar se Python está instalado
python3 --version
```

### Painel web não carrega dados

1. Verificar se API está rodando: `curl http://54.207.172.193:9000/health`
2. Abrir console do navegador (F12) e verificar erros
3. Verificar URL no arquivo `src/web/assets/js/config.js`

### APK não conecta na API

1. Verificar se o IP no `build.gradle` está correto
2. Verificar se o firewall permite conexões na porta 9000
3. Verificar CORS no backend

---

## 📞 Suporte

Em caso de problemas, verificar:
- Logs do backend: `/var/www/pontoprime/backend/api.log`
- Logs do Apache: `/var/log/apache2/error.log`
- Status do serviço: `sudo systemctl status pontoprime`
