# 📱 PontoPrime - Instruções para André

**Bem-vindo ao PontoPrime!**

Este é seu sistema de registro de ponto com biometria nativa Android.

---

## 🌐 Acesso ao Painel Web

**URL:** https://automaniaai.com.br/propostas/andre/painel.html

O painel web mostra:
- ✅ Total de funcionários ativos
- ✅ Registros de ponto do dia
- ✅ Status da sincronização
- ✅ Histórico completo de registros
- ✅ Visualização por funcionário

**Não precisa de login!** O painel é público para esta demo.

---

## 📲 Baixar e Instalar o App Android

### Passo 1: Download

Acesse pelo celular:
https://automaniaai.com.br/propostas/andre/pontoprime.apk

Ou escaneie este QR Code (será gerado para você):

```
[QR CODE AQUI - gerar em: https://qr-code-generator.com]
```

### Passo 2: Permitir Instalação

Ao baixar, o Android vai perguntar:
1. Permitir instalação de "Fontes Desconhecidas"
2. Clique em **Configurações**
3. Ative **"Permitir desta fonte"**
4. Volte e clique em **Instalar**

### Passo 3: Abrir o App

1. Toque no ícone **PontoPrime**
2. Faça login com seu ID de funcionário:
   - Use **1** para André (Gerente)
   - Use **2, 3** ou **123** para teste

---

## 🎯 Como Usar o App

### 1️⃣ Login
- Digite seu ID de funcionário
- Clique em **Entrar**

### 2️⃣ Registrar Ponto
- Na tela principal, clique em **"Registrar Ponto"**
- O app vai:
  - ✅ Capturar data/hora automaticamente
  - ✅ Capturar sua localização (GPS)
  - ✅ Salvar no celular (funciona sem internet!)
  - ✅ Sincronizar com o servidor quando tiver internet

### 3️⃣ Ver Histórico
- Clique em **"Ver Histórico"**
- Veja todos os seus registros de ponto
- Status verde = sincronizado com o servidor
- Status amarelo = aguardando sincronização

---

## 💡 Dicas Importantes

### ✅ O App Funciona Offline!
- Mesmo sem internet, o app salva o registro no celular
- Quando conectar à internet, sincroniza automaticamente

### ✅ Permissões Necessárias
- **Localização:** Para capturar o GPS (obrigatório)
- **Internet:** Para sincronizar com o servidor

### ✅ Versão Demo
Esta é uma versão de demonstração:
- Biometria está **simulada** (não usa sensor real ainda)
- Geolocalização está **ativa** (captura GPS real)
- Dados são **salvos em memória** no servidor (resetam quando o servidor reinicia)

---

## 🔍 Testando o Sistema

### Teste 1: Registro Básico
1. Abra o app
2. Login com ID: **1**
3. Clique em **Registrar Ponto**
4. Veja a confirmação
5. Abra o painel web e veja o registro aparecer

### Teste 2: Modo Offline
1. Desligue o Wi-Fi/Dados do celular
2. Registre um ponto
3. Veja que foi salvo localmente (histórico mostra "Pendente")
4. Ligue o Wi-Fi/Dados
5. O registro sincroniza automaticamente

### Teste 3: Múltiplos Funcionários
1. Faça login com ID: **1** (André)
2. Registre um ponto
3. Saia do app (botão "Sair")
4. Faça login com ID: **2** (João Silva)
5. Registre outro ponto
6. Abra o painel web e filtre por funcionário

---

## 📊 Monitoramento pelo Painel Web

O painel atualiza automaticamente a cada 30 segundos.

Você pode:
- ✅ Ver todos os registros em tempo real
- ✅ Filtrar por funcionário específico
- ✅ Ver localização GPS de cada registro
- ✅ Verificar status de sincronização
- ✅ Acompanhar quantos funcionários estão usando

---

## 🚀 Próximos Passos (Versão Completa)

Após aprovar a demo, a versão completa terá:

### Backend
- ✅ Banco de dados PostgreSQL (dados permanentes)
- ✅ Autenticação JWT para segurança
- ✅ CRUD de funcionários
- ✅ Relatórios em PDF/Excel
- ✅ API de auditoria

### App Android
- ✅ **Biometria REAL** (impressão digital, facial, PIN)
- ✅ Validação de GPS ativo
- ✅ Criptografia de dados locais
- ✅ Sincronização em background
- ✅ Notificações push

### Painel Web
- ✅ Login com autenticação
- ✅ Dashboard com gráficos
- ✅ Mapa interativo com registros
- ✅ Gestão de funcionários
- ✅ Exportação de relatórios
- ✅ Auditoria completa

---

## 📞 Suporte Técnico

### URLs Importantes
- **Painel Web:** https://automaniaai.com.br/propostas/andre/painel.html
- **API (para testes):** http://54.207.172.193:9000/docs
- **Download APK:** https://automaniaai.com.br/propostas/andre/pontoprime.apk

### Em Caso de Problemas

**App não instala:**
- Verifique se permitiu "Fontes Desconhecidas"
- Versão mínima do Android: 7.0 (Nougat)

**App não conecta:**
- Verifique se tem internet
- O app funciona offline, mas precisa de internet para sincronizar

**Registro não aparece no painel:**
- Aguarde 30 segundos (atualização automática)
- Clique no botão "🔄 Atualizar"

---

## 🎉 Aproveite a Demo!

Use o sistema por **7 dias** e me dê feedback sobre:
- ✅ Facilidade de uso
- ✅ Performance do app
- ✅ Funcionalidades que faltam
- ✅ Sugestões de melhorias

**Qualquer dúvida, estou à disposição!** 🚀
