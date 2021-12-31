-- Table: public.customer_film_profile

-- DROP TABLE public.customer_film_profile;

CREATE TABLE public.customer_film_profile
(
    customer_film_profile_id integer NOT NULL DEFAULT nextval('customer_film_profile_customer_film_profile_id_seq'::regclass),
    customer_id integer NOT NULL,
    all_rentals_description text COLLATE pg_catalog."default" NOT NULL,
    all_rentals_fulltext tsvector NOT NULL,
    CONSTRAINT customer_film_profile_customer_id FOREIGN KEY (customer_id)
        REFERENCES public.customer (customer_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
)

TABLESPACE pg_default;

ALTER TABLE public.customer_film_profile
    OWNER to postgres;
-- Index: all_rentals_fulltext_idx

-- DROP INDEX public.all_rentals_fulltext_idx;

CREATE INDEX all_rentals_fulltext_idx
    ON public.customer_film_profile USING gist
    (all_rentals_fulltext)
    TABLESPACE pg_default;
-- Index: fki_customer_film_profile_customer_id

-- DROP INDEX public.fki_customer_film_profile_customer_id;

CREATE INDEX fki_customer_film_profile_customer_id
    ON public.customer_film_profile USING btree
    (customer_id ASC NULLS LAST)
    TABLESPACE pg_default;