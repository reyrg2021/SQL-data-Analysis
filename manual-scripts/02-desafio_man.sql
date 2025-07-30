
-- Descripción del desafío
--A continuación, una empresa que dicta cursos de inglés nos hace entrega de un set de datos 
--que contiene información de inscritos. Estas inscripciones se realizan a través de dos vías, 
--por página web y por el blog de la institución.
--Con el set de datos, nos solicitan que realicemos un conjunto de consultas que serán 
--utilizadas para saber cuál es el medio que más utilizan los/as futuros estudiantes y cuál 
--tiene más impacto en las redes sociales.

drop database if exists desafio_2_reinier_rodriguez_595;
CREATE DATABASE desafio_2_reinier_rodriguez_595;-- Creando la base de datos para el 3er desafio 

drop table if exists inscritos;
-- Creando la tabla o conjunto de datos
CREATE TABLE INSCRITOS(cantidad INT, fecha DATE, fuente VARCHAR);

-- Insertando datos
INSERT INTO INSCRITOS(cantidad, fecha, fuente)
VALUES ( 44, '2021-01-01', 'Blog' );
INSERT INTO INSCRITOS(cantidad, fecha, fuente)
VALUES ( 56, '2021-01-01', 'Página' );
INSERT INTO INSCRITOS(cantidad, fecha, fuente)
VALUES ( 39, '2021-01-02', 'Blog' );
INSERT INTO INSCRITOS(cantidad, fecha, fuente)
VALUES ( 81, '2021-01-02', 'Página' );
INSERT INTO INSCRITOS(cantidad, fecha, fuente)
VALUES ( 12, '2021-01-03', 'Blog' );
INSERT INTO INSCRITOS(cantidad, fecha, fuente)
VALUES ( 91, '2021-01-03', 'Página' );
INSERT INTO INSCRITOS(cantidad, fecha, fuente)
VALUES ( 48, '2021-01-04', 'Blog' );
INSERT INTO INSCRITOS(cantidad, fecha, fuente)
VALUES ( 45, '2021-01-04', 'Página' );
INSERT INTO INSCRITOS(cantidad, fecha, fuente)
VALUES ( 55, '2021-01-05', 'Blog' );
INSERT INTO INSCRITOS(cantidad, fecha, fuente)
VALUES ( 33, '2021-01-05', 'Página' );
INSERT INTO INSCRITOS(cantidad, fecha, fuente)
VALUES ( 18, '2021-01-06', 'Blog' );
INSERT INTO INSCRITOS(cantidad, fecha, fuente) 
VALUES ( 12, '2021-01-06', 'Página' );
INSERT INTO INSCRITOS(cantidad, fecha, fuente) 
VALUES ( 34, '2021-01-07', 'Blog' );
INSERT INTO INSCRITOS(cantidad, fecha, fuente) 
VALUES ( 24, '2021-01-07', 'Página' );
INSERT INTO INSCRITOS(cantidad, fecha, fuente) 
VALUES ( 83, '2021-01-08', 'Blog' );
INSERT INTO INSCRITOS(cantidad, fecha, fuente) 
VALUES ( 99, '2021-01-08', 'Página' );
-- Ver los datos
select * from inscritos;

-- Punto 1 (¿Cuántos registros hay?)
select count(*) as cantidad_de_registros
from inscritos;

--Punto 2 ¿Cuántos inscritos hay en total?
select sum(cantidad) as cantidad_de_inscritos
from inscritos;

--Punto 3 ¿Cuál o cuáles son los registros de mayor antigüedad?
--Escenario 1 para saber cual registro es el de mayor antigüedad
select * from 
inscritos
order by fecha 
limit 1
;
--Punto 3 ¿Cuál o cuáles son los registros de mayor antigüedad?
--Escenario 2 para saber cuales registros tienen mayor antigüedad 
-- Variante con subconsulta pero no óptima
select * from 
inscritos
where fecha in (
select fecha  
from inscritos
order by fecha 
limit 1)
;

--Punto 3 ¿Cuál o cuáles son los registros de mayor antigüedad?
--Escenario 2 para saber cuales registros tienen mayor antigüedad 
drop table if exists inscritos_temp_3;
create temp table inscritos_temp_3 
as select fecha  
from inscritos
order by fecha 
limit 1
;



select * from 
inscritos
where fecha in(select * from  
inscritos_temp_3) 
;


-- Punto 4
-- ¿Cuántos inscritos hay por día? (Indistintamente de la fuente de inscripción)
select * from
inscritos;

select fecha,sum(cantidad) as cantidad_inscritos_por_dia
from inscritos 
group by fecha 
order by fecha
;

select sum(cantidad) as cantidad_inscritos_por_dia
from inscritos 
group by fecha 
order by fecha
;

-- Punto 5
--¿Cuántos inscritos hay por fuente?
select * from
inscritos;

select fuente,sum(cantidad) as cantidad_inscritos_por_fuente
from inscritos 
group by fuente 
;

--Punto 6
--¿Qué día se inscribió la mayor cantidad de personas? 
--Y 
--¿Cuántas personas se inscribieron en ese día?
select * from
inscritos;

--¿Qué día se inscribió la mayor cantidad de personas? 
select  fecha as dia_mayor_cant_pers
from inscritos 
group by fecha
order by sum(cantidad) desc
limit 1
; 


--¿Cuántas personas se inscribieron en ese día?
select  sum(cantidad) as cantidad_maxima_personas
from inscritos 
group by fecha 
order by cantidad_maxima_personas desc
limit 1
;
-- fecha y cantidad de personas

select  fecha,sum(cantidad) as cantidad_maxima
from inscritos 
group by fecha 
order by cantidad_maxima desc
limit 1
;

--Punto 7
--¿Qué día se inscribieron la mayor cantidad de personas utilizando el blog?


select fecha
from inscritos 
where fuente = 'Blog'
order by cantidad desc 
limit 1;


--¿Cuántas personas fueron? (si hay más de un registro con el máximo de personas, considera 
--solo el primero)
select cantidad
from inscritos 
where fuente = 'Blog'
order by cantidad desc 
limit 1;

-- Consulta general donde se obtiene el dia y la cantidad
select fecha,cantidad
from inscritos 
where fuente = 'Blog'
order by cantidad desc 
limit 1;

-- Punto 8 
--¿Cuál es el promedio de personas inscritas por día? Toma en consideración que la
--base de datos tiene un registro de 8 días, es decir, se obtendrán 8 promedios.
-- adicionalmete se organizó por fecha este promedio

select fecha,avg(cantidad) as inscritos_por_dia
from inscritos
group by fecha
order by fecha
;

-- Punto 9 
--¿Qué días se inscribieron más de 50 personas?
select *
from inscritos;
-- Se supone que se debe sumar la cantidad de personas en diferentes fuentes 
-- ya que se pregunta por dia no por fuente y en un mismo dia hay dos fuentes, por lo que 
-- el unico dia donde no se cumple la pregunta es en el dia 6
select fecha
from inscritos 
group by fecha 
having sum(cantidad)> 50
;

-- Punto 10
--¿Cuál es el promedio por día de personas inscritas?
--Considerando sólo calcular desde el tercer día.

-- Se creo una tabla temporal con el objetivo de no utilizar subconsultas o que el uso de esta sea mas decuado
-- Se optimiza la solucion, con esto me quedo con los dos registros mas bajos ordenados
-- Ademas esto se puede utilizar inlcuso si se adicionar mas registros con fechas mas antiguas
drop table if exists tabla_temp_10;
create temp table tabla_temp_10 as select fecha,avg(cantidad) as inscritos_por_dia
from inscritos
group by fecha
order by fecha
limit 2
;

-- Con esto busco y obtengo el promedio desde el 3er dia en adelante
-- Se logra calculando el promedio y buscando las fechas que no sean o no estan en la
-- tabla temporal, ademas se agrupan por fecha para calcular el promedio y se orden por fecha
-- por orden ascendente. 

select fecha,avg(cantidad)
from inscritos
where fecha not in (select fecha from 
tabla_temp_10)
group by fecha
order by fecha;


