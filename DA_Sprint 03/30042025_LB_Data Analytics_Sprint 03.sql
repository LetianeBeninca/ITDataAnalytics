-- Nivel 01: Ejercicio 01:
-- Diseñar y crear una tabla llamada "credit_card" que almacene detalles cruciales sobre las tarjetas de crédito.
CREATE TABLE IF NOT EXISTS credit_card (
    id VARCHAR(15) PRIMARY KEY,
    iban VARCHAR(50),
    pan VARCHAR(20),
    pin VARCHAR(4),
    cvv VARCHAR(3),
    expiring_date VARCHAR(10),
    FOREIGN KEY (id)
	REFERENCES transaction (credit_card_id)
); 

ALTER TABLE transaction
ADD CONSTRAINT fk_transaction_credit_card
FOREIGN KEY (credit_card_id)
REFERENCES credit_card(id);

SELECT *
FROM credit_card;

-- Nivel 01: Ejercicio 02:
-- El departamento de Recursos Humanos ha identificado un error en el número de cuenta del usuario con ID CcU-2938. 
-- La información que debe mostrarse para este registro es: R323456312213576817699999. 
SELECT *
FROM credit_card
WHERE id = 'CcU-2938';

UPDATE credit_card
SET iban = 'R32345631221357681769999'
WHERE id = 'CcU-2938';

SELECT *
FROM credit_card
WHERE id = 'CcU-2938';

-- Nivel 01: Ejercicio 03:
-- En la tabla "transaction" ingresa un nuevo usuario:
SELECT *
FROM transaction
WHERE id = '108B1D1D-5B23-A76C-55EF-C568E49A99DD';

INSERT INTO company (id)
VALUES ('b-9999');

INSERT INTO credit_card (id)
VALUES ('CcU-9999');

INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, amount, declined) 
VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', 9999, 829.999, -117.999, 111.11, 0);

SELECT *
FROM transaction
WHERE id = '108B1D1D-5B23-A76C-55EF-C568E49A99DD';

-- Nivel 01: Ejercicio 04:
-- Desde Recursos Humanos solicitan eliminar la columna "pan" de la tabla credit_card.
ALTER TABLE credit_card
DROP COLUMN pan;

SELECT *
FROM credit_card;

-- Nivel 02: Ejercicio 01:
-- Elimina de la tabla transaction el registro con ID 02C6201E-D90A-1859-B4EE-88D2986D3B02 de la base de datos.
SELECT *
FROM transaction
WHERE id = '02C6201E-D90A-1859-B4EE-88D2986D3B02';

DELETE FROM transaction
WHERE id = '02C6201E-D90A-1859-B4EE-88D2986D3B02';

SELECT *
FROM transaction
WHERE id = '02C6201E-D90A-1859-B4EE-88D2986D3B02';

-- Nivel 02: Ejercicio 02:
-- Crear una vista llamada VistaMarketing:
CREATE VIEW VistaMarketing AS
SELECT co.company_name, co.phone, co.country, ROUND(AVG(tr.amount), 2) AS Promedio_Compra
FROM company co
JOIN transaction tr
WHERE tr.declined = 0
GROUP BY 1, 2, 3
ORDER BY 4 DESC;

SELECT * 
FROM VistaMarketing;

-- Nivel 02: Ejercicio 03:
-- Filtra la vista VistaMarketing para mostrar solo las compañías que tienen su país de residencia en "Germany".
SELECT *
FROM vistamarketing
WHERE country = 'Germany';

-- Nivel 03: Ejercicio 01:
-- documentar los comandos ejecutados para obtener el diagrama dado:
-- Primero creamos la tabla user:
CREATE INDEX idx_user_id ON transaction(user_id);
 
CREATE TABLE IF NOT EXISTS user (
        id INT PRIMARY KEY,
        name VARCHAR(100),
        surname VARCHAR(100),
        phone VARCHAR(150),
        email VARCHAR(150),
        birth_date VARCHAR(100),
        country VARCHAR(150),
        city VARCHAR(150),
        postal_code VARCHAR(100),
        address VARCHAR(255),
        FOREIGN KEY(id) REFERENCES transaction(user_id)        
    );

-- Cambios necesarios para adaptarse al modelo dado:
-- En la tabla user:
-- Cambiar el nombre tabla para data_user:
RENAME TABLE user TO data_user;

-- Cambiar el nombre de la columna email para personal_email:
ALTER TABLE data_user
CHANGE email personal_email VARCHAR(150);

-- En la tabla company:
-- Eliminar la columna website:
ALTER TABLE company
DROP COLUMN website;

-- En la tabla credit_card:
-- Creamos la columna fecha_actual:
ALTER TABLE credit_card
ADD COLUMN fecha_actual DATE;

-- Cambiar el tipo de datos del cvv para INT:
ALTER TABLE credit_card
MODIFY COLUMN cvv INT;

-- Cambiar el tipo de datos en expiring_date:
ALTER TABLE credit_card
MODIFY COLUMN expiring_date VARCHAR(20);

-- Eliminar la clave foranea:
ALTER TABLE data_user 
DROP FOREIGN KEY data_user_ibfk_1;

-- Registramos el usuario 9999:
INSERT INTO data_user (id) 
VALUES (9999);

-- Crear la foreign key entre las tablas de hecho y dimension:
ALTER TABLE transaction
ADD FOREIGN KEY (user_id) REFERENCES data_user(id);

-- Nivel 03: Ejercicio 02:
-- La empresa también solicita crear una vista llamada "InformeTecnico":
CREATE VIEW InformeTecnico AS 
SELECT tr.id, us.name, us.surname, cr.iban, co.company_name
FROM transaction tr
JOIN data_user us
ON tr.user_id = us.id
JOIN credit_card cr
ON tr.credit_card_id = cr.id
JOIN company co
ON tr.company_id = co.id
ORDER BY 1;

SELECT *
FROM InformeTecnico
ORDER BY id Desc;
