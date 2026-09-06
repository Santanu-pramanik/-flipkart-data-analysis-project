# Flipkart E-Commerce Data Analysis — Findings Report

**Author:** Santanu Pramanik
**Project:** End-to-end data warehouse, SQL analysis, and Power BI dashboard on Flipkart retail data (~80,000 products)

---

## 1. Project Summary

This project analyzes Flipkart's product, seller, pricing, and sales data to answer key
business questions about revenue distribution, seller performance, discount effectiveness,
delivery experience, and return policy consistency. Raw data was loaded into a PostgreSQL
data warehouse using a star schema, cleaned and modeled in SQL, then visualized in an
interactive Power BI dashboard.

**Tech Stack:** Python (pandas, SQLAlchemy) · PostgreSQL · SQL · Power BI (DAX)

**Architecture:**
Raw CSV → Staging Table (`staging_flipkart`) → Star Schema (`dim_products`, `dim_sellers`,
`fact_sales`) → Power BI Dashboard

---

## 2. Key Findings

### Finding 1 — Revenue is evenly distributed across categories
All 8 product categories (Beauty, Fashion, Electronics, Appliances, Sports, Mobiles,
Home & Kitchen, Toys) generate remarkably similar revenue, each within ~4% of the others
(~₹580,000–₹605,000 Cr). No single category dominates the business.

**Implication:** Flipkart is not over-reliant on any one category — a healthier, more
diversified revenue base than a business concentrated in a single vertical.

### Finding 2 — Seller performance is balanced across the marketplace
Across all 8 sellers, both total revenue (~₹58,800–₹60,400 Cr) and average customer rating
(~2.99–3.01) are nearly identical. No seller is dramatically outperforming others, and no
high-volume seller is sacrificing customer satisfaction for sales.

**Implication:** The seller ecosystem is healthy and standardized, without dependency risk
on any single seller.

### Finding 3 — Discount percentage does not meaningfully drive sales or rating
Grouping products into discount bands (0%, 1–15%, 16–30%, 30%+), the average units sold
per product and average rating stay virtually constant across all bands (~2,500 units/product,
~3.0 rating).

**Implication:** Heavy discounting is not correlated with higher sales volume or better
customer satisfaction — Flipkart could potentially reduce discounting on certain products
without losing sales, improving profit margins.

### Finding 4 — Delivery speed has negligible impact on customer rating
Orders were grouped into delivery bands (1–3, 4–7, 8–11 days — no orders exceeded 11 days
in this dataset). Average rating held steady at 2.99–3.00 across all bands.

**Implication:** Customers are not penalizing slower deliveries within this range, suggesting
delivery expectations are already being met.

### Finding 5 — Return policy windows are consistent across categories
Average return policy windows are nearly identical across all categories (~12.3–12.5 days),
and this consistency correlates with stable ratings (2.97–3.02) — no category shows signs
of a return/quality problem.

### Finding 6 — City-level revenue differences are explained by seller count, not performance
Hyderabad generates the highest total revenue among seller cities, but this is because it
hosts more sellers (3) than Mumbai, Pune (2 each), or Bengaluru (1) — not because its sellers
perform better. Per-seller revenue is consistent across all cities (~₹58,000–60,000 Cr/seller).

---

## 3. Overall Conclusion

Across category, seller, discount, delivery, and return dimensions, Flipkart's marketplace
shows **remarkable operational consistency and balance** rather than obvious inefficiencies
or problem areas. This suggests a mature, well-optimized platform. The clearest actionable
opportunity is around **discount strategy** (Finding 3) — since heavier discounts don't
correlate with more sales, selectively reducing discounts on certain products is a
low-risk way to protect margins.

---

## 4. Dashboard

See `/screenshots/dashboard_final.png` for the full interactive Power BI dashboard,
featuring a category slicer, KPI card, and 4 insight-driven visuals.
