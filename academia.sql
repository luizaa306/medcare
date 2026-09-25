CREATE TABLE alunos (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    cpf VARCHAR(11) NOT NULL UNIQUE,
    telefone VARCHAR(20) NOT NULL,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE planos (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(150) NOT NULL UNIQUE,
    valor_mensal_base DECIMAL(10,2) NOT NULL
        CHECK (valor_mensal_base > 0)
);

CREATE TABLE modalidades (
    id SERIAL PRIMARY KEY,
    plano_id INT NOT NULL,
    FOREIGN KEY (plano_id) REFERENCES planos(id),
    nome VARCHAR(150) NOT NULL,
    sala VARCHAR(100) NOT NULL,
    capacidade_maxima INT NOT NULL
        CHECK (capacidade_maxima > 0),
    disponivel BOOLEAN DEFAULT TRUE
);

CREATE TABLE matriculas (
    id SERIAL PRIMARY KEY,
    aluno_id INT NOT NULL,
    FOREIGN KEY (aluno_id) REFERENCES alunos(id),
    data_inicio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'Ativa',
    CHECK (status IN ('Ativa', 'Cancelada', 'Trancada'))
);

CREATE TABLE itens_matricula (
    id SERIAL PRIMARY KEY,
    matricula_id INT NOT NULL,
    FOREIGN KEY (matricula_id) REFERENCES matriculas(id),
    modalidade_id INT NOT NULL,
    FOREIGN KEY (modalidade_id) REFERENCES modalidades(id),
    duracao_meses INT NOT NULL
        CHECK (duracao_meses > 0),
    valor_mensal_aplicado DECIMAL(10,2) NOT NULL
        CHECK (valor_mensal_aplicado > 0),
    taxa_adesao DECIMAL(10,2) DEFAULT 0.00
        CHECK (taxa_adesao >= 0)
);


INSERT INTO planos (nome, valor_mensal_base)
VALUES
('VIP Premium', 250.00),
('Fitness Standard', 150.00),
('Basic Fit', 90.00);


INSERT INTO modalidades
(plano_id, nome, sala, capacidade_maxima, disponivel)
VALUES
(1, 'Crossfit Pro', 'Arena 01', 20, TRUE),
(2, 'Pilates Avançado', 'Studio 02', 15, TRUE),
(3, 'Musculação Livre', 'Sala 03', 30, TRUE);


INSERT INTO alunos
(nome, email, cpf, telefone)
VALUES
('Carlos Ferreira', 'carlos@email.com', '12345678901', '48999991111'),
('Marina Souza', 'marina@email.com', '23456789012', '48999992222'),
('Pietro Lima', 'pietro@email.com', '34567890123', '48999993333');


INSERT INTO matriculas
(aluno_id, data_inicio, status)
VALUES
(1, '2026-09-01 10:00:00', 'Ativa'),
(2, '2026-09-02 09:00:00', 'Ativa'),
(3, '2026-09-03 14:00:00', 'Cancelada'),
(1, '2026-09-04 16:00:00', 'Ativa');


INSERT INTO itens_matricula
(matricula_id, modalidade_id, duracao_meses, valor_mensal_aplicado, taxa_adesao)
VALUES
(1, 1, 12, 250.00, 100.00),
(2, 2, 6, 150.00, 50.00),
(3, 3, 3, 90.00, 0.00),
(4, 2, 6, 150.00, 50.00);


-- Q1

CREATE VIEW vw_modalidades_custo_estimado AS
SELECT
    modalidades.nome AS modalidade,
    modalidades.sala,
    planos.nome AS plano,
    planos.valor_mensal_base * 1.10 AS valor_mensal_ajustado
FROM modalidades
JOIN planos
ON modalidades.plano_id = planos.id
ORDER BY valor_mensal_ajustado DESC;

SELECT * FROM vw_modalidades_custo_estimado;


-- Q2

CREATE VIEW vw_matriculas_ativas AS
SELECT
    alunos.nome AS aluno,
    alunos.cpf,
    modalidades.nome AS modalidade,
    modalidades.sala,
    itens_matricula.duracao_meses,
    matriculas.data_inicio
FROM matriculas
JOIN alunos
ON matriculas.aluno_id = alunos.id
JOIN itens_matricula
ON matriculas.id = itens_matricula.matricula_id
JOIN modalidades
ON itens_matricula.modalidade_id = modalidades.id
WHERE matriculas.status = 'Ativa';

SELECT * FROM vw_matriculas_ativas;


-- Q3

CREATE VIEW vw_alunos_vip AS
SELECT
    alunos.nome AS aluno,
    COUNT(matriculas.id) AS contratos_ativos,
    SUM(
        (itens_matricula.valor_mensal_aplicado * itens_matricula.duracao_meses)
        + itens_matricula.taxa_adesao
    ) AS valor_total_investido
FROM alunos
JOIN matriculas
ON alunos.id = matriculas.aluno_id
JOIN itens_matricula
ON matriculas.id = itens_matricula.matricula_id
WHERE matriculas.status = 'Ativa'
GROUP BY alunos.nome
HAVING SUM(
    (itens_matricula.valor_mensal_aplicado * itens_matricula.duracao_meses)
    + itens_matricula.taxa_adesao
) > 1000;

SELECT * FROM vw_alunos_vip;


-- Q4

SELECT
    modalidades.nome AS modalidade,
    modalidades.sala,
    modalidades.capacidade_maxima,
    planos.nome AS plano,
    planos.valor_mensal_base,
    modalidades.disponivel
FROM modalidades
JOIN planos
ON modalidades.plano_id = planos.id
WHERE modalidades.capacidade_maxima >= 15
AND planos.valor_mensal_base > 100
AND modalidades.disponivel = TRUE;


-- Q5

CREATE VIEW vw_faturamento_medio_plano AS
SELECT
    planos.nome AS plano,
    SUM(
        (itens_matricula.valor_mensal_aplicado * itens_matricula.duracao_meses)
        + itens_matricula.taxa_adesao
    ) AS faturamento_total,
    AVG(itens_matricula.duracao_meses) AS media_duracao_meses
FROM planos
JOIN modalidades
ON planos.id = modalidades.plano_id
JOIN itens_matricula
ON modalidades.id = itens_matricula.modalidade_id
JOIN matriculas
ON itens_matricula.matricula_id = matriculas.id
WHERE matriculas.status = 'Ativa'
GROUP BY planos.nome;

SELECT * FROM vw_faturamento_medio_plano;