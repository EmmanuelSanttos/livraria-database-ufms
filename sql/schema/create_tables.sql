-- ========================================
-- SISTEMA DE BANCO DE DADOS PARA LIVRARIA
-- Projeto Acadêmico UFMS - Módulo 3
-- Banco de Dados e Controle de Versão
-- ========================================

-- ----------------------------------------
-- TABELA: produtos
-- Descrição: Catálogo de livros disponíveis na livraria
-- Relacionamentos: Um produto pode estar em N pedidos (1:N)
-- ----------------------------------------

CREATE TABLE produtos (
    -- Chave Primária: identificador único auto-incrementável
    produto_id INT AUTO_INCREMENT PRIMARY KEY,
    
    -- Informações básicas do livro
    nome VARCHAR(255) NOT NULL COMMENT 'Título do livro',
    descricao TEXT COMMENT 'Sinopse e descrição detalhada',
    
    -- Dados financeiros: DECIMAL(10,2) garante precisão exata para valores monetários
    -- Nunca usar FLOAT/DOUBLE para dinheiro (causa erros de arredondamento)
    preco DECIMAL(10,2) NOT NULL COMMENT 'Preço de venda em R$',
    
    -- Controle de estoque
    estoque INT NOT NULL DEFAULT 0 COMMENT 'Quantidade disponível em estoque',
    
    -- Informações bibliográficas
    isbn VARCHAR(13) UNIQUE COMMENT 'Código ISBN-10 ou ISBN-13',
    autor VARCHAR(255) COMMENT 'Nome do autor ou autores',
    editora VARCHAR(255) COMMENT 'Nome da editora',
    
    -- Controle de status: soft delete permite desativar sem perder histórico
    ativo BOOLEAN DEFAULT TRUE COMMENT 'Indica se o produto está ativo no catálogo',
    
    -- Auditoria: timestamp automático na criação
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Data e hora do cadastro',
    
    -- Constraints: validações de integridade de dados
    CONSTRAINT chk_preco CHECK (preco >= 0) COMMENT 'Preço não pode ser negativo',
    CONSTRAINT chk_estoque CHECK (estoque >= 0) COMMENT 'Estoque não pode ser negativo',
    
    -- Índices para otimização de consultas
    INDEX idx_nome (nome),
    INDEX idx_isbn (isbn),
    INDEX idx_ativo (ativo)
    
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci 
COMMENT='Tabela de produtos/livros da livraria';


-- ----------------------------------------
-- TABELA: pedidos
-- Descrição: Registro de vendas/pedidos realizados
-- Relacionamentos: N pedidos para 1 produto (N:1 via FK produto_id)
-- ----------------------------------------

CREATE TABLE pedidos (
    -- Chave Primária: identificador único do pedido
    pedido_id INT AUTO_INCREMENT PRIMARY KEY,
    
    -- Chave Estrangeira: relacionamento com tabela produtos
    -- ON DELETE RESTRICT impede deletar produto que tem pedidos
    produto_id INT NOT NULL COMMENT 'Referência ao produto comprado',
    
    -- Informações do cliente
    nome_cliente VARCHAR(255) NOT NULL COMMENT 'Nome completo do cliente',
    email_cliente VARCHAR(100) NOT NULL COMMENT 'E-mail para contato e confirmação',
    
    -- Detalhes do pedido
    quantidade INT NOT NULL COMMENT 'Quantidade de itens pedidos',
    
    -- Preços históricos: armazenam valores NO MOMENTO da compra
    -- Essencial porque o preço do produto pode mudar no futuro
    preco_unitario DECIMAL(10,2) NOT NULL COMMENT 'Preço unitário no momento da compra',
    valor_total DECIMAL(10,2) NOT NULL COMMENT 'Valor total (quantidade × preço unitário)',
    
    -- Timestamp automático do pedido
    data_pedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Data e hora do pedido',
    
    -- Status do pedido com valores controlados
    status_pedido VARCHAR(50) NOT NULL DEFAULT 'pendente' 
        COMMENT 'Status atual: pendente, confirmado, enviado, entregue, cancelado',
    
    -- Definição da Chave Estrangeira
    FOREIGN KEY (produto_id) REFERENCES produtos(produto_id) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE
        COMMENT 'FK: Impede deletar produto com pedidos; atualiza cascata se ID mudar',
    
    -- Constraints: validações de dados
    CONSTRAINT chk_quantidade CHECK (quantidade > 0) 
        COMMENT 'Quantidade deve ser positiva',
    CONSTRAINT chk_preco_unitario CHECK (preco_unitario >= 0) 
        COMMENT 'Preço unitário não pode ser negativo',
    CONSTRAINT chk_valor_total CHECK (valor_total >= 0) 
        COMMENT 'Valor total não pode ser negativo',
    CONSTRAINT chk_status CHECK (status_pedido IN 
        ('pendente', 'confirmado', 'enviado', 'entregue', 'cancelado'))
        COMMENT 'Apenas status válidos são permitidos',
    
    -- Índices para otimização
    INDEX idx_produto_id (produto_id),
    INDEX idx_cliente_email (email_cliente),
    INDEX idx_data_pedido (data_pedido),
    INDEX idx_status (status_pedido)
    
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci 
COMMENT='Tabela de pedidos/vendas realizadas';
