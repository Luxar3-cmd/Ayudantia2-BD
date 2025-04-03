-- Active: 1742559472605@@127.0.0.1@5432@supermercado
-- Listar las ventas de la surcursal A ordenadas por fecha y hora.
SELECT boleta.ID_boleta, boleta.fecha, boleta.hora, producto.linea_producto, venta.precio_unitario, venta.cantidad, venta.total
FROM boleta
JOIN venta ON boleta.ID_boleta = venta.ID_boleta
JOIN producto ON venta.ID_producto = producto.ID_producto
JOIN sucursal ON boleta.ID_sucursal = sucursal.ID_sucursal
WHERE tipo = 'A'
ORDER BY boleta.fecha, boleta.hora;


-- Total de ventas agrupadas por sucursal y ciudad.
SELECT sucursal.tipo, sucursal.ciudad, SUM(venta.total) AS total_ventas
FROM venta
JOIN boleta ON venta.ID_boleta = boleta.ID_boleta 
JOIN sucursal ON boleta.ID_sucursal = sucursal.ID_sucursal
GROUP BY sucursal.tipo, sucursal.ciudad
ORDER BY sucursal.tipo, sucursal.ciudad;

-- Promedio del precio unitario y de la calificación por linea de producto
SELECT producto.linea_producto, ROUND(AVG(venta.precio_unitario),2) AS promedio_precio_unitario, ROUND(AVG(boleta.calificacion),2) AS promedio_calificacion
FROM venta
JOIN boleta ON venta.ID_boleta = boleta.ID_boleta
JOIN producto ON venta.ID_producto = producto.ID_producto
GROUP BY producto.linea_producto
ORDER BY producto.linea_producto;

-- Conteo de ventas y total de impuestos por tipo de pago
SELECT boleta.tipo_pago, COUNT(venta.ID_boleta) AS total_ventas, SUM(venta.impuesto) AS total_impuesto
FROM venta
JOIN boleta ON venta.ID_boleta = boleta.ID_boleta
GROUP BY boleta.tipo_pago
ORDER BY boleta.tipo_pago;

-- Ventas realizadas en el mes de enro de 2019
SELECT boleta.ID_boleta, boleta.fecha, boleta.hora, producto.linea_producto, venta.precio_unitario, venta.cantidad, venta.total
FROM boleta
JOIN venta ON boleta.ID_boleta = venta.ID_boleta
JOIN producto ON venta.ID_producto = producto.ID_producto
WHERE boleta.fecha >= '2019-01-01' AND boleta.fecha <= '2019-01-31'
ORDER BY boleta.fecha, boleta.hora;

-- Promedio de cantidad vendida por linea de producto
SELECT producto.linea_producto, ROUND(AVG(venta.cantidad),2) AS promedio_cantidad
FROM venta
JOIN producto ON venta.ID_producto = producto.ID_producto
GROUP BY producto.linea_producto
ORDER BY producto.linea_producto;

-- Determinar el día con mayor total de ventas 

SELECT boleta.fecha, SUM(venta.total) AS total_ventas
FROM boleta
JOIN venta ON boleta.ID_boleta = venta.ID_boleta
GROUP BY boleta.fecha
ORDER BY total_ventas DESC
LIMIT 1;
-- Determinar el día con menor total de ventas
SELECT boleta.fecha, SUM(venta.total) AS total_ventas
FROM boleta
JOIN venta ON boleta.ID_boleta = venta.ID_boleta
GROUP BY boleta.fecha
ORDER BY total_ventas ASC
LIMIT 1;

-- Ventas totales por genero
SELECT cliente.genero, SUM(venta.total) AS total_ventas
FROM venta
JOIN boleta ON venta.ID_boleta = boleta.ID_boleta
JOIN cliente ON boleta.ID_cliente = cliente.ID_cliente
GROUP BY cliente.genero
ORDER BY cliente.genero;

