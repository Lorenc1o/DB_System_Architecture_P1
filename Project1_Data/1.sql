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
