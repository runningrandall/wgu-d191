SELECT
	f.film_id,
	f.title, 
	f.description,
	ts_rank(
		f.fulltext,
		plainto_tsquery(cfp.all_rentals_description)
	) as similarity_score
FROM 
	film f,
	(
		SELECT customer_id, all_rentals_description
		FROM customer_film_profile 
		WHERE customer_id = 1
	) as cfp
WHERE film_id NOT IN (SELECT f2.film_id
 		FROM customer c
		JOIN rental r ON r.customer_id = c.customer_id
 		JOIN inventory i ON r.inventory_id = i.inventory_id
 		JOIN film f2 ON f2.film_id = i.film_id
 		WHERE c.customer_id = cfp.customer_id)
ORDER BY similarity_score DESC LIMIT 5;