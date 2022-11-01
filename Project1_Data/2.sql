--Initial query №2

SELECT country.country 
	FROM public.country, public.city, public.address, public.customer 
	where country.country_id=city.country_id and city.city_id=address.city_id
	and address.address_id=customer.address_id
		GROUP BY country.country_id, city.city_id
		having count (customer.customer_id)> 1 
		
-- Optimization v1, no indexes need to be used (AVG (Addition of Planning time + Execution time per execution) = 2.9055 ms)
WITH cte 
AS (
    SELECT city.country_id
    FROM customer
    INNER JOIN address ON customer.address_id = address.address_id
    INNER JOIN city ON city.city_id = address.city_id
    GROUP BY city.city_id
    HAVING COUNT (customer.customer_id) > 1)
SELECT country.country
FROM cte
INNER JOIN country ON country.country_id = cte.country_id

-- Optimization v2 (Mariana PC)
-- Changes: joining city table after filtering results
--  Tested: using with cte vs using subquery


-- Fastest: Using subqueries
-- 1.2098 ms
explain analyze
select country.country
from 
	(
	Select address.city_id
	from public.customer inner join public.address on address.address_id = customer.address_id
	group by address.city_id
	having count(customer.customer_id) > 1
	) as filtered
inner join public.city on city.city_id = filtered.city_id
inner join public.country on country.country_id = city.country_id


-- Second fastest with cte
-- 1.2378 ms
explain analyze
with cte as (
		Select address.city_id
		from public.customer inner join public.address on address.address_id = customer.address_id
		group by address.city_id
		having count(customer.customer_id) > 1
	)

SELECT country.country
FROM cte
inner join public.city on city.city_id = cte.city_id
INNER JOIN country ON country.country_id = city.country_id
