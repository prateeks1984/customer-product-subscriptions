# Commercial data controls and runbook

| Control | Proposed owner | Evidence |
| --- | --- | --- |
| Customer and SKU mapping integrity | Product Data Steward | Missing keys, invalid product types, candidate batch |
| Subscription term integrity | Subscription Operations | Subscription ID, overlapping terms, dates and contract references |
| Hardware fulfillment integrity | Fulfillment Operations | Sale line ID, booked quantity, shipped serials |
| Commercial reconciliation | Finance Data Owner | Customer-level expected totals and summary differences |

Hold publication on any data control failure and retain the previous validated snapshot. A hardware line with open units or a renewal awaiting signature remains visible for business follow-up.

## Exercises

- **Overlapping software terms.** In a transaction, move T02 to June 25, 2025 through June 25, 2026. T01 and T02 overlap, so the overlap control should return SUB-01. Roll back.
- **Over-fulfillment.** In a transaction, add a fourth distinct serial to H01. The quantity control should report four recorded units against three ordered units. Roll back.
- **Cutoff replay.** In a fresh scratch run, set the as-of date to July 1 and keep the hardware period unchanged. T02 replaces T01. Northstar has 80 active seats, $11,400 annual software sales, $7,500 annual software cost, and the same $7,700 booked hardware sales.
