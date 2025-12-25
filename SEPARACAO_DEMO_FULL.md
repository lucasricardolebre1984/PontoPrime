# 🔀 Separação: DEMO vs VERSÃO FULL

Este documento explica como rodar as duas versões do PontoPrime **completamente separadas** e em paralelo.

---

## 📋 Resumo das Versões

| Característica | DEMO (V1) | FULL (V2) |
|----------------|-----------|-----------|
| **Porta** | 9000 | 9001 |
| **Arquivo Principal** | `main_production.py` | `main_v2.py` |
| **Dockerfile** | `Dockerfile` | `Dockerfile.v2` |
| **Docker Compose** | `docker-compose.yml` | `docker-compose.v2.yml` |
| **Banco de Dados** | Memória (perde ao reiniciar) | PostgreSQL (persistente) |
| **PostgreSQL Porta** | - | 6000 |
| **Nginx HTTP** | 80 | 8080 |
| **Nginx HTTPS** | 443 | 8443 |
| **Uso** | Testes de novos clientes | Produção profissional |

---

## 🎯 DEMO (V1) - Para Novos Clientes

### Objetivo
Versão **simplificada e imutável** para demonstrações rápidas.

### Como Rodar

#### Opção 1: Direto com Python (Recomendado para DEMO)
```bash
cd src/backend
python main_production.py
```

**URLs:**
- API: http://54.207.172.193:9000
- Docs: http://54.207.172.193:9000/docs
- Painel: http://54.207.172.193:9000/painel/

#### Opção 2: Com Docker (se necessário)
```bash
cd src/backend
docker build -t pontoprime-demo .
docker run -p 9000:9000 pontoprime-demo
```

### Características do DEMO
- ✅ Rápido de iniciar
- ✅ Sem dependências externas
- ✅ Ideal para apresentações
- ⚠️ Dados perdidos ao reiniciar
- ⚠️ Sem CRUD de funcionários

---

## 🚀 VERSÃO FULL (V2) - Para Produção

### Objetivo
Versão **profissional** com PostgreSQL, migrations e CRUD completo.

### Como Rodar

#### Opção 1: Docker Compose (Recomendado para FULL)
```bash
cd src/backend

# Criar .env
cp .env.example .env

# Subir toda a infraestrutura V2
docker-compose -f docker-compose.v2.yml up -d

# Ver logs
docker-compose -f docker-compose.v2.yml logs -f backend_v2

# Parar
docker-compose -f docker-compose.v2.yml down
```

**URLs:**
- API: http://54.207.172.193:9001
- Docs: http://54.207.172.193:9001/docs
- Painel: http://54.207.172.193:9001/painel/
- PostgreSQL: localhost:5433

#### Opção 2: Desenvolvimento Local
```bash
cd src/backend

# Criar venv
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# PostgreSQL precisa estar rodando
# Configurar DATABASE_URL no .env

# Rodar migrations
./migrate.sh upgrade

# Iniciar servidor
python main_v2.py
```

### Características da FULL
- ✅ PostgreSQL real (dados persistem)
- ✅ CRUD completo de funcionários
- ✅ Migrations versionadas
- ✅ Validações completas
- ✅ Paginação e filtros
- ✅ Soft delete
- ⚠️ Requer PostgreSQL
- ⚠️ Requer configuração de .env

---

## 🔄 Rodando Ambas Simultaneamente

Você pode rodar **DEMO e FULL ao mesmo tempo** sem conflitos:

```bash
# Terminal 1: DEMO na porta 9000
cd src/backend
python main_production.py

# Terminal 2: FULL na porta 9001
cd src/backend
docker-compose -f docker-compose.v2.yml up
```

**Acesso:**
- DEMO: http://54.207.172.193:9000
- FULL: http://54.207.172.193:9001

---

## 📊 Comparação de Endpoints

### Endpoints Comuns (presentes em ambas)

| Endpoint | DEMO | FULL |
|----------|------|------|
| `POST /api/v1/punch-record` | ✅ Salva em memória | ✅ Salva no PostgreSQL + valida |
| `GET /api/v1/punch-records/{id}` | ✅ Busca da memória | ✅ Busca do PostgreSQL |
| `GET /api/v1/all-records` | ✅ Lista todos | ✅ Lista com paginação + JOIN |
| `GET /health` | ✅ Status básico | ✅ Status + DB connection |

### Endpoints Exclusivos da FULL

| Endpoint | Método | Descrição |
|----------|--------|-----------|
| `/api/v1/employees` | GET | Listar funcionários |
| `/api/v1/employees/{id}` | GET | Buscar funcionário |
| `/api/v1/employees` | POST | Criar funcionário |
| `/api/v1/employees/{id}` | PATCH | Atualizar funcionário |
| `/api/v1/employees/{id}` | DELETE | Desativar funcionário |

---

## 🧪 Testes

### Testar DEMO (9000)
```bash
# Health check
curl http://localhost:9000/health

# Criar registro
curl -X POST http://localhost:9000/api/v1/punch-record \
  -H "Content-Type: application/json" \
  -d '{
    "employee_id": 1,
    "timestamp": "2025-12-23T10:00:00",
    "latitude": -23.5505,
    "longitude": -46.6333
  }'
```

### Testar FULL (9001)
```bash
# Health check (com DB status)
curl http://localhost:9001/health

# Listar funcionários
curl http://localhost:9001/api/v1/employees

# Criar funcionário
curl -X POST http://localhost:9001/api/v1/employees \
  -H "Content-Type: application/json" \
  -d '{
    "employee_code": "999",
    "name": "Teste Full",
    "email": "teste@plantherm.com",
    "department": "TI",
    "position": "Desenvolvedor"
  }'
```

---

## 🚀 Deploy em Produção AWS

### DEMO (Mantém atual)
```bash
ssh ubuntu@54.207.172.193

# O DEMO já está rodando
# NÃO MEXER

# Se precisar reiniciar:
cd ~/PontoPrime/src/backend
source venv/bin/activate
python main_production.py
```

### FULL (Deploy novo)
```bash
ssh ubuntu@54.207.172.193
cd ~/PontoPrime
git pull origin claude/init-pontoprime-project-EiNV4

# Subir FULL (porta 9001)
cd src/backend
docker-compose -f docker-compose.v2.yml up -d

# Liberar porta 9001 no Security Group AWS
# Console AWS > EC2 > Security Groups > Adicionar regra
# Porta: 9001, Tipo: TCP, Origem: 0.0.0.0/0
```

---

## 📁 Estrutura de Arquivos

```
src/backend/
├── main_production.py          # 🔵 DEMO (V1) - Porta 9000
├── main_v2.py                  # 🟢 FULL (V2) - Porta 9001
├── Dockerfile                  # 🔵 DEMO
├── Dockerfile.v2               # 🟢 FULL
├── docker-compose.yml          # 🔵 DEMO (original)
├── docker-compose.v2.yml       # 🟢 FULL (novo)
├── models.py                   # 🟢 Usado apenas pela FULL
├── database.py                 # 🟢 Usado apenas pela FULL
├── alembic/                    # 🟢 Usado apenas pela FULL
└── migrate.sh                  # 🟢 Usado apenas pela FULL
```

---

## ⚠️ IMPORTANTE

### NUNCA FAÇA (para manter DEMO intacto):
- ❌ Modificar `main_production.py`
- ❌ Modificar `Dockerfile` (sem .v2)
- ❌ Usar porta 9000 para V2
- ❌ Deletar arquivos do DEMO

### SEMPRE FAÇA (para desenvolver FULL):
- ✅ Usar `main_v2.py`
- ✅ Usar `Dockerfile.v2`
- ✅ Usar `docker-compose.v2.yml`
- ✅ Usar porta 9001
- ✅ Testar antes de fazer deploy

---

## 🎯 Casos de Uso

### Quando usar DEMO?
- ✅ Apresentar para novos clientes
- ✅ Testes rápidos de conceito
- ✅ Demonstrações ao vivo
- ✅ Quando não precisa persistir dados

### Quando usar FULL?
- ✅ Produção real com PLANTHERM
- ✅ Quando precisa gerenciar funcionários
- ✅ Quando precisa histórico persistente
- ✅ Quando precisa auditoria
- ✅ Quando precisa relatórios complexos

---

## 📞 Suporte

**Desenvolvedor:** AutoManiaAI
**Cliente:** PLANTHERM

**URLs de Produção:**
- DEMO: http://54.207.172.193:9000
- FULL: http://54.207.172.193:9001

---

*As duas versões coexistem pacificamente. O DEMO permanece intocável para novos clientes, enquanto a FULL evolui para produção profissional.*
