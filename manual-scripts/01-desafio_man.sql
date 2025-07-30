
-- Ejercicio 1. Crear una base de datos llamada desaﬁo-tuNombre-tuApellido-3digitos
drop database if exists desafio_1_reinier_rodriguez_595;
create database desafio_1_reinier_rodriguez_595; 

-- Ejercicio 2. Crear una tabla llamada clientes:
--a)   Con una columna llamada email de tipo varchar(50).
--b) Una columna llamada nombre de tipo varchar sin limitación.
--c) Una columna llamada teléfono de tipo varchar(16).
-- d) Un campo llamado empresa de tipo varchar(50).
-- e)Una columna de tipo smallint, para indicar la prioridad del cliente. Ahí se debe ingresar un valor entre 1 y 10, donde 10 es más prioritario.

create table clientes (email varchar(50),
nombre varchar,
teléfono varchar(16),
empresa varchar(50),
prioridad smallint);

-- Ejercicio 3. Ingresar 10 clientes distintos con distintas prioridades, el resto de los valores los puedes inventar.

insert into clientes (email,nombre,teléfono,empresa,prioridad) values ('ceo@amazon.com','Andy Jassy','14845101528','amazon',9);
insert into clientes (email,nombre,teléfono,empresa,prioridad) values ('ceo@google.com','Sundar Pichai','13844601528','google',8);
insert into clientes (email,nombre,teléfono,empresa,prioridad) values ('ceo@facebook.com','Mark Zuckerberg','11744600028','facebook',3);
insert into clientes (email,nombre,teléfono,empresa,prioridad) values ('ceo@openai.com','Samuel Altman','10733600028','openai',10);
insert into clientes (email,nombre,teléfono,empresa,prioridad) values ('ceo@microsoft.com','Satya Nadella','10733600028','microsoft',7);
Insert into clientes (email,nombre,teléfono,empresa,prioridad) values ('ceo@mercadolibre.com','Marcos Galperín','1112345678','mercadolibre',5);
insert into clientes (email,nombre,teléfono,empresa,prioridad) values ('ceo@shein.com','Chris Xu','01012345678','shein',1);
insert into clientes (email,nombre,teléfono,empresa,prioridad) values ('ceo@aliexpress.com','Daniel Zhang','01012345443','alibaba',6);
insert into clientes (email,nombre,teléfono,empresa,prioridad) values ('ceo@huawei.com','Ren Zhengfei','01013455443','huawei',4);
insert into clientes (email,nombre,teléfono,empresa,prioridad) values ('ceo@intel.com','Lip-Bu Tan','10678600028','intel',2);

-- Ejercicio 4. Selecciona los tres clientes de mayor prioridad.
Select * from clientes
Order by prioridad desc
Limit 3;

-- Ejercicio 5. Selecciona todos los clientes cuya prioridad sea mayor a 5.

Select * from clientes
Where prioridad > 5;
