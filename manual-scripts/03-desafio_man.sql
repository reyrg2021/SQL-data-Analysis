
--drop database if exists desafio4_g108_reinierrg;
----------------------------------------------------------------------------------------------
-- TODO ESTO PERTENECE AL PUNTO 1
drop database if exists desafio_3_reinier_rodriguez_595;
create database desafio_3_reinier_rodriguez_595;

-- Creación tabla "user"
drop table if exists usuarios;
create table 
usuarios(
id serial,
email varchar,
nombre varchar,
apellido varchar,
rol varchar);
-- Inserción de datos en la tabla usuarios
insert into usuarios(email,nombre,apellido,rol)
values ('ceo@microsoft.com','Satya','Nadella','administrador'),
       ('ceo@google.com','Sundar','Pichai','usuario'),
       ( 'ceo@facebook.com','Mark','Zuckerberg','usuario'),
       ('ceo@openai.com','Samuel','Altman','administrador'),
       ('ceo@amazon.com','Andy','Jassy','usuario');
select *
from usuarios;

-- Creación tabla "post"
drop table if exists articulos;
create table articulos(
id serial,
titulo varchar,
contenido text,
fecha_creacion timestamp,
fecha_actualizacion timestamp,
destacado boolean,
usuario_id bigint);
-- Inserción de datos en la tabla "post"
insert into articulos(titulo,contenido,fecha_creacion,fecha_actualizacion,destacado,usuario_id)
values ('Windows','La creacion de windows fue una revolucion y es a la actualidad ...','1995-01-01 10:10:10','2025-05-01 09:30:01',false,1),
       ('IA','La IA y los LLM son el futuro de la humanidad ...','2021-01-01 10:10:10','2025-02-05 10:10:01',true,4),
       ('Amazon','Amazon es una de las empresas mas grandes del mundo ...','2010-01-01 10:10:10','2023-10-05 23:10:01',true,5),
       ('Google','Google es una de las empresas mas grandes del mundo ...','2014-01-01 10:10:10','2021-12-05 23:10:01',false,2),
       ('Facebook','Faxebook es una de las ...','2009-01-01 10:10:10','2020-10-05 23:10:01',false,null);
select * from articulos;


--creacion de la tabla comentarios
drop table if exists comentarios;
create table comentarios(
id serial,
contenido varchar,
fecha_creacion timestamp,
usuario_id bigint,
post_id bigint);
-- Inserción de datos en la tabla comentarios
insert into comentarios(contenido,fecha_creacion,usuario_id,post_id)
values ( 'Windows 10 es ...','2020-05-15 10:20:06',1,1),
       ('Windows 7 es ...', '2010-09-20 22:14:56',2,1),
       ('Windows 11 es ...', '2022-06-20 20:14:56',3,1),
       ('IA es ...', '2024-03-02 12:14:56',1,2),
       ('IA es ...', '2025-04-02 11:14:56',2,2);

select * from comentarios;

-----------------------------------------------------------------------------------
-- PUNTO 2
--Cruza los datos de la tabla usuarios y posts, mostrando las siguientes columnas:
--nombre y email del usuario junto al título y contenido del post.

--Datos:
--Cruzar tablas usuario y articulos
--nombre,email--> usuario
--titulo,contenido --> articulo
--columna que los enlaza es: usuario_id


-- Variante usando where sin join (solo lo utilizare en este punto en adelante voy a utiliza los join)
select u.nombre,u.email,a.titulo,a.contenido
from usuarios u,articulos a  
where u.id = a.usuario_id;
-- Variante inner joint (elementos comunes a ambas tablas)
select u.nombre,u.email,a.titulo,a.contenido
from usuarios u
inner join articulos a
on u.id = a.usuario_id;
---------------------------------------------------------------------------------------
select *
from usuarios;
select *
from articulos;
select *
from comentarios;
--Punto 3
-- Muestra el id, título y contenido de los posts de los administradores.
--a. El administrador puede ser cualquier id.
--Datos:
-- id, titulo, contenido --> tabla articulo
--rol(administrador) --> tabla usuario
-- cruzar tablas usuarios <--> articulos
select a.id,a.titulo, a.contenido
from usuarios u 
inner join articulos a
on u.id = a.usuario_id
where u.rol ='administrador';
------------------------------------------------------------------------------------------------------------
select *
from usuarios;
select *
from articulos;
select *
from comentarios;
--Punto 4
--Cuenta la cantidad de posts de cada usuario.
--a. La tabla resultante debe mostrar el id e email del usuario junto con la
--cantidad de posts de cada usuario.
--Datos:
-- id,email --> tabla usuario
-- articulos(cantidad)--> tabla articulo
-- Se cuentan la cantidad de articulos realizados por los usuarios
-- Variante inner joint
select u.id,u.email,count(a.usuario_id) as cantidad_articulos_por_usuario
from usuarios u
inner join articulos a
on u.id = a.usuario_id
group by u.id,u.email;
-- Rta parcial 1/ Con inner se realiza la intersección entre la tabla A( usuarios) y la tabla B(articulos)
-- Es decir los elementos comunes de ambas tablas, como en articulos en la columna que se utiliza para realizar la conexión
-- existe un campo nulo, es decir no hay usuario con el uso de inner no se toma y como respuesta se tiene solo los usuario, email que han realizado articulos en este caso: 
-- Son 4 registros con valor de 1.
select u.id,u.email,count(a.usuario_id) as cantidad_articulos_por_usuario
from usuarios u
right join articulos a
on u.id = a.usuario_id
group by u.id,u.email;
-- Rta parcial 2/ Con right se toman todos los valores de la tabla a la derecha tabla B(articulos) y
-- los valores comunes con la tabla A(usuarios), en este caso se cuenta 1 articulo mas y como no tiene un id para relacionarlo con la tabla A
-- devuelve los campos id y email con valor nulo

select u.id,u.email,count(a.usuario_id) as cantidad_articulos_por_usuario
from usuarios u
left join articulos a
on u.id = a.usuario_id
group by u.id,u.email;
-- Rta parcial 3/ Con left se toman todos los valores de la tabla a la izquierda tabla A(usuarios) y
-- los valores comunes con la tabla B(articulos), este caso es el correcto ya que busca en la tabla A y la conecta con la tabla B y cuenta los articulos

--Rta final/ La selección correcta es la variante con left join.

---------------------------------------------------------------------------------------------------------
-- Punto 5
select *
from usuarios;
select *
from articulos;
select *
from comentarios;
-- Muestra el email del usuario que ha creado más posts.
--a. Aquí la tabla resultante tiene un único registro y muestra solo el email.
select u.email
from usuarios u
inner join articulos a
on u.id = a.usuario_id
group by u.email
order by count(a.usuario_id) desc
limit 1;

------------------------------------------------------------------------------------------------------------
--Punto 6
--Muestra la fecha del último post de cada usuario.
select *
from usuarios;
select *
from articulos;
select *
from comentarios;
-- Usando la sugerencia sobre la fecha de creacion
select max(a.fecha_creacion) as fecha_creacion_ultimo_art_por_usuario
from usuarios u
inner join articulos a 
on u.id = a.usuario_id
group by  a.usuario_id;

----------------------------------------------------------------------------------------------------------------
--Punto 7
select *
from usuarios;
select *
from articulos;
select *
from comentarios;
--Muestra el título y contenido del post (artículo) con más comentarios.
select a.titulo,a.contenido
from articulos a 
inner join comentarios c 
on c.post_id = a.id
group by a.titulo,a.contenido
order by count(c.post_id) desc
limit 1;

-------------------------------------------------------------------------------------------------------------------
--Punto 8
--Muestra en una tabla el título de cada post, el contenido de cada post y el contenido 
--de cada comentario asociado a los posts mostrados, junto con el email del usuario 
--que lo escribió.
select *
from usuarios;
select *
from articulos;
select *
from comentarios;


-- Código del punto 8
select a.titulo as titulo_post, a.contenido as contenido_post, c.contenido as contenido_comentario, u.email as email_usuario
from  comentarios c 
inner join articulos a
on c.post_id = a.id
inner join usuarios u
on a.usuario_id  = u.id;
-------------------------------------------------------------------------------------------------------------
--Punto 9
--Muestra el contenido del último comentario de cada usuario.
select *
from usuarios;
select *
from articulos;
select *
from comentarios;
-- Creo que puedo crear un tabla temporal para abordar el problema
-- 1ro creo una tabla temporal para obtener la fecha mas reciente por usuario

-- drop table if exists tabla_temp;
create temp table tabla_temp as select max(c.fecha_creacion) as fecha_maxima
from comentarios c 
inner join usuarios u 
on c.usuario_id = u.id 
group by c.usuario_id;

select *
from tabla_temp;
-- Utilizo esta tabla temporal para buscar en la tabla original
select c.contenido
from comentarios c 
inner join usuarios u
on c.usuario_id = u.id 
where c.fecha_creacion in(select
fecha_maxima from tabla_temp);
-----------------------------------------------------------------------------------------------------
--Punto 10
--Muestra los emails de los usuarios que no han escrito ningún comentario.
select *
from usuarios;
select *
from articulos;
select *
from comentarios;

-- Al igual que el anterior voy a probar mediante tablas temporales
-- drop table if exists tabla_temp_2
create temp table tabla_temp_2 as select u.email as email_con_comentarios
from usuarios u
inner join comentarios c
on u.id = c.usuario_id;

select *
from tabla_temp_2;
-- Busco en la tabla original
select u.email as email_con_comentarios
from usuarios u
left join comentarios c
on u.id = c.usuario_id
where u.email not in (select email_con_comentarios 
from tabla_temp_2);

