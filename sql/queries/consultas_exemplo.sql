-- ========================================
-- CONSULTAS DE EXEMPLO
-- Sistema de Banco de Dados para Livraria
-- Demonstração de JOINs e relacionamentos
-- ========================================

-- ----------------------------------------
-- CONSULTA 1: Relatório de Pedidos com Informações dos Produtos
-- Demonstra o relacionamento entre as tabelas produtos e pedidos via INNER JOIN
-- ----------------------------------------

SELECT 
    -- Informações do pedido
    p.pedido_id AS 'Código Pedido',
    p.data_pedido AS 'Data do Pedido',
    p.status_pedido AS 'Status',
    
    -- Informações do cliente
    p.nome_cliente AS 'Cliente',
    p.email_cliente AS 'E-mail',
    
    -- Informações do produto (da tabela produtos via JOIN)
    pr.nome AS 'Livro Comprado',
    pr.autor AS 'Autor',
    pr.editora AS 'Editora',
    
    -- Detalhes financeiros do pedido
    p.quantidade AS 'Quantidade',
    CONCAT('R$ ', FORMAT(p.preco_unitario, 2, 'pt_BR')) AS 'Preço Unitário',
    CONCAT('R$ ', FORMAT(p.valor_total, 2, 'pt_BR')) AS 'Valor Total',
    
    -- Informações adicionais
    pr.estoque AS 'Estoque Atual',
    CONCAT('R$ ', FORMAT(pr.preco, 2, 'pt_BR')) AS 'Preço Atual no Catálogo'
    
FROM 
    pedidos p
    
    -- INNER JOIN: relaciona pedidos com produtos através da chave estrangeira
    INNER JOIN produtos pr ON p.produto_id = pr.produto_id
    
WHERE 
    -- Filtro: apenas pedidos ativos (não cancelados)
    p.status_pedido != 'cancelado'
    
ORDER BY 
    -- Ordenação: pedidos mais recentes primeiro
    p.data_pedido DESC;


-- ========================================
-- CONSULTAS ADICIONAIS ÚTEIS
-- ========================================

-- ----------------------------------------
-- CONSULTA 2: Total de Vendas por Produto
-- ----------------------------------------
SELECT 
    pr.nome AS 'Produto',
    COUNT(p.pedido_id) AS 'Quantidade de Pedidos',
    SUM(p.quantidade) AS 'Total de Livros Vendidos',
    CONCAT('R$ ', FORMAT(SUM(p.valor_total), 2, 'pt_BR')) AS 'Receita Total'
FROM produtos pr
LEFT JOIN pedidos p ON pr.produto_id = p.produto_id
WHERE p.status_pedido NOT IN ('cancelado') OR p.status_pedido IS NULL
GROUP BY pr.produto_id, pr.nome
ORDER BY SUM(p.valor_total) DESC;


-- ----------------------------------------
-- CONSULTA 3: Produtos Mais Vendidos
-- ----------------------------------------
SELECT 
    pr.nome AS 'Livro',
    pr.autor AS 'Autor',
    SUM(p.quantidade) AS 'Total Vendido',
    pr.estoque AS 'Estoque Restante',
    CASE 
        WHEN pr.estoque < 10 THEN 'CRÍTICO - Reabastecer'
        WHEN pr.estoque < 25 THEN 'BAIXO'
        ELSE 'OK'
    END AS 'Status Estoque'
FROM produtos pr
INNER JOIN pedidos p ON pr.produto_id = p.produto_id
GROUP BY pr.produto_id, pr.nome, pr.autor, pr.estoque
ORDER BY SUM(p.quantidade) DESC;


-- ----------------------------------------
-- CONSULTA 4: Pedidos Pendentes de Atendimento
-- ----------------------------------------
SELECT 
    p.pedido_id AS 'Código',
    p.nome_cliente AS 'Cliente',
    p.email_cliente AS 'Contato',
    pr.nome AS 'Produto',
    p.quantidade AS 'Qtd',
    CONCAT('R$ ', FORMAT(p.valor_total, 2, 'pt_BR')) AS 'Valor',
    p.data_pedido AS 'Data',
    TIMESTAMPDIFF(DAY, p.data_pedido, NOW()) AS 'Dias Aguardando'
FROM pedidos p
INNER JOIN produtos pr ON p.produto_id = pr.produto_id
WHERE p.status_pedido = 'pendente'
ORDER BY p.data_pedido ASC;


-- ----------------------------------------
-- CONSULTA 5: Análise de Receita por Status
-- ----------------------------------------
SELECT 
    p.status_pedido AS 'Status',
    COUNT(p.pedido_id) AS 'Quantidade Pedidos',
    SUM(p.quantidade) AS 'Total Itens',
    CONCAT('R$ ', FORMAT(SUM(p.valor_total), 2, 'pt_BR')) AS 'Receita Total',
    CONCAT('R$ ', FORMAT(AVG(p.valor_total), 2, 'pt_BR')) AS 'Ticket Médio'
FROM pedidos p
GROUP BY p.status_pedido
ORDER BY SUM(p.valor_total) DESC;


-- ----------------------------------------
-- CONSULTA 6: Clientes com Múltiplas Compras
-- ----------------------------------------
SELECT 
    p.email_cliente AS 'E-mail',
    p.nome_cliente AS 'Cliente',
    COUNT(p.pedido_id) AS 'Total Compras',
    SUM(p.quantidade) AS 'Total Livros',
    CONCAT('R$ ', FORMAT(SUM(p.valor_total), 2, 'pt_BR')) AS 'Valor Total Gasto'
FROM pedidos p
WHERE p.status_pedido NOT IN ('cancelado')
GROUP BY p.email_cliente, p.nome_cliente
HAVING COUNT(p.pedido_id) > 1
ORDER BY SUM(p.valor_total) DESC;


-- ----------------------------------------
-- CONSULTA 7: Catálogo Completo com Status de Vendas
-- ----------------------------------------
SELECT 
    pr.produto_id AS 'ID',
    pr.nome AS 'Livro',
    pr.autor AS 'Autor',
    pr.editora AS 'Editora',
    CONCAT('R$ ', FORMAT(pr.preco, 2, 'pt_BR')) AS 'Preço',
    pr.estoque AS 'Estoque',
    COALESCE(SUM(p.quantidade), 0) AS 'Total Vendido',
    CASE 
        WHEN pr.ativo = TRUE THEN 'Ativo'
        ELSE 'Inativo'
    END AS 'Status'
FROM produtos pr
LEFT JOIN pedidos p ON pr.produto_id = p.produto_id AND p.status_pedido NOT IN ('cancelado')
GROUP BY pr.produto_id, pr.nome, pr.autor, pr.editora, pr.preco, pr.estoque, pr.ativo
ORDER BY pr.nome;
