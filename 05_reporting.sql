-- Detailed customer-to-SKU records, with money in USD cents.
SELECT * FROM v_customer_product_mapping ORDER BY customer_id, sku;

SELECT customer_id, subscription_id, sku, term_id, starts_on, ends_on, seats,
       annual_sales_cents, annual_cost_cents, annual_margin_cents
FROM v_active_subscriptions
ORDER BY customer_id, subscription_id;

SELECT * FROM v_renewal_pipeline ORDER BY renewal_on, subscription_id;

SELECT customer_id, sku, sale_line_id, quantity, shipped_quantity, unshipped_quantity,
       booked_sales_cents, booked_cost_cents
FROM v_hardware_sales
ORDER BY customer_id, sale_line_id;

SELECT * FROM v_hardware_asset_mapping ORDER BY customer_id, sku, serial_number;

SELECT * FROM v_customer_commercial_summary ORDER BY customer_id;
