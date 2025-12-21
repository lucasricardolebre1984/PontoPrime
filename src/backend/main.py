"""
PontoPrime Backend - FastAPI
MVP Version: Endpoint simples para logging de registros de ponto
"""
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from datetime import datetime
from typing import Optional
import logging

# Configuração de logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(
    title="PontoPrime API",
    description="Sistema de Registro de Ponto com Biometria",
    version="1.0.0-MVP"
)

# CORS - Permitir requisições do app Android
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # MVP: Permitir todas as origens
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

# Endpoints
@app.get("/")
async def root():
    """Endpoint raiz - Health check"""
    return {
        "service": "PontoPrime API",
        "version": "1.0.0-MVP",
        "status": "running"
    }

@app.get("/health")
async def health_check():
    """Health check para monitoramento"""
    return {"status": "healthy", "timestamp": datetime.now().isoformat()}

@app.post("/api/v1/punch-record", response_model=PunchRecordResponse)
async def create_punch_record(record: PunchRecordRequest):
    """
    MVP: Endpoint que loga o registro de ponto
    Em produção, isso salvará no banco de dados PostgreSQL
    """
    try:
        # MVP: Apenas loga os dados recebidos
        logger.info(f"📍 Registro de Ponto Recebido:")
        logger.info(f"   Employee ID: {record.employee_id}")
        logger.info(f"   Timestamp: {record.timestamp}")
        logger.info(f"   Location: ({record.latitude}, {record.longitude})")

        # Simula ID gerado pelo banco
        mock_record_id = hash(f"{record.employee_id}{record.timestamp}") % 10000

        return PunchRecordResponse(
            success=True,
            message="Registro de ponto recebido com sucesso (MVP mode)",
            record_id=mock_record_id
        )

    except Exception as e:
        logger.error(f"Erro ao processar registro: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"Erro ao processar registro: {str(e)}"
        )

@app.get("/api/v1/punch-records/{employee_id}")
async def get_employee_records(employee_id: int):
    """
    MVP: Retorna registros mockados para um funcionário
    Em produção, buscará do banco de dados
    """
    logger.info(f"Buscando registros do employee_id: {employee_id}")

    # MVP: Retorna dados mockados
    mock_records = [
        {
            "id": 1,
            "employee_id": employee_id,
            "timestamp": "2025-12-21T09:00:00",
            "latitude": -23.5505,
            "longitude": -46.6333
        },
        {
            "id": 2,
            "employee_id": employee_id,
            "timestamp": "2025-12-21T12:00:00",
            "latitude": -23.5505,
            "longitude": -46.6333
        }
    ]

    return {
        "employee_id": employee_id,
        "records": mock_records,
        "total": len(mock_records)
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
