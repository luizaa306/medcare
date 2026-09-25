CREATE TABLE pacientes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    cpf VARCHAR(11) NOT NULL UNIQUE,
    data_nascimento DATE NOT NULL,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE especialidades (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE medicos (
    id SERIAL PRIMARY KEY,
    especialidade_id INT NOT NULL,
    FOREIGN KEY (especialidade_id) REFERENCES especialidades(id),
    nome VARCHAR(150) NOT NULL,
    crm VARCHAR(150) NOT NULL UNIQUE,
    valor_consulta DECIMAL(10,2) NOT NULL CHECK (valor_consulta > 0)
);

CREATE TABLE consultas (
    id SERIAL PRIMARY KEY,
    medico_id INT NOT NULL,
    FOREIGN KEY (medico_id) REFERENCES medicos(id),
    paciente_id INT NOT NULL,
    FOREIGN KEY (paciente_id) REFERENCES pacientes(id),
    data_hora TIMESTAMP NOT NULL,
    status VARCHAR(20) DEFAULT 'Agendada',
    CHECK (status IN ('Agendada', 'Realizada', 'Cancelada'))
);

CREATE TABLE exames_consulta (
    id SERIAL PRIMARY KEY,
    consulta_id INT NOT NULL,
    FOREIGN KEY (consulta_id) REFERENCES consultas(id),
    nome_exame VARCHAR(150) NOT NULL,
    valor_exame DECIMAL(10,2) NOT NULL CHECK (valor_exame >= 0)
);


INSERT INTO especialidades (nome)
VALUES
('Cardiologia'),
('Pediatria'),
('Dermatologia');


INSERT INTO medicos (especialidade_id, nome, crm, valor_consulta)
VALUES
(1, 'João Mendes', 'CRM1001', 450.00),
(2, 'Ana Costa', 'CRM1002', 280.00),
(3, 'Lucas Pereira', 'CRM1003', 350.00);


INSERT INTO pacientes (nome, email, cpf, data_nascimento)
VALUES
('Carlos Ferreira', 'carlos@email.com', '12344567890', '2001-06-13'),
('Marina Souza', 'marina@email.com', '23455678901', '1992-08-20'),
('Pietro Lima', 'pietro@email.com', '34566789012', '1985-11-10');


INSERT INTO consultas (medico_id, paciente_id, data_hora, status)
VALUES
(1, 1, '2026-09-01 10:00:00', 'Realizada'),
(2, 1, '2026-09-03 14:00:00', 'Agendada'),
(3, 2, '2026-09-02 09:30:00', 'Realizada'),
(1, 3, '2026-09-04 16:00:00', 'Cancelada');


INSERT INTO exames_consulta (consulta_id, nome_exame, valor_exame)
VALUES
(5, 'Eletrocardiograma', 150.00),
(5, 'Hemograma Completo', 80.00),
(7, 'Exame Dermatologico', 120.00),
(7, 'Hemograma Completo', 80.00);


-- Q1

CREATE VIEW vw_medicos_especialidades AS
SELECT
    medicos.nome AS medico,
    medicos.crm,
    especialidades.nome AS especialidade,
    medicos.valor_consulta
FROM medicos
JOIN especialidades
ON medicos.especialidade_id = especialidades.id
ORDER BY medicos.valor_consulta DESC;

SELECT * FROM vw_medicos_especialidades;


-- Q2

CREATE VIEW vw_consultas_carlos AS
SELECT
    consultas.id AS consulta_id,
    consultas.data_hora,
    medicos.nome AS medico,
    especialidades.nome AS especialidade,
    consultas.status
FROM consultas
JOIN pacientes
ON consultas.paciente_id = pacientes.id
JOIN medicos
ON consultas.medico_id = medicos.id
JOIN especialidades
ON medicos.especialidade_id = especialidades.id
WHERE pacientes.nome = 'Carlos Ferreira';

SELECT * FROM vw_consultas_carlos;


-- Q3

CREATE VIEW vw_valor_da_consulta AS
SELECT
    consultas.id AS consulta_id,
    pacientes.nome AS paciente,
    medicos.nome AS medico,
    medicos.valor_consulta +
    COALESCE(SUM(exames_consulta.valor_exame), 0) AS valor_total
FROM consultas
JOIN pacientes
ON consultas.paciente_id = pacientes.id
JOIN medicos
ON consultas.medico_id = medicos.id
LEFT JOIN exames_consulta
ON consultas.id = exames_consulta.consulta_id
GROUP BY
    consultas.id,
    pacientes.nome,
    medicos.nome,
    medicos.valor_consulta
ORDER BY consultas.id;

SELECT * FROM vw_valor_da_consulta;


-- Q4

CREATE VIEW vw_medicos_acima_300 AS
SELECT
    nome,
    crm,
    valor_consulta
FROM medicos
WHERE valor_consulta > 300;

SELECT * FROM vw_medicos_acima_300;


-- Q5

CREATE VIEW vw_faturamento_especialidade AS
SELECT
    especialidades.nome AS especialidade,
    SUM(
        medicos.valor_consulta +
        COALESCE(exame.total_exames, 0)
    ) AS total_faturado
FROM consultas
JOIN medicos
ON consultas.medico_id = medicos.id
JOIN especialidades
ON medicos.especialidade_id = especialidades.id
LEFT JOIN (
    SELECT
        consulta_id,
        SUM(valor_exame) AS total_exames
    FROM exames_consulta
    GROUP BY consulta_id
) AS exame
ON consultas.id = exame.consulta_id
WHERE consultas.status = 'Realizada'
GROUP BY especialidades.nome;

SELECT * FROM vw_faturamento_especialidade;