# PontoPrime - Sistema de Ponto Eletrônico com Biometria Nativa

**PontoPrime** é um sistema de registro de ponto para funcionários remotos, composto por um Aplicativo Android nativo e um Backend API. A autenticação é feita via biometria nativa do Android (impressão digital, facial, PIN), garantindo segurança a custo zero.

## 🎯 Status: MVP COMPLETO ✅

O MVP foi desenvolvido e está funcional com todas as features planejadas:
- ✅ Backend FastAPI com endpoints de registro
- ✅ App Android com Jetpack Compose
- ✅ Simulação de biometria
- ✅ Armazenamento local com Room
- ✅ Sincronização com backend
- ✅ Histórico de registros

## 🏗️ Stack Tecnológica

### Backend
- **Framework:** Python 3.11 + FastAPI
- **Documentação:** Swagger UI automático
- **Container:** Docker pronto

### Android
- **Linguagem:** Kotlin
- **UI:** Jetpack Compose + Material 3
- **Arquitetura:** MVVM (ViewModel + Repository)
- **Banco Local:** Room (SQLite)
- **Networking:** Retrofit + OkHttp
- **Navegação:** Navigation Compose
- **Async:** Coroutines + StateFlow

### Produção (Planejado)
- **Banco de Dados:** PostgreSQL
- **Painel Web:** React + Material-UI
- **Mapas:** Google Maps API

## 🚀 Como Executar

### 1️⃣ Backend FastAPI

```bash
# Navegar para o diretório
cd src/backend

# Criar ambiente virtual
python3 -m venv venv
source venv/bin/activate  # Linux/Mac
# ou
venv\Scripts\activate     # Windows

# Instalar dependências
pip install -r requirements.txt

# Rodar servidor
python main.py
```

**API disponível em:**
- Base: http://localhost:8000
- Documentação: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

### 2️⃣ App Android

```bash
# Abrir no Android Studio
cd src/android
# Abrir a pasta no Android Studio

# Ou usar linha de comando (com Android Studio instalado)
./gradlew assembleDebug
```

**Requisitos:**
- Android Studio Hedgehog ou superior
- JDK 17
- Android SDK 34
- Emulador ou dispositivo com API 24+ (Android 7.0+)

**Configuração da API:**
- Para emulador: já configurado em `10.0.2.2:8000`
- Para dispositivo físico: alterar IP em `app/build.gradle`

### 3️⃣ Testando o Fluxo Completo

1. Inicie o backend primeiro
2. Execute o app no emulador/dispositivo
3. Faça login com qualquer ID numérico (ex: 123)
4. Clique em "Registrar Ponto"
5. Veja a confirmação
6. Acesse "Ver Histórico" para ver o registro
7. Verifique os logs no terminal do backend

## 📂 Estrutura do Projeto

```
PontoPrime/
├── docs/                    # Documentação completa
│   ├── ARCHITECTURE.md      # Arquitetura e stack
│   ├── DECISIONS.md         # Decisões arquiteturais (ADR)
│   ├── ROADMAP.md          # Roadmap e checklist
│   ├── STATUS.md           # Status atual
│   └── CONTEXT_DUMP.md     # Contexto do projeto
├── prompts/                # Inteligência de IA
│   ├── system_prompt.md    # Prompt do sistema
│   └── agent_factory.md    # Template de agentes
├── scripts/                # Scripts de automação
│   └── run_backend.sh      # Iniciar backend
├── src/
│   ├── android/            # App Android
│   │   ├── app/src/main/java/com/pontoprime/
│   │   │   ├── data/       # Room + Retrofit + Repository
│   │   │   ├── ui/         # Telas Compose + ViewModels
│   │   │   └── navigation/ # Navigation Compose
│   │   └── README.md
│   └── backend/            # API FastAPI
│       ├── main.py         # Servidor principal
│       ├── requirements.txt
│       ├── Dockerfile
│       └── README.md
├── .gitignore
├── .env.example
└── README.md (este arquivo)
```

## 🎨 Features do MVP

### Backend
- ✅ Endpoint POST `/api/v1/punch-record` - Registrar ponto
- ✅ Endpoint GET `/api/v1/punch-records/{employee_id}` - Buscar registros
- ✅ Health checks (/, /health)
- ✅ CORS configurado
- ✅ Logging estruturado

### Android
- ✅ Tela de Login com validação
- ✅ Tela Principal com botão de registro
- ✅ Simulação de biometria (AlertDialog)
- ✅ Captura de geolocalização (mockada para MVP)
- ✅ Armazenamento local offline-first
- ✅ Sincronização automática com backend
- ✅ Tela de histórico com status de sync
- ✅ Navegação fluida entre telas

## 🔜 Próximos Passos (Fase 2 - Produção)

### Backend
- [ ] Migrar para PostgreSQL
- [ ] Implementar autenticação JWT
- [ ] CRUD completo de funcionários
- [ ] API de auditoria com filtros
- [ ] Geração de relatórios (PDF/CSV)

### Android
- [ ] Biometria real com BiometricPrompt API
- [ ] Geolocalização real com GPS
- [ ] Validação de GPS ativo
- [ ] Criptografia de dados locais
- [ ] Sincronização em background
- [ ] Notificações push

### Painel Web
- [ ] Dashboard com gráficos
- [ ] CRUD de funcionários
- [ ] Auditoria com mapa (Google Maps)
- [ ] Exportação de relatórios

## 📚 Documentação Adicional

- [Arquitetura Completa](docs/ARCHITECTURE.md)
- [Decisões Técnicas](docs/DECISIONS.md)
- [Status do Projeto](docs/STATUS.md)
- [Backend README](src/backend/README.md)
- [Android README](src/android/README.md)

## 🤝 Contribuindo

Este é um projeto MVP. Para contribuir:
1. Consulte `docs/DECISIONS.md` para entender as decisões
2. Siga a arquitetura definida em `docs/ARCHITECTURE.md`
3. Mantenha os commits semânticos (feat, fix, docs, etc.)

## 📄 Licença

Este projeto é open source e está disponível sob a licença MIT.
