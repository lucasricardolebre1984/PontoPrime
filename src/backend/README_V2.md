# PontoPrime Backend V2 - PostgreSQL Full

**Versão Profissional com Banco de Dados Real**

---

## 🚀 O que mudou da V1 para V2?

### V1 (DEMO - main_production.py)
- ❌ Armazenamento em memória (dados perdidos ao reiniciar)
- ❌ Sem gerenciamento de funcionários
- ❌ Sem autenticação
- ❌ Sem persistência de dados

### V2 (FULL - main_v2.py)
- ✅ **PostgreSQL real** com persistência total
- ✅ **CRUD completo de funcionários**
- ✅ **Migrations com Alembic**
- ✅ **Schema profissional** (Companies, Employees, PunchRecords, Users, AuditLogs)
- ✅ **Paginação e filtros avançados**
- ✅ **Docker Compose** com PostgreSQL + Backend + Nginx
- ✅ **Health checks** e monitoramento

---

## 📦 Estrutura de Arquivos

```
src/backend/
├── main_v2.py              # 🆕 API V2 com PostgreSQL
├── main_production.py      # Versão antiga (memória)
├── models.py               # 🆕 SQLAlchemy models
├── database.py             # 🆕 Database config
├── requirements.txt        # 🆕 Atualizado com SQLAlchemy + Alembic
├── Dockerfile              # 🆕 Atualizado para V2
├── docker-compose.yml      # 🆕 PostgreSQL + Backend + Nginx
├── nginx.conf              # Reverse proxy
├── .env.example            # Variáveis de ambiente
├── alembic.ini             # 🆕 Config de migrations
├── alembic/                # 🆕 Pasta de migrations
│   ├── env.py
│   ├── script.py.mako
│   └── versions/
│       └── 2025_12_23_0000-001_initial_schema.py
├── migrate.sh              # 🆕 Helper para migrations
└── init.sql                # Seed data inicial
```

---

## 🔧 Instalação e Configuração

### Opção 1: Docker Compose (Recomendado - Produção)

```bash
# 1. Configurar variáveis de ambiente
cd src/backend
cp .env.example .env

# 2. Editar .env com suas credenciais
nano .env

# 3. Subir toda a infraestrutura
docker-compose up -d

# 4. Verificar logs
docker-compose logs -f backend

# 5. Acessar
# API: http://54.207.172.193:9000
# Docs: http://54.207.172.193:9000/docs
# Painel: http://54.207.172.193:9000/painel/
```

### Opção 2: Desenvolvimento Local (Sem Docker)

```bash
# 1. Instalar PostgreSQL localmente
sudo apt install postgresql postgresql-contrib

# 2. Criar banco de dados
sudo -u postgres psql
CREATE DATABASE pontoprime_db;
CREATE USER pontoprime WITH PASSWORD 'pontoprime2025';
GRANT ALL PRIVILEGES ON DATABASE pontoprime_db TO pontoprime;
\q

# 3. Criar ambiente virtual
cd src/backend
python3 -m venv venv
source venv/bin/activate

# 4. Instalar dependências
pip install -r requirements.txt

# 5. Configurar .env
cp .env.example .env
# Editar DATABASE_URL para apontar para localhost

# 6. Rodar migrations
./migrate.sh upgrade

# 7. (Opcional) Popular com dados de teste
psql -h localhost -U pontoprime -d pontoprime_db -f init.sql

# 8. Iniciar servidor
python main_v2.py
```

---

## 🗄️ Gerenciamento de Migrations

### Script Helper (migrate.sh)

```bash
# Ver comandos disponíveis
./migrate.sh help

# Aplicar migrations
./migrate.sh upgrade

# Ver status atual
./migrate.sh current

# Ver histórico
./migrate.sh history

# Criar nova migration
./migrate.sh revision "adicionar campo X"

# Reverter última migration
./migrate.sh downgrade

# Resetar banco (CUIDADO!)
./migrate.sh reset
```

### Comandos Alembic Diretos

```bash
# Aplicar todas as migrations
alembic upgrade head

# Criar migration automática
alembic revision --autogenerate -m "descrição"

# Ver revisão atual
alembic current

# Histórico de migrations
alembic history --verbose

# Reverter para versão específica
alembic downgrade <revision_id>

# Resetar para estado inicial
alembic downgrade base
```

---

## 📊 Novos Endpoints API

### Funcionários (CRUD Completo)

#### Listar Funcionários
```http
GET /api/v1/employees?active_only=true
```

**Response:**
```json
[
  {
    "id": 1,
    "employee_code": "001",
    "name": "André - Gerente",
    "cpf": "111.111.111-11",
    "email": "andre@plantherm.com",
    "phone": null,
    "department": "Administração",
    "position": "Gerente Geral",
    "is_active": true,
    "created_at": "2025-12-23T00:00:00"
  }
]
```

#### Buscar Funcionário
```http
GET /api/v1/employees/{employee_id}
```

#### Criar Funcionário
```http
POST /api/v1/employees
Content-Type: application/json

{
  "employee_code": "005",
  "name": "Carlos Oliveira",
  "cpf": "555.555.555-55",
  "email": "carlos@plantherm.com",
  "phone": "(11) 98888-8888",
  "department": "Operações",
  "position": "Supervisor",
  "company_id": 1
}
```

#### Atualizar Funcionário
```http
PATCH /api/v1/employees/{employee_id}
Content-Type: application/json

{
  "phone": "(11) 99999-9999",
  "department": "Manutenção"
}
```

#### Desativar Funcionário
```http
DELETE /api/v1/employees/{employee_id}
```

### Registros de Ponto (Melhorados)

#### Criar Registro (V2 - Com validações)
```http
POST /api/v1/punch-record
Content-Type: application/json

{
  "employee_id": 1,
  "timestamp": "2025-12-23T10:30:00",
  "latitude": -23.5505,
  "longitude": -46.6333,
  "device_id": "android-abc123",
  "biometric_verified": true
}
```

**V2 Validações:**
- ✅ Verifica se funcionário existe
- ✅ Verifica se funcionário está ativo
- ✅ Salva no PostgreSQL (persistente)
- ✅ Registra biometria verificada
- ✅ Retorna objeto completo

#### Listar Todos os Registros (Paginado)
```http
GET /api/v1/all-records?limit=50&offset=0
```

**Response:**
```json
{
  "total_employees": 4,
  "total_records": 125,
  "limit": 50,
  "offset": 0,
  "records": [
    {
      "id": 1,
      "employee_id": 1,
      "employee_name": "André - Gerente",
      "employee_code": "001",
      "timestamp": "2025-12-23T10:30:00",
      "latitude": -23.5505,
      "longitude": -46.6333,
      "biometric_verified": true,
      "status": "valid",
      "created_at": "2025-12-23T10:30:05"
    }
  ]
}
```

---

## 🧪 Testes

### Testar Health Check
```bash
curl http://localhost:9000/health
```

**Response esperado:**
```json
{
  "status": "healthy",
  "timestamp": "2025-12-23T10:00:00",
  "database": "connected",
  "total_records": 0,
  "total_employees": 4
}
```

### Testar Criação de Funcionário
```bash
curl -X POST http://localhost:9000/api/v1/employees \
  -H "Content-Type: application/json" \
  -d '{
    "employee_code": "999",
    "name": "Teste API",
    "email": "teste@plantherm.com",
    "department": "QA",
    "position": "Tester"
  }'
```

### Testar Registro de Ponto
```bash
curl -X POST http://localhost:9000/api/v1/punch-record \
  -H "Content-Type: application/json" \
  -d '{
    "employee_id": 1,
    "timestamp": "2025-12-23T10:30:00",
    "latitude": -23.5505,
    "longitude": -46.6333,
    "biometric_verified": true
  }'
```

---

## 🐳 Docker Compose

### Comandos Úteis

```bash
# Subir serviços
docker-compose up -d

# Ver logs
docker-compose logs -f
docker-compose logs -f backend
docker-compose logs -f db

# Parar serviços
docker-compose stop

# Remover tudo
docker-compose down

# Rebuild (após mudanças no código)
docker-compose up -d --build

# Acessar shell do container
docker-compose exec backend sh
docker-compose exec db psql -U pontoprime -d pontoprime_db

# Ver status
docker-compose ps
```

### Verificar Banco de Dados

```bash
# Acessar PostgreSQL
docker-compose exec db psql -U pontoprime -d pontoprime_db

# Ver tabelas
\dt

# Ver funcionários
SELECT * FROM employees;

# Ver registros
SELECT * FROM punch_records;

# Sair
\q
```

---

## 📝 Variáveis de Ambiente (.env)

```env
# Database
DB_USER=pontoprime
DB_PASSWORD=pontoprime2025
DB_NAME=pontoprime_db
DATABASE_URL=postgresql://pontoprime:pontoprime2025@db:5432/pontoprime_db

# Security
JWT_SECRET=change-this-secret-in-production-use-long-random-string
JWT_ALGORITHM=HS256
JWT_EXPIRATION=30

# Application
ENVIRONMENT=production
DEBUG=false
LOG_LEVEL=info

# CORS
ALLOWED_ORIGINS=*
```

---

## 🔐 Segurança (TODO - Próximas versões)

- [ ] Implementar autenticação JWT
- [ ] Hash de senhas com bcrypt
- [ ] Rate limiting
- [ ] HTTPS obrigatório
- [ ] Validação de biometria real
- [ ] Criptografia de dados sensíveis

---

## 📈 Monitoramento

### Health Checks

- **Root**: `GET /` - Status geral + DB connection
- **Health**: `GET /health` - Health check detalhado

### Logs

```bash
# Ver logs do backend
docker-compose logs -f backend

# Ver logs do PostgreSQL
docker-compose logs -f db

# Logs salvos em arquivo
tail -f logs/backend.log
```

---

## 🚀 Deploy em Produção (AWS EC2)

```bash
# 1. SSH no servidor
ssh ubuntu@54.207.172.193

# 2. Atualizar código
cd ~/PontoPrime
git pull origin main

# 3. Rebuild e restart
cd src/backend
docker-compose down
docker-compose up -d --build

# 4. Verificar
curl http://localhost:9000/health
docker-compose logs -f backend
```

---

## 📞 Suporte

**Desenvolvedor:** AutoManiaAI
**Cliente:** PLANTHERM
**Ambiente:** AWS EC2 - 54.207.172.193
**Porta:** 9000

---

## 📄 Changelog

### V2.0.0-FULL (2025-12-23)
- ✅ PostgreSQL real substituindo memória
- ✅ CRUD completo de funcionários
- ✅ Migrations com Alembic
- ✅ Schema profissional (5 tabelas)
- ✅ Docker Compose completo
- ✅ Validações e health checks
- ✅ Paginação e filtros

### V1.0.0-DEMO (2025-12-21)
- ✅ MVP funcional
- ✅ Armazenamento em memória
- ✅ Endpoints básicos
