// Estado da aplicação
let allRecords = [];
let selectedEmployeeId = 'all';
let autoRefreshTimer = null;

// Elementos do DOM
const elements = {
    totalEmployees: document.getElementById('total-employees'),
    totalPunches: document.getElementById('total-punches'),
    syncedPunches: document.getElementById('synced-punches'),
    apiStatus: document.getElementById('api-status'),
    apiUrl: document.getElementById('api-url'),
    employeeSelect: document.getElementById('employee-select'),
    refreshBtn: document.getElementById('refresh-btn'),
    recordsTbody: document.getElementById('records-tbody')
};

// Inicialização
document.addEventListener('DOMContentLoaded', () => {
    initializeApp();
});

async function initializeApp() {
    // Mostrar URL da API
    elements.apiUrl.textContent = API_CONFIG.BASE_URL;

    // Preencher select de funcionários
    populateEmployeeSelect();

    // Event listeners
    elements.refreshBtn.addEventListener('click', refreshData);
    elements.employeeSelect.addEventListener('change', (e) => {
        selectedEmployeeId = e.target.value;
        renderRecords();
    });

    // Carregar dados iniciais
    await refreshData();

    // Iniciar auto-refresh
    startAutoRefresh();
}

function populateEmployeeSelect() {
    DEMO_EMPLOYEES.forEach(emp => {
        const option = document.createElement('option');
        option.value = emp.id;
        option.textContent = emp.name;
        elements.employeeSelect.appendChild(option);
    });
}

async function refreshData() {
    elements.refreshBtn.disabled = true;
    elements.refreshBtn.textContent = '⏳ Atualizando...';

    try {
        // Verificar status da API
        await checkApiStatus();

        // Carregar registros de todos os funcionários
        await loadAllRecords();

        // Atualizar estatísticas
        updateStats();

        // Renderizar tabela
        renderRecords();

    } catch (error) {
        console.error('Erro ao atualizar dados:', error);
        showError('Erro ao carregar dados. Verifique se a API está rodando.');
    } finally {
        elements.refreshBtn.disabled = false;
        elements.refreshBtn.textContent = '🔄 Atualizar';
    }
}

async function checkApiStatus() {
    try {
        const response = await fetch(`${API_CONFIG.BASE_URL.replace('/api/v1', '')}/health`, {
            method: 'GET',
            headers: { 'Content-Type': 'application/json' }
        });

        if (response.ok) {
            elements.apiStatus.textContent = 'Online';
            elements.apiStatus.style.color = '#28a745';
        } else {
            throw new Error('API não está respondendo');
        }
    } catch (error) {
        elements.apiStatus.textContent = 'Offline';
        elements.apiStatus.style.color = '#dc3545';
        throw error;
    }
}

async function loadAllRecords() {
    allRecords = [];

    // Carregar registros de cada funcionário
    for (const employee of DEMO_EMPLOYEES) {
        try {
            const response = await fetch(`${API_CONFIG.BASE_URL}/punch-records/${employee.id}`, {
                method: 'GET',
                headers: { 'Content-Type': 'application/json' }
            });

            if (response.ok) {
                const data = await response.json();
                if (data.records && Array.isArray(data.records)) {
                    // Adicionar nome do funcionário a cada registro
                    data.records.forEach(record => {
                        allRecords.push({
                            ...record,
                            employee_name: employee.name
                        });
                    });
                }
            }
        } catch (error) {
            console.warn(`Erro ao carregar registros do funcionário ${employee.id}:`, error);
        }
    }

    // Ordenar por timestamp (mais recente primeiro)
    allRecords.sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));
}

function updateStats() {
    // Total de funcionários
    elements.totalEmployees.textContent = DEMO_EMPLOYEES.length;

    // Total de registros
    elements.totalPunches.textContent = allRecords.length;

    // Registros sincronizados (para demo, vamos assumir 100%)
    elements.syncedPunches.textContent = allRecords.length;
}

function renderRecords() {
    // Filtrar registros se necessário
    let recordsToShow = allRecords;

    if (selectedEmployeeId !== 'all') {
        recordsToShow = allRecords.filter(r => r.employee_id === parseInt(selectedEmployeeId));
    }

    // Limpar tabela
    elements.recordsTbody.innerHTML = '';

    if (recordsToShow.length === 0) {
        elements.recordsTbody.innerHTML = `
            <tr>
                <td colspan="5" class="loading">Nenhum registro encontrado</td>
            </tr>
        `;
        return;
    }

    // Renderizar registros
    recordsToShow.forEach(record => {
        const row = document.createElement('tr');
        row.innerHTML = `
            <td>#${record.id}</td>
            <td><strong>${record.employee_name || `Funcionário ${record.employee_id}`}</strong></td>
            <td>${formatDateTime(record.timestamp)}</td>
            <td>📍 ${formatCoordinates(record.latitude, record.longitude)}</td>
            <td><span class="status-badge status-synced">Sincronizado</span></td>
        `;
        elements.recordsTbody.appendChild(row);
    });
}

function formatDateTime(timestamp) {
    try {
        const date = new Date(timestamp);
        return date.toLocaleString('pt-BR', {
            day: '2-digit',
            month: '2-digit',
            year: 'numeric',
            hour: '2-digit',
            minute: '2-digit',
            second: '2-digit'
        });
    } catch (error) {
        return timestamp;
    }
}

function formatCoordinates(lat, lng) {
    return `${lat.toFixed(4)}, ${lng.toFixed(4)}`;
}

function showError(message) {
    elements.recordsTbody.innerHTML = `
        <tr>
            <td colspan="5" style="color: #dc3545; text-align: center; padding: 20px;">
                ❌ ${message}
            </td>
        </tr>
    `;
}

function startAutoRefresh() {
    // Limpar timer anterior se existir
    if (autoRefreshTimer) {
        clearInterval(autoRefreshTimer);
    }

    // Configurar novo timer
    autoRefreshTimer = setInterval(() => {
        console.log('Auto-refresh executado');
        refreshData();
    }, API_CONFIG.AUTO_REFRESH_INTERVAL);
}

// Limpar timer quando a página for fechada
window.addEventListener('beforeunload', () => {
    if (autoRefreshTimer) {
        clearInterval(autoRefreshTimer);
    }
});
