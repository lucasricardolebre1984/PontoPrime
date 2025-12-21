// Configuração da API
// ATENÇÃO: Altere o IP abaixo para o IP do seu servidor AWS antes do deploy
const API_CONFIG = {
    // Para desenvolvimento local:
    // BASE_URL: 'http://localhost:9000/api/v1',

    // Para produção (AWS):
    BASE_URL: 'http://54.207.172.193:9000/api/v1',

    // Timeout em milissegundos
    TIMEOUT: 10000,

    // Intervalo de atualização automática (em milissegundos)
    AUTO_REFRESH_INTERVAL: 30000 // 30 segundos
};

// IDs de funcionários para demo
const DEMO_EMPLOYEES = [
    { id: 1, name: 'André - Gerente' },
    { id: 2, name: 'João Silva' },
    { id: 3, name: 'Maria Santos' },
    { id: 123, name: 'Funcionário Teste' }
];
