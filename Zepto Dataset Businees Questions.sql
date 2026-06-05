-- BUSINESS QUESTIONS -- 

-- Q1. How many products and categories are available on Zepto?
SELECT  COUNT(*) AS Totat_Products 
FROM zepto_cleaned_rd;

SELECT COUNT(DISTINCT Category) AS Total_Categories
FROM zepto_cleaned_rd;

-- Total Products = 3725
-- Total Categories = 14

-- Q2. Which categories have the highest number of products?
SELECT Category , COUNT(*) AS products
FROM zepto_cleaned_rd 
GROUP BY Category 
ORDER BY products DESC;

-- Cooking Essentials And Munchies Category Has The Highest Number Of Products => 512

-- Q.3. What is the average selling price across all products?
SELECT ROUND(AVG(discountedSellingPrice_rupees) , 2) AS avg_selling_price
FROM zepto_cleaned_rd;

-- the average selling price across all products is 142.09

-- Q.4. Which are the top 10 most expensive products?
SELECT name , Category , ROUND(discountedSellingPrice_rupees , 2) AS products_price 
FROM zepto_cleaned_rd
ORDER BY products_price DESC
LIMIT 10;


-- Q5. Which categories have the highest average selling price?
SELECT Category , ROUND(AVG(discountedSellingPrice_rupees) , 2) AS avg_selling_price
FROM zepto_cleaned_rd 
GROUP BY Category
ORDER BY avg_selling_price DESC;

-- Q6. What is the average discount offered by Zepto?
SELECT ROUND(AVG(discountPercent) , 2 ) AS avg_discount
FROM zepto_cleaned_rd;

-- Q.7. Which categories have the most out-of-stock products?
SELECT Category , COUNT(*) AS out_of_stock_products 
FROM zepto_cleaned_rd
WHERE outOfStock = 'TRUE'
GROUP BY Category 
ORDER BY out_of_stock_products DESC;

-- Q.8. What is the average listed price vs. discounted price across categories?
SELECT 
	Category ,
    ROUND(AVG(mrp_rupees) , 2) AS avg_listed_price,
    ROUND(AVG(discountedSellingPrice_rupees) ,2 ) AS avg_discounted_price
FROM zepto_cleaned_rd
GROUP BY Category;

-- Q.9. Which products are sold at full MRP with zero discount?
SELECT name , Category , mrp_rupees 
FROM zepto_cleaned_rd
WHERE discountPercent = 0 AND outOfStock = FALSE 
ORDER BY mrp_rupees DESC
LIMIT 10;

-- Q.10. How are products distributed across discount tiers (None, Low, Medium, High)?
SELECT 
	CASE
		WHEN discountPercent = 0 THEN 'No Discount'
		WHEN discountPercent BETWEEN 1 AND 10 THEN 'Low (1-10%)' 
		WHEN discountPercent BETWEEN 11 AND 25 THEN 'Medium (11-25%)'
		ELSE 'High (>25%)'
	END AS discount_tiers,
    COUNT(*) AS products 
FROM zepto_cleaned_rd
GROUP BY discount_tiers;

-- Q.11. Which products offer the highest absolute rupee savings for a customer?
SELECT 
	name ,
    Category,
    (mrp_rupees - discountedSellingPrice_rupees) AS saving_rs,
    discountPercent
FROM zepto_cleaned_rd
WHERE outOfStock = FALSE
ORDER BY saving_rs DESC
LIMIT 10;

-- Q.12  What percentage of each category's catalog is currently out of stock?
SELECT 
	Category , 
    COUNT(*) AS total,
    SUM(CASE WHEN outOfStock = 'TRUE' THEN 1 ELSE 0 END) AS out_of_stock_total,
    ROUND(100 * SUM( CASE WHEN outOfStock = 'TRUE' THEN 1 ELSE 0 END) / COUNT(*) , 1) AS out_of_stock_percent
FROM zepto_cleaned_rd
GROUP BY Category
ORDER BY out_of_stock_percent DESC;

-- Q.13. Which products give the best value for money per gram of product?
SELECT name , 
	Category , 
	discountedSellingPrice_rupees AS price_rs ,
    weightInGms,
    ROUND((discountedSellingPrice_rupees * 100) / weightInGms , 2) AS price_per_gm
FROM zepto_cleaned_rd 
WHERE weightInGms > 0  AND outOfStock = 'FALSE'
ORDER BY price_per_gm ASC
LIMIT 10 ;

-- Q.14. Which categories consistently offer heavy discounts (avg discount > 10%)?
SELECT Category , 
	ROUND(AVG(discountPercent) , 2) As avg_discount,
    COUNT(*) AS product
FROM zepto_cleaned_rd
GROUP BY Category
HAVING AVG(discountPercent) > 10 
ORDER BY avg_discount DESC;


-- Q.15. Which  are the best performing products from each category?
WITH performance AS (
  SELECT
    name,
    Category,
    availableQuantity,
    discountPercent,
    discountedSellingPrice_rupees AS price,
    ROUND(
      (availableQuantity * 0.6) + (discountPercent * 0.4), 2
    ) AS performance_score,
    DENSE_RANK() OVER (
      PARTITION BY Category
      ORDER BY (availableQuantity * 0.6 + discountPercent * 0.4) DESC
    ) AS perf_rank
  FROM zepto_cleaned_rd
  WHERE outOfStock = FALSE
)
SELECT *
FROM performance
WHERE perf_rank = 1
ORDER BY Category;

-- Q.16. What is the cumulative catalog value (MRP) as products are sorted by price?
SELECT name , Category , 
	mrp_rupees ,
    SUM(mrp_rupees) OVER (
					ORDER BY mrp_rupees DESC 
                    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
                    ) AS cumulative_mrp_rupees
	FROM zepto_cleaned_rd
    ORDER BY mrp_rupees DESC
    LIMIT 20;
    
-- Q.17. Do higher-priced products tend to get larger discounts? Analyse by price bucket.

WITH bucketed AS (
SELECT name , mrp_rupees  , discountPercent , 
		CASE
			WHEN mrp_rupees < 50 THEN 'Budget (<₹50)'
            WHEN mrp_rupees < 150 THEN 'Mid (₹50-150)'
            WHEN mrp_rupees < 500 THEN 'Premium (₹150-500)'
            ELSE  'Luxury (>₹500)'
		END AS price_bucket
FROM zepto_cleaned_rd
)
SELECT price_bucket ,
		COUNT(*) AS product_count,
        ROUND(AVG(discountPercent) , 2) AS avg_discount,
        MAX(discountPercent) AS max_discount
FROM bucketed
GROUP BY price_bucket
ORDER BY avg_discount DESC;        

-- Q.18. Build a one-row-per-category health dashboard covering price, discount, and availability.
WITH health AS (
 SELECT 
	Category , 
    COUNT(*) AS products,
    ROUND(AVG(discountedSellingPrice_rupees) , 2) AS avg_price,
    ROUND(AVG(discountPercent) , 2 ) AS avg_discount_percent,
    ROUND(100 * SUM(CASE WHEN outOfStock = 'TRUE' THEN 1 ELSE 0 END ) / COUNT(*) , 1 ) AS out_of_stock_percent,
    MAX(discountPercent) AS max_dicount_percent
FROM zepto_cleaned_rd
GROUP BY Category
)
SELECT * , 
	CASE 
		WHEN out_of_stock_percent > 20  THEN 'Critical'
        WHEN out_of_stock_percent BETWEEN 10 AND 20 THEN 'Watch'
        ELSE 'Healthy'
	END AS availabilty_status 
FROM health
ORDER BY out_of_stock_percent 
LIMIT 15;

    
