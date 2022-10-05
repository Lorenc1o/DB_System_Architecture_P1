SELECT country.country 
	FROM public.country, public.city, public.address, public.customer 
	where country.country_id=city.country_id and city.city_id=address.city_id
	and address.address_id=customer.address_id
		GROUP BY country.country_id, city.city_id
		having count (customer.customer_id)> 1 