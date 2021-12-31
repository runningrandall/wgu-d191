-- Table: public.customer_film_profile

-- DROP TABLE public.customer_film_profile;

CREATE TABLE public.customer_film_profile
(
    customer_film_profile_id integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    customer_id integer NOT NULL,
    all_rentals_description text COLLATE pg_catalog."default" NOT NULL,
    all_rentals_fulltext tsvector NOT NULL,
    CONSTRAINT fk_customers FOREIGN KEY (customer_id)
        REFERENCES public.customer (customer_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
)

TABLESPACE pg_default;

ALTER TABLE public.customer_film_profile
    OWNER to postgres;

COMMENT ON TABLE public.customer_film_profile
    IS 'Table of storing the aggregated film descriptions of a customer and their respective tsvector of the descriptions. From this we can match it against other movies.';
-- Index: fki_fk_customers

-- DROP INDEX public.fki_fk_customers;

CREATE INDEX fki_fk_customers
    ON public.customer_film_profile USING btree
    (customer_id ASC NULLS LAST)
    TABLESPACE pg_default;
