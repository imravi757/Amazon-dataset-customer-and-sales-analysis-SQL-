-- creating the database
create database odindb;
show databases;
select * from amazon;
-- Converting date into date datatype
Alter table amazon
add new_date DATE;
update amazon
set new_date = str_to_date(`Date`,'%Y-%m-%d');
show columns from amazon;
alter table amazon
drop `Date`;
alter table amazon
rename column new_date to `Date`;
-- Add new columns
Alter table amazon
add timeofday varchar(20);
update amazon 
set timeofday = 
case when extract(Hour from `time`) < 12 then 'Morning'
when extract(Hour from `time`) < 16 then 'Afternoon'
else 'Evening' end;

Alter table amazon
add dayname varchar(20);
update amazon 
set dayname = Dayname(`date`);

Alter table amazon
add monthname varchar(20);
update amazon 
set monthname = monthname(`Date`);

-- 1. What is the count of distinct cities in the dataset?
SELECT COUNT(DISTINCT(City))
FROM amazon;
SELECT DISTINCT(City)
FROM amazon;
-- There are total three cities in dataset, the names of the cities are Yangon, Naypyitaw, Mandalay.
-- ----------------------------------------------------------------------------------------------------
-- 2. For each branch, what is the corresponding city?
SELECT DISTINCT(branch), city 
FROM amazon
ORDER BY 1;
-- Comment- The cities For Branch A,B and C are Yangon, Mandalay and Naypyitaw respectively.
-- -------------------------------------------------------------------------------------------------------
-- 3. What is the count of distinct product lines in the dataset?
SELECT DISTINCT(`Product line`)
FROM amazon;
/* Comment - There are total 6 product lines in the dataset.
 There names are Health and beauty, Electronic accessories,
 Home and lifestyle, Sports and travel, Food and beverages, Fashion accessories. */
-- ---------------------------------------------------------------------------------------------------------------------
-- 4. Which payment method occurs most frequently?
SELECT Payment,COUNT(Payment)  as `Total Payment`
FROM amazon
GROUP BY Payment
ORDER BY COUNT(*) DESC
LIMIT 1;
-- Comment- Ewallet is the most frequently occuring payment method.
-- -------------------------------------------------------------------------------------------------------
-- 5. Which product line has the highest sales?
SELECT
`Product line`, 
ROUND(SUM(Total),2) AS `Total Sales` 
FROM amazon
GROUP BY `Product line`
ORDER BY SUM(Total) DESC
LIMIT 1;
-- Comment- Food and beverages has highest sales in the dataset with Total 56144.84 rupees of sales.
-- -------------------------------------------------------------------------------------------------------
-- 6. How much revenue is generated each month?
SELECT `monthname`,
ROUND(SUM(Total),2) AS `TOTAL GROSS INCOME`
FROM AMAZON
GROUP BY `monthname`
ORDER BY 2 DESC;
-- 7. In which month did the cost of goods sold reach its peak?
SELECT `monthname`,
ROUND(SUM(cogs),0) AS `Total Gross Income`
FROM amazon
GROUP BY `monthname`
ORDER BY 2 DESC;

-- 8. Which product line generated the highest revenue?
SELECT `Product line`,ROUND(SUM(`gross income`),0) AS `Total Revenue` FROM AMAZON
GROUP BY `Product line`
ORDER BY 2 DESC
LIMIT 1;
-- 9. In which city was the highest revenue recorded?
SELECT City, ROUND(SUM(`gross income`),0) AS `Total Revenue` FROM AMAZON
GROUP BY City
ORDER BY 2 DESC
LIMIT 1;
-- 10.Which product line incurred the highest Value Added Tax?
SELECT * FROM AMAZON;
SELECT `Product line`, ROUND(SUM(`Tax 5%`),2)
FROM amazon
GROUP BY `Product line`
ORDER BY 2 DESC
LIMIT 1;
-- 11. For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."
WITH SALES_CTE AS (select `Product line`,sum(quantity) as `Total Sale` from amazon
group by `Product line`)
SELECT `Product line`,`Total Sale`, 
CASE WHEN `Total Sale`> (SELECT AVG(`Total Sale`)  FROM SALES_CTE)
 THEN 'Good' ELSE 'Bad' END AS 'Sales Performance' FROM SALES_CTE ;
-- 12. Identify the branch that exceeded the average number of products sold.
WITH branch_cte AS(
	SELECT branch,
	SUM(quantity) AS `Total Sale`
	FROM amazon
	GROUP BY Branch)
SELECT branch,`Total Sale` 
FROM branch_cte
WHERE `Total Sale` > (SELECT AVG(`Total Sale`) FROM branch_cte);
-- 13. Which product line is most frequently associated with each gender?
With gender_cte as(SELECT `Product Line`,
case when gender = 'Male' then 1 else 0 end as male_count,
case when gender = 'Female' then 1 else 0 end as Female_count
from  amazon)
select `Product Line`, sum(male_count) as Males, sum(female_count) as Females from gender_cte
group by `Product Line`;

select `product line`,gender, count(*) as `Total Buyers` from amazon
group by `product line`,gender
order by 3 desc;
-- 14. Calculate the average rating for each product line.
SELECT `product line`, ROUND(AVG(RATING),2)
FROM AMAZON
GROUP BY `product line`
ORDER BY 2 DESC;
-- 15. Count the sales occurrences for each time of day on every weekday.
SELECT timeofday, count(`Invoice ID`) as `Total Sales Occurrences`
FROM AMAZON
group by timeofday
order by 2 desc;
-- 16. Identify the customer type contributing the highest revenue.
select `Customer type`,round(sum(Total),2) as `Total Revenue`  from amazon
group by `Customer type`;
select * from amazon;
-- 17. Determine the city with the highest VAT percentage.
SELECT City, ROUND(SUM(`Tax 5%`),2)
FROM amazon
GROUP BY City
ORDER BY 2 DESC;
-- 18. Identify the customer type with the highest VAT payments.
SELECT `Customer type`, ROUND(SUM(`Tax 5%`),2)
FROM amazon
GROUP BY `Customer type`
ORDER BY 2 DESC;
-- 19. What is the count of distinct customer types in the dataset?
SELECT COUNT(DISTINCT(`Customer type`))as `Distinct Customer Type` from amazon;
-- 20. What is the count of distinct payment methods in the dataset?
SELECT COUNT(DISTINCT(Payment))as `Distinct Payment Method` from amazon;
-- 21. Which customer type occurs most frequently?
Select `Customer type`, count(`Invoice ID`) as frequency from amazon
Group by `Customer type`;
-- 22. Identify the customer type with the highest purchase frequency.
Select `Customer type`, count(`Invoice ID`) as frequency from amazon
Group by `Customer type`
limit 1;
-- 23. Determine the predominant gender among customers.
select gender, count(`Invoice ID`) as `Total Buyers` from amazon
group by gender
order by 2 desc;
-- 24. Examine the distribution of genders within each branch.
select branch, gender, count(`Invoice ID`) as `Total Buyers` from amazon
group by branch, gender
order by 1;
-- 25. Identify the time of day when customers provide the most ratings.
select timeofday, round(avg(Rating),2) from amazon
group by timeofday
order by 2 desc;
-- 26. Determine the time of day with the highest customer ratings for each branch.
select branch, timeofday, round(avg(Rating),2) from amazon
group by branch,timeofday
order by 1 asc, 3 desc;
-- 27. Identify the day of the week with the highest average ratings.
select dayname, round(avg(Rating),2) from amazon
group by dayname
order by 2 desc
limit 1;
-- 28. Determine the day of the week with the highest average ratings for each branch.

WITH dow 
	AS(
	SELECT 
		branch, 
        dayname, 
        ROUND(AVG(Rating),2) AS avg_rating 
	FROM amazon
	GROUP BY
		branch,
        dayname
	ORDER BY 1)
SELECT
	branch,
    dayname, 
    MAX(avg_rating) AS avg_highest_rating 
FROM dow
GROUP BY branch, dayname
HAVING avg_highest_rating IN(
SELECT MAX(avg_rating)
FROM dow
GROUP BY branch
);

