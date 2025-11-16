# 📚 Sistema de Banco de Dados para Livraria

> Projeto acadêmico de Banco de Dados e Controle de Versão - UFMS Módulo 3

[![Database](https://img.shields.io/badge/Database-MySQL-blue.svg)](https://www.mysql.com/)
[![Language](https://img.shields.io/badge/Language-SQL-orange.svg)](https://www.iso.org/standard/63555.html)
[![License](https://img.shields.io/badge/License-Academic-green.svg)](LICENSE)

## 📖 Sobre o Projeto

Sistema de gerenciamento de banco de dados relacional para uma livraria, desenvolvido como projeto acadêmico para a disciplina de Tecnologia da Informação (Módulo 3) da UFMS. O projeto implementa um schema normalizado com duas tabelas relacionadas (**produtos** e **pedidos**), demonstrando conceitos de modelagem de dados, normalização, chaves primárias/estrangeiras e controle de versão com Git/GitHub.

**Objetivos:**
- Modelar um banco de dados relacional seguindo as normas de normalização (1NF, 2NF, 3NF)
- Implementar relacionamento 1:N entre entidades
- Utilizar tipos de dados SQL apropriados para cada contexto
- Aplicar constraints para garantir integridade de dados
- Versionar o projeto utilizando Git com Conventional Commits
- Documentar o projeto de forma profissional

## 🗄️ Estrutura do Banco de Dados

### Diagrama ER (Entidade-Relacionamento)

```
┌─────────────────────────────────┐
│         PRODUTOS                │
├─────────────────────────────────┤
│ * produto_id (INT) PK           │
│   nome (VARCHAR 255)            │
│   descricao (TEXT)              │
│   preco (DECIMAL 10,2)          │
│   estoque (INT)                 │
│   isbn (VARCHAR 13)             │
│   autor (VARCHAR 255)           │
│   editora (VARCHAR 255)         │
│   ativo (BOOLEAN)               │
│   data_cadastro (TIMESTAMP)     │
└─────────────────────────────────┘
              │
              │ 1
              │
              │ referenciado por
              │
              │ N
              ▼
┌─────────────────────────────────┐
│          PEDIDOS                │
├─────────────────────────────────┤
│ * pedido_id (INT) PK            │
│ + produto_id (INT) FK           │
│   nome_cliente (VARCHAR 255)    │
│   email_cliente (VARCHAR 100)   │
│   quantidade (INT)              │
│   preco_unitario (DECIMAL 10,2) │
│   valor_total (DECIMAL 10,2)    │
│   data_pedido (TIMESTAMP)       │
│   status_pedido (VARCHAR 50)    │
└─────────────────────────────────┘

Legenda: * = Primary Key | + = Foreign Key | 1:N = One-to-Many
```

### Tabelas

#### 📦 produtos
Armazena o catálogo de livros disponíveis na livraria.

| Coluna | Tipo | Constraints | Descrição |
|--------|------|-------------|-----------|
| produto_id | INT | PRIMARY KEY, AUTO_INCREMENT | Identificador único |
| nome | VARCHAR(255) | NOT NULL | Título do livro |
| descricao | TEXT | - | Sinopse e descrição |
| preco | DECIMAL(10,2) | NOT NULL, CHECK >= 0 | Preço de venda em R$ |
| estoque | INT | NOT NULL, DEFAULT 0, CHECK >= 0 | Quantidade disponível |
| isbn | VARCHAR(13) | UNIQUE | Código ISBN-10 ou ISBN-13 |
| autor | VARCHAR(255) | - | Nome do autor |
| editora | VARCHAR(255) | - | Nome da editora |
| ativo | BOOLEAN | DEFAULT TRUE | Status do produto (soft delete) |
| data_cadastro | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Data de criação |

#### 🛒 pedidos
Registra as vendas/pedidos realizados pelos clientes.

| Coluna | Tipo | Constraints | Descrição |
|--------|------|-------------|-----------|
| pedido_id | INT | PRIMARY KEY, AUTO_INCREMENT | Identificador único |
| produto_id | INT | FOREIGN KEY, NOT NULL | Referência ao produto |
| nome_cliente | VARCHAR(255) | NOT NULL | Nome do cliente |
| email_cliente | VARCHAR(100) | NOT NULL | E-mail de contato |
| quantidade | INT | NOT NULL, CHECK > 0 | Quantidade pedida |
| preco_unitario | DECIMAL(10,2) | NOT NULL, CHECK >= 0 | Preço histórico no momento da compra |
| valor_total | DECIMAL(10,2) | NOT NULL, CHECK >= 0 | Total do pedido |
| data_pedido | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Data do pedido |
| status_pedido | VARCHAR(50) | NOT NULL, DEFAULT 'pendente', CHECK IN (...) | Status atual |

### Relacionamentos

- **produtos 1:N pedidos**: Um produto pode estar em múltiplos pedidos
- **Chave Estrangeira**: `pedidos.produto_id` → `produtos.produto_id`
- **Integridade Referencial**: `ON DELETE RESTRICT` (não permite deletar produto com pedidos)

## 📊 Normalização

O schema foi projetado seguindo as formas normais:

**1ª Forma Normal (1NF)** ✅
- Todos os atributos contêm valores atômicos
- Não há grupos repetidos ou arrays

**2ª Forma Normal (2NF)** ✅
- Não existem dependências parciais
- Todos os atributos não-chave dependem totalmente da chave primária

**3ª Forma Normal (3NF)** ✅
- Não existem dependências transitivas
- Dados do cliente estão em pedidos (dependem de pedido_id)
- Dados do produto estão em produtos (evita redundância)

**Decisão de Design**: Preço histórico (`preco_unitario`) em `pedidos` preserva o valor no momento da compra, essencial porque o preço do produto pode mudar com o tempo.

## 🚀 Como Usar

### Pré-requisitos

- MySQL 8.0+ ou MariaDB 10.5+
- Cliente MySQL (Workbench, CLI, DBeaver, etc.)
- Git (para clonar o repositório)

### Instalação

1. **Clone o repositório**
   ```bash
   git clone https://github.com/SEUUSUARIO/livraria-database-ufms.git
   cd livraria-database-ufms
   ```

2. **Crie o banco de dados**
   ```sql
   CREATE DATABASE livraria CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
   USE livraria;
   ```

3. **Execute o script de criação de tabelas**
   ```bash
   mysql -u root -p livraria < sql/schema/create_tables.sql
   ```
   
   Ou dentro do MySQL:
   ```sql
   SOURCE /caminho/completo/sql/schema/create_tables.sql;
   ```

4. **Carregue os dados de exemplo**
   ```bash
   mysql -u root -p livraria < sql/data/insert_data.sql
   ```

5. **Verifique a instalação**
   ```sql
   SHOW TABLES;
   SELECT COUNT(*) FROM produtos;
   SELECT COUNT(*) FROM pedidos;
   ```

### Exemplos de Uso

#### Consulta básica de produtos
```sql
SELECT produto_id, nome, autor, preco, estoque
FROM produtos
WHERE ativo = TRUE
ORDER BY nome;
```

#### Relatório de pedidos com JOIN
```sql
SELECT 
    p.pedido_id,
    p.nome_cliente,
    pr.nome AS livro,
    pr.autor,
    p.quantidade,
    p.valor_total,
    p.status_pedido
FROM pedidos p
INNER JOIN produtos pr ON p.produto_id = pr.produto_id
WHERE p.status_pedido != 'cancelado'
ORDER BY p.data_pedido DESC;
```

#### Produtos mais vendidos
```sql
SELECT 
    pr.nome AS livro,
    SUM(p.quantidade) AS total_vendido,
    COUNT(p.pedido_id) AS numero_pedidos
FROM produtos pr
INNER JOIN pedidos p ON pr.produto_id = p.produto_id
GROUP BY pr.produto_id, pr.nome
ORDER BY total_vendido DESC;
```

Mais exemplos em: [`sql/queries/consultas_exemplo.sql`](sql/queries/consultas_exemplo.sql)

## 📁 Estrutura de Arquivos

```
livraria-database-ufms/
├── README.md                               # Este arquivo
├── .gitignore                              # Arquivos ignorados pelo Git
└── sql/
    ├── schema/
    │   └── create_tables.sql               # DDL: Criação das tabelas
    ├── data/
    │   └── insert_data.sql                 # DML: Dados de exemplo
    └── queries/
        └── consultas_exemplo.sql           # Consultas demonstrativas
```

## 🔧 Decisões Técnicas

### Tipos de Dados

- **DECIMAL(10,2) para preços**: Garante precisão exata (não arredonda como FLOAT/DOUBLE)
- **VARCHAR vs TEXT**: VARCHAR para campos com tamanho previsível, TEXT para descrições longas
- **INT para IDs**: AUTO_INCREMENT simplifica inserção, suporta 2B+ registros
- **TIMESTAMP**: Registra data e hora automaticamente, essencial para auditoria

### Constraints

- **CHECK**: Validação de dados (preços/quantidades não negativas, status válidos)
- **NOT NULL**: Campos obrigatórios identificados
- **UNIQUE**: Previne duplicação de ISBNs
- **FOREIGN KEY**: Mantém integridade referencial

### Índices

Criados em colunas frequentemente usadas em:
- Joins (chaves estrangeiras)
- WHERE clauses (filtros comuns)
- ORDER BY (ordenação)

### Nomenclatura

- **snake_case**: Padrão da indústria para SQL (evita problemas com case sensitivity)
- **Português**: Contexto acadêmico brasileiro
- **Nomes descritivos**: Auto-documentação do código

## 📝 Controle de Versão

### Conventional Commits

Este projeto segue a especificação [Conventional Commits](https://www.conventionalcommits.org/):

```
<tipo>(escopo): descrição

Tipos:
- feat: Nova funcionalidade
- fix: Correção de bug
- docs: Documentação
- chore: Tarefas de manutenção
```

### Histórico de Commits

```bash
git log --oneline --graph
```

Exemplos:
- `chore: initialize database project structure`
- `feat(db): create products and orders schema`
- `feat(data): add sample data for bookstore`
- `docs(queries): add example JOIN queries`
- `docs(readme): add comprehensive project documentation`

## 👥 Autor

**Aldo Emanuel dos Santos**


## 📄 Licença

Este projeto foi desenvolvido para fins acadêmicos como parte do Módulo 3 na disciplina de Projeto Integrador de Tecnologia da Informação II do Curso Superior de Tecnologia da Informação da UFMS.
