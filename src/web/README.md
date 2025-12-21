# Painel Web PontoPrime

Painel web estático para visualização de registros de ponto.

## 📁 Estrutura

```
web/
├── index.html              # Página principal
├── assets/
│   ├── css/
│   │   └── style.css      # Estilos
│   └── js/
│       ├── config.js      # Configuração da API
│       └── app.js         # Lógica da aplicação
└── pontoprime.apk         # APK Android (copiar aqui)
```

## 🚀 Deploy

### Para AWS/Apache/Nginx

Copiar todos os arquivos para:
```
/var/www/automaniaai.com.br/pontoprime/andre/
```

### URL de Acesso

```
https://automaniaai.com.br/pontoprime/andre/
```

## ⚙️ Configuração

Editar `assets/js/config.js` e ajustar:

```javascript
const API_CONFIG = {
    BASE_URL: 'http://54.207.172.193:9000/api/v1'
};
```

## 🎨 Features

- ✅ Dashboard com estatísticas
- ✅ Lista de registros em tempo real
- ✅ Filtro por funcionário
- ✅ Auto-refresh a cada 30 segundos
- ✅ Visualização de localização GPS
- ✅ Status de sincronização
- ✅ Link para download do APK
- ✅ Design responsivo

## 📦 APK

Copiar o APK compilado para esta pasta:

```bash
cp /caminho/do/apk/pontoprime.apk .
```

O painel web terá um botão de download automático.
