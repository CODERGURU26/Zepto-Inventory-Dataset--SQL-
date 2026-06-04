-- Exploratory Data Analysis 

-- Phase 1: Dataset Overview

-- Total Records => 3725
SELECT COUNT(*) AS total_records
FROM zepto_cleaned_rd ;

-- Total Categories => 14
SELECT COUNT(DISTINCT Category) AS total_category 
FROM zepto_cleaned_rd ;

SELECT DISTINCT Category AS list_of_categories
FROM zepto_cleaned_rd;

-- Products Per Category 
SELECT Category , COUNT(*) AS Product_count
FROM zepto_cleaned_rd
GROUP BY Category
ORDER BY Product_count DESC;

-- Phase 2 : Price Analysis 

-- Average Selling Price => 142.09
SELECT ROUND(AVG(discountedSellingPrice_rupees) , 2) AS avg_product_price 
FROM zepto_cleaned_rd;

-- Maximum Price => 1399
SELECT ROUND(MAX(discountedSellingPrice_rupees) , 2) AS max_price
FROM zepto_cleaned_rd;

-- Minimum Price => 9
SELECT ROUND(MIN(discountedSellingPrice_rupees) , 2) AS min_price
FROM zepto_cleaned_rd;

-- Cheapest Products
SELECT name , ROUND(discountedSellingPrice_rupees , 2) AS price 
FROM zepto_cleaned_rd
ORDER BY price
LIMIT 10; 

-- Most Expensive Products 
SELECT name , ROUND(discountedSellingPrice_rupees , 2) AS price 
FROM zepto_cleaned_rd
ORDER BY price DESC
LIMIT 10; 

-- Price Distribution
SELECT 
	CASE 
    WHEN discountedSellingPrice_rupees < 50 THEN 'Under  ₹50'
    WHEN discountedSellingPrice_rupees > 50  AND discountedSellingPrice_rupees < 100 THEN 'Between  ₹50 -  ₹100'
    WHEN discountedSellingPrice_rupees > 100 AND discountedSellingPrice_rupees < 500 THEN 'Between  ₹100 -  ₹500'
	WHEN discountedSellingPrice_rupees > 500 AND discountedSellingPrice_rupees < 1000 THEN 'Between  ₹500 -  ₹1000'
    ELSE 'Above  ₹1000'
END AS price_range,
COUNT(*) AS products
FROM zepto_cleaned_rd
GROUP BY price_range
ORDER BY products DESC;

-- Phase 3: Discount Analysis

-- Average Discount => 7.62 %
SELECT ROUND(AVG(discountPercent) , 2) AS avg_discount
FROM zepto_cleaned_rd;

-- Maximum Discount => 51 % 
SELECT ROUND(MAX(discountPercent) , 2) AS max_discount
FROM zepto_cleaned_rd;

-- Minimum Discount => 0 %
SELECT ROUND(MIN(discountPercent) , 2) AS min_discount
FROM zepto_cleaned_rd;

-- Highest Discounted Products 
SELECT name  AS productName, discountPercent 
FROM zepto_cleaned_rd
ORDER BY diScountPercent DESC
LIMIT 10;

-- Lowest Discounted Products
SELECT name  AS productName, discountPercent 
FROM zepto_cleaned_rd
ORDER BY diScountPercent 
LIMIT 10;

-- Category-Wise Discounts
SELECT Category , ROUND(AVG(discountPercent) , 2) AS avg_discount
FROM zepto_cleaned_rd
GROUP BY Category
ORDER BY avg_discount DESC;

-- Phase 4: Inventory Analysis

-- Stock Status
SELECT outOfStock , COUNT(*) AS products
FROM zepto_cleaned_rd
GROUP BY outOfStock;

-- Out-of-Stock Percentage
SELECT
ROUND(
100.0 * SUM(CASE WHEN outOfStock = 'TRUE' THEN 1 ELSE 0 END)
/ COUNT(*)
,2) AS stockout_percentage
FROM zepto_cleaned_rd;

-- Category with highest stockouts
SELECT Category , COUNT(*) AS stockout_count
FROM zepto_cleaned_rd
WHERE outOfStock = 'TRUE'
GROUP BY Category 
ORDER BY stockout_count DESC;

-- PHASE 5 : Inventory values

-- Inventory Values Per Product
SELECT name , ROUND((discountedSellingPrice_rupees * availableQuantity) , 2 ) AS inventory_value
FROM zepto_cleaned_rd 
ORDER BY inventory_value DESC
LIMIT 20;

-- Inventory Value By Category
SELECT Category , ROUND(SUM(discountedSellingPrice_rupees * availableQuantity) , 2 ) AS inventory_value
FROM zepto_cleaned_rd 
GROUP BY Category
ORDER BY inventory_value DESC;