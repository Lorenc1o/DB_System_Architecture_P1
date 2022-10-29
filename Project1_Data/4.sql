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


-- Optimized fastest query (index on customer.custoer_id included)
select customer.customer_id, customer.last_name
from public.customer,
public.film_category
inner join public.inventory ON inventory.film_id = film_category.film_id
inner join public.rental ON rental.inventory_id = inventory.inventory_id
group by customer.customer_id, rental.customer_id
having count(distinct film_category.category_id) = (select count(category_id) from public.category)  and rental.customer_id = customer.customer_id

/* Times in Mariana's PC
Planning time	1.031
Execution time	50.023
Planning time	1.123
Execution time	37.047
Planning time	1.239
Execution time	44.187
Planning time	1.194
Execution time	72.91
Planning time	1.133
Execution time	37.97
Planning time	1.072
Execution time	56.133
Planning time	1.121
Execution time	48.319
Planning time	1.088
Execution time	51.197
Planning time	1.022
Execution time	51.275
Planning time	1.172
Execution time	34.896

AVG (Addition of Planning time + Execution time per execution) = 49.5152 ms

*/
-- Other variantions tested> merging customer with inner join, using cte, starting joins from customer to film_Category. Join with film table and category table removed, no needed for the result.


-- joining the customer but starting from category seems to work a bit faster
SELECT customer.customer_id, customer.last_name
FROM public.film_category
INNER JOIN public.inventory ON inventory.film_id = film_category.film_id
INNER JOIN public.rental ON rental.inventory_id = inventory.inventory_id
INNER JOIN public.customer ON rental.customer_id = customer.customer_id
GROUP BY customer.customer_id, rental.customer_id
HAVING COUNT(DISTINCT film_category.category_id) = 
	(SELECT count(category_id) 
	 FROM public.category);
