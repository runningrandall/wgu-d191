-- INSERT INTO public.customer_film_profile
--  		SELECT
-- 			nextval('customer_film_profile_customer_film_profile_id_seq'),
--  			c.customer_id,
--  			string_agg(f.description, ' ') as agg_description,
--  			to_tsvector(string_agg(f.description, '')) as agg_fulltext
--  			FROM rental r
--  				JOIN inventory i ON r.inventory_id = i.inventory_id
--  				JOIN customer c ON c.customer_id = r.customer_id
--  				JOIN film f ON f.film_id = i.film_id
-- 		GROUP BY c.customer_id;

SELECT
	f.title, 
	f.description, 
	ts_rank(f.fulltext, plainto_tsquery(cfp.all_rentals_description)) as similarity_score
FROM customer c
JOIN customer_film_profile cfp ON cfp.customer_id = c.customer_id
JOIN rental r ON r.customer_id = c.customer_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON f.film_id = i.film_id
WHERE 
	c.customer_id = 1
	AND f.film_id NOT IN (
		SELECT
			f.film_id
		FROM customer c2
		JOIN rental r ON r.customer_id = c.customer_id
		JOIN inventory i ON r.inventory_id = i.inventory_id
		JOIN film f ON f.film_id = i.film_id
		WHERE c2.customer_id = c.customer_id
	)
ORDER BY similarity_score DESC LIMIT 5;

104
985
679
31
313

3
22
44
70
159
174
204
228
243
294
308
315
316
317
317
341
480
490
539
579
611
663
663
709
764
766
814
875
924
929
982
997

	
-- SELECT
-- 	c.customer_id,
-- 	string_agg(f.description, ' ') as agg_description,
-- 	to_tsvector(string_agg(f.description, '')) as agg_fulltext
-- 	FROM rental r
-- 		JOIN inventory i ON r.inventory_id = i.inventory_id
-- 		JOIN customer c ON c.customer_id = r.customer_id
-- 		JOIN film f ON f.film_id = i.film_id
-- 	WHERE c.customer_id = 1
-- 	GROUP BY c.customer_id;

--  SELECT c.name AS category,
--     sum(p.amount) AS total_sales
--    FROM payment p
--      JOIN rental r ON p.rental_id = r.rental_id
--      JOIN inventory i ON r.inventory_id = i.inventory_id
--      JOIN film f ON i.film_id = f.film_id
--      JOIN film_category fc ON f.film_id = fc.film_id
--      JOIN category c ON fc.category_id = c.category_id
--   GROUP BY c.name
--   ORDER BY (sum(p.amount)) DESC;