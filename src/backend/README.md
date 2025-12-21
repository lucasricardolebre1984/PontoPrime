# PontoPrime Backend - FastAPI

## MVP Version

Backend simples que loga os registros de ponto recebidos do app Android.

## Como Executar

### Opção 1: Python Local

```bash
cd src/backend
pip install -r requirements.txt
python main.py
```

### Opção 2: Docker

```bash
cd src/backend
docker build -t pontoprime-backend .
docker run -p 8000:8000 pontoprime-backend
```

## Endpoints

- `GET /` - Health check
- `GET /health` - Status da API
- `POST /api/v1/punch-record` - Registrar ponto
- `GET /api/v1/punch-records/{employee_id}` - Buscar registros

## Documentação Interativa

Após iniciar o servidor, acesse:
- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc
