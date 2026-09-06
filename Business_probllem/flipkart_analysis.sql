--Creating Staging Table
CREATE TABLE staging_flipkart (
    product_id TEXT,
    product_name TEXT,
    category TEXT,
    brand TEXT,
    seller TEXT,
    seller_city TEXT,
    price NUMERIC,
    discount_percent NUMERIC,
    final_price NUMERIC,
    rating NUMERIC,
    review_count INTEGER,
    stock_available INTEGER,
    units_sold INTEGER,
    listing_date DATE,
    delivery_days INTEGER,
    weight_g NUMERIC,
    warranty_months INTEGER,
    color TEXT,
    size TEXT,
    return_policy_days INTEGER,
    is_returnable TEXT,
    payment_modes TEXT,
    shipping_weight_g NUMERIC,
    product_score NUMERIC,
    seller_rating NUMERIC
);

--Check Data
--1. Check data are properly insert or not
SELECT * 
from staging_flipkart
LIMIT 20;

SELECT COUNT(*)
FROM staging_flipkart;

-- 2. Any missing/null product_id? (red flag if yes)
SELECT COUNT(*) FROM staging_flipkart WHERE product_id IS NULL;

-- 3. Check value ranges - do numbers look sensible?
SELECT 
    MIN(price), MAX(price), 
    MIN(rating), MAX(rating),
    MIN(discount_percent), MAX(discount_percent)
FROM staging_flipkart;

-- 4. Any duplicate product_ids?
SELECT product_id, COUNT(*) 
FROM staging_flipkart 
GROUP BY product_id 
HAVING COUNT(*) > 1;

-- 5. Quick peek at actual data
SELECT * FROM staging_flipkart LIMIT 10;

-- Product dimension: one row per unique product
CREATE TABLE dim_products (
    product_id TEXT PRIMARY KEY,
    product_name TEXT,
    category TEXT,
    brand TEXT,
    color TEXT,
    size TEXT,
    weight_g NUMERIC,
    warranty_months INTEGER
);

-- Seller dimension: one row per unique seller
CREATE TABLE dim_sellers (
    seller_id SERIAL PRIMARY KEY,
    seller_name TEXT UNIQUE,
    seller_city TEXT,
    seller_rating NUMERIC
);

-- Sales fact: one row per product listing/sale event
CREATE TABLE fact_sales (
    sale_id SERIAL PRIMARY KEY,
    product_id TEXT REFERENCES dim_products(product_id),
    seller_id INTEGER REFERENCES dim_sellers(seller_id),
    price NUMERIC,
    discount_percent NUMERIC,
    final_price NUMERIC,
    rating NUMERIC,
    review_count INTEGER,
    stock_available INTEGER,
    units_sold INTEGER,
    listing_date DATE,
    delivery_days INTEGER,
    return_policy_days INTEGER,
    is_returnable TEXT,
    payment_modes TEXT,
    shipping_weight_g NUMERIC,
    product_score NUMERIC
);

SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';

-- Insert data into dim_products table
INSERT INTO dim_products (product_id, product_name, category, brand, color, size, weight_g, warranty_months)
SELECT DISTINCT ON (product_id)
    product_id,
    product_name,
    category,
    brand,
    color,
    size,
    weight_g,
    warranty_months
FROM staging_flipkart
WHERE product_id IS NOT NULL
ORDER BY product_id;

--Business Question
--1. Revenue distribution across categories
SELECT 
    p.category,
    ROUND(SUM(fs.final_price * fs.units_sold) / 10000000, 2) AS Total_revenue_crores,
    SUM(fs.units_sold) AS total_units_sold
FROM fact_sales fs
JOIN dim_products p ON fs.product_id = p.product_id
GROUP BY p.category
ORDER BY Total_revenue_crores DESC;

--2.Seller performance (revenue & rating)
SELECT
    ds.seller_id,
    ds.seller_name,
    ROUND(SUM(fs.final_price * fs.units_sold) / 10000000, 2) AS Total_revenue_crores,
    ROUND(AVG(fs.rating), 2) AS Average_rating
FROM fact_sales fs
JOIN dim_sellers ds
    ON ds.seller_id = fs.seller_id
GROUP BY ds.seller_id, ds.seller_name
ORDER BY Total_revenue_crores DESC;

--3.Discount impact on units sold and rating
SELECT 
    CASE 
        WHEN discount_percent = 0 THEN '0% - No discount'
        WHEN discount_percent BETWEEN 1 AND 15 THEN '1-15%'
        WHEN discount_percent BETWEEN 16 AND 30 THEN '16-30%'
        ELSE '30%+'
    END AS discount_band,
    SUM(units_sold) AS total_units_sold,
    ROUND(AVG(rating), 2) AS avg_rating,
    COUNT(*) AS num_products
FROM fact_sales
GROUP BY discount_band
ORDER BY discount_band;

--4. Delivery speed vs customer rating
SELECT
    CASE
        WHEN delivery_days BETWEEN 1 AND 3 THEN '1-3 Days'
        WHEN delivery_days BETWEEN 4 AND 7 THEN '4-7 Days'
        WHEN delivery_days BETWEEN 8 AND 11 THEN '8-11 Days'
        ELSE '15+ Days'
    END AS delivery_band,
    MAX(delivery_days) AS Slowest_delivery,
    MIN(delivery_days) AS Fast_delivery,
    ROUND(AVG(rating), 2) AS Average_Rating,
    COUNT(*) AS num_delivery_days
FROM fact_sales
GROUP BY 
    CASE
        WHEN delivery_days BETWEEN 1 AND 3 THEN '1-3 Days'
        WHEN delivery_days BETWEEN 4 AND 7 THEN '4-7 Days'
        WHEN delivery_days BETWEEN 8 AND 11 THEN '8-11 Days'
        ELSE '15+ Days'
    END
ORDER BY delivery_band;

--5. Return policy consistency across categories
SELECT
    p.category,
    ROUND(AVG(fs.return_policy_days), 1) AS avg_return_window,
    ROUND(AVG(fs.rating), 2) AS avg_rating,
    COUNT(*) AS num_products
FROM fact_sales fs
JOIN dim_products p
    ON p.product_id = fs.product_id
GROUP BY p.category
ORDER BY avg_rating ASC;

--6.City-wise seller performance
SELECT 
    ds.seller_city,
    COUNT(DISTINCT ds.seller_id) AS num_sellers,
    ROUND(AVG(fs.rating), 2) AS average_rating,
    ROUND(SUM(fs.final_price * fs.units_sold) / 10000000, 2) AS total_revenue_crores,
    SUM(fs.units_sold) AS total_units_sold
FROM dim_sellers ds
JOIN fact_sales fs
    ON fs.seller_id = ds.seller_id
GROUP BY ds.seller_city
ORDER BY total_revenue_crores DESC;