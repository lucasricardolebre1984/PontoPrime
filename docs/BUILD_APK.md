# 🔨 Guia de Build do APK - PontoPrime

Este guia mostra como compilar o APK do PontoPrime para distribuição ao cliente.

---

## 📋 Pré-requisitos

- ✅ Android Studio Hedgehog ou superior
- ✅ JDK 17
- ✅ Android SDK 34
- ✅ Gradle configurado

---

## 🏗️ Build via Android Studio (Recomendado)

### Passo 1: Configurar URL de Produção

Editar `src/android/app/build.gradle`:

```gradle
buildConfigField "String", "API_BASE_URL", "\"http://54.207.172.193:9000/api/v1/\""
```

**Importante:** Certifique-se de que o IP está correto!

### Passo 2: Build APK

1. Abrir Android Studio
2. Abrir projeto em `src/android`
3. Menu: **Build > Build Bundle(s) / APK(s) > Build APK(s)**
4. Aguardar a conclusão do build
5. Clicar em **"locate"** quando aparecer a notificação

### Passo 3: Localizar APK

O APK será gerado em:
```
src/android/app/build/outputs/apk/debug/app-debug.apk
```

### Passo 4: Renomear e Copiar

```bash
# Renomear para nome amigável
cp app-debug.apk pontoprime.apk

# Copiar para pasta web
cp pontoprime.apk ../../web/
```

---

## 💻 Build via Terminal (Linha de Comando)

### Passo 1: Navegar para o Projeto

```bash
cd /home/user/PontoPrime/src/android
```

### Passo 2: Limpar Build Anterior

```bash
./gradlew clean
```

### Passo 3: Build Debug

```bash
./gradlew assembleDebug
```

Ou para Release (assinado):

```bash
./gradlew assembleRelease
```

### Passo 4: Encontrar APK

```bash
# Debug APK
ls -lh app/build/outputs/apk/debug/app-debug.apk

# Release APK (se fez build release)
ls -lh app/build/outputs/apk/release/app-release.apk
```

### Passo 5: Copiar para Distribuição

```bash
# Debug
cp app/build/outputs/apk/debug/app-debug.apk ../../web/pontoprime.apk

# Release
cp app/build/outputs/apk/release/app-release.apk ../../web/pontoprime.apk
```

---

## 📦 Build Release (Versão Assinada)

Para builds de produção, é recomendado criar uma versão **Release assinada**.

### Passo 1: Criar Keystore

```bash
keytool -genkey -v -keystore pontoprime-release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias pontoprime
```

Preencher:
- Password: **[ANOTAR EM LOCAL SEGURO]**
- Nome: PontoPrime
- Organização: AutoManiaAI
- Etc.

### Passo 2: Configurar build.gradle

Adicionar em `app/build.gradle`:

```gradle
android {
    ...

    signingConfigs {
        release {
            storeFile file("../pontoprime-release-key.jks")
            storePassword "SUA_SENHA_AQUI"
            keyAlias "pontoprime"
            keyPassword "SUA_SENHA_AQUI"
        }
    }

    buildTypes {
        release {
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
            signingConfig signingConfigs.release
        }
    }
}
```

### Passo 3: Build Release

```bash
./gradlew assembleRelease
```

### Passo 4: APK Assinado

Será gerado em:
```
app/build/outputs/apk/release/app-release.apk
```

---

## 🚀 Upload para Servidor

### Opção 1: SCP Direto

```bash
scp ../../web/pontoprime.apk ubuntu@54.207.172.193:/var/www/automaniaai.com.br/pontoprime/andre/
```

### Opção 2: Via SFTP

```bash
sftp ubuntu@54.207.172.193
put ../../web/pontoprime.apk /var/www/automaniaai.com.br/pontoprime/andre/
quit
```

### Opção 3: Manual (Upload via Painel)

Se você tem cPanel ou similar:
1. Acessar File Manager
2. Navegar até `/public_html/pontoprime/andre/`
3. Upload do arquivo `pontoprime.apk`

---

## ✅ Verificar APK

### Verificar Assinatura

```bash
jarsigner -verify -verbose -certs app-release.apk
```

### Verificar Informações do APK

```bash
aapt dump badging app-debug.apk | grep package
```

Deve mostrar:
```
package: name='com.pontoprime' versionCode='1' versionName='1.0.0-MVP'
```

### Verificar Tamanho

```bash
du -h app-debug.apk
```

Tamanho esperado: **~10-20 MB** para a versão debug.

---

## 🔄 Atualizar APK (Novas Versões)

Quando fizer alterações no código:

1. **Incrementar versionCode** em `app/build.gradle`:
   ```gradle
   versionCode 2  // Era 1
   versionName "1.0.1"  // Era 1.0.0
   ```

2. **Rebuild:**
   ```bash
   ./gradlew clean
   ./gradlew assembleDebug  # ou assembleRelease
   ```

3. **Upload novo APK:**
   ```bash
   scp app-debug.apk ubuntu@54.207.172.193:/var/www/.../pontoprime.apk
   ```

---

## 🐛 Troubleshooting

### Erro: "SDK location not found"

Criar arquivo `local.properties`:
```properties
sdk.dir=/path/to/Android/Sdk
```

### Erro: "Build failed - Execution failed for task ':app:processDebugResources'"

```bash
./gradlew clean
rm -rf .gradle
./gradlew assembleDebug
```

### APK muito grande (>50MB)

1. Verificar se tem recursos desnecessários
2. Usar build Release com minifyEnabled
3. Verificar dependências duplicadas

### Erro de Assinatura

```bash
# Verificar se o keystore existe
ls -lh pontoprime-release-key.jks

# Verificar alias
keytool -list -v -keystore pontoprime-release-key.jks
```

---

## 📊 Checklist de Build

- [ ] URL da API atualizada para produção
- [ ] versionCode incrementado
- [ ] versionName atualizado
- [ ] Build concluído sem erros
- [ ] APK testado em emulador
- [ ] APK testado em dispositivo real
- [ ] APK renomeado para `pontoprime.apk`
- [ ] APK enviado para servidor
- [ ] Link de download testado
- [ ] Cliente notificado da nova versão

---

## 📱 QR Code para Download

Gerar QR Code apontando para:
```
https://automaniaai.com.br/pontoprime/andre/pontoprime.apk
```

Usar: https://qr-code-generator.com

Salvar como `pontoprime-qrcode.png` e enviar junto ao cliente.

---

## 📞 Notas Importantes

### Para o Cliente

- ✅ APK é assinado e seguro
- ✅ Versão mínima: Android 7.0
- ✅ Tamanho: ~15 MB
- ✅ Permissões: Internet, Localização
- ✅ Funciona offline

### Para Desenvolvimento

- 🔒 **NUNCA** commitar keystore no Git
- 🔒 **NUNCA** commitar senhas no código
- 📝 Manter keystore em local seguro
- 📝 Documentar cada versão no Git (tags)
