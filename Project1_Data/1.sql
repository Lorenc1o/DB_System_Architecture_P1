--Initial query №1

select customer.customer_id, customer.last_name
from public.customer
inner join public.rental on rental.customer_id = customer.customer_id
inner join public.inventory ON inventory.inventory_id = rental.inventory_id
inner join public.film on film.film_id = inventory.film_id
group by 1
having max(film.length/60) < 3


-- Optimized fastest query with used indexes (AVG (Addition of Planning time + Execution time per execution) = 28.7992 ms)

CREATE INDEX idx_customer_id ON customer USING Hash(customer_id);

CREATE INDEX inventrory_film_id ON inventory USING Hash (film_id);

CREATE INDEX rental_inventory_id ON rental USING Hash (inventory_id);


SELECT customer.customer_id, customer.last_name
FROM public.customer 
INNER JOIN public.rental ON rental.customer_id = customer.customer_id
INNER JOIN public.inventory ON inventory.inventory_id = rental.inventory_id
INNER JOIN public.film ON film.film_id = inventory.film_id
GROUP BY customer.customer_id
HAVING MAX(film.length) < 180;


-- (in Mariana's PC) Optimized changing query structure, considering indexes mentioned above 

-- Algorithm changes made: Use subqueries to filter before joining.
-- Syntax versions tested:
-- -> Using subqueries vs With
-- -> Using inner joins vs merging in where statement
-- -> Using distinct vs not using distinct in subquery shortMovies


-- Fastest ( 14.5629 ms avg)
-- just subqueries, except, with distinct in subquery
Select customer.customer_id, customer.last_name
from 
	(Select rental.customer_id
	from public.rental 
	EXCEPT
		SELECT distinct rental.customer_id
		FROM (SELECT film.film_id
		from public.film
		where film.length >= 180) as longMovies 
		inner join public.inventory on longMovies.film_id = inventory.film_id
		inner join public.rental on rental.inventory_id = inventory.inventory_id) as shortMovies
inner join public.customer on shortMovies.customer_id = customer.customer_id






-- Second Fastest ( 14.5629 ms avg)
-- merge customer in where, with, except, no distinct in subquery
-- AVG time: 15.7921


With longMovies as	(
	SELECT film.film_id
	from public.film
	where film.length >= 180)
	
Select customer.customer_id, customer.last_name
from 
	(
	Select rental.customer_id
	from public.rental 
	EXCEPT
	SELECT rental.customer_id
	FROM longMovies 
	inner join public.inventory on longMovies.film_id = inventory.film_id
	inner join public.rental on rental.inventory_id = inventory.inventory_id
) as shortMovies
,public.customer 
where shortMovies.customer_id = customer.customer_id
