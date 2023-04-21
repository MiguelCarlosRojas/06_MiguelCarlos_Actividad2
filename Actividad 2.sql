﻿-- Base de datos

/* Poner en uso base de datos master */
USE master;

/* Eliminar base de datos */
DROP DATABASE db_SalesClothes;

/* Crear base de datos Sales Clothes */
CREATE DATABASE db_SalesClothes;

/* Poner en uso la base de datos */
USE db_SalesClothes;

/* Configurar idioma español en el servidor */
SET LANGUAGE Español
GO
SELECT @@language AS 'Idioma'
GO

/* Configurar el formato de fecha */
SET DATEFORMAT dmy
GO

-- Tablas

/* Crear tabla client */
CREATE TABLE client (
    id int identity(1,1)  NOT NULL,
    type_document char(3)  NOT NULL,
    number_document char(15)  NOT NULL,
    names varchar(60)  NOT NULL,
    last_name varchar(90)  NOT NULL,
    email varchar(80)  NOT NULL,
    cell_phone char(9)  NOT NULL,
    birthdate date  NOT NULL,
    active bit DEFAULT (1)  NOT NULL,
    CONSTRAINT client_pk PRIMARY KEY  (id)
);


/* El tipo de documento puede ser DNI ó CNE */
ALTER TABLE client
	DROP COLUMN type_document
GO

/* Agregar restricción para tipo documento */
ALTER TABLE client
	ADD type_document char(3)
	CONSTRAINT type_document_client
	CHECK(type_document ='DNI' OR type_document ='CNE')
GO

/* Eliminar columna number_document de tabla client */
ALTER TABLE client
	DROP COLUMN number_document
GO

/* El número de documento sólo debe permitir dígitos de 0 - 9 */
ALTER TABLE client
	ADD number_document char(9)
	CONSTRAINT number_document_client
	CHECK (number_document like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][^A-Z]')
GO

/* Eliminar columna email de tabla client */
ALTER TABLE client
	DROP COLUMN email
GO

/* Agregar columna email */
ALTER TABLE client
	ADD email varchar(80)
	CONSTRAINT email_client
	CHECK(email LIKE '%@%._%')
GO

/* Eliminar columna celular */
ALTER TABLE client
	DROP COLUMN cell_phone
GO

/* Validar que el celular esté conformado por 9 números */
ALTER TABLE client
	ADD cell_phone char(9)
	CONSTRAINT cellphone_client
	CHECK (cell_phone like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
GO

/* Eliminar columna fecha de nacimiento */
ALTER TABLE client
	DROP COLUMN birthdate
GO

/* Sólo debe permitir el registro de clientes mayores de edad */
ALTER TABLE client
	ADD birthdate date
	CONSTRAINT birthdate_client
	CHECK((YEAR(GETDATE())- YEAR(birthdate )) >= 18)
GO

/* Crear tabla seller */
CREATE TABLE seller (
    id int identity(1,1)  NOT NULL,
    type_document char(3)  NOT NULL,
    number_document char(15)  NOT NULL,
    names varchar(60)  NOT NULL,
    last_name varchar(90)  NOT NULL,
    salary decimal(8,2)  NOT NULL,
    cell_phone char(9)  NOT NULL,
    email varchar(80)  NOT NULL,
    active bit DEFAULT (1)  NOT NULL,
    CONSTRAINT seller_pk PRIMARY KEY  (id)
);

/* El tipo de documento puede ser DNI ó CNE */
ALTER TABLE seller
	DROP COLUMN type_document
GO

/* Agregar restricción para tipo documento */
ALTER TABLE seller
	ADD type_document char(3)
	CONSTRAINT type_document_seller
	CHECK(type_document ='DNI' OR type_document ='CNE')
GO

/* Eliminar columna number_document de tabla client */
ALTER TABLE seller
	DROP COLUMN number_document
GO

/* El número de documento sólo debe permitir dígitos de 0 - 9 */
ALTER TABLE seller
	ADD number_document char(9)
	CONSTRAINT number_document_seller
	CHECK (number_document like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][^A-Z]')
GO

/* Eliminar columna salary de tabla seller */
ALTER TABLE seller
	DROP COLUMN salary
GO

/* Crear columna salary */
ALTER TABLE seller
	ADD salary decimal(8,2)
GO

/*Poner valor predeterminado 1025 */
ALTER TABLE seller 
    ADD DEFAULT 1025 FOR salary
GO

/* Eliminar columna celular */
ALTER TABLE seller
	DROP COLUMN cell_phone
GO

/* Validar que el celular esté conformado por 9 números */
ALTER TABLE seller
	ADD cell_phone char(9)
	CONSTRAINT cellphone_seller
	CHECK (cell_phone like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
GO

/* Eliminar columna email de tabla client */
ALTER TABLE seller
	DROP COLUMN email
GO

/* Agregar columna email */
ALTER TABLE seller
	ADD email varchar(80)
	CONSTRAINT email_seller
	CHECK(email LIKE '%@%._%')
GO

/* Crear tabla clothes */
CREATE TABLE clothes (
    id int identity(1,1)  NOT NULL,
    descriptions varchar(60)  NOT NULL,
    brand varchar(60)  NOT NULL,
    amount int  NOT NULL,
    size varchar(10)  NOT NULL,
    price decimal(8,2)  NOT NULL,
    active bit DEFAULT (1)  NOT NULL,
    CONSTRAINT clothes_pk PRIMARY KEY  (id)
);

/* Crear tabla sale */
CREATE TABLE sale (
    id int identity(1,1)  NOT NULL,
    date_time datetime  NOT NULL,
    seller_id int  NOT NULL,
    client_id int  NOT NULL,
    active bit DEFAULT (1)  NOT NULL,
    CONSTRAINT sale_pk PRIMARY KEY  (id)
);

/*Poner el valor predeterminado la fecha y hora del servidor */
ALTER TABLE sale
    ADD CONSTRAINT date_time_sale DEFAULT (GETDATE()) FOR date_time
GO

/* Crear tabla sale_detail */
CREATE TABLE sale_detail (
    id int  NOT NULL,
    sale_id int  NOT NULL,
    clothes_id int  NOT NULL,
    amount int  NOT NULL,
    CONSTRAINT sale_detail_pk PRIMARY KEY  (id)
);


-- foreign keys
/* Relacionar tabla sale con tabla client */
ALTER TABLE sale
	ADD CONSTRAINT sale_client FOREIGN KEY (client_id)
	REFERENCES client (id)
	ON UPDATE CASCADE 
      ON DELETE CASCADE
GO

/* Relacionar tabla sale_detail_clothes con tabla sale_detail */
ALTER TABLE sale_detail 
	ADD CONSTRAINT sale_detail_clothes FOREIGN KEY (clothes_id)
    REFERENCES clothes (id)
	ON UPDATE CASCADE 
      ON DELETE CASCADE
GO

/* Relacionar tabla sale_detail_sale con tabla sale_detail */
ALTER TABLE sale_detail 
	ADD CONSTRAINT sale_detail_sale FOREIGN KEY (sale_id)
    REFERENCES sale (id)
	ON UPDATE CASCADE 
      ON DELETE CASCADE
GO

/* Relacionar tabla sale_seller con tabla sale */
ALTER TABLE sale 
	ADD CONSTRAINT sale_seller FOREIGN KEY (seller_id)
    REFERENCES seller (id)
	ON UPDATE CASCADE 
      ON DELETE CASCADE
GO

/* Ver relaciones creadas entre las tablas de la base de datos */
SELECT 
    fk.name [Constraint],
    OBJECT_NAME(fk.parent_object_id) [Tabla],
    COL_NAME(fc.parent_object_id,fc.parent_column_id) [Columna FK],
    OBJECT_NAME (fk.referenced_object_id) AS [Tabla base],
    COL_NAME(fc.referenced_object_id, fc.referenced_column_id) AS [Columna PK]
FROM 
    sys.foreign_keys fk
    INNER JOIN sys.foreign_key_columns fc ON (fk.OBJECT_ID = fc.constraint_object_id)
GO


---Registros en las tablas MAESTRAS

/*Crear o insertar registros client*/
INSERT INTO client 
    (type_document, number_document, names, last_name, email, cell_phone, birthdate)
VALUES
    ('DNI', '78451233', 'Fabiola', 'Perales Campos', 'fabiolaperales@gmail.com', '991692597', '19/01/2005'),
    ('DNI', '14782536', 'Marcos', 'Dávila Palomino', 'marcosdavila@gmail.com', '982514752', '03/03/1990'),
    ('DNI', '78451236', 'Luis Alberto', 'Barrios Paredes', 'luisbarrios@outlook.com', '985414752', '03/10/1995'),
    ('CNE', '352514789', 'Claudia María', 'Martínez Rodríguez', 'claudiamartinez@yahoo.com', '995522147', '23/09/1992'),
    ('CNE', '142536792', 'Mario Tadeo', 'Farfán Castillo', 'mariotadeo@outlook.com', '973125478', '25/11/1997'),
    ('DNI', '58251433', 'Ana Lucrecia', 'Chumpitaz Prada', 'anachumpitaz@gmail.com', '982514361', '17/10/1992'),
    ('DNI', '15223369', 'Humberto', 'Cabrera Tadeo', 'humbertocabrera@yahoo.com', '977112234', '27/05/1990'),
    ('CNE', '442233698', 'Rosario', 'Prada Velásquez', 'rosarioprada@outlook.com', '971144782', '05/11/1990')
GO

/* Listar registros de tabla client */
SELECT * FROM client

/*Crear o insertar registros seller*/
INSERT INTO seller
    (type_document, number_document, names, last_name, cell_phone, email)
VALUES
    ('DNI', '11224578', 'Oscar', 'Paredes Flores', '985566251', 'oparedes@miemrpesa.com'),
    ('CNE', '889922365', 'Azucena', 'Valle Alcazar', '966338874', 'avalle@miemrpesa.com'),
    ('DNI', '44771123', 'Rosario', 'Huarca Tarazona', '933665521', 'rhuaraca@miempresa.com')
GO

/* Listar registros de tabla seller */
SELECT * FROM seller

/*Crear o insertar registros  clothes*/
INSERT INTO  clothes
    (descriptions, brand, amount, size, price)
VALUES
    ('Polo camisero', 'Adidas', '20', 'Medium', '40.50'),
    ('Short playero', 'Nike', '30', 'Medium', '55.50'),
    ('Camisa sport', 'Adams', '60', 'Large', '60.80'),
    ('Camisa sport', 'Adams', '70', 'Medium', '58.75'),
    ('buzo de verano', 'Reebok', '45', 'Small', '62.90'),
    ('Pantalón Jean', 'Lewis', '35', 'Large', '73.60')
GO

/* Listar registros de tabla clothes */
SELECT * FROM clothes


--- Listar documentos

/* Listar tipo de documento DNI de client */
SELECT * FROM client
	WHERE type_document like'DNI'
GO

/* Listar cuyo servidor de correo electrónico sea outlook.com */
SELECT * FROM client
	WHERE email like '%@outlook.com'
GO

/* Listar tipo de documento DNI de client */
SELECT * FROM seller
	WHERE type_document LIKE 'CNE'
GO

/*Listar todas las prendas de ropa clothes  cuyo costo sea menor e igual que S/. 55.00 */
SELECT * FROM clothes
	WHERE price <= 55.00
GO

/* Listar todas las prendas de ropa clothes cuya marca sea Adams */
SELECT * FROM clothes
	WHERE brand LIKE 'Adams'
GO


--- Eliminar datos

/*Eliminar lógicamente los datos de un cliente (client) de acuerdo a un determinado id*/
UPDATE client
	SET active = '0' 
	WHERE id = '6'
GO

/* Listar registros de tabla client */
SELECT * FROM client


/*Eliminar lógicamente los datos de un cliente (seller) de acuerdo a un determinado id*/
UPDATE seller
	SET active = '0' 
	WHERE id = '2'
GO

/* Listar registros de tabla seller */
SELECT * FROM seller

/*Eliminar lógicamente los datos de un cliente (clothes) de acuerdo a un determinado id*/
UPDATE clothes
	SET active = '0' 
	WHERE id = '5'
GO

/* Listar registros de tabla clothes */
SELECT * FROM clothes

--- fin