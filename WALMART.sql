Create table walmart
(
	invoice_id	int,
	Branch	varchar(70),
	City char(60),
	category varchar(100),	
	unit_price	int,
	quantity int,
	date date,
	time TIME,	
	payment_method varchar(50),
	rating float,
	profit_margin float,
	total float

)

	alter table walmart
	alter column unit_price set data type float;

ALTER TABLE walmart
  ALTER COLUMN quantity SET DATA TYPE DOUBLE PRECISION;

SET datestyle = 'DMY';


copy walmart
from 'C:\\Program Files\\PostgreSQL\\16\\data\\data_copy\\walmart_clean_data.csv'
delimiter ','
csv header


select count(distinct branch)
from walmart

--Business Problem 1:
-- find different payment method and number of transactions, number of qty sold

select distinct payment_method,
	count(*) as no_payments,
	sum(quantity) as no_qty_sold
	from walmart
group by payment_method


--Business Problem 2:
--Identify the highest-rated category in each branch, displaying the branch, category, avg rating
select *
	from
	(
select
    branch,
category,
avg(rating) as avg_Rating,
rank () over (partition by branch order by avg(rating) desc) as rank
from walmart
group by 1,2
)
where rank=1

--Business Problem 3:
-- Identify the busiest day for each branch based on the number of transcations
select *
	from
	(
select 
branch,
to_char(date, 'Day') as day,
	count(*) as no_transactions,
	rank() over (partition by branch order by count(*) desc) as rank
from walmart
group by 1,2
)
where rank =1

--Business Problem 4:
-- Calculate the total quantiy of items sold per payment method. List payment method and total quatity

select sum(quantity),
payment_method
from walmart
group by payment_method

--Business Problem 5:
--Determine the average, mimimum, and maximum rating of products for each city
--list the city, average_Rating, min_rating, and max_rating

select
 min(rating),
max(rating),
avg(rating),
city,
	category
from walmart
group by city, category

--Business Problem 6:
--calculate the total profit for each category by considering total_profit as
--(unit_price * quantity * profit_margin). List category and total_profit, ordered from highest to lowest profit\

select
	category,
	sum(total) as total_revenue,
	sum(total * profit_margin) as profit
from walmart
group by 1

--Business Problem 7:
--Determine the most common payment method for each branch
--display branch and the preferred payment method

	with cte as
	(
select branch, payment_method,
count(*) as total_transaction,
	rank() over(partition by branch order by count(*) desc) as rank
from walmart
group by 1,2)

select branch, payment_method, total_transaction
from cte
where rank=1

--Business Problem 8:
--categorize the sale into 3 groups: MORNING, AFTERNOON, EVENING
--Find out which of the shift and number of invoices

SELECT
	branch,
    CASE 
        WHEN EXTRACT(HOUR FROM time) < 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS day_time,
	count(*)
FROM walmart
group by 1,2
order by 1, 3 desc


--Business Problem 9:
-- Identify 5 branch with highest decrease ration in revenue compare to last year(current year 2023 and last year 2022)
with revenue_2022 as
	(
select 
branch,
	sum(total) as revenue
	from walmart
	where extract(year from date) =2022
group by 1
),
	revenue_2023
	as
	(
select 
branch,
	sum(total) as revenue
	from walmart
	where extract(year from date) =2023
group by 1
)

	select 
	ls.branch,
	ls.revenue as last_year_revenue,
	cs.revenue as current_year_revenue,
	ROUND((ls.revenue-cs.revenue)::numeric/ls.revenue::numeric *100,2) as decrease_ratio
from revenue_2022 as ls
join 
revenue_2023 as cs
on ls.branch = cs.branch
where 
ls.revenue > cs.revenue
ORDER BY 4 DESC
LIMIT 5



