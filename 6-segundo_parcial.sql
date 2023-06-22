/*
 * Segundo Parcial 
 * Jazmin Gamarra 
 */*/
 
 -----------------------------------------------------------------------------------------------------------------------------------------
 -- TEMA 1 
 -----------------------------------------------------------------------------------------------------------------------------------------
 
	-- Obtener todos los id de las cervezas 
	SELECT * FROM articulos  WHERE descripcion LIKE '%CERVEZA%';
	
	-- Ver todas las facturaciones de cerveza 
	select * from facturas_articulos fa
	where fa.articulo_id in (SELECT articulo_id FROM articulos  WHERE descripcion LIKE '%CERVEZA%') 
	 
	-- Ordenar las facturaciones por fecha descendientemente 
	select f.fecha, sum(fa.precio * fa.cantidad) as total_vendido from facturas_articulos fa
	join facturas f on f.factura_id = fa.factura_id 
	where fa.articulo_id in (SELECT articulo_id FROM articulos  WHERE descripcion LIKE '%CERVEZA%')
	group by f.fecha
	order by total_vendido desc 
	
	-- Mostrar la cantidad de clientes y el dia 
	select f.fecha, fn_nombredia(EXTRACT(DOW FROM f.fecha)) AS nombre_dia, 
	count(distinct f.cliente_id) as cantidad_clientes, sum(fa.precio * fa.cantidad) as total_vendido, f.fecha
	from facturas_articulos fa
	join facturas f on f.factura_id = fa.factura_id 
	where fa.articulo_id in (SELECT articulo_id FROM articulos  WHERE descripcion LIKE '%CERVEZA%')
	group by f.fecha
	order by total_vendido desc 
	limit 5 
 
 -----------------------------------------------------------------------------------------------------------------------------------------
 -- TEMA 2 
 -----------------------------------------------------------------------------------------------------------------------------------------
	
	-- Identificar los datos de la panaderia y cocina 
	 select * from proveedores p where descripcion like '%PANADERIA%' or  descripcion like '%COCINA%'
	 
	 -- Obtener el volumen de ventas de los proveedores 
	 select sum(fa.precio * fa.cantidad) as ventas, pr.descripcion from proveedores pr 
	 join articulos ar on ar.proveedor_id = pr.proveedor_id 
	 join facturas_articulos fa on fa.articulo_id = ar.articulo_id 
	 group by pr.proveedor_id
	 order by ventas desc 
	 
	 -- Calcular costo y ganancia 
	 select  pr.descripcion as proveedor, sum(fa.precio * fa.cantidad) as ventas, 
	 sum(fa.precio * fa.cantidad * 0.7) as costo, sum(fa.precio * fa.cantidad - fa.precio * fa.cantidad * 0.7) as ganancia 
	 from proveedores pr 
	 join articulos ar on ar.proveedor_id = pr.proveedor_id 
	 join facturas_articulos fa on fa.articulo_id = ar.articulo_id 
	 where pr.descripcion not like '%PANADERIA%' and  pr.descripcion not like '%COCINA%'
	 group by pr.proveedor_id
	 order by ventas desc 
	 limit 10
	 
	 -- Crear la vista 
	 create view vProveedores10 as
	 select  pr.descripcion as proveedor, sum(fa.precio * fa.cantidad) as ventas, 
	 sum(fa.precio * fa.cantidad * 0.7) as costo, sum(fa.precio * fa.cantidad - fa.precio * fa.cantidad * 0.7) as ganancia 
	 from proveedores pr 
	 join articulos ar on ar.proveedor_id = pr.proveedor_id 
	 join facturas_articulos fa on fa.articulo_id = ar.articulo_id 
	 where pr.descripcion not like '%PANADERIA%' and  pr.descripcion not like '%COCINA%'
	 group by pr.proveedor_id
	 order by ventas desc 
	 limit 10
	 
	 -- Consultar vista 
	 select * from vproveedores10 
 
-----------------------------------------------------------------------------------------------------------------------------------------
-- TEMA 3 
-----------------------------------------------------------------------------------------------------------------------------------------
	 
	 -- Identificar los cafes vendidos por nestle paraguay 
	 select ar.stock_minimo, ca.categoria, AR.descripcion as producto,  PR.descripcion as proveedor
	 from articulos ar
	 join proveedores pr on pr.proveedor_id = ar.proveedor_id 
	 join categorias ca on ca.id = ar.categoria_id 
	 where ar.descripcion like '%CAFE%' and pr.descripcion like '%NESTLE%'
	 
	 -- Modificar el stock minimo 
	 update articulos ar
	 set stock_minimo = 20
		from proveedores pr
		where ar.descripcion like '%CAFE%' 
		  and pr.descripcion like '%NESTLE%'
		  and ar.categoria_id <> 3
		  and pr.proveedor_id = ar.proveedor_id;
		
-----------------------------------------------------------------------------------------------------------------------------------------
-- TEMA 4 
-----------------------------------------------------------------------------------------------------------------------------------------
	
	-- Crear la tabla
	create table alertas_stock (
	  fecha date,
	  id_articulo varchar(100),
	  stock numeric(12,2)
	);
	
	-- Crear o actualizar el trigger 
	CREATE TRIGGER trigger_stock 
	AFTER INSERT OR UPDATE OR DELETE ON facturas_articulos
	FOR EACH row 
	EXECUTE FUNCTION fn_actualizar_stock();
	 	
    -- Consultar la tabla 
	select * from alertas_stock
	
	-- Probar el trigger 
	INSERT INTO public.facturas(factura_id, cliente_id, fecha)
	VALUES(6141592, 1, now());

	INSERT INTO public.facturas_articulos (detalle_id, factura_id, articulo_id, precio, cantidad)
    VALUES(1315603, '6141592', '7891000062968', 26545, 45);


	select * from facturas f where factura_id = '6141592'
	select max(detalle_id) from facturas_articulos fa 
	select * from articulos a where a.articulo_id = '7891000062968'