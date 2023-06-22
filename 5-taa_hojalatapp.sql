-- Los datos de la entrega, el delivery, la cantidad de clientes a visitar, la fecha prevista de entrega y la cantidad 
-- de artículos por cada entrega:

	SELECT fa.numero_entrega, clientes_visitados, en.fecha_prevista, de.nombre_chofer, sum(far.cantidad)
	FROM facturas fa
	JOIN entregas en ON fa.numero_entrega = en.numero_entrega  
	JOIN delivery de ON de.codigo_chofer = en.codigo_chofer 
	JOIN facturas_articulos far ON far.numero_factura = fa.numero_factura 
	JOIN (
	    SELECT fa.numero_entrega, count( fa.numero_entrega) AS clientes_visitados
	    FROM facturas fa
	    GROUP BY fa.numero_entrega
	) AS subquery ON subquery.numero_entrega = fa.numero_entrega
	GROUP BY fa.numero_entrega, clientes_visitados, en.fecha_prevista, de.nombre_chofer

-- Los datos de los choferes, las zonas de entrega y el monto total de la comisión a pagar al delivery por las entregas:

	select en.codigo_chofer, de.nombre_chofer, en.codigo_zona, zo.zona, 
	sum(far.precio_venta*far.cantidad) as total, (zo.comision/100) * sum(far.precio_venta*far.cantidad) as comision_total
	from entregas en
	join delivery de on de.codigo_chofer = en.codigo_chofer 
	join zonas zo on zo.codigo_zona = en.codigo_zona 
	join facturas fa on en.numero_entrega = fa.numero_entrega 
	join facturas_articulos far on far.numero_factura = fa.numero_factura 
	group by en.numero_entrega, en.codigo_chofer, de.nombre_chofer, en.codigo_zona, zo.zona, zo.comision 
	
	-- Obtener la suma de cada factura 
	select sum(far.precio_venta*far.cantidad) from facturas_articulos far 
	join facturas fa on far.numero_factura = fa.numero_factura
	group by fa.numero_entrega

-- Cree una vista denominada vEntregas que contenga todos los datos según el ejemplo que se indica abajo:
	
	-- Crear la vista 
	CREATE VIEW vEntregas as
		select fa.numero_factura, fa.fecha_factura, fa.ruc_cliente, cl.nombre, fa.direccion_entrega, zo.zona, 
		en.numero_entrega, en.fecha_prevista, es.estado  
		from facturas fa
		join clientes cl on cl.ruc_cliente = fa.ruc_cliente 
		join entregas en on en.numero_entrega = fa.numero_entrega 
		join zonas zo on zo.codigo_zona = en.codigo_zona 
		join estados es on es.codigo_estado = en.codigo_estado 
	
	-- Consultar la vista 
	select * from vEntregas	
		
-- Lista de los 5 artículos más caros vendidos, hasta la fecha, y a qué clientes: 
	
	select fa.ruc_cliente, cl.nombre, far.codigo_articulo, ar.descripcion, far.precio_venta 
	from facturas_articulos far
	join facturas fa on far.numero_factura = fa.numero_factura 
	join clientes cl on cl.ruc_cliente = fa.ruc_cliente
	join articulos ar on ar.codigo_articulo = far.codigo_articulo 
	order by far.precio_venta desc limit 5 

-- Implemente un trigger para que cada vez que se venda un artículo (INSERT) disminuya el stock del artículo. 
-- Para demostrar el funcionamiento del trigger inserte una nueva factura en la cual se incluya un solo artículo. 
-- Debe incluir todas las sentencias SQL utilizadas. No es necesario que inserte datos de entrega.

	-- Crear la funcion que se ejecutara ante el trigger 
	CREATE OR REPLACE FUNCTION public.reducir_stock()
    RETURNS trigger
	LANGUAGE plpgsql
	AS $function$
		BEGIN
		    IF TG_OP = 'INSERT' THEN
		       update articulos  
		       set stock = (stock - new.cantidad) 
		       where codigo_articulo = new.codigo_articulo; 		       
		    END IF;
	    	RAISE NOTICE 'Se ejecutó el trigger para la tabla %', TG_TABLE_NAME;
		    RETURN NEW;
	END;
	$function$;

	-- Crear el trigger  
	CREATE or replace TRIGGER trigger_insertar
	AFTER INSERT ON facturas_articulos 
	FOR EACH ROW
	EXECUTE FUNCTION reducir_stock();

	-- Demostrar el funcionamiento 
	INSERT INTO public.facturas (numero_factura, ruc_cliente, direccion_entrega, fecha_factura, numero_entrega)
    VALUES('001-002-0000151', '1234567-4', '', now(), 456852);

	-- Verificar el stock de el producto
	select stock from articulos where codigo_articulo = 103
   
   	-- Insertar 
	INSERT INTO public.facturas_articulos (numero_factura, codigo_articulo, cantidad, precio_venta)
	VALUES('001-002-0000151', 103, 1, 6625000);

-- Cree y use una función SQL llamada Retraso() que devuelva la cantidad de días que faltan para la entrega considerando 
-- la fecha de la factura y la fecha prevista de entrega. Para los ya entregados la función debe devolver 0 (cero). 
-- Demuestre el funcionamiento desplegando una sentencia con el resultado indicado abajo: