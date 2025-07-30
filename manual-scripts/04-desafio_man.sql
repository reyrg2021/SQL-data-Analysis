
-- Creacion de la BD
drop database if exists pf_db_reinier_rodriguez_595;
create database pf_db_reinier_rodriguez_595;
----------------------------------------------------------------------------------------------------------
--Punto 1
--Revisa el tipo de relación y crea el modelo correspondiente. Respeta las claves 
--primarias, foráneas y tipos de datos. 

-- Se debe insertar un tabla intermedia debido a que la relacion o cardinalidad es de N a N
-- Creando la tabla de peliculas
drop table if exists peliculas;
create table 
peliculas(
id int not null,
constraint pk_peliculas
primary key(id),
unique(id),
nombre varchar(255),
anno int);

-- Creando la tabla de tags
drop table if exists tags;
create table tags(
id int not null,
constraint pk_tags
primary key(id),
unique(id),
tag varchar(32));

-- Creando la tabla intermedia
drop table if exists pelicula_tag;
create table pelicula_tag(
pelicula_id int,
foreign key(pelicula_id)
references peliculas(id),
tag_id int,
foreign key(tag_id)
references tags(id));
------------------------------------------------------------------------------------------------
--Punto 2
--Inserta 5 películas y 5 tags; la primera película debe tener 3 tags asociados, la 
--segunda película debe tener 2 tags asociados. 

-- Insertando peliculas
insert into peliculas
(id,nombre,anno)
values
(1,'Star Wars: Una nueva amenaza',1977),
(2,'Star Wars: El Imperio contraataca',1980),
(3,'Star Wars: El retorno del Jedi',1983),
(4,'Star Wars: La amenaza fantasma',1999),
(5,'Star Wars: El ataque de los clones',2002);


-- Insertando tags para lo cual por ejemplo voy a considerar como tags a genero
insert into tags
(id,tag)
values
(1,'Ciencia ficción'),
(2,'Acción'),
(3,'Aventura'),
(4,'Fantasía'),
(5,'Suspenso');
select * from tags;
-- Variante usando solo 5 tags
insert into pelicula_tag
(pelicula_id,tag_id)
values
(1,2),
(1,3),
(1,4),
(2,1),
(2,5);

select * from peliculas;
select * from tags;
select * from pelicula_tag;
--------------------------------------------------------------
--Punto 3
-- Variante donde pongo los nombres, cuento los tags y ordeno por año
select p.anno,p.nombre, count(pt.tag_id) as cantidad_tags_por_pelicula
from peliculas p
left join pelicula_tag pt 
on p.id = pt.pelicula_id
group by p.nombre,p.anno
order by p.anno;

-- Variante donde cuento los tags y ordeno por año
select count(pt.tag_id) as cantidad_tags_por_pelicula
from peliculas p
left join pelicula_tag pt on p.id = pt.pelicula_id
group by p.nombre,p.anno
order by p.anno;
-------------------------------------------------------------------------
--Punto 4
--Crea las tablas correspondientes respetando los nombres, tipos, claves primarias y 
--foráneas y tipos de datos. (1 punto)
 drop table if exists preguntas;
create table preguntas(
id int not null,
constraint pk_preg
primary key(id),
unique(id),
pregunta varchar(255),
respuesta_correcta varchar);

drop table if exists usuarios;
create table usuarios(
id int not null,
constraint pk_user 
primary key(id),
unique(id),
nombre varchar(255),
edad int);

drop table if exists respuestas;
create table respuestas(
id int not null,
constraint pk_resp
primary key(id),
unique (id),
respuesta varchar(255),
usuario_id int,
constraint fk_user
foreign key(usuario_id)
references usuarios(id),
pregunta_id int,
constraint fk_preg
foreign key(pregunta_id)
references preguntas(id));
--------------------------------------------------------------------------------------
-- Punto 5
--Agrega 5 usuarios y 5 preguntas. 
--a. La primera pregunta debe estar respondida correctamente dos veces, por dos usuarios diferentes.  
--b. La segunda pregunta debe estar contestada correctamente solo por un usuario. 
--c. Las otras dos preguntas deben tener respuestas incorrectas. 

--Contestada correctamente signiﬁca que la respuesta indicada en la tabla respuestas 
--es exactamente igual al texto indicado en la tabla de preguntas. 
--(1 punto) 
insert into usuarios(id,nombre,edad)
values
(1,'Pedro',45),
(2,'Aleida',55),
(3,'Jorge',60),
(4,'Reinier',35),
(5,'Maria',44);
select * from usuarios;

insert into preguntas(id,pregunta,respuesta_correcta)
values
(1,'¿Cómo optimizar consultas en PostgreSQL?','Usa EXPLAIN ANALYZE para identificar cuellos de botella, crea índices adecuados,...'),
(2,'Diferencias entre INNER JOIN y LEFT JOIN','INNER JOIN solo muestra registros con coincidencias en ambas tablas, mientras LEFT JOIN muestra todos los registros ...'),
(3,'Mejores prácticas para índices en tablas grandes','Para tablas grandes, crea índices solo en columnas usadas en WHERE, JOIN y ORDER BY, ...'),
(4,'Implementación de búsqueda full-text en PostgreSQL','PostgreSQL ofrece búsqueda full-text con tsvector y tsquery.'),
(5,'Replicación de bases de datos PostgreSQL','Para alta disponibilidad en PostgreSQL, recomiendo replicación lógica para flexibilidad o streaming.');
select * from preguntas;

insert into respuestas(id,respuesta,usuario_id,pregunta_id)
values 
(1,'Usa EXPLAIN ANALYZE para identificar cuellos de botella, crea índices adecuados,...',1,1),
(2,'Usa EXPLAIN ANALYZE para identificar cuellos de botella, crea índices adecuados,...',5,1),
(3,'INNER JOIN solo muestra registros con coincidencias en ambas tablas, mientras LEFT JOIN muestra todos los registros ...',2,2),
(4,'La mejor forma de optimizar consultas en PostgreSQL es siempre usar SELECT *',3,3),
(5,'Para implementar búsqueda full-text en PostgreSQL, lo más eficiente es usar múltiples condiciones',4,4);

select * from respuestas;
--------------------------------------------------------------------------------------------------------------
--Punto 6
--Cuenta la cantidad de respuestas correctas totales por usuario (independiente de la pregunta).  
--(1 punto) 
select * from usuarios;
select * from respuestas;
select * from preguntas;

-- Variante donde se cuentan las respuestas correctas y nombres de los usuarios con las respuestas correctas
select u.nombre ,count (r.usuario_id) as cantidad_respuestas_correctas_por_usuario
from preguntas p
inner join respuestas r 
on p.id = r.pregunta_id
inner join usuarios u
on r.usuario_id = u.id
where r.respuesta = p.respuesta_correcta
group by u.nombre;

---------
--Prueba para ver si funciona lo anterior se va a modificar la tabla de respuestas y se va a dar una respuesta correcta mas a un usuario
--insert into respuestas(id,respuesta,usuario_id,pregunta_id)
--values 
--(1,'Usa EXPLAIN ANALYZE para identificar cuellos de botella, crea índices adecuados,...',1,1),
--(2,'Usa EXPLAIN ANALYZE para identificar cuellos de botella, crea índices adecuados,...',5,1),
--(3,'INNER JOIN solo muestra registros con coincidencias en ambas tablas, mientras LEFT JOIN muestra todos los registros ...',1,2),
--(4,'La mejor forma de optimizar consultas en PostgreSQL es siempre usar SELECT *',3,3),
--(5,'Para implementar búsqueda full-text en PostgreSQL, lo más eficiente es usar múltiples condiciones',4,4);
------Funciona el código------ OK
select r.usuario_id,count (r.id) as cantidad
from preguntas p
inner join respuestas r 
on p.id = r.pregunta_id
inner join usuarios u
on r.usuario_id = u.id
where r.respuesta = p.respuesta_correcta 
group by r.usuario_id;
------Variante para contar o ver los usuarios que no respondieron correctamente y los que si
-- drop table if exists temp_table; (no sirve en el docker compose para inicializar automatico) 
create temp table temp_table as select r.usuario_id,count (r.id) as cantidad
from preguntas p
inner join respuestas r 
on p.id = r.pregunta_id
inner join usuarios u
on r.usuario_id = u.id
where r.respuesta = p.respuesta_correcta 
group by r.usuario_id;

select u.nombre, coalesce(t.cantidad, 0) as respuestas_correctas
from usuarios u 
left join temp_table t on u.id = t.usuario_id
order by respuestas_correctas desc,u.nombre;

--------------------------------------------------------------------------------------
-- Punto 7
--Por cada pregunta, en la tabla preguntas, cuenta cuántos usuarios respondieron correctamente. (1 punto) 
-- Voy a realizar una estructura parecida a la de la pregunta anterior
select * from usuarios;
select * from respuestas;
select * from preguntas;
-- Con esto obtengo las preguntas que fueron respondidas correctamente y la cantidad
select p.id as pregunta_id, count(r.pregunta_id) as respuestas_correctas
from preguntas p 
inner join respuestas r
on p.id = r.pregunta_id
where r.respuesta = p.respuesta_correcta
group by p.id;
-- Creando tabla temporal para hacer algo parecido a la pregunta anterior
-- drop table if exists temp_table_2; (no sirve en el docker compose para inicializar automatico) 
create temp table temp_table_2 as select p.id as pregunta_id, count(r.pregunta_id) as cantidad
from preguntas p 
inner join respuestas r
on p.id = r.pregunta_id
where r.respuesta = p.respuesta_correcta
group by p.id;

select * from temp_table_2;

select p.id as preguntas, coalesce(t2.cantidad, 0) as respuestas_correctas_por_preguntas
from preguntas p 
left join temp_table_2 t2 on p.id = t2.pregunta_id;
----------------------------------------------------------------------------------
-- Punto 8
--Implementa un borrado en cascada de las respuestas al borrar un usuario. Prueba la 
--implementación borrando el primer usuario. (1 punto) 
select * from usuarios;
select * from respuestas;
select * from preguntas;
--Antes de poder implementar directamente el borrado en cascada se debe borrar la FK
alter table respuestas drop constraint fk_user, add constraint fk_user
foreign key(usuario_id) 
references usuarios(id)
on delete cascade;
-- Prueba de borrado del primer usuario
delete from usuarios u
where u.id = 1;
select * from usuarios;
---------------------------------------------------------------------------------------
--Punto 9
--Crea una restricción que impida insertar usuarios menores de 18 años en la base de 
--datos. (1 punto) 
alter table usuarios
add constraint rest_edad check(edad>=18);

insert into usuarios (id,nombre,edad)
values
(6,'Emily',18);
-- ESTE SE HICE PARA PROBAR LO ANTERIOR PERO EN FORMA AUTOMATICA NO SE PUEDE HACER 
--insert into usuarios (id,nombre,edad)
--values
--(6,'Emily',10);

----------------------------------------------------------------------------------------
-- Punto 10
--Altera la tabla existente de usuarios agregando el campo email. Debe tener la 
--restricción de ser único. (1 punto) 
alter table usuarios add column email varchar(255),
add constraint rest_email unique(email);

insert into usuarios(id,nombre,edad,email)
values
(7,'Lamine',18,'laminebarca@gmail.com'),
--(8,'Cubarsi',18,'laminebarca@gmail.com')
(9,'Cubarsi',18,'cubarsibarca@gmail.com');