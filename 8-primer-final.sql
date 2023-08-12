-- ¿Quiénes son los transportistas que poseen más de 100 unidades de transporte a su cargo?
select tr.ruc, tr.nombre, count(un.*) as unidades
from buses_unidades un
join buses_transportistas tr on tr.ruc = un.ruc 
group by tr.ruc, tr.nombre 
having count(un.*) > 100
order by unidades desc;

-- Por cada uno de los 14 departamentos del país, obtener la cantidad de unidades con servicio interdepartamental y clasificados 0 según el tipo de vehículo. 
select de.codigo_departamento as nro, de.departamento, vb.tipo, count(re.*) as cantidad 
from buses_recorrido re 
join buses_departamentos de on de.codigo_departamento = re.codigo_departamento 
join buses_unidades_recorrido unr on unr.codigo_recorrido = re.codigo_recorrido 
join vbuses vb on unr.chapa = vb.chapa
where re.codigo_servicio = (select codigo_tipo_servicio from buses_tipo_servicio bts where servicio = 'INTERDEPARTAMENTAL')
group by de.codigo_departamento, de.departamento, vb.tipo
order by nro 

-- Ranking de los 10 transportistas, que son personas naturales, con la mayor cantidad de unidades de transporte a cargo. Especifique cuántos de esos vehículos tienen 10 o más años de antigüedad.
-- 10 transportistas naturales con mas buses a cargo 
select tr.ruc, concat(tr.apellidopaterno, ' ', tr.apellidomaterno, ', ', tr.nombre) as nombre_completo, 
count(un.*) as unidades, 
from buses_unidades un
join buses_transportistas tr on tr.ruc = un.ruc 
where not tr.persona_juridica 
group by tr.ruc, tr.nombre, tr.apellidopaterno, tr.apellidomaterno 
order by unidades desc 
limit 10;

-- Calcular la antiguedad de los buses de un determinado transportista // 0203-260404-101-1 
select (2023 - bu.modelo) as antiguedad
from buses_unidades bu 
join buses_transportistas tr on bu.ruc = tr.ruc 
where tr.ruc = '0203-260404-101-1'
order by antiguedad desc 

-- Calcular la cantidad de buses que superan los 10 anhos de un determinado transportista 
select count(*) as cantidad_buses
from buses_unidades bu
join buses_transportistas tr on bu.ruc = tr.ruc
where tr.ruc = '0203-260404-101-1' and (2023 - bu.modelo) > 10;

-- Crear la funcion que retorne la cantidad de buses que superen los 10 anhos 
CREATE OR REPLACE FUNCTION fn_buses_chatarra (ruc_transportista VARCHAR(50)) 
RETURNS INTEGER AS $$
DECLARE
    cantidad_buses INTEGER;
BEGIN
    SELECT COUNT(*) INTO cantidad_buses
    FROM buses_unidades bu
    JOIN buses_transportistas tr ON bu.ruc = tr.ruc
    WHERE tr.ruc = ruc_transportista AND (2023 - bu.modelo) >= 10;
    
    RETURN cantidad_buses;
END;
$$ LANGUAGE plpgsql;

-- Usar la funcion en la consulta anterior jeje 
select tr.ruc, concat(tr.apellidopaterno, ' ', tr.apellidomaterno, ', ', tr.nombre) as nombre_completo, 
count(un.*) as unidades, (select fn_buses_chatarra(tr.ruc) as buses_chatarra)
from buses_unidades un
join buses_transportistas tr on tr.ruc = un.ruc 
where not tr.persona_juridica 
group by tr.ruc, tr.nombre, tr.apellidopaterno, tr.apellidomaterno 
order by unidades desc 
limit 10 

-- Calcular el porcentaje 
select tr.ruc, concat(tr.apellidopaterno, ' ', tr.apellidomaterno, ', ', tr.nombre) as nombre_completo, 
count(un.*) as unidades, (select fn_buses_chatarra(tr.ruc) as buses_chatarra), 
round((select fn_buses_chatarra(tr.ruc)) * 100 / count(un.*) , 2) as porcentaje 
from buses_unidades un
join buses_transportistas tr on tr.ruc = un.ruc 
where not tr.persona_juridica 
group by tr.ruc, tr.nombre, tr.apellidopaterno, tr.apellidomaterno 
order by unidades desc 
limit 10 






