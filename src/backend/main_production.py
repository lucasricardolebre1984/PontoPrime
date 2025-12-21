"""
PontoPrime Backend - PRODUÇÃO
Versão configurada para rodar no servidor AWS
Porta: 9000
"""
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from datetime import datetime
from typing import Optional
import logging
import uvicorn

# Configuração de logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

app = FastAPI(
    title="PontoPrime API - Produção",
    description="Sistema de Registro de Ponto com Biometria - Demo André",
    version="1.0.0-DEMO"
)

# CORS - Permitir requisições do painel web e app Android
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "https://automaniaai.com.br",
        "https://pontoprime.automaniaai.com.br",
        "http://54.207.172.193",
        "http://localhost",
        "*"  # Para demo, permite todas as origens
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Models
class PunchRecordRequest(BaseModel):
    employee_id: int = Field(..., description="ID do funcionário", example=1)
    timestamp: str = Field(..., description="Data/hora do registro", example="2025-12-21T10:30:00")
    latitude: float = Field(..., description="Latitude", example=-23.5505)
    longitude: float = Field(..., description="Longitude", example=-46.6333)

    class Config:
        json_schema_extra = {
            "example": {
                "employee_id": 1,
                "timestamp": "2025-12-21T10:30:00",
                "latitude": -23.5505,
                "longitude": -46.6333
            }
        }

class PunchRecordResponse(BaseModel):
    success: bool
    message: str
    record_id: Optional[int] = None

# Storage em memória para demo (resetado quando o servidor reinicia)
# Em produção real, isso seria um banco de dados PostgreSQL
DEMO_RECORDS = {}

# Endpoints
@app.get("/")
async def root():
    """Endpoint raiz - Health check"""
    return {
        "service": "PontoPrime API - Produção",
        "version": "1.0.0-DEMO",
        "status": "running",
        "client": "André - AutoManiaAI",
        "api_docs": "/docs"
    }

@app.get("/health")
async def health_check():
    """Health check para monitoramento"""
    return {
        "status": "healthy",
        "timestamp": datetime.now().isoformat(),
        "total_records": sum(len(records) for records in DEMO_RECORDS.values())
    }

@app.post("/api/v1/punch-record", response_model=PunchRecordResponse)
async def create_punch_record(record: PunchRecordRequest):
    """
    DEMO: Endpoint que salva o registro em memória
    Em produção real, salvaria no PostgreSQL
    """
    try:
        # Log detalhado
        logger.info(f"📍 Registro de Ponto Recebido:")
        logger.info(f"   Employee ID: {record.employee_id}")
        logger.info(f"   Timestamp: {record.timestamp}")
        logger.info(f"   Location: ({record.latitude}, {record.longitude})")

        # Salvar em memória
        if record.employee_id not in DEMO_RECORDS:
            DEMO_RECORDS[record.employee_id] = []

        # Gerar ID único
        record_id = len(DEMO_RECORDS[record.employee_id]) + 1

        # Adicionar registro
        DEMO_RECORDS[record.employee_id].append({
            "id": record_id,
            "employee_id": record.employee_id,
            "timestamp": record.timestamp,
            "latitude": record.latitude,
            "longitude": record.longitude,
            "created_at": datetime.now().isoformat()
        })

        logger.info(f"✅ Registro salvo com sucesso! ID: {record_id}")

        return PunchRecordResponse(
            success=True,
            message="Registro de ponto salvo com sucesso",
            record_id=record_id
        )

    except Exception as e:
        logger.error(f"❌ Erro ao processar registro: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"Erro ao processar registro: {str(e)}"
        )

@app.get("/api/v1/punch-records/{employee_id}")
async def get_employee_records(employee_id: int):
    """
    DEMO: Retorna registros salvos em memória
    Em produção real, buscaria do PostgreSQL
    """
    logger.info(f"📊 Buscando registros do employee_id: {employee_id}")

    # Buscar registros salvos
    records = DEMO_RECORDS.get(employee_id, [])

    logger.info(f"✅ Encontrados {len(records)} registros")

    return {
        "employee_id": employee_id,
        "records": records,
        "total": len(records)
    }

@app.get("/api/v1/all-records")
async def get_all_records():
    """
    DEMO: Retorna todos os registros (para o painel web)
    """
    all_records = []
    for employee_id, records in DEMO_RECORDS.items():
        all_records.extend(records)

    # Ordenar por timestamp (mais recente primeiro)
    all_records.sort(key=lambda x: x.get('created_at', ''), reverse=True)

    return {
        "total_employees": len(DEMO_RECORDS),
        "total_records": len(all_records),
        "records": all_records
    }

@app.delete("/api/v1/records/clear")
async def clear_all_records(secret: str):
    """
    DEMO: Limpa todos os registros (use com cuidado!)
    Requer secret: "andre2025"
    """
    if secret != "andre2025":
        raise HTTPException(status_code=403, detail="Secret inválido")

    DEMO_RECORDS.clear()
    logger.warning("🗑️ Todos os registros foram limpos!")

    return {"message": "Todos os registros foram limpos", "success": True}

if __name__ == "__main__":
    logger.info("🚀 Iniciando PontoPrime API - Produção (AWS)")
    logger.info("📍 Porta: 9000")
    logger.info("🌐 Cliente: André - AutoManiaAI")

    uvicorn.run(
        app,
        host="0.0.0.0",  # Escuta em todas as interfaces
        port=9000,        # Porta de produção
        log_level="info"
    )
