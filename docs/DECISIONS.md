# Registro de Decisões Arquiteturais (ADR)

## ADR-001: Escolha da Tecnologia de Autenticação
- **Decisão:** Utilizar a API `BiometricPrompt` nativa do Android.
- **Justificativa:** Custo zero de implementação e manutenção, alta segurança validada por hardware, e excelente experiência do usuário. Evita a complexidade e o custo de soluções de terceiros.

## ADR-002: Stack do Backend
- **Decisão:** Iniciar com Python e FastAPI.
- **Justificativa:** Alta performance, digitação estática (type hints) que reduz erros, e geração automática de documentação interativa (Swagger UI), o que acelera o desenvolvimento do cliente Android.

## ADR-003: Stack do Painel Web
- **Decisão:** Utilizar React.
- **Justificativa:** Ecossistema maduro, vasta disponibilidade de bibliotecas (gráficos, tabelas, etc.), e grande comunidade de desenvolvedores.

## ADR-004: Migração para PostgreSQL (V2)
- **Data:** 2025-12-23
- **Decisão:** Migrar de armazenamento em memória para PostgreSQL real.
- **Contexto:** A versão V1 (MVP) usava armazenamento em memória, o que significava perda de dados ao reiniciar o servidor. Para produção profissional, é necessário persistência real.
- **Opções Consideradas:**
  - SQLite: Simples, mas não ideal para multi-usuário e produção
  - MySQL: Popular, mas PostgreSQL tem features mais avançadas
  - PostgreSQL: ACID completo, JSON support, excelente performance
- **Decisão Final:** PostgreSQL
- **Motivo:**
  - Compliance com Diretrizes Institucionais (AWS EC2 + PostgreSQL)
  - ACID transactions completas
  - Suporte nativo a JSON (para audit_logs.details)
  - Excelente performance com indexes
  - Pool de conexões robusto
- **Consequências:**
  - ✅ Dados persistentes mesmo após restart
  - ✅ Suporte a múltiplos usuários simultâneos
  - ✅ Queries complexas com JOINs otimizados
  - ⚠️ Requer infraestrutura de banco de dados
  - ⚠️ Necessita backups e manutenção

## ADR-005: Alembic para Migrations
- **Data:** 2025-12-23
- **Decisão:** Usar Alembic para versionamento de schema do banco de dados.
- **Contexto:** Com PostgreSQL real, precisamos de uma forma profissional de gerenciar mudanças no schema ao longo do tempo.
- **Opções Consideradas:**
  - SQL scripts manuais: Difícil de versionar e aplicar
  - Django ORM: Requer framework completo
  - Alembic: Padrão da indústria com SQLAlchemy
- **Decisão Final:** Alembic
- **Motivo:**
  - Integração perfeita com SQLAlchemy
  - Auto-geração de migrations
  - Histórico completo de mudanças
  - Suporte a upgrade/downgrade
  - Usado por grandes empresas
- **Consequências:**
  - ✅ Mudanças de schema versionadas e rastreáveis
  - ✅ Fácil rollback em caso de problemas
  - ✅ Trabalho em equipe facilitado
  - ✅ Documentação automática do schema

## ADR-006: Soft Delete para Funcionários
- **Data:** 2025-12-23
- **Decisão:** Implementar soft delete (flag `is_active`) ao invés de deletar registros permanentemente.
- **Contexto:** Funcionários podem ser desativados, mas seus registros de ponto históricos devem ser preservados para auditoria.
- **Motivo:**
  - Conformidade com leis trabalhistas (manter histórico)
  - Auditoria completa
  - Possibilidade de reativar funcionários
  - Integridade referencial mantida
- **Consequências:**
  - ✅ Histórico completo preservado
  - ✅ Possível reativar funcionários
  - ⚠️ Queries devem filtrar por `is_active`
  - ⚠️ Banco cresce mais (mas de forma controlada)

## ADR-007: Dockerização Completa (Diretriz Institucional)
- **Data:** 2025-12-23
- **Decisão:** Dockerizar completamente o backend usando Docker Compose.
- **Contexto:** Diretriz Institucional: "Todos os serviços de back-end DEVEM ser conteinerizados com Docker"
- **Stack Docker:**
  - PostgreSQL: postgres:15-alpine
  - Backend: Multi-stage build Python 3.11-slim
  - Nginx: nginx:alpine (reverse proxy + HTTPS)
- **Motivo:**
  - ✅ Compliance com diretrizes
  - ✅ Ambiente reproduzível
  - ✅ Fácil deploy e rollback
  - ✅ Isolamento de dependências
  - ✅ Escalabilidade horizontal futura
- **Consequências:**
  - ✅ Deploy simplificado
  - ✅ Ambiente dev = prod
  - ⚠️ Requer conhecimento de Docker
  - ⚠️ Overhead mínimo de recursos
