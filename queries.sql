-- Consultas analíticas del shop

-- 1) Top productos por ingresos
SELECT p.sku, p.name,
       SUM(oi.qty * oi.unit_price_cents) AS revenue_cents,
       SUM(oi.qty) AS units
FROM order_items oi
JOIN products p ON p.id = oi.product_id
JOIN orders o ON o.id = oi.order_id
WHERE o.status <> 'cancelled'
GROUP BY p.sku, p.name
ORDER BY revenue_cents DESC;

-- 2) Ticket promedio por cliente
SELECT c.full_name, c.email,
       COUNT(o.id) AS orders_count,
       ROUND(AVG(o.total_cents)::numeric, 0) AS avg_ticket_cents
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.id
GROUP BY c.id
ORDER BY avg_ticket_cents DESC NULLS LAST;

-- 3) Stock bajo (< 10) en categorías activas
SELECT c.name AS category, p.sku, p.name, p.stock
FROM products p
JOIN categories c ON c.id = p.category_id
WHERE p.is_active AND p.stock < 10
ORDER BY p.stock ASC;

-- 4) Órdenes con detalle (JSON-friendly)
SELECT o.id, o.status, o.placed_at, c.email,
       json_agg(json_build_object(
         'sku', p.sku,
         'qty', oi.qty,
         'unit_price_cents', oi.unit_price_cents
       )) AS items
FROM orders o
JOIN customers c ON c.id = o.customer_id
JOIN order_items oi ON oi.order_id = o.id
JOIN products p ON p.id = oi.product_id
GROUP BY o.id, c.email
ORDER BY o.placed_at DESC;

-- 5) Vista materializada candidata: ventas diarias
-- CREATE MATERIALIZED VIEW mv_daily_sales AS
SELECT DATE(placed_at) AS day,
       COUNT(*) AS orders,
       SUM(total_cents) AS revenue_cents
FROM orders
WHERE status IN ('paid', 'shipped')
GROUP BY 1
ORDER BY 1 DESC;
