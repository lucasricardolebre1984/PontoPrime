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

## Fase 2: Versão de Produção (V2 FULL) - ✅ PARCIALMENTE COMPLETO

### Backend - Base de Dados ✅
- [x] **Backend:** Configurar PostgreSQL.
- [x] **Backend:** Implementar schemas de `Companies`, `Employees`, `PunchRecords`, `Users`, `AuditLogs`.
- [x] **Backend:** Desenvolver APIs CRUD para gestão de funcionários.
- [x] **Backend:** Implementar Alembic para migrations.
- [x] **Backend:** Docker Compose completo (PostgreSQL + Backend + Nginx).

### Backend - Segurança e Features Avançadas ⏳ EM ANDAMENTO
- [ ] **Backend:** Implementar autenticação JWT.
- [ ] **Backend:** Adicionar rate limiting.
- [ ] **Backend:** HTTPS com Let's Encrypt.
- [ ] **Backend:** Desenvolver API de auditoria com filtros avançados.
- [ ] **Backend:** Implementar geração de relatórios PDF (ReportLab).
- [ ] **Backend:** Implementar exportação Excel (openpyxl).

### Painel Web ⏳ EM ANDAMENTO
- [x] **Painel Web:** Dashboard básico com estatísticas.
- [ ] **Painel Web:** Dashboard com gráficos (Chart.js).
- [ ] **Painel Web:** Implementar UI para CRUD de funcionários.
- [ ] **Painel Web:** Implementar UI de auditoria com mapa (Google Maps API).
- [ ] **Painel Web:** Relatórios avançados com filtros.

### Android - Features Avançadas ⏳ EM ANDAMENTO
- [x] **Android:** Implementar modo offline com sincronização automática.
- [ ] **Android:** Integrar a API `BiometricPrompt` REAL (remover AlertDialog).
- [ ] **Android:** Implementar GPS REAL (remover mock).
- [ ] **Android:** Adicionar validação de GPS ativo.
- [ ] **Android:** Criptografar dados locais (SQLCipher).
- [ ] **Android:** Notificações push para confirmação de registro.

## Fase 3: Deploy e Produção ⏳ EM ANDAMENTO

### Deploy
- [x] **Deploy:** Script único de deploy (`deploy_v2.sh`).
- [ ] **Deploy:** Testar deploy localmente.
- [ ] **Deploy:** Deploy V2 em produção AWS (porta 9001).
- [ ] **Deploy:** Liberar porta 9001 no Security Group.
- [ ] **Deploy:** Validar funcionamento end-to-end.

### DevOps
- [ ] **DevOps:** CI/CD com GitHub Actions.
- [ ] **DevOps:** Testes automatizados (pytest + instrumented tests).
- [ ] **DevOps:** Monitoramento com Prometheus + Grafana.
- [ ] **DevOps:** Backup automático PostgreSQL.
- [ ] **DevOps:** Ambiente de staging separado.
