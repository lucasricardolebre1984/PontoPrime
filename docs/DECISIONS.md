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
