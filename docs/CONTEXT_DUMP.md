# Context Dump - O Que Foi Discutido

## Visão Geral do Projeto

Construir um sistema de registro de ponto para funcionários remotos (`PontoPrime`) com um Aplicativo Android nativo e um Painel de Controle Web.

## Requisitos Chave

- **Autenticação:** Utilizar a API `BiometricPrompt` do Android para custo zero e alta segurança. A identidade é validada pelo hardware do dispositivo.
- **Registro de Ponto:** Capturar obrigatoriamente data, hora e geolocalização.
- **Modo Offline:** O app deve funcionar sem internet e sincronizar os dados quando a conexão for restabelecida.
- **Fases:**
  1. **MVP (48h):** Prova de conceito com funcionalidades simuladas.
  2. **Produção:** Sistema completo, robusto e escalável.

## Modelo de Dados

- **Employees**: `id`, `name`, `role`, `document_id`, `is_active`, `created_at`.
- **PunchRecords**: `id`, `employee_id` (FK), `timestamp`, `latitude`, `longitude`, `is_synced`, `created_at`.
- **Users**: `id`, `email`, `password_hash`.
