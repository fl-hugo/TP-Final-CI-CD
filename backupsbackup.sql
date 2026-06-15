--
-- PostgreSQL database dump
--

\restrict 8E3dxEoX177Z8C4EcBkZApvaJdxKfGcOiKbs1bevxVfACtNSuR3ZAq73M9Qqb0S

-- Dumped from database version 16.14
-- Dumped by pg_dump version 16.14

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: products; Type: TABLE; Schema: public; Owner: shoplite
--

CREATE TABLE public.products (
    id integer NOT NULL,
    name text NOT NULL,
    description text NOT NULL,
    price_cents integer NOT NULL,
    CONSTRAINT products_price_cents_check CHECK ((price_cents > 0))
);


ALTER TABLE public.products OWNER TO shoplite;

--
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: shoplite
--

CREATE SEQUENCE public.products_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.products_id_seq OWNER TO shoplite;

--
-- Name: products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: shoplite
--

ALTER SEQUENCE public.products_id_seq OWNED BY public.products.id;


--
-- Name: products id; Type: DEFAULT; Schema: public; Owner: shoplite
--

ALTER TABLE ONLY public.products ALTER COLUMN id SET DEFAULT nextval('public.products_id_seq'::regclass);


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: shoplite
--

COPY public.products (id, name, description, price_cents) FROM stdin;
1	Clavier compact	Clavier mecanique compact pour developpeur.	5990
2	Souris precision	Souris ergonomique pour poste de travail.	3490
3	Ecran 24 pouces	Ecran full HD pour environnement bureautique.	12990
\.


--
-- Name: products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: shoplite
--

SELECT pg_catalog.setval('public.products_id_seq', 3, true);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: shoplite
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- PostgreSQL database dump complete
--

\unrestrict 8E3dxEoX177Z8C4EcBkZApvaJdxKfGcOiKbs1bevxVfACtNSuR3ZAq73M9Qqb0S

