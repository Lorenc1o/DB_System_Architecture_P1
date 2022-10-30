-- Indexes considered>
--CREATE INDEX idx_customer_id ON customer USING Hash(customer_id);
--CREATE INDEX inventrory_film_id ON inventory USING Hash (film_id);
--CREATE INDEX rental_inventory_id ON rental USING Hash (inventory_id);


-- just subqueries, except, with distinct in subquery
-- AVG time:14.5629
-- FASTEST

explain analyze
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

-- just subqueries, except, no distinct in subquery
-- AVG time: 19.4772

explain analyze
Select customer.customer_id, customer.last_name
from 
	(Select rental.customer_id
	from public.rental 
	EXCEPT
		SELECT rental.customer_id
		FROM (SELECT film.film_id
		from public.film
		where film.length >= 180) as longMovies 
		inner join public.inventory on longMovies.film_id = inventory.film_id
		inner join public.rental on rental.inventory_id = inventory.inventory_id) as shortMovies
inner join public.customer on shortMovies.customer_id = customer.customer_id


-- with, except, with distinct in subquery
-- AVG time: 17.8412

explain analyze
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
		SELECT distinct rental.customer_id
		FROM longMovies 
		inner join public.inventory on longMovies.film_id = inventory.film_id
		inner join public.rental on rental.inventory_id = inventory.inventory_id
	) as shortMovies
inner join public.customer on shortMovies.customer_id = customer.customer_id

-- with, except, no distinct in subquery
-- AVG time: 16.0283

explain analyze
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
inner join public.customer on shortMovies.customer_id = customer.customer_id

-- merge customer in where, just subqueries, except, with distinct in subquery
-- AVG time:17.5407

explain analyze
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
,public.customer 
where shortMovies.customer_id = customer.customer_id


-- merge customer in where, just subqueries, except, no distinct in subquery
-- AVG time: 19.6663

explain analyze
Select customer.customer_id, customer.last_name
from 
	(Select rental.customer_id
	from public.rental 
	EXCEPT
		SELECT rental.customer_id
		FROM (SELECT film.film_id
		from public.film
		where film.length >= 180) as longMovies 
		inner join public.inventory on longMovies.film_id = inventory.film_id
		inner join public.rental on rental.inventory_id = inventory.inventory_id) as shortMovies
,public.customer 
where shortMovies.customer_id = customer.customer_id

-- merge customer in where, with, except, with distinct in subquery
-- AVG time: 15.9008

explain analyze
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
		SELECT distinct rental.customer_id
		FROM longMovies 
		inner join public.inventory on longMovies.film_id = inventory.film_id
		inner join public.rental on rental.inventory_id = inventory.inventory_id
	) as shortMovies
,public.customer 
where shortMovies.customer_id = customer.customer_id

-- merge customer in where, with, except, no distinct in subquery
-- AVG time: 15.7921

explain analyse
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

-- original query
SELECT customer.customer_id, customer.last_name
FROM public.customer 
INNER JOIN public.rental ON rental.customer_id = customer.customer_id
INNER JOIN public.inventory ON inventory.inventory_id = rental.inventory_id
INNER JOIN public.film ON film.film_id = inventory.film_id
GROUP BY customer.customer_id
HAVING MAX(film.length) < 180;

/*
select a.customer_id, a.last_name
from (select d.film_id from public.film d having max(d.length) < 180) as Filtered
inner join public.inventory c ON c.film_id = Filtered.film_id
inner join public.rental b on b.inventory_id = c.inventory_id 
inner join public.customer a on b.customer_id = a.customer_id
group by a.customer_id
 

select 
a.customer_id, a.last_name
from public.customer a
inner join public.rental b on b.customer_id = a.customer_id
inner join public.inventory c ON c.inventory_id = b.inventory_id
inner join public.film d on d.film_id = c.film_id
group by 1
having max(d.length) < 180


--Initial query №2

SELECT country.country 
	FROM public.country, public.city, public.address, public.customer 
	where country.country_id=city.country_id and city.city_id=address.city_id
	and address.address_id=customer.address_id
		GROUP BY country.country_id, city.city_id
		having count (customer.customer_id)> 1 
		
--Initial query №3

WITH cte as (
Select customer.customer_id, customer.last_name, date(rental.return_date) as date
from public.customer
inner join public.rental on rental.customer_id = customer.customer_id
inner join public.inventory ON inventory.inventory_id = rental.inventory_id
inner join public.film on inventory.film_id = film.film_id
group by customer.customer_id, date
having count(rental.rental_id) >= 4) 
select cte.customer_id, cte.last_name
from cte
group by cte.customer_id, cte.last_name
having count(cte.date) > 1



--Initial query №4

select customer.customer_id, customer.last_name
from public.customer
inner join public.rental on rental.customer_id = customer.customer_id
inner join public.inventory ON inventory.inventory_id = rental.inventory_id
inner join public.film on inventory.film_id = film.film_id
inner join public.film_category on film_category.film_id = film.film_id
inner join public.category on category.category_id = film_category.category_id
group by 1
having count(distinct category.category_id) = (select count(category_id) from public.category)
		
*/

