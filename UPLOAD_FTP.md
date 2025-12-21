# 📤 Como Subir para KingHost via FTP

## 🎯 Estrutura Final no Servidor

```
www/
├── index.html                    (SEU SITE - NÃO MEXER)
├── logo/                         (SUAS IMAGENS - NÃO MEXER)
├── foto/                         (SUAS FOTOS - NÃO MEXER)
└── propostas/
    └── andre/
        ├── index.html            (JÁ EXISTE - NÃO MEXER)
        ├── painel.html           ⬅️ NOVO! (Painel PontoPrime)
        ├── pontoprime.apk        ⬅️ NOVO! (App Android)
        └── assets/               ⬅️ NOVO! (CSS, JS, Imagens)
            ├── css/
            │   └── style.css
            ├── js/
            │   ├── config.js
            │   └── app.js
            └── img/
                ├── logo-automaniaai.svg
                └── logo-andre-engenharia.svg
```

---

## 📋 Arquivos para Upload

Na pasta `src/web/` você tem:

```
src/web/
├── painel.html              ⬅️ COPIAR
├── pontoprime.apk           ⬅️ COPIAR (depois de compilar)
└── assets/                  ⬅️ COPIAR TODA A PASTA
    ├── css/
    │   └── style.css
    ├── js/
    │   ├── config.js
    │   └── app.js
    └── img/
        ├── logo-automaniaai.svg
        └── logo-andre-engenharia.svg
```

---

## 🚀 Passo a Passo com FileZilla (ou qualquer FTP)

### 1️⃣ Conectar no FTP

**Dados da KingHost:**
- Host: `ftp.automaniaai.com.br` (ou IP fornecido)
- Usuário: `seu_usuario`
- Senha: `sua_senha`
- Porta: `21`

### 2️⃣ Navegar até a Pasta Correta

No lado **DIREITO** (servidor):
```
/ (raiz)
└── www/
    └── propostas/
        └── andre/     ⬅️ ENTRAR AQUI
```

### 3️⃣ Upload dos Arquivos

**No lado ESQUERDO** (seu computador), navegue até:
```
/home/user/PontoPrime/src/web/
```

**Arrastar e soltar** para o servidor:

1. **painel.html** ➡️ `www/propostas/andre/painel.html`
2. **pasta assets/** ➡️ `www/propostas/andre/assets/`
   - Vai criar automaticamente: css/, js/, img/
3. **pontoprime.apk** ➡️ `www/propostas/andre/pontoprime.apk`
   (depois que você compilar o APK)

---

## ✅ Verificar se Funcionou

### Testar Painel Web

Acesse no navegador:
```
https://automaniaai.com.br/propostas/andre/painel.html
```

Deve aparecer:
- ✅ Logos: AutoManiaAI + André Engenharia
- ✅ Cores azul escuro + laranja
- ✅ Cards de estatísticas
- ✅ Botão de download do APK

### Testar Download do APK

```
https://automaniaai.com.br/propostas/andre/pontoprime.apk
```

Deve baixar o arquivo APK.

---

## 🔧 Configurar IP do Backend

**ANTES de fazer upload**, edite o arquivo:

`src/web/assets/js/config.js`

```javascript
const API_CONFIG = {
    BASE_URL: 'http://54.207.172.193:9000/api/v1'
};
```

Certifique-se que o IP está correto!

---

## 📱 Compilar e Upload do APK

### Compilar no Android Studio

```bash
cd src/android

# No Android Studio:
# 1. Build > Build Bundle(s) / APK(s) > Build APK(s)
# 2. Aguardar conclusão
# 3. O APK estará em: app/build/outputs/apk/debug/app-debug.apk
```

### Renomear e Copiar

```bash
# Renomear
cp app/build/outputs/apk/debug/app-debug.apk ../../web/pontoprime.apk

# Agora fazer upload via FTP do arquivo:
# src/web/pontoprime.apk ➡️ www/propostas/andre/pontoprime.apk
```

---

## 🎨 Permissões (Importante!)

Depois do upload, verifique as permissões via FTP:

- **painel.html**: `644` (leitura para todos)
- **assets/**: `755` (pasta executável)
- **Todos os arquivos**: `644`
- **pontoprime.apk**: `644`

**No FileZilla:** Botão direito > Permissões de arquivo > 644 ou 755

---

## 🌐 URLs Finais

| Recurso | URL |
|---------|-----|
| **Painel Web** | https://automaniaai.com.br/propostas/andre/painel.html |
| **Download APK** | https://automaniaai.com.br/propostas/andre/pontoprime.apk |
| **API Backend** | http://54.207.172.193:9000 |
| **API Docs** | http://54.207.172.193:9000/docs |

---

## 🐛 Troubleshooting

### Erro 404 - Arquivo não encontrado

1. Verificar se o nome está correto: `painel.html` (não `Painel.html` ou `index.html`)
2. Verificar caminho: `/www/propostas/andre/`
3. Verificar permissões: `644`

### Painel não carrega CSS/JS

1. Verificar se a pasta `assets/` foi toda copiada
2. Abrir F12 no navegador e ver erros no Console
3. Verificar se os caminhos em `painel.html` estão relativos: `assets/css/style.css`

### Logos não aparecem

1. Verificar se os arquivos SVG estão em: `assets/img/`
2. Abrir F12 e ver erros de carregamento
3. Verificar permissões: `644`

### Painel não conecta na API

1. Verificar se o backend está rodando: `curl http://54.207.172.193:9000/health`
2. Verificar CORS no backend (já configurado)
3. Abrir F12 > Network e ver erro de conexão

---

## 📞 Enviar para o Cliente

Depois do upload, envie para André:

**WhatsApp/Email:**
```
Olá André!

O sistema PontoPrime está no ar! 🎉

🌐 Acesse o painel:
https://automaniaai.com.br/propostas/andre/painel.html

📱 Baixe o app (Android):
https://automaniaai.com.br/propostas/andre/pontoprime.apk

Use por 7 dias e me dê seu feedback!

Qualquer dúvida, estou à disposição.
```

---

## ✅ Checklist Final

- [ ] Backend rodando na AWS (porta 9000)
- [ ] Firewall liberado para porta 9000
- [ ] Arquivos copiados via FTP
- [ ] Painel acessível no navegador
- [ ] Logos aparecem corretamente
- [ ] Cores azul + laranja aplicadas
- [ ] APK disponível para download
- [ ] Testado em celular Android
- [ ] Cliente notificado

**Tudo pronto para impressionar o André! 🚀**
