CREATE INDEX idx_customer_id ON customer USING Hash(customer_id);

CREATE INDEX inventrory_film_id ON inventory USING Hash (film_id);

CREATE INDEX rental_inventory_id ON rental USING Hash (inventory_id);


--Query №1

SELECT customer.customer_id, customer.last_name
FROM public.customer 
INNER JOIN public.rental ON rental.customer_id = customer.customer_id
INNER JOIN public.inventory ON inventory.inventory_id = rental.inventory_id
INNER JOIN public.film ON film.film_id = inventory.film_id
GROUP BY customer.customer_id
HAVING MAX(film.length) < 180;


--Query №2

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
INNER JOIN country ON country.country_id = cte.country_id;


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
FROM public.customer,
public.film_category
INNER JOIN public.inventory ON inventory.film_id = film_category.film_id
INNER JOIN public.rental ON rental.inventory_id = inventory.inventory_id
GROUP BY customer.customer_id, rental.customer_id
HAVING COUNT(DISTINCT film_category.category_id) = (SELECT count(category_id) FROM public.category)  AND rental.customer_id = customer.customer_id;