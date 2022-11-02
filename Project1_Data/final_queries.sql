CREATE INDEX idx_customer_id ON customer USING Hash(customer_id);

CREATE INDEX inventrory_film_id ON inventory USING Hash (film_id);

CREATE INDEX rental_inventory_id ON rental USING Hash (inventory_id);


--Query №1

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


--Query №2

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


--Query №3

SELECT customer.customer_id, customer.last_name
FROM public.customer,
     (
      SELECT rental.customer_id, date(rental.return_date) AS date
      FROM public.rental
      GROUP BY rental.customer_id, date
      HAVING COUNT(rental.rental_id) >= 4 
		) as rent
	GROUP BY rent.customer_id, customer.customer_id, customer.last_name
	HAVING COUNT(rent.date) > 1 AND rent.customer_id = customer.customer_id;
	
	
--Query №4

SELECT customer.customer_id, customer.last_name
FROM public.film_category
INNER JOIN public.inventory ON inventory.film_id = film_category.film_id
INNER JOIN public.rental ON rental.inventory_id = inventory.inventory_id
INNER JOIN public.customer ON rental.customer_id = customer.customer_id
GROUP BY customer.customer_id, rental.customer_id
HAVING COUNT(DISTINCT film_category.category_id) = 
	(SELECT count(category_id) 
	 FROM public.category);
