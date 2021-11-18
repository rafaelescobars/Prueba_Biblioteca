----Cambiarse a base postgres
\c postgres;

-- Create a new database called 'library'
CREATE DATABASE library;

--Conexión base library
\c library;

--Encoding UTF8
SET client_encoding TO 'UTF8';

--Crear Tablas
CREATE TABLE authors(
  id_author SMALLINT NOT NULL,
  name VARCHAR(30) NOT NULL,
  last_name VARCHAR(30) NOT NULL,
  birth_year SMALLINT NOT NULL,
  death_year SMALLINT,
  PRIMARY KEY(id_author)
);

CREATE TABLE books(
  isbn VARCHAR(15) NOT NULL,
  title VARCHAR(50) NOT NULL,
  pages SMALLINT NOT NULL,
  borrowing_days SMALLINT NOT NULL,
  PRIMARY KEY(isbn)
);

CREATE TABLE author_book(
  id_author_book SERIAL NOT NULL,
  isbn VARCHAR(15) NOT NULL,
  id_author SMALLINT NOT NULL, 
  author_type VARCHAR(9) NOT NULL,
  PRIMARY KEY(id_author_book),
  FOREIGN KEY(isbn) REFERENCES books(isbn),
  FOREIGN KEY(id_author) REFERENCES authors(id_author)
  );

CREATE TABLE associates(
  rut VARCHAR(10) NOT NULL,
  name VARCHAR(30) NOT NULL,
  last_name VARCHAR(30) NOT NULL,
  address VARCHAR(50) NOT NULL,
  phone VARCHAR(12) NOT NULL,
  PRIMARY KEY(rut)
);

CREATE TABLE borrowings(
  id_borrowing SERIAL NOT NULL,
  isbn VARCHAR(15) NOT NULL,
  rut VARCHAR(10),
  start_date DATE,
  borrowing_days SMALLINT NOT NULL,
  deadline_date DATE,
  returning_date DATE,
  PRIMARY KEY(id_borrowing),
  FOREIGN KEY(isbn) REFERENCES books(isbn),
  FOREIGN KEY(rut) REFERENCES associates(rut)
);

--Insertar valores en tabla associates
INSERT INTO associates(rut, name, last_name, address, phone) VALUES 
('1111111-1', 'JUAN', 'SOTO', 'AVENIDA 1, SANTIAGO', '911111111'), 
('2222222-2', 'ANA', 'PÉREZ', 'PASAJE 2, SANTIAGO', '922222222'),
('3333333-3', 'SANDRA', 'AGUILAR', 'AVENIDA 2, SANTIAGO', '93333333'),
('4444444-4', 'ESTEBAN', 'JEREZ', 'AVENIDA 3, SANTIAGO', '944444444'),
('5555555-5', 'SILVANA', 'MUÑOZ', 'PASAJE 3, SANTIAGO', '955555555');

--Insertar valore en tabla authors
INSERT INTO authors(id_author, name, last_name, birth_year, death_year) VALUES 
(3, 'JOSE', 'SALGADO', 1968, 2020);
INSERT INTO authors(id_author, name, last_name, birth_year) VALUES 
(4, 'ANA', 'SALGADO', 1972),
(1, 'ANDRÉS', 'ULLOA', 1982);
INSERT INTO authors(id_author, name, last_name, birth_year, death_year) VALUES 
(2, 'SERGIO', 'MARDONES', 1950, 2012);
INSERT INTO authors(id_author, name, last_name, birth_year) VALUES 
(5, 'MATRTIN', 'PORTA', 1976);

--Insertar valores en tabla books
INSERT INTO books(isbn, title, pages, borrowing_days) VALUES 
('111-1111111-111', 'CUENTOS DE TERROR', 344, 7),
('222-2222222-222', 'POESÍAS CONTEMPORÁNEAS', 167, 7),
('333-3333333-333', 'HISTORIA DE ASIA', 511, 14),
('444-4444444-444', 'MANUAL DE MECÁNICA', 298, 14);

--Insertar valores en tabla author_book
INSERT INTO author_book(isbn, id_author, author_type) VALUES
('111-1111111-111',3,'PRINCIPAL'),
('111-1111111-111',4,'COAUTOR'),
('222-2222222-222',1,'PRINCIPAL'),
('333-3333333-333',2,'PRINCIPAL'),
('444-4444444-444',5,'PRINCIPAL');

--Setear valores iniciales en tabla borrowings
INSERT INTO borrowings(isbn, rut, start_date, borrowing_days, returning_date) VALUES 
((SELECT isbn FROM books WHERE books.title='CUENTOS DE TERROR'), (SELECT rut FROM associates WHERE (associates.name, associates.last_name) IN (('JUAN', 'SOTO'))), '2020-01-20', (SELECT borrowing_days FROM books WHERE books.title='CUENTOS DE TERROR'), '2020-01-27'),
((SELECT isbn FROM books WHERE books.title='POESÍAS CONTEMPORÁNEAS'), (SELECT rut FROM associates WHERE (associates.name, associates.last_name) IN (('SILVANA', 'MUÑOZ'))), '2020-01-20', (SELECT borrowing_days FROM books WHERE books.title='POESÍAS CONTEMPORÁNEAS'), '2020-01-30'),
((SELECT isbn FROM books WHERE books.title='HISTORIA DE ASIA'), (SELECT rut FROM associates WHERE (associates.name, associates.last_name) IN (('SANDRA', 'AGUILAR'))), '2020-01-22', (SELECT borrowing_days FROM books WHERE books.title='HISTORIA DE ASIA'), '2020-01-30'),
((SELECT isbn FROM books WHERE books.title='MANUAL DE MECÁNICA'), (SELECT rut FROM associates WHERE (associates.name, associates.last_name) IN (('ESTEBAN', 'JEREZ'))), '2020-01-23', (SELECT borrowing_days FROM books WHERE books.title='MANUAL DE MECÁNICA'), '2020-01-30'),
((SELECT isbn FROM books WHERE books.title='CUENTOS DE TERROR'), (SELECT rut FROM associates WHERE (associates.name, associates.last_name) IN (('ANA', 'PÉREZ'))), '2020-01-27', (SELECT borrowing_days FROM books WHERE books.title='CUENTOS DE TERROR'), '2020-02-04'),
((SELECT isbn FROM books WHERE books.title='MANUAL DE MECÁNICA'), (SELECT rut FROM associates WHERE (associates.name, associates.last_name) IN (('JUAN', 'SOTO'))), '2020-01-31', (SELECT borrowing_days FROM books WHERE books.title='MANUAL DE MECÁNICA'), '2020-02-12'),
((SELECT isbn FROM books WHERE books.title='POESÍAS CONTEMPORÁNEAS'), (SELECT rut FROM associates WHERE (associates.name, associates.last_name) IN (('SANDRA', 'AGUILAR'))), '2020-01-31', (SELECT borrowing_days FROM books WHERE books.title='POESÍAS CONTEMPORÁNEAS'), '2020-02-12');

--Agreagar la fecha de entrega según los dias de préstamo por libro
UPDATE borrowings SET deadline_date=borrowings.start_date + INTERVAL '7 day' WHERE borrowing_days=7;
UPDATE borrowings SET deadline_date=borrowings.start_date + INTERVAL '14 day' WHERE borrowing_days=14;

--Consultas
--Mostrar libros con menos de 300 páginas
SELECT title AS libros_mas_de_300_paginas FROM books WHERE pages<300;

--mostrar autores que hayn nacido despues de 01-01-1970
SELECT name || ' ' || last_name AS autores_nacidos_despues_de_01_01_1970 FROM authors WHERE birth_year>1970;

--Mostrar libro mas solicitado
SELECT bks.title AS libros_mas_solicitados, count(brr.isbn) AS veces_solicitados
FROM borrowings AS brr
INNER join books AS bks
ON brr.isbn=bks.isbn
GROUP BY bks.title
HAVING count(brr.isbn)=	(SELECT COUNT(borrowings.isbn) AS counted
								        FROM borrowings
								        GROUP BY isbn
								        ORDER BY counted DESC
								        LIMIT 1);

--Multa por atrasos
--SELECT deadline_date - returning_date AS dias_atraso, returning_date, deadline_date, id_borrowing, borrowing_days FROM borrowings where borrowing_days>7;
SELECT associates.name || ' ' || associates.last_name AS usuario, 
(deadline_date - returning_date)*100 AS multa_por_atraso 
FROM borrowings 
INNER join associates 
ON associates.rut=borrowings.rut 
AND borrowings.borrowing_days>7;