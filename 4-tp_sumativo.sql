/* ACTIVIDAD U4.7 
 * Autor: Jazmin Gamarra 
 * */

------------------------------------------------------------------------------------------------------------------------------------------
-- Agregue una nueva columna a la tabla cuentas que se llame saldo_actual para almacenar el saldo actual de cada cuenta.
------------------------------------------------------------------------------------------------------------------------------------------

		-- Crear el campo en la tabla 
		select * from cuentas;
		alter table cuentas add saldo_actual numeric;

------------------------------------------------------------------------------------------------------------------------------------------
-- Cree una sentencia que actualice el campo saldo_actual en la cuenta número 5576. Utilice la función para calcular saldo ya disponible en la base de datos.
------------------------------------------------------------------------------------------------------------------------------------------
	
		-- Ver el codigo de cuenta de la cuenta numero 5576 
		select codigo_cuenta from cuentas c where c.numero_cuenta = 5576
	
		-- Ver su ultimo movimiento usando el codigo de cuenta
		select max(m.codigo_movimiento) from movimiento m where m.codigo_cuenta  = 10833;	
		
		-- Obtener el mismo resultado con subselects en vez de poner el codigo de cuenta 
		SELECT calcularsaldo(max(m.codigo_movimiento)) AS saldo
		FROM movimiento m
		join cuentas c on c.codigo_cuenta = m.codigo_cuenta 
		WHERE c.numero_cuenta = 5576;
			
		-- Actualizar el campo 
		UPDATE cuentas
		SET saldo_actual = (
			    SELECT calcularsaldo(max(m.codigo_movimiento))
			    FROM movimiento m
			    JOIN cuentas c ON c.codigo_cuenta = m.codigo_cuenta
			    WHERE c.numero_cuenta = 5576)
		WHERE numero_cuenta = 5576;
	
		-- El mismo pero menos redundante xd 
		UPDATE cuentas c 
		SET saldo_actual = (
			    SELECT calcularsaldo(max(m.codigo_movimiento))
			    FROM movimiento m
			    where m.codigo_cuenta = c.codigo_cuenta)
		WHERE c.numero_cuenta = 5576;
	
		-- Verificar si se cargo correctamente 
		select saldo_actual from cuentas where numero_cuenta = 5576 
	
------------------------------------------------------------------------------------------------------------------------------------------
-- Cree un trigger sobre la tabla movimiento que actualice el saldo por cada movimiento que se inserte, se borre o se actualice.
------------------------------------------------------------------------------------------------------------------------------------------
		
		-- Crear la funcion que se ejecutara ante el trigger 
		CREATE OR REPLACE FUNCTION public.trigger_saldo()
		RETURNS TRIGGER AS $$
		BEGIN
		    IF TG_OP = 'INSERT' THEN
		        -- Actualizar saldo en la tabla cuentas para el movimiento insertado
		        UPDATE cuentas c
		        SET saldo_actual = (SELECT calcularsaldo(max(m.codigo_movimiento))
		                            FROM movimiento m
		                            WHERE m.codigo_cuenta = c.codigo_cuenta)
		        WHERE c.codigo_cuenta = NEW.codigo_cuenta;
		    ELSIF TG_OP = 'DELETE' THEN
		        -- Actualizar saldo en la tabla cuentas para el movimiento borrado
		        UPDATE cuentas c
		        SET saldo_actual = (SELECT calcularsaldo(max(m.codigo_movimiento))
		                            FROM movimiento m
		                            WHERE m.codigo_cuenta = c.codigo_cuenta)
		        WHERE c.codigo_cuenta = OLD.codigo_cuenta;
		    ELSIF TG_OP = 'UPDATE' THEN
		        -- Actualizar saldo en la tabla cuentas para el movimiento actualizado
		        UPDATE cuentas c
		        SET saldo_actual = (SELECT calcularsaldo(max(m.codigo_movimiento))
		                            FROM movimiento m
		                            WHERE m.codigo_cuenta = c.codigo_cuenta)
		        WHERE c.codigo_cuenta = NEW.codigo_cuenta;
		    END IF;
		
		    RETURN NEW;
		END;
		$$ LANGUAGE plpgsql;
	
		-- Crear el trigger 
		CREATE or replace TRIGGER trigger_operaciones
		AFTER INSERT OR UPDATE OR DELETE ON movimiento
		FOR EACH ROW
		EXECUTE FUNCTION trigger_saldo();
	
		-- Para eliminar un trigger 
		DROP TRIGGER trigger_operaciones ON movimiento;
		
------------------------------------------------------------------------------------------------------------------------------------------
-- Demuestre el funcionamiento del trigger insertando, mediante SQL, un nuevo movimiento de depósito en la cuenta 5576 por un monto del 1.000.000 (un millón), con la fecha actual.
------------------------------------------------------------------------------------------------------------------------------------------
	
		-- Probando los selects de los datos que queremos insertar 
		select codigo_cuenta from cuentas c where c.numero_cuenta = 5576; -- numero de cuenta 
		select max(numero_movimiento) + 1 from movimiento where codigo_cuenta = 10833 -- ultimo movimiento + 1  
		select now() -- fecha actual 
		select tm.codigo_tipo_movimiento from tipos_movimiento tm where descripcion='DEPOSITO' -- codigo de movimiento para deposito 
		select max(comprobante)+1 from movimiento m -- ultimo comprobante + 1 
		select (count(distinct numero_movimiento)) from movimiento  
			
		-- Insertar con los valores 
		insert into movimiento (codigo_cuenta, numero_movimiento, fecha_operacion, importe, codigo_tipo_movimiento, comprobante) values (
		10833, 37, now(), 1000000, 1, 5247613)
		select * from movimiento where comprobante = 5247613; 
		
		-- Insertar con subselects 
		INSERT INTO public.movimiento (codigo_cuenta, numero_movimiento, fecha_operacion, importe, codigo_tipo_movimiento, comprobante)
		VALUES(	
		(select codigo_cuenta from cuentas c where c.numero_cuenta = 5576), 
		(select max(m.numero_movimiento) + 1 from movimiento m where codigo_cuenta = 10833),
		(select now()),
		(1000000), 
		(select tm.codigo_tipo_movimiento from tipos_movimiento tm where descripcion='DEPOSITO'),
		(select max(comprobante)+1 from movimiento m)
		);
		
		-- Verificar el saldo actual de la cuenta 
		select saldo_actual, codigo_cuenta from cuentas c where c.numero_cuenta = 5576; 

------------------------------------------------------------------------------------------------------------------------------------------
-- Demuestre el funcionamiento del trigger modificando, mediante SQL, el mismo depósito anterior a 10.000.000 (diez millones).
------------------------------------------------------------------------------------------------------------------------------------------
	
		-- Modificar el campo usando subselects 
		UPDATE movimiento m
		SET importe = 10000000
		WHERE codigo_movimiento = (select max(codigo_movimiento) from movimiento where codigo_cuenta = (select codigo_cuenta from cuentas c where c.numero_cuenta = 5576))

		-- Verificar el historial de transacciones de esa cuenta 
		select codigo_movimiento, importe from movimiento where codigo_cuenta = 10833 order by numero_movimiento desc 
	
		-- Verificar el saldo actual de la cuenta 
		select saldo_actual, codigo_cuenta from cuentas c where c.numero_cuenta = 5576;