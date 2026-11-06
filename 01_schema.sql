CREATE TABLE customer (
    customer_id VARCHAR NOT NULL PRIMARY KEY,
    customer_name VARCHAR NOT NULL
);

CREATE TABLE product (
    sku VARCHAR NOT NULL PRIMARY KEY,
    product_name VARCHAR NOT NULL,
    product_type VARCHAR NOT NULL
);

CREATE TABLE subscription (
    subscription_id VARCHAR NOT NULL PRIMARY KEY,
    customer_id VARCHAR NOT NULL REFERENCES customer(customer_id),
    sku VARCHAR NOT NULL REFERENCES product(sku)
);

-- Each row freezes the negotiated annual economics for a full term.
CREATE TABLE subscription_term (
    term_id VARCHAR NOT NULL PRIMARY KEY,
    subscription_id VARCHAR NOT NULL REFERENCES subscription(subscription_id),
    starts_on DATE NOT NULL,
    ends_on DATE NOT NULL,
    signed_on DATE NOT NULL,
    seats INTEGER NOT NULL,
    annual_price_per_seat_cents NUMBER(18, 0) NOT NULL,
    annual_cost_per_seat_cents NUMBER(18, 0) NOT NULL
);

CREATE TABLE hardware_sale_line (
    sale_line_id VARCHAR NOT NULL PRIMARY KEY,
    customer_id VARCHAR NOT NULL REFERENCES customer(customer_id),
    sku VARCHAR NOT NULL REFERENCES product(sku),
    sold_on DATE NOT NULL,
    quantity INTEGER NOT NULL,
    unit_price_cents NUMBER(18, 0) NOT NULL,
    unit_cost_cents NUMBER(18, 0) NOT NULL
);

CREATE TABLE hardware_asset (
    asset_id VARCHAR NOT NULL PRIMARY KEY,
    serial_number VARCHAR NOT NULL UNIQUE,
    sale_line_id VARCHAR NOT NULL REFERENCES hardware_sale_line(sale_line_id),
    shipped_on DATE NOT NULL
);
