SELECT * FROM retail;

SELECT count(*) FROM retail;

-- creating duplicate table for data manipulation
CREATE TABLE new_retail LIKE retail;

-- modifying datatypes of few columns 
ALTER TABLE new_retail 
MODIFY COLUMN sale_date DATE, 
MODIFY COLUMN sale_time TIME,
MODIFY COLUMN gender VARCHAR(15),
MODIFY COLUMN category VARCHAR(15),
MODIFY COLUMN price_per_unit FLOAT,
MODIFY COLUMN cogs FLOAT,
MODIFY COLUMN total_sale FLOAT;


-- while inserting values from retail, I encoutered an error as date and time were not in standard format
INSERT INTO new_retail (transactions_id, sale_date, sale_time, customer_id, gender,age, category, quantity, price_per_unit, cogs, total_sale)
SELECT
	transactions_id,
    STR_TO_DATE(sale_date, '%d-%m-%Y'),  -- Converted sale_date to correct format
    STR_TO_DATE(sale_time, '%H:%i:%s'),  -- Converted sale_time to TIME format
    customer_id,
    gender,
    age,
    category, 
    quantity,
    price_per_unit, 
    cogs, 
    total_sale
FROM retail;

-- checking datatype of columns in retail data
DESC retail;

-- before setting transaction_id column as primary key , few checks needs to be performed
SELECT transactions_id, COUNT(*)
FROM new_retail
GROUP BY transactions_id
HAVING COUNT(*) > 1; -- This checks for duplicates
-- no duplicates were found

SELECT COUNT(*) FROM new_retail 
WHERE transactions_id IS NULL; -- This checks for NULL values
-- no null values found

-- setting transactions_id as primary key
ALTER TABLE new_retail
ADD PRIMARY KEY (transactions_id);


select * from new_retail;

-- ensuring if all the rows have been correctly imported or not
select count(*) from new_retail;
-- total number of rows in excel were 2000, that means 13 rows were missed during importing data into MySQL

-- below query gives accurate count of missing records
SELECT (2000 - COUNT(transactions_id)) AS missing_count 
FROM new_retail;

SET SESSION cte_max_recursion_depth = 2000;

-- to retrieve the missing transaction id's
WITH RECURSIVE numbers AS (
    SELECT 1 AS num
    UNION ALL
    SELECT num + 1 FROM numbers WHERE num < 2000
)
SELECT num AS missing_transaction_id
FROM numbers
LEFT JOIN new_retail ON numbers.num = new_retail.transactions_id
WHERE new_retail.transactions_id IS NULL;

-- inserting the missing values
INSERT INTO new_retail (
    transactions_id, sale_date, sale_time, customer_id, gender, age, category,
    quantity, price_per_unit, cogs, total_sale
)
VALUES
    (150, '2022-04-13', '08:25:00', 89, 'Female', NULL, 'Electronics', 4, 30, 16.2, 120),
    (432, '2022-03-10', '11:31:00', 17, 'Female', NULL, 'Electronics', 2, 500, 190, 1000),
    (679, '2022-08-26', '08:59:00', 64, 'Female', 18, 'Beauty', NULL, NULL, NULL, NULL),
    (746,'2022-07-05',	'11:33:00',	42,	'Female',33, 'Clothing',NULL, NULL, NULL, NULL),
    (797, '2022-09-16', '06:38:00', 116, 'Male', NULL, 'Clothing', 3, 25, 10.75, 75),
    (845, '2022-10-27', '10:12:00', 25, 'Male', NULL, 'Clothing', 1, 500, 145, 500),
    (921, '2022-09-28', '09:34:00', 101, 'Male', NULL, 'Electronics', 3, 25, 8, 75),
    (1150, '2022-08-22', '10:04:00', 77, 'Female', NULL, 'Electronics', 4, 30, 10.2, 120),
    (1225, '2022-02-02', '09:51:00', 137, 'Female', 57, 'Beauty', NULL, NULL, NULL, NULL),
    (1367, '2022-04-15', '11:38:00', 16, 'Female', NULL, 'Electronics', 1, 50, 15.5, 50),
    (1391, '2022-03-01', '11:29:00', 130, 'Male', NULL, 'Beauty', 2, 25, 9.25, 50),
    (1432, '2022-12-25', '06:24:00', 67, 'Female', NULL, 'Electronics', 2, 500, 245, 1000),
    (1845, '2022-05-24', '07:06:00', 94, 'Male', NULL, 'Clothing', 1, 500, 185, 500);


-- retrieving records which contains NULL values    
    select * from new_retail
		where
        transactions_id IS NULL
        OR
        sale_date IS NULL
        OR
        sale_time IS NULL
        OR
        gender IS NULL
        OR
        age IS NULL
        OR
        category IS NULL
        OR
        quantity IS NULL
        OR
        price_per_unit IS NULL
        OR
        cogs IS NULL
        OR
        total_sale IS NULL;
        
-- removing NULL values(data cleaning)
DELETE from new_retail
		where
        transactions_id IS NULL
        OR
        sale_date IS NULL
        OR
        sale_time IS NULL
        OR
        gender IS NULL
        OR
        age IS NULL
        OR
        category IS NULL
        OR
        quantity IS NULL
        OR
        price_per_unit IS NULL
        OR
        cogs IS NULL
        OR
        total_sale IS NULL;


-- Data Exploration
-- How many sales do we have?
select count(*) from new_retail;  

-- How many unique customers do we have?
select count(DISTINCT(customer_id)) from new_retail;

-- How many unique category do we have?
select count(DISTINCT(category)) from new_retail;

-- Data Analysis
-- Q1. Write a SQL query to retrieve all the columns for sales made on '2022-11-05'

select * FROM new_retail
where sale_date = '2022-11-05';

-- Q2. Write a SQL query to retrieve all the transactions where category is 'clothing' and quantity sold is more than 3 in the 
-- month of Nov 2022

select * FROM new_retail
where category = 'Clothing' and quantity > 3 and (sale_date BETWEEN '2022-11-01' AND '2022-11-30');

-- Q3. Write a SQL query to calculate the total sales for each category
select category, SUM(total_sale) AS Net_sale
FROM new_retail
group by 1;

-- Q4. Write a SQL query to find out the average age of customers who purchased items from the beauty category

select round(avg(age),2) AS Average_age
from new_retail
where category = 'beauty';

-- Q5. Write a SQL query to find all transactions where total_sale is greater than 1000
select * from new_retail
where total_sale > 1000;

-- Q6. Write a SQL query to find total number of transactions made by each gender in each category
select gender, category, COUNT(transactions_id) AS total_trans
from new_retail
group by gender, category
ORDER BY 2;

-- Q7. Write a SQL query to calculate average sale for each month. Find out best selling month in each year.
select retail_month, retail_year, AVG_Sale
from 
(select 
	month(sale_date) AS retail_month, 
    year(sale_date) AS retail_year, 
    round(avg(total_sale),2) AS AVG_Sale,
    RANK() OVER(partition by year(sale_date) ORDER BY round(avg(total_sale),2) DESC  ) AS order_rank
FROM new_retail
group by 1,2) AS T1
where order_rank = 1; 

-- Q8. Write a SQL query to find the top 5 customers based on the highest total sales

select customer_id, sum(total_sale) 
from new_retail
group by customer_id
order by 2 desc
limit 5;

-- Q9. Write a SQL query to find the number of unique customers who purchased items from each category

select category, count(DISTINCT(customer_id))
from new_retail
group by 1;

-- Q10. Write a SQL query to create each shift and number of orders Example : Morning <= 12, Afternoon between 12 & 17, Evening > 17)

WITH hourly_sale AS(
select *,
		CASE
			WHEN HOUR(sale_time) < 12 THEN 'Morning'
			WHEN HOUR(sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
			ELSE 'Evening'
		END AS Shift
from new_retail)
select count(transactions_id), Shift
from hourly_sale
group by Shift;

-- Q11. What are the sales trends over time? 

select * from new_retail; 

-- monthly sales trend (returns start of each month)
SELECT
	DATE_FORMAT(sale_date, '%Y-%m-01') AS sales_month,  
    SUM(quantity * price_per_unit) AS total_retails_sales  
FROM new_retail  
GROUP BY sales_month  
ORDER BY 1;

-- weekly sales trend (weekly sales distribution)
SELECT  
    DATE_FORMAT(sale_date, '%Y-%u-01') AS week_start,  
    SUM(total_sale) AS total_sales  
FROM new_retail  
GROUP BY week_start  
ORDER BY 1;

-- daily sales trend
SELECT 
    DATE(sale_date) AS sales_date, 
    SUM(total_sale) AS total_sales
FROM new_retail
GROUP BY sales_date
ORDER BY 1;



-- monthwise total sales in year 2022 and 2023
SELECT  
    EXTRACT(YEAR FROM sale_date) AS sales_year,  
    EXTRACT(MONTH FROM sale_date) AS sales_month,  
    SUM(total_sale) AS total_sales  
FROM new_retail  
GROUP BY sales_year, sales_month  
ORDER BY sales_year, sales_month;


-- Q12. Display total sales done on weekends and weekdays.

SELECT 
	CASE
		WHEN dayofweek(sale_date) IN (2,3,4,5,6) THEN 'WEEKDAY' 
        ELSE 'WEEKENDS'
	END AS day_type,
    SUM(total_sale)
FROM new_retail
group by day_type;

-- Q13.Does the time of day influence the type of products sold?

WITH hourly_sale AS(
select *,
		CASE
			WHEN HOUR(sale_time) < 12 THEN 'Morning'
			WHEN HOUR(sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
			ELSE 'Evening'
		END AS Shift
from new_retail)
select sum(total_sale), Shift, category
from hourly_sale
where category = 'Beauty' OR category = 'Electronics'
group by Shift, category
ORDER BY 2;
-- during evenings the sale is often more as compared to Afternoon and Morning


-- Q14. Which gender contributes the most to total sales?

select gender, SUM(total_sale)
from new_retail
group by gender;
-- females contribute slightly more as compared to males


-- Q15.What is the age distribution of customers across different product categories?

select 
	CASE
		WHEN age BETWEEN 18 AND 39  THEN 'Adult'
		WHEN age between 40 AND 60  THEN 'Middle-Aged'
        ELSE 'Senior-Citizen'
    END AS age_groups,
SUM(total_sale)
from new_retail
group by age_groups; 


-- Q16. What is the year-over-year growth in sales?
-- (Analyze if the business is expanding or shrinking.)

SELECT 
        YEAR(sale_date) AS sales_year,
        SUM(total_sale) AS total_sales
    FROM new_retail
    GROUP BY sales_year;

WITH yearly_sales AS (
    SELECT 
        YEAR(sale_date) AS sales_year,
        SUM(total_sale) AS total_sales
    FROM new_retail
    GROUP BY sales_year
)
SELECT 
    a.sales_year,
    a.total_sales AS current_year_sales,
    b.total_sales AS previous_year_sales,
    ((a.total_sales - b.total_sales) / b.total_sales) * 100 AS yoy_growth
FROM yearly_sales a
LEFT JOIN yearly_sales b
ON a.sales_year = b.sales_year + 1
ORDER BY a.sales_year;
-- from 2022 to 2023, business grew by 2.12% 

-- Q17. Which category has the lowest total sales?

select category, SUM(total_sale) from new_retail
group by category
order by 1; 

