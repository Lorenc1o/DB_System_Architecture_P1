--Initial query №1

select customer.customer_id, customer.last_name
from public.customer
inner join public.rental on rental.customer_id = customer.customer_id
inner join public.inventory ON inventory.inventory_id = rental.inventory_id
inner join public.film on film.film_id = inventory.film_id
group by 1
having max(length/60) < 3
