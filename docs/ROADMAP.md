# Roadmap do Projeto - PontoPrime

## Fase 1: MVP (Prazo: 48 Horas) - ✅ COMPLETO
- [x] **Backend:** Criar endpoint `POST /api/v1/punch-record` que apenas loga os dados.
- [x] **Backend:** Criar endpoint `GET /api/v1/punch-records/{employee_id}` para buscar registros.
- [x] **Backend:** Configurar CORS e documentação automática (Swagger).
- [x] **Android:** Tela de login mockada.
- [x] **Android:** Tela principal com botão "Registrar Ponto".
- [x] **Android:** Simulação de biometria com um simples `AlertDialog`.
- [x] **Android:** Captura de data/hora e geolocalização (mockada).
- [x] **Android:** Armazenamento local com Room.
- [x] **Android:** Envio dos dados para o endpoint do backend.
- [x] **Android:** Tela de histórico lendo do banco local.
- [x] **Android:** Navegação completa entre telas.
- [x] **Android:** Repository pattern para abstração de dados.
- [x] **Documentação:** README completo para backend e Android.

## Fase 2: Versão de Produção
- [ ] **Backend:** Configurar PostgreSQL.
- [ ] **Backend:** Implementar schemas de `Employees`, `PunchRecords`, `Users`.
- [ ] **Backend:** Desenvolver APIs CRUD para gestão de funcionários.
- [ ] **Backend:** Desenvolver API de auditoria com filtros.
- [ ] **Backend:** Implementar lógica para geração de relatórios (PDF, CSV).
- [ ] **Painel Web:** Criar dashboard com gráficos.
- [ ] **Painel Web:** Implementar UI para CRUD de funcionários.
- [ ] **Painel Web:** Implementar UI de auditoria com mapa.
- [ ] **Android:** Integrar a API `BiometricPrompt` real.
- [ ] **Android:** Implementar modo offline com sincronização automática.
- [ ] **Android:** Adicionar validação de GPS ativo.
- [ ] **Android:** Criptografar dados locais.
