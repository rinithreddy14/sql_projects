-- create database paintings
-- use  paintings;

-- 1) Fetch all the paintings which are not displayed on any museums?
SELECT 
    *
FROM
    work
WHERE
    museum_id IS NULL OR museum_id = ' ';


-- 2) Are there museuems without any paintings?
SELECT 
    *
FROM
    museum
WHERE
    museum_id NOT IN (SELECT 
            museum_id
        FROM
            work);


-- 3) How many paintings have an asking price of more than their regular price? 
-- not need join aksed how many
SELECT 
    *
FROM
    work AS w
        INNER JOIN
    product_size AS p ON w.work_id = p.work_id
WHERE
    p.sale_price > p.regular_price;


-- 4) Identify the paintings whose asking price is less than 50% of its regular price
SELECT 
    *
FROM
    product_size
WHERE
    sale_price < (regular_price / 2);

-- 5) Which canva size costs the most?
select c.label,p.size_id from canvas_size as c
join (select *,rank() over (order by regular_price desc) as ranking from product_size as p) as p
on p.size_id=c.size_id
where ranking=1;

-- 6) Delete duplicate records from work, product_size, subject and image_link tables
-- work_id is unique

DELETE w
FROM work w
LEFT JOIN (
    SELECT MIN(work_id) AS min_work_id
    FROM work
    GROUP BY work_id
) sub ON w.work_id = sub.min_work_id;
-- WHERE sub.min_work_id IS NULL;
-- (
-- with selected_data as 
-- (select min(work_id) as work_id
-- from work
-- group by  name ,artist_id,style ,museum_id)
--  delete from work 
--  where work_id not in (select work_id from selected_data)
--  -- 21 rows deleted
--  select * from product_size
-- with selected_data as 
-- (select min(work_id) as work_id
-- from canvas_size
-- group by  name ,artist_id,style ,museum_id)
--  delete from work 
--  where work_id not in (select work_id from selected_data)
--  




-- 7) Identify the museums with invalid city information in the given dataset
SELECT 
    name, city
FROM
    museum
WHERE
    city REGEXP '^[0-9]+$';


--  8) Museum_Hours table has 1 invalid entry. Identify it and remove it.
-- duplictae value at museum_id=80 and day=saturday
create table temp as
select museum_id,day,open,close from (
select *, row_number() over (partition by museum_id,day) as num from  museum_hours) as x
where num =1;

drop table museum_hours;
alter table temp
rename to museum_hours;



-- 9) Fetch the top 10 most famous painting subject


select subject,ranking from (select subject,count(1),rank() over (order by count(1) desc) as ranking from subject
group by subject) as x
where ranking<=10;



-- 10) Identify the museums which are open on both Sunday and Monday. Display museum name, city.
SELECT m.name, m.city 
FROM museum_hours AS mh
INNER JOIN museum AS m ON mh.museum_id = m.museum_id
WHERE mh.day = 'Sunday'
AND EXISTS (
    SELECT 1
    FROM museum_hours AS mmh
    WHERE mmh.museum_id = m.museum_id
    AND mmh.day = 'Monday'
);




-- 11) How many museums are open every single day?

SELECT 
    COUNT(museum_id) AS no_museums_open_all_week
FROM
    (SELECT 
        museum_id
    FROM
        museum_hours AS mm
    GROUP BY museum_id
    HAVING COUNT(day) = 7) AS x;


-- 12) Which are the top 5 most popular museum? (Popularity is defined based on most no of paintings in a museum)

select museum_id,ranking from (select museum_id,count(work_id),dense_rank() over (order by count(work_id) desc) as ranking from work
group by museum_id) as x
where ranking<=5;


-- 13) Who are the top 5 most popular artist? (Popularity is defined based on most no of paintings done by an artist)

select artist_id,ranking from (select artist_id,count(work_id),dense_rank() over (order by count(work_id) desc) as ranking from work
group by artist_id) as x
where ranking<=5;


select * from canvas_size;

-- 14) Display the 3 least popular canva sizes

-- both may give diffenrt answers but all are same if we remove limit we see all answers
SELECT 
    label
FROM
    (SELECT 
        label, p.size_id, COUNT(p.size_id) AS size_count
    FROM
        canvas_size AS c
    INNER JOIN product_size AS p
    WHERE
        c.size_id = p.size_id
    GROUP BY label , c.size_id
    ORDER BY size_count ASC) AS x
LIMIT 3;


SELECT 
    label, size_id
FROM
    canvas_size
WHERE
    size_id IN (SELECT 
            size_id
        FROM
            (SELECT 
                size_id, COUNT(1) AS size_count
            FROM
                product_size
            GROUP BY size_id
            ORDER BY size_count ASC
            LIMIT 3) AS x);


-- 15) Which museum is open for the longest during a day. Dispay museum name, state and hours open and which day?


with museum_time_diff as (
SELECT 
    museum_id,
    day,
    open_time,
    close_time,
    TIMESTAMPDIFF(MINUTE, open_time, close_time) AS duration_minutes,
    dense_rank() over (order by TIMESTAMPDIFF(MINUTE, open_time, close_time)  desc) as ranking
FROM (
    SELECT
    museum_id,
    day,
    STR_TO_DATE(close, '%h:%i :%p') AS close_time,
    STR_TO_DATE(open, '%h:%i :%p') AS open_time
FROM museum_hours

) AS x)
SELECT 
    m.museum_id,
    name,
    day,
    state,
    duration_minutes / 60 AS hours_open
FROM
    museum AS m
        INNER JOIN
    museum_time_diff AS mt ON m.museum_id = mt.museum_id
WHERE
    mt.ranking = 1;


-- 16) Which museum has the most no of most popular painting style?
with most_popular as(
select style from (
select style,count(style),dense_rank() over (order by count(style) desc) as ranking from work
where style <> ''
group by style
) as x
where ranking=1)
select museum_id from(
select museum_id,count(museum_id),dense_rank() over (order by count(museum_id) desc ) as ranking from work 
where style = (select style from most_popular)
group by museum_id) x
where ranking=1;




-- 17) Identify the artists whose paintings are displayed in multiple countries

select artist_id,full_name from (select a.artist_id,a.full_name,m.country,count(m.country),dense_rank() over(partition by a.artist_id order by count(m.country) ) as ranking from work as w
inner join artist as a on w.artist_id=a.artist_id
inner join museum as m on w.museum_id=m.museum_id
group by a.artist_id,a.full_name,m.country) as x
where ranking>1
group by artist_id,full_name;


SELECT 
    artist_id, full_name
FROM
    (SELECT 
        a.artist_id, a.full_name, m.country, COUNT(m.country)
    FROM
        work AS w
    INNER JOIN artist AS a ON w.artist_id = a.artist_id
    INNER JOIN museum AS m ON w.museum_id = m.museum_id
    GROUP BY a.artist_id , a.full_name , m.country) AS x
GROUP BY artist_id , full_name
HAVING COUNT(artist_id) > 1;


-- 18) Display the country and the city with most no of museums. Output 2 seperate columns t
-- o mention the city and country. If there are multiple value, seperate them with comma.

SELECT 
    country,
    city,
    GROUP_CONCAT(name
        SEPARATOR ',')
FROM
    museum
GROUP BY country , city;


-- 19) Identify the artist and the museum where the most expensive and least expensive painting is placed. 
-- Display the artist name, sale_price, painting name, museum name, museum city and canvas label

select  artist_id,museum_id,full_name,min(sale_price),name,city,label from 
(select a.artist_id,w.museum_id,a.full_name,sale_price,m.name,m.city,c.label,dense_rank() over (order by sale_price desc) as highest_rank,dense_rank() over (order by sale_price asc) as lowest_rank from work as w
inner join artist as a on w.artist_id=a.artist_id
inner join museum as m on m.museum_id=w.museum_id
inner join product_size as p on w.work_id=p.work_id
inner join canvas_size as c on p.size_id=c.size_id) as x
where highest_rank =1 or lowest_rank=1
group by artist_id,museum_id,full_name,sale_price,name,city,label;


-- 20) Which country has the 5th highest no of paintings?
select country from (select country,count(1),dense_rank() over (order by count(1) desc) as ranking from museum
group by country
) as x
where ranking =5;




-- 21) Which are the 3 most popular and 3 least popular painting styles?


select style,(case when low_ranking<=3 then 'least_popular' else 'high_popular' end) as popularity from(
select style,count(1),
dense_rank() over (order by count(1) asc) as low_ranking,
dense_rank() over (order by count(1) desc) as high_ranking from work
group by style) as x
where low_ranking<=3 or high_ranking<=3;

-- 22) Which artist has the most no of Portraits paintings outside USA?. 
-- Display artist name, no of paintings and the artist nationality.
SELECT 
    a.full_name,
    COUNT(1) AS no_of_Portraits,
    country AS nationality
FROM
    work AS w
        INNER JOIN
    artist AS a ON w.artist_id = a.artist_id
        INNER JOIN
    museum AS m ON m.museum_id = w.museum_id
WHERE
    country != 'USA'
GROUP BY a.full_name , country
ORDER BY no_of_Portraits DESC

