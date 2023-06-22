-- Seleccionar todos los adjudicados 
select * from adjudicaciones where id_estado = 2 order by id_proveedor 

-- Contar las adjudicaciones de cada uno y calcular los montos 
select count(ad.id_proveedor) as cantidad, pr.descripcion, extract(year from ad.fecha_adjudicacion) as fecha, es.descripcion as estado, sum(ad.monto) as monto 
from adjudicaciones ad
join proveedores pr on pr.id = ad.id_proveedor
join estados es on es.id = ad.id_estado 
where ad.id_estado = 2 and extract(year from ad.fecha_adjudicacion) in (2020, 2021)
group by id_proveedor, pr.descripcion, fecha, es.descripcion
having count(ad.id_proveedor) > 50
order by cantidad desc  

-- Verificar la categorias 
select * from categorias c where id = 27 

-- Calcular el monto total de todas las instituciones 
select sum(ad.monto) as monto_total, ins.descripcion 
from adjudicaciones ad 
join llamados ll on ll.id = ad.id_llamado 
join instituciones ins on ins.id = ll.id_institucion 
group by (ll.id_institucion), ins.descripcion 
order by monto_total desc limit 15 

-- Filtrar por categoria y condicionar 
select ins.descripcion, ca.descripcion as categoria, sum(ad.monto) as monto_total	
from adjudicaciones ad 
join llamados ll on ll.id = ad.id_llamado 
join instituciones ins on ins.id = ll.id_institucion 
join categorias ca on ll.id_categoria = ca.id 
where ca.id in (27,33)
group by ll.id_institucion, ins.descripcion, ca.descripcion 
order by monto_total desc limit 15