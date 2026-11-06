# Architecture decisions

## 1. Keep the customer relationship separate from annual terms

A subscription links one customer to one software SKU. Each annual term freezes the agreed seats, customer price, and reseller cost. Start dates are inclusive and end dates exclusive. A signed successor counts in the renewal pipeline before it starts, then replaces the previous term at the boundary. A successor must begin on the current end date to qualify as a contiguous renewal. A gap represents a break in coverage.

The model handles complete annual terms at per-seat pricing. It excludes co-terms, mid-term amendments, usage tiers, refunds, and deferred revenue. Supporting those cases would require a different pricing or event grain and effective-dated commercial rules.

## 2. Separate hardware economics from serial tracking

A booked hardware line carries quantity, unit price, and unit cost. Each shipped serial inherits its customer and SKU through that line. Count serials before joining to booked values, so one three-unit order remains one line even when three serials are present.

The sample covers original shipments. Returns, replacements, and transfers would require asset movement history and a separate commercial adjustment design.

## 3. Preserve measurement basis in the customer view

The product mapping groups software and hardware separately by customer and SKU. Fields that do not apply to a product type stay null. The customer summary places annual software sales and costs alongside period hardware sales and costs in separate columns. Direct margin excludes overhead and tax. These are commercial measures and the project does not model invoices, collections, or accounting recognition.

The source fixtures are fixed. The as-of date filters signatures, active terms, sales, and shipments. Production reporting would version source corrections and customer or product changes, persist the selected period and source batches with the published snapshot, and restrict reseller cost and margin to approved roles.
