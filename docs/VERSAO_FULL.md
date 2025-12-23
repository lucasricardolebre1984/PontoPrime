# 🚀 PONTOPRIME - VERSÃO FULL (PROFISSIONAL)

**Data de Início:** 2025-12-23
**Cliente:** PLANTHERM
**Status MVP:** ✅ COMPLETO E OPERACIONAL
**Objetivo:** Evoluir de DEMO para PRODUÇÃO PROFISSIONAL

---

## 📋 VISÃO GERAL

Transformar o PontoPrime de uma demo funcional em um sistema profissional de nível empresarial, seguindo as **Diretrizes Técnicas Institucionais** e implementando todas as funcionalidades da **Fase 2** do Roadmap.

---

## 🎯 OBJETIVOS PRINCIPAIS

### 1. ✅ Conformidade com Diretrizes Institucionais
- **Dockerização obrigatória do backend** (atualmente rodando direto com Python)
- HTTPS adequado para produção
- Infraestrutura escalável e profissional

### 2. 🗄️ Banco de Dados Real
- Substituir armazenamento em memória por **PostgreSQL**
- Schema completo: `employees`, `punch_records`, `users`, `audit_logs`
- Migrations e versionamento de schema

### 3. 🔐 Segurança e Autenticação
- JWT para autenticação de usuários admin
- Biometria REAL no app Android (BiometricPrompt API)
- Criptografia de dados sensíveis
- Rate limiting e proteção contra ataques

### 4. 📊 Features Avançadas
- Dashboard com gráficos e analytics
- Relatórios em PDF/Excel
- Mapa de localizações em tempo real
- Sistema de auditoria completo
- Notificações push

### 5. 🏗️ DevOps e Infraestrutura
- CI/CD com GitHub Actions
- Monitoramento (Prometheus + Grafana)
- Logs centralizados
- Backups automáticos
- Ambientes dev/staging/prod

---

## 📦 FASE 1: DOCKERIZAÇÃO (PRIORIDADE MÁXIMA)

**Motivo:** Diretriz Institucional obrigatória - "Todos os serviços de back-end DEVEM ser conteinerizados com Docker"

### Backend Dockerizado

**Estrutura:**
```
src/backend/
├── Dockerfile
├── docker-compose.yml
├── .dockerignore
├── requirements.txt (já existe)
├── main_production.py (já existe)
└── alembic/ (migrations - novo)
```

**docker-compose.yml:**
```yaml
version: '3.8'

services:
  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_USER: pontoprime
      POSTGRES_PASSWORD: ${DB_PASSWORD}
      POSTGRES_DB: pontoprime_db
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U pontoprime"]
      interval: 10s
      timeout: 5s
      retries: 5

  backend:
    build: .
    ports:
      - "9000:9000"
    environment:
      DATABASE_URL: postgresql://pontoprime:${DB_PASSWORD}@db:5432/pontoprime_db
      JWT_SECRET: ${JWT_SECRET}
      ENVIRONMENT: production
    depends_on:
      db:
        condition: service_healthy
    volumes:
      - ./logs:/app/logs
      - ../web:/app/static
    restart: unless-stopped

  nginx:
    image: nginx:alpine
    ports:
      - "443:443"
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/nginx/ssl
    depends_on:
      - backend
    restart: unless-stopped

volumes:
  postgres_data:
```

**Benefícios:**
- ✅ Conformidade institucional
- ✅ Fácil deploy e rollback
- ✅ Isolamento de dependências
- ✅ Escalabilidade horizontal
- ✅ HTTPS com Nginx reverse proxy

---

## 🗄️ FASE 2: BANCO DE DADOS POSTGRESQL

### Schema Completo

```sql
-- Tabela de Empresas/Clientes
CREATE TABLE companies (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    cnpj VARCHAR(18) UNIQUE,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Tabela de Funcionários
CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    company_id INTEGER REFERENCES companies(id),
    employee_code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    cpf VARCHAR(14) UNIQUE,
    email VARCHAR(255),
    phone VARCHAR(20),
    department VARCHAR(100),
    position VARCHAR(100),
    biometric_hash TEXT, -- Hash da digital cadastrada
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Tabela de Registros de Ponto
CREATE TABLE punch_records (
    id SERIAL PRIMARY KEY,
    employee_id INTEGER REFERENCES employees(id) NOT NULL,
    timestamp TIMESTAMP NOT NULL,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    location_address TEXT,
    device_id VARCHAR(255),
    biometric_verified BOOLEAN DEFAULT FALSE,
    photo_url TEXT, -- Opcional: foto do momento do registro
    status VARCHAR(50) DEFAULT 'valid', -- valid, invalid, pending_review
    synced_at TIMESTAMP DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Tabela de Usuários Admin (para painel web)
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(50) DEFAULT 'viewer', -- admin, manager, viewer
    company_id INTEGER REFERENCES companies(id),
    last_login TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Tabela de Auditoria
CREATE TABLE audit_logs (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50),
    entity_id INTEGER,
    details JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Índices para performance
CREATE INDEX idx_punch_records_employee ON punch_records(employee_id);
CREATE INDEX idx_punch_records_timestamp ON punch_records(timestamp DESC);
CREATE INDEX idx_employees_code ON employees(employee_code);
CREATE INDEX idx_audit_logs_created ON audit_logs(created_at DESC);
```

### Migrations com Alembic

```bash
# Instalar Alembic
pip install alembic

# Inicializar
alembic init alembic

# Criar migration
alembic revision --autogenerate -m "initial schema"

# Aplicar migrations
alembic upgrade head
```

---

## 🔐 FASE 3: AUTENTICAÇÃO E SEGURANÇA

### JWT para API

```python
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from jose import JWTError, jwt
from datetime import datetime, timedelta

SECRET_KEY = os.getenv("JWT_SECRET")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

security = HTTPBearer()

def create_access_token(data: dict):
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

async def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security)):
    try:
        token = credentials.credentials
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id: int = payload.get("sub")
        if user_id is None:
            raise HTTPException(status_code=401, detail="Invalid token")
        return user_id
    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid token")

# Endpoints protegidos
@app.get("/api/v1/admin/employees", dependencies=[Depends(get_current_user)])
async def get_employees():
    # Apenas usuários autenticados
    pass
```

### Biometria Real no Android

```kotlin
import androidx.biometric.BiometricPrompt
import androidx.biometric.BiometricManager

class BiometricAuthenticator(private val activity: FragmentActivity) {

    fun authenticate(onSuccess: () -> Unit, onError: (String) -> Unit) {
        val executor = ContextCompat.getMainExecutor(activity)

        val biometricPrompt = BiometricPrompt(activity, executor,
            object : BiometricPrompt.AuthenticationCallback() {
                override fun onAuthenticationSucceeded(result: BiometricPrompt.AuthenticationResult) {
                    super.onAuthenticationSucceeded(result)
                    onSuccess()
                }

                override fun onAuthenticationError(errorCode: Int, errString: CharSequence) {
                    super.onAuthenticationError(errorCode, errString)
                    onError(errString.toString())
                }
            }
        )

        val promptInfo = BiometricPrompt.PromptInfo.Builder()
            .setTitle("Autenticação Biométrica")
            .setSubtitle("Confirme sua digital para registrar ponto")
            .setNegativeButtonText("Cancelar")
            .build()

        biometricPrompt.authenticate(promptInfo)
    }
}
```

---

## 📊 FASE 4: DASHBOARD E RELATÓRIOS

### Dashboard com Chart.js

```javascript
// Gráfico de registros por dia
const ctx = document.getElementById('punchesChart').getContext('2d');
new Chart(ctx, {
    type: 'line',
    data: {
        labels: ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'],
        datasets: [{
            label: 'Registros de Ponto',
            data: [65, 59, 80, 81, 56, 55, 40],
            borderColor: '#0066A1',
            backgroundColor: 'rgba(0, 102, 161, 0.1)'
        }]
    }
});
```

### Geração de Relatórios PDF

```python
from reportlab.lib.pagesizes import A4
from reportlab.pdfgen import canvas

@app.get("/api/v1/reports/pdf/{employee_id}")
async def generate_pdf_report(employee_id: int, month: int, year: int):
    # Buscar dados do banco
    records = await get_employee_records(employee_id, month, year)

    # Gerar PDF
    pdf_path = f"/tmp/relatorio_{employee_id}_{month}_{year}.pdf"
    c = canvas.Canvas(pdf_path, pagesize=A4)

    # Header
    c.setFont("Helvetica-Bold", 16)
    c.drawString(100, 800, "PLANTHERM - Relatório de Ponto")

    # Conteúdo
    y = 750
    for record in records:
        c.drawString(100, y, f"{record.timestamp} - {record.location}")
        y -= 20

    c.save()
    return FileResponse(pdf_path)
```

---

## 🏗️ FASE 5: DEVOPS E CI/CD

### GitHub Actions Workflow

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      - name: Install dependencies
        run: |
          pip install -r requirements.txt
          pip install pytest pytest-cov
      - name: Run tests
        run: pytest --cov=src

  deploy:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - name: Deploy to AWS
        run: |
          ssh ubuntu@54.207.172.193 "cd ~/PontoPrime && git pull && docker-compose up -d --build"
```

---

## 📅 CRONOGRAMA ESTIMADO

| Fase | Duração | Prioridade |
|------|---------|------------|
| **Fase 1: Dockerização** | 1 dia | 🔴 ALTA |
| **Fase 2: PostgreSQL** | 2 dias | 🔴 ALTA |
| **Fase 3: Autenticação** | 2 dias | 🟡 MÉDIA |
| **Fase 4: Dashboard/Relatórios** | 3 dias | 🟡 MÉDIA |
| **Fase 5: DevOps/CI-CD** | 2 dias | 🟢 BAIXA |

**Total:** ~10 dias úteis

---

## 💰 ESTIMATIVA DE RECURSOS

### Infraestrutura Mensal (AWS)
- EC2 t3.medium (2 vCPU, 4GB RAM): ~$30/mês
- RDS PostgreSQL db.t3.micro: ~$15/mês
- SSL Certificate (Let's Encrypt): GRÁTIS
- S3 para backups: ~$5/mês
- **Total:** ~$50/mês

### Serviços Adicionais (Opcional)
- Cloudflare Pro (CDN + DDoS protection): $20/mês
- SendGrid (notificações email): $15/mês
- **Total com opcionais:** ~$85/mês

---

## ✅ CHECKLIST DE MIGRAÇÃO

### Pré-requisitos
- [ ] Backup completo da versão atual
- [ ] Testar ambiente Docker localmente
- [ ] Configurar variáveis de ambiente (.env)
- [ ] Documentar procedimentos de rollback

### Execução
- [ ] Criar branch `feature/version-full`
- [ ] Implementar Dockerfile e docker-compose
- [ ] Configurar PostgreSQL e migrations
- [ ] Migrar dados da memória para banco
- [ ] Implementar autenticação JWT
- [ ] Adicionar HTTPS com Nginx
- [ ] Testar todos os endpoints
- [ ] Deploy em ambiente de staging
- [ ] Testes de carga e performance
- [ ] Deploy em produção
- [ ] Monitoramento 24h pós-deploy

---

## 🎯 PRÓXIMA AÇÃO IMEDIATA

**COMEÇAR PELA DOCKERIZAÇÃO (Diretriz Institucional obrigatória)**

1. Criar `Dockerfile` otimizado
2. Criar `docker-compose.yml` completo
3. Testar localmente
4. Deploy na AWS
5. Validar funcionamento

**Posso começar agora?** 🚀
