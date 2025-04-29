-- Nível 01. Ejercicio 02:
-- Listado de los países que están realizando compras:
SELECT DISTINCT country AS Paises
FROM company co
JOIN transaction tr
ON co.id = tr.company_id;

-- Desde cuántos países se realizan las compras:
SELECT COUNT(DISTINCT country) AS Total_Paises
FROM company co
JOIN transaction tr
ON co.id = tr.company_id;

-- Identifica la compañía con el promedio más grande de ventas:
SELECT 	company_id, 
		company_name, 
		ROUND(AVG(tr.amount), 2) AS Promedio_ventas
FROM transaction tr
JOIN company co
ON co.id = tr.company_id
WHERE declined = 0
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 1;

-- Nível 01. Ejercicio 03:
-- Muestra todas las transacciones realizadas por empresas de Alemania.
SELECT *
FROM transaction
WHERE company_id IN (	
		SELECT id
		FROM company
        WHERE country = 'Germany');

-- Lista las empresas que han realizado transacciones por un monto superior al promedio de todas las transacciones.
SELECT company_name
FROM company
WHERE id IN (
	SELECT company_id
    FROM transaction
    WHERE amount > ( 
		SELECT AVG(amount)
        FROM transaction))
ORDER BY 1 ASC;

-- Se eliminarán del sistema las empresas que no tienen transacciones registradas; entrega el listado de estas empresas.
SELECT company_name
FROM company
WHERE id NOT IN (
	SELECT DISTINCT company_id
    FROM transaction);
    
-- Nível 02. Ejercicio 01:
-- Identifica los cinco días en los que se generó la mayor cantidad de ingresos para la empresa por ventas. 
-- Muestra la fecha de cada transacción junto con el total de las ventas.
SELECT 	DATE(timestamp) AS Fecha,
		SUM(amount) AS Total_Ventas
FROM transaction
WHERE declined = 0
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- Nível 02. Ejercicio 02:
-- ¿Cuál es el promedio de ventas por país? Presente los resultados ordenados de mayor a menor promedio.
SELECT 	country AS Países,
		ROUND(AVG(amount), 2) AS Total_Ventas
FROM transaction tr
JOIN company co
ON co.id = tr.company_id
WHERE declined = 0
GROUP BY 1
ORDER BY 2 DESC;

-- Nível 02. Ejercicio 03:
-- En tu empresa, se plantea un nuevo proyecto para lanzar algunas campañas publicitarias para hacer competencia 
-- a la compañía “Non Institute”. Para ello, te piden la lista de todas las transacciones realizadas por empresas 
-- que están ubicadas en el mismo país que esta compañía. Mostrar el listado aplicando JOIN y subconsultas: 
SELECT *
FROM transaction tr
JOIN company co
ON co.id = tr.company_id
WHERE co.country = (
	SELECT country
    FROM company
    WHERE company_name = 'Non Institute')
AND NOT company_name = 'Non Institute';

-- Muestra el listado utilizando solo subconsultas:
SELECT *
FROM transaction
WHERE company_id IN (
	SELECT id 
    FROM company
	WHERE country = (
			SELECT country 
            FROM company
			WHERE company_name = "Non Institute") 
	AND NOT company_name = "Non Institute");

-- Nível 03. Ejercicio 01:
-- Presenta el nombre, teléfono, país, fecha y amount (cantidad) de aquellas empresas que realizaron transacciones con un valor 
-- comprendido entre 100 y 200 euros y en alguna de estas fechas: 29 de abril de 2021, 20 de julio de 2021 y 13 de marzo de 2022. 
-- Ordena los resultados de mayor a menor cantidad.
SELECT 	co.company_name, co.phone, co.country, DATE(tr.timestamp) AS date, tr.amount
FROM transaction tr
JOIN company co
ON tr.company_id = co.id
WHERE tr.amount BETWEEN 100 AND 200
AND DATE(tr.timestamp) IN ('2021-04-29', '2021-07-20', '2022-03-13')
ORDER BY 4 DESC;

-- Nível 03. Ejercicio 02:
-- Necesitamos optimizar la asignación de los recursos, lo cual dependerá de la capacidad operativa que se requiera. 
-- Por ello, te piden información sobre la cantidad de transacciones que realizan las empresas. 
-- Sin embargo, el departamento de recursos humanos es exigente y quiere un listado de las empresas donde especifiques 
-- si tienen más de 4 transacciones o menos.
SELECT co.company_name,
	CASE WHEN COUNT(tr.id) > 4 THEN 'More than 4'
	     WHEN COUNT(tr.id) <= 4 THEN 'less than 4'
	END AS 'Número de transacciones'
FROM transaction tr
JOIN company co
ON tr.company_id = co.id
GROUP BY 1;