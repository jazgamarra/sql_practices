/*
Fecha: 22/04/2023
Autor: jazgamarra
Nota: Práctica de sentencias SQL SELECT
Base de datos: distribuidora
*/

/*
  TEMA 1. (Resuelto). 
  Obtener los primeros 10 articulos proveidos por ALGODONERA GUARANI
*/  
  
--Paso 1. Obtenga todos los proveedores para identificar a ALGODONERA GUARANI...
select * from proveedores;
-- o busque por patrones:
select * from proveedores where desc_proveedor ilike '%algo%';

-- Paso 2. Recuperar todos los articulos que provee ALGODONERA GUARANI (codigo = 3)
select * from articulos where codigo_proveedor = 3;

-- Paso 3. SOLUCION: incluya el límite
select * from articulos where codigo_proveedor = 3 limit 10;


/*
TEMA 2. De la consulta anterior recupere solamente el código del articulo,
la descripción, el precio unitario, el nombre y el email del proveedor.
Ordene los resultados por la columna precio unitario en forma descendente
*/
select ar.codigo_articulo, ar.descripcion, ar.precio_unitario, pr.desc_proveedor, pr.email_proveedor 
from articulos ar 
join proveedores pr on ar.codigo_proveedor = pr.codigo_proveedor 
where ar.codigo_proveedor = 3 
order by ar.precio_unitario desc limit 10;

	
/*
TEMA 3. De la consulta anterior incluya solamente los articulos 
cuyo precio se encuentra en un rago entre 4 millón y 5 millones inclusive.
*/

select ar.codigo_articulo, ar.descripcion, ar.precio_unitario, pr.desc_proveedor, pr.email_proveedor 
from articulos ar 
join proveedores pr on ar.codigo_proveedor = pr.codigo_proveedor 
where ar.codigo_proveedor = 3 and ar.precio_unitario between 4000000 and 5000000
order by ar.precio_unitario desc limit 10;

/*
TEMA 4. La consulta anterior recupera el articulo más caro proveido por ALGODONERA GUARANI.
Por l tanto, despligue: numero_pedido, fecha, ruc y nombre del cliente, asi como el precio y
la cantidad vendida de dicho articulo en el mes de junio del año 2017.
*/

select pe.numero_pedido, pe.fecha, cl.nombre, a.codigo_articulo, a.descripcion, a.precio_unitario, p.desc_proveedor, p.email_proveedor
from articulos a join proveedores p on a.codigo_proveedor = p.codigo_proveedor
join pedidos_articulos d on a.codigo_articulo = d.codigo_articulo
join pedidos pe on d.numero_pedido = pe.numero_pedido and d.anho = pe.anho
join clientes cl on pe.ruc = cl.ruc
where a.codigo_proveedor = 3 and precio_unitario between 4000000 and 5000000
and pe.fecha between '2017-06-01' and '2017-07-31'

/*
TEMA 5. Investigue lo siguiente:
a) Otras formas de hacer la consulta del tema 4 sin usar BETWEEN ni >= en las fechas.
*/

select pe.numero_pedido, pe.fecha, cl.nombre, ar.codigo_articulo, ar.descripcion, ar.precio_unitario, pr.desc_proveedor, pr.email_proveedor
from articulos ar join proveedores pr on ar.codigo_proveedor = pr.codigo_proveedor
join pedidos_articulos pa on ar.codigo_articulo = ar.codigo_articulo
join pedidos pe on pa.numero_pedido = pe.numero_pedido and pa.anho = pe.anho
join clientes cl on pe.ruc = cl.ruc
where ar.codigo_proveedor = 3 and precio_unitario between 4000000 and 5000000
	and extract(month from fecha) in (6,7) and extract(year from fecha) = 2017

/*
b) Otras formas de hacer la consulta sin digitar el codigo del articulo.
*/

select pe.numero_pedido, pe.fecha, cl.nombre, ar.codigo_articulo, ar.descripcion, ar.precio_unitario, pr.desc_proveedor, pr.email_proveedor
from articulos ar join proveedores pr on ar.codigo_proveedor = pr.codigo_proveedor
join pedidos_articulos pa on ar.codigo_articulo = pa.codigo_articulo
join pedidos pe on pa.numero_pedido = pe.numero_pedido 
join clientes cl on pe.ruc = cl.ruc
where ar.codigo_articulo in (
	select ar.codigo_articulo
	from articulos ar 
	join proveedores pr on ar.codigo_proveedor = pr.codigo_proveedor 
	where ar.codigo_proveedor = 3 and ar.precio_unitario between 4000000 and 5000000
	order by ar.precio_unitario desc limit 10
)
and extract(month from fecha) in (6,7) and extract(year from fecha) = 2017