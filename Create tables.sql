-- SEQUENCE (used to generate order_id manually)
-- ------------------------------------------------------------
CREATE SEQUENCE order_id_seq START WITH 1001 INCREMENT BY 1;

-- ------------------------------------------------------------
-- TABLE: customers
-- ------------------------------------------------------------

CREATE TABLE customers (
    customer_id   INT PRIMARY KEY,
    name          VARCHAR(100) NOT NULL,
    email         VARCHAR(100) UNIQUE NOT NULL,
    city          VARCHAR(50),
    signup_date   DATE DEFAULT CURRENT_DATE,
    referred_by   INT REFERENCES customers(customer_id)  -- self-referencing FK
);

-- TABLE: products
-- ------------------------------------------------------------
CREATE TABLE products (
    product_id    INT PRIMARY KEY,
    product_name  VARCHAR(100) NOT NULL,
    category      VARCHAR(50) NOT NULL,
    price         DECIMAL(10,2) NOT NULL CHECK (price > 0)
);

-- TABLE: orders
-- ------------------------------------------------------------
CREATE TABLE orders (
    order_id      INT PRIMARY KEY DEFAULT nextval('order_id_seq'),
    customer_id   INT NOT NULL REFERENCES customers(customer_id),
    order_date    DATE DEFAULT CURRENT_DATE,
    status        VARCHAR(20) DEFAULT 'pending'
                  CHECK (status IN ('pending','shipped','delivered','cancelled'))
);

-- ------------------------------------------------------------

-- TABLE: order_items
-- ------------------------------------------------------------
CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id      INT NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id    INT NOT NULL REFERENCES products(product_id),
    quantity      INT NOT NULL CHECK (quantity > 0),
    unit_price    DECIMAL(10,2) NOT NULL CHECK (unit_price > 0),
    UNIQUE (order_id, product_id)
);
