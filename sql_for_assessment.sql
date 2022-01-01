-- STEP 1 create the customer_film_profile table

CREATE TABLE public.customer_film_profile
(
    customer_file_profile_id integer NOT NULL DEFAULT nextval('customer_film_profile_customer_file_profile_id_seq'::regclass),
    customer_id integer NOT NULL,
    all_rentals_description text COLLATE pg_catalog."default" NOT NULL,
    all_rentals_fulltext tsvector NOT NULL,
    CONSTRAINT customer_film_profile_pkey PRIMARY KEY (customer_file_profile_id),
    CONSTRAINT customer_film_profile_customer_id FOREIGN KEY (customer_id)
        REFERENCES public.customer (customer_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE public.customer_film_profile
    OWNER to postgres;

-- End of STEP 1

-- STEP 2 populate our customer_film_profile
INSERT INTO public.customer_film_profile
    SELECT
        nextval('customer_film_profile_customer_film_profile_id_seq'),
        c.customer_id,
        -- The next 2 agregation functions are the transformations
        string_agg(f.description, ' ') as agg_description,
        to_tsvector(string_agg(f.description, '')) as agg_fulltext
        FROM rental r
            JOIN inventory i ON r.inventory_id = i.inventory_id
            JOIN customer c ON c.customer_id = r.customer_id
            JOIN film f ON f.film_id = i.film_id
GROUP BY c.customer_id;

-- End of STEP 2

 -- Option update script
UPDATE public.customer_film_profile SET
    all_rentals_description = (
        SELECT string_agg(f.description, ' ') as agg_description
            FROM rental r
                    JOIN inventory i ON r.inventory_id = i.inventory_id
                    JOIN customer c ON c.customer_id = r.customer_id
                    JOIN film f ON f.film_id = i.film_id
            WHERE c.customer_id = new.customer_id
        ),
    all_rentals_fulltext = (
        SELECT to_tsvector(string_agg(f.description, '')) as agg_fulltext
            FROM rental r
                    JOIN inventory i ON r.inventory_id = i.inventory_id
                    JOIN customer c ON c.customer_id = r.customer_id
                    JOIN film f ON f.film_id = i.film_id
            WHERE c.customer_id = new.customer_id
        )
WHERE customer_id = new.customer_id;
    SELECT
        c.customer_id,
        -- The next 2 agregation functions are the transformations
        string_agg(f.description, ' ') as agg_description,
        to_tsvector(string_agg(f.description, '')) as agg_fulltext
        FROM rental r
            JOIN inventory i ON r.inventory_id = i.inventory_id
            JOIN customer c ON c.customer_id = r.customer_id
            JOIN film f ON f.film_id = i.film_id
WHERE c.customer_id 1;

-- STEP 3 Generate report of recommended movies

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

-- End of STEP 3

-- STEP 4 Report of mv for next recommended movie:

CREATE MATERIALIZED VIEW public.next_recommended_film
TABLESPACE pg_default
AS
 SELECT cfp.customer_id,
    ( SELECT film.film_id
           FROM film
          ORDER BY (ts_rank(film.fulltext, plainto_tsquery(cfp.all_rentals_description))) DESC
         LIMIT 1) AS film_id
   FROM customer_film_profile cfp
   WHERE cfp.customer_id BETWEEN 1 and 10
WITH DATA;

ALTER TABLE public.next_recommended_film
    OWNER TO postgres;

-- END of STEP 4 

-- STEP 5 Create trigger function:
CREATE FUNCTION public.update_customer_profile()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
BEGIN
UPDATE public.customer_film_profile SET
    all_rentals_description = (
        SELECT string_agg(f.description, ' ') as agg_description
            FROM rental r
                    JOIN inventory i ON r.inventory_id = i.inventory_id
                    JOIN customer c ON c.customer_id = r.customer_id
                    JOIN film f ON f.film_id = i.film_id
            WHERE c.customer_id = new.customer_id
        ),
    all_rentals_fulltext = (
        SELECT to_tsvector(string_agg(f.description, '')) as agg_fulltext
            FROM rental r
                    JOIN inventory i ON r.inventory_id = i.inventory_id
                    JOIN customer c ON c.customer_id = r.customer_id
                    JOIN film f ON f.film_id = i.film_id
            WHERE c.customer_id = new.customer_id
        )
WHERE customer_id = new.customer_id;
RETURN NEW;
END;
$BODY$;

ALTER FUNCTION public.update_customer_profile()
    OWNER TO postgres;

-- End of STEP 5 of trigger function

-- STEP 6 Create trigger on rental table

CREATE TRIGGER update_customer_profile
    AFTER INSERT
    ON public.rental
    FOR EACH ROW
    EXECUTE FUNCTION public.update_customer_profile();

-- End STEP 6

-- STEP 7 Insert to verify trigger

EXPLAIN ANALYZE INSERT INTO public.rental(
	rental_id, rental_date, inventory_id, customer_id, return_date, staff_id, last_update)
	VALUES (
		nextval('rental_rental_id_seq'),
		current_timestamp,
		2,
		1,
		current_timestamp,
		1,
		current_timestamp
	);

-- End of STEP 7

-- STEP 8 Stored procedure of recommendations
-- PROCEDURE: public.refresh_customer_profile()

-- DROP PROCEDURE public.refresh_customer_profile();

CREATE OR REPLACE PROCEDURE public.refresh_customer_profile()
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
TRUNCATE public.customer_film_profile;
INSERT INTO public.customer_film_profile
    SELECT
        nextval('customer_film_profile_customer_film_profile_id_seq'),
        c.customer_id,
        -- The next 2 agregation functions are the transformations
        string_agg(f.description, ' ') as agg_description,
        to_tsvector(string_agg(f.description, '')) as agg_fulltext
        FROM rental r
            JOIN inventory i ON r.inventory_id = i.inventory_id
            JOIN customer c ON c.customer_id = r.customer_id
            JOIN film f ON f.film_id = i.film_id
GROUP BY c.customer_id;
COMMIT;
REFRESH MATERIALIZED VIEW next_recommended_film;
END;
$BODY$;

-- END OF DEMO
