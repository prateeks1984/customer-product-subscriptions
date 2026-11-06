CREATE VIEW v_run AS
SELECT DATE '2025-06-30' AS as_of_on,
       DATE '2025-06-30' AS hardware_sales_through,
       DATE '2025-01-01' AS hardware_sales_from,
       DATE '2025-09-29' AS renewal_before;

CREATE VIEW v_signed_terms AS
SELECT t.*, s.customer_id, s.sku,
       t.seats * t.annual_price_per_seat_cents AS annual_sales_cents,
       t.seats * t.annual_cost_per_seat_cents AS annual_cost_cents
FROM subscription_term AS t
JOIN subscription AS s ON s.subscription_id = t.subscription_id
CROSS JOIN v_run AS r
WHERE t.signed_on <= r.as_of_on;

CREATE VIEW v_active_subscriptions AS
SELECT t.*, t.annual_sales_cents - t.annual_cost_cents AS annual_margin_cents
FROM v_signed_terms AS t CROSS JOIN v_run AS r
WHERE t.starts_on <= r.as_of_on AND r.as_of_on < t.ends_on;

CREATE VIEW v_renewal_pipeline AS
SELECT t.customer_id, t.sku, t.subscription_id, t.term_id, t.ends_on AS renewal_on,
       t.annual_sales_cents AS current_annual_sales_cents,
       t.annual_cost_cents AS current_annual_cost_cents,
       n.term_id AS signed_successor_term_id,
       n.annual_sales_cents AS renewal_annual_sales_cents,
       n.annual_cost_cents AS renewal_annual_cost_cents,
       n.annual_sales_cents - t.annual_sales_cents AS signed_sales_change_cents,
       (n.annual_sales_cents - n.annual_cost_cents) - t.annual_margin_cents AS signed_margin_change_cents,
       CASE WHEN n.term_id IS NULL THEN 'NO_SIGNED_SUCCESSOR'
            ELSE 'SIGNED_SUCCESSOR' END AS renewal_status
FROM v_active_subscriptions AS t CROSS JOIN v_run AS r
LEFT JOIN v_signed_terms AS n ON n.subscription_id = t.subscription_id AND n.starts_on = t.ends_on
WHERE t.ends_on < r.renewal_before;

CREATE VIEW v_hardware_asset_mapping AS
SELECT a.asset_id, a.serial_number, h.customer_id, h.sku, h.sale_line_id, a.shipped_on
FROM hardware_asset AS a JOIN hardware_sale_line AS h ON h.sale_line_id = a.sale_line_id
CROSS JOIN v_run AS r
WHERE h.sold_on <= r.as_of_on AND a.shipped_on <= r.as_of_on;

CREATE VIEW v_hardware_sales AS
WITH shipped AS (
    SELECT sale_line_id, COUNT(*) AS shipped_quantity
    FROM v_hardware_asset_mapping GROUP BY sale_line_id
)
SELECT h.*, COALESCE(s.shipped_quantity, 0) AS shipped_quantity,
       h.quantity - COALESCE(s.shipped_quantity, 0) AS unshipped_quantity,
       h.quantity * h.unit_price_cents AS booked_sales_cents,
       h.quantity * h.unit_cost_cents AS booked_cost_cents
FROM hardware_sale_line AS h CROSS JOIN v_run AS r
LEFT JOIN shipped AS s ON s.sale_line_id = h.sale_line_id
WHERE h.sold_on >= r.hardware_sales_from AND h.sold_on <= r.hardware_sales_through
  AND h.sold_on <= r.as_of_on;

-- Keep nonapplicable measures null and aggregate at customer/SKU before reporting.
CREATE VIEW v_customer_product_mapping AS
WITH footprint AS (
    SELECT customer_id, sku, SUM(seats) AS active_software_seats,
           SUM(annual_sales_cents) AS software_annual_sales_cents,
           SUM(annual_cost_cents) AS software_annual_cost_cents,
           NULL AS hardware_booked_units, NULL AS hardware_shipped_units,
           NULL AS hardware_booked_sales_cents, NULL AS hardware_booked_cost_cents
    FROM v_active_subscriptions GROUP BY customer_id, sku
    UNION ALL
    SELECT customer_id, sku, NULL, NULL, NULL, SUM(quantity), SUM(shipped_quantity),
           SUM(booked_sales_cents), SUM(booked_cost_cents)
    FROM v_hardware_sales GROUP BY customer_id, sku
)
SELECT f.*, p.product_name, p.product_type
FROM footprint AS f JOIN product AS p ON p.sku = f.sku;

CREATE VIEW v_customer_commercial_summary AS
SELECT c.customer_id, c.customer_name,
       COALESCE(SUM(m.active_software_seats), 0) AS active_software_seats,
       COALESCE(SUM(m.software_annual_sales_cents), 0) AS software_annual_sales_cents,
       COALESCE(SUM(m.software_annual_cost_cents), 0) AS software_annual_cost_cents,
       COALESCE(SUM(m.software_annual_sales_cents - m.software_annual_cost_cents), 0) AS software_annual_margin_cents,
       COALESCE(SUM(m.hardware_booked_sales_cents), 0) AS hardware_booked_sales_cents,
       COALESCE(SUM(m.hardware_booked_cost_cents), 0) AS hardware_booked_cost_cents,
       COALESCE(SUM(m.hardware_booked_sales_cents - m.hardware_booked_cost_cents), 0) AS hardware_booked_margin_cents
FROM customer AS c LEFT JOIN v_customer_product_mapping AS m ON m.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name;
