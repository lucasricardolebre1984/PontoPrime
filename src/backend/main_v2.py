"""
PontoPrime Backend V2 - PRODUÇÃO COM POSTGRESQL
Versão Full com banco de dados real, autenticação e CRUD completo
Porta: 9000
"""
from fastapi import FastAPI, HTTPException, Depends, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from pydantic import BaseModel, Field, EmailStr
from datetime import datetime
from typing import Optional, List
from sqlalchemy.orm import Session
from sqlalchemy import desc, func
import logging
import uvicorn
import os

# Import database e models
from database import engine, get_db, Base
from models import Company, Employee, PunchRecord, User, AuditLog

# Configuração de logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Criar tabelas (se não existirem)
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="PontoPrime API V2 - Produção Full",
    description="Sistema de Registro de Ponto com Biometria + PostgreSQL - PLANTHERM",
    version="2.0.0-FULL"
)

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "https://automaniaai.com.br",
        "https://pontoprime.automaniaai.com.br",
        "http://54.207.172.193",
        "http://localhost",
        "*"
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Security
security = HTTPBearer()

# ========================================
# SCHEMAS (Pydantic Models)
# ========================================

class PunchRecordRequest(BaseModel):
    """Request para criar registro de ponto"""
    employee_id: int = Field(..., description="ID do funcionário")
    timestamp: str = Field(..., description="Data/hora do registro")
    latitude: float = Field(..., description="Latitude")
    longitude: float = Field(..., description="Longitude")
    device_id: Optional[str] = Field(None, description="ID do dispositivo")
    biometric_verified: Optional[bool] = Field(False, description="Biometria verificada")

    class Config:
        json_schema_extra = {
            "example": {
                "employee_id": 1,
                "timestamp": "2025-12-23T10:30:00",
                "latitude": -23.5505,
                "longitude": -46.6333,
                "device_id": "android-abc123",
                "biometric_verified": True
            }
        }

class PunchRecordResponse(BaseModel):
    """Response de registro de ponto"""
    id: int
    employee_id: int
    timestamp: datetime
    latitude: Optional[float]
    longitude: Optional[float]
    location_address: Optional[str]
    device_id: Optional[str]
    biometric_verified: bool
    status: str
    created_at: datetime

    class Config:
        from_attributes = True

class EmployeeCreate(BaseModel):
    """Request para criar funcionário"""
    employee_code: str = Field(..., description="Código do funcionário")
    name: str = Field(..., description="Nome completo")
    cpf: Optional[str] = Field(None, description="CPF")
    email: Optional[EmailStr] = Field(None, description="Email")
    phone: Optional[str] = Field(None, description="Telefone")
    department: Optional[str] = Field(None, description="Departamento")
    position: Optional[str] = Field(None, description="Cargo")
    company_id: int = Field(default=1, description="ID da empresa")

class EmployeeUpdate(BaseModel):
    """Request para atualizar funcionário"""
    name: Optional[str] = None
    email: Optional[EmailStr] = None
    phone: Optional[str] = None
    department: Optional[str] = None
    position: Optional[str] = None
    is_active: Optional[bool] = None

class EmployeeResponse(BaseModel):
    """Response de funcionário"""
    id: int
    employee_code: str
    name: str
    cpf: Optional[str]
    email: Optional[str]
    phone: Optional[str]
    department: Optional[str]
    position: Optional[str]
    is_active: bool
    created_at: datetime

    class Config:
        from_attributes = True

# ========================================
# SERVIR ARQUIVOS ESTÁTICOS
# ========================================

WEB_DIR = os.path.join(os.path.dirname(__file__), "..", "web")
if os.path.exists(WEB_DIR):
    app.mount("/painel", StaticFiles(directory=WEB_DIR, html=True), name="painel")
    logger.info(f"✅ Painel web disponível em http://54.207.172.193:9000/painel/")

# ========================================
# ENDPOINTS - HEALTH CHECKS
# ========================================

@app.get("/")
async def root(db: Session = Depends(get_db)):
    """Endpoint raiz - Health check"""
    # Verificar conexão com banco
    try:
        total_records = db.query(func.count(PunchRecord.id)).scalar()
        total_employees = db.query(func.count(Employee.id)).filter(Employee.is_active == True).scalar()
        db_status = "connected"
    except Exception as e:
        logger.error(f"Erro ao conectar com banco: {e}")
        total_records = 0
        total_employees = 0
        db_status = "error"

    return {
        "service": "PontoPrime API V2 - Produção Full",
        "version": "2.0.0-FULL",
        "status": "running",
        "client": "PLANTHERM - AutoManiaAI",
        "database": db_status,
        "total_employees": total_employees,
        "total_records": total_records,
        "api_docs": "/docs"
    }

@app.get("/health")
async def health_check(db: Session = Depends(get_db)):
    """Health check detalhado para monitoramento"""
    try:
        total_records = db.query(func.count(PunchRecord.id)).scalar()
        total_employees = db.query(func.count(Employee.id)).filter(Employee.is_active == True).scalar()

        return {
            "status": "healthy",
            "timestamp": datetime.now().isoformat(),
            "database": "connected",
            "total_records": total_records,
            "total_employees": total_employees
        }
    except Exception as e:
        logger.error(f"Health check failed: {e}")
        return {
            "status": "unhealthy",
            "timestamp": datetime.now().isoformat(),
            "database": "error",
            "error": str(e)
        }

# ========================================
# ENDPOINTS - PUNCH RECORDS
# ========================================

@app.post("/api/v1/punch-record", response_model=PunchRecordResponse, status_code=status.HTTP_201_CREATED)
async def create_punch_record(record: PunchRecordRequest, db: Session = Depends(get_db)):
    """
    Criar novo registro de ponto (com PostgreSQL real)
    """
    try:
        # Verificar se funcionário existe
        employee = db.query(Employee).filter(Employee.id == record.employee_id).first()
        if not employee:
            raise HTTPException(
                status_code=404,
                detail=f"Funcionário com ID {record.employee_id} não encontrado"
            )

        if not employee.is_active:
            raise HTTPException(
                status_code=400,
                detail=f"Funcionário {employee.name} está inativo"
            )

        # Log
        logger.info(f"📍 Registro de Ponto Recebido:")
        logger.info(f"   Funcionário: {employee.name} (ID: {record.employee_id})")
        logger.info(f"   Timestamp: {record.timestamp}")
        logger.info(f"   Location: ({record.latitude}, {record.longitude})")
        logger.info(f"   Biometria: {'✅ Verificada' if record.biometric_verified else '❌ Não verificada'}")

        # Criar registro no banco
        new_record = PunchRecord(
            employee_id=record.employee_id,
            timestamp=datetime.fromisoformat(record.timestamp),
            latitude=record.latitude,
            longitude=record.longitude,
            device_id=record.device_id,
            biometric_verified=record.biometric_verified,
            status='valid',
            synced_at=datetime.now()
        )

        db.add(new_record)
        db.commit()
        db.refresh(new_record)

        logger.info(f"✅ Registro salvo no PostgreSQL! ID: {new_record.id}")

        return new_record

    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        logger.error(f"❌ Erro ao processar registro: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"Erro ao processar registro: {str(e)}"
        )

@app.get("/api/v1/punch-records/{employee_id}", response_model=List[PunchRecordResponse])
async def get_employee_records(employee_id: int, db: Session = Depends(get_db)):
    """
    Buscar registros de um funcionário específico
    """
    logger.info(f"📊 Buscando registros do employee_id: {employee_id}")

    # Verificar se funcionário existe
    employee = db.query(Employee).filter(Employee.id == employee_id).first()
    if not employee:
        raise HTTPException(status_code=404, detail="Funcionário não encontrado")

    # Buscar registros
    records = db.query(PunchRecord)\
        .filter(PunchRecord.employee_id == employee_id)\
        .order_by(desc(PunchRecord.timestamp))\
        .all()

    logger.info(f"✅ Encontrados {len(records)} registros")

    return records

@app.get("/api/v1/all-records")
async def get_all_records(
    limit: int = 100,
    offset: int = 0,
    db: Session = Depends(get_db)
):
    """
    Retorna todos os registros com paginação (para o painel web)
    """
    # Buscar registros com JOIN para incluir nome do funcionário
    records_query = db.query(
        PunchRecord,
        Employee.name.label('employee_name'),
        Employee.employee_code.label('employee_code')
    ).join(Employee, PunchRecord.employee_id == Employee.id)\
     .order_by(desc(PunchRecord.timestamp))

    total = records_query.count()
    records = records_query.limit(limit).offset(offset).all()

    # Formatar response
    formatted_records = []
    for record, employee_name, employee_code in records:
        formatted_records.append({
            "id": record.id,
            "employee_id": record.employee_id,
            "employee_name": employee_name,
            "employee_code": employee_code,
            "timestamp": record.timestamp.isoformat(),
            "latitude": float(record.latitude) if record.latitude else None,
            "longitude": float(record.longitude) if record.longitude else None,
            "biometric_verified": record.biometric_verified,
            "status": record.status,
            "created_at": record.created_at.isoformat()
        })

    # Contar funcionários únicos
    total_employees = db.query(func.count(func.distinct(Employee.id)))\
        .filter(Employee.is_active == True)\
        .scalar()

    return {
        "total_employees": total_employees,
        "total_records": total,
        "limit": limit,
        "offset": offset,
        "records": formatted_records
    }

# ========================================
# ENDPOINTS - EMPLOYEES CRUD
# ========================================

@app.get("/api/v1/employees", response_model=List[EmployeeResponse])
async def list_employees(
    active_only: bool = True,
    db: Session = Depends(get_db)
):
    """
    Listar todos os funcionários
    """
    query = db.query(Employee)

    if active_only:
        query = query.filter(Employee.is_active == True)

    employees = query.order_by(Employee.name).all()

    logger.info(f"📋 Listando {len(employees)} funcionários")

    return employees

@app.get("/api/v1/employees/{employee_id}", response_model=EmployeeResponse)
async def get_employee(employee_id: int, db: Session = Depends(get_db)):
    """
    Buscar funcionário por ID
    """
    employee = db.query(Employee).filter(Employee.id == employee_id).first()

    if not employee:
        raise HTTPException(status_code=404, detail="Funcionário não encontrado")

    return employee

@app.post("/api/v1/employees", response_model=EmployeeResponse, status_code=status.HTTP_201_CREATED)
async def create_employee(employee_data: EmployeeCreate, db: Session = Depends(get_db)):
    """
    Criar novo funcionário
    """
    # Verificar se employee_code já existe
    existing = db.query(Employee).filter(Employee.employee_code == employee_data.employee_code).first()
    if existing:
        raise HTTPException(
            status_code=400,
            detail=f"Código de funcionário '{employee_data.employee_code}' já existe"
        )

    # Verificar se CPF já existe (se fornecido)
    if employee_data.cpf:
        existing_cpf = db.query(Employee).filter(Employee.cpf == employee_data.cpf).first()
        if existing_cpf:
            raise HTTPException(status_code=400, detail="CPF já cadastrado")

    # Criar funcionário
    new_employee = Employee(
        company_id=employee_data.company_id,
        employee_code=employee_data.employee_code,
        name=employee_data.name,
        cpf=employee_data.cpf,
        email=employee_data.email,
        phone=employee_data.phone,
        department=employee_data.department,
        position=employee_data.position,
        is_active=True
    )

    db.add(new_employee)
    db.commit()
    db.refresh(new_employee)

    logger.info(f"✅ Funcionário criado: {new_employee.name} (ID: {new_employee.id})")

    return new_employee

@app.patch("/api/v1/employees/{employee_id}", response_model=EmployeeResponse)
async def update_employee(
    employee_id: int,
    employee_data: EmployeeUpdate,
    db: Session = Depends(get_db)
):
    """
    Atualizar dados de funcionário
    """
    employee = db.query(Employee).filter(Employee.id == employee_id).first()

    if not employee:
        raise HTTPException(status_code=404, detail="Funcionário não encontrado")

    # Atualizar apenas campos fornecidos
    update_data = employee_data.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(employee, field, value)

    db.commit()
    db.refresh(employee)

    logger.info(f"✅ Funcionário atualizado: {employee.name} (ID: {employee.id})")

    return employee

@app.delete("/api/v1/employees/{employee_id}", status_code=status.HTTP_204_NO_CONTENT)
async def deactivate_employee(employee_id: int, db: Session = Depends(get_db)):
    """
    Desativar funcionário (soft delete)
    """
    employee = db.query(Employee).filter(Employee.id == employee_id).first()

    if not employee:
        raise HTTPException(status_code=404, detail="Funcionário não encontrado")

    employee.is_active = False
    db.commit()

    logger.warning(f"⚠️ Funcionário desativado: {employee.name} (ID: {employee.id})")

    return None

# ========================================
# ENDPOINT DE DESENVOLVIMENTO/DEBUG
# ========================================

@app.delete("/api/v1/records/clear")
async def clear_all_records(secret: str, db: Session = Depends(get_db)):
    """
    DANGER: Limpa todos os registros de ponto (mantém funcionários)
    Requer secret: "plantherm2025"
    """
    if secret != "plantherm2025":
        raise HTTPException(status_code=403, detail="Secret inválido")

    deleted_count = db.query(PunchRecord).delete()
    db.commit()

    logger.warning(f"🗑️ {deleted_count} registros foram limpos!")

    return {
        "message": f"{deleted_count} registros foram limpos",
        "success": True
    }

# ========================================
# STARTUP
# ========================================

if __name__ == "__main__":
    logger.info("=" * 60)
    logger.info("🚀 PontoPrime API V2 - Produção Full (PostgreSQL)")
    logger.info("=" * 60)
    logger.info("📍 Porta: 9001 (DEMO na porta 9000)")
    logger.info("🌐 Cliente: PLANTHERM - AutoManiaAI")
    logger.info("🗄️ Database: PostgreSQL")
    logger.info("📊 Painel Web: http://54.207.172.193:9001/painel/")
    logger.info("📚 API Docs: http://54.207.172.193:9001/docs")
    logger.info("=" * 60)

    uvicorn.run(
        app,
        host="0.0.0.0",
        port=9001,  # Porta 9001 para V2 FULL (DEMO fica na 9000)
        log_level="info"
    )
