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
