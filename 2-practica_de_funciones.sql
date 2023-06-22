-- Obtener la cantidad de articulos 
	select count(*) as cantidad from articulos where codigo_tipo = 1; 
	
	-- Obtener el articulo mas caro 
	select max(precio_unitario) from articulos
	
	-- Suma de las ganancias de junio de 2017 
	select sum(total) from pedidos where extract(month from fecha) = 6 and anho = 2017
	
	-- Agregar la cantidad de pedidos 
	select sum(total) as ganancia, count(*) as cantidad_pedidos from pedidos where extract(month from fecha) = 6 and anho = 2017
	
	-- Agregar mayor y menor monto 
	select sum(total) as ganancia, count(*) as cantidad_pedido, min(total) as menor_monto, max(total) as mayor_monto 
	from pedidos where extract(month from fecha) = 6 and anho = 2017
	
	-- Agregar cantidad de clientes 
	select sum(total) as ganancia, count(*) as cantidad_pedido, count(distinct ruc) as cantidad_clientes, min(total) as menor_monto, max(total) as mayor_monto 
	from pedidos where extract(month from fecha) = 6 and anho = 2017
	
	-- Anho 2016 y 2017 a la vez 
	select sum(total) as ganancia, count(*) as cantidad_pedido, count(distinct ruc) as cantidad_clientes, min(total) as menor_monto, max(total) as mayor_monto 
	from pedidos where extract(month from fecha) = 6 and anho in (2016, 2017)
	
	-- EJemplo del profe -> Extraer los datos de 2016 y 2017 por separado 
	select sum(p.total) as Total, count(*) as cantidad ,count(distinct p.ruc) as clientes, max(p.total) as monto_mayor, min(p.total) as monto_menor,
	p.anho, extract(month from p.fecha) mes
	from pedidos p 
	where p.anho in (2016,2017) and extract(month from p.fecha) = 6
	group by p.anho, 
	extract (month from p.fecha)
	
	-- Extraer la suma de cada mes 
	select sum(p.total) as Total, count(*) as cantidad, count(distinct p.ruc) as clientes, max(p.total) as monto_mayor, min(p.total) as monto_menor,
	    p.anho, to_char(p.fecha, 'Month' ) as mes
	from pedidos p
	where p.anho in (2016, 2017)
	group by p.anho, to_char(p.fecha, 'Month' )
	order by p.anho, to_char(p.fecha, 'Month' )
	
	-- En espanhol
	SET lc_time TO 'es_ES.UTF-8'; -- cambiar el lenguaje de la db 
	SELECT SUM(p.total) AS Total, COUNT(*) AS cantidad, COUNT(DISTINCT p.ruc) AS clientes, MAX(p.total) AS monto_mayor, MIN(p.total) AS monto_menor,
	    p.anho, to_char(p.fecha, 'TMMonth') AS mes
	FROM pedidos p
	WHERE p.anho IN (2016, 2017)
	GROUP BY p.anho, to_char(p.fecha, 'TMMonth')
	ORDER BY p.anho, to_char(p.fecha, 'TMMonth');