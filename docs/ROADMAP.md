# Roadmap do Projeto - PontoPrime

## Fase 1: MVP (Prazo: 48 Horas)
- [ ] **Backend:** Criar endpoint `POST /api/v1/punch-record` que apenas loga os dados.
- [ ] **Android:** Tela de login mockada.
- [ ] **Android:** Tela principal com botão "Registrar Ponto".
- [ ] **Android:** Simulação de biometria com um simples `AlertDialog`.
- [ ] **Android:** Captura de data/hora e geolocalização.
- [ ] **Android:** Armazenamento local com Room.
- [ ] **Android:** Envio dos dados para o endpoint do backend.
- [ ] **Android:** Tela de histórico lendo do banco local.

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
