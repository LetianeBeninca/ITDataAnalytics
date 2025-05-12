-- TAREA S4.01: Creación de base de datos
CREATE DATABASE db_sp04_transaction;
USE db_sp04_transaction;

-- Creación de las tablas: primero creamos las tablas de dimensiones:
-- Tabla company:
CREATE TABLE IF NOT EXISTS db_company (
    company_id VARCHAR(255) PRIMARY KEY,
    company_name VARCHAR(255),
    phone VARCHAR(255),
    email VARCHAR(255),
    country VARCHAR(255),
    website VARCHAR(255)
);

-- Creación tabla tarjeta de credito
CREATE TABLE IF NOT EXISTS db_credit_card (
    id VARCHAR(255) PRIMARY KEY,
    user_id INT,
    iban VARCHAR(255),
    pan VARCHAR(255),
    pin VARCHAR(255),
    cvv VARCHAR(255),
    track1 VARCHAR(255),
    track2 VARCHAR(255),
    expiring_date VARCHAR(255)
);

-- Creación tabla user:
CREATE TABLE IF NOT EXISTS db_user (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255),
    surname VARCHAR(255),
    phone VARCHAR(255),
    email VARCHAR(255),
    birth_date VARCHAR(255),
    country VARCHAR(255),
    city VARCHAR(255),
    postal_code VARCHAR(255),
    address VARCHAR(255)
);

-- Tabla transactions: tabla de hechos:
CREATE TABLE IF NOT EXISTS db_transactions (
    id VARCHAR(255) PRIMARY KEY,
    card_id VARCHAR(255),
    business_id VARCHAR(255),
    timestamp TIMESTAMP,
    amount DECIMAL(10,2),
    declined BOOLEAN,
    product_ids VARCHAR(255),
    user_id INT,
    lat FLOAT,
    longitude FLOAT,
    FOREIGN KEY (business_id) REFERENCES db_company (company_id),
    FOREIGN KEY (card_id) REFERENCES db_credit_card (id),
    FOREIGN KEY (user_id) REFERENCES db_user (id)
);

-- Cargar datos de db_company:
LOAD DATA INFILE 'C:\Users\Usuario\Desktop\IT Academy\01. Especialização 2025\Sprint 04\Dados\companies.csv'
INTO TABLE db_company
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
IGNORE 1 ROWS;

-- Error Code: 1290. The MySQL server is running with the --secure-file-priv option so it cannot execute this statement:
SHOW VARIABLES LIKE 'secure_file_priv';

-- Cargar datos de db_company:
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/companies.csv'
INTO TABLE db_company
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
IGNORE 1 ROWS;

SELECT *
FROM db_company;

-- Cargar datos de db_credit_card:
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/credit_cards.csv'
INTO TABLE db_credit_card
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
IGNORE 1 ROWS;

SELECT *
FROM db_credit_card;

-- Cargar datos de db_user:
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_uk.csv'
INTO TABLE db_user
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
IGNORE 1 ROWS;

-- Volvemos a cargar datos de db_user:
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_uk.csv'
INTO TABLE db_user
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n' 
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_ca.csv'
INTO TABLE db_user
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n' 
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_usa.csv'
INTO TABLE db_user
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n' 
IGNORE 1 ROWS;

SELECT *
FROM db_user;

-- Cargar datos de db_transactions:
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/transactions.csv'
INTO TABLE db_transactions
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n' 
IGNORE 1 ROWS;

SELECT *
FROM db_transactions;

-- Nivel 01: Ejercício 01:
-- Realiza una subconsulta que muestre todos los usuarios con más de 30 transacciones utilizando como mínimo dos tablas.
SELECT id, name, surname
FROM db_user
WHERE id IN (	SELECT user_id
				FROM db_transactions 
                GROUP BY 1
				HAVING COUNT(id) > 30);

-- Otra forma de hacer la consulta, con el CASE WHEN (como en el sprint 02).
SELECT us.id, us.name, us.surname,
	CASE WHEN COUNT(tr.id) > 30 THEN 'More than 30'
	     ELSE 'Less than 30'
	END AS 'Número de transacciones'
FROM db_transactions tr
JOIN db_user us
ON us.id = tr.user_id
GROUP BY 1;

-- Nivel 01: Ejercício 02:
-- Muestra el promedio del monto por IBAN de las tarjetas de crédito hechas a la compañía Donec Ltd, utiliza como mínimo 2 tablas.
-- Primera forma con join entre las tres tablas:
SELECT	co.company_name, 
		cr.iban, 
		ROUND(AVG(tr.amount), 2) AS Promedio_ventas
FROM db_transactions tr
JOIN db_credit_card cr 
ON tr.card_id = cr.id
JOIN db_company co 
ON tr.business_id = co.company_id
WHERE co.company_name = 'Donec Ltd'
GROUP BY 1,2;

-- Segunda forma con join entre dos tablas (business_id = b-2242):
SELECT 	cr.iban, 
		ROUND(AVG(tr.amount), 2) AS Promedio_ventas
FROM db_transactions tr
JOIN db_credit_card cr
ON tr.card_id = cr.id
WHERE tr.business_id ='b-2242'
GROUP BY 1;

-- Nivel 02: Ejercício 01:
-- Crea una nueva tabla que refleje el estado de las tarjetas de crédito basado en si las últimas tres transacciones fueron 
-- declinadas y genera la siguiente consulta: ¿Cuántas tarjetas están activas?
-- Creación tabla status de las tarjetas de credito
CREATE TABLE IF NOT EXISTS db_status_credit_card (
    id VARCHAR(255) PRIMARY KEY,
    status VARCHAR(255),
    FOREIGN KEY (id) REFERENCES db_credit_card (id)
	);
    
SELECT *
FROM db_status_credit_card;

-- Insertar los datos a las tarjetas, con la condición:
INSERT INTO db_status_credit_card (id, status)
SELECT 
    card_id,
    CASE 
        WHEN SUM(declined) >= 3 THEN 'disabled'
        ELSE 'activated'
    END AS status
FROM (
    SELECT 
        card_id,
        declined,
        ROW_NUMBER() OVER (PARTITION BY card_id ORDER BY timestamp DESC) AS transaciones
    FROM db_transactions
) AS ultimas_3_transaciones
WHERE transaciones <= 3 -- Seleccionamos solo las últimas 3 transacciones por tarjeta
GROUP BY card_id;

SELECT *
FROM db_status_credit_card;

SELECT COUNT(status) AS Activated
FROM db_status_credit_card
WHERE status = 'activated';

-- Nivel 03: Ejercício 01:
-- Crea una tabla con la que podamos unir los datos del nuevo archivo products.csv con la base de datos creada, 
-- teniendo en cuenta que desde transaction tienes producto_ids. Genera la siguiente consulta:
-- Necesitamos conocer el número de veces que se ha vendido cada producto.
-- Creacción tabla products:
CREATE TABLE IF NOT EXISTS db_products (
    id VARCHAR(255) PRIMARY KEY,
    product_name VARCHAR(255),
    price DECIMAL(10,2),
    colour VARCHAR(255),
    weight DECIMAL(10,2),
    warehouse_id VARCHAR(255)
    );
    
SELECT *
FROM db_products;

-- Carga datos excel:
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/products.csv'
INTO TABLE db_products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
IGNORE 1 ROWS;

ALTER TABLE db_products
MODIFY COLUMN price VARCHAR(255);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/products.csv'
INTO TABLE db_products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
IGNORE 1 ROWS;

SELECT *
FROM db_products;

ALTER TABLE db_transactions
ADD FOREIGN KEY (product_ids) REFERENCES db_products(id);

SELECT product_ids
FROM db_transactions;

CREATE TABLE db_transaction_product (
    transaction_id VARCHAR(255),
    product_id VARCHAR(255),
    PRIMARY KEY (transaction_id, product_id),
    FOREIGN KEY (transaction_id) REFERENCES db_transactions(id),
    FOREIGN KEY (product_id) REFERENCES db_products(id)
);

SELECT *
FROM db_transaction_product;

SHOW INDEX FROM db_transaction_product;

INSERT INTO db_transaction_product (transaction_id, product_id)
SELECT db_transactions.id AS transaction_id, db_products.id AS product_id
FROM db_transactions
JOIN db_products ON FIND_IN_SET(db_products.id, REPLACE (db_transactions.product_ids, " ", ""))>0;

SELECT * 
FROM db_transaction_product;

SELECT product_ids
FROM db_transactions
WHERE id = '02C6201E-D90A-1859-B4EE-88D2986D3B02';

-- Necesitamos conocer el número de veces que se ha vendido cada producto.
SELECT pr.id, pr.product_name, COUNT(tr.transaction_id) AS Num_Ventas
FROM db_transaction_product tr
JOIN db_products pr
ON tr.product_id = pr.id
GROUP BY 1, 2
ORDER BY 3 DESC;


