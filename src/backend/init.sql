-- Seed data para testes iniciais
-- Este arquivo é executado automaticamente na primeira inicialização

-- Empresa PLANTHERM
INSERT INTO companies (name, cnpj) VALUES
('PLANTHERM', '12.345.678/0001-90')
ON CONFLICT DO NOTHING;

-- Funcionários de teste
INSERT INTO employees (company_id, employee_code, name, cpf, email, department, position, is_active) VALUES
(1, '001', 'André - Gerente', '111.111.111-11', 'andre@plantherm.com', 'Administração', 'Gerente Geral', true),
(1, '002', 'João Silva', '222.222.222-22', 'joao@plantherm.com', 'Operações', 'Operador', true),
(1, '003', 'Maria Santos', '333.333.333-33', 'maria@plantherm.com', 'Manutenção', 'Técnica', true),
(1, '123', 'Funcionário Teste', '444.444.444-44', 'teste@plantherm.com', 'Teste', 'Tester', true)
ON CONFLICT DO NOTHING;

-- Usuário admin de teste
-- Senha: admin123 (hash bcrypt)
INSERT INTO users (username, email, password_hash, role, company_id, is_active) VALUES
('admin', 'admin@plantherm.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5UpfDRwOh7J5i', 'admin', 1, true)
ON CONFLICT DO NOTHING;
