SELECT
	f.title, 
	f.description, 
	ts_rank(fulltext, plainto_tsquery(o.description)) as similarity
FROM film f, (SELECT film_id, description FROM film WHERE film_id = 1) as o 
WHERE f.film_id != o.film_id
ORDER BY similarity DESC LIMIT 5;