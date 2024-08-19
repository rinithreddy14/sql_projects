-- create database walmart;
-- use walmart;
select * from walmart;


-- changing the datatypes

ALTER TABLE walmart
ADD COLUMN dated date,
add column timed time;

update walmart
set dated=str_to_date(Date,"%Y-%m-%d"),
    timed=str_to_date(time,"%H:%i:%s");

-- droping the old columns
alter table walmart
drop column time,
drop column date;

-- renaming the new tables with the old tables

alter table walmart
rename column dated to date,
rename column timed to time;


-- There are no null values or blanks in the data , The data was ready for analysis

-- Generic Questions

-- How many distinct cities are present in the dataset?
SELECT DISTINCT
    city
FROM
    walmart;
-- In which city is each branch situated?
SELECT DISTINCT
    branch, city
FROM
    walmart;
-- Product Analysis
-- How many distinct product lines are there in the dataset?
SELECT DISTINCT
`product line`
FROM
    walmart;

-- What is the most common payment method?
select payment from ( 
select payment,dense_rank() over(order by count(payment) desc) as ranking from walmart
group by payment) as x
where ranking=1;

-- (or)

select payment,count(payment) from walmart
group by payment
order by 2 desc
limit 1;
-- What is the most selling product line?

select `product line` from ( 
select `product line`,dense_rank() over(order by count(`product line`) desc) as ranking from walmart
group by `product line`) as x
where ranking=1;

-- (or)
SELECT 
    `product line`, COUNT(`product line`)
FROM
    walmart
GROUP BY `product line`
ORDER BY 2 DESC
LIMIT 1;

-- What is the total revenue by month?
SELECT 
    MONTH(date), ROUND(SUM(total), 2)
FROM
    walmart
GROUP BY MONTH(date)
ORDER BY 2 DESC
LIMIT 1;

-- Which month recorded the highest Cost of Goods Sold (COGS)?
SELECT 
    MONTH(date), SUM(cogs)
FROM
    walmart
GROUP BY MONTH(date)
ORDER BY 2 DESC
LIMIT 1;

-- Which product line generated the highest revenue?
SELECT 
    `product line`, ROUND(SUM(total), 2)
FROM
    walmart
GROUP BY `product line`
ORDER BY 2 DESC
LIMIT 1;
-- Which city has the highest revenue?
SELECT 
    city, ROUND(SUM(total), 2)
FROM
    walmart
GROUP BY city
ORDER BY 2 DESC
LIMIT 1;

-- Retrieve each product line and add a column product_category
-- , indicating 'Good' or 'Bad,' based on whether its sales are above the average.
alter table walmart
add column product_category varchar(10);

create table temp as
select avg(total) as total from walmart ;

UPDATE walmart 
SET 
    product_category = CASE
        WHEN
            total >= (SELECT 
                    total
                FROM
                    temp)
        THEN
            'Good'
        ELSE 'Bad'
    END; 
    
drop table temp;
-- Which branch sold more products than average product sold?
select branch,sum(quantity)  from walmart
group by branch
having sum(quantity)>avg(quantity)
order by 2 desc 
limit 1;

-- What is the most common product line by gender?
select gender,`product line` from (
select gender, `product line`,
dense_rank() over (partition by gender order by count(`product line`) desc) as ranking from walmart
group by gender,`product line`) as x
where ranking=1;

-- What is the average rating of each product line?
SELECT 
    `product line`, ROUND(AVG(rating), 2)
FROM
    walmart
GROUP BY `product line`;

-- Sales Analysis


alter table walmart 
add column dayname varchar(10);

UPDATE walmart 
SET 
    dayname = DAYNAME(date);

alter table walmart 
add column month_name varchar(10);

UPDATE walmart 
SET 
    month_name = MONTHNAME(date);




-- Number of sales made in each time of the day per weekday
SELECT 
    DAY(date), dayname, HOUR(time), COUNT(`invoice id`)
FROM
    walmart
GROUP BY DAY(date) , dayname , HOUR(time)
HAVING dayname NOT IN ('Sunday' , 'Saturday')
ORDER BY 1 , 2;



-- Identify the customer type that generates the highest revenue.
SELECT 
    `customer type`, ROUND(SUM(total), 2)
FROM
    walmart
GROUP BY `customer type`
ORDER BY 2 DESC;


-- Which city has the largest tax percent?
SELECT 
    city,
    CONCAT(ROUND(SUM(`tax 5%`) / COUNT(city), 2),
            '%')
FROM
    walmart
GROUP BY city
ORDER BY 2 DESC
LIMIT 1;


-- Customer Analysis


-- How many unique customer types does the data have?

SELECT DISTINCT
    `customer type`
FROM
    walmart;


-- How many unique payment methods does the data have?

SELECT DISTINCT
    Payment
FROM
    walmart;
-- Which is the most common customer type?

SELECT 
    `customer type`, COUNT(`customer type`)
FROM
    walmart
GROUP BY `customer type`
ORDER BY 2 DESC
LIMIT 1;

-- Which customer type buys the most?

SELECT 
    `customer type`, SUM(total)
FROM
    walmart
GROUP BY `customer type`
ORDER BY 2 DESC
LIMIT 1;
-- What is the gender of most of the customers?
SELECT 
    gender, COUNT(gender)
FROM
    walmart
GROUP BY gender
ORDER BY 2 DESC
LIMIT 1;
-- What is the gender distribution per branch?
SELECT 
    Branch,
    COUNT(CASE
        WHEN gender = 'male' THEN 1
        ELSE NULL
    END) AS male,
    COUNT(CASE
        WHEN gender = 'female' THEN 1
        ELSE NULL
    END) AS female
FROM
    walmart
GROUP BY branch;
              
              
              
              -- or

SELECT 
    branch, gender, COUNT(gender)
FROM
    walmart
GROUP BY branch , gender
ORDER BY branch , gender;

-- Which time of the day do customers give most ratings?

SELECT 
    HOUR(time), COUNT(rating)
FROM
    walmart
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;
-- Which time of the day do customers give most ratings per branch?

select branch,hour from 
(select hour(time) as hour,branch, dense_rank() over (partition by branch order by count(rating) desc) as ranking from walmart
group by hour(time),branch) as x
where ranking=1;



-- Which day of the week has the best avg ratings?

SELECT 
    dayname, ROUND(AVG(rating), 2) AS best_rating
FROM
    walmart
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;
-- Which day of the week has the best average ratings per branch?

select branch,day from 
(select dayname as day,branch, dense_rank() over (partition by branch order by avg(rating) desc) as ranking from walmart
group by dayname,branch) as x
where ranking=1;


