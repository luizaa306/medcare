CREATE TABLE clientes (
	id SERIAL PRIMARY KEY,
	nome VARCHAR(150) NOT NULL,
	email VARCHAR(150) UNIQUE NOT NULL,
	telefone VARCHAR(20) NOT NULL,
	cpf VARCHAR(11) UNIQUE NOT NULL,
	data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE mecanicos (
	id SERIAL PRIMARY KEY, 
	nome VARCHAR(150) NOT NULL,
	especialidade VARCHAR(100) NOT NULL,
	valor_hora DECIMAL(10,2) NOT NULL CHECK (valor_hora > 0)
);


CREATE TABLE veiculos (
	id SERIAL PRIMARY KEY, 
	cliente_id INT NOT NULL,
	FOREIGN KEY (cliente_id) REFERENCES clientes(id),
	placa VARCHAR(7) UNIQUE NOT NULL,
	modelo VARCHAR(100) NOT NULL,
	marca VARCHAR(100) NOT NULL,
	ano INT NOT NULL
);


CREATE TABLE ordens_servico (
	id SERIAL PRIMARY KEY, 
	veiculo_id INT NOT NULL,
	FOREIGN KEY (veiculo_id) REFERENCES veiculos(id),
	mecanico_id INT NOT NULL,
	FOREIGN KEY (mecanico_id) REFERENCES mecanicos(id),
	data_abertura TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	valor_mao_obra DECIMAL(10,2) NOT NULL CHECK (valor_mao_obra >= 0),
	status VARCHAR(20) DEFAULT 'Em Aberto',
	CHECK (status IN ('Em Aberto', 'Em Andamento', 'Concluida', 'Cancelada'))
);


CREATE TABLE pecas_os (
	id SERIAL PRIMARY KEY,
	os_id INT NOT NULL,
	FOREIGN KEY (os_id) REFERENCES ordens_servico(id),
	nome_peca VARCHAR(150) NOT NULL,
	quantidade INT NOT NULL CHECK (quantidade > 0),
	valor_unitario DECIMAL(10,2) NOT NULL CHECK (valor_unitario > 0)
);


INSERT INTO clientes (nome, email, telefone, cpf)
VALUES
('Fernanda Lima', 'fernanda@gmail.com', '48982345675', '34511287690'),
('Pedro Santana', 'pedro@gmail.com', '48972459067', '67855698712'),
('Kaue Alves', 'kaue@gmail.com', '48551206534', '09877654321');


INSERT INTO mecanicos (nome, especialidade, valor_hora)
VALUES
('Roberto Pereira', 'Motor', 120.00),
('Marcelo Mendes', 'Suspensão', 85.00),
('Rafael Costa','Elétrica', 110.00);


INSERT INTO veiculos (cliente_id, placa, modelo, marca, ano)
VALUES
(1, 'ABC1D23', 'Civic', 'Honda', 2020),
(2, 'DEF4G56', 'Onix', 'Chevrolet', 2021),
(3, 'HIJ7K89', '320i', 'BMW', 2022);


INSERT INTO ordens_servico (veiculo_id, mecanico_id, valor_mao_obra, status)
VALUES
(1, 1, 500.00, 'Concluida'),
(1, 3, 300.00, 'Em Andamento'),
(2, 2, 250.00, 'Em Aberto'),
(3, 1, 450.00, 'Cancelada');


INSERT INTO pecas_os (os_id, nome_peca, quantidade, valor_unitario)
VALUES
(1, 'Filtro de Óleo', 1, 80.00),
(1, 'Óleo do Motor', 4, 40.00),
(2, 'Pastilja de Freio', 2, 120.00),
(3, 'Bateria', 1, 450.00);


SELECT 
veiculos.modelo,
veiculos.marca,
veiculos.placa,
clientes.nome AS proprietario,
clientes.telefone
FROM veiculos
JOIN clientes
ON veiculos.cliente_id = clientes.id
ORDER BY veiculos.marca, veiculos.modelo;


SELECT
ordens_servico.id AS os_id, 
veiculos.placa,
veiculos.modelo,
ordens_servico.data_abertura,
mecanicos.nome AS mecanico,
ordens_servico.status
FROM ordens_servico
JOIN veiculos
ON ordens_servico.veiculo_id = veiculos.id
JOIN clientes
ON veiculos.cliente_id = clientes.id
JOIN mecanicos
ON ordens_servico.mecanico_id = mecanicos.id
WHERE clientes.nome = 'Fernanda Lima';


SELECT
ordens_servico.id AS os_id,
veiculos.placa,
mecanicos.nome AS mecanico,
ordens_servico.valor_mao_obra,
ordens_servico.valor_mao_obra + COALESCE(SUM(pecas_os.quantidade * pecas_os.valor_unitario), 0) AS valor_total
FROM ordens_servico
JOIN veiculos
ON ordens_servico.veiculo_id = veiculos.id
JOIN mecanicos
ON ordens_servico.mecanico_id = mecanicos.id
LEFT JOIN pecas_os
ON ordens_servico.id = pecas_os.os_id
GROUP BY
ordens_servico.id,
veiculos.placa,
mecanicos.nome,
ordens_servico.valor_mao_obra
ORDER BY ordens_servico.id;


SELECT 
nome, 
especialidade
valor_hora
FROM mecanicos
WHERE valor_hora > 90;


SELECT 
mecanicos.especialidade,
SUM(ordens_servico.valor_mao_obra) AS total_faturado
FROM ordens_servico
JOIN mecanicos
ON ordens_servico.mecanico_id = mecanicos.id
WHERE ordens_servico.status = 'Concluida'
GROUP BY mecanicos.especialidade;
