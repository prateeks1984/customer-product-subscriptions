-- Every query must return zero rows before publishing.
WITH key_counts AS (
    SELECT 'CUSTOMER' AS object_name, customer_id AS id, COUNT(*) AS copies FROM customer GROUP BY customer_id
    UNION ALL
    SELECT 'PRODUCT', sku, COUNT(*) FROM product GROUP BY sku
    UNION ALL
    SELECT 'SUBSCRIPTION', subscription_id, COUNT(*) FROM subscription GROUP BY subscription_id
    UNION ALL
    SELECT 'TERM', term_id, COUNT(*) FROM subscription_term GROUP BY term_id
    UNION ALL
    SELECT 'SALE_LINE', sale_line_id, COUNT(*) FROM hardware_sale_line GROUP BY sale_line_id
    UNION ALL
    SELECT 'ASSET', asset_id, COUNT(*) FROM hardware_asset GROUP BY asset_id
    UNION ALL
    SELECT 'SERIAL', serial_number, COUNT(*) FROM hardware_asset GROUP BY serial_number
)
SELECT * FROM key_counts WHERE copies > 1;

SELECT sku FROM product WHERE product_type NOT IN ('SOFTWARE', 'HARDWARE');

SELECT s.subscription_id
FROM subscription AS s
LEFT JOIN customer AS c ON c.customer_id = s.customer_id
LEFT JOIN product AS p ON p.sku = s.sku
WHERE c.customer_id IS NULL OR p.sku IS NULL OR p.product_type <> 'SOFTWARE';

SELECT t.term_id
FROM subscription_term AS t
LEFT JOIN subscription AS s ON s.subscription_id = t.subscription_id
WHERE s.subscription_id IS NULL OR t.signed_on > t.starts_on
   OR t.ends_on <> DATEADD(year, 1, t.starts_on)
   OR t.seats <= 0 OR t.annual_price_per_seat_cents < 0 OR t.annual_cost_per_seat_cents < 0;

SELECT a.subscription_id, a.term_id, b.term_id AS overlapping_term_id
FROM subscription_term AS a
JOIN subscription_term AS b
  ON a.subscription_id = b.subscription_id AND a.term_id < b.term_id
 AND a.starts_on < b.ends_on AND b.starts_on < a.ends_on;

SELECT h.sale_line_id
FROM hardware_sale_line AS h
LEFT JOIN customer AS c ON c.customer_id = h.customer_id
LEFT JOIN product AS p ON p.sku = h.sku
WHERE c.customer_id IS NULL OR p.sku IS NULL OR p.product_type <> 'HARDWARE'
   OR h.quantity <= 0 OR h.unit_price_cents < 0 OR h.unit_cost_cents < 0;

SELECT a.asset_id
FROM hardware_asset AS a LEFT JOIN hardware_sale_line AS h ON h.sale_line_id = a.sale_line_id
WHERE h.sale_line_id IS NULL OR a.shipped_on < h.sold_on;

SELECT h.sale_line_id, h.quantity, COUNT(a.asset_id) AS recorded_units
FROM hardware_sale_line AS h JOIN hardware_asset AS a ON a.sale_line_id = h.sale_line_id
GROUP BY h.sale_line_id, h.quantity
HAVING COUNT(a.asset_id) > h.quantity;

SELECT customer_id, sku, COUNT(*) AS mapping_rows
FROM v_customer_product_mapping
GROUP BY customer_id, sku
HAVING COUNT(*) <> 1;

-- Reconcile the commercial summary back to the underlying facts.
WITH expected AS (
    SELECT customer_id, annual_sales_cents AS software_sales, annual_cost_cents AS software_cost,
           0 AS hardware_sales, 0 AS hardware_cost
    FROM v_active_subscriptions
    UNION ALL
    SELECT customer_id, 0, 0, booked_sales_cents, booked_cost_cents
    FROM v_hardware_sales
),
totals AS (
    SELECT customer_id, SUM(software_sales) AS software_sales, SUM(software_cost) AS software_cost,
           SUM(hardware_sales) AS hardware_sales, SUM(hardware_cost) AS hardware_cost
    FROM expected GROUP BY customer_id
)
SELECT t.customer_id
FROM totals AS t LEFT JOIN v_customer_commercial_summary AS s ON s.customer_id = t.customer_id
WHERE s.customer_id IS NULL OR t.software_sales <> s.software_annual_sales_cents
   OR t.software_cost <> s.software_annual_cost_cents
   OR t.hardware_sales <> s.hardware_booked_sales_cents
   OR t.hardware_cost <> s.hardware_booked_cost_cents;
