#Initial query №3

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

		