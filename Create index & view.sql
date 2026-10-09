-- INDEXES
-- ------------------------------------------------------------
CREATE INDEX idx_orders_customer   ON orders(customer_id);
CREATE INDEX idx_orders_date       ON orders(order_date);
CREATE INDEX idx_items_order       ON order_items(order_id);
CREATE INDEX idx_products_category ON products(category);

-- ------------------------------------------------------------
-- VIEW: order-level summary (joins all 4 tables)
-- ------------------------------------------------------------
CREATE VIEW vw_order_summary AS
SELECT
    o.order_id,
    c.customer_id,
    c.name          AS customer_name,
    o.order_date,
    o.status,
    SUM(oi.quantity * oi.unit_price) AS order_total
FROM orders o
JOIN customers c   ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id, c.customer_id, c.name, o.order_date, o.status;