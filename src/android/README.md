# PontoPrime Android App

Aplicativo Android nativo para registro de ponto eletrônico com biometria.

## Stack Tecnológica

- **Linguagem:** Kotlin
- **UI:** Jetpack Compose + Material 3
- **Arquitetura:** MVVM (Model-View-ViewModel)
- **Banco de Dados:** Room (SQLite)
- **Networking:** Retrofit + OkHttp
- **Navegação:** Navigation Compose
- **Async:** Coroutines + Flow

## Estrutura do Projeto

```
app/src/main/java/com/pontoprime/
├── data/
│   ├── local/          # Room Database (Entity, DAO, Database)
│   ├── remote/         # Retrofit (API Service, Models)
│   └── repository/     # Repository pattern
├── ui/
│   ├── login/          # Tela de Login
│   ├── main/           # Tela Principal (Registro de Ponto)
│   ├── history/        # Tela de Histórico
│   └── theme/          # Material 3 Theme
├── navigation/         # Navigation Graph
├── MainActivity.kt
└── PontoPrimeApplication.kt
```

## Funcionalidades MVP

- ✅ Login com ID do funcionário
- ✅ Registro de ponto com simulação de biometria
- ✅ Captura de geolocalização (mockada no MVP)
- ✅ Armazenamento local com Room
- ✅ Sincronização com backend via Retrofit
- ✅ Visualização de histórico de registros
- ✅ Modo offline (sync pendente)

## Como Executar

### Pré-requisitos

- Android Studio Hedgehog ou superior
- JDK 17
- SDK Android 34 (compileSdk)
- Dispositivo/Emulador com API 24+ (Android 7.0+)

### Passos

1. **Abrir o projeto no Android Studio:**
   ```bash
   cd src/android
   # Abrir a pasta no Android Studio
   ```

2. **Sincronizar Gradle:**
   - Aguarde o Android Studio sincronizar as dependências

3. **Configurar Backend:**
   - Certifique-se que o backend está rodando em `http://localhost:8000`
   - Para emulador Android: a URL `http://10.0.2.2:8000` já está configurada no `build.gradle`
   - Para dispositivo físico: altere a URL em `app/build.gradle` para o IP da sua máquina

4. **Executar o App:**
   - Conectar dispositivo ou iniciar emulador
   - Clicar em "Run" (ou Shift+F10)

## Configurações Importantes

### Permissões (AndroidManifest.xml)

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.USE_BIOMETRIC" />
```

### API Base URL

Configurado em `app/build.gradle`:
```gradle
buildConfigField "String", "API_BASE_URL", "\"http://10.0.2.2:8000/api/v1/\""
```

## Roadmap Produção

- [ ] Integração real com BiometricPrompt API
- [ ] Captura real de geolocalização (GPS)
- [ ] Sincronização automática em background
- [ ] Criptografia de dados locais
- [ ] Validação de GPS ativo
- [ ] Notificações push
- [ ] Testes unitários e instrumentados

## Troubleshooting

### Erro de Conexão com Backend

- Verifique se o backend está rodando
- Para emulador, use `10.0.2.2` em vez de `localhost`
- Para dispositivo físico, use o IP da máquina na mesma rede

### Erro de Biometria

- No MVP, a biometria é simulada com um dialog
- Em produção, será necessário dispositivo com sensor biométrico

### Erro de Build

```bash
./gradlew clean
./gradlew build
```
