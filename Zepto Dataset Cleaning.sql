USE zepto;
-- Data Cleaning 

-- Converting The Products Prices Paise to Rupees

CREATE VIEW zepto_cleaned AS
	SELECT 
		Category,
        name ,
        ROUND(mrp/100 , 2) AS mrp_rupees,
        discountPercent ,
        availableQuantity,
        ROUND(discountedSellingPrice/100 , 2) AS discountedSellingPrice_rupees,
        weightInGms,
        outOfStock,
        quantity
FROM zepto_v2;
        
        
SELECT * 
FROM zepto_cleaned;

-- Checking Missing Values
-- 1. Product Name -> 0

SELECT COUNT(*)
FROM zepto_cleaned
WHERE name IS NULL;

-- 2. Category -> 0
SELECT COUNT(*)
FROM zepto_cleaned
WHERE category IS NULL;

-- 3. MRP -> 1
SELECT COUNT(*) 
FROM zepto_cleaned 
WHERE mrp_rupees = 0 OR mrp_rupees < 0;

SELECT *
FROM zepto_cleaned
WHERE mrp_rupees = 0 OR mrp_rupees < 0;

DELETE 
FROM zepto_cleaned
WHERE mrp_rupees = 0 OR mrp_rupees < 0;

--  4.Selling Price -> 0
SELECT COUNT(*) 
FROM zepto_cleaned 
WHERE discountedSellingPrice_rupees = 0 OR discountedSellingPrice_rupees < 0;

-- 5. AvailableQuantity -> 0 
SELECT COUNT(*)
FROM zepto_cleaned 
WHERE availableQuantity <= 0 AND outOfStock = TRUE;

-- Checking Duplicate Products 
SELECT *,
       COUNT(*) AS cnt
FROM zepto_cleaned
GROUP BY Category,
         name,
         mrp_rupees,
         discountPercent,
         availableQuantity,
         discountedSellingPrice_rupees,
         weightInGms,
         outOfStock,
         quantity
HAVING COUNT(*) > 1;

CREATE TABLE zepto_cleaned_rd AS
SELECT DISTINCT *
FROM zepto_cleaned;

SELECT COUNT(*) FROM zepto_cleaned; -- COUNT = 3727
SELECT COUNT(*) FROM zepto_cleaned_rd; -- COUNT = 3725 -> Removed Two Duplicates 

-- Checking Invalid Discounts -> 0 
SELECT * 
FROM zepto_cleaned_rd 
WHERE discountPercent < 0 AND discountPercent > 100;

-- checking Invalid Prices -> 0 
SELECT * 
FROM zepto_cleaned_rd 
WHERE mrp_rupees < discountedSellingPrice_rupees;

-- Checking Negative Quantities -> 0 
SELECT * 
FROM zepto_cleaned_rd
WHERE availableQuantity < 0 ;

-- Checking Out-of-Stock Consistency -> 0 
SELECT * 
FROM zepto_cleaned_rd 
WHERE outOfStock = TRUE AND availableQuantity > 0 ;
