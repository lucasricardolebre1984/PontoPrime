# 🚀 GUIA DE TESTE E DEPLOY - VERSÃO FULL (V2)

**Data:** 24/12/2025
**Versão:** 2.0.0-FULL
**Cliente:** PLANTHERM

---

## ✅ ARQUIVOS DE DEPLOY - VERIFICAÇÃO

### Arquivos CORRETOS para V2 FULL:

| Arquivo | Status | Descrição |
|---------|--------|-----------|
| `Dockerfile.v2` | ✅ Correto | Multi-stage, porta 9001, roda migrations |
| `docker-compose.v2.yml` | ✅ Correto | PostgreSQL + Backend + Nginx, porta 9001 |
| `deploy_v2.sh` | ✅ Correto | Script automatizado completo |
| `main_v2.py` | ✅ Correto | API V2 com PostgreSQL |
| `requirements.txt` | ✅ Atualizado | Inclui slowapi, reportlab, openpyxl |

**Separação DEMO vs FULL:**
- ✅ DEMO usa `Dockerfile` + `docker-compose.yml` (porta 9000)
- ✅ FULL usa `Dockerfile.v2` + `docker-compose.v2.yml` (porta 9001)
- ✅ Podem rodar simultaneamente SEM conflitos

---

## 🐳 TESTE 1: DEPLOY LOCAL DA V2

### Comando Único (Recomendado):

```bash
cd /home/user/PontoPrime
./deploy_v2.sh
```

**O que o script faz:**
1. ✅ Verifica pré-requisitos (Docker, Docker Compose)
2. ✅ Cria `.env` com credenciais seguras (se não existir)
3. ✅ Build das imagens Docker
4. ✅ Sobe PostgreSQL + Backend V2 + Nginx
5. ✅ Aguarda serviços ficarem prontos
6. ✅ Valida deployment (health checks)

### Comando Manual (Alternativo):

```bash
cd /home/user/PontoPrime/src/backend

# 1. Criar .env (se não existir)
cat > .env << EOF
DB_USER=pontoprime
DB_PASSWORD=$(openssl rand -base64 16 | tr -d "=+/" | cut -c1-20)
DB_NAME=pontoprime_db
JWT_SECRET=$(openssl rand -hex 32)
JWT_ALGORITHM=HS256
JWT_EXPIRATION=30
ENVIRONMENT=production
DEBUG=false
LOG_LEVEL=info
ALLOWED_ORIGINS=*
EOF

# 2. Build e subir serviços
docker-compose -f docker-compose.v2.yml up -d --build

# 3. Ver logs
docker-compose -f docker-compose.v2.yml logs -f backend_v2
```

---

## 🧪 TESTE 2: VALIDAR BACKEND V2

### Testar Endpoints:

```bash
# 1. Health Check
curl http://localhost:9001/health

# Resposta esperada:
# {
#   "status": "healthy",
#   "timestamp": "2025-12-24...",
#   "database": "connected",
#   "total_records": 0,
#   "total_employees": 4
# }

# 2. API Docs (Swagger)
xdg-open http://localhost:9001/docs
# ou
curl http://localhost:9001/docs

# 3. Listar funcionários
curl http://localhost:9001/api/v1/employees

# Resposta esperada: Array de funcionários do seed data

# 4. Criar funcionário (teste CRUD)
curl -X POST http://localhost:9001/api/v1/employees \
  -H "Content-Type: application/json" \
  -d '{
    "employee_code": "999",
    "name": "Teste API V2",
    "email": "teste@plantherm.com",
    "department": "TI",
    "position": "Desenvolvedor"
  }'

# 5. Criar registro de ponto
curl -X POST http://localhost:9001/api/v1/punch-record \
  -H "Content-Type: application/json" \
  -d '{
    "employee_id": 1,
    "timestamp": "2025-12-24T10:00:00",
    "latitude": -23.5505,
    "longitude": -46.6333,
    "biometric_verified": true
  }'
```

### Verificar PostgreSQL:

```bash
# Acessar banco de dados
docker-compose -f docker-compose.v2.yml exec db_v2 psql -U pontoprime -d pontoprime_db

# Comandos SQL:
\dt                              # Listar tabelas
SELECT * FROM companies;         # Ver empresas
SELECT * FROM employees;         # Ver funcionários
SELECT * FROM punch_records;     # Ver registros
\q                               # Sair
```

---

## 📱 TESTE 3: BUILD DO APK ANDROID

### Verificar se há Mudanças no Android:

```bash
cd /home/user/PontoPrime/src/android
git status app/
```

**IMPORTANTE:** O app Android atual **NÃO MUDOU** ainda. As implementações de Biometria Real e GPS Real ainda não foram feitas.

### Build do APK (Mesmo APK Atual):

#### Opção 1: Android Studio (Recomendado)

```bash
# 1. Abrir projeto
cd /home/user/PontoPrime/src/android
# Abrir no Android Studio

# 2. Build > Generate Signed Bundle / APK
# 3. Escolher APK
# 4. Assinar com keystore (ou criar novo)
# 5. Build > Release

# APK gerado em: app/build/outputs/apk/release/
```

#### Opção 2: Linha de Comando (Gradle)

```bash
cd /home/user/PontoPrime/src/android

# Build release
./gradlew assembleRelease

# APK gerado em:
# app/build/outputs/apk/release/app-release-unsigned.apk

# Assinar APK (opcional)
# Requer keystore configurado
```

#### Opção 3: Debug (Sem Assinatura)

```bash
cd /home/user/PontoPrime/src/android

# Build debug (rápido, não precisa assinar)
./gradlew assembleDebug

# APK gerado em:
# app/build/outputs/apk/debug/app-debug.apk
```

### Configurar API URL (se mudar porta):

**Arquivo:** `src/android/app/build.gradle`

```gradle
android {
    defaultConfig {
        // Mudar para V2 (porta 9001)
        buildConfigField "String", "API_BASE_URL", '"http://54.207.172.193:9001/api/v1/"'
    }
}
```

**Rebuild após mudança:**
```bash
./gradlew clean assembleRelease
```

---

## 🔍 TESTE 4: VERIFICAR SERVIÇOS RODANDO

### Ver Containers:

```bash
# Status de todos os serviços V2
docker-compose -f docker-compose.v2.yml ps

# Deve mostrar:
# pontoprime_db_v2        Up (healthy)
# pontoprime_backend_v2   Up (healthy)
# pontoprime_nginx_v2     Up
```

### Logs em Tempo Real:

```bash
# Todos os logs
docker-compose -f docker-compose.v2.yml logs -f

# Apenas backend
docker-compose -f docker-compose.v2.yml logs -f backend_v2

# Apenas PostgreSQL
docker-compose -f docker-compose.v2.yml logs -f db_v2
```

### Recursos:

```bash
# CPU e Memória dos containers
docker stats
```

---

## 🚨 TROUBLESHOOTING

### Problema 1: Porta 9001 já em uso

```bash
# Verificar o que está usando a porta
sudo lsof -i :9001

# Matar processo
sudo kill -9 <PID>

# Ou usar porta diferente editando docker-compose.v2.yml
```

### Problema 2: Erro ao conectar PostgreSQL

```bash
# Ver logs do DB
docker-compose -f docker-compose.v2.yml logs db_v2

# Recriar volume (APAGA DADOS!)
docker-compose -f docker-compose.v2.yml down -v
docker-compose -f docker-compose.v2.yml up -d
```

### Problema 3: Migration falha

```bash
# Rodar migrations manualmente
docker-compose -f docker-compose.v2.yml exec backend_v2 alembic upgrade head

# Ver histórico de migrations
docker-compose -f docker-compose.v2.yml exec backend_v2 alembic history
```

### Problema 4: .env não existe

```bash
# Criar .env manualmente
cd src/backend
cp .env.example .env

# Editar com credenciais
nano .env
```

---

## 📊 COMPARAÇÃO: DEMO vs FULL

### Qual Versão Está Rodando?

```bash
# DEMO (V1) - Porta 9000
curl http://localhost:9000/health

# FULL (V2) - Porta 9001
curl http://localhost:9001/health
```

### Ambas Rodando Simultaneamente:

```bash
# Terminal 1: DEMO
cd src/backend
python main_production.py

# Terminal 2: FULL
cd src/backend
docker-compose -f docker-compose.v2.yml up

# Acessar:
# DEMO: http://localhost:9000
# FULL: http://localhost:9001
```

---

## ✅ CHECKLIST DE SUCESSO

Após rodar `./deploy_v2.sh`, você deve ter:

- [ ] ✅ Health check respondendo em http://localhost:9001/health
- [ ] ✅ Swagger UI acessível em http://localhost:9001/docs
- [ ] ✅ PostgreSQL rodando (porta 6000)
- [ ] ✅ 3 containers UP (db_v2, backend_v2, nginx_v2)
- [ ] ✅ Tabelas criadas (companies, employees, punch_records, users, audit_logs)
- [ ] ✅ Funcionários seed data (4 funcionários)
- [ ] ✅ Endpoint de CRUD funcionando
- [ ] ✅ Logs sem erros

---

## 🎯 PRÓXIMOS PASSOS

### Depois do Teste Local:

1. **Deploy em Produção AWS:**
   ```bash
   ssh ubuntu@54.207.172.193
   cd ~/PontoPrime
   git pull origin claude/init-pontoprime-project-EiNV4
   cd src/backend
   docker-compose -f docker-compose.v2.yml up -d --build
   ```

2. **Liberar Porta 9001 no Security Group:**
   - AWS Console > EC2 > Security Groups
   - Adicionar regra: Porta 9001, TCP, 0.0.0.0/0

3. **Atualizar Painel Web:**
   - Mudar `config.js` para usar porta 9001
   - Adicionar UI de CRUD de funcionários

4. **Build APK com Features Novas:**
   - Implementar BiometricPrompt real
   - Implementar GPS real
   - Rebuildar APK

---

**FIM DO GUIA DE TESTE**

*Para executar agora:*
```bash
cd /home/user/PontoPrime
./deploy_v2.sh
```
