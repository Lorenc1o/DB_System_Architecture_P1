select 
a.customer_id, a.last_name
from public.customer a
inner join public.rental b on b.customer_id = a.customer_id
inner join public.inventory c ON c.inventory_id = b.inventory_id
inner join public.film d on d.film_id = c.film_id
group by 1
having max(d.length/60) < 3