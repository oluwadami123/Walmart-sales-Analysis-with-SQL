USE walmart_sales_data;	

-- Creating the table for the data
DROP TABLE IF EXISTS sales_data;
CREATE TABLE walmart_sales(
invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
branch VARCHAR(10) NOT NULL,
city VARCHAR(30) NOT NULL,
customer_type VARCHAR(30) NOT NULL,
gender VARCHAR(15) NOT NULL,
product_line VARCHAR(100) NOT NULL,
unit_price DECIMAL(10,2) NOT NULL,
quantity INT NOT NULL,
VAT FLOAT(6,4) NOT NULL,
total DECIMAL(12,4) NOT NULL,
date DATETIME NOT NULL,
time TIME NOT NULL,
payment_method VARCHAR(15) NOT NULL,
cogs DECIMAL(10,4) NOT NULL,
gross_margin_percentage FLOAT(11,9),
gross_income DECIMAL(12,4) NOT NULL,
rating FLOAT(2,1)
);

SELECT 
	DISTINCT city,
    branch
FROM walmart_sales;

SELECT 
	time,
    ( CASE
		WHEN time BETWEEN "00.00.00" AND "12.00.00" THEN "Morning" 
		WHEN time BETWEEN "12.00.01" AND "16.00.00" THEN "Afternoon"
		ELSE "Evening"
      END  
    ) AS Time_of_the_Day
FROM walmart_sales;


ALTER TABLE walmart_sales
ADD COLUMN Time_of_the_Day VARCHAR(30);

SET SQL_SAFE_UPDATES = 0;

UPDATE walmart_sales
SET Time_of_the_Day = (
CASE
	WHEN 'time' BETWEEN "00.00.00" AND "12.00.00" THEN "Morning" 
	WHEN 'time' BETWEEN "12.00.01" AND "16.00.00" THEN "Afternoon"
	ELSE "Evening"
END
);

 -- Day_Name
 
 SELECT
	date,
    DAYNAME(date) AS Day_Name,
    MONTHNAME(date) AS Month_Name
 FROM walmart_sales;


ALTER TABLE walmart_sales
ADD COLUMN Day_Name VARCHAR(30),
ADD COLUMN Month_Name VARCHAR(30);

UPDATE walmart_sales
SET Day_Name = DAYNAME(date),
Month_Name = MONTHNAME(date); 


------------------------------------------- Products -----------------------------------------

SELECT 
	*
FROM walmart_sales;

-- Unique Cities 
SELECT 
	DISTINCT city
FROM walmart_sales;

-- In which city is each branch
SELECT 
	DISTINCT city,
    branch
FROM walmart_sales;

-- How many unique product_lines does the data have?
SELECT
	COUNT(DISTINCT product_line) as No_of_unique_productlines
FROM walmart_sales;

-- What is the most common payment method?
SELECT 
	payment_method,
	Count(payment_method) 
FROM walmart_sales
GROUP BY payment_method
ORDER BY 2 DESC;

-- What is the most selling product_line?
SELECT
	DISTINCT product_line,
    COUNT(product_line) AS Count_of_product_line
FROM walmart_sales
GROUP BY product_line
ORDER BY 2 DESC;

-- What is the total revenue by month?
SELECT 
	DISTINCT Month_Name,
    SUM(total) OVER(PARTITION BY Month_Name) AS Total_Revenue_by_Month
FROM walmart_sales
ORDER BY Total_Revenue_by_Month DESC;

-- Second Method
SELECT 
	Month_Name,
    SUM(total) as Total_Revenue_by_Month
FROM walmart_sales
GROUP BY Month_Name
ORDER BY Total_Revenue_by_Month DESC;

-- What month had the largest Cogs(Cost of Good Sold)
SELECT 
	Month_Name AS Month, 
	SUM(cogs) AS Cost_Of_Good_Sold
FROM walmart_sales
GROUP BY Month
ORDER BY Cost_Of_Good_Sold DESC;

-- Second Method
SELECT
	DISTINCT Month_Name As Month,
    SUM(cogs) OVER(PARTITION BY Month_Name) AS Cost_Of_Good_Sold
FROM walmart_sales
ORDER BY 2 DESC;

-- Which product_line had the largest revenue?
SELECT 
	DISTINCT product_line,
    SUM(total) AS Total_Revenue
FROM walmart_sales
GROUP BY product_line
ORDER BY 2 DESC;

-- Second Method
SELECT 
	DISTINCT product_line,
    SUM(cogs) OVER (PARTITION BY product_line) AS Cost_Of_Goods
FROM walmart_sales
ORDER BY 2 DESC;    
    
-- What is the city with the largest revenue?
SELECT 
	city,
    SUM(total) as Revenue
FROM walmart_sales
GROUP BY city
ORDER BY 2 DESC;

-- Second Method
SELECT
	DISTINCT city,
    ROUND(SUM(total) OVER(PARTITION BY city),1) AS Revenue
FROM walmart_sales
ORDER BY 2 DESC; 

-- What Product_line has the largest VAT(Tax of 5%)
SELECT
	product_line,
	AVG(VAT) AS Avg_of_VAT
FROM walmart_sales
GROUP BY product_line
ORDER BY 2 DESC;

-- Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales
SELECT 
	DISTINCT product_line,
    SUM(total) AS Sum_sales,
    AVG(total) as Avg_sales,
    CASE 
		WHEN SUM(total) >= Avg(total) THEN "Good"
        ELSE "Bad"
	END AS Sales_score
FROM walmart_sales
GROUP BY product_line
ORDER BY 2 DESC;

-- Which branch sold more products than average product sold?
SELECT 
	branch,
    SUM(quantity) AS Qty
FROM walmart_sales
GROUP BY branch
HAVING SUM(quantity) > (
SELECT 
	AVG(quantity)
FROM walmart_sales
);


SELECT 
	branch,
    SUM(quantity) AS qty
FROM walmart_sales
GROUP BY branch
ORDER BY 2 DESC;

-- 9. What is the most common product line by gender?
SELECT 
	DISTINCT gender,
	product_line,
    COUNT(product_line) AS count_product_by_gender
FROM walmart_sales
GROUP BY gender, product_line
ORDER BY 1,3 DESC; 

-- What is the average rating of each product line?
SELECT 
    product_line,
    AVG(rating) AS Avg_rating_for_product_line
FROM walmart_sales
GROUP BY product_line
ORDER BY 2 DESC;

------------------------------------------- Sales -----------------------------------------
-- 1. Number of sales made in each time of the day per weekday
SELECT 
	Time_of_the_Day,
	COUNT(total) AS count_sales
FROM walmart_sales
WHERE Day_Name = "Saturday"
GROUP BY Time_of_the_Day
ORDER BY 2 DESC;

-- 2. Which of the customer types brings the most revenue?
SELECT 
	customer_type,
   ROUND(SUM(total),2) AS Sum_of_Sales
FROM walmart_sales
GROUP BY customer_type
ORDER BY 2 DESC;

-- 3. Which city has the largest tax percent/ VAT (**Value Added Tax**)?
SELECT 
	city,
    AVG(VAT) AS Tax_Payment
FROM walmart_sales
GROUP BY city
ORDER BY 2 DESC;

-- 4. Which customer type pays the most in VAT?
SELECT 
	customer_type,
    AVG(VAT) AS Tax_payment
FROM walmart_sales
GROUP BY customer_type
ORDER BY 2 DESC;

------------------------------------------- Customer -----------------------------------------
-- 1. How many unique customer types does the data have?
SELECT
	customer_type,
	COUNT(DISTINCT customer_type) as Unique_count_of_customer_type
FROM walmart_sales
GROUP BY customer_type
ORDER BY 2 DESC;
-- 2. How many unique payment methods does the data have?
SELECT 
	DISTINCT payment_method,
    COUNT(DISTINCT payment_method) Unique_count_of_payment_method
FROM walmart_sales
GROUP BY payment_method;
-- 4. Which customer type buys the most?
SELECT 
	customer_type,
    SUM(total) as Sum_of_Sales
FROM walmart_sales
GROUP BY customer_type
ORDER BY 2 DESC;    

SELECT 
	customer_type,
    COUNT(customer_type) AS count_of_customer_type
FROM walmart_sales
GROUP BY customer_type
ORDER BY 2 DESC;
-- 5. What is the gender of most of the customers?
SELECT 
	gender,
    COUNT(gender) AS Count_of_gender
FROM walmart_sales
GROUP BY gender
ORDER BY 2 DESC;

-- 6. What is the gender distribution per branch?
-- Gender distribution for the first branch "a"
SELECT
DISTINCT branch
FROM walmart_Sales
ORDER BY 1;

SELECT
	gender,
    COUNT(gender) AS count_of_gender
FROM walmart_sales
WHERE branch ="a"    
GROUP BY gender
ORDER BY 2 DESC;

-- Gender distribution for the second branch "b"
SELECT
	gender,
    COUNT(gender) AS count_of_gender
FROM walmart_sales
WHERE branch ="b"    
GROUP BY gender
ORDER BY 2 DESC;
 
-- Gender distribution for the third branch "c"
SELECT
	gender,
    COUNT(gender) AS count_of_gender
FROM walmart_sales
WHERE branch ="c"    
GROUP BY gender
ORDER BY 2 DESC;
    
-- 7. Which time of the day do customers give most ratings?
SELECT 
	Time_of_the_Day,
    AVG(rating) AS Avg_rating
FROM walmart_sales
GROUP BY Time_of_the_Day
ORDER BY 2 DESC;

-- 8. Which time of the day do customers give most ratings per branch?
-- Branch A
SELECT 
	Time_of_the_Day,
    AVG(rating) AS Avg_rating
FROM walmart_sales
WHERE branch = "a"
GROUP BY Time_of_the_Day
ORDER BY 2 DESC;

-- Branch B
SELECT 
	Time_of_the_Day,
    AVG(rating) AS Avg_rating
FROM walmart_sales
WHERE branch = "b"
GROUP BY Time_of_the_Day
ORDER BY 2 DESC;

-- Branch C
SELECT 
	Time_of_the_Day,
    AVG(rating) AS Avg_rating
FROM walmart_sales
WHERE branch = "c"
GROUP BY Time_of_the_Day
ORDER BY 2 DESC;

-- 9. Which day of the week has the best avg ratings?
SELECT 
	Day_Name,
    AVG(rating) AS Avg_Rating
FROM walmart_sales
GROUP BY Day_Name
ORDER BY 2 DESC;

-- 10. Which day of the week has the best average ratings per branch?
SELECT 
	Day_Name,
    AVG(rating) AS Avg_Rating
FROM walmart_sales
WHERE branch = "A"
GROUP BY Day_Name
ORDER BY 2 DESC;

SELECT 
	Day_Name,
    AVG(rating) AS Avg_Rating
FROM walmart_sales
WHERE branch = "B"
GROUP BY Day_Name
ORDER BY 2 DESC;

SELECT 
	Day_Name,
    AVG(rating) AS Avg_Rating
FROM walmart_sales
WHERE branch = "C"
GROUP BY Day_Name
ORDER BY 2 DESC;




