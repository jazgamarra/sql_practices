-- Verificar todas las transferencias 
select * from transferencias t 

-- obtenga el ranking de las 10 entidades que mayor monto han recibido como transferencia, durante el mes de enero del 2022. Debe incluir la cantidad de transferencias
select tr.mes, tr.anio, en.descripcionentidad, 
count(tr.codigotransferencia) as transferencias, 
sum(tr.montotransferido) as monto 
from transferencias tr
join entidades en on en.codigoentidad = tr.codigoentidad and en.codigonivel  = tr.codigonivel 
where tr.mes = 1 and tr.anio = 2022
group by tr.mes, tr.anio, en.descripcionentidad 
order by monto desc limit 10

-- Verificar cuales son gobernaciones 
select * from niveles -- 22 

-- Crear una funcion 
CREATE OR REPLACE FUNCTION TotalMes()
RETURNS TABLE (
    descripcionentidad varchar(255),
    monto_enero numeric,
    monto_mayo numeric
)
AS $$
BEGIN
    RETURN QUERY
    SELECT
        entidades.descripcionentidad,
        SUM(CASE WHEN mes = 1 THEN montotransferido ELSE 0 END) AS monto_enero,
        SUM(CASE WHEN mes = 5 THEN montotransferido ELSE 0 END) AS monto_mayo
    FROM
        transferencias
    JOIN
        entidades ON transferencias.codigonivel = entidades.codigonivel AND transferencias.codigoentidad = entidades.codigoentidad
    WHERE
        transferencias.codigonivel = 22
        AND anio = 2022
    GROUP BY
        entidades.descripcionentidad;

END;
$$ LANGUAGE plpgsql;

-- Llamar a la funcion 
select * from TotalMes() 

-- Visualice la distribución porcentual de las transferencias a cada banco y despliegue primero el banco que mayor porcentaje total ha recibido
select ba.banco, sum(tr.montotransferido) as total, 
round(sum(tr.montotransferido) / (select sum(montotransferido) from transferencias) * 100, 2) as porcentaje 
from transferencias tr 
join cuentasbancarias cu on cu.cuentadeposito = tr.cuentadeposito
join bancos ba on cu.bancodeposito = ba.bancodeposito 
group by ba.banco 
order by total desc