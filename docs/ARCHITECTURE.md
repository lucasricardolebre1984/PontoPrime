# Arquitetura do Sistema - PontoPrime

## Stack Tecnológica

- **Aplicativo Android (Nativo):**
  - **Linguagem:** Kotlin
  - **UI:** Jetpack Compose
  - **Rede:** Retrofit
  - **Banco de Dados Local:** Room (SQLite)
  - **Autenticação:** BiometricPrompt API

- **Backend (API):**
  - **Framework:** Python com FastAPI
  - **Banco de Dados:** PostgreSQL
  - **Autenticação (Painel):** JWT

- **Frontend (Painel de Controle):**
  - **Framework:** React
  - **UI Kit:** Material-UI (MUI) ou similar
  - **Mapas:** Google Maps API

## Modelo de Dados (Schema)

- **Employees**: `id`, `name`, `role`, `document_id`, `is_active`, `created_at`.
- **PunchRecords**: `id`, `employee_id` (FK), `timestamp`, `latitude`, `longitude`, `is_synced`, `created_at`.
- **Users** (Administradores): `id`, `email`, `password_hash`.
