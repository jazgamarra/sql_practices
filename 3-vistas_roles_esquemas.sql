-- 

-- CREAR UNA VISTA 
CREATE VIEW  v_totales_cliente_origen AS
SELECT vto.*
FROM v_totv_origen vto

-- MOSTRAR UNA VISTA 
select * from v_totales_cliente_origen 

-- ELIMINAR UNA VISTA 
drop view v_viajes_depositos 

-- CREAR VISTAS CN JOINS 
create view v_viajes_depositos as 
	select vi.id, vi.fechasalida, vi.fechallegada, 
deo.nombre as origen, ded.nombre as destino, 
di.distancia 
from viajes vi 
join depositos deo on deo.id = vi.iddepositoorigen
join depositos ded on ded.id = vi.iddepositodestino 
join distancias di on di.id_origen = deo.id and di.id_destino = ded.id 

--- CREAR UN ROL 
create role infoi2023 login; 

-- CREAR LOS USUARIOS 
create user user1 with password 'user1';
create user user2 with password 'user2';
create user user3 with password 'user3';
create user jamin with password '333'; 

-- ASIGNAR EL ROL A LOS USUARIOS 
grant infoi2023 to user1, user2, jamin

-- INICIAR CON EL ROL POSGRES
set role postgres; 

-- DAR PERMISOS A JAMIN 
grant select on v_viajes_depositos to jamin

-- DAR PERMISOS AL ROL 
grant insert on v_viajes_depositos to infoi2023

-- CREAR UN ESQUEMA 
CREATE SCHEMA audit; 

