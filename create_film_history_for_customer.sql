SELECT
	string_agg(f.description, ' ') as agg_description,
	to_tsvector(string_agg(f.description, '')) as agg_fulltext
	FROM rental r
		JOIN inventory i ON r.inventory_id = i.inventory_id
		JOIN customer c ON c.customer_id = r.customer_id
		JOIN film f ON f.film_id = i.film_id
	WHERE c.customer_id = 1;