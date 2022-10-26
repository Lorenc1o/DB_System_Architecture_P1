--Initial query №2

SELECT country.country 
	FROM public.country, public.city, public.address, public.customer 
	where country.country_id=city.country_id and city.city_id=address.city_id
	and address.address_id=customer.address_id
		GROUP BY country.country_id, city.city_id
		having count (customer.customer_id)> 1 
		
-- Optimized fastest query, no indexes need to be used (AVG (Addition of Planning time + Execution time per execution) = 2.9055 ms)
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
