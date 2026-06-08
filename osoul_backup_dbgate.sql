--
-- PostgreSQL database dump
--


-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

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

--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: admins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admins (
    admin_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    username character varying(20),
    password text
);


--
-- Name: categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.categories (
    category_id integer NOT NULL,
    name character varying(50) NOT NULL,
    parent_id integer
);


--
-- Name: categories_category_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.categories_category_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: categories_category_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.categories_category_id_seq OWNED BY public.categories.category_id;


--
-- Name: cities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cities (
    city_id integer NOT NULL,
    name character varying(100) NOT NULL
);


--
-- Name: cities_city_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cities_city_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cities_city_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cities_city_id_seq OWNED BY public.cities.city_id;


--
-- Name: conditions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.conditions (
    condition_id integer NOT NULL,
    name character varying(10) NOT NULL
);


--
-- Name: conditions_condition_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.conditions_condition_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: conditions_condition_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.conditions_condition_id_seq OWNED BY public.conditions.condition_id;


--
-- Name: otps; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.otps (
    id integer NOT NULL,
    phone character varying(20) NOT NULL,
    otp_hash character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    used boolean DEFAULT false NOT NULL
);


--
-- Name: otps_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.otps_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: otps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.otps_id_seq OWNED BY public.otps.id;


--
-- Name: posts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.posts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    caption text,
    city_id integer NOT NULL,
    sale_type_id integer NOT NULL,
    category_id integer NOT NULL,
    is_direct boolean DEFAULT true NOT NULL,
    condition_id integer NOT NULL,
    building character varying(50),
    price numeric(12,2),
    rooms integer,
    toilets integer,
    land_area numeric(12,2),
    images text[],
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    user_id text NOT NULL,
    area character varying(50),
    viewscnt integer DEFAULT 0,
    overprice numeric(10,2),
    is_featured boolean,
    location public.geography(Point,4326),
    address text,
    public_ids text[] DEFAULT '{}'::text[] NOT NULL
);


--
-- Name: sale_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sale_types (
    sale_type_id integer NOT NULL,
    name character varying(10) NOT NULL
);


--
-- Name: sale_types_sale_type_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sale_types_sale_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sale_types_sale_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sale_types_sale_type_id_seq OWNED BY public.sale_types.sale_type_id;


--
-- Name: saved_posts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.saved_posts (
    user_id text NOT NULL,
    post_id uuid NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    user_id text NOT NULL,
    user_phone character varying(20) NOT NULL,
    user_type character varying(20) NOT NULL,
    hashed_pass character varying(150),
    full_name_en character varying(120),
    full_name_ar character varying(120),
    commercial_registeration character varying(30),
    company_name_en character varying(120),
    company_name_ar character varying(120),
    is_active boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    address text,
    pending boolean DEFAULT true,
    CONSTRAINT users_user_type_check CHECK (((user_type)::text = ANY (ARRAY[('individual'::character varying)::text, ('business'::character varying)::text])))
);


--
-- Name: categories category_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories ALTER COLUMN category_id SET DEFAULT nextval('public.categories_category_id_seq'::regclass);


--
-- Name: cities city_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cities ALTER COLUMN city_id SET DEFAULT nextval('public.cities_city_id_seq'::regclass);


--
-- Name: conditions condition_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conditions ALTER COLUMN condition_id SET DEFAULT nextval('public.conditions_condition_id_seq'::regclass);


--
-- Name: otps id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.otps ALTER COLUMN id SET DEFAULT nextval('public.otps_id_seq'::regclass);


--
-- Name: sale_types sale_type_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sale_types ALTER COLUMN sale_type_id SET DEFAULT nextval('public.sale_types_sale_type_id_seq'::regclass);


--
-- Data for Name: admins; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.admins VALUES ('efa8f22b-daa1-4e48-9ebd-97913d8cb3a3', 'ibrahim', '$2b$10$uQu.1gNuRwpDIexZTd.RWuoxRKaedJtS8hOJyMcQm82wnBL9A8wJ6');


--
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.categories VALUES (1, 'Commercial', NULL);
INSERT INTO public.categories VALUES (2, 'Residential', NULL);
INSERT INTO public.categories VALUES (3, 'Company', 1);
INSERT INTO public.categories VALUES (4, 'Project', 1);
INSERT INTO public.categories VALUES (5, 'Goods', 1);
INSERT INTO public.categories VALUES (6, 'Factory', 1);
INSERT INTO public.categories VALUES (8, 'Brands', 1);
INSERT INTO public.categories VALUES (9, 'Service', 2);
INSERT INTO public.categories VALUES (10, 'Living', 2);
INSERT INTO public.categories VALUES (11, 'Office', 9);
INSERT INTO public.categories VALUES (12, 'Market', 9);
INSERT INTO public.categories VALUES (13, 'Service Building', 9);
INSERT INTO public.categories VALUES (14, 'Service Villa', 9);
INSERT INTO public.categories VALUES (15, 'Land (Svc)', 9);
INSERT INTO public.categories VALUES (16, 'Store', 9);
INSERT INTO public.categories VALUES (17, 'Apartment', 10);
INSERT INTO public.categories VALUES (18, 'Villa', 10);
INSERT INTO public.categories VALUES (19, 'Land (Liv)', 10);
INSERT INTO public.categories VALUES (20, 'Building', 10);
INSERT INTO public.categories VALUES (21, 'Chalet', 10);
INSERT INTO public.categories VALUES (22, 'Farm', 10);
INSERT INTO public.categories VALUES (23, 'Manors', 10);
INSERT INTO public.categories VALUES (7, 'Stock', 1);


--
-- Data for Name: cities; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.cities VALUES (1, 'Doha');
INSERT INTO public.cities VALUES (2, 'Al Rayyan');
INSERT INTO public.cities VALUES (3, 'Umm Salal');
INSERT INTO public.cities VALUES (4, 'Al Khawr wa adh Dhakhira');
INSERT INTO public.cities VALUES (5, 'Al Wakrah');
INSERT INTO public.cities VALUES (6, 'Al Daayen');
INSERT INTO public.cities VALUES (7, 'Al Shamal');
INSERT INTO public.cities VALUES (8, 'Al Shahaniyah');


--
-- Data for Name: conditions; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.conditions VALUES (1, 'new');
INSERT INTO public.conditions VALUES (2, 'used');
INSERT INTO public.conditions VALUES (3, 'old');


--
-- Data for Name: otps; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: posts; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.posts VALUES ('82277f44-c4db-4102-bfb1-6678ed871a0e', 'ط§ط±ط¶ ظ„ظ„ط¨ظٹط¹ ظپظٹ ط±ظˆط¶ط© ط§ظ„ظ…ط·ط§ط± ظ…ظˆظ‚ط¹ ظ…ظ†طھط§ط² ط´ط§ط±ط¹ ظˆط³ظƒظ‡', 1, 2, 19, true, 1, 'ط§ط±ط¶ ظپط¶ط§ط،', 2.40, 1, 1, 650.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1751223395/h29tu9jotvigbgsckoxd.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1751223395/ewebmyswvnjxikj8040x.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1751223395/tcd0go2txkxrqrpt6wdi.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1751223395/mbphpli3zmxr4qq0rdea.jpg}', '2025-06-29 18:56:36.821244', '2025-06-29 18:56:36.821244', 'f5002ca7-cefd-46b9-9897-a99512b09969', 'ط±ظˆط¶ط© ط§ظ„ظ…ط·ط§ط±', 682, NULL, NULL, NULL, NULL, '{}');
INSERT INTO public.posts VALUES ('278f5c69-242d-42e5-82ad-359b73e2d63f', '
ظپظٹظ„ط§ ظپظٹ ط§ظ… ظ‚ط±ظ† ظ„ظ„ط§ظٹط¬ط§ط± 
ظ…ط³ط§ط­ط© ط§ظ„ط¨ظ†ظٹط§ظ† 460 ظ…طھط± 
ظ¨ ط؛ط±ظپ ظˆطµط§ظ„ط© ظˆظ…ط¬ظ„ط³ ط¯ط§ط®ظ„ظ‰ ظˆظ…ظ„ط­ظ‚ ط®ط§ط±ط¬ظ‰. 

ظ…ط·ظ„ظˆط¨ ظ،ظ¢  ط£ظ„ظپ ط±ظٹط§ظ„
', 6, 1, 18, false, 2, 'ط§ظ… ظ‚ط±ظ† ', 12000.00, 8, 5, 460.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1761403325/uploads/cu5lfikvzb2q49q9d9vj.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1761403325/uploads/r3qzw7hwl02zsuq8tem5.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1761403326/uploads/lsqtvlwbayaswcgq3axc.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1761403325/uploads/c6ynkbrbdudngralojyu.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1761403325/uploads/nlsygiefwpje1qufzaip.jpg}', '2025-10-25 14:42:07.940626', '2025-10-25 14:42:07.940626', '00008d13-0bba-4508-b679-1fdee2890c14', 'ط§ظ… ظ‚ط±ظ† ', 1007, NULL, NULL, NULL, NULL, '{uploads/r3qzw7hwl02zsuq8tem5,uploads/cu5lfikvzb2q49q9d9vj,uploads/lsqtvlwbayaswcgq3axc,uploads/c6ynkbrbdudngralojyu,uploads/nlsygiefwpje1qufzaip}');
INSERT INTO public.posts VALUES ('82050a33-47cd-4704-b6df-4d941b6026c4', 'ظ„ظ„ط§ظٹط¬ط§ط± ظ…ظƒطھط¨ ط¨ط¨ط±ظƒظ‡ ط§ظ„ط¹ظˆط§ظ…ط± ظ…ط³ط§ط­ظ‡ ظ©ظ  ظ…طھط± ظ…ط·ظ„ظˆط¨ ظ¢ظ¨ظ ظ  ط±ظٹط§ظ„', 5, 1, 3, false, 2, 'ط¨ط±ظƒظ‡ ط§ظ„ط¹ظˆط§ظ…ط±', 2800.00, 3, 2, 50.00, '{}', '2025-06-29 08:10:18.020401', '2025-06-29 08:10:18.020401', 'c39d7df4-4abb-4f74-8d95-b9311f628611', 'ط¨ط±ظƒظ‡ ط§ظ„ط¹ظˆط§ظ…ط±', 329, NULL, NULL, NULL, NULL, '{}');
INSERT INTO public.posts VALUES ('a63644ed-0c88-4562-99c7-ec7766d39cc0', 'ظ„ظ„ط¨ظٹط¹ ط£ط±ط§ط¶ظٹ ظپظٹ ط§ظ„ط±ظˆظٹط³ ط£ط³ط¹ط§ط± ظ…طھظپط§ظˆطھظ‡ 
ط§ظ„ظپظˆطھ ظ…ظ† ظ،ظ¤ظ¥ ط¥ظ„ظ‰ ظ،ظ¥ظ¥ 
ظ…ط³ط§ط­ط§طھ ظ…ظ† ظ©ظ¥ظ  ظ„ظٹظ† ظ،ظ،ظ¥ظ ', 7, 2, 19, true, 1, '', 1400000.00, NULL, NULL, 960.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1763244725/uploads/cminhoypeht4xkgfwfbi.jpg}', '2025-11-15 22:12:06.014843', '2025-11-15 22:12:06.014843', '801ae98c-66a3-40b6-a34b-9192d248636f', 'ط§ظ„ط±ظˆظٹط³', 479, NULL, NULL, NULL, NULL, '{uploads/cminhoypeht4xkgfwfbi}');
INSERT INTO public.posts VALUES ('ad984bba-787a-4c6e-8fba-09ca3066998f', 'ظ„ظ„ط¨ظٹط¹ ظپظٹظ„ط§ ظپظ‰ ط§ظ„ط®ظٹط³ظ‡ 
ط®ظ„ظپ ط§ظ„ظپظٹط³طھظٹظپط§ظ„ 
ظ…ط³ط§ط­ظ‡ ظ¥ظ¦ظ  ظ…طھط±  
طھطھظƒظˆظ† ظ…ظ† :
ط§ظ„ط¯ظˆط± ط§ظ„ط§ط±ط¶ظٹ  
ط؛ط±ظپط© ط³ط§ط¦ظ‚ 
طµط§ظ„ط§طھ ظ…ظپطھظˆط­ط©  + ظ…ط¬ظ„ط³ ط¯ط§ط®ظ„ظٹ 
ظˆط؛ط±ظپط©  ظ†ظˆظ…  ظˆظ…ط·ط¨ط® ط¯ط§ط®ظ„ظٹ  
ط§ظ„ط¯ظˆط± ط§ظ„ط§ظˆظ„ : 
طµط§ظ„ظ‡  + ظ¤ ط؛ط±ظپ ظ†ظˆظ… ظ…ط§ط³طھط± 
ط§ظ„ط¨ظ†طھ ظ‡ط§ظˆط³ 
طµط§ظ„ظ‡ + ط؛ط±ظپطھظٹظ† ظ†ظˆظ… ظ…ط§ط³طھط± 
ط§ظ„ظ…ظ„ط­ظ‚ 
ظ…ط·ط¨ط® ظˆط؛ط±ظپظ‡ ط®ط§ط¯ظ…ظ‡

ظ…ط·ظ„ظˆط¨  :   4.700.000', 1, 2, 18, false, 1, 'ط§ظ„ط®ظٹط³ظ‡', 4700000.00, 7, 5, 560.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1769168995/uploads/uhfkzwityjtnsjtghhja.jpg}', '2026-01-23 11:49:56.389006', '2026-01-23 11:49:56.389006', '00008d13-0bba-4508-b679-1fdee2890c14', 'ط§ظ„ط®ظٹط³ظ‡', 796, NULL, NULL, NULL, NULL, '{uploads/uhfkzwityjtnsjtghhja}');
INSERT INTO public.posts VALUES ('a0bdc4dc-ed5b-4d9d-ae94-42ca94a4fa3e', 'ظپط±طµظ‡ ظ„ظ„ط§ط³طھط«ظ…ط§ط± 
ظ£ظ  ط§ظ„ظپ ط±ظٹط§ظ„ ط´ظٹظƒ ظˆط§ط­ط¯ ط´ظ‡ط±ظٹط§
ظ„ظ„ط¨ظٹط¹ ظپظ„طھظٹظ† ظ…طھظ„ط§طµظ‚ط§طھ ظپظٹ ط§ظ„ط±ظٹط§ظ† ظ§ظ¥ظ  ظ… ظ…ظˆظ‚ط¹ ظ…ظ…طھط§ط² ط¬ط¯ط§
ط®ظ„ظپ ط´ ط§ظ„ ط´ط§ظپظٹ 
 ظƒظ„ ظپظٹظ„ط§  ظ¦ ط؛ط±ظپ ظ†ظˆظ… ظˆطµط§ظ„ظ‡ ظˆظ…ط·ط¨ط® ظˆظ…ط¬ظ„ط³
 ظ…ط¤ط¬ط±ظٹظ† ط¹ظˆط§ط¦ظ„ 
 ط¹ظ‚ط¯ ظ£ ط³ظ†ظˆط§طھ', 2, 2, 18, false, 2, 'ط§ظ„ط±ظٹط§ظ†', 4500000.00, 7, 5, 748.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1758493036/uploads/fkmmfgemsgynkconsmul.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1758493036/uploads/ccbpb4xplngv7rlzip75.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1758493036/uploads/w6jqgpqrmzrlvqowgypn.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1758493036/uploads/ttsthrf9cltudgk63pwr.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1758493036/uploads/iocy8z3nbj7kconmaafy.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1758493036/uploads/h4m7g2g738xykf8jrnva.jpg}', '2025-09-21 22:17:18.224309', '2025-09-21 22:17:18.224309', '00008d13-0bba-4508-b679-1fdee2890c14', 'ط§ظ„ط±ظٹط§ظ†', 872, NULL, NULL, NULL, NULL, '{uploads/fkmmfgemsgynkconsmul,uploads/w6jqgpqrmzrlvqowgypn,uploads/ccbpb4xplngv7rlzip75,uploads/h4m7g2g738xykf8jrnva,uploads/ttsthrf9cltudgk63pwr,uploads/iocy8z3nbj7kconmaafy}');
INSERT INTO public.posts VALUES ('dc60e9c7-d842-443d-935d-59864bcc5dc9', 'ظ„ظ„ط§ط³طھط«ظ…ط§ط± ظپظ‰ ظ…ظˆظ‚ط¹ ظ…ظ…ظٹط² 
ظپظٹظ„ط§ ظ…ط¤ط¬ط±ظ‡ ظ„ظ„ط¨ظٹط¹ 
ظپظ‰ ط§ظ„ط®ظٹط³ظ‡ ط®ظ„ظپ ط§ظ„ظپظٹط³طھظپط§ظ„ ط¹ظ„ظ‰ ط´ط§ط±ط¹ظٹظ† ط§ظ…ط§ظ…ظ‰ ظˆط®ظ„ظپظ‰ 
ظ…ط³ط§ط­ظ‡ ظ¤ظ¤ظ¦ ظ…طھط± ', 6, 2, 18, false, 2, 'ط§ظ„ط®ظٹط³ظ‡', 2900000.00, 7, 5, 448.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1777650349/uploads/oiedztxbwx2hr649bwlq.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1777650349/uploads/nvjbol1m7p3umrusmdm4.jpg}', '2026-05-01 15:45:51.219303', '2026-05-01 15:45:51.219303', '00008d13-0bba-4508-b679-1fdee2890c14', 'ط§ظ„ط®ظٹط³ظ‡', 3, NULL, NULL, NULL, NULL, '{uploads/nvjbol1m7p3umrusmdm4,uploads/oiedztxbwx2hr649bwlq}');
INSERT INTO public.posts VALUES ('7b7a8d1d-4c6f-481f-9403-dff0f1d415ca', 'ظ„ظ„ط¨ظٹط¹ ط§ط±ط¶ ط¨ط§ظ… طµظ„ط§ظ„ ظ…ط­ظ…ط¯ ظ…ط³ط§ط­ط§طھ ظ…ط®طھظ„ظپط© ط³ط¹ط± ط§ظ„ظپظˆطھ 330 ط±ظٹط§ظ„ ظ…ظˆظ‚ط¹ ظ…ظ…طھط§ط² ', 3, 2, 19, false, 1, 'ط§ظ… طµظ„ط§ظ„ ظ…ط­ظ…ط¯ ', 3000000.00, 8, 5, 850.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1751926090/uploads/ewtu7r3cfzuxewux9l0d.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1751926090/uploads/niuwqzvcoldybie2hjwj.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1751926091/uploads/yrb5zykwv2qk2t0hmokc.jpg}', '2025-07-07 22:08:12.218865', '2025-07-07 22:08:12.218865', '69e24c97-9e3a-495b-9553-21aaf6731354', 'ط§ظ… طµظ„ط§ظ„ ظ…ط­ظ…ط¯ ', 712, NULL, NULL, NULL, NULL, '{}');
INSERT INTO public.posts VALUES ('7de33174-135a-46a7-8efc-a928804fc685', '*ظ„ظ„ط¨ظٹط¹ 

ظپظٹظ„ط§ ط¹ظ„ظ‰ ط®ط· ط§ظ„ط´ظ…ط§ظ„ ط¬ظ†ط¨ ط§ظٹظƒظٹط§ ظ…ط¨ط§ط´ط±ظ‡ ط¹ظ„ظ‰ ط´ط§ط±ط¹ظٹظ† ط²ط§ظˆظٹط© .

ظپظٹظ„ط§ ط®ط¯ظ…ظٹط©  640 ظ…طھط± ظپط§ط¶ظٹط©
 ط¹ظ…ط± ط§ظ„ط¨ظ†ط§ط، ط³ظ†طھظٹظ†.

ظ…ط·ظ„ظˆط¨ 6طŒ000طŒ000  ط±ظٹط§ظ„', 6, 2, 18, false, 1, 'ط§ظ„ط®ظٹط³ظ‡', 6000000.00, 7, 5, 640.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1756664590/uploads/fpj1eoi3fd5jef9m9f4y.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1756664590/uploads/rvzjibvflt5ljpzpsmfh.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1756664590/uploads/xoe5zoxv96porg1yi4nq.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1756664590/uploads/zk6i5ypdl06mnxzfeuvt.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1756664590/uploads/dyveopj6mzj9ip5ytnds.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1756664590/uploads/oit4vokktvccnon3tmrq.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1756664590/uploads/f6nrucuqfdeilkn96txp.jpg}', '2025-08-31 18:23:12.881186', '2025-08-31 18:23:12.881186', '00008d13-0bba-4508-b679-1fdee2890c14', 'ط§ظ„ط®ظٹط³ظ‡ ', 1289, NULL, NULL, NULL, NULL, '{uploads/fpj1eoi3fd5jef9m9f4y,uploads/rvzjibvflt5ljpzpsmfh,uploads/f6nrucuqfdeilkn96txp,uploads/zk6i5ypdl06mnxzfeuvt,uploads/xoe5zoxv96porg1yi4nq,uploads/dyveopj6mzj9ip5ytnds,uploads/oit4vokktvccnon3tmrq}');
INSERT INTO public.posts VALUES ('96d075e5-8f1a-4de1-85e8-805f98bc5199', '', 6, 2, 18, false, 2, '1', 5200000.00, 1, 1, 1204.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1752264361/uploads/unfibw2yqhfpdbyut7fe.jpg}', '2025-07-11 20:06:02.500205', '2025-07-11 20:06:02.500205', '0b84d6dd-a098-4d39-a6e5-e1dc95b64c0c', 'ط§ظ„ط®ظٹط³ظ‡ ', 697, NULL, NULL, NULL, NULL, '{}');
INSERT INTO public.posts VALUES ('80911cea-cc06-414a-a260-14f2232312c8', 'ط§ظ„ط³ظ„ط§ظ… ط¹ظ„ظٹظƒظ… ظ„ظ„ط¨ظٹط¹ ط§ط±ط¶ ط­ط²ظˆظ… ظ„ظˆط³ظٹظ„ ظ¤ظ ظ  ظ… ط§ظ„ط³ط¹ط± ط§ظ„ظ…ط·ظ„ظˆط¨ *ظ…ظ„ظٹظˆظ† ظˆظ©ظ ظ  ط§ظ„ظپ*', 6, 2, 19, false, 1, 'ظ„ظˆط³ظٹظ„', 1900000.00, NULL, NULL, 400.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1761981442/uploads/lhiyebxbwvz0wbfde4qk.jpg}', '2025-11-01 07:17:23.681036', '2025-11-01 07:17:23.681036', '00008d13-0bba-4508-b679-1fdee2890c14', 'ظ„ظˆط³ظٹظ„', 525, NULL, NULL, NULL, NULL, '{uploads/lhiyebxbwvz0wbfde4qk}');
INSERT INTO public.posts VALUES ('5b989cc7-c3a3-4b62-b881-29f653c67acf', 'ط§ظ„ط³ظ„ط§ظ… ط¹ظ„ظٹظƒظ… ظˆط±ط­ظ…ظ‡ ط§ظ„ظ„ظ‡ ظˆط¨ط±ظƒط§طھظ‡ 
ظ„ظ„ط¨ظٹط¹ ظپظ„طھظٹظ† ظ…طھظ„ط§طµظ‚ط§طھ ظپظٹ ظپط±ظٹط¬ ط§ظ„ط³ظˆط¯ط§ظ† ظ…ظ‚ط§ط¨ظ„ ظ†ط§ط¯ظٹ ط§ظ„ط³ط¯ ظ…ط¨ط§ط´ط±ط©  ظ…ط³ط§ط­ط© 737 ظ… 
طھط´ط·ظٹط¨ ط±ط§ظ‚ظٹ ط¬ط¯ط§ظ‹ ظپظٹظ„ط§ ظ…ط¤ط¬ط±ط© ط¹ظ„ظٹ ظ…ط±ظƒط² 
ط·ط¨ظٹ ط¨  25 ط£ظ„ظپ ط±ظٹط§ظ„ ظˆط§ظ„ط«ط§ظ†ظٹط© ظ…ط¤ط¬ط±ط© ط¹ظ„ظ‰ طµط§ظ„ظˆظ† ط¨ 18 ط§ظ„ظپ ط±ظٹط§ظ„ 
ط¥ط¬ظ…ط§ظ„ظٹ  ط§ظ„ظ…ط¯ط®ظˆظ„ ط§ظ„ط´ظ‡ط±ظٹ 43 ط§ظ„ظپ', 1, 2, 14, false, 2, 'ظپط±ظٹط¬ ط§ظ„ط³ظˆط¯ط§ظ† ', 5700000.00, 10, 5, 737.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1777650502/uploads/cuybkmw07c5uxgzef9si.jpg}', '2026-05-01 15:48:23.434525', '2026-05-01 15:48:23.434525', '00008d13-0bba-4508-b679-1fdee2890c14', 'ظپط±ظٹط¬ ط§ظ„ط³ظˆط¯ط§ظ†', 2, NULL, NULL, NULL, NULL, '{uploads/cuybkmw07c5uxgzef9si}');
INSERT INTO public.posts VALUES ('6eef6caa-6f56-4e48-bc34-4f531eb8cf25', 'ظ„ظ„ط¨ظٹط¹ ظپظٹظ„ط§ ط§ظ„ط«ظ…ط§ظ…ظ‡ ط§ظ„ظ‚ط¯ظٹظ…ظ‡ 
ظ…ط³ط§ط­ظ‡ ط§ظ„ط§ط±ط¶ 426ظ… ظ…ط³ط§ط­ظ‡ ط§ظ„ط¨ظ†ط§ط، 557ظ…
ظ…ظ‚ط§ط¨ظ„ ط§ظ„ظ…ظٹط±ظ‡ ظ…ط¨ط§ط´ط±ظ‡ 
ظ…ظˆظ‚ط¹ ظ…ظ…طھط§ط² ط¬ط¯ط§ 

ط§ظ„ط¯ظˆط± ط§ظ„ط§ط±ط¶ظ‰ 
ظ…ط¬ظ„ط³ ط¯ط§ط®ظ„ظ‰ ظ…ط¹ ظ…ط؛ط§ط³ظ„ ظˆط­ظ…ط§ظ… 
طµط§ظ„ظ‡ ظ…ظ†ظپطµظ„ظ‡ ظ…ط¹ ظ…ط؛ط§ط³ظ„ ظˆط­ظ…ط§ظ… 
ط؛ط±ظپظ‡ ظ…ط§ط³طھط± ظˆظ…ط·ط¨ط® ط¯ط§ط®ظ„ظ‰ 

ط§ظ„ط¯ظˆط± ط§ظ„ط§ظˆظ„ 
4 ط؛ط±ظپ ظ…ط§ط³طھط± ظˆطµط§ظ„ظ‡ 

ط§ظ„ط¨ظ†طھ ظ‡ط§ظˆط³ 
ط؛ط±ظپطھظٹظ† ظ…ط§ط³طھط± ظˆطµط§ظ„ظ‡ ظƒط¨ظٹط±ظ‡ 

ط§ظ„ظ…ظ„ط­ظ„ظ‚ ط§ظ„ط®ط§ط±ط¬ظ‰ 
ظ…ط·ط¨ط® ط®ط§ط±ط¬ظ‰ 
ظˆط؛ط±ظپظ‡ ط®ط¯ط§ظ…ظ‡ 
ظˆظ…ط؛ط³ظ„ظ‡ ظ…ظ„ط§ط¨ط³ 

ظ…طµط¹ط¯ ط±ط§ظƒط¨ 
ط§ظ„ظپظٹظ„ط§ ط¬ط¨ط³ ط¨ظˆط±ط¯ ظƒط§ظ…ظ„ظ‡ 
ظˆط§ط¬ظ‡ظ‡ ظ…ظˆط¯ط±ظ† ط­ط¬ط± 
طھط´ط·ظٹط¨ ط³ظˆط¨ط± ط¯ظٹظ„ظˆظƒط³ 

ط؛ط±ظپظ‡ ط³ط§ط¦ظ‚ ط®ط§ط±ط¬ظٹظ‡

ظ…ظƒظٹظپط§طھ 

ظ…ط·ظ„ظˆط¨ 3 ظ…ظ„ظٹظˆظ† 800 ط§ظ„ظپ


طھظˆط§طµظ„ ظ…ط¹ظ†ط§ 
ظ…ط­ظ…ط¯ ط®ط§ط·ط± 
50067840
ظ…ط±ط³ط§ظ†ط§ ظ„ظ„ظˆط³ط§ط·ط© ط§ظ„ط¹ظ‚ط§ط±ظٹط© 
طھط±ط®ظٹطµ ظˆط²ط§ط±ظ‡ ط§ظ„ط¹ط¯ظ„ ط±ظ‚ظ… 54', 1, 2, 18, false, 1, 'ظپظٹظ„ط§ ط³ظƒظ†ظٹظ‡ ', 3800000.00, 7, 5, 426.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1762119088/uploads/tlkndnaumbzsaypjpn4j.jpg}', '2025-11-02 21:31:29.813983', '2025-11-02 21:31:29.813983', 'c0461100-60ce-404a-86a6-86610b5c2f89', 'ط§ظ„ط«ظ…ط§ظ…ظ‡ ', 331, NULL, NULL, NULL, NULL, '{uploads/tlkndnaumbzsaypjpn4j}');
INSERT INTO public.posts VALUES ('985b3a1d-a208-430c-9a3e-20b73578759a', '*ط§ظ„ط³ظ„ط§ظ… ط¹ظ„ظٹظƒظ… ظ„ظ„ط¨ظٹط¹ ظ…ظ† ط§ظ„ظ…ط§ظ„ظƒ ط¨ظٹطھ ط´ط¹ط¨ظٹ ظپظ‰ ظ…ط¹ظٹط°ط± ط§ظ„ظ…ط³ط§ط­ط© ظ¨ظ§ظ§ ظ… ط¹ظ„ظ‰ ط´ط§ط±ط¹ ط±ط¦ظٹط³ظٹ  ظ…ط¤ط¬ط± ط¨ ظ،ظ¢ ط£ظ„ظپ  ظ…ط·ظ„ظˆط¨ ظ¢ظ…ظ„ظٹظˆظ† ظˆ ظ©ظ¥ظ ط£ظ„ظپ*ظ‡ظˆ', 2, 2, 18, false, 2, 'ظ…ط¹ظٹط°ط± ', 2950000.00, 7, 5, 877.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1758092815/uploads/asimbzq0xcinoplnoi7h.jpg}', '2025-09-17 07:06:56.309063', '2025-09-17 07:06:56.309063', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'ظ…ط¹ظٹط°ط± ', 877, NULL, NULL, NULL, NULL, '{uploads/asimbzq0xcinoplnoi7h}');
INSERT INTO public.posts VALUES ('9ae78732-1117-4dc3-b94e-36a050ffb852', 'ط§ظ„ط³ظ„ط§ظ… ط¹ظ„ظٹظƒظ… 
ظ„ظ„ط¨ط¨ط¹ ط§ط±ط¶ ظ„ظ„ط¨ظٹط¹ ط§ط±ط¶ ط¨ط§ظ… طµظ„ط§ظ„ ط¹ظ„ظٹ
ظ…ط³ط§ط­طھظ‡ط§ 6250ظ…طھط±
ط¹ظ„ظٹ ط´ط§ط±ط¹ظٹظ† ط²ط§ظˆظٹط©
ظ…ط·ظ„ظˆط¨ ط§ظ„ظپظˆطھ 250ط±ظٹط§ظ„', 3, 2, 19, false, 1, 'ط§ط±ط¶', 17490000.00, 1, 1, 6250.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1753607498/uploads/fwtcgjwjhzbrengspgxt.jpg}', '2025-07-27 09:11:39.362537', '2025-07-27 09:11:39.362537', 'f660dd0b-f66c-406a-a688-e30374396930', 'ط§ظ… طµظ„ط§ظ„ ط¹ظ„ظٹ', 356, NULL, NULL, NULL, NULL, '{}');
INSERT INTO public.posts VALUES ('e70b30b5-15f4-4580-8bfc-68021b0b5c6b', '
ظپظٹظ„ط§ ظ„ظ„ط¨ظٹط¹ ظپظٹ ط§ظ„ط¯ط­ظٹظ„ ظ…ط³ط§ط­ظ‡ 841 ظ… ط®ظ„ظپ ط§ظ„ط±ظٹظپظٹط±ط§  ط¹ظ…ط±ظ‡ط§ 16 ط³ظ†ظ‡ 
طھطھظƒظˆظ† ظ…ظ† 
7 ط؛ط±ظپ ظ…ط§ط³طھط± 
ظˆظ…ط¬ظ„ط³ ط¯ط§ط®ظ„ظٹ ظ…ظ†ظپطµظ„ 
ظˆط¨ظ†طھ ظ‡ط§ظˆط³ 
ظˆطµط§ظ„طھظٹظ† ظˆظ…ظ„ط­ظ‚ ط®ط§ط±ط¬ظٹ 
ظˆظ…ط·ط¨ط® ط¯ط§ط®ظ„ظٹ 
ظˆظ…ظ„ط­ظ‚ ط®ط§ط±ط¬ظٹ 

ط§ظ„ظپظٹظ„ط§ ظپط§ط¶ظٹظ‡ ظˆط¬ط§ظ‡ط²ظ‡ ظ„ظ„ط§ط³طھظ„ط§ظ… 
ظ…ط·ظ„ظˆط¨ 4 ظ…ظ„ظٹظˆظ† ظˆ50 ط§ظ„ظپ 
ط¨ط³ط¹ط± ط§ظ„ط§ط±ط¶ ط§ظ„ظپظٹظ„ط§', 1, 2, 18, false, 2, 'ط§ظ„ط¯ط­ظٹظ„', 4050000.00, 7, 5, 841.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1761578564/uploads/ycwwd4x8fbrbn0s8hdnv.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1761578564/uploads/dutkbarfth5vlgzmkffw.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1761578564/uploads/bzpo8kaspr5b6gkrqshg.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1761578564/uploads/vsiytqcuyzfngkidw8np.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1761578564/uploads/nodriy1uupedyfm7x1nv.jpg}', '2025-10-27 15:22:45.982794', '2025-10-27 15:22:45.982794', '00008d13-0bba-4508-b679-1fdee2890c14', 'ط§ظ„ط¯ط­ظٹظ„', 496, NULL, NULL, NULL, NULL, '{uploads/vsiytqcuyzfngkidw8np,uploads/dutkbarfth5vlgzmkffw,uploads/bzpo8kaspr5b6gkrqshg,uploads/nodriy1uupedyfm7x1nv,uploads/ycwwd4x8fbrbn0s8hdnv}');
INSERT INTO public.posts VALUES ('6aa80bda-e80c-4cc1-9906-4af05885e20f', 'ًںڈ، ظ„ظ„ط¨ظٹط¹
ط£ط±ط¶ ظپظٹ ط§ظ… ظ‚ط±ظ† ط¹ظ„ظٹ ط´ط§ط±ط¹ظٹظ† ط²ظˆط§ظٹط©
â–ھï¸ڈ ط§ظ„ظ…ط³ط§ط­ط©: 569 ظ…طھط± 
ط§', 6, 2, 19, false, 1, 'ط§ظ… ظ‚ط±ظ†', 2050000.00, NULL, NULL, 569.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1777671487/uploads/ceoh5anabjzv89psphb4.jpg}', '2026-05-01 21:38:09.151736', '2026-05-01 21:38:09.151736', '00008d13-0bba-4508-b679-1fdee2890c14', 'ط§ظ… ظ‚ط±ظ†', 3, NULL, NULL, NULL, NULL, '{uploads/ceoh5anabjzv89psphb4}');
INSERT INTO public.posts VALUES ('a678a4de-bc9d-4e3a-acc3-3132185c56f3', 'ظ…ظ† ط§ظ„ظ…ط§ظ„ظƒ 
ظ„ظ„ط¨ظٹط¹ ط¨ظٹطھ ظپظٹ ط§ط¨ظˆط³ط¯ط±ظ‡ 906 ظ… 
ط§ظ„ط¨ظٹطھ ظپط§ط¶ظٹ 
ظ…ظˆظ‚ط¹ ظ…ظ…طھط§ط² ظ‚ط±ظٹط¨ ط´ط§ط±ط¹ ط§ظ„ظپط±ظˆط³ظٹظ‡ ط§ظ„ط±ط§ط¦ظٹط³ظٹ
ط§ظ„ظپظˆطھ 276 ط±ظٹط§ظ„ 
ظ…ط·ظ„ظˆط¨ 2700.000', 5, 2, 18, false, 3, 'ط§ط¨ظˆط³ط¯ط±ظ‡ ', 2700000.00, 7, 5, 906.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1758093174/uploads/tbcjjjksus2lxsohuycq.jpg}', '2025-09-17 07:12:55.384219', '2025-09-17 07:12:55.384219', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'ط§ط¨ظˆط³ط¯ط±ظ‡ ', 851, NULL, NULL, NULL, NULL, '{uploads/tbcjjjksus2lxsohuycq}');
INSERT INTO public.posts VALUES ('d5fd0e3d-c15b-4f64-afd8-52e7a485347b', 'ط§ظ„ط³ظ„ط§ظ… ط¹ظ„ظٹظƒظ…
ظ„ظ„ط¨ظٹط¹ ط¨ظٹطھ ط´ط¹ط¨ظٹ ط¨ط§ظ„ط±ظٹط§ظ†
ظ…ط³ط§ط­طھظ‡ 728 ظ…طھط±', 2, 2, 18, false, 3, 'ط¨ظٹطھ ط´ط¹ط¨ظٹ', 2200000.00, 5, 5, 728.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1753608619/uploads/eqkpymmbjerclhv8rmjr.jpg}', '2025-07-27 09:30:20.559492', '2025-07-27 09:30:20.559492', 'f660dd0b-f66c-406a-a688-e30374396930', 'ط§ظ„ط±ظٹط§ظ†', 930, NULL, NULL, NULL, NULL, '{}');
INSERT INTO public.posts VALUES ('88d10cda-9416-4ae3-8596-04e0bbe78720', '*ظ„ظ„ط¨ظٹط¹ *ظپظٹظ„ط§ ظ…ط¤ط¬ط±ظ‡

ظپظٹظ„ط§ ط¨ط§ظ„ط«ظ…ط§ظ…ط© ط§ظ„ط¬ط¯ظٹط¯ط© ظ…ظˆظ‚ط¹ ظ…ظ…طھط§ط² 
ط¹ظ„ظ‰ ط§ظ…طھط¯ط§ط¯ ظ…ظˆظ„ ط³ظƒظˆظٹط± 
ظ…ط³ط§ط­ط© ط§ظ„ظپظٹظ„ط§ ظ¤ظ¥ظ¥ ظ… 
ظ…ط¤ط¬ط±ط© ط¨ظ…ط¯ط®ظˆظ„ ط´ظ‡ط±ظ‰  ظ،ظ¢ظ ظ ظ   ط±ظٹط§ظ„ (ط¹ظ„ظ‰ ط´ط±ظƒط© طھظ‚ط³ظٹظ… )
ط¹ظ„ظ‰ ط´ط§ط±ط¹ظٹظ† ط²ط§ظˆظٹط© 
ظ…ظ†ظ‡ظ… ط´ط§ط±ط¹ ط®ط¯ظ…ظ‰ ط§ظ…طھط¯ط§ط¯ ط§ظ„ظ…ظˆظ„ 

*ط§طھظ…ط§ظ… ط§ظ„ط¨ظ†ط§ط، ظ¢ظ ظ،ظ¨ ظ…*

*ظ…ط·ظ„ظˆط¨ ظ¢.ظ©ظ ظ .ظ ظ ظ   ط±ظٹط§ظ„*', 1, 2, 18, false, 1, 'ط§ظ„ط«ظ…ط§ظ…ظ‡', 2900000.00, 7, 5, 455.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1762707341/uploads/vv74av1famjsqykwvgzh.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1762707341/uploads/zt21emfp8ivp6mq2td9f.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1762707341/uploads/xutvoglxiqfpmrojjort.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1762707341/uploads/pdmjhjqqwoxtxl2a8m3p.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1762707341/uploads/ijljfvmahu3jkxsbahtc.jpg}', '2025-11-09 16:55:43.509557', '2025-11-09 16:55:43.509557', '00008d13-0bba-4508-b679-1fdee2890c14', 'ط§ظ„ط«ظ…ط§ظ…ظ‡', 496, NULL, NULL, NULL, NULL, '{uploads/ijljfvmahu3jkxsbahtc,uploads/pdmjhjqqwoxtxl2a8m3p,uploads/vv74av1famjsqykwvgzh,uploads/xutvoglxiqfpmrojjort,uploads/zt21emfp8ivp6mq2td9f}');
INSERT INTO public.posts VALUES ('c018a5bb-b9f4-4ce1-a6fd-534ec9d113ab', 'ظ„ظ„ط¨ظٹط¹ 
ط³طھظˆط± ظپظ‰ ط¨ط±ظƒط© ط§ظ„ط¹ظˆط§ظ…ط±
ظ…ط³ط§ط­ط© ط§ظ„ط£ط±ط¶ 2000 ظ…طھط± 
ط§ظ„ظ…ط®ط²ظ† 1100 ظ…طھط± 
ظ…ط³ط§ط­ط© ط®ط§ط±ط¬ظٹط© ظƒط¨ظٹط±ط© ظ…ط¹ ط؛ط±ظپط© ط­ط§ط±ط³ 
ظˆط±ط®طµط© ط³ظƒظ† ط¹ظ…ط§ظ„ 12 ط؛ط±ظپط© 
ظٹظ…ظƒظ† طھط­ظˆظٹظ„ ط§ظ„ظ†ط´ط§ط· ظ„ط£ظ‰ ظ†ط´ط§ط· ط§ظ„ط§ ط§ظ„ظ†ط´ط§ط· ط§ظ„ظƒظٹظ…ظٹط§ط¦ظٹ 
ط±ط®طµط© ط®ط§ظ„طµظ‡ ظ…ظ† ط§ظ„ط¯ظپط§ط¹ ط§ظ„ظ…ط¯ظ†ظ‰
ط§ظ„ظ…ط³ط§ط­ط© ط§ظ„ظ…ط؛ط·ط§ط© 1000 ظ…طھط± 
ظ…ط·ظ„ظˆط¨ 3 ظ…ظ„ظٹظˆظ† 100 ط£ظ„ظپ', 8, 1, 13, false, 2, 'ط¨ط±ظƒط© ط§ظ„ط¹ظˆط§ظ…ط± ', 3100000.00, 1, 1, NULL, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1756058630/uploads/cwc9jwnh66eh9lotcb3g.jpg}', '2025-08-24 18:03:51.265951', '2025-08-24 18:03:51.265951', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'ط¨ط±ظƒط© ط§ظ„ط¹ظˆط§ظ…ط±', 1082, NULL, NULL, NULL, NULL, '{uploads/cwc9jwnh66eh9lotcb3g}');
INSERT INTO public.posts VALUES ('3631b9a9-4f46-4aa9-b4d8-edf279cba882', 'ظ„ظ„ط¨ظٹط¹ ط¨ظٹطھ ط´ط¹ط¨ظٹ ط¨ط§ظ„ظ…ط±ظ‡ ط§ظ„ط´ط±ظ‚ظٹظ‡ ط§ظ„ظ…ط³ط§ط­ظ‡ 1493ظ… ط§ظ„ط¨ظٹطھ ط¨ط­ط§ظ„ظ‡ ظ…ظ…طھط§ط²ظ‡ ظˆظ…ط¤ط¬ط± ط¨17ط§ظ„ظپ ط§ظ„ط¨ظٹطھ ظˆط§ط¬ظ‡طھظ‡ ظƒط¨ظٹط±ظ‡ 39ظ… ظٹطµظ„ط­ ظ„ظ„ظپط±ط² ط§ظˆ ط¨ظ†ط§ط، 3 ظپظ„ظ„ ظ…طھظ„ط§طµظ‚ظ‡ ط§ظ„ط¨ظٹط¹ ط¨ط³ط¹ط± ط§ظ„ط§ط±ط¶ ط³ط¹ط± ط§ظ„ظپظˆطھ 240 ط±ظٹط§ظ„ ظ†ظ‡ط§ط¦ظٹ ط؛ظٹط± ظ‚ط§ط¨ظ„', 2, 2, 18, false, 3, 'ط§ظ„ظ…ط±ط© ط§ظ„ط´ط±ظ‚ظٹط© ', 3856000.00, 7, 5, 1493.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1758443329/uploads/ui3dtijm1um9s81vills.jpg}', '2025-09-21 08:28:49.874942', '2025-09-21 08:28:49.874942', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'ط§ظ„ظ…ط±ط© ط§ظ„ط´ط±ظ‚ظٹط© ', 654, NULL, NULL, NULL, NULL, '{uploads/ui3dtijm1um9s81vills}');
INSERT INTO public.posts VALUES ('54d9df10-85cd-455a-a7fc-2baa1b892c5d', 'ظ„ظ„ط¨ظٹط¹ ظپظٹظ„ط§ ط¨ط§ظ… ظ‚ط±ظ† ظ¤ظ©ظ©ظ…طھط± ظˆط§ظ„ط¨ظ†ط§ط،ظ¥ظ¨ظ ظ…طھط±
ظˆط§ط¬ظ‡ط§طھ ط­ط¬ط±ط·ط¨ظٹط¹ظٹ 
طھط´ط·ظٹط¨ ط³ظˆط¨ط±ط¯ظٹظ„ظˆظƒط³
ط§ط³ط§ظ†ط³ظٹط± ط±ط§ظƒط¨
ظˆط§طµظ„ظ‡ ظ…ط§ط، ظˆظƒظ‡ط±ط¨ط§ط،
ظ‚ط±ظٹط¨ ط®ط· ط§ظ„ط´ظ…ط§ظ„
ط§ظ„ط¯ظˆط± ط§ظ„ط§ط±ط¶ظٹ ::
ظ…ط¬ظ„ط³ ط®ط§ط±ط¬ظ‰ ظ…ظ†ظپطµظ„
ط­ظˆط´ ظƒط¨ظٹط±
ظ…ط¬ظ„ط³ ط¯ط§ط®ظ„ظٹ ظ…ظپطھظˆط­ظ‡ ط¹ظ„ظ‰ ط§ظ„طµط§ظ„ظ‡ 
ظˆط؛ط±ظپطھظٹظ† ظ†ظˆظ…
ظˆط؛ط±ظپظ‡ ط·ط¹ط§ظ…
ط§ظ„ط¯ظˆط± ط§ظ„ط§ظˆظ„ ::
ظ¤ ط؛ط±ظپ ظ†ظˆظ… ظ…ط§ط³طھط±
ظˆطµط§ظ„ظ‡ 
ط§ظ„ط¨ظ†طھ ظ‡ط§ظˆظˆط³::
ط؛ط±ظپطھظٹظ† ظ†ظˆظ… ظ…ط§ط³طھط± ظˆطµط§ظ„ظ‡
ط§ظ„ظپظ„ظ„ ط¬ط¯ظٹط¯ظ‡ ط§ظˆظ„ ط³ط§ظƒظ†
ط¬ط§ظ‡ط²ظ‡ ظ„ظ„ط³ظƒظ† ظˆط§طµظ„ظ‡ ظ…ط§ط، ظˆظƒظ‡ط±ط¨ط§ط،


ظ…ط·ظ„ظˆط¨ ظ„ظ„ظپظٹظ„ط§  3 ظ…ظ„ظٹظˆظ† 350 ط§ظ„ظپ 


طھظˆط§طµظ„ ظ…ط¹ظ†ط§
ظ…ط­ظ…ط¯ ط®ط§ط·ط± 
50067840
ظ…ط±ط³ط§ظ†ط§ ظ„ظ„ظˆط³ط§ط·ظ‡ ط§ظ„ط¹ظ‚ط§ط±ظٹط©
طھط±ط®ظٹطµ ظˆط²ط§ط±ظ‡ ط§ظ„ط¹ط¯ظ„ ط±ظ‚ظ… 54
', 6, 2, 18, false, 1, 'ظپظٹظ„ط§ ط³ظƒظ†ظٹظ‡ ', 3350000.00, 7, 5, 499.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1762119614/uploads/rtn1nhu0wcyqglwzq0s5.jpg}', '2025-11-02 21:40:15.972252', '2025-11-02 21:40:15.972252', 'c0461100-60ce-404a-86a6-86610b5c2f89', 'ط§ظ… ظ‚ط±ظ† ', 423, NULL, NULL, NULL, NULL, '{uploads/rtn1nhu0wcyqglwzq0s5}');
INSERT INTO public.posts VALUES ('0d083aa7-a329-4353-b841-574919aeaf0d', 'ظ„ظ„ط¨ظٹط¹ ظ…ط¨ط§ط´ط± 

ط§ط±ط¶ ظپظٹ ظ…ط¯ظٹظ†ط© ط®ظ„ظٹظپط© ط§ظ„ط´ظ…ط§ظ„ظٹط© ظ…ط³ط§ط­ظ‡ 748ظ… ط¹ظ„ظٹ ط´ط§ط±ط¹ظٹظ† ط£ظ…ط§ظ…ظٹ ظˆط®ظ„ظپظٹ ظ…ظˆظ‚ط¹ ظ…ظ…طھط§ط² ط¬ط¯ط§ 
ظ…ظ‚ط§ط¨ظ„ ظ…ط±ظƒط² طµط­ظٹ ظ…ط¯ظٹظ†ط© ط®ظ„ظٹظپط© 

ظ…ط·ظ„ظˆط¨ ظ†ظ‡ط§ط¦ظٹ 

3.150.000', 1, 2, 19, false, 1, 'ظ…ط¯ظٹظ†ط© ط®ظ„ظٹظپط© ط§ظ„ط´ظ…ط§ظ„ظٹط© ', 3150000.00, NULL, NULL, 748.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1756836037/uploads/buydxoueltwi2sapnmps.jpg}', '2025-09-02 18:00:38.852382', '2025-09-02 18:00:38.852382', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'ظ…ط¯ظٹظ†ط© ط®ظ„ظٹظپط© ط§ظ„ط´ظ…ط§ظ„ظٹط© ', 842, NULL, NULL, NULL, NULL, '{uploads/buydxoueltwi2sapnmps}');
INSERT INTO public.posts VALUES ('5da6563b-1c48-49d3-a5b5-1ebc286d6f15', '
ظ„ظ„ط¨ظٹط¹ ظپظٹظ„ط§ ظپط®ظ…ط© ظپظٹ ظ…ظ†ط·ظ‚ط© ط§ظ… ظ‚ط±ظ†
ظ…ط³ط§ط­ط© ط§ظ„ط§ط±ط¶ ظ¤ظ©ظ© طھطµظ…ظٹظ… ظ…طµظ…ظ… ط³ط¹ظˆط¯ظٹ ط®ط±ط§ظٹط· ظ…طھظ…ظٹط²ظ‡ ظˆ طھط´ط·ظٹط¨ ط¹ط§ظ„ظٹ طµط§ظ„ط§طھ ظ…ظپطھظˆط­ط© ظ…ط¹ ظ…ظ„ط­ظ‚ ط®ط§ط±ط¬ظٹ ظˆ ظ…ط·ط¨ط® ط¯ط§ط®ظ„ظٹ ظˆ ط®ط§ط±ط¬ظٹ ط؛ط±ظپط© ط§ط³ط§ظ†ط³ظٹط± ظˆ ط«ظ„ط§ط« ط؛ط±ظپ ظ†ظˆظ… ظپظˆظ‚ ظˆ ط¨ظ†طھ ظ‡ط§ظˆط³ ظپظٹظ‡ط§ ط؛ط±ظپطھظٹظ† ظˆ ط؛ط±ظپط© ط³ط§ظٹظ‚ ظˆ ط؛ط±ظپط© ط´ط؛ط§ظ„ط§طھ ظ…ط³ط§ط­ط© ط§ظ„ط¨ظ†ط§ط، ظ¤ظ§ظ  ظˆ ط§ظ„ط³ط¹ط± ظ£ ظ…ظ„ظٹظˆظ† ظˆ ظ£ظ¥ظ  ظ†ظ‡ط§ط¦ظٹ', 6, 2, 18, false, 1, 'ط§ظ… ظ‚ط±ظ†', 3350000.00, 7, 5, 499.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1762593208/uploads/uhgkzqixtyvrpz6nqnlc.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1762593208/uploads/tmd6yhxaqini362eukco.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1762593208/uploads/pztthkuf8z66uuextcvs.jpg}', '2025-11-08 09:13:29.866596', '2025-11-08 09:13:29.866596', '00008d13-0bba-4508-b679-1fdee2890c14', 'ط§ظ… ظ‚ط±ظ† ', 468, NULL, NULL, NULL, NULL, '{uploads/uhgkzqixtyvrpz6nqnlc,uploads/pztthkuf8z66uuextcvs,uploads/tmd6yhxaqini362eukco}');
INSERT INTO public.posts VALUES ('20c3c516-3483-476c-b938-dfeaff50a92a', 'ظ„ظ„ط¨ظٹط¹ ظپظ„طھظٹظ† ظپظٹ ط§ظ… طµظ„ط§ظ„ ط¹ظ„ظٹ ظ…ط³ط§ط­ط© ط§ظ„ط§ط±ط¶ 450 ظ…طھط± ظˆظ…ط³ط§ط­ط© ط§ظ„ط¨ظ†ط§ط، 437 ظ…طھط±.. طµط§ظ„ط© ظˆظ…ط¬ظ„ط³ ظˆظ…ط·ط¹ظ…  ظˆط¹ط¯ط¯ 7 ط؛ط±ظپ 7 ط­ظ…ط§ظ…ط§طھ ظˆظ…ط·ط¨ط® ط®ط§ط±ط¬ظٹ  ظˆط؛ط±ظپط© ط؛ط³ظٹظ„ ظˆط؛ط±ظپط© ط®ط§ط¯ظ…ط© ظˆط؛ط±ظپط© ط³ط§ط¦ظ‚ 
ط§ظ„ظ…ظˆظ‚ط¹ ظ…ظ…ظٹط² ط¹ظ„ظٹ ط´ط§ط±ط¹ظٹظ† ط§ظ…ط§ظ…ظٹ ظˆ ط®ظ„ظپظٹ ط¨ط¬ط§ظ†ط¨ ط§ظ„ظ…ط³ط¬ط¯ 
ط§ظ„ط³ط¹ط± 3,100,000 ط±ظٹط§ظ„  
ظ‚ط§ط¨ظ„ ظ„ظ„ط¬ط§ط¯', 3, 2, 18, false, 1, 'ط§ظ… طµظ„ط§ظ„ ط¹ظ„ظ‰ ', 3100000.00, 8, 5, 450.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1756649899/uploads/q9rms0svg1clv3ndnkyy.jpg}', '2025-08-31 14:18:21.387122', '2025-08-31 14:18:21.387122', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'ط§ظ… طµظ„ط§ظ„ ط¹ظ„ظ‰ ', 1065, NULL, NULL, NULL, NULL, '{uploads/q9rms0svg1clv3ndnkyy}');
INSERT INTO public.posts VALUES ('e2c38e12-a684-4f5f-9584-ecdaddd07b57', 'ظ„ظ„ط¨ظٹط¹ ط¨ظٹطھ ط´ط¹ط¨ظ‰ ط¨ط£ظ… طµظ„ط§ظ„ ظ…ط­ظ…ط¯ ط´ط§ط±ط¹ظٹظ† ط²ط§ظˆظٹظ‡ ظ…ظˆظ‚ط¹ ظ…ظ…طھط§ط²   ظ…ط³ط§ط­ظ‡ 722ظ… ظ…ط¤ط¬ط± 16800 ط§ظ„ظƒظ‡ط±ظˆظ…ط§ط، 2000 ط±ظٹط§ظ„ ط´ظ‡ط±ظ‰ ط¹ظ„ظ‰ ط§ظ„ظ…ط§ظ„ظƒ طµط§ظپظ‰ ط§ظ„ط§ظٹط¬ط§ط± 14800 ظ…ط·ظ„ظˆط¨ 2500000 
', 3, 2, 19, false, 3, 'ط§ظ… طµظ„ط§ظ„ ظ…ط­ظ…ط¯ ', 2500000.00, NULL, NULL, 722.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1763568369/uploads/tenrgaa3i1ltxhnadesh.jpg}', '2025-11-19 16:06:11.240416', '2025-11-19 16:06:11.240416', '00008d13-0bba-4508-b679-1fdee2890c14', 'ط§ظ… طµظ„ط§ظ„ ظ…ط­ظ…ط¯ ', 443, NULL, NULL, NULL, NULL, '{uploads/tenrgaa3i1ltxhnadesh}');
INSERT INTO public.posts VALUES ('f069a3bf-2228-45f2-a9be-793edfe534eb', 'ظ„ظ„ط¨ظٹط¹ ط¨ظٹطھ ط´ط¹ط¨ظ‰ ظپظ‰ ط§ظ„ط¯ظپظ†ظ‡ 
ط¹ظ„ظ‰ ط´ط§ط±ط¹ ظˆط³ظƒظ‡ 
ظ…ظˆظ‚ط¹ ظ…ظ…ظٹط² ', 1, 2, 19, false, 3, 'ط§ظ„ط¯ظپظ†ظ‡', 3600000.00, NULL, NULL, 875.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1758495948/uploads/yxnf8exk1luc5cbcsesf.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1758495947/uploads/nc9w8d1h3nmxfn4bfbok.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1758495948/uploads/mcpaiz8dulfehtavoueh.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1758495947/uploads/go8n5a7ehj3kaznb5dao.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1758495947/uploads/tp6ffqfgit5ueqrhxuxc.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1758495948/uploads/l8kgizmalxeodeiokocc.jpg}', '2025-09-21 23:05:49.876712', '2025-09-21 23:05:49.876712', '00008d13-0bba-4508-b679-1fdee2890c14', 'ط§ظ„ط¯ظپظ†ظ‡', 682, NULL, NULL, NULL, NULL, '{uploads/tp6ffqfgit5ueqrhxuxc,uploads/go8n5a7ehj3kaznb5dao,uploads/l8kgizmalxeodeiokocc,uploads/nc9w8d1h3nmxfn4bfbok,uploads/mcpaiz8dulfehtavoueh,uploads/yxnf8exk1luc5cbcsesf}');
INSERT INTO public.posts VALUES ('7adb1c2c-41df-4bfe-b591-d2ba33207b3e', 'ظ„ظ„ط¨ظٹط¹ ظپظٹظ„ط§ ط§ظ… ظ‚ط±ظ† ظ£ظ§ظ¥ ط±ظٹط§ظ„ 
ظ¦ ط؛ط±ظپ ظˆظ…ط¬ظ„ط³ ظˆطµط§ظ„ظ‡ ظˆظ…ط·ط¨ط® ط®ط§ط±ط¬ظٹ ظˆظ…ظ„ط­ظ‚ ط®ط§ط±ط¬ظٹ 
ط¹ظ…ط±ظ‡ط§ ظ¨ ط³ظ†ظˆط§طھ 
ظ…ط·ظ„ظˆط¨ ظ¢ظ£ظ ظ ظ ظ ظ ', 6, 2, 18, false, 2, 'ط§ظ… ظ‚ط±ظ†', 2300000.00, 7, 5, 375.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1763572937/uploads/w8nv6c9kamquzhilpqat.jpg}', '2025-11-19 17:22:18.458455', '2025-11-19 17:22:18.458455', '00008d13-0bba-4508-b679-1fdee2890c14', 'ط§ظ… ظ‚ط±ظ†', 514, NULL, NULL, NULL, NULL, '{uploads/w8nv6c9kamquzhilpqat}');
INSERT INTO public.posts VALUES ('296f6b84-fbcb-4f7c-aecb-adf975a583f3', 'ط§ظ„ط³ظ„ط§ظ… ط¹ظ„ظٹظƒظ… 
ظ„ظ„ط¨ظٹط¹ ط§ط±ط¶ ط¨ ظ„ظˆط³ظٹظ„ ظˆظˆطھط±ظپط±ظˆظ†طھ  ط§ظ„ظˆط¬ظ‡ط© ط§ظ„ط¨ط­ط±ظٹط©
ظ…ط³ط§ط­طھظ‡ط§ 1500ظ…طھط± ط¹ظ„ظٹ ط´ط§ط±ط¹ظٹظ†', 6, 2, 19, false, 1, 'ط§ط±ط¶', 7500000.00, 1, 1, 1500.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1753607791/uploads/s7lfdnhmpn2miggmqjep.jpg}', '2025-07-27 09:16:32.079499', '2025-07-27 09:16:32.079499', 'f660dd0b-f66c-406a-a688-e30374396930', 'ظ„ظˆط³ظٹظ„', 276, NULL, NULL, NULL, NULL, '{}');
INSERT INTO public.posts VALUES ('85e59f59-7793-455c-8208-bb8ec1640ce8', 'ًں”¹ ظپظٹظ„ط§ ط±ط§ظ‚ظٹط© ظ„ظ„ط¨ظٹط¹ ظپظٹ ط§ظ„ط®ظٹط³ط©ًں”¹

âœ¨ ط§ظ„ظ…ظˆط§طµظپط§طھ:
ًںڈ، ط§ظ„ظ…ط³ط§ط­ط©:508ظ…آ² | ظ…ط³ط§ط­ط© ط§ظ„ط¨ظ†ط§ط،: 588 ظ…آ²
ًںڈ—ï¸ڈ طھطµظ…ظٹظ… ظپط±ظٹط¯ ظˆطھط´ط·ظٹط¨ ط³ظˆط¨ط± ط¯ظٹظ„ظˆظƒط³

ًں”¸ ط§ظ„ط®ط§ط±ط¬:
âœ… ظ…ط¬ظ„ط³ ط®ط§ط±ط¬ظٹ ظ…ط³طھظ‚ظ„
âœ… ظ…ظˆط§ظ‚ظپ ط³ظٹط§ط±ط§طھ ظˆط§ط³ط¹ط©
âœ…ط­ط¯ظٹظ‚ط© طµط؛ظٹط±ط© ظپظٹ ط§ظ„ط­ظˆط´ ط®ظ„ظپظٹ
âœ…ط؛ط±ظپط© ط³ط§ط¦ظ‚ ظ…ط¹ ط­ظ…ط§ظ… 
ًں”¸ ط§ظ„ط¯ظˆط± ط§ظ„ط£ط±ط¶ظٹ:
âœ… طµط§ظ„ط© ظƒط¨ظٹط±ط© ط¨طھطµظ…ظٹظ… ظپط§ط®ط±
âœ… ط؛ط±ظپطھط§ظ† ظ…ط§ط³طھط±
âœ… ظ…ط·ط¨ط® ط±ط¦ظٹط³ظٹ ظ…ط¬ظ‡ط²
âœ… ظ…ظ„ط­ظ‚ ط®ط§ط±ط¬ظٹ (ظ…ط·ط¨ط® ط¥ط¶ط§ظپظٹ + ط؛ط±ظپط© ط¨ط­ظ…ط§ظ… + ظ…ط®ط²ظ†)

ًں”¸ ط§ظ„ط¯ظˆط± ط§ظ„ط£ظˆظ„:
âœ… 4 ط؛ط±ظپ ظ…ط§ط³طھط± ظˆط§ط³ط¹ط©
âœ… طµط§ظ„ط© ط¹ط§ط¦ظ„ظٹط©
âœ… ط¨ظ„ظƒظˆظ†ط© ط¨ط¥ط·ظ„ط§ظ„ط© ط±ط§ط¦ط¹ط©

ًں”¸ ط§ظ„ط¨ظ†طھظ‡ط§ظˆط³:
âœ… ط؛ط±ظپطھط§ظ† ظ…ط§ط³طھط±
âœ… ط¨ط§ظ†طھط±ظٹ (ظ…ط·ط¨ط® طµط؛ظٹط±)

â‌„ï¸ڈ ط§ظ„طھظƒظٹظٹظپ: ظ„ظ„ظپظٹظ„ط§ ط¨ط§ظ„ظƒط§ظ…ظ„
ًںڈ، ط§ظ„طھط´ط·ظٹط¨: ط³ظˆط¨ط± ط¯ظٹظ„ظˆظƒط³ ط¨ظˆط§ط¬ظ‡ط§طھ ط­ط¬ط±ظٹط©
ًں“چ ط§ظ„ظ…ظˆظ‚ط¹: ظ…ظ…ظٹط² ط§ظ„ط®ظٹط³ط© 

ًں’° ط§ظ„ط³ط¹ط±: 4,350,000ط±ظٹط§ظ„', 2, 1, 18, false, 1, '', 4350000.00, 6, 5, 508.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1753570440/uploads/cd6odn2dabsksuxtxina.jpg}', '2025-07-26 22:54:01.394847', '2025-07-26 22:54:01.394847', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'ط§ظ„ط®ظٹط³ط© ', 911, NULL, NULL, NULL, NULL, '{}');
INSERT INTO public.posts VALUES ('9113bec1-3f00-49aa-8e91-320d9036f26c', 'ط§ظ„ط³ظ„ط§ظ… ط¹ظ„ظٹظƒظ…
ظ„ظ„ط¨ظٹط¹ ط§ط±ط¶ ط¨ط´ط¹ط¨ظٹط© ط®ظ„ظٹظپط©
ظ…ط³ط§ط­طھظ‡ط§ 607 ظ…طھط±', 2, 2, 19, false, 1, 'ط§ط±ط¶', 2500000.00, 1, 1, 607.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1753608434/uploads/rvjgqqeqn9mc4jifwjmd.jpg}', '2025-07-27 09:27:15.659161', '2025-07-27 09:27:15.659161', 'f660dd0b-f66c-406a-a688-e30374396930', 'ط´ط¹ط¨ظٹط© ط®ظ„ظٹظپط©', 469, NULL, NULL, NULL, NULL, '{}');
INSERT INTO public.posts VALUES ('e17039e4-51d0-4d57-896e-66f11d1c6c94', 'ظ„ظ„ط¨ظٹط¹ ط¨ظٹطھ ط´ط¹ط¨ظ‰ ظپظ‰ ظ…ط¹ظٹط²ط± ط§ظ„ط¬ظ†ظˆط¨ظ‰', 1, 1, 18, false, 3, '', 3700000.00, 6, 5, 1019.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1753558576/uploads/tjsmbfblel2kjfjmucjj.jpg}', '2025-07-26 19:36:17.261768', '2025-07-26 19:36:17.261768', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'ظ…ط¹ظٹط²ط± ط§ظ„ط¬ظ†ظˆط¨ظ‰', 783, NULL, NULL, NULL, NULL, '{}');
INSERT INTO public.posts VALUES ('908e646a-02e5-4970-94fb-e6c2b5f8aebd', 'ط§ظ„ط³ظ„ط§ظ… ط¹ظ„ظٹظƒظ… ظˆط±ط­ظ…ط© ط§ظ„ظ„ظ‡ ظˆط¨ط±ظƒط§طھظ‡ 
ظ„ظ„ط¥ظٹط¬ط§ط± ط§ط³طھظˆط±  
ظپظٹ ط¨ط±ظƒط© ط§ظ„ط¹ظˆط§ظ…ط± 
ظ…ط³ط§ط­ط© ط§ظ„ط§ط±ط¶ 1000 ظ… 
ظ…ط³ط§ط­ط© ط§ظ„ط·ط§ط¨ظ‚ ط§ظ„ط§ط±ط¶ظٹ 440 ظ…
ظ…ط³ط§ط­ط© ط§ظ„ط·ط§ط¨ظ‚  ط§ظ„ظ…ظٹط²ط§ظ†ظٹظ† 313 ظ…
ظٹطھظƒظˆظ† 
1-ط§ظ„ط§ط±ط¶ظٹ ظ…ط¹ط±ط¶+ظ…ظƒطھط¨ +ط­ظ…ط§ظ… 
2- ط·ط§ط¨ظ‚ ط§ظ„ط§ظˆظ„ ظ…ظƒط§طھط¨ ظ…ط¹ ط­ظ…ط§ظ…
3-  8 ط؛ط±ظپ 
4- 4 ط­ظ…ط§ظ…ط§طھ
5- 1 ظ…ط·ط§ط¨ط® 
6- ط؛ط±ظپط© ط­ط§ط±ط³ + ط­ظ…ط§ظ… +ظ…ط·ط¨ط®
ظ…ط·ظ„ظˆط¨ 18 ط£ظ„ظپ ط±ظٹط§ظ„', 5, 1, 13, false, 1, 'ط¨ط±ظƒط© ط§ظ„ط¹ظˆط§ظ…ط± ', 18000.00, 9, 5, 0.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1758361901/uploads/u3qsz742ga0tyomybmfi.jpg}', '2025-09-20 09:51:42.18912', '2025-09-20 09:51:42.18912', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'ط¨ط±ظƒط© ط§ظ„ط¹ظˆط§ظ…ط± ', 1260, NULL, NULL, NULL, NULL, '{uploads/u3qsz742ga0tyomybmfi}');
INSERT INTO public.posts VALUES ('52a9cb96-def0-4df2-a9e0-3539e89d0e42', 'ط§ظ„ط³ظ„ط§ظ… ط¹ظ„ظٹظƒظ… 
ظ„ظ„ط¨ظٹط¹ ط¨ظٹطھ ظپظٹ ط§ظ„ط®ظٹط³ظ‡ (ط¬ط±ظٹط§ظ† ط¬ظ†ظٹط­ط§طھ )
ظ…ط³ط§ط­ظ‡ 1195ظ… ط¹ظ„ظٹ 3 ط´ظˆط§ط±ط¹ 
ظ…ظ‚ط§ط¨ظ„ ظ…ط³ط¬ط¯ ظ…ظˆظ‚ط¹ ظ…ظ…طھط§ط² 
ط¹ظ„ظٹظ‡ ظ…ظ‚طھط±ط­ ظپط±ط² ظ‚ط·ط¹طھظٹظ† 
ط§ظ„ظ…ط§ظ„ظƒ ط³ط§ظƒظ† ظپظٹظ‡ ظˆط¨ظٹط·ظ„ط¹ ', 6, 2, 19, false, 2, 'ط§ظ„ط®ظٹط³ظ‡ ', 5500000.00, NULL, NULL, 1195.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1763650685/uploads/pasdkqwc2p7sudtxqcim.jpg}', '2025-11-20 14:58:06.266204', '2025-11-20 14:58:06.266204', '00008d13-0bba-4508-b679-1fdee2890c14', 'ط§ظ„ط®ظٹط³ظ‡.', 292, NULL, NULL, NULL, NULL, '{uploads/pasdkqwc2p7sudtxqcim}');
INSERT INTO public.posts VALUES ('ce20b91c-e690-4054-9984-918bb703594e', '*ظ„ظ„ط¨ظٹط¹ ظ…ظ† ط§ظ„ظ…ط§ظ„ظƒ* 

ظپظٹظ„ط§ ط¹ظ„ظ‰ ط®ط· ط§ظ„ط´ظ…ط§ظ„ ط¬ظ†ط¨ ط§ظٹظƒظٹط§ ظ…ط¨ط§ط´ط±ظ‡ ط¹ظ„ظ‰ ط´ط§ط±ط¹ظٹظ† ط²ط§ظˆظٹط© .

ظپظٹظ„ط§ ط®ط¯ظ…ظٹط©  640 ظ…طھط± ظپط§ط¶ظٹط©
 ط¹ظ…ط± ط§ظ„ط¨ظ†ط§ط، ط³ظ†طھظٹظ†.

ظ…ط·ظ„ظˆط¨ 6طŒ000طŒ000  ط±ظٹط§ظ„', 1, 1, 14, false, 2, 'ط¨ط¬ظˆط§ط± ط§ظٹظƒظٹط§', 6000000.00, 6, 3, 640.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1755806699/uploads/vqgmh3bwdqptwvnoapzr.jpg}', '2025-08-21 20:05:00.48376', '2025-08-21 20:05:00.48376', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'ط§ظ„ط®ظٹط³ط© ', 1079, NULL, NULL, NULL, NULL, '{uploads/vqgmh3bwdqptwvnoapzr}');
INSERT INTO public.posts VALUES ('4e19f191-e0cf-4b4f-95ee-d27576048c31', 'ظپظٹظ„ط§ ط¬ط¯ظٹط¯ط© ظ„ظ„ط¨ظٹط¹ ط¨ظ…ظ†ط·ظ‚ط© ط§ظ… ظ‚ط±ظ† 
ظ…ط³ط§ط­ط© ط§ظ„ط§ط±ط¶  ظ¤ظ©ظ©
ظ…ط³ط§ط­ط© ط§ظ„ط¨ظ†ظٹط§ظ† ظ¤ظ¤ظ 
ط³ط¨ط¹ ط؛ط±ظپ ظ…ط§ط³طھط±
ظˆظ…ظ„ط­ظ‚ ط®ط§ط±ط¬ظٹ ظ…ط·ط¨ط® ظˆط؛ط±ظپط© ط®ط¯ظ… 
ظˆط§ط¬ظ‡ط© ط­ط¬ط±
ظ…ط·ظ„ظˆط¨ 3 ظ…ظ„ظٹظˆظ†
', 6, 2, 18, false, 1, 'ط§ظ… ظ‚ط±ظ†', 3000000.00, 7, 5, 499.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1758001416/uploads/rwzolppeu9bccjzgnrfm.jpg}', '2025-09-16 05:43:37.759543', '2025-09-16 05:43:37.759543', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'ط£ظ… ظ‚ط±ظ†', 999, NULL, NULL, NULL, NULL, '{uploads/rwzolppeu9bccjzgnrfm}');
INSERT INTO public.posts VALUES ('51a19e99-9490-4e65-be7d-3dd689719748', 'ظپظٹظ„ط§ ظ„ظ„ط§ظٹط¬ط§ط± ظپظ‰ ط§ظ… ظ‚ط±ظ† ط¹ظ„ظ‰ ط§ظ„ط§ط³ظƒط§ظ† 6 ط؛ط±ظپ ظˆظ…ط¬ظ„ط³ ظˆطµط§ظ„ط© ظˆظ…ظ„ط­ظ‚ ط¨ط§ظ„ظ…ظƒظٹظپط§طھ', 6, 2, 18, true, 2, 'ظپظٹظ„ط§', 11000.00, 6, 5, 500.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1753605799/uploads/qzwax6ep4jmpuz85yqbr.jpg}', '2025-07-27 08:43:20.841393', '2025-07-27 08:43:20.841393', 'f660dd0b-f66c-406a-a688-e30374396930', 'ط§ظ… ظ‚ط±ظ†', 601, NULL, NULL, NULL, NULL, '{}');
INSERT INTO public.posts VALUES ('8e7d8048-9edd-4231-83c2-78f6988d6276', 'ظ„ظ„ط¨ظٹط¹ ط§ط±ط¶ظٹظ† ظپظٹ ط´ط¹ط¨ظٹط© ط®ظ„ظٹظپط© 
680 ظ…طھط± ط´ط§ط±ط¹ظٹظ† ط§ظ…ط§ظ…ظٹ ظˆط®ظ„ظپظٹ
 ط´ط§ط±ط¹  ط§ظ„ط´ط§ظ‡ظٹظ†ظٹط© ط§ظ„ط®ط¯ظ…ظٹ 
', 1, 2, 19, false, 3, 'ط´ط¹ط¨ظٹظ‡ ط®ظ„ظٹظپظ‡ ', 2560000.00, NULL, NULL, 680.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1761580879/uploads/mt6qcy6ji1gczavp7yg5.jpg}', '2025-10-27 16:01:20.913413', '2025-10-27 16:01:20.913413', '00008d13-0bba-4508-b679-1fdee2890c14', 'ط´ط¹ط¨ظٹظ‡ ط®ظ„ظٹظپظ‡', 495, NULL, NULL, NULL, NULL, '{uploads/mt6qcy6ji1gczavp7yg5}');
INSERT INTO public.posts VALUES ('e6035054-a4db-4c45-b816-594fdc2d4989', '', 1, 1, 18, false, 1, '', 4400000.00, 6, 5, 525.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1753570277/uploads/wzuckoefgzx74hhzn6nv.jpg}', '2025-07-26 22:51:18.169342', '2025-07-26 22:51:18.169342', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'ط§ظ„ط®ظٹط³ط© ط§ظ„ط¬ط¯ظٹط¯ط© ', 873, NULL, NULL, NULL, NULL, '{}');
INSERT INTO public.posts VALUES ('7ae2e2fb-10c8-41fd-8994-899a63575591', 'ظ„ظ„ط§ظٹط¬ط§ط± ظپظ‰ ط³ظ…ظٹط³ظ…ط© ظپظٹظ„ط§ ظ…ظ…طھط§ط²ط© 
  ظ¦ ط؛ط±ظپ ظ…ط§ط³طھط± ظƒظ„ ط؛ط±ظپظ‡ ظ…ط¹ ط­ظ…ط§ظ…
ظ…ط¬ظ„ط³ + ط­ظ…ط§ظ… 
طµط§ظ„طھظٹظ† 
ظ…ط·ط¨ط® ظƒط¨ظٹط± ظپط§ظ„ط·ط§ط¨ظ‚ ط§ظ„ط§ط±ط¶ظٹ ظˆظˆط§ط­ط¯ ط«ط§ظ†ظٹ طµط؛ظٹط± ظپط§ظ„ط·ط§ط¨ظ‚ ط§ظ„ط§ظˆظ„ 
ط§ظ„ظ…ط³ط§ط­ط© ظ¤ظ ظ£ظ… 
ط·ط§ط¨ظ‚ظٹظ† + ط¨ظ†طھ ظ‡ط§ظˆط³
ظ…ط·ظ„ظˆط¨ ظ،ظ، ط§ظ„ظپ ط±ظٹط§ظ„ ظ‚ط·ط±ظٹ ظپط§ظ„ط´ظ‡ط±', 6, 1, 18, false, 2, 'ط³ظ…ظٹط³ظ…ط© ', 11000.00, 6, 5, 500.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1756526686/uploads/xk0n0xera9rkj2vqrqwq.jpg}', '2025-08-30 04:04:48.336121', '2025-08-30 04:04:48.336121', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'ط³ظ…ظٹط³ظ…ط© ', 1874, NULL, NULL, NULL, NULL, '{uploads/xk0n0xera9rkj2vqrqwq}');
INSERT INTO public.posts VALUES ('60c5e109-fe62-4cef-8909-aff7a112ff65', 'ط§ظ„ط³ظ„ط§ظ… ط¹ظ„ظٹظƒظ…
ظ„ظ„ط¨ظٹط¹ ط§ط±ط¶ ط¨ط§ظ… طµظ„ط§ظ„ ط¹ظ„ظٹ ظ…ط³ط§ط­طھظ‡ط§ 8509ظ…طھط±
ط¹ظ„ظٹ 3ط´ظˆط§ط±ط¹ ط§ظ„ظپظˆطھ 260 ط±ظٹط§ظ„', 3, 2, 19, false, 1, 'ط§ط±ط¶', 23800000.00, 1, 1, 8509.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1753607896/uploads/xs2odezzivldrhcwjixw.jpg}', '2025-07-27 09:18:17.07104', '2025-07-27 09:18:17.07104', 'f660dd0b-f66c-406a-a688-e30374396930', 'ط§ظ… طµظ„ط§ظ„ ط¹ظ„ظٹ', 388, NULL, NULL, NULL, NULL, '{}');
INSERT INTO public.posts VALUES ('1cfa83f0-26c5-43e5-bc31-385484854b7a', 'ط§ظ„ط³ظ„ط§ظ… ط¹ظ„ظٹظƒظ… ظˆط±ط­ظ…ط© ط§ظ„ظ„ظ‡
 
ظ„ظ„ط¨ظٹط¹ ظپظٹظ„ط§ ط¨ط£ظ… طµظ„ط§ظ„ ط¹ظ„ظٹ
ط¨ط­ط§ظ„ظ‡ ط¬ظٹط¯ظ‡ ط¬ط¯ط§ 
ظ…ط³ط§ط­ظ‡ ط§ظ„ط§ط±ط¶ 400 ظ…طھط± 

ظ…ط¤ط¬ط±ظ‡ ط¹ظ„ظٹ ظˆط²ط§ط±ط© ط§ظ„ط£ظˆظ‚ط§ظپ
 ط¨ 8000 ط±ظٹط§ظ„ ط´ظ‡ط±ظٹ
 
 ط¹ظ…ط±ظ‡ط§ 9 ط³ظ†ظˆط§طھ ظپظ‚ط· 
 ظ…ط·ظ„ظˆط¨2,200,000 ط±ظٹط§ظ„', 3, 2, 18, false, 2, 'ط§ظ… طµظ„ط§ظ„ ط¹ظ„ظ‰ ', 2200000.00, 7, 5, 400.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1758199227/uploads/fk2pealmw3jq0hmiqvi3.jpg}', '2025-09-18 12:40:28.101189', '2025-09-18 12:40:28.101189', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'ط§ظ… طµظ„ط§ظ„ ط¹ظ„ظ‰ ', 1042, NULL, NULL, NULL, NULL, '{uploads/fk2pealmw3jq0hmiqvi3}');
INSERT INTO public.posts VALUES ('3bc81f11-a702-4947-bfe3-6f3ad16891ba', 'ظ„ظ„ط¨ظٹط¹ ظ…ظ† ط§ظ„ظ…ط§ظ„ظƒ ظ…ط¨ط§ط´ط±ط§ â€¦
ط¨ظٹطھ ط´ط¹ط¨ظٹ ظپظٹ ظ…ظ†ط·ظ‚ظ‡ ظ…ط¹ظٹط°ط± ط§ظ„ط¬ظ†ظˆط¨ظٹ ط§ظ„ظ„ظٹ ط®ظ„ظپ ظ†ط§ط¯ظٹ ظ…ط¹ظٹط°ط± ظپظٹ ط·ط§ط¨ظ‚ ظˆط§ط­ط¯ ظ…ظ† ظپظˆظ‚ ظƒظٹط±ط¨ظٹ 
ظ…ط³ط§ط­ظ‡ 1200ظ…
ظ…ط¤ط¬ط± 13 ط§ظ„ظپ ط±ظٹط§ظ„ ط´ظ‡ط±ظٹط§ ط¹ظ‚ط¯ ط¨ظٹظ†طھظ‡ظٹ ظپظٹ ط´ظ‡ط± 8 ط§ظ„ظ‚ط§ط¯ظ…
ظ…ط³ط§ط­ظ‡ ط§ظ„ط§ط±ط¶ / 1196ظ… 
ط¹ط¨ط§ط±ظ‡ ط¹ظ† ظ¦ ط؛ط±ظپ ظ…ط§ط³طھط± ظˆطµط§ظ„ظ‡ ظˆظ…ط¬ظ„ط³ ظˆظ…ظ‚ظ„ط¯ ط±ط¬ط§ظ„ظٹ ظˆط؛ط±ظپظ‡   
ظˆط§طµظ„ ط§ظ„ط³ط¹ط± 2.800.000 ظˆط±ظپط¶
ط§ظ„ظ…ط·ظ„ظˆط¨  2.900.000 ط؛ظٹط± ظ‚ط§ط¨ظ„
ط´ط±ظƒظ‡ ط§ظ„طھظˆط­ظٹط¯ ظ„ظ„ط¹ظ‚ط§ط±ط§طھ 
طھط±ط®ظٹطµ / 387

طھظˆط§طµظ„ ط¹ظ„ظٹ ط§ظ„ط®ط§طµ ', 2, 2, 18, false, 3, 'ط¨ظٹطھ', 2900000.00, 6, 4, 1200.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1757891823/uploads/jantxox2qfzj6dwrkprp.jpg}', '2025-09-14 23:17:04.069915', '2025-09-14 23:17:04.069915', '0b84d6dd-a098-4d39-a6e5-e1dc95b64c0c', 'ظ…ط¹ظٹط°ط±', 1100, NULL, NULL, NULL, NULL, '{uploads/jantxox2qfzj6dwrkprp}');
INSERT INTO public.posts VALUES ('375770d8-83a8-4f35-a337-16696f07ba4e', '*ظ„ظ„ط¨ظٹط¹ *
ط¨ظ„ظˆظƒ ط§ط±ط§ط¶ظٹ ط³ظƒظ†ظٹظ‡ ظپظٹ ط§ظ„ظˆظƒط±ظ‡ 
ط§ظ„ط¬ط¨ظ„ ظ‚ط±ظٹط¨ ظ…ظ† ط§ظ„ط¨ط­ط± ط¹ط¯ط¯ 28
ظ‚ط·ط¹ظ‡ ظ…ط³ط§ط­ظ‡ ط§ظ„ظ‚ط·ط¹ظ‡ 600ظ… 
طھط£ط®ط° ظپظ„طھظٹظ† ظ…طھظ„ط§طµظ‚ط§طھ ظˆط§ط¬ظ‡ظ‡ ظƒظ„ ظ‚ط·ط¹ظ‡ 22 ظ… طھظ‚ط±ظٹط¨ط§ ظ…ظˆظ‚ط¹ ظ…ظ…طھط§ط² 
ظ…ط·ظ„ظˆط¨ 300 ط±ظٹط§ظ„ ظ„ظ„ظپظˆطھ ظ†ظ‡ط§ط¦ظٹ 
', 5, 1, 19, false, 1, 'ظ‚ط±ظٹط¨ ط§ظ„ط¨ط­ط±', 1937000.00, NULL, NULL, 600.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1755688415/uploads/juy3hdymdqsnq5qyq5xp.jpg}', '2025-08-20 11:13:35.916047', '2025-08-20 11:13:35.916047', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'ط§ظ„ظˆظƒط±ط© ط§ظ„ط¬ط¨ظ„', 1073, NULL, NULL, NULL, NULL, '{uploads/juy3hdymdqsnq5qyq5xp}');
INSERT INTO public.posts VALUES ('fbe82a85-cec5-423f-8a4d-47bb38657753', 'ظ„ظ„ط¨ظٹط¹ ظپظٹظ„ط§ ظپظٹ ظ…ظ†ط·ظ‚ط© ط¬ط±ظٹط§ظ† ط¬ظ†ظٹط­ط§طھ 
ظ…ط³ط§ط­ط© ط§ظ„ظپظٹظ„ط§ 508ظ… ظˆظ…ط³ط§ط­ط© ط§ظ„ط¨ظ†ط§ط، 575ظ… ظˆط§طµظ„ ط§ظ„ط®ط¯ظ…ط§طھ ط´ط§ط±ط¹ ظ‚ط§ط± 20 ظ…طھط± 
طھطھظƒظˆظ† ظ…ظ† :- 
ط§ظ„ط¯ظˆط± ط§ظ„ط£ط±ط¶ظٹ ط¹ط¨ط§ط±ظ‡ ط¹ظ† ظ…ط¬ظ„ط³ ط®ط§ط±ط¬ظٹ 
ظˆظ…ط¬ظ„ط³ ط¯ط§ط®ظ„ظٹ ظ…ط¹ طµط§ظ„ظ‡ /ط؛ط±ظپط© ظ…ط§ط³طھط±/ ظ…ط·ط¨ط® ط¯ط§ط®ظ„ظٹ / ط­ط¯ظٹظ‚ظ‡ ط®ظ„ظپظٹظ‡ / ظ…ظ„ط­ظ‚ ط®ط§ط±ط¬ظٹ ظ…ط¹ ظ…ط·ط¨ط®
ط§ظ„ط¯ظˆط± ط§ظ„ط§ظˆظ„ / ط¹ط¨ط§ط±ظ‡ ط¹ظ† ظ¤ ط؛ط±ظپ ظ…ط§ط³طھط± 
ط§ظ„ط¨ظ†طھ ظ‡ط§ظˆط³ / ط¹ط¨ط§ط±ظ‡ ط¹ظ† ط؛ط±ظپطھظٹظ† ظ…ط§ط³طھط± / طµط§ظ„ظ‡ / ظ…ط·ط¨ط® طھط­ط¶ظٹط±ظٹ 
ظˆط§ط¬ظ‡ط§طھ ط§ظ„ظپظٹظ„ط§ ط­ط¬ط± / ط¬ظٹط¨ط³ط¨ظˆط±ط¯ / ظ…طµط¹ط¯ /ط؛ط±ظپط© ط³ط§ظٹظ‚
ظ…ط·ظ„ظˆط¨ 4,350,000
4,200,000 ظ†ظ‡ط§ط¦ظٹ', 1, 1, 18, false, 1, '', 4200000.00, 6, 5, 508.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1753570681/uploads/wilqkfd0mnkmn6mvxyls.jpg}', '2025-07-26 22:58:02.459809', '2025-07-26 22:58:02.459809', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'ط§ظ„ط®ظٹط³ط© ط¬ط±ظٹط§ظ† ط¬ظ†ظٹط­ط§طھ', 858, NULL, NULL, NULL, NULL, '{}');
INSERT INTO public.posts VALUES ('b6533582-e805-4670-b46f-934a2539b793', 'ظ„ظ„ط¥ظٹط¬ط§ط± 
ظپظٹظ„ط§ ظپظ‰ ط§ظ„ط«ظ…ط§ظ…ظ‡ ط§ظ„ظ‚ط¯ظٹظ…ظ‡ 
ظ…ظˆظ‚ط¹ ظ…ظ…طھط§ط² 
طھطھظƒظˆظ† ظ…ظ† :- 
ط§ظ„ط¯ظˆط±  ط§ظ„ط§ط±ط¶ظٹ  :-
طµط§ظ„ط§طھ ظ…ظپطھظˆط­ط© ظ…ط¹ ط­ظ…ط§ظ… + ط؛ط±ظپطھظٹظ† ظ…ظ†ظ‡ظ… ط؛ط±ظپظ‡ ظ…ط§ط³طھط± ظ…ط¹ ط³طھظˆط±
 ظˆط؛ط±ظپظ‡ ط¨ط­ظ…ط§ظ… ط®ط§ط±ط¬ظٹ
ط§ظ„ط¯ظˆط± ط§ظ„ط§ظˆظ„ :- 
طµط§ظ„ط©  + ظ¤ ط؛ط±ظپ ظƒظ„ ط؛ط±ظپطھظٹظ†  ط¨ط­ظ…ط§ظ… ظ…ط´طھط±ظƒ  

ظ…ط·ظ„ظˆط¨ :   ظ،ظ،ظ ظ ظ   ط±ظٹط§ظ„', 1, 1, 18, false, 2, 'ط§ظ„ط«ظ…ط§ظ…ظ‡', 11000.00, 6, 5, 0.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1761993479/uploads/ohc7n2lnq0oxszcxp9n9.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1761993479/uploads/zmr2cwj8ygljqtchj8fp.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1761993479/uploads/lksq82sdwyjpoznx7gbz.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1761993479/uploads/zt4rfphgu4mazjw5vb5p.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1761993479/uploads/oh5p2gucoo2pclksabyr.jpg}', '2025-11-01 10:38:01.546859', '2025-11-01 10:38:01.546859', '00008d13-0bba-4508-b679-1fdee2890c14', 'ط§ظ„ط«ظ…ط§ظ…ظ‡ ', 909, NULL, NULL, NULL, NULL, '{uploads/ohc7n2lnq0oxszcxp9n9,uploads/zmr2cwj8ygljqtchj8fp,uploads/lksq82sdwyjpoznx7gbz,uploads/oh5p2gucoo2pclksabyr,uploads/zt4rfphgu4mazjw5vb5p}');
INSERT INTO public.posts VALUES ('8f4b037a-eb1d-44c5-9dd9-cfa84be004b2', 'ظ„ظ„ط¨ظٹط¹ ظپظٹظ„ط§ ظ…ط±ظٹط® ظ…ظ‚ط§ط¨ظ„ ط§ط³ط¨ط§ظٹط± ظ…ظˆظ‚ط¹ ظ…ظ…طھط§ط² ط¬ط¯ط§ 
ظ…ط³ط§ط­ظ‡ ط§ظ„ط§ط±ط¶ / 606ظ… .
ط¹ظ„ظ‰ ط´ط§ط±ط¹ظٹظ† ط§ظ…ط§ظ…ظٹ ظˆط®ظ„ظپظٹ ظˆط§ط¬ظ‡ط© ط­ط¬ط±  
8 ط؛ط±ظپ ظ†ظˆظ… ظˆظ…ط¬ظ„ط³ ط®ط§ط±ط¬ظٹ 
ظ„ظپطھ ط±ط®ط§ظ… ظˆطھظƒظٹظپ ظ…ط±ظƒط²ظٹ
ط§ط±ط¶ظٹ ظ…ط¬ظ„ط³ طµط§ظ„ط© ط­ظ…ط§ظ… ظˆظ…ط؛ط§ط³ظ„  ط؛ط±ظپط© ط·ط¹ط§ظ…  ظˆط؛ط±ظپط© ظ…ط§ط³طھط±
ظ…ط·ط¨ط® ط®ط§ط±ط¬ظٹ ظˆط؛ط±ظپط© ط³ط§ظٹظ‚  ظˆط­ظˆط´ ظ…ظ† ط§ظ„ط®ظ„ظپ
ط§ظ„ط¯ظˆط± ط§ظ„ط£ظˆظ„ 4 ط؛ط±ظپ ظ…ط§ط³طھط± ظˆطµط§ظ„ط© 
ط¨ظ†طھظ‡ط§ظˆط³ 3 ط؛ط±ظپ  ظ…ط§ط³طھط± ظˆطµط§ظ„ط© ظˆظ…ط·ط¨ط® طھط­ط¶ظٹط±ظٹ
 
ظ…ط·ظ„ظˆط¨ / 5.300.000
ظ„ظ„طھظˆط§طµظ„ ط¹ ط§ظ„ط®ط§طµ 
ط´ط±ظƒظ‡ ط§ظ„طھظˆط­ظٹط¯ ظ„ظ„ط¹ظ‚ط§ط±ط§طھ
طھط±ط®ظٹطµ / 387', 2, 2, 18, false, 1, 'ظپظٹظ„ط§', 5300000.00, 8, 5, 606.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1757891937/uploads/uqkuaxneetpytpne3lnz.jpg}', '2025-09-14 23:18:58.39125', '2025-09-14 23:18:58.39125', '0b84d6dd-a098-4d39-a6e5-e1dc95b64c0c', 'ظ…ط±ظٹط®', 1244, NULL, NULL, NULL, NULL, '{uploads/uqkuaxneetpytpne3lnz}');
INSERT INTO public.posts VALUES ('d5baff4a-0074-4674-b625-7f97478bb7c9', 'ظ„ظ„ط¨ظٹط¹ ط³ظˆظ‚ طھط¬ط§ط±ظٹ ظپظٹ ط§ظ„ط؛ط±ط§ظپط© ظ…ط³ط§ط­ط© 517 ظ…
ط¹ط¯ط¯ ط§ظ„ظ…ظƒط§طھط¨ 8
ظ…ط¤ط¬ط±ط© ط¹ظ„ظٹ ط´ط±ظƒط© ظ…ط¯ط®ظˆظ„ ط´ظ‡ط±ظٹ 83 ط§ظ„ظپ ط±ظٹط§ظ„ 
ط¹ط¯ط¯ ط§ظ„ظ…ط­ظ„ط§طھ ط§ظ„طھط¬ط§ط±ظٹط© 4
ط£ط³طھظˆط± 2
ط¹ظ…ط± ط§ظ„ط¨ظ†ط§ظٹط© ظˆط¨ط¯ط§ظٹط© ط§ظ„ط§ظٹط¬ط§ط± 2017
ظ…ط·ظ„ظˆط¨ 16 ظ…ظ„ظٹظˆظ† 
', 1, 2, 12, false, 2, 'ط§ظ„ط؛ط±ط§ظپظ‡ ', 16000000.00, NULL, NULL, NULL, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1770582849/uploads/jpvymccyedu8f4otlsoc.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1770582850/uploads/dldq3smq6y2axzap6pvt.jpg}', '2026-02-08 20:34:11.625255', '2026-02-08 20:34:11.625255', '00008d13-0bba-4508-b679-1fdee2890c14', '', 453, NULL, NULL, NULL, NULL, '{uploads/jpvymccyedu8f4otlsoc,uploads/dldq3smq6y2axzap6pvt}');
INSERT INTO public.posts VALUES ('43bb3afc-5227-4dda-9d12-7d5738044418', ' 
ظ„ظ„ط¨ظٹط¹ ظپظٹظ„ط§ ط§ظ„ط«ظ…ط§ظ…ظ‡ ط§ظ„ظ‚ط¯ظٹظ…ظ‡ 
ظ…ط³ط§ط­ظ‡ ط§ظ„ط§ط±ط¶ 426ظ… ظ…ط³ط§ط­ظ‡ ط§ظ„ط¨ظ†ط§ط، 557ظ…
ظ…ظ‚ط§ط¨ظ„ ط§ظ„ظ…ظٹط±ظ‡ ظ…ط¨ط§ط´ط±ظ‡ 
ظ…ظˆظ‚ط¹ ظ…ظ…طھط§ط² ط¬ط¯ط§ 

ط§ظ„ط¯ظˆط± ط§ظ„ط§ط±ط¶ظ‰ 
ظ…ط¬ظ„ط³ ط¯ط§ط®ظ„ظ‰ ظ…ط¹ ظ…ط؛ط§ط³ظ„ ظˆط­ظ…ط§ظ… 
طµط§ظ„ظ‡ ظ…ظ†ظپطµظ„ظ‡ ظ…ط¹ ظ…ط؛ط§ط³ظ„ ظˆط­ظ…ط§ظ… 
ط؛ط±ظپظ‡ ظ…ط§ط³طھط± ظˆظ…ط·ط¨ط® ط¯ط§ط®ظ„ظ‰ 

ط§ظ„ط¯ظˆط± ط§ظ„ط§ظˆظ„ 
4 ط؛ط±ظپ ظ…ط§ط³طھط± ظˆطµط§ظ„ظ‡ 

ط§ظ„ط¨ظ†طھ ظ‡ط§ظˆط³ 
ط؛ط±ظپطھظٹظ† ظ…ط§ط³طھط± ظˆطµط§ظ„ظ‡ ظƒط¨ظٹط±ظ‡ 

ط§ظ„ظ…ظ„ط­ظ„ظ‚ ط§ظ„ط®ط§ط±ط¬ظ‰ 
ظ…ط·ط¨ط® ط®ط§ط±ط¬ظ‰ 
ظˆط؛ط±ظپظ‡ ط®ط¯ط§ظ…ظ‡ 
ظˆظ…ط؛ط³ظ„ظ‡ ظ…ظ„ط§ط¨ط³ 

ظ…طµط¹ط¯ ط±ط§ظƒط¨ 
ظ…ظƒظٹظپط§طھ 
ط§ظ„ظپظٹظ„ط§ ط¬ط¨ط³ ط¨ظˆط±ط¯ ظƒط§ظ…ظ„ظ‡ 
ظˆط§ط¬ظ‡ظ‡ ظ…ظˆط¯ط±ظ† ط­ط¬ط± 
طھط´ط·ظٹط¨ ط³ظˆط¨ط± ط¯ظٹظ„ظˆظƒط³ 
ط؛ط±ظپظ‡ ط³ط§ط¦ظ‚ ط®ط§ط±ط¬ظٹظ‡
ظ…ظƒظٹظپط§طھ
ظˆط§طµظ„ظ‡ ظ…ط§ط، ظˆظƒظ‡ط±ط¨ط§ط،
ط§ط³ط§ظ†ط³ظٹط± ط±ط§ظƒط¨
ظ…ط·ظ„ظˆط¨ 3 ظ…ظ„ظٹظˆظ† 750 ط§ظ„ظپ', 1, 2, 18, false, 1, 'ط§ظ„ط«ظ…ط§ظ…ظ‡', 3750000.00, 7, 5, 426.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1766665543/uploads/m1f9uidk7z2mznucecn8.jpg}', '2025-12-25 12:25:43.990492', '2025-12-25 12:25:43.990492', '00008d13-0bba-4508-b679-1fdee2890c14', 'ط§ظ„ط«ظ…ط§ظ…ظ‡', 1183, NULL, NULL, NULL, NULL, '{uploads/m1f9uidk7z2mznucecn8}');
INSERT INTO public.posts VALUES ('0bef2049-b775-472a-846f-a12eeda9527e', '
ظ„ظ„ط¨ظٹط¹  ظپظٹظ„ط§ ط¬ط¯ظٹط¯ط© ظپظٹ ط§ظ… ظ‚ط±ظ† ظ…ط³ط§ط­ط© ط§ظ„ط§ط±ط¶ 420 ظ… ظ…ط³ط§ط­ط© ط§ظ„ط¨ظ†ط§ط، 510 ظ… 
طھط´ط·ظٹط¨ ظ…ظ…طھط§ط² ط¨ظ‡ط§ ظ…ط¬ظ„ط³ ط®ط§ط±ط¬ظٹ 

طھطھظƒظˆظ† ظ…ظ† :- 
ظ…ط¬ظ„ط³ ط®ط§ط±ط¬ظٹ
ط§ظ„ط·ط§ط¨ظ‚ ط§ظ„ط£ط±ط¶ظٹ: ظ…ط¬ظ„ط³ ط®ط§ط±ط¬ظٹ ظˆ ظ…ط¬ظ„ط³ ط¯ط§ط®ظ„ظٹ ظ…ظ†ظپطµظ„ ظˆطµط§ظ„ظ‡ ظƒط¨ظٹط±ظ‡ ظˆط؛ط±ظپط© ط·ط¹ط§ظ… ظˆ ط؛ط±ظپط© ظ…ط§ط³طھط±

ط§ظ„ط¯ظˆط± ط§ظ„ط§ظˆظ„ : 4 ط؛ط±ظپ ظ…ط§ط³طھط± ظˆطµط§ظ„ظ‡ 

ط§ظ„ط¨ظ†طھ ظ‡ط§ظˆط³: ط؛ط±ظپطھظٹظ† ظ…ط§ط³طھط± ظˆطµط§ظ„ظ‡ 
ط§ظ„ظ…ظ„ط­ظ‚ ط§ظ„ط®ط§ط±ط¬ظٹ : ظ…ط·ط¨ط® ط®ط§ط±ط¬ظٹطŒ ظˆط؛ط±ظپط© ط؛ط³ظٹظ„طŒ ظˆط؛ط±ظپط© ظ„ظ„ط®ط§ط¯ظ…ط©طŒ
ظ…ط¬ظ„ط³ ط®ط§ط±ط¬ظٹ
ظ…ظˆظ‚ظپ ط³ظٹط§ط±ط© ظ…ط¹ ظ…ط¸ظ„ط©
طھط´ط·ظٹط¨ ظ…ظ…طھط§ط² ط¬ط¨ط³ ط¨ط§ظ„ظƒط§ظ…ظ„ ط¯ط±ط§ظٹط´ ط¨ظˆط¨ظٹ ظپظٹ ط³ظٹ 
', 1, 2, 18, false, 1, 'ط§ظ… ظ‚ط±ظ†', 2900000.00, 7, 5, 420.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1763712586/uploads/fgn0l2hdct2tfp8kxudk.jpg}', '2025-11-21 08:09:47.357106', '2025-11-21 08:09:47.357106', '00008d13-0bba-4508-b679-1fdee2890c14', 'ط§ظ… ظ‚ط±ظ†', 502, NULL, NULL, NULL, NULL, '{uploads/fgn0l2hdct2tfp8kxudk}');
INSERT INTO public.posts VALUES ('469299cf-f9df-4b3b-a967-be56d38915de', 'ط§ظ„ط³ظ„ط§ظ… ط¹ظ„ظٹظƒظ…
ظ„ظ„ط¨ظٹط¹ ط§ط±ط¶ ط¨ط±ظˆط¶ط© ظ‚ط¯ظٹظ… ظ…ط³ط§ط­طھظ‡ط§ 1175ظ…طھط±
ط§ظ„ظپظˆطھ 360ط±ظٹط§ظ„', 2, 2, 19, false, 1, 'ط§ط±ط¶', 4458000.00, 1, 1, 1157.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1753608109/uploads/tall0wbtbb2ha342h9v0.jpg}', '2025-07-27 09:21:50.44505', '2025-07-27 09:21:50.44505', 'f660dd0b-f66c-406a-a688-e30374396930', 'ط±ظˆط¶ط© ظ‚ط¯ظٹظ…', 315, NULL, NULL, NULL, NULL, '{}');
INSERT INTO public.posts VALUES ('7c39bbfc-4a07-4fb4-87d5-0691d4666f4a', 'ط§ظ„ط³ظ„ط§ظ… ط¹ظ„ظٹظƒظ… ظ„ظ„ط¨ظٹط¹ ط§ط±ط¶ ط¨ط§ظ„ظˆط¹ط¨ ظ…ط³ط§ط­طھظ‡ط§ 2456ظ…طھط± 
ط¹ظ„ظٹ ط§ظ„ط´ط§ط±ط¹ ط§ظ„ط¹ط§ظ… ظ„ظ„ظˆط¹ط¨ 64ظ…طھط±
ط§ظ„ط§ط±ط¶ ط¹ظ„ظٹ 3ط´ظˆط§ط±ط¹ ظ…ط·ظ„ظˆط¨ ط§ظ„ظپظˆطھ 540ط±ظٹط§ظ„ ظ‚ط§ط¨ظ„', 2, 2, 19, false, 1, 'ط§ط±ط¶', 14275000.00, 1, 1, 2456.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1753606067/uploads/kdbwvxvxwfkn0e47seg2.jpg}', '2025-07-27 08:47:48.445892', '2025-07-27 08:47:48.445892', 'f660dd0b-f66c-406a-a688-e30374396930', 'ط§ظ„ظˆط¹ط¨', 343, NULL, NULL, NULL, NULL, '{}');
INSERT INTO public.posts VALUES ('ba716ca4-0864-44e0-8e6f-a23f8d923ac6', 'ظ„ظ„ط¨ظٹط¹ ط§ط±ط¶  ط¨ط§ظ„ظˆظƒظٹط± 
ط¹ظ„ظ‰ ط´ط§ط±ط¹ ط±ط¦ظٹط³ظٹ
ظ‚ط§ط¨ظ„ ظ„ظ„ظپط±ط² ظ‚ط·ط¹طھظٹظ†
ط¹ظ„ظٹظ‡ط§ ط¨ظٹطھ ط´ط¹ط¨ظٹ ظپط§ط¶ظٹ 
ظ…ط³ط§ط­ظ‡ 1500 ظ…طھط± ط´ط§ط±ط¹ ط£ظ…ط§ظ…ظٹ ظˆط®ظ„ظپظٹ
 ظ…ظ‚ط§ط¨ظ„ ط§ط²ط¯ط§ظ† 21
ط¹ط§ظ„ط´ط§ط±ط¹ ط§ظ„ط±ط¦ظٹط³ظٹ
ظ…ط·ظ„ظˆط¨ 4 ظ…ظ„ظٹظˆظ† ظ†ظ‡ط§ط¦ظٹ
ط§ظ„ظپظˆطھ 247
ط¬ظˆط§ظ„ 70401700 //
33833660', 5, 2, 19, false, 3, '', 4000000.00, NULL, NULL, 1500.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1756845154/uploads/qukwkbmetypqlponlteo.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1756845154/uploads/mhnpgeryhtzdrrvomhsk.jpg}', '2025-09-02 20:32:36.231695', '2025-09-02 20:32:36.231695', 'a7b77bb9-8519-4201-8034-527b17d21de3', 'ط§ظ„ظˆظƒظٹط± ظ…ظ‚ط§ط¨ظ„ ط§ط²ط¯ط§ظ† 21', 602, NULL, NULL, NULL, NULL, '{uploads/qukwkbmetypqlponlteo,uploads/mhnpgeryhtzdrrvomhsk}');
INSERT INTO public.posts VALUES ('97c3b770-9fe5-4526-9ac8-c6783608e332', 'ظ„ظ„ط¨ظٹط¹ ظ…ط¨ط§ط´ط± 

ط¨ظٹطھ ط´ط¹ط¨ظٹ ظ‚ط¯ظٹظ… ظپط§ط¶ظٹ  ظپ ط§ظ„ظˆظƒط±ط© ظ…ط³ط§ط­ط© ظ¥ظ ظ¥ ظ…طھط± ط´ط§ط±ط¹ظٹظ† ط²ط§ظˆظٹط©  ظ…ظˆظ‚ط¹ ظ…ظ…طھط§ط²
 ظ…ط·ظ„ظˆط¨
 ظ…ظ„ظٹظˆظ† ظˆ ظ¨ظ¥ظ  ط§ظ„ظپ', 5, 2, 18, false, 3, 'ط§ظ„ظˆظƒط±ط©', 1850000.00, 5, 4, 505.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1755696801/uploads/q0xgloq6gdj8bjqt7bln.jpg}', '2025-08-20 13:33:23.285521', '2025-08-20 13:33:23.285521', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'ط§ظ„ظˆظƒط±ط©', 1091, NULL, NULL, NULL, NULL, '{uploads/q0xgloq6gdj8bjqt7bln}');
INSERT INTO public.posts VALUES ('402a6775-fdd1-4c91-b0ef-c751e3b5389c', 'ظ„ظ„ط¨ظٹط¹ ط¹ظ‚ط§ط± طھط¬ط§ط±ظٹ ط¹ظ„ظ‰ ط´ط§ط±ط¹ ط±ط§ط³ ط£ط¨ظˆ ط¹ط¨ظˆط¯ ط¹ظ„ظ‰ ط´ط§ط±ط¹ظٹظ† ط²ظˆظٹط© ظ…ط³ط§ط­ط© ط§ظ„ط¹ظ‚ط§ط± 353ظ…طھط± ظٹطھظƒظˆظ† ط§ظ„ط¹ظ‚ط§ط± ظ…ظ† 6 ط´ظ‚ظ‚ ظƒظ„ظ‡ط§ 5 ط؛ط±ظپ ظ†ظˆظ… 3 ط­ظ…ط§ظ… ظˆطµط§ظ„ظ‡ ظ…ط¹ ظˆط¬ظˆط¯ ط¹ط¯ط¯ ط®ظ…ط³ظ‡ ظ…ط­ظ„ط§طھ طھط¬ط§ط±ظٹظ‡ ط§ط¬ظ…ط§ظ„ظ‰ ط§ظ„ط§ظٹط¬ط§ط± ط³ط¨ط¹ظٹظ† ط§ظ„ظپ ط±ظٹط§ظ„ ط´ظ‡ط±ظٹ ظˆط§ظ„ط¯ط®ظ„ ط§ظ„ط³ظ†ظˆظٹ
 840000 ط±ظٹط§ظ„
ط«ظ…ط§ظ† ظ…ط§ط¦ظ‡ ظˆط§ط±ط¨ط¹ظٹظ† ط§ظ„ظپ
', 1, 2, 20, false, 2, 'ط±ط§ط³ ط§ط¨ظˆ ط¹ط¨ظˆط¯', 13000000.00, 10, NULL, 353.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1763816268/uploads/xvagvvzzh2nq9pbwbjqj.jpg}', '2025-11-22 12:57:49.545481', '2025-11-22 12:57:49.545481', '00008d13-0bba-4508-b679-1fdee2890c14', 'ط±ط§ط³ ط§ط¨ظˆ ط¹ط¨ظˆط¯', 405, NULL, NULL, NULL, NULL, '{uploads/xvagvvzzh2nq9pbwbjqj}');
INSERT INTO public.posts VALUES ('9218f1da-73c7-4a52-9442-d74e00383f7d', 'ظپظٹظ€ظ€ظ€ظ€ظ„ط§ ظ…ط³طھط¹ظ…ظ„ط© ط§ظ„ط®ط±ظٹط·ظٹط§طھ ظ„ظ„ط¨ظٹط¹

 ظ…ط³ط§ط­ظ‡ 650ظ… ط¹ظ„ظ‰ ط´ط§ط±ط¹ ظˆط³ظƒط©
ظ…ط¤ط¬ط±ط© ط¹ظ„ظ‰ ط´ط±ظƒط© ط¹ظ‚ط¯ ط¬ط¯ظٹط¯ 3ط³ظ†ظˆط§طھ ط¹ظˆط§ط¦ظ„ 
ط¨ 15ط§ظ„ظپ ط±ظٹط§ظ„ 
ط¹ظ…ط± ط§ظ„ظپظٹظ„ط§ ظ،ظ¢ ط³ظ†ظ‡
ظ…ط·ظ„ظ€ظ€ظˆط¨
 3.200.000', 1, 2, 18, false, 2, 'ط§ظ„ط®ط±ظٹط·ظٹط§طھ ', 3200000.00, 7, 5, 650.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1756527422/uploads/uevzghhpb82hb590uqcx.jpg}', '2025-08-30 04:17:03.134574', '2025-08-30 04:17:03.134574', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'ط§ظ„ط®ط±ظٹط·ظٹط§طھ ', 1123, NULL, NULL, NULL, NULL, '{uploads/uevzghhpb82hb590uqcx}');
INSERT INTO public.posts VALUES ('cc48e097-554c-4bf6-9ae6-bfe9c4893211', 'ط§ظ„ط³ظ„ط§ظ… ط¹ظ„ظٹظƒظ…
ظ„ظ„ط¨ظٹط¹ ط§ط±ط¶ ط¨ط§ظ„ظˆظƒظٹط±
ظ…ط³ط§ط­طھظ‡ط§ 600ظ…طھط±
ط¹ظ„ظٹ ط´ط§ط±ط¹ ط¹ط§ظ… 40,ظ…طھط±', 5, 2, 19, false, 1, 'ط§ط±ط¶', 1743000.00, 1, 1, 600.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1753608227/uploads/xgkcfvjo4wyyiwvmo0hx.jpg}', '2025-07-27 09:23:48.193023', '2025-07-27 09:23:48.193023', 'f660dd0b-f66c-406a-a688-e30374396930', 'ط§ظ„ظˆظƒظٹط±', 304, NULL, NULL, NULL, NULL, '{}');
INSERT INTO public.posts VALUES ('ccd0b489-1009-4bb0-9d80-4f941009b42f', '
ط¨ظٹطھ ط´ط¹ط¨ظٹ ظ„ظ„ط¨ظٹط¹
ًں“چ ط§ظ„ط؛ط±ط§ظپط© 

ط¨ط§ظ„ظ‚ط±ط¨ ظ…ظ† ط­ط¯ظٹظ‚ط© ط§ظ„ط؛ط±ط§ظپط© ظ…ظˆظ‚ط¹ ظ…ظ…طھط§ط² 

ًں“گ ظ…ط³ط§ط­طھظ‡  683 ظ…طھط± ط²ط§ظˆظٹط© ط¹ظ„ظ‰ ط´ط§ط±ط¹ ظˆط³ظƒط©

ًں‘ˆًںڈ»ظ…ط¤ط¬ط± 22 ط§ظ„ظپ ط¨ط§ظ‚ظٹ ظپظٹ ط§ظ„ط¹ظ‚ط¯ ط³ظ†ط© 

5 ط¹ط¯ط§ط¯ط§طھ ظƒظ‡ط±ط¨ط§ط، ظ…ظپطµظˆظ„ط©
ظ…ظˆظ‚ط¹ 

ظ…ط·ظ„ظˆط¨ ظ£ظ©ظ ظ ظ ظ ظ 


ط§', 2, 2, 19, false, 3, 'ط§ظ„ط؛ط±ط§ظپظ‡', 3900000.00, NULL, NULL, 683.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1768586732/uploads/u5rtyyf3qefblowzvs2z.jpg}', '2026-01-16 18:05:33.169217', '2026-01-16 18:05:33.169217', '00008d13-0bba-4508-b679-1fdee2890c14', 'ط§ظ„ط؛ط±ط§ظپظ‡', 1149, NULL, NULL, NULL, NULL, '{uploads/u5rtyyf3qefblowzvs2z}');
INSERT INTO public.posts VALUES ('5e048df3-4d79-498f-ab61-bbb88ad36805', 'ظ„ظ„ط§ظٹط¬ط§ط± ظپظٹظ„ط§ ط§ط±ط¶ظٹط© ط³ظٹظ„ظٹظ‡ ط§ظ„ظ…ط¹ط±ط§ط¶  
ظ…ط³ط§ط­ط© 925ظ… ط¹ظ„ظ‰ ط´ط§ط±ط¹ظٹظ† ط²ط§ظˆظٹط© ط¹ط¨ط§ط±ط© ط¹ظ† 6 ط؛ط±ظپ 
6 ط­ظ…ط§ظ… ظٹظˆط¬ط¯ ط؛ط±ظپطھظٹظ† ظ…ط§ط³طھط± ظ…ط·ط¨ط® ط®ط§ط±ط¬ظ‰ 
ط؛ط±ظپط© ظˆط؛ط±ظپط© ط³ط§ط¦ظ‚ ظ…ط³طھظ‚ظ„ط© ظٹظˆط¬ط¯ 
ظ…ط¬ظ„ط³ ط®ط§ط±ط¬ظ‰ ط¹ط¨ط§ط±ط© ط¹ظ† ط®ظٹظ…ط© ظˆط­ظˆط´ ظˆط§ط³ط¹ 
ط§ظ„ظپظٹظ„ط§ ط¨ط§ظ„ظ…ظƒظٹظپط§طھ 

ظ…ط·ظ„ظˆط¨ 16000 ط±ظٹط§ظ„ 
طھظ…ط´ظ‰ ط§ظٹط¬ط§ط± ط´ط®طµظ‰ ط§ظˆ ط¹ظ„ظ‰ ط§ظ„ط¥ط³ظƒط§ظ† ط§ظ„ط­ظƒظˆظ…ظ‰
ط§ظ„ط³ط¹ظ€ط± ظ‚ظ€ط§ط¨ظ„', 2, 1, 18, false, 2, 'ط§ظ„ظ…ط¹ط±ط§ط¶', 16000.00, 6, 5, 925.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1756526435/uploads/a0dpwfvxbvdtct0dmph1.jpg}', '2025-08-30 04:00:36.438998', '2025-08-30 04:00:36.438998', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'ط§ظ„ط³ظٹظ„ظٹط© ', 1438, NULL, NULL, NULL, NULL, '{uploads/a0dpwfvxbvdtct0dmph1}');
INSERT INTO public.posts VALUES ('be87438f-60b9-4341-aaeb-2133c3226071', '
ظ„ظ„ط§ظٹط¬ط§ط±

ظپظٹظ„ط§ ظپظٹ ط§ظ… ظ‚ط±ظ†
ظ…ط³ط§ط­ط© ط§ظ„ط¨ظ†ظٹط§ظ† 460 ظ…طھط± 
ظ¨ ط؛ط±ظپ ظˆطµط§ظ„ط© ظˆظ…ط¬ظ„ط³ ط¯ط§ط®ظ„ظ‰ ظˆظ…ظ„ط­ظ‚ ط®ط§ط±ط¬ظ‰. 

ظ…ط·ظ„ظˆط¨ ظ،ظ¢  ط£ظ„ظپ ط±ظٹط§ظ„
', 1, 1, 18, false, 2, 'ط§ظ… ظ‚ط±ظ†', 12000.00, 6, 5, 460.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1763827002/uploads/sdvtighnxftf2ktaogvb.jpg}', '2025-11-22 15:56:42.91222', '2025-11-22 15:56:42.91222', '00008d13-0bba-4508-b679-1fdee2890c14', 'ط§ظ… ظ‚ط±ظ†', 953, NULL, NULL, NULL, NULL, '{uploads/sdvtighnxftf2ktaogvb}');
INSERT INTO public.posts VALUES ('4bfba044-5337-4642-aeb2-69ac2925ff71', 'ظ…ظ† ط§ظ„ظ…ط§ظ„ظƒ 
ظ„ظ„ط¨ظٹط¹ ط¨ط§ظ… ط¹ط¨ظٹط±ظٹظ‡ ط«ظ„ط§ط« ط§ط±ط§ط¶ظٹ  
ظ…ط³ط§ط­ظ‡ ظƒظ„ ظ‚ط·ط¹ظ‡ 613 ظ… ط´ط§ط±ط¹ ظ‚ط§ط± 
ط±ط®طµ ظˆط®ط±ط§ظٹط· ط¬ط§ظ‡ط²ظ‡
ظ…ط·ظ„ظˆط¨ ظ¢ظ¥ظ¥ ط±ظٹط§ظ„  ظ„ظ„ظپظˆطھ', 3, 2, 19, false, 1, 'ط§ظ… ط¹ط¨ظٹط±ظٹط©', 1680000.00, NULL, NULL, 613.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1755700164/uploads/rvktsgvfxdfvhq6bujgp.jpg}', '2025-08-20 14:29:25.998239', '2025-08-20 14:29:25.998239', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'ط§ظ… ط¹ط¨ظٹط±ظٹط©', 847, NULL, NULL, NULL, NULL, '{uploads/rvktsgvfxdfvhq6bujgp}');
INSERT INTO public.posts VALUES ('d50f79cb-3ae4-47fe-abd8-109507d547c7', 'ط§ظ„ط³ظ„ط§ظ… ط¹ظ„ظٹظƒظ…
ظ„ظ„ط¨ظٹط¹ ط§ط±ط¶ ط¨ط±ظˆط¶ط© ط§ظ„ط­ظ…ط§ظ…ط©
ظ…ط³ط§ط­طھظ‡ط§ 1471ظ…طھط±
ظ…ط·ظ„ظˆط¨ ط§ظ„ظپظˆطھ 340ط±ظٹط§ظ„', 6, 2, 19, false, 1, 'ط§ط±ط¶', 5385008.00, 1, 1, 1471.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1753606943/uploads/rfkdang8rnvgoozzs7an.jpg}', '2025-07-27 09:02:24.124306', '2025-07-27 09:02:24.124306', 'f660dd0b-f66c-406a-a688-e30374396930', 'ط±ظˆط¶ط© ط§ظ„ط­ظ…ط§ظ…ط©', 201, NULL, NULL, NULL, NULL, '{}');
INSERT INTO public.posts VALUES ('4f236d89-6dd0-444c-8621-c27021da3844', 'ط§ط±ط¶ ظ„ظ„ط¨ظٹط¹ ظپظ‰ ظ„ط¬ظ…ظٹظ„ظٹظ‡
ط§ط±ط¶ ظ‚ط±ظٹط¨ظ‡ ظ…ظ† ط¬ظ…ظٹط¹ ط§ظ„ط®ط¯ظ…ط§طھ 
', 8, 2, 19, false, 3, 'ظ„ط¬ظ…ظٹظ„ظٹظ‡', 1425000.00, NULL, NULL, 873.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1766918213/uploads/lirfsaprrz1ula0dpy2d.jpg}', '2025-12-28 10:36:56.18708', '2025-12-28 10:36:56.18708', '00008d13-0bba-4508-b679-1fdee2890c14', 'ظ„ط¬ظ…ظٹظ„ظٹظ‡', 1142, NULL, NULL, NULL, NULL, '{uploads/lirfsaprrz1ula0dpy2d}');
INSERT INTO public.posts VALUES ('64c3043e-2169-4bda-8f27-9fbcd049109a', 'ظ„ظ„ط¨ظٹط¹  
ط¨ظٹطھ ط´ط¹ط¨ظٹ ظپظٹ ط§ظ„ط®ظٹط³ظ‡ 1204ظ… 
ط¹ظ„ظٹ ط´ط§ط±ط¹ظٹظ† ط²ط§ظˆظٹط© ظ…ظ†ظ‡ظ… ط´ط§ط±ط¹ ط¹ط±ط¶ 40ظ… ظˆط´ط§ط±ط¹ ط¹ط±ط¶ 16ظ… ظٹظ†ظپط±ط² ظ‚ط·ط¹طھظٹظ† 
ظ…ط¤ط¬ط± ط­ط§ظ„ظٹط§ ط¨ظ‚ظٹظ…ظ‡ ظ،ظ£.ظ¥ظ ظ  ط´ظ‡ط±ظٹط§ ط¨ظٹظ†طھظ‡ظٹ ط¹ظ‚ط¯ظ‡ ط´ظ‡ط± 10 ط§ظ„ظ‚ط§ط¯ظ…
ظˆط§طµظ„ 5.100  
ظ…ط·ظ„ظˆط¨ 5.100.000 ط§ظ„ظپ ط±ظٹط§ظ„ ظ†ظ‡ط§ط¦ظٹ 
ط´ط±ظƒظ‡ ط§ظ„طھظˆط­ظٹط¯ ظ„ظ„ط¹ظ‚ط§ط±ط§طھ 
طھط±ط®ظٹطµ / 387', 6, 2, 19, false, 3, 'ط¨ظٹطھ', 5100000.00, NULL, NULL, 1204.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1757891437/uploads/ytjr1osmrkcldwnwf19e.jpg}', '2025-09-14 23:10:38.423091', '2025-09-14 23:10:38.423091', '0b84d6dd-a098-4d39-a6e5-e1dc95b64c0c', 'ط§ظ„ط®ظٹط³ظ‡ ', 793, NULL, NULL, NULL, NULL, '{uploads/ytjr1osmrkcldwnwf19e}');
INSERT INTO public.posts VALUES ('a53a2465-060f-436a-a123-8852437cab43', 'ط§ط±ط¶ ظپظٹ ط§ظ„ظ…ط´ط§ظپ ظ„ظ„ط¨ظٹط¹ 

ظ…ط³ط§ط­ط© ظ¤ظ©ظ©ظ…
ط¹ظ„ظٹ ط´ط§ط±ط¹ ظƒط¨ظٹط±
ط®ط¯ظ…ظٹ ظ¤ظ ظ…
 ط§ط±ط¶ طھظپطھط­ ط¹ظ„ظٹ ط´ط§ط±ط¹ ط§ظ„ط¹ط§ظ…
ظ…ط·ظ„ظˆط¨ ط§ظ„ظپظˆطھ ظ£ظ،ظ 
ظ„ظ„ط¨ظٹط¹ ظ…ط¨ط§ط´ط± 

ط§ط±ط¶ ظپظٹ ط§ظ„ظ…ط´ط§ظپ
ظ¤ظ©ظ©ظ…
ط¹ظ„ظٹ ط´ط§ط±ط¹ ظƒط¨ظٹط±
ط®ط¯ظ…ظٹ ظ¤ظ ظ…
 ط§ط±ط¶ طھظپطھط­ ط¹ظ„ظٹ ط´ط§ط±ط¹ ط§ظ„ط¹ط§ظ…
ظ…ط·ظ„ظˆط¨ ط§ظ„ظپظˆطھ ظ£ظ،ظ 
1665000', 5, 2, 19, false, 1, 'ط§ظ„ظ…ط´ط§ظپ ', 1665000.00, NULL, NULL, 499.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1756527811/uploads/qx4xsoqqqp3twgs54di0.jpg}', '2025-08-30 04:23:32.781569', '2025-08-30 04:23:32.781569', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'ط§ظ„ظ…ط´ط§ظپ ', 584, NULL, NULL, NULL, NULL, '{uploads/qx4xsoqqqp3twgs54di0}');
INSERT INTO public.posts VALUES ('d9cd05fb-4aa5-44cb-8fbf-90af6a9caec2', 'ط§ظ„ط³ظ„ط§ظ… ط¹ظ„ط¨ظƒظ…
ظ„ظ„ط¨ظٹط¹ ط§ط±ط¶ ط¨ط®ظ„ظٹظپط© ط§ظ„ط¬ظ†ظˆط¨ظٹط©
ظ…ط³ط§ط­طھظ‡ط§ 603ظ…طھط±
', 1, 2, 19, false, 1, 'ط§ط±ط¶', 2800000.00, 1, 1, 603.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1753608326/uploads/outkg2cmbfrzvfhx1ulo.jpg}', '2025-07-27 09:25:27.815329', '2025-07-27 09:25:27.815329', 'f660dd0b-f66c-406a-a688-e30374396930', 'ط®ظ„ظٹظپط© ط§ظ„ط¬ظ†ظˆط¨ظٹط©', 481, NULL, NULL, NULL, NULL, '{}');
INSERT INTO public.posts VALUES ('14cabc01-e099-46a4-9e84-dd5e4d4c6ca4', 'ظ„ظ„ط¨ظٹط¹ ط§ط±ط¶ ظپظ‰ ط§ظ„ظˆظƒط±ظ‡ 
ظ…ظ‚ط§ط¨ظ„ ط§ظ„ظ…ط³طھط´ظپظ‰ ', 5, 2, 19, false, 1, 'ط§ظ„ظˆظƒط±ظ‡ ', 1650000.00, NULL, NULL, 509.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1770143868/uploads/lirhtrsj4g6mdqcvjrvm.jpg}', '2026-02-03 18:37:48.944361', '2026-02-03 18:37:48.944361', '00008d13-0bba-4508-b679-1fdee2890c14', 'ط§ظ„ظˆظƒط±ظ‡ ', 669, NULL, NULL, NULL, NULL, '{uploads/lirhtrsj4g6mdqcvjrvm}');
INSERT INTO public.posts VALUES ('6461adb7-6ed2-4065-ac5c-66444c43522b', 'ظ„ظ„ط¨ظٹط¹ ط¨ظٹطھ ط´ط¹ط¨ظٹ ظپ ط§ظ„ط¯ط­ظٹظ„ ظ…ظˆظ‚ط¹ ظ…ظ…طھط§ط²
ظ…ط³ط§ط­ظ‡ ط§ظ„ط§ط±ط¶ / 1225ظ… 
ط§ظ„ط¨ظٹطھ ط­ط§ظ„طھظ‡ ظƒظˆظٹط³ظ‡ ط¬ط¯ط§ ظٹطµظ„ط­ ظ„ظ„ط³ظƒظ† 

ظ…ط·ظ„ظˆط¨ / 5.500.000
ط§ظ„ظ„ظٹ ط¹ظ†ط¯ظ‡ ط³ط¹ط± ط¬ط§ط¯ ط¨ط¨ظ„ط؛ ط¨ظٹظ‡ ط§ظ„ظ…ط§ظ„ظƒ 

ط´ط±ظƒظ‡ ط§ظ„طھظˆط­ظٹط¯ ظ„ظ„ط¹ظ‚ط§ط±ط§طھ 
طھط±ط®ظٹطµ / 387', 1, 2, 18, false, 2, 'ط¨ظٹطھ', 5500000.00, 5, 5, 1225.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1757891711/uploads/wm8nbn53lowrndeputjq.jpg}', '2025-09-14 23:15:12.539088', '2025-09-14 23:15:12.539088', '0b84d6dd-a098-4d39-a6e5-e1dc95b64c0c', 'ط§ظ„ط¯ط­ظٹظ„ ', 1181, NULL, NULL, NULL, NULL, '{uploads/wm8nbn53lowrndeputjq}');
INSERT INTO public.posts VALUES ('c3f743bb-92f6-410c-a0cc-eced13f7b16e', 'ظ„ظ„ط¨ظٹط¹ ط¢ط±ط¶ ظپظٹ ظپط±ظٹط¬ ط§ظ„ظ…ط±ظ‡ ط¹ظ„ظٹ ط«ظ„ط§ط« ط´ظˆط§ط±ط¹ ط®ظ„ظپ ط·ط±ظٹظ‚ ط³ظ„ظˆظٹ ظ…ظˆظ‚ط¹ ظ…ظ…طھط§ط² ط¬ط¯ط§ ظˆطھظ†ظپط±ط² 4 ظ‚ط·ط¹ 
 ظ…ط³ط§ط­ظ‡ ط§ظ„ط§ط±ط¶ / 1997ظ…
 ظ…ط·ظ„ظˆط¨ ظپ ط§ظ„ظپظˆطھ / 300 ط±ظٹط§ظ„

https://google.com/maps/search/?api=1&query=25.232950,51.437810', 1, 2, 19, false, 3, '10', 300.00, NULL, NULL, 1997.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1757431877/uploads/m91uliimhfxd9xroxbi4.jpg}', '2025-09-09 15:31:18.151807', '2025-09-09 15:31:18.151807', '0b84d6dd-a098-4d39-a6e5-e1dc95b64c0c', 'ط§ظ„ظ…ط±ظ‡', 1250, NULL, NULL, NULL, NULL, '{uploads/m91uliimhfxd9xroxbi4}');
INSERT INTO public.posts VALUES ('189e2d33-0f78-4b2e-8f8b-2bd8ccb74a5e', 'ظ„ظ„ط§ظٹط¬ط§ط± ظپظٹظ„ط§ ظپظٹ ط±ظˆط¶ط© ط§ظ„ط­ظ…ط§ظ… ط¹ظ„ظ‰ ط§ظ„ط´ط§ط±ط¹  ط§ظ„ط¹ط§ظ…  ط¹ط¨ط§ط±ط© ط¹ظ† 
ط·ط§ط¨ظ‚ ط£ط±ط¶ظٹ :ظ…ط¬ظ„ط³ ظƒط¨ظٹط± ظ…ظ‚ظ„ط· ظˆطµط§ظ„ط© ظˆط؛ط±ظپطھظٹظ† ظ…ط§ط³طھط±

ظ…ط·ط¨ط® ط¯ط§ط®ظ„ظٹ  
 
ط·ط§ط¨ظ‚ ط§ظˆظ„ : 5 ط؛ط±ظپ  
 ظ…ط§ط³طھط± 
طµط§ظ„ط© ظƒط¨ظٹط±ط©
ط¨ظ†طھ ظ‡ط§ظˆط³ ط¹ط¨ط§ط±ط© ط¹ظ† : 
ظ…ظƒظˆظ† ظ…ظ† ظ¤ ط؛ط±ظپ  ظ…ط§ط³طھط± 
ظˆظ…ط·ط¨ط® طھط­ط¶ظٹط±ظٹ 
ط¨ط³ظ…ظ†طھ ط¹ط¨ط§ط±ط© ط¹ظ† ظ…ط·ط¨ط® طھط­ط¶ظٹط±ظٹ ظˆط³طھظˆط± ظˆط­ظ…ط§ظ… ظˆظ…ط¬ظ„ط³ ظƒط¨ظٹط± ظˆط؛ط±ظپط© ط·ط¹ط§ظ… 
ظ…طµط¹ط¯ 
ط§ظ„ظپظٹظ„ط§ ط¨ط§ظ„ظ…ظƒظٹظپط§طھ ط´ظ‡ط± ظ…ط¬ط§ظ†ط§ 
ظ…ط·ظ„ظˆط¨ 22ط§ظ„ظپ', 6, 1, 18, false, 2, 'ط±ظˆط¶ظ‡ ط§ظ„ط­ظ…ط§ظ…ظ‡', 22000.00, 8, 5, 1000.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1759842899/uploads/a17zsmkgewhz1lri1ssq.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1759842899/uploads/mltyih2yuehjqacuwhtv.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1759842898/uploads/nndi4ai02ylao2x2ytek.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1759842899/uploads/krhydqjnafm6kilrsy7q.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1759842898/uploads/jucwpe8g2p8sn53kvheq.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1759842898/uploads/bimg4dlbrzgovdsjhrxp.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1759842898/uploads/epemxsexdsfrwrjnluep.jpg}', '2025-10-07 13:15:00.363561', '2025-10-07 13:15:00.363561', '00008d13-0bba-4508-b679-1fdee2890c14', 'ط±ظˆط¶ظ‡ ط§ظ„ط­ظ…ط§ظ…ظ‡', 2545, NULL, NULL, NULL, NULL, '{uploads/jucwpe8g2p8sn53kvheq,uploads/a17zsmkgewhz1lri1ssq,uploads/bimg4dlbrzgovdsjhrxp,uploads/nndi4ai02ylao2x2ytek,uploads/krhydqjnafm6kilrsy7q,uploads/epemxsexdsfrwrjnluep,uploads/mltyih2yuehjqacuwhtv}');
INSERT INTO public.posts VALUES ('2b1af9bd-2ee9-453f-bce9-3ed3a569ab70', 'ظ„ظ„ط¨ظٹط¹ ط§ط±ط¶ ط¹ظ…ط§ط±ط§طھ ظپظٹ ط§ظ„ط¯ظˆط­ظ‡ ط§ظ„ط¬ط¯ظٹط¯ظ‡ ط¹ظ„ظ‰ ط´ط§ط±ط¹ظٹظ† ظˆط§ظ„ظ…ظ†ط·ظ‚ظ‡ ط¹ظ„ظٹظ‡ط§ ط§ط±طھظپط§ط¹ط§طھ ط§ط±ط¶ظٹ 7ط·ط§ط¨ظ‚ ظ…ط³ط§ط­ظ‡ 881 ظ…طھط± 
ظ…ظ† ط§ظ„ظ…ط§ظ„ظƒ ظ…ط¨ط§ط´ط± 
ظ…ط·ظ„ظˆط¨ 8.500.000
ط¹ظ„ظٹظ‡ط§ ظ…ظ‚طھط±ط­ ظ…ظ† ظ…ظƒطھط¨ ط§ظ„ط§ط³طھط´ط§ط±ظٹ ظ¢ظ، ط´ظ‚ظ‡ ظˆط§ط°ط§ ط¹ظ…ظ„طھ ط¨ظٹط³ظ…ظ†طھ ظٹطµظٹط± ظ¢ظ¤ ط´ظ‚ظ‡
ظ‚ط§ط¨ظ„ ط§ظ„طھظپط§ظˆط¶', 1, 2, 19, false, 1, 'ط§ظ„ظ…ط¬ظ…ط¹ ', 850000.00, NULL, NULL, 881.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1765367093/uploads/akpdnkgjbucpl47caspn.jpg}', '2025-12-10 11:44:54.171802', '2025-12-10 11:44:54.171802', '18e15b48-2d06-47e9-b8ec-aa49ef39b847', 'ط§ظ„ط¯ظˆط­ط© ط§ظ„ط¬ط¯ظٹط¯ظ‡', 477, NULL, NULL, NULL, NULL, '{uploads/akpdnkgjbucpl47caspn}');
INSERT INTO public.posts VALUES ('084a8995-b0a2-4056-9959-366253c37a71', 'ظ„ظ„ط¨ظٹط¹ 
ظپظٹظ„ط§ ط§ط²ط؛ظˆظ‰ 
ظ…ط³ط§ط­ظ‡ 609ظ… ظˆط§ظ„ط¨ظ†ط§ط، 700ظ… 
ط´ط§ط±ط¹ظٹظ† ط§ظ…ط§ظ…ظ‰ ظˆط®ظ„ظپظ‰ 
ظˆط§ط¬ظ‡ظ‡ ط­ط¬ط± ط·ط¨ظٹط¹ظ‰ ظ…ظ† ط§ظ„ط¬ظ‡طھظٹظ† 
ط§ظ„ط¯ظˆط± ط§ظ„ط§ط±ط¶ظ‰ 
طµط§ظ„طھظٹظ† ظƒط¨ط§ط± ظˆط؛ط±ظپظ‡ ظ…ط§ط³طھط±
ظ…طµط¹ط¯ ظƒظ‡ط±ط¨ط§ط¦ظ‰ 
ط§ظ„ط¯ظˆط± ط§ظ„ط§ظˆظ„ 
4 ط؛ط±ظپ ظ…ط§ط³طھط± ظˆطµط§ظ„ظ‡ 
ط§ظ„ط¨ظ†طھ ظ‡ط§ظˆط³ ط؛ط±ظپطھظٹظ† ظ…ط§ط³طھط± ظˆطµط§ظ„ظ‡ 
ظ…ط·ط¨ط® ط®ط§ط±ط¬ظ‰ ظ…ط¹ ظ…ظ„ط­ظ‚ ظ…ط§ط³طھط± 
ظˆظ…ط؛ط³ظ„ظ‡ 
ط§ط±ط¶ظٹط§طھ ط±ط®ط§ظ… 
ط¬ط¨ط³ ط¨ظˆط±ط¯ ط¨ط§ظ„ظƒط§ظ…ظ„ 
طھظƒظٹظٹظپ ظ…ط±ظƒط²ظ‰ ط¨ط§ظ„ظƒط§ظ…ظ„ 
ظٹظˆ ط¨ظٹ ظپظٹ ط³ظٹ 
ظ…ظˆظ‚ط¹ ظ…ظ…طھط§ط² ط¬ط¯ط§ 
طھط´ط·ظٹط¨ ط³ظˆط¨ط± 
ظ…ط·ظ„ظˆط¨ 5 ظ…ظ„ظٹظˆظ† 500 ط§ظ„ظپ', 2, 2, 18, false, 1, 'ط§ط²ط؛ظˆظ‰', 5500000.00, 6, 5, 610.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1766175219/uploads/yx2tumkpryx4hfse1zgz.jpg}', '2025-12-19 20:13:40.339061', '2025-12-19 20:13:40.339061', '00008d13-0bba-4508-b679-1fdee2890c14', 'ط§ط²ط؛ظˆظ‰', 1024, NULL, NULL, NULL, NULL, '{uploads/yx2tumkpryx4hfse1zgz}');
INSERT INTO public.posts VALUES ('404c3210-b8b9-4580-ba9d-e5c2b3477403', '*ظ„ظ„ط¨ظٹط¹ *

 ط´ظ‚ط© ظپظٹ ط§ظ„ط¨ط±ط¬ ط§ظ„ظ…طھط¹ط±ط¬ B ( ظ„ظ„ط§ط¬ظˆظ†ط§ ). Zigzag*

 
ط§ظ„ظ…ط³ط§ط­ظ‡: 165ظ…
طµط§ظپظٹ ط§ظ„ظ…ط³ط§ط­ظ‡:140ظ…
*ط§ظ„ط·ط§ط¨ظ‚ ط§ظ„ط«ظ„ط§ط«ظ‡ ظˆط§ظ„ط«ظ„ط§ط«ظˆظ†.
ظ…ظپط±ظˆط´ط© ط¨ط§ظ„ظƒط§ظ…ظ„ 
*ط¹ط¯ط¯ ط§ظ„ط؛ط±ظپ : ظ¢ ظ…ط§ط³طھط± ظƒظ„ ط؛ط±ظپط© ظ…ط¹ ط­ظ…ط§ظ… 
*طµط§ظ„ط© + ط­ظ…ط§ظ… ط¶ظٹظˆظپ. 
*ظ…ط·ط¨ط® ظ…ط¬ظ‡ط² ط¨ظƒط§ظ…ظ„ ط§ظ„ظ…ط¹ط¯ط§طھ ظ…ط؛ظ„ظ‚ ظˆظ…ظپطµظˆظ„ ط¹ظ† ط§ظ„طµط§ظ„ظ‡. 
*ظ…ط·ظ„ط© ط¹ظ„ظ‰ ط§ظ„ظ„ط¤ظ„ط¤ظ‡ ظˆظپظ†ط¯ظ‚ ط¬ط±ط§ظ†ط¯ ط­ظٹط§ط© 
*ط§ظ„ط±ط³ظˆظ… ط§ظ„ط³ظ†ظˆظٹط© ط¹ظ„ظ‰ طµظٹط§ظ†ظ‡ ط§ظ„ط¨ط±ط¬ ظٹطھط­ظ…ظ„ظ‡ط§  ط§ظ„ظ…ط§ظ„ظƒ
*ط§ظ„طµظٹط§ظ†ظ‡ ط§ظ„ط¹ط§ط¯ظٹظ‡ ظˆط¬ظ…ظٹط¹ ظ…طµط§ط±ظٹظپ ط§ظ„ظƒظ‡ط±ط¨ط§ط، ظˆط§ظ„ظ…ط§ط، ظˆظ‚ط·ط± ظƒظˆظ„ ظˆط§ظ„ط§ظ†طھط±ظ†طھ ظˆط§ظˆط±ظٹط¯ظˆ ظٹطھط­ظ…ظ„ظ‡ط§ ط§ظ„ظ…ط³طھط£ط¬ط± 

ظ…ط¤ط¬ط±ظ‡ ط¹ظ‚ط¯ ط¬ط¯ظٹط¯/ ط§ظ„ط§ط¬ط§ط± ط§ظ„ط´ظ‡ط±ظٹ ظ§طŒظ¥ظ ظ  ظ„ظ…ط¯ط© ط³ظ†طھظٹظ† ط§ط¨طھط¯ط£ ظ…ظ† ط´ظ‡ط± ظ© ط³ظ†ط© ظ¢ظ ظ¢ظ¥ ظ…

*ظ…ط·ظ„ظˆط¨  1,450,000 ط±ظٹط§ظ„*', 1, 2, 17, false, 2, 'ط§ظ„ط¯ظˆط­ظ‡', 1500000.00, 2, 2, 165.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1762605254/uploads/ubn9diopax9tqmbtrxdu.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1762605252/uploads/ozy3rjelz4kl9jzfhwmh.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1762605252/uploads/bqr6xfpijjpwghmvhnwp.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1762605252/uploads/jbcojuudgawdaqivwmqv.jpg}', '2025-11-08 12:34:15.014479', '2025-11-08 12:34:15.014479', '00008d13-0bba-4508-b679-1fdee2890c14', 'ط§ظ„ط¯ظˆط­ظ‡', 533, NULL, NULL, NULL, NULL, '{uploads/ozy3rjelz4kl9jzfhwmh,uploads/bqr6xfpijjpwghmvhnwp,uploads/jbcojuudgawdaqivwmqv,uploads/ubn9diopax9tqmbtrxdu}');
INSERT INTO public.posts VALUES ('2eededae-898f-40f8-a2bf-01379ef40863', '*ظ„ظ„ط¨ظٹط¹ ظ…ظ† ط§ظ„ظ…ط§ظ„ظƒ ط¨ظٹطھ ط´ط¹ط¨ظ‰ ظپظ‰ ط´ط¹ط¨ظٹط© ط®ظ„ظٹظپط© ظ¦ظ ظ¤ ظ… ط¹ظ„ظ‰ ط²ط§ظˆظٹط© ظˆ ظ…ط¤ط¬ط± ط¨ ظ© ط§ظ„ط§ظپ ظ…ط·ظ„ظˆط¨ ظ¢.ظ£ظ ظ  ظ…ظ„ظٹظˆظ†.*', 1, 2, 18, false, 2, 'ط´ط¹ط¨ظٹط© ط®ظ„ظٹظپط© ', 2300000.00, 6, 5, 604.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1758015860/uploads/cmr5cfikrrkdd4stopsm.jpg}', '2025-09-16 09:44:21.099388', '2025-09-16 09:44:21.099388', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'ط´ط¹ط¨ظٹط© ط®ظ„ظٹظپط© ', 1117, NULL, NULL, NULL, NULL, '{uploads/cmr5cfikrrkdd4stopsm}');
INSERT INTO public.posts VALUES ('576df839-08eb-447f-adff-a9d94c518193', '*ظ„ظ„ط¨ظٹط¹*

*ظپظٹظ„ط§  ظ¤ظ§ظ© ظ…طھط± ط¨ط§ظ„ط®ط±ظٹط·ظٹط§طھ ط¹ظ„ظ‰ ط´ط§ط±ط¹ظٹظ† ط²ط§ظˆظٹط© ظ…ظˆظ‚ط¹ ظ…ظ…طھط§ط²*

*ط¹ط¨ط§ط±ط© ط¹ظ† ظ¦ ط؛ط±ظپ ظˆطµط§ظ„ط© ظˆظ…ط¬ظ„ط³ ط¯ط§ط®ظ„ظ‰ ظˆظ…ظ„ط­ظ‚ ط®ط§ط±ط¬ظ‰ ظˆط­ظˆط´*

ط§ظ„ط¯ظˆط± ط§ظ„ط§ط±ط¶ظ‰ 
ط؛ط±ظپط© ظˆطµط§ظ„ط© ظˆظ…ط¬ظ„ط³ ظˆط؛ط±ظپط© ط·ط¹ط§ظ… 

ط§ظ„ط¯ظˆط± ط§ظ„ط§ظˆظ„ 
ظ¤ ط؛ط±ظپ ظˆطµط§ظ„ط© 

ط¨ظ†طھظ‡ط§ظˆط³ ط؛ط±ظپط© ظ…ط§ط³طھط± 

ظ…ظ„ط­ظ‚ ط®ط§ط±ط¬ظٹ: ظ…ط·ط¨ط® ظˆط³طھظˆط± ظˆط؛ط±ظپط© ط®ط¯ظ….


*ظ…ط·ظ„ظˆط¨ ظ†ظ‡ط§ط¦ظ‰ ظ£.ظ¥ظ ظ .ظ ظ ظ  ط±ظٹط§ظ„*

ط£ظˆظ„ ط³ط§ظƒظ† ط§طھظ…ط§ظ… ط§ظ„ط¨ظ†ط§ط، ظ¢ظ ظ¢ظ¢ ظ…', 3, 2, 18, false, 1, 'ط§ظ„ط®ط±ظٹط·ظٹط§طھ', 3500000.00, 7, 5, 480.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1758990462/uploads/ble6xiwvyodqkjteyei4.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1758990462/uploads/jm4ovnuiukiieihp7qk9.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1758990462/uploads/ahlnk58zub4g8qrpzsph.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1758990462/uploads/ta9q55o67feu0tqaerlf.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1758990462/uploads/svo9tl7zvbztvshnher0.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1758990462/uploads/ygalp0s9tk0odtmkcyhr.jpg}', '2025-09-27 16:27:44.253947', '2025-09-27 16:27:44.253947', '00008d13-0bba-4508-b679-1fdee2890c14', 'ط§ظ„ط®ط±ظٹط·ظٹط§طھ', 2130, NULL, NULL, NULL, NULL, '{uploads/ble6xiwvyodqkjteyei4,uploads/svo9tl7zvbztvshnher0,uploads/ta9q55o67feu0tqaerlf,uploads/ygalp0s9tk0odtmkcyhr,uploads/jm4ovnuiukiieihp7qk9,uploads/ahlnk58zub4g8qrpzsph}');
INSERT INTO public.posts VALUES ('fab5c16c-92f6-4b02-85a3-23f5ba529eea', 'ظ„ظ„ط¨ظٹط¹ ط§ط±ط§ط¶ظٹ ظپظ‰ ظ…ط±ظٹط® ظ…ط³ط§ط­ط§طھ 600ظ… ظ…ظˆظ‚ط¹ ظˆط³ط¹ط± ظ…ظ…طھط§ط² ظ‚ط±ظٹط¨ ظ…ظ† ط³ط¨ط§ظٹط±
ط§ظ„ظ…ط£ظ…ظˆظ† ظ„ظ„ظˆط³ط§ط·ط© ط§ظ„ط¹ظ‚ط§ط±ظٹط© طھط±ط®ظٹطµ ط±ظ‚ظ… 201 ', 2, 2, 19, false, 1, 'ط§ط±ط§ط¶ظ‰', 380.00, NULL, NULL, 600.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1765460626/uploads/wntrr7go4v86cf3wdxrb.jpg}', '2025-12-11 13:43:47.844726', '2025-12-11 13:43:47.844726', '8c35d390-0b62-47dc-934d-02201a4e4051', 'ظ…ط±ظٹط® ', 477, NULL, NULL, NULL, NULL, '{uploads/wntrr7go4v86cf3wdxrb}');
INSERT INTO public.posts VALUES ('84bec0f2-9266-4a71-afc3-71c40aaea9e9', 'ظ„ظ„ط§ظٹط¬ط§ط± ظپظٹظ„ط§ ط§ط±ط¶ظٹط© ط³ظٹظ„ظٹظ‡ ط§ظ„ظ…ط¹ط±ط§ط¶ ظ…ط³ط§ط­ط© 
925ظ… ط¹ظ„ظ‰ ط´ط§ط±ط¹ظٹظ† ط²ط§ظˆظٹط© ط¹ط¨ط§ط±ط© ط¹ظ† 6 ط؛ط±ظپ 
6 ط­ظ…ط§ظ… ظٹظˆط¬ط¯ ط؛ط±ظپطھظٹظ† ظ…ط§ط³طھط± ظ…ط·ط¨ط® ط®ط§ط±ط¬ظ‰ 
ط؛ط±ظپط© ظˆط؛ط±ظپط© ط³ط§ط¦ظ‚ ظ…ط³طھظ‚ظ„ط© ظٹظˆط¬ط¯ 
ظ…ط¬ظ„ط³ ط®ط§ط±ط¬ظ‰ ط¹ط¨ط§ط±ط© ط¹ظ† ط®ظٹظ…ط© ظˆط­ظˆط´ ظˆط§ط³ط¹ 
ط§ظ„ظپظٹظ„ط§ ط¨ط§ظ„ظ…ظƒظٹظپط§طھ 

ظ…ط·ظ„ظˆط¨ 16000 ط±ظٹط§ظ„ 
طھظ…ط´ظ‰ ط§ظٹط¬ط§ط± ط´ط®طµظ‰ ط§ظˆ ط¹ظ„ظ‰ ط§ظ„ط¥ط³ظƒط§ظ† ط§ظ„ط­ظƒظˆظ…ظ‰
ط§ظ„ط³ط¹ظ€ط± ظ‚ظ€ط§ط¨ظ„', 1, 1, 18, true, 2, 'ط§ظ„ظ…ط¹ط±ط§ط¶', 16000.00, 6, 3, 925.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1755806818/uploads/p2nj3bxuslyr7cnljgcb.jpg}', '2025-08-21 20:06:59.775848', '2025-08-21 20:06:59.775848', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'ط³ظٹظ„ظٹط© ط§ظ„ظ…ط¹ط±ط§ط¶', 1257, NULL, NULL, NULL, NULL, '{uploads/p2nj3bxuslyr7cnljgcb}');
INSERT INTO public.posts VALUES ('348a4273-84cd-4ad5-b7dd-8bb8b6767d16', 'ظ„ظ„ط¨ظٹط¹ ط¨ظٹطھ ط´ط¹ط¨ظٹ ط¨ط§ظ„ظˆظƒط±ط© ظ…ظ†ط·ظ‚ط© ظƒط¨ط§ط± ط§ظ„ظ…ظˆط¸ظپظٹظ† ظ†ط§ط­ظٹط© ط§ظ„ط¬ط¨ظ„ ظ…ظˆظ‚ط¹ ظ…ظ…طھط§ط² ظ،ظ¢ظ ظ  ظ…طھط± ظٹطµظ„ط­ ظ„ظ„ظپط±ط² ط¹ظ„ظٹظ‡ ط±ط®طµط© ظ‡ط¯ظ… ظˆطھظ… ط§ط²ط§ظ„ط© ط¹ط¯ط§ط¯ط§طھ ط§ظ„ظƒظ‡ط±ط¨ط§ط، ظˆط§ظ„ظ…ظٹط§ط©', 5, 2, 19, false, 2, '', 3681000.00, NULL, NULL, 1200.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1758379871/uploads/yt5i64quzusdt7as4oy9.jpg}', '2025-09-20 14:51:12.299864', '2025-09-20 14:51:12.299864', '896876b6-f72e-4e03-8513-a29066826066', '', 758, NULL, NULL, NULL, NULL, '{uploads/yt5i64quzusdt7as4oy9}');
INSERT INTO public.posts VALUES ('ecc91751-1d48-4fcf-b278-94b7554dacaa', 'ظ„ظ„ط¨ظٹط¹ ظپظٹظ„ط§ ظپظ‰ ط§ظ„ط®ظˆط± طھط´ط·ظٹط¨ ط³ظˆط¨ط± ظ„ظˆظƒط³ ظˆط§ط¬ظ‡ظ‡ ط­ط¬ط± 8 ط؛ط±ظپ ظ…ط§ط³طھط± ظˆطµط§ظ„ط© ظˆظ…ط¬ظ„ط³ ظ…ظپطھظˆط­ظٹظ† ط¹ظ„ظ‰ ط¨ط¹ط¶ ظˆظ…ط¬ظ„ط³ ط®ط§ط±ط¬ظ‰ ظˆظ…ظ„ط­ظ‚ ظˆظ…طµط¹ط¯ ط¬ط§ظ‡ط²ط© ظ„ظ„ط³ظƒظ† ط¹ظ„ظ‰ ط´ط§ط±ط¹ ط¹ط§ظ…
ط§ظ„ظ…ط£ظ…ظˆظ† ظ„ظ„ظˆط³ط§ط·ط© ط§ظ„ط¹ظ‚ط§ط±ظٹط© طھط±ط®ظٹطµ ط±ظ‚ظ… 201
ظ„ظ„طھظˆط§طµظ„
66141559 ', 4, 2, 18, false, 1, 'ظپظٹظ„ط§', 3200000.00, 8, 5, 490.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1769859255/uploads/k7wvt1svau1vlgsaxl3k.jpg}', '2026-01-31 11:34:16.658698', '2026-01-31 11:34:16.658698', '8c35d390-0b62-47dc-934d-02201a4e4051', 'ط§ظ„ط®ظˆط±', 652, NULL, NULL, NULL, NULL, '{uploads/k7wvt1svau1vlgsaxl3k}');
INSERT INTO public.posts VALUES ('a359669a-f3a8-47f4-8188-e93e72c2f119', 'ظ„ظ„ط¨ظٹط¹ ظپظٹظ„ط§ ظپظ‰ ط§ظ„ظ…ط´ط§ظپ 7 ط؛ط±ظپ ظˆ 3 طµط§ظ„ط§طھ ظˆظ…ظ„ط­ظ‚ ط¹ظ…ط±ظ‡ط§ 6 ط³ظ†ظˆط§طھ ط¨ط­ط§ظ„ط© ظ…ظ…طھط§ط²ط© ظپط§ط¶ظٹط©
ط§ظ„ظ…ط£ظ…ظˆظ† ظ„ظ„ظˆط³ط§ط·ط© ط§ظ„ط¹ظ‚ط§ط±ظٹط© طھط±ط®ظٹطµ ط±ظ‚ظ… 201 ', 5, 2, 18, false, 2, 'ظپظٹظ„ط§', 2700000.00, 7, 5, 500.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1765460769/uploads/lr6pgtkpe8nuxlemnntq.jpg}', '2025-12-11 13:46:10.713683', '2025-12-11 13:46:10.713683', '8c35d390-0b62-47dc-934d-02201a4e4051', 'ط§ظ„ظ…ط´ط§ظپ ', 631, NULL, NULL, NULL, NULL, '{uploads/lr6pgtkpe8nuxlemnntq}');
INSERT INTO public.posts VALUES ('7f6dbb6f-d096-420a-af5d-d00bf0f45197', '1. ط§ط±ط¶ ط³ظƒظ†ظٹظ‡ ظپظٹ ط³ظ…ظٹط³ظ…ظ‡ ط¨ظ…ط³ط§ط­ط© 1,218 ظ….ظ…. (ظˆط§ط¬ظ‡ط© 25 ظ…طھط± ظˆط¹ظ…ظ‚ 50 ظ…طھط±طŒ ط¹ظ„ظ‰ ط´ط§ط±ط¹ظٹظ† ط§ظ…ط§ظ…ظٹ ظˆط®ظ„ظپظٹ + ط³ظƒظ‡ ط¨ط§ظ„ط¬ط§ظ†ط¨ ظˆظ…ط³ط¬ط¯طŒ طھطµظ„ط­ ظ„ظ„ظپط±ط²).
ط§ظ„ط³ط¹ط± = 3,800,000 ط±.ظ‚. ظ†ظ‡ط§ط¦ظٹ (290 ط±.ظ‚. ظ„ظ„ظپظˆطھ).
ظˆط¹ظ…ظˆظ„ظ‡ ط§ظ„ط´ط±ظƒط©
ط¬ظˆط§ظ„ 70401700', 6, 2, 19, false, 1, '', 3800000.00, NULL, NULL, 1218.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1756845298/uploads/ueolpyrccflnesot8yno.jpg}', '2025-09-02 20:34:59.321457', '2025-09-02 20:34:59.321457', 'a7b77bb9-8519-4201-8034-527b17d21de3', 'ط³ظ…ظٹط³ظ…ط©', 862, NULL, NULL, NULL, NULL, '{uploads/ueolpyrccflnesot8yno}');
INSERT INTO public.posts VALUES ('bf9b368d-f4c9-4a31-8996-7c0eb61c5dcb', 'ظ„ظ„ط¨ظٹط¹ ظ…ظ† ط§ظ„ظ…ط§ظ„ظƒ ط§ط±ط¶ ط¨ظ…ط¹ظٹط°ط± ط§ظ„ظˆظƒظٹط± ظ…ط³ط§ط­ط© ظ©ظ¦ظ  ظ…طھط± ط¹ ط´ط§ط±ط¹ظٹظ† ط²ط§ظˆظٹط© ظ…ط·ظ„ظˆط¨ ظ¢ ظ…ظ„ظٹظˆظ† ظˆ ظ¥ظ ظ  ط§ظ„ظپ ظ‚ط§ط¨ظ„ ط´ظ‰ط، ط¨ط³ظٹط·', 5, 2, 19, false, 1, 'ظ…ط¹ظٹط°ط± ط§ظ„ظˆظƒظٹط± ', 2500000.00, NULL, NULL, 960.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1758351047/uploads/ywflruu71g23pspg5jua.jpg}', '2025-09-20 06:50:48.099539', '2025-09-20 06:50:48.099539', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'ط§ظ„ظˆظƒظٹط±', 581, NULL, NULL, NULL, NULL, '{uploads/ywflruu71g23pspg5jua}');
INSERT INTO public.posts VALUES ('61c29b45-3f5c-4e38-ab82-1f95732be148', 'ط§ظ„ط³ظ„ط§ظ… ط¹ظ„ظٹظƒظ… 
ظ„ظ„ط¨ظٹط¹  ظ…ظ† ط§ظ„ظ…ط§ظ„ظƒ ظ…ط¨ط§ط´ط±ط±ط±ط±ط± ظپظٹظ„ط§ ط¨ط§ظ„ظ…ط·ط§ط± ظ…ط³ط§ط­ط© 431ظ… 
ظ…ظƒظˆظ†ظ‡ ظ…ظ† ظ¦ ط؛ط±ظپ ظˆظ…ظ„ط§ط­ظ‚ 
ظ…ط¤ط¬ط±ط© 9000ط±ظٹط§ظ„ 
ظ…ط¹ظ…ظˆظ„ ظ„ظٹظ‡ط§ طµظٹط§ظ†ظ‡ ط¨ط§ظ„ظƒط§ظ…ظ„ 
ظ…ط·ظ„ظˆط¨ 2,400,000', 1, 2, 18, false, 2, 'ط§ظ„ظ…ط·ط§ط± ', 2400000.00, 6, 5, 431.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1758955780/uploads/ohkczt3mlyer4emcxldz.jpg}', '2025-09-27 06:49:41.279824', '2025-09-27 06:49:41.279824', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'ط§ظ„ظ…ط·ط§ط±', 2092, NULL, NULL, NULL, NULL, '{uploads/ohkczt3mlyer4emcxldz}');
INSERT INTO public.posts VALUES ('f4e8b359-30df-4600-b55a-20996e9b64e7', 'ظ„ظ„ط¨ظٹط¹ ط§ط±ط¶ ظپظ‰ ط§ظ… ط§ظ„ط¹ظ…ط¯ ظ…ط³ط§ط­ط© 616ظ… ط¹ظ„ظ‰ ط´ط§ط±ط¹ ظ…ظˆظ‚ط¹ ظ…ظ…طھط§ط²
ط§ظ„ظ…ط£ظ…ظˆظ† ظ„ظ„ظˆط³ط§ط·ط© ط§ظ„ط¹ظ‚ط§ط±ظٹط© طھط±ط®ظٹطµ ط±ظ‚ظ… 201 ظ„ظ„طھظˆط§طµظ„
66141559 ', 3, 2, 19, false, 1, 'ط§ط±ط¶', 1820000.00, NULL, NULL, 616.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1769859348/uploads/xfmvzsswrhugfseqljh7.jpg}', '2026-01-31 11:35:50.774442', '2026-01-31 11:35:50.774442', '8c35d390-0b62-47dc-934d-02201a4e4051', 'ط§ظ… ط§ظ„ط¹ظ…ط¯ ', 647, NULL, NULL, NULL, NULL, '{uploads/xfmvzsswrhugfseqljh7}');
INSERT INTO public.posts VALUES ('7f5a42d3-625a-4157-b675-40efafbedb43', 'ظ…ظ† ط§ظ„ظ…ط§ظ„ظƒ 
ظ„ظ„ط¨ظٹط¹ ظپظٹظ„ط§ ظپظٹ ظ…ظ†ط·ظ‚ط© ط§ظ… ظ‚ط±ظ†  ظ…ط³ط§ط­ط© ط§ظ„ظپظٹظ„ط§ ط§ظ„ط§ط±ط¶ 500 ظ… ط§ظ„ظˆط§ط¬ظ‡ط© ط­ط¬ط± ط·ط¨ظٹط¹ظٹ طھط´ط·ظٹط¨ ظ…ظ…طھط§ط² 

طھطھظƒظˆظ† ط§ظ„ظپظٹظ„ط§ ظ…ظ† :-   
ط§ظ„ط¯ظˆط± ط§ظ„ط£ط±ط¶ظٹ : ظ…ط¬ظ„ط³ ط¯ط§ط®ظ„ظٹ ظ…ظ†ظپطµظ„ ظˆطµط§ظ„ظ‡ ظ…ط¹ ط­ظ…ط§ظ… ظˆظ…ط؛ط§ط³ظ„  ظ…ظپطھظˆط­ظٹظ† ط¹ظ„ظٹ ط¨ط¹ط¶ 
ط؛ط±ظپط©  ظ…ط§ط³طھط± ظˆط؛ط±ظپظ‡ ط·ط¹ط§ظ…  
 
ط§ظ„ط¯ظˆط± ط§ظ„ط§ظˆظ„ : 4 ط؛ط±ظپ ظ…ط§ط³طھط± ظˆطµط§ظ„ط© 
ط§ظ„ط¨ظ†طھ ظ‡ط§ظˆط³ : 2  ظ…ط§ط³طھط± ظ…ط¹ طµط§ظ„ط© ظƒط¨ظٹط±ظ‡ 

ط§ظ„ظ…ظ„ط­ظ‚ ط§ظ„ط®ط§ط±ط¬ظٹ : ظ…ط·ط¨ط® ط®ط§ط±ط¬ظٹ ظˆط؛ط±ظپظ‡ ظ…ط§ط³طھط± ظˆط³طھظˆط±  

ط¬ط¯ظٹط¯ظ‡ ط§ظ„ظپظٹظ„ط§ 
ط§ظ„ط³ط¹ط± 2850.000', 1, 2, 18, false, 1, 'ط§ظ… ظ‚ط±ظ†', 2850000.00, 7, 5, 500.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1757168890/uploads/kcuxiamhv128dyqta6mq.jpg}', '2025-09-06 14:28:10.93262', '2025-09-06 14:28:10.93262', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'ط§ظ… ظ‚ط±ظ†', 1679, NULL, NULL, NULL, NULL, '{uploads/kcuxiamhv128dyqta6mq}');
INSERT INTO public.posts VALUES ('758e4d2a-6cbd-4bcb-8a9f-0da30ec1ef19', '*ظ„ظ„ط¨ظٹط¹ ظ…ظ† ط§ظ„ظ…ط§ظ„ظƒ*
*ظپظٹظ„ط§ ط§ظ… ظ‚ط±ظ†  ظ…ط³ط§ط­ط© ط§ظ„ط£ط±ط¶ 500 ظ… ظ…ط³ط§ط­ط© ط§ظ„ط¨ظ†ط§ط، 600 ظ…* *طھط´ط·ظٹط¨ ط³ظˆط¨ط± ط¯ظٹظ„ظˆظƒط³ ظˆط¬ظ‡ط§طھ ط­ط¬ط± ط·ط¨ظٹط¹ظ‰ +ط§ط³ظ‚ظپ ط¬ط¨ط³ ط¨ظˆط±ط¯* *ط´ط¨ط§ط¨ظٹظƒ ظˆط£ط¨ظˆط§ط¨ ظٹظˆط¨ظٹ ظپظٹ ط³ظٹ*
 .
*طھطھظƒظˆظ† ظ…ظ†:- 7 ط؛ط±ظپ ظ…ط§ط³طھط±*  3 *ظ…ط·ط§ط¨ط® ط¨ط§ظ„ظپظٹظ„ط§ ط¯ط§ط®ظ„ظ‰ ظˆط®ط§ط±ط¬ظٹ ط¨ط§ظ„ظ…ظ„ط­ظ‚ ظˆظ…ط·ط¨ط® ط¨ظٹظ† ط§ظ„ط؛ط±ظپ 3* *طµط§ظ„ط§طھ ظˆظ…ط¬ظ„ط³ ط¯ط§ط®ظ„ ط§ظ„ظپظٹظ„ط§*
*ظ…ط¬ظ„ط³ ط®ط§ط±ط¬ظ‰ ظˆط؛ط±ظپط© ط³ط§ظٹظ‚ ط¨ط¨ط§ط¨ _ ط®ط§ط±ط¬ظ‰ ظ…ظ†ظپطµظ„ ط§ط³ط§ظ†ط³ظٹط± ط±ط§ظƒط¨*


*ظ…ط·ظ„ظˆط¨ 3 ظ…ظ„ظٹظˆظ† 400 ط§ظ„ظپ*', 6, 2, 18, false, 1, 'ط§ظ… ظ‚ط±ظ†', 3400000.00, 8, 5, 500.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1756649990/uploads/uwxduogfcxhhew2oqvss.jpg}', '2025-08-31 14:19:51.041982', '2025-08-31 14:19:51.041982', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'ط§ظ… ظ‚ط±ظ†', 1348, NULL, NULL, NULL, NULL, '{uploads/uwxduogfcxhhew2oqvss}');
INSERT INTO public.posts VALUES ('fe56a96c-de96-4da8-b398-23f243f96413', '*ظ„ظ„ط¨ظٹط¹*

*ط§ط±ط¶ ط¹ظ…ط§ط±ط§طھ ط¨ط§ظ„ط®ظˆط±*
 ط§ظپط§ط¯ظ‡
 ( ط§ط±ط¶ظٹ + ظ£ ط·ظˆط§ط¨ظ‚ + ط·ط§ط¨ظ‚ ط³ط·ط­ ظ…ط¹ ( ظ…ط­ظ„ طھط¬ط§ط±ظٹ ).
ط§ظ„ظ…ط³ط§ط­ظ‡ ظ¥ظ،ظ¦ ظ…طھط± ظ…ط±ط¨ط¹ 
ط´ط§ط±ط¹ ط§ظ…ط§ظ…ظٹ ظˆط®ظ„ظپظٹ.

ط­ط§ظ„ظٹط§ ط¹ظ„ظٹظ‡ط§ ظپظٹظ„ط§ ط¯ظˆط± ط§ط±ط¶ظٹ 
 ظ…ط³ط§ط­ظ‡ ظ¢ظ،ظ¤ ظ…طھط± .
* ظ…ط¤ط¬ط±ط© ط¨ ظ¥ظ¥ظ ظ  ( ط´ظٹظƒط§طھ ) ط§ظ„ط¹ظ‚ط¯ ظٹظ†طھظ‡ظٹ ط´ظ‡ط± ظ¨/ ظ¢ظ ظ¢ظ¦ ..  ظ‚ط§ط¨ظ„ ظ„ظ„طھط¬ط¯ظٹط¯.
*', 4, 2, 15, false, 3, 'ط§ظ„ط®ظˆط±', 2900000.00, NULL, NULL, 516.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1771183454/uploads/d02tfplqz45i3xsffmui.jpg}', '2026-02-15 19:24:15.35986', '2026-02-15 19:24:15.35986', '00008d13-0bba-4508-b679-1fdee2890c14', 'ط§ظ„ط®ظˆط±', 288, NULL, NULL, NULL, NULL, '{uploads/d02tfplqz45i3xsffmui}');
INSERT INTO public.posts VALUES ('1899713e-2b01-43b5-bf8d-b136d9f26059', 'ظ„ظ„ط¨ظٹط¹ ط¹ظ…ط§ط±ط© ط¬ط¯ظٹط¯ط© ظپظٹ ط¨ظ† ط¹ظ…ط±ط§ظ† 6 ط´ظ‚ظ‚ ظˆظˆط§ط³طھظˆط¯ظٹظˆ ط´ظ‚طھظٹظ† ط؛ط±ظپطھظٹظ† ظˆطµط§ظ„ظ‡ ظˆط­ظ…ط§ظ…ظٹظ† ظˆظ…ط·ط¨ط® ظˆ4 ط´ظ‚ظ‚ ط؛ط±ظپط© ظˆطµط§ظ„ط© ظˆط­ظ…ط§ظ…ظٹظ† ظˆظ…ط·ط¨ط® +ط§ط³طھط¯ظٹظˆ
ط§ظ„ظ…ط£ظ…ظˆظ† ظ„ظ„ظˆط³ط§ط·ط© ط§ظ„ط¹ظ‚ط§ط±ظٹط© طھط±ط®ظٹطµ ط±ظ‚ظ… 201 ', 1, 2, 20, false, 1, 'ط¹ظ…ط§ط±ط©', 4600000.00, 2, NULL, 241.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1765460880/uploads/hetxtokgeuwemfsp4jkn.jpg}', '2025-12-11 13:48:00.722919', '2025-12-11 13:48:00.722919', '8c35d390-0b62-47dc-934d-02201a4e4051', 'ط¨ظ† ط¹ظ…ط±ط§ظ†', 840, NULL, NULL, NULL, NULL, '{uploads/hetxtokgeuwemfsp4jkn}');
INSERT INTO public.posts VALUES ('a5cb24ae-691d-4bc5-a812-e09dc1a91875', 'ظ„ظ„ط¨ظٹط¹ ط§ط±ط¶ ظپظ‰ ط§ظ… ط§ظ„ط¹ظ…ط¯ ظ…ط³ط§ط­ط© 750ظ… ط¹ظ„ظ‰ ط´ط§ط±ط¹ ظ…ظˆظ‚ط¹ ظ…ظ…طھط§ط²
ط§ظ„ظ…ط£ظ…ظˆظ† ظ„ظ„ظˆط³ط§ط·ط© ط§ظ„ط¹ظ‚ط§ط±ظٹط© طھط±ط®ظٹطµ ط±ظ‚ظ… 201 ظ„ظ„طھظˆط§طµظ„
66141559 ', 3, 2, 19, false, 1, 'ط§ط±ط¶', 2220000.00, NULL, NULL, 750.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1769859445/uploads/tszrgp7gnthnoyso02nc.jpg}', '2026-01-31 11:37:26.118913', '2026-01-31 11:37:26.118913', '8c35d390-0b62-47dc-934d-02201a4e4051', 'ط§ظ… ط§ظ„ط¹ظ…ط¯ ', 796, NULL, NULL, NULL, NULL, '{uploads/tszrgp7gnthnoyso02nc}');
INSERT INTO public.posts VALUES ('0233be76-41d1-4e50-9c95-f137cde8d18e', 'ظ„ظ„ط¨ظٹط¹ ط§ط±ط¶ظٹظ† ظپظٹ ظ…ظ†ط·ظ‚ظ‡ ط§ظ„ظ„ظ‚ط·ظ‡ ظ…ط³ط§ط­ظ‡ ظƒظ„ ط§ط±ط¶ 453ظ… ط¹ظ„ظٹ ط´ط§ط±ط¹ ظˆط³ظƒظ‡ 
ظ…ظˆظ‚ط¹ ظ…ظ…طھط§ط² ط¨ط¬ظˆط§ط±ظ‡ط§ ظ…ط¯ط±ط³ظ‡ 
ظˆظ…ظ‚ط§ط¨ظ„ظ‡ط§ ظ…ط³ط¬ط¯ ًں•Œ 
ظ‚ط±ظٹط¨ ظ…ظ† ط§ظ„ظ…ط¯ظٹظ†ظ‡ ط§ظ„طھط¹ظ„ظٹظ…ظ‡ 
ظˆظ…ط³طھط´ظپظٹ ط³ط¯ط±ظ‡ 
', 1, 2, 19, false, 3, 'ط§ظ„ظ„ظ‚ط·ظ‡ ', 1900000.00, NULL, NULL, 453.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1771852001/uploads/dd6rfzbz6sdqgq3q48wc.jpg}', '2026-02-23 13:06:42.313112', '2026-02-23 13:06:42.313112', '00008d13-0bba-4508-b679-1fdee2890c14', 'ط§ظ„ظ„ظ‚ط·ظ‡', 296, NULL, NULL, NULL, NULL, '{uploads/dd6rfzbz6sdqgq3q48wc}');
INSERT INTO public.posts VALUES ('41bb6eee-1701-437d-a9bd-a9db507121bb', 'ظ„ظ„ط§ط³طھط«ظ…ط§ط± ط¨ط³ط¹ط± ظ…ظ…طھط§ط² 
ظ„ظ„ط¨ظٹط¹ ط¨ظٹطھ ط´ط¹ط¨ظٹ ظپظٹ ط§ظ„ظ…ط±ظ‡ ط§ظ„ط؛ط±ط¨ظٹظ‡ ظ‚ط±ظٹط¨ ط§ظ„ط´ط§ط±ط¹ ط§ظ„ط¹ط§ظ… ط§ظ„ظ…ط³ط§ط­ظ‡ : 904 ظ… 
ظپط§ط¶ظٹ ط­ط§ظ„ظٹط§ ظˆظٹظˆط¬ط¯ ظ…ط³طھط§ط¬ط± 16 ط§ظ„ظپ ط¬ط§ظ‡ط² ظ„طھظˆظ‚ظٹط¹ ط§ظ„ط¹ظ‚ط¯ 

ط§ظ„ط³ط¹ط± : 2,350,000', 1, 2, 18, false, 2, '', 235000.00, 9, 5, 904.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1765532374/uploads/xuj8nclfoxzqwf1zfuhz.jpg}', '2025-12-12 09:39:35.418503', '2025-12-12 09:39:35.418503', '18e15b48-2d06-47e9-b8ec-aa49ef39b847', '', 1004, NULL, NULL, NULL, NULL, '{uploads/xuj8nclfoxzqwf1zfuhz}');
INSERT INTO public.posts VALUES ('b441544f-e327-4888-9dc6-d2f7a121a7b8', 'ظ„ظ„ط¨ظٹط¹ ظ…ظ† ط§ظ„ظ…ط§ظ„ظƒ
ظپظٹظ„ط§ ط¨ط§ظ„ظˆظƒظٹط± ط¬ط¯ظٹط¯ظ‡
ظ…ط³ط§ط­ظ‡ ط§ظ„ط§ط±ط¶ 720 ظ… ظˆط§ظ„ط¨ظ†ط§ط، 780 ظ…
ظˆط§ط¬ظ‡ط§طھ ط­ط¬ط±
ظ…ط¬ظ„ط³ ط®ط§ط±ط¬ظ‰
ظˆط§طµظ„ظ‡ ظƒظ‡ط±ط¨ط§ط، ظˆظ…ط§ط، ظˆط¬ط§ظ‡ط²ظ‡ ظ„ظ„ط³ظƒظ†
ط§ط³ط§ظ†ط³ظٹط±
ط§ظ„ط¯ظˆط± ط§ظ„ط§ط±ط¶ظ‰ط›
ظ…ط¬ظ„ط³ ط¯ط§ط®ظ„ظ‰ ط¨ط§ظ„ظ…ط؛ط§ط³ظ„ + طµط§ظ„ظ‡ ظƒط¨ظٹط±ظ‡ + ط؛ط±ظپظ‡ ظ…ط§ط³طھط± + ظ…ط·ط¨ط® ط¯ط§ط®ظ„ظ‰
ط§ظ„ط¯ظˆط± ط§ظ„ط§ظˆظ„ :
طµط§ظ„ظ‡ + 4 ط؛ط±ظپ ظ…ط§ط³طھط± + ط¨ط§ظ†طھط±ظ‰
ط§ظ„ط¨ظ†طھ ظ‡ط§ظˆط³:
طµط§ظ„ظ‡ + ط؛ط±ظپطھظٹظ† ظ…ط§ط³طھط± + ط¨ط§ظ†طھط±ظ‰
ط§ظ„ظ…ظ„ط§ط­ظ‚ ط§ظ„ط®ط§ط±ط¬ظٹظ‡:
ظ…ط·ط¨ط® ط®ط§ط±ط¬ظ‰+ ط؛ط±ظپطھظٹظ† ط¨ط­ظ…ط§ظ…

ظ…ط·ظ„ظˆط¨ 4.500.000 ط±ظٹط§ظ„', 5, 2, 18, false, 1, 'ط§ظ„ظˆظƒظٹط± ', 4500000.00, 8, 5, 720.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1758350832/uploads/ygdqcoe7npvwsuohcy09.jpg}', '2025-09-20 06:47:13.80536', '2025-09-20 06:47:13.80536', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'ط§ظ„ظˆظƒظٹط± ', 713, NULL, NULL, NULL, NULL, '{uploads/ygdqcoe7npvwsuohcy09}');
INSERT INTO public.posts VALUES ('8d0307aa-70ee-412e-9b2b-8d9384c432ef', 'ظ„ظ„ط¥ظٹط¬ط§ط± ظ…ط­ظ„ط§طھ ظپظٹ ظپط±ظٹط¬ ظƒظ„ظٹط¨ ظ‚ط±ظٹط¨ط© ظ…ظ† ط´ط§ط±ط¹ ط§ظ„ظ…ط±ط®ظٹط© ط§ظ„طھط¬ط§ط±ظٹظ‡  ظ© + ظ¤ ظˆط­ظ…ط§ظ… ظˆظ…ط·ط¨ط® ظ…ط´طھط±ظƒ ظ„ط¬ظ…ظٹط¹ ط§ظ„ظ…ط­ظ„ط§طھ
ط§ظ„ط§ظٹط¬ط§ط± ظ¨.ظ¥ظ ظ  ط±ظٹط§ظ„ 
ظ…ط¨ط§ط´ط± ط¨ط¯ظˆظ† ط¹ظ…ظˆظ„ظ‡ 
', 1, 1, 16, true, 1, '', 8500.00, 1, 1, NULL, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1768424233/uploads/o6jpbtgcgup2drdahgro.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1768424233/uploads/rgn71lnmxzd9lyxiocvj.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1768424233/uploads/mv34ggqx0a0xpcgpclwi.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1768424233/uploads/da1cyci5gi7gwf1pfqzy.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1768424233/uploads/koolurybd7nvsmz3fyu0.jpg}', '2026-01-14 20:57:14.720606', '2026-01-14 20:57:14.720606', '801ae98c-66a3-40b6-a34b-9192d248636f', '', 1209, NULL, NULL, NULL, NULL, '{uploads/o6jpbtgcgup2drdahgro,uploads/mv34ggqx0a0xpcgpclwi,uploads/koolurybd7nvsmz3fyu0,uploads/da1cyci5gi7gwf1pfqzy,uploads/rgn71lnmxzd9lyxiocvj}');
INSERT INTO public.posts VALUES ('576b0623-4c18-48c6-8dd7-d712aa5f3e3b', 'ظ„ظ„ط¨ظٹط¹ ط«ظ„ط§ط« ظپظٹظ„ظ„ ظ„ظ„ط¨ظٹط¹  ظپظٹ ظ…ط¹ظٹط°ط± ط®ظ„ظپ ط§ظ„ظپط±ظˆط³ظٹظ‡ ظ…ط³ط§ط­ظ‡ ظƒظ„ ظپظٹظ„ط§ ط§ظ„ظپظٹظ„ط§ ط§ظ„ط§ط±ط¶ 440 ظ… ظˆط§ظ„ط¨ظ†ط§ط، 560ظ… طھط´ط·ظٹط¨ ط±ط§ظ‚ظٹ ظˆط§ط¬ظ‡ظ‡ ط­ط¬ط± ط·ط¨ظٹط¹ظٹ ط¬ط¨ط³ ط¨ط§ظ„ظƒط§ظ…ظ„ ط¨ظ‡ط§ ظ…ط¬ظ„ط³ ط®ط§ط±ط¬ظٹ ظˆط؛ط±ظپظ‡ ظ„ظ„ط³ط§ط¦ظ‚ ط¬ط¯ظٹط¯ظ‡ طھطھظƒظˆظ† ط§ظ„ظپظٹظ„ط§ ظ…ظ† :-ط§ظ„ط¯ظˆط± ط§ظ„ط§ط±ط¶ظ‰ : ظ…ط¬ظ„ط³  ط®ط§ط±ط¬ظٹ ظˆط؛ط±ظپظ‡ ظ„ظ„ط³ط§ط¦ظ‚ ظˆظ…ط¬ظ„ط³ ط¯ط§ط®ظ„ظ‰ ظˆطµط§ظ„ظ‡ ظƒط¨ظٹط±ظ‡ ظ…ظپطھظˆط­ظٹظ† ط¹ظ„ظٹ ط¨ط¹ط¶ ظˆط؛ط±ظپظ‡ ظ…ط§ط³طھط± ظˆط؛ط±ظپظ‡ ط·ط¹ط§ظ… ط§ظ„ط¯ظˆط± ط§ظ„ط§ظˆظ„ : 4 ط؛ط±ظپ ظ…ط§ط³طھط± ظˆطµط§ظ„ظ‡ ظƒط¨ظٹط±ظ‡ ط§ظ„ط¨ظ†طھ ظ‡ط§ظˆط³ :- ط؛ط±ظپطھظٹظ† ظ…ط§ط³طھط± ظˆطµط§ظ„ظ‡ ظƒط¨ظٹط±ظ‡ ط§ظ„ظ…ظ„ط­ظ‚ ط§ظ„ط®ط§ط±ط¬ظٹ :- ظ…ط·ط¨ط® ط®ط§ط±ط¬ظ‰ ظˆط؛ط±ظپظ‡ ظ…ط§ط³طھط± ظˆظ…ط؛ط³ظ„ظ‡ ظˆط³طھظˆط± طھط´ط·ظٹط¨ ط±ط§ظ‚ظٹ ظˆط®ط§طµ ط¨ظ‡ط§ ظ…ط¬ظ„ط³ ط®ط§ط±ط¬ظٹ ظˆط؛ط±ظپظ‡ ظ„ظ„ط³ط§ط¦ظ‚ ظ…ظˆظ‚ط¹ ظ…ظ…طھط§ط² ط®ظ„ظپ ط§ظ„ظپط±ظˆط³ظٹظ‡ ظ…ط·ظ„ظˆط¨ 3 ظ…ظ„ظٹظˆظ† ظˆ250

ط´ط±ظƒظ‡ ط§ظ„طھظˆط­ظٹط¯ ظ„ظ„ط¹ظ‚ط§ط±ط§طھ 
طھط±ط®ظٹطµ / 387', 2, 2, 18, false, 1, 'ظپظٹظ„ط§', 3250000.00, 7, 5, NULL, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1757891362/uploads/kcrsrm4khkn12se8qkxe.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1757891362/uploads/vb4dequhjuuysk4zodia.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1757891362/uploads/jpi68hwco7f2bdholmya.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1757891362/uploads/qynh6opevqfja27pjytk.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1757891362/uploads/h2njbp2oxqlwbgv0arfi.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1757891362/uploads/ksvofpbdpigemmyuq4xd.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1757891362/uploads/fnua0bb5jnnajpbmqlfl.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1757891362/uploads/cwlmfdsd5hceg4ix0jly.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1757891363/uploads/uu6q0p88wmo2qqms2mdt.jpg}', '2025-09-14 23:09:24.986646', '2025-09-14 23:09:24.986646', '0b84d6dd-a098-4d39-a6e5-e1dc95b64c0c', 'ظ…ط¹ظٹط°ط± ', 961, NULL, NULL, NULL, NULL, '{uploads/kcrsrm4khkn12se8qkxe,uploads/ksvofpbdpigemmyuq4xd,uploads/vb4dequhjuuysk4zodia,uploads/fnua0bb5jnnajpbmqlfl,uploads/qynh6opevqfja27pjytk,uploads/jpi68hwco7f2bdholmya,uploads/cwlmfdsd5hceg4ix0jly,uploads/h2njbp2oxqlwbgv0arfi,uploads/uu6q0p88wmo2qqms2mdt}');
INSERT INTO public.posts VALUES ('ed52c449-444f-455e-a239-73a89b05ca5e', 'ظ„ظ„ط¨ظٹط¹ 
ظپظٹظ„ط§ ط¨ط§ظ„ط±ظٹط§ظ† ظ…ط³ط§ط­ظ‡ 442 ظ… 
ظ…ط¤ط¬ط±ظ‡ ( 22700 ط±ظٹط§ظ„ )
ظ…ظˆظ‚ط¹ظ‡ط§ ظ…ظ…طھط§ط² ط¬ط¯ط§
ط¹ظ…ط±ظ‡ط§ 8 ط³ظ†ظˆط§طھ
ظ…ظ‚ط³ظ…ظ‡ 6 ط´ظ‚ظ‚ ظ†ط¸ط§ظ…ظٹظ‡ ط¹ظ„ظ‰ ط¹ظˆط§ط¦ظ„ 
ظƒظ„ ط´ظ‚ظ‡ ط´ظٹظƒط§طھظ‡ط§ ط¨ط±ظˆط­ظ‡ط§
ط§ظ„ظƒظ‡ط±ط¨ط§ط، ظˆط§ظ„ظ…ط§ط، ط¹ظ„ظ‰ ط§ظ„ظ…ط§ظ„ظƒ
ظ…ط·ظ„ظˆط¨ 2.800.000 ط±ظٹط§ظ„', 2, 2, 18, false, 2, 'ط§ظ„ط±ظٹط§ظ† ', 2800000.00, 7, 5, 442.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1758995527/uploads/ejghg8uuwuqycfymbueh.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1758995527/uploads/otwkge54lycaqslcmsks.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1758995527/uploads/uozucjltgckwhosboafs.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1758995527/uploads/bavbk7qoabji5zt0hhwl.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1758995527/uploads/iniaz0bf5vcoojityynf.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1758995527/uploads/xyfuemnd0knmo8k354lh.jpg}', '2025-09-27 17:52:08.59625', '2025-09-27 17:52:08.59625', '00008d13-0bba-4508-b679-1fdee2890c14', 'ط§ظ„ط±ظٹط§ظ†', 2197, NULL, NULL, NULL, NULL, '{uploads/otwkge54lycaqslcmsks,uploads/ejghg8uuwuqycfymbueh,uploads/bavbk7qoabji5zt0hhwl,uploads/iniaz0bf5vcoojityynf,uploads/uozucjltgckwhosboafs,uploads/xyfuemnd0knmo8k354lh}');
INSERT INTO public.posts VALUES ('2e8af654-fada-4522-b894-c5c16c564164', 'ظ„ظ„ط¨ظٹط¹ ظپظٹظ„ط§ ط­ظ„ظˆط© ظˆظˆط§ط³ط¹ط© ظˆظ…ط¬ط¯ط¯ظ‡ ط¨ط§ظ„ظƒط§ظ…ظ„ ظپظٹ ط§ظ„ط³ظٹظ„ظٹظ‡ ظ…ظ…ظˆظ‚ط¹ ظ…ظ…ظٹط² ظ…ط³ط§ط­ط© 1320 ظ… ط§طھظ…ط§ظ… ط§ظ„ط¨ظ†ط§ط، 2010
11ط؛ط±ظپظ‡ 9 ط­ظ…ط§ظ…ط§طھ 4 طµط§ظ„ط§طھ ط¯ط§ط®ظ„ظ‰ ظˆط®ط§ط±ط¬ظٹ ظˆظ…ط¬ظ„ط³ ط®ط§ط±ط¬ظٹ ظˆظ…ظ‚ظ„ط· ظˆط؛ط±ظپط© ط¯ط±ظٹظˆظ„ ظˆظ…ط·ط¨ط® ظˆط§ط³طھظˆط± ط®ط§ط±ط¬ظٹ ظˆط¹ط¯ط¯ 2 ظ…ط·ط¨ط® ط±ط¦ظٹط³ظٹ ظˆ2ظ…ط·ط¨ط® طھط­ط¶ظٹط±ظٹ ظˆظ…ظ„ط­ظ‚ظٹظ†  ظˆط­ط¯ظٹظ‚ط© ظپظٹ ط§ظ„ط­ظˆط´ ظˆط·ط¨ظٹظ„ط§طھ ط§ظ„ظپظ„ظ‡ 
ظƒط§ظ† ط§ظ„ظ…ط§ظ„ظƒ ط³ط§ظƒظ† ظپظٹظ‡ط§ ط¬ط§ظ‡ط²ظ‡ ظ„ظ„ط³ظƒظ† ظ…ط§طھط­طھط§ط¬ طµظٹط§ظ†ظ‡
ظ…ط·ظ„ظˆط¨ ظ„ظ„ط¨ظٹط¹ 4 ظ…ظ„ظٹظˆظ† ظˆ 200 ط§ظ„ظپ', 1, 1, 18, false, 2, '', 4000000.00, 10, 5, 1320.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1753605825/uploads/fyqitnd8gjhdcdnfsusv.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1753605825/uploads/ohibrlrs4cs8mhye7qje.jpg}', '2025-07-27 08:43:46.646514', '2025-07-27 08:43:46.646514', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'ط§ظ„ظ…ط¹ط±ط§ط¶ ', 775, NULL, NULL, NULL, NULL, '{}');
INSERT INTO public.posts VALUES ('1d67d7de-9346-4be7-8149-935de681ea40', 'ظ„ظ„ط¨ظٹط¹ ظپظٹظ„ط§ ط§ط²ط؛ظˆظ‰
ظ…ط³ط§ط­ظ‡  645ظ… ط§ظ„ط§ط±ط¶ 
ط§ظ„ط¨ظ†ط§ط، 700ظ… 

ط§ظ„ط¯ظˆط± ط§ظ„ط§ط±ط¶ظ‰ 
ظ…ط¬ظ„ط³ ط®ط§ط±ط¬ظ‰ ظˆط؛ط±ظپظ‡ ط³ط§ط¦ظ‚ 
ظ…ط¬ظ„ط³ ط¯ط§ط®ظ„ظ‰ ظƒط¨ظٹط± ظˆطµط§ظ„ظ‡ ظƒط¨ظٹط±ظ‡ 
ط؛ط±ظپظ‡ ظ…ط§ط³طھط± 
ط§ظ„ط¯ظˆط± ط§ظ„ط§ظˆظ„ 
4 ط؛ط±ظپ ظ…ط§ط³طھط± ظˆطµط§ظ„ظ‡ 

ط§ظ„ط¨ظ†طھ ظ‡ط§ظˆط³ 
ط؛ط±ظپطھظٹظ† ظ…ط§ط³طھط± ظˆطµط§ظ„ظ‡ 

طھظƒظٹظٹظپ ظ…ط±ظƒط²ظ‰ 
ظ…طµط¹ط¯ 
ط§ط±ط¶ظٹط§طھ ط±ط®ط§ظ… 
ظˆط¬ظ‡ط§طھ ط­ط¬ط± 
ط¬ط¨ط³ ط¨ظˆط±ط¯ ظƒط§ظ…ظ„ظ‡ 
طھط´ط·ظٹط¨ ط³ظˆط¨ط± ط¯ظٹظ„ظˆظƒط³ 

ظ…ظˆظ‚ط¹ ظ…ظ…طھط§ط² ط¬ط¯ط§ 
ظ…ظ‚ط§ط¨ظ„ ط§ظ„ظ…ط³ط¬ط¯
ظ‚ط±ظٹط¨ ط§ظ„ظ…ظٹط±ظ‡
ط¯ط±ط§ظٹط´ ظٹظˆ ط¨ظٹ ظپظٹ ط³ظٹ 
ط؛ط±ظپظ‡ ط³ط§ط¦ظ‚ 

طھط´ط·ظٹط¨ ط±ط§ظ‚ظ‰ ط¬ط¯ط§ ظˆط®ط§طµ 
ظˆط§طµظ„ظ‡ ظƒظ‡ط±ظ…ط§ط، ظˆظ…ظƒظٹظپط§طھ 

ظ…ط·ظ„ظˆط¨ 5 ظ…ظ„ظٹظˆظ† 600 ط§ظ„ظپ


طھظˆط§طµظ„ ظ…ط¹ظ†ط§ 
ظ…ط­ظ…ط¯ ط®ط§ط·ط± 
50067840
ظ…ط±ط³ط§ظ†ط§ ظ„ظ„ظˆط³ط§ط·ط© ط§ظ„ط¹ظ‚ط§ط±ظٹظ‡ 
طھط±ط®ظٹطµ ظˆط²ط§ط±ظ‡ ط§ظ„ط¹ط¯ظ„ ط±ظ‚ظ… ', 2, 2, 18, false, 1, 'ظپظٹظ„ط§ ط³ظƒظ†ظٹظ‡ ', 5600000.00, 7, 5, 645.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1762118991/uploads/cp7adz6iqg31jean4cta.jpg}', '2025-11-02 21:29:52.896351', '2025-11-02 21:29:52.896351', 'c0461100-60ce-404a-86a6-86610b5c2f89', 'ط§ط²ط؛ظˆظ‰', 329, NULL, NULL, NULL, NULL, '{uploads/cp7adz6iqg31jean4cta}');
INSERT INTO public.posts VALUES ('1b940a3d-a9b8-4baa-b2a8-69c52e92cfd8', 'ظ„ظ„ط¨ظٹط¹ ظ…ظ† ط§ظ„ظ…ط§ظ„ظƒ

ظپظٹظ„ط§ ط¨ط§ظ„ظˆظƒظٹط± ط¬ط¯ظٹط¯ظ‡
ط¹ظ„ظ‰ ط´ط§ط±ط¹ظٹظ† ط²ط§ظˆظٹظ‡
ظ…ط³ط§ط­ظ‡ ط§ظ„ط§ط±ط¶ 758 ظ… ظˆط§ظ„ط¨ظ†ط§ط، 900 ظ…
ظˆط§ط¬ظ‡ط§طھ ط­ط¬ط±
ظ…ط¬ظ„ط³ ط®ط§ط±ط¬ظ‰
ط§ط³ط§ظ†ط³ظٹط±
ط؛ط±ظپظ‡ ط³ط§ط¦ظ‚
ط§ظ„ط¯ظˆط± ط§ظ„ط§ط±ط¶ظ‰:
ظ…ط¬ظ„ط³ ط¯ط§ط®ظ„ظ‰ ظˆطµط§ظ„ظ‡ ظ…ظپطھظˆط­ظٹظ† ظپظ‰ ط¨ط¹ط¶ + ط؛ط±ظپطھظٹظ† ظ…ط§ط³طھط± + ظ…ط·ط¨ط® ط¯ط§ط®ظ„ظ‰
ط§ظ„ط¯ظˆط± ط§ظ„ط§ظˆظ„:
طµط§ظ„ظ‡ ظƒط¨ظٹط±ظ‡ + 4 ط؛ط±ظپ ظ…ط§ط³طھط± 
ط§ظ„ط¨ظ†طھ ظ‡ط§ظˆط³:
طµط§ظ„ظ‡ + ط؛ط±ظپطھظٹظ† ظ…ط§ط³طھط± + ط؛ط±ظپظ‡ ط؛ط³ظٹظ„ ظˆط§ط³طھظˆط±

ط§ظ„ظ…ظ„ط§ط­ظ‚ ط§ظ„ط®ط§ط±ط¬ظٹظ‡:
ظ…ط·ط¨ط® ط®ط§ط±ط¬ظ‰ + ط؛ط±ظپظ‡ ط¨ط­ظ…ط§ظ…

ظ…ط·ظ„ظˆظ„ 5.200.000 ط±ظٹط§ظ„', 5, 2, 18, false, 1, 'ط§ظ„ظˆظƒظٹط± ', 5200000.00, 9, 5, 758.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1758351195/uploads/dioktkh8cgaqv5rofvpl.jpg}', '2025-09-20 06:53:16.8039', '2025-09-20 06:53:16.8039', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'ط§ظ„ظˆظƒظٹط± ', 715, NULL, NULL, NULL, NULL, '{uploads/dioktkh8cgaqv5rofvpl}');
INSERT INTO public.posts VALUES ('aea23fbd-0e96-4b7d-b052-62650d7724f6', 'ظ…ظ† ط§ظ„ظ…ط§ظ„ظƒ 
ظ„ظ„ط¨ظٹط¹ ظپظٹظ„ط§ ظپط§ط®ط±ط© ط¨ط§ظ… ظ‚ط±ظ† 
ظ…ط³ط§ط­ط© ط§ظ„ط§ط±ط¶ ظ¤ظ¢ظ  ظ…طھط± ظ…ط±ط¨ط¹ ظ…ط³ط§ط­ط© ط§ظ„ط¨ظ†ط§ط، ظ¤ظ£ظ¥ ظ…طھط± ظ…ط±ط¨ط¹
ظ…ظˆظ‚ط¹ ظ…ظ…ظٹط² ط¨ط§ظ„ظ‚ط±ط¨ ظ…ظ† ط§ظ„ط·ط±ظٹظ‚ ط§ظ„ط³ط§ط­ظ„ظٹ

ظ…ط¬ظ„ط³ ط®ط§ط±ط¬ظٹ ظ…ظ†ظپطµظ„ 
ط§ظ„ط·ط§ط¨ظ‚ ط§ظ„ط£ط±ط¶ظٹ: ظ…ط¬ظ„ط³ ط¯ط§ط®ظ„ظٹ ظ…ط¹ ط؛ط±ظپط© ط·ط¹ط§ظ… + طµط§ظ„ط© + ط؛ط±ظپط© ظ…ط§ط³طھط±
ط§ظ„ط·ط§ط¨ظ‚ ط§ظ„ط«ط§ظ†ظٹ: ظ¤ ط؛ط±ظپ ظ…ط§ط³طھط± ظˆطµط§ظ„ظ‡
ط§ظ„ط¨ظ†طھ ظ‡ط§ظˆط³: ط؛ط±ظپطھظٹظ† ظ…ط§ط³طھط± ظˆط§ط³طھظˆط± ظˆطµط§ظ„ظ‡ 
ط§ظ„ظ…ظ„ط­ظ‚ ط§ظ„ط®ظ„ظپظٹ: ظ…ط·ط¨ط® ط®ط§ط±ط¬ظٹطŒ ظˆط؛ط±ظپط© ط؛ط³ظٹظ„طŒ ظˆط؛ط±ظپط© ظ„ظ„ط®ط§ط¯ظ…ط©طŒ
ظ…ط¬ظ„ط³ ط®ط§ط±ط¬ظٹ ظ…ظ†ظپطµظ„ 
ظ…ظˆظ‚ظپ ط³ظٹط§ط±ط© ظٹط§ط®ط° ظ£ط³ظٹط§ط±ط§طھ
طھط´ط·ظٹط¨ ظ…ظ…ظٹط² طŒ ط¬ط¨ط³ ط¨ظˆط±ط¯ 
ظٹظˆط¨ظٹ ظپظٹ ط³ظٹ
ظ…ط·ظ„ظˆط¨
ظ¢.ظ©ظ ظ ظ…ظ„ظٹظˆظ†', 6, 2, 18, false, 1, 'ط§ظ… ظ‚ط±ظ†', 2900000.00, 7, 5, 420.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1758199073/uploads/rjnjvdngbfleze8koece.jpg}', '2025-09-18 12:37:54.085112', '2025-09-18 12:37:54.085112', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'ط§ظ… ظ‚ط±ظ†', 1032, NULL, NULL, NULL, NULL, '{uploads/rjnjvdngbfleze8koece}');
INSERT INTO public.posts VALUES ('9116b2c7-1d47-49d3-9b05-ea7a20e3e17c', 'ظپظٹظ„ط§ ظ„ظ„ط¨ظٹط¹ ظپظٹ ط§ظ„طµط®ط§ظ…ط© ظ…ظ…طھط§ط²ظ‡
ظ…ط³ط§ط­ط© ط§ظ„ط§ط±ط¶ 565
ظ…ط³ط§ط­ط© ط§ظ„ط¨ظ†ط§ط، 701 
ط§ظ„ط¯ظˆط± ط§ظ„ط§ط±ط¶ظٹ: طµط§ظ„ط© ظˆ ظ…ط¬ظ„ط³ ظ…ظپطھظˆط­ظٹظ† ط¹ظ„ظ‰ ط¨ط¹ط¶ ظ…ط¹ ظ…ط؛ط§ط³ظ„ ظˆ ط­ظ…ط§ظ… ظˆظ…ط·ط¨ط® ط¯ط§ط®ظ„ظٹ ظˆط؛ط±ظپط© ط·ط¹ط§ظ…+ ط؛ط±ظپط© ظ†ظˆظ… ظ…ط§ط³طھط±
ط§ظ„ط¯ظˆط± ط§ظ„ط£ظˆظ„: طµط§ظ„ط© + 4 ط؛ط±ظپ ظ†ظˆظ… ظ…ط§ط³طھط± ظ…ط¹ ط؛ط±ظپ ط§ظ„ظ…ظ„ط§ط¨ط³
ط¨ظ†طھ ظ‡ط§ظˆط³: طµط§ظ„ط© + ط؛ط±ظپطھظٹظ† ظ†ظˆظ… ظ…ط§ط³طھط±
ط§ظ„ظ…ظ„ط­ظ‚: ط؛ط±ظپط© ظˆط­ظ…ط§ظ… ظˆ ظ…ط·ط¨ط® ط®ط§ط±ط¬ظٹ ظˆ ط؛ط±ظپط© ط§ظ„ط؛ط³ظٹظ„
ط؛ط±ظپط© ظ„ظ„ط³ط§ظٹظ‚ ظ…ط¹ ط­ظ…ط§ظ…ظ‡ط§
ظ…ط¬ظ„ط³ ط®ط§ط±ط¬ظٹ ظ…ط¹ ظ…ط؛ط§ط³ظ„ ظˆط­ظ…ط§ظ…
ظ…طµط¹ط¯
طھط´ط·ظٹط¨ ط±ط§ظ‚ظ‰  
ط§ظ„ط³ط¹ط± 4.200.000 ط±ظٹط§ظ„ ظ‚ط·ط±ظٹ', 6, 2, 18, false, 1, 'ط§ظ„طµط®ط§ظ…ظ‡', 4200000.00, 8, 5, 565.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1772100441/uploads/rzl5kduguahfcq4j62bt.jpg}', '2026-02-26 10:07:22.962482', '2026-02-26 10:07:22.962482', '00008d13-0bba-4508-b679-1fdee2890c14', 'ط§ظ„طµط®ط§ظ…ظ‡', 268, NULL, NULL, NULL, NULL, '{uploads/rzl5kduguahfcq4j62bt}');
INSERT INTO public.posts VALUES ('878096d3-f73e-4f3e-89a8-56f4d1540ba5', 'ظ„ظ„ط¨ظٹط¹ ط§ط±ط¶ ظ„ظ„ط¨ظٹط¹ ط§ط±ط¶ ظپظٹ ط§ظ„ط°ط®ظٹط±ظ‡ 1616 ظ… 
ط¹ظ„ظٹ ط«ظ„ط§ط« ط´ظˆط§ط±ط¹ ظˆط³ظƒظ‡ ظٹط¬ظˆط² ظپط±ط²ظ‡ط§ ط­ط³ط¨ ط§ظ„ظ…ط§ظ„ظƒ ط§ظ„ظ‰ ط«ظ„ط§ط« ظ‚ط·ط¹ ', 4, 2, 19, false, 3, 'ط§ظ„ط°ط®ظٹط±ظ‡', 3565000.00, NULL, NULL, 1616.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1762878038/uploads/wjz8mfmcbglvrhlirhrb.jpg}', '2025-11-11 16:20:38.959587', '2025-11-11 16:20:38.959587', '00008d13-0bba-4508-b679-1fdee2890c14', 'ط§ظ„ط°ط®ظٹط±ظ‡', 452, NULL, NULL, NULL, NULL, '{uploads/wjz8mfmcbglvrhlirhrb}');
INSERT INTO public.posts VALUES ('713612a3-9e01-449a-95a3-7dbf56c70f5a', 'ظ„ظ„ط¨ظٹط¹ ظ…ظ† ط§ظ„ظ…ط§ظ„ظƒ 

ظپظٹظ„ط§ ظپظ‰ ط§ظ„ظˆظƒظٹط±  
ظ…ط³ط§ط­ط© ط§ظ„ط§ط±ط¶  516  ظ…طھط± 
ظ…ط³ط§ط­ظ‡ ط§ظ„ط¨ظ†ط§ط،   550   ظ…طھط± 
طھطھظƒظˆظ† ظ…ظ† :- 
ط§ظ„ط¯ظˆط± ط§ظ„ط§ط±ط¶ظٹ : 
ظ…ط¬ظ„ط³ ط¯ط§ط®ظ„ظٹ ظˆطµط§ظ„ظ‡ ظ…ظپطھظˆط­ظٹظ†  
ظˆط؛ط±ظپظ‡ ظ…ط§ط³طھط±  ظˆظ…ط·ط¨ط® ط¯ط§ط®ظ„ظٹ 
ط§ظ„ط¯ظˆط± ط§ظ„ط§ظˆظ„ :
ظ¤ ط؛ط±ظپ ظ…ط§ط³طھط± ظˆطµط§ظ„ظ‡ 
ط§ظ„ط¨ظ†طھ ظ‡ط§ظˆط³ : 
ظ¢  ط؛ط±ظپط©  ظ…ط§ط³طھط± 
ط§ظ„ظ…ظ„ط­ظ‚:
ط؛ط±ظپط© ط®ط§ط¯ظ…ظ‡ + ظ…ط·ط¨ط® ط®ط§ط±ط¬ظ‰  +ظ…ط؛ط³ظ„ط©

ظ…ط·ظ„ظˆط¨  :  3.100.000  ط±ظٹط§ظ„', 5, 2, 18, false, 1, 'ط§ظ„ظˆظƒظٹط± ', 3100000.00, 8, 5, 516.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1758351347/uploads/utljwlyxnklycicms7pn.jpg}', '2025-09-20 06:55:48.76236', '2025-09-20 06:55:48.76236', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'ط§ظ„ظˆظƒظٹط± ', 824, NULL, NULL, NULL, NULL, '{uploads/utljwlyxnklycicms7pn}');
INSERT INTO public.posts VALUES ('8532c9d1-5461-4212-9e6d-9db189291f85', 'ظپظٹظ„ط§ ظ„ظ„ط¨ظٹط¹ ط§ظ„طµط®ط§ظ…ظ‡ 
ظ…ط³ط§ط­ظ‡  619ظ… 
ط´ط§ط±ط¹ظٹظ†  ط²ط§ظˆظٹظ‡ 
طھط´ط·ظٹط¨ ط³ظˆط¨ط± 
ط§ط±ط¶ظٹط§طھ ط±ط®ط§ظ… 
ط¬ط¨ط³ ط¨ظˆط±ط¯ 

طھطھظƒظˆظ† ظ…ظ† :- 
ط§ظ„ط¯ظˆط± ط§ظ„ط§ط±ط¶ظ‰: 
ظ…ط¬ظ„ط³ ط¯ط§ط®ظ„ظ‰ ظˆطµط§ظ„ظ‡ ظˆط؛ط±ظپظ‡ ظ…ط§ط³طھط± 
ط§ظ„ط¯ظˆط± ط§ظ„ط§ظˆظ„ : 
4 ط؛ط±ظپ ظ…ط§ط³طھط± ظˆطµط§ظ„ظ‡ 
ط§ظ„ط¨ظ†طھ ظ‡ط§ظˆط³ :ط؛ط±ظپظ‡ ظ…ط§ط³طھط± 
ظ…ظ„ط­ظ‚ ط®ط§ط±ط¬ظٹ : 
ظ…ط·ط¨ط® ط®ط§ط±ط¬ظ‰ ظˆط؛ط±ظپظ‡ ظ…ط§ط³طھط± 
ظ…ط¬ظ„ط³ ط®ط§ط±ط¬ظ‰ 
ظˆط§ط¬ظ‡ظ‡ ط­ط¬ط± ط·ط¨ظٹط¹ظ‰ ط§ط±ط¶ظٹط§طھ ط±ط®ط§ظ… 
ط¬ط¨ط³ ط¨ظˆط±ط¯ ظƒط§ظ…ظ„ ط§ظ„ظپظٹظ„ط§ 
ظ…ظˆظ‚ط¹ ظ…ظ…طھط§ط² ط¬ط¯ط§

ظ…ط·ظ„ظˆط¨   
3 ظ…ظ„ظٹظˆظ† 800 ط§ظ„ظپ

طھظˆط§طµظ„ ظ…ط¹ظ†ط§ 
ظ…ط­ظ…ط¯ ط®ط§ط·ط± 
50067840
ظ…ط±ط³ط§ظ†ط§ ظ„ظ„ظˆط³ط§ط·ط© ط§ظ„ط¹ظ‚ط§ط±ظٹظ‡ 
طھط±ط®ظٹطµ ظˆط²ط§ط±ظ‡ ط§ظ„ط¹ط¯ظ„ ط±ظ‚ظ… 54
', 6, 2, 18, false, 1, 'ظپظٹظ„ط§ ط³ظƒظ†ظٹظ‡ ', 3800000.00, 6, 5, 619.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1762119374/uploads/mztejrzgabihwuvm1fb9.jpg}', '2025-11-02 21:36:15.935057', '2025-11-02 21:36:15.935057', 'c0461100-60ce-404a-86a6-86610b5c2f89', 'ط§ظ„طµط®ط§ظ…ظ‡ ', 383, NULL, NULL, NULL, NULL, '{uploads/mztejrzgabihwuvm1fb9}');
INSERT INTO public.posts VALUES ('b077aa5a-0259-4e57-9fd3-bd7e18b20fa5', ' 

ط§ظ„ط³ظ„ط§ظ… ط¹ظ„ظٹظƒظ… 
ظ„ظ„ط¨ظٹط¹ ط¨ظٹطھ ط´ط¹ط¨ظٹ ظپظٹ ط§ظ„ظ†ط§طµط±ظٹظ‡ 
ظ…ط³ط§ط­ظ‡ 1200ظ…(ظٹظ†ظپط±ط²)
ط´ط§ط±ط¹ظٹظ† ط§ظ…ط§ظ…ظٹ ظˆط®ظ„ظپظٹ 
ط´ط§ط±ط¹ 16ظ… ظˆط´ط§ط±ط¹ 24ظ…
ظ…ظˆظ‚ط¹ ظ…ظ…طھط§ط² ظ…ظ‚ط§ط¨ظ„ (ظ…ط±ظƒط² طµط­ظٹ ط§ظ„ط؛ط±ط§ظپظ‡)
ط§ظ„ظ…ط§ظ„ظƒ ط³ط§ظƒظ† ظپظٹظ‡ 
ظ…ط·ظ„ظˆط¨ 5,200,000', 2, 2, 19, false, 3, 'ط§ظ„ط؛ط±ط§ظپظ‡', 5200000.00, NULL, NULL, 1200.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1762879996/uploads/bpbipry9pm54jamwifvg.jpg}', '2025-11-11 16:53:17.652924', '2025-11-11 16:53:17.652924', '00008d13-0bba-4508-b679-1fdee2890c14', 'ط§ظ„ط؛ط±ط§ظپظ‡ ', 377, NULL, NULL, NULL, NULL, '{uploads/bpbipry9pm54jamwifvg}');
INSERT INTO public.posts VALUES ('49d6444b-e3c7-493a-bdef-d248f6e67d7f', '*ط§ظ„ط³ظ„ط§ظ… ط¹ظ„ظٹظƒظ… ظ„ظ„ط¨ظٹط¹ ط£ط±ط¶ ط§ظ„ظˆط¹ط¨ ظ©ظ،ظ© ظ… 
ط¹ظ„ظ‰ ط´ط§ط±ط¹ظٹظ† ط£ظ…ط§ظ…ظ‰ ظˆط®ظ„ظپظ‰ 
ظ…ظ†ظ‡ظ… ط´ط§ط±ط¹ ط±ط¦ظٹط³ظٹ ظ£ظ¢ ظ…  
ظˆط³ظƒط© ظ…ظˆظ‚ط¹ ظ…ظ…طھط§ط² 
ظ‚ط±ظٹط¨ ط³ط¨ط§ظٹط± 
ظ…ط·ظ„ظˆط¨ ظ¥ ظ…ظ„ظٹظˆظ†*', 1, 2, 19, false, 1, 'ط§ظ„ظˆط¹ط¨ ', 5000000.00, NULL, NULL, 919.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1762244765/uploads/djtbp2s50rgherfprban.jpg}', '2025-11-04 08:26:05.956801', '2025-11-04 08:26:05.956801', '00008d13-0bba-4508-b679-1fdee2890c14', 'ط§ظ„ظˆط¹ط¨ ', 298, NULL, NULL, NULL, NULL, '{uploads/djtbp2s50rgherfprban}');
INSERT INTO public.posts VALUES ('77dee17f-ca12-47df-80da-d3d5ccd6aebf', 'ط¨ظٹطھ ط§ط±ط¶ظ‰ ط¹ظ„ظ‰ ط´ط§ط±ط¹ظٹظ† ط²ط§ظˆظٹظ‡ 
ظپظ‰ ظ…ط±ظٹط® ظ…ظˆظ‚ط¹ ظ…ظ…طھط§ط² 
ظ…ظ‚ط§ط¨ظ„ ظ…ط³ط¬ط¯ 
ظ…ط¬ط¯ط¯ ط¨ط§ظ„ظƒط§ظ…ظ„ ', 2, 2, 19, false, 3, 'ظ…ط±ظٹط® ', 2600000.00, NULL, NULL, 550.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1773009538/uploads/i0vnrcckzs7kcunxx76f.jpg}', '2026-03-08 22:38:59.50925', '2026-03-08 22:38:59.50925', '00008d13-0bba-4508-b679-1fdee2890c14', 'ظ…ط±ظٹط® ', 340, NULL, NULL, NULL, NULL, '{uploads/i0vnrcckzs7kcunxx76f}');
INSERT INTO public.posts VALUES ('c082624b-3cc1-470a-9a5f-21c8476b6fdd', 'ظپظٹظ„ط§ ظ…ط³طھظ‚ظ„ط© ط¨ط§ظ„ط؛ط±ط§ظپط©  ظ¦ ط؛ط±ظپ ظˆ ظ§ ط­ظ…ط§ظ…ط§طھ ظˆ ظ…ط¬ظ„ط³ ط¯ط§ط®ظ„ظ‰ ظˆ طµط§ظ„طھظٹظ† ظˆ ط­ظˆط´ ط§ظ…ط§ظ…ظ‰ ظˆ ظ…ط¬ظ„ط³ ط¯ط§ط®ظ„ظ‰', 1, 2, 18, true, 2, '', 15000.00, 6, 5, 45050.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1752686321/uploads/oywzjkxc5ws0cq23ntgx.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1752686321/uploads/utrinihhwmihzujlly3o.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1752686321/uploads/rs0sbrrtrgo8xur9etxt.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1752686321/uploads/cglukbuyfxrtnxuukfv7.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1752686320/uploads/cw5qv1sbzeubymynnqdu.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1752686320/uploads/p0tz8l45xaquverklat3.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1752686320/uploads/p30ea816p1enaueq0tpf.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1752686320/uploads/qtzxp0mraehta6iajgho.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1752686320/uploads/c8v9d7b3yp48jkymznje.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1752686320/uploads/bvpiegilnhmpqsnnhzms.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1752686320/uploads/cw19ckfcvdhlafjtwffm.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1752686320/uploads/oc7mgw0p0fp2lpw3nobh.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1752686320/uploads/gqssboewjihpcdb6hvqh.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1752686321/uploads/u7ubso3o2jzec25kawgt.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1752686320/uploads/geh31cb0y8lpegi7vdcb.jpg}', '2025-07-16 17:18:43.262722', '2025-07-16 17:18:43.262722', '479690a3-da25-4188-bf72-eade4825f30c', '', 817, NULL, NULL, NULL, NULL, '{}');
INSERT INTO public.posts VALUES ('614ea843-7165-4c42-87a3-ee873d26b15e', ' 
ظ„ظ„ط¨ظٹط¹ ط¹ظ…ط§ط±ظ‡ ظ…ظ…ظٹط²ظ‡ ظپظ‰ ط§ظ„ط³ط¯ ط¬ط¯ظٹط¯ظ‡ ط§ظ„ط¹ظ…ط§ط±ظ‡ ظ…ط³ط§ط­ط© ط§ظ„ط§ط±ط¶ 350 ظ… ط§ط±ط¶ظ‰ ظˆ5 ط·ظˆط§ط¨ظ‚ 
طھطھظƒظˆظ† ظ…ظ† 10 ط´ظ‚ظ‡ ظˆط³طھط¯ظٹظˆ 
ظƒظ„ ط´ظ‚ط© ط¨ظ‡ط§ 2 ط؛ط±ظپ ظ†ظˆظ… ظˆ2 ط­ظ…ط§ظ… ظˆطµط§ظ„ط© ظˆظ…ط·ط¨ط® 
ظ…ظپط±ظˆط´ظ‡ ط§ظ„ظپط±ط´ ط¬ط¯ظٹط¯ 
ط§ظ„ظ…ط§ظ„ظƒ ظ…ظ‚ط¯ظ… ط¹ظ„ظٹ طھط±ط®ظٹطµ ط´ظ‚ظ‚ ظپظ†ط¯ظ‚ظ‡ ط¨طھط§ط®ط° طھط±ط®ظٹطµ ط´ظ‚ظ‚ ظپظ†ط¯ظ‚ظٹظ‡ 

ظ…ط·ظ„ظˆط¨ 9 ظ…ظ„ظٹظˆظ† ظˆ500 ط§ظ„ظپ', 1, 2, 20, false, 1, 'ط§ظ„ط³ط¯ ', 9500000.00, 10, NULL, 350.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1762782157/uploads/k0t4n2qtexriffo1mijb.jpg}', '2025-11-10 13:42:38.953136', '2025-11-10 13:42:38.953136', '00008d13-0bba-4508-b679-1fdee2890c14', 'ط§ظ„ط³ط¯ ', 655, NULL, NULL, NULL, NULL, '{uploads/k0t4n2qtexriffo1mijb}');
INSERT INTO public.posts VALUES ('9b93b91f-e8ef-49bb-bae0-c4b2f889c6cd', '*ظ„ظ„ط¨ظٹط¹*
ظ…ط¤ط¬ط±ظ‡ ط´ظٹظƒ ظˆط§ط­ط¯
ط¹ظ…ط§ط±ظ‡ ظپظٹ ط§ظ„ظ…ظ†طµظˆط±ظ‡ 35 ط´ظ‚ط©
 ظ…ط³ط§ط­ظ‡ ظ©ظ ظ¦ ظ…طھط± ط¹ظ„ظ‰ ط´ط§ط±ط¹ظٹظ†.

*ط¹ط¨ط§ط±ط© ط¹ظ†*
( ط¨ط³ظ…ظ†طھ + ط§ط±ط¶ظٹ + 7 ط§ط¯ظˆط§ط± ط·ظˆط§ط¨ظ‚ ظ…طھظƒط±ط±ظ‡).
 ط§ظ„ظ‚ط¨ظˆ ظˆط§ظ„ط·ط§ط¨ظ‚ ط§ظ„ط§ط±ط¶ظٹ ط¹ط¨ط§ط±ظ‡ ط¹ظ† ظ…ظˆط§ظ‚ظپ ظ„ظ„ط³ظٹط§ط±ط§طھ ط¨ط¹ط¯ط¯ 40 ظ…ظˆظ‚ظپ.
 ظˆط§ظ„ط·ظˆط§ط¨ظ‚ ظ…ظ† ط§ظ„ط§ظˆظ„ ط§ظ„ظ‰ ط§ظ„ط³ط§ط¨ط¹ ظٹط­طھظˆظٹ ظƒظ„ ط·ط§ط¨ظ‚ ط¹ظ„ظ‰ ط¹ط¯ط¯ 5 ط´ظ‚ظ‚.
 *ظˆظƒظ„ ط´ظ‚ظ‡ ط¹ط¨ط§ط±ظ‡ ط¹ظ† ط؛ط±ظپطھظٹظ† ظ†ظˆظ… ظˆطµط§ظ„ظ‡ ظˆظ…ط·ط¨ط® ظˆط­ظ…ط§ظ…ظٹظ†*

 *ظ…ط¤ط¬ط±ظ‡ ط¹ظ„ظ‰ ط´ط±ظƒظ‡ ط´ظٹظƒ ظˆط§ط­ط¯           ظٹظ‚ط¯ط± ط§ظ„ظ…ط¯ط®ظˆظ„ ط§ظ„ط´ظ‡ط±ظٹ ظ„ظ„ط¨ظ†ط§ظٹظ‡ ط¨ 160,000 ط§ظ„ظپ ط´ظ‡ط±ظٹط§*   

     
*ط¹ظ‚ط¯ ط¬ط¯ظٹط¯ ظ…ط¯طھظ‡ 4 ط³ظ†ظˆط§طھ*                         
ط¨ط¯ط£ ظ…ظ† ط´ظ‡ط± ظ¨  / ظ¢ظ ظ¢ظ¥ 

*ظ…ط·ظ„ظˆط¨ ظ¢ظ£ ظ…ظ„ظٹظˆظ† ط±ظٹط§ظ„*', 1, 2, 20, false, 2, 'ط§ظ„ظ…ظ†طµظˆط±ظ‡', 23000000.00, 10, NULL, 906.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1765820637/uploads/rdjekxkx3fegv6k2dbau.jpg}', '2025-12-15 17:43:59.240063', '2025-12-15 17:43:59.240063', '00008d13-0bba-4508-b679-1fdee2890c14', 'ط§ظ„ظ…ظ†طµظˆط±ظ‡', 849, NULL, NULL, NULL, NULL, '{uploads/rdjekxkx3fegv6k2dbau}');
INSERT INTO public.posts VALUES ('710ffe32-a096-4f2e-b412-27da4a2e0647', 'ظ„ظ„ط¨ظٹط¹ 

ط¹ظ…ط§ط±ط©  ظپظٹ ط§ظ„ظ…ط·ط§ط± ط§ظ„ظ‚ط¯ظٹظ…  ظ…ط³ط§ط­ظ‡ 505 ظ…
 .ظ‚ط±ظٹط¨ ظ…ظ† ط§ظ„ط´ط§ط±ط¹ ط§ظ„ط±ط¦ظٹط³ظٹ ظˆط´ط§ط±ط¹ ط§ظ„ظ…ط·ط§ط± ط§ظ„طھط¬ط§ط±ظٹ

ظ…ظپط±ظˆط´ط© ط¨ط§ظ„ظƒط§ظ…ظ„ 
ظ…ط¤ط¬ط±ط© ط¨ط¹ظ‚ط¯  ظˆط¨ط´ظٹظƒ ظˆط§ط­ط¯ ظ…ط¹ ط´ط±ظƒط© 
ظ…ظ† 2024/6/15 ط¥ظ„ظ‰ 2027/6/15 
ظˆظ„ظ…ط¯ط© 3 ط³ظ†ظˆط§طھ 
ط¨ ظ…ط¨ظ„ط؛  ( 48000 ط´ظ‡ط±ظٹط§  )
طھطھظƒظˆظ† ط§ظ„ط¹ظ…ط§ط±ظ‡ ظ…ظ† :
10 ط´ظ‚ظ‚ ظƒظ„ ط´ظ‚ط© ظ…ظ† 2 ظ†ظˆظ… 2 ط­ظ…ط§ظ… ظˆطµط§ظ„ط© ظˆظ…ط·ط¨ط® ظˆط؛ط±ظپط© ط­ط§ط±ط³ ظ…ط¹ ط§ظ„ط­ظ…ط§ظ…

ظ…ط·ظ„ظˆط¨ : 8,300,000

', 1, 2, 20, false, 2, 'ط§ظ„ظ…ط·ط§ط± ط§ظ„ظ‚ط¯ظٹظ…', 8300000.00, 10, NULL, 505.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1762272126/uploads/m86rgk8uqewww0xosmrv.jpg}', '2025-11-04 16:02:08.25755', '2025-11-04 16:02:08.25755', '00008d13-0bba-4508-b679-1fdee2890c14', 'ط§ظ„ظ…ط·ط§ط± ط§ظ„ظ‚ط¯ظٹظ… ', 464, NULL, NULL, NULL, NULL, '{uploads/m86rgk8uqewww0xosmrv}');
INSERT INTO public.posts VALUES ('9cb9d33a-bb13-4ea3-b549-1e22d4a1c405', 'ظ„ظ„ط¨ظٹط¹ ط¨ظٹطھ ط§ظ„ط®ط±ظٹط·ظٹط§طھ 960 ظ… 

ط¹ظ„ظٹ ط´ط§ط±ط¹ظٹظ† ط§ظ…ط§ظ…ظٹ ظˆط®ظ„ظپظٹ 

ظ…ظˆظ‚ط¹ ظ…ظ…طھط§ط² ط¬ط¯ط§

ظ…ظ†ظ‡ظ… ط´ط§ط±ط¹ ط¹ط§ظ…  

ظ…ظ‚ط§ط¨ظ„ ط§ظ„ظ…ط³ط¬ط¯ 

ط§ظ„ط¨ظٹطھ ظ…ط¤ط¬ط± ط¹ظ„ظٹ ط¹ط§ط¦ظ„ظ‡ 9000 ط§ظ„ط§ظپ

ط¨ط³ط¹ط± ط§ظ„ط§ط±ط¶ ط§ظ„ظپظˆطھ 377

ظ…ط·ظ„ظˆط¨ 3.900.000', 3, 2, 19, false, 3, 'ط§ظ„ط®ط±ظٹط·ظٹط§طھ', 3900000.00, NULL, NULL, 960.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1762880463/uploads/lg51axmwogt74wwxoawr.jpg}', '2025-11-11 17:01:04.553109', '2025-11-11 17:01:04.553109', '00008d13-0bba-4508-b679-1fdee2890c14', 'ط§ظ„ط®ط±ظٹط·ظٹط§طھ', 401, NULL, NULL, NULL, NULL, '{uploads/lg51axmwogt74wwxoawr}');
INSERT INTO public.posts VALUES ('04b624c2-6033-44f9-a6eb-66b36ab2ed15', 'ظ„ظ„ط¨ظٹط¹ ظ…ط¨ط§ط´ط± 
ظپظٹظ„ط§ ظپظٹ  ط§ظ„ظˆظƒط±ط© ظ…ط³ط§ط­ط© ظ¥ظ¨ظ¤ ظ…طھط±
ط´ط§ط±ط¹ظٹظ† ط²ط§ظˆظٹط©  طھطھظƒظˆظ† ظ…ظ† :-
ظ…ط¬ظ„ط³ ط®ط§ط±ط¬ظٹ ظ…ط¹ ط­ظ…ط§ظ… 
ط§ظ„ط¯ظˆط± ط§ظ„ط§ط±ط¶ظٹ :-
طµط§ظ„طھظٹظ† ظپط§طھط­ظٹظ† ط¹ظ„ظ‰ ط¨ط¹ط¶ ظ…ط¹ ط­ظ…ط§ظ… 
ظˆط؛ط±ظپط© ظ…ط§ط³طھط±  + ط؛ط±ظپظ‡ ط¨ط¯ظˆظ† ط­ظ…ط§ظ…
ط§ظ„ط¯ظˆط± ط§ظ„ط§ظˆظ„ :- 
ظ¤ ط؛ط±ظپ  ظ£ ط؛ط±ظپ ط­ظ…ط§ظ… ظ…ط´طھط±ظƒ 
ظˆط؛ط±ظپط© ظ…ط§ط³طھط± 
ط§ظ„ط¨ظ†طھ ظ‡ط§ظˆط³ :- 
ط؛ط±ظپطھظٹظ† ظ…ط§ط³طھط± +  طµط§ظ„ظ‡ طµط؛ظٹط±ط© 
ط§ظ„ظ…ظ„ط­ظ‚ :- 
ظ…ط·ط¨ط® ط®ط§ط±ط¬ظٹ
ظ…ط·ظ„ظˆط¨ :  ظ¢.ظ¥ظ ظ .ظ ظ ظ   ط§ظ„ظپ ط±ظٹط§ظ„', 5, 1, 18, false, 3, 'ط§ظ„ظˆظƒط±ط©', 2500000.00, 8, 5, 584.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1756312125/uploads/xjdynpsq44messa1ozbc.jpg}', '2025-08-27 16:28:46.675038', '2025-08-27 16:28:46.675038', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'ط§ظ„ظˆظƒط±ط© ', 1361, NULL, NULL, NULL, NULL, '{uploads/xjdynpsq44messa1ozbc}');
INSERT INTO public.posts VALUES ('c87c3189-354c-426b-87eb-ae2dabc2d11b', 'ظ„ظ„ط¨ظٹط¹ ظ…ط¨ط§ط´ط±
ظپظٹظ„ط§ ط±ط§ظ‚ظٹط© ظ„ظ„ط¨ظٹط¹ ظپظٹ ط§ظ„ط®ظٹط³ط©
ط§ظ„ظ…ط³ط§ط­ط©:507 ظ…آ² | ظ…ط³ط§ط­ط© ط§ظ„ط¨ظ†ط§ط،: 588 ظ…آ²
ط§ظ„ظˆط§ط¬ظ‡ط© ط­ط¬ط± ط¨ط§ظ„ظƒط§ظ…ظ„
طھط´ط·ظٹط¨ ط³ظˆط¨ط± ط¯ظٹظ„ظˆظƒط³
ط¨ظ‡ط§ ظ…ط¬ظ„ط³ ط®ط§ط±ط¬ظٹ ظ…ط³طھظ‚ظ„
ط­ط¯ظٹظ‚ط© طµط؛ظٹط±ط© ظپظٹ ط§ظ„ط­ظˆط´ ط®ظ„ظپظٹ
ط؛ط±ظپط© ط³ط§ط¦ظ‚ ظ…ط¹ ط­ظ…ط§ظ… 
 ط§ظ„ط¯ظˆط± ط§ظ„ط£ط±ط¶ظٹ 
طµط§ظ„ط© ظƒط¨ظٹط±ط© ظˆط¹ط¯ط¯ 2 ط؛ط±ظپط© ظ…ط§ط³طھط±
ظˆظ…ط·ط¨ط® ط±ط¦ظٹط³ظٹ ظ…ط¬ظ‡ط²
ظˆظ…ظ„ط­ظ‚ ط®ط§ط±ط¬ظٹ (ظ…ط·ط¨ط® ط¥ط¶ط§ظپظٹ + ط؛ط±ظپط© ط¨ط­ظ…ط§ظ… + ظ…ط®ط²ظ†)
 ط§ظ„ط¯ظˆط± ط§ظ„ط£ظˆظ„:
 4 ط؛ط±ظپ ظ…ط§ط³طھط± ظˆطµط§ظ„ط© ظƒط¨ظٹط±ط©
 ط¨ظ†طھ ظ‡ط§ظˆط³:
 ط؛ط±ظپطھظٹظ† ظ…ط§ط³طھط±
ظˆظ…ط·ط¨ط®
 ط§ظ„ط³ط¹ط±: 4,300,000 ط±ظٹط§ظ„', 6, 2, 18, false, 1, 'ط§ظ„ط®ظٹط³ط© ', 4300000.00, 8, 5, 507.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1756903195/uploads/whouqt2qtxiptacawrik.jpg}', '2025-09-03 12:39:56.907375', '2025-09-03 12:39:56.907375', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'ط§ظ„ط®ظٹط³ط© ', 1536, NULL, NULL, NULL, NULL, '{uploads/whouqt2qtxiptacawrik}');
INSERT INTO public.posts VALUES ('1ccc2170-9add-487f-95a7-de3f38c159da', 'ط§ط±ط¶ ظپظ‰ ط§ظ„ظ…ط´ط§ظپ 
ظ‚ط§ط¨ظ„ ظ„ظ„ظپط±ط² 
ظ…ظˆظ‚ط¹ ظ…ظ…طھط§ط² ط¬ط¯ط§ ', 5, 2, 19, false, 3, 'ط§ظ„ظ…ط´ط§ظپ', 3100000.00, NULL, NULL, 1190.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1773777006/uploads/cp7heudmrvplefpp39hw.jpg}', '2026-03-17 19:50:08.143331', '2026-03-17 19:50:08.143331', '00008d13-0bba-4508-b679-1fdee2890c14', 'ط§ظ„ظ…ط´ط§ظپ', 270, NULL, NULL, NULL, NULL, '{uploads/cp7heudmrvplefpp39hw}');
INSERT INTO public.posts VALUES ('86157917-6091-4b5e-a957-b291cd97341d', 'ظ„ظ„ط§ظٹط¬ط§ط± ط¨ط§ظ„ظ…ط´ط§ظپ ظ…ظ‚ط§ط¨ظ„ ظˆظ‚ظˆط¯ ط§ظ„ظ…ط´ط§ظپ 
ظپظٹظ„ط§ ط¨ظˆط¬ظ‡ظ‡ ط­ط¬ط± 
ط§ظ„ظپظٹظ„ط§ ظ…ظƒظˆظ†ظ‡ ظ…ظ† ظ…ط¬ظ„ط³ ظ…ظپطµظˆظ„ ط¹ظ† ط§ظ„طµط§ظ„ظ‡ 
ظˆطµط§ظ„ظ‡ ط¨ط§ظ„ط¯ظˆط± ط§ظ„ط§ط±ط¶ظٹ 
ط؛ط±ظپظ‡  ظ†ظˆظ… ظˆظ…ط·ط¨ط® 
ظˆط§ظ„ط¯ظˆط± ط§ظ„ط¹ظ„ظˆظٹ ظ¤ ط؛ط±ظپ ظ…ط§ط³طھط± ظ…ط¹ طµط§ظ„ظ‡ 
ط¨ظ†طھ ظ‡ط§ظˆط³ ط؛ط±ظپظ‡ ط¨ط­ظ…ط§ظ… 
ظˆظ…ظ„ط­ظ‚ ط®ط§ط±ط¬ظٹ ط؛ط±ظپظ‡ ظˆط­ظ…ط§ظ… ظˆظ…ط·ط¨ط® 
ظ…ط·ظ„ظˆط¨ ظ،ظ£ ط§ظ„ظپ ط§ط³ظƒط§ظ† ط­ظƒظˆظ…ظٹ', 5, 1, 18, false, 2, '', 13000.00, 7, 5, 500.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1751110955/r69td3psfcszjtsmojjy.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1751110955/bhko5wckrrdxyrkaawiv.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1751110955/bspmhc0h8mpdzn0qr7ud.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1751110955/qos0n29yl9tntht1gns2.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1751110955/ciet1ghrae68ofacao5o.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1751110955/o6tpxknq51qmw4hzlhfx.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1751110955/jlk0dbtwwzaicqrldrta.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1751110955/zpvocluak0eemqpwvz62.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1751110955/uo7ot3wwsynxl9fbotlb.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1751110955/ugz8ej6qd3o0hw61xzkz.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1751110955/l7uhq98qqlnp0nziileu.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1751110955/gnh4yhlkeqjx2evkda72.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1751110955/vteinuadspr5gd2kuxu1.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1751110955/ap4rxnwkv1xhewzcqkhc.jpg}', '2025-06-28 11:42:36.667563', '2025-06-28 11:42:36.667563', '479690a3-da25-4188-bf72-eade4825f30c', '', 821, NULL, NULL, NULL, NULL, '{}');
INSERT INTO public.posts VALUES ('a027543b-16e4-44c5-bb39-1d3689a2cabe', '*ظ„ظ„ط¨ظٹط¹ *

ط¹ظ…ط§ط±ط© ط¨ط§ظ„ط¯ظˆط­ط© ط§ظ„ط¬ط¯ظٹط¯ط© 
ظ© ط´ظ‚ظ‚
 [ ط؛ط±ظپط© ظˆطµط§ظ„ط© ظˆط­ظ…ط§ظ… ظˆظ…ط·ط¨ط®]
ظ…ط¤ط¬ط±ط© ط¨ ظ¢ظ§ ط£ظ„ظپ ط±ظٹط§ظ„ 
ط¨ط­ط§ظ„ط© ظ…ظ…طھط§ط²ط© ظˆظ…ط±طھط¨ط© ظˆظ†ط¸ظٹظپط©
ظ…ط¯ط®ظ„ ط±ط®ط§ظ… 
ط¹ظ‚ظˆط¯ ظˆط´ظٹظƒط§طھ ظ© ط¹ظˆط§ط¦ظ„ 

*ظ…ط·ظ„ظˆط¨ ظ¥ ظ…ظ„ظٹظˆظ†*', 1, 2, 20, false, 2, 'ط§ظ„ط¯ظˆط­ظ‡ ط§ظ„ط¬ط¯ظٹط¯ظ‡', 5000000.00, 9, NULL, 303.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1762707796/uploads/gga45nyzal5f9dt5e6lj.jpg}', '2025-11-09 17:03:17.575624', '2025-11-09 17:03:17.575624', '00008d13-0bba-4508-b679-1fdee2890c14', 'ط§ظ„ط¯ظˆط­ظ‡ ط§ظ„ط¬ط¯ظٹط¯ظ‡', 649, NULL, NULL, NULL, NULL, '{uploads/gga45nyzal5f9dt5e6lj}');
INSERT INTO public.posts VALUES ('2ee8d467-86fd-4f70-99c7-5e3d4366b772', 'ظ„ظ„ط§ظٹط¬ط§ط± ظپظ„طھظٹظ† ط®ط¯ظ…ظ‰ 
ط¹ظ„ظ‰ ط§ظ„ط´ط§ط±ط¹ ط§ظ„ط¹ط§ظ… ط¨ط§ظ„ظ…ط±ط®ظٹط©
ظ¦ط؛ط±ظپ ظˆط±ظٹط³ط¨ط´ظ† ظˆطµط§ظ„ط§طھ
ظˆظ…ظ„ط­ظ‚ ظˆظ…ط·ط¨ط® ط¯ط§ط®ظ„ظ‰
ظ…ظˆظ‚ط¹ ظ…ظ…طھط§ط² 
ظ…ط·ظ„ظˆط¨ ط¨ط§ظ„ظپظٹظ„ط§ 20 ط§ظ„ظپ', 1, 1, 14, false, 2, 'ط§ظ„ظ…ط±ط®ظٹظ‡', 20000.00, 6, 5, 0.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1762881082/uploads/veslmn5hbgjqqtidmxpt.jpg}', '2025-11-11 17:11:24.732811', '2025-11-11 17:11:24.732811', '00008d13-0bba-4508-b679-1fdee2890c14', 'ط­ط²ظ… ط§ظ„ظ…ط±ط®ظٹظ‡', 923, NULL, NULL, NULL, NULL, '{uploads/veslmn5hbgjqqtidmxpt}');
INSERT INTO public.posts VALUES ('68847e6c-afb0-4166-b46b-345e65238f4c', '1 bedroom for sale with flexible payment plan for 7 years near boulevard, facind lusail stadium, above commercial mall with luxary facilities 
pool, gym, spa, garden

ط؛ط±ظپط© ظˆ طµط§ظ„ط© ظ„ظ„ط¨ظٹط¹ ط¨ط£ظ‚ط³ط§ط· ظ…ط±ظٹط­ط© ظ„ظ…ط¯ط© ظ§ ط³ظ†ظٹظ† ظپظٹ ظ…ط´ط±ظˆط¹ ط¬ط¯ظٹط¯
ط¬ظ†ط¨ ط§ظ„ط¨ظ„ظپط§ط±ط¯طŒ ظ…ظ‚ط§ط¨ظ„ ط§ظ„ط§ط³طھط§ط¯ طŒ  ظپظˆظ‚ ظ…ظˆظ„ طھط¬ط§ط±ظٹ ظ…ط¹ ط¬ظ…ظٹط¹ ط§ظ„ظ†ط´ط§ط·ط§طھ ط§ظ„طھط±ظپظٹظ‡ظٹط© ظ…ظ† ط­ظ…ط§ظ… ط³ط¨ط§ط­ط©طŒ طµط§ظ„ط© ط¬ظٹظ…طŒ ط³ط¨ط§طŒ ط­ط¯ظٹظ‚ط©.', 6, 2, 17, false, 1, 'City avenue', 1150000.00, 1, 2, 90.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1758715337/uploads/jowspmglvcgkg4igs1qq.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1758715337/uploads/fkhfyuv9qtn0vjizrdjo.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1758715337/uploads/xistfxgqaphavyuyucfe.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1758715337/uploads/u08v9r8jlurhefeunuil.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1758715337/uploads/rfofogc8wfluz2xai5mt.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1758715337/uploads/uoh0po8nucsf5pfghulo.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1758715337/uploads/qr0v8mnpizhszevjk9du.jpg}', '2025-09-24 12:02:18.708848', '2025-09-24 12:02:18.708848', 'a6ac6c51-f18d-4d5b-ad55-bc621162dd65', 'lusail', 1612, NULL, NULL, NULL, NULL, '{uploads/uoh0po8nucsf5pfghulo,uploads/u08v9r8jlurhefeunuil,uploads/fkhfyuv9qtn0vjizrdjo,uploads/rfofogc8wfluz2xai5mt,uploads/xistfxgqaphavyuyucfe,uploads/jowspmglvcgkg4igs1qq,uploads/qr0v8mnpizhszevjk9du}');
INSERT INTO public.posts VALUES ('a00a1714-65ae-444a-976a-d5493cc26fa6', 'ط§ظ„ط³ظ„ط§ظ… ط¹ظ„ظٹظƒظ… 
ظ„ظ„ط¨ظٹط¹ ط¨ظٹطھ ط´ط¹ط¨ظٹ ظپظٹ ط§ظ„ظ†ط§طµط±ظٹظ‡ 
ظ…ط³ط§ط­ظ‡ 1200ظ…(ظٹظ†ظپط±ط²)
ط´ط§ط±ط¹ظٹظ† ط§ظ…ط§ظ…ظٹ ظˆط®ظ„ظپظٹ 
ط´ط§ط±ط¹ 16ظ… ظˆط´ط§ط±ط¹ 24ظ…
ظ…ظˆظ‚ط¹ ظ…ظ…طھط§ط² ظ…ظ‚ط§ط¨ظ„ (ظ…ط±ظƒط² طµط­ظٹ ط§ظ„ط؛ط±ط§ظپظ‡)
ط§ظ„ظ…ط§ظ„ظƒ ط³ط§ظƒظ† ظپظٹظ‡ 
ظ…ط·ظ„ظˆط¨ 5,200,000', 1, 2, 19, false, 3, 'ط§ظ„ط؛ط±ط§ظپظ‡', 5200000.00, NULL, NULL, 1200.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1762799414/uploads/inazszdwryvdudzw2ss8.jpg}', '2025-11-10 18:30:16.019669', '2025-11-10 18:30:16.019669', '00008d13-0bba-4508-b679-1fdee2890c14', 'ط§ظ„ط؛ط±ط§ظپظ‡', 598, NULL, NULL, NULL, NULL, '{uploads/inazszdwryvdudzw2ss8}');
INSERT INTO public.posts VALUES ('9439b4b8-3e61-4622-9154-40707f3769bd', 'ظ„ظ„ط¨ظٹط¹ ظپظ„طھظٹظ† ط¬ط¯ط§ط¯ ظپظٹ ط§ظ… طµظ„ط§ظ„ ط¹ظ„ظٹ 
 ظ…ط³ط§ط­ط© ط§ظ„ط§ط±ط¶ 450 ظ…طھط± ظˆظ…ط³ط§ط­ط© ط§ظ„ط¨ظ†ط§ط، 437 ظ…طھط±.. طµط§ظ„ط© ظˆظ…ط¬ظ„ط³ ظˆظ…ط·ط¹ظ…  ظˆط¹ط¯ط¯ 7 ط؛ط±ظپ 7 ط­ظ…ط§ظ…ط§طھ ظˆظ…ط·ط¨ط® ط®ط§ط±ط¬ظٹ  ظˆط؛ط±ظپط© ط؛ط³ظٹظ„ ظˆط؛ط±ظپط© ظˆط؛ط±ظپط© ط³ط§ط¦ظ‚ 
ط§ظ„ظ…ظˆظ‚ط¹ ظ…ظ…ظٹط² ط¹ظ„ظٹ ط´ط§ط±ط¹ظٹظ† ط§ظ…ط§ظ…ظٹ ظˆ ط®ظ„ظپظٹ ط¨ط¬ط§ظ†ط¨ ط§ظ„ظ…ط³ط¬ط¯ 
ط§ظ„ط³ط¹ط± 3,100,000 ط±ظٹط§ظ„  
ظ‚ط§ط¨ظ„ ظ„ظ„ط¬ط§ط¯', 3, 2, 18, false, 1, 'ط§ظ… طµظ„ط§ظ„ ط¹ظ„ظ‰ ', 3100000.00, 7, 5, 450.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1756526064/uploads/hzagxcw6ztfbhezhxl6l.jpg}', '2025-08-30 03:54:24.964729', '2025-08-30 03:54:24.964729', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'ط§ظ… طµظ„ط§ظ„ ط¹ظ„ظ‰', 599, NULL, NULL, NULL, NULL, '{uploads/hzagxcw6ztfbhezhxl6l}');
INSERT INTO public.posts VALUES ('270f91ae-cc7b-4843-8a15-b9cbc7a1fe6d', 'ظ…ظ† ط§ظ„ظ…ط§ظ„ظƒ 
ظ„ظ„ط¨ظٹط¹ ظپظٹظ„ط§ ظپظٹ ط§ظ„ط®ط±ظٹط·ظٹط§طھ طھط´ط·ظٹط¨ VIB ط³ظˆط¨ط± ط¯ظٹظ„ظˆظƒط³ (ط±ط§ظ‚ظٹ ط¬ط¯ط§ ط¹ظ„ظ‰ ط¢ط¹ظ„ظ‰ ظ…ط³طھظˆظ‰ ) ظ…ط³ط§ط­ظ‡ ط§ظ„ط§ط±ط¶ 600 ظ… ظˆط§ظ„ط¨ظ†ط§ط، 650 ظ… ط§ظ„ظپظٹظ„ط§ ط­ط¬ط± ط·ط¨ظٹط¹ظٹ + ظ„ظپطھ ط°ظ‡ط¨ظٹ + ظˆط§ط¬ظ‡ط§طھ ط±ط®ط§ظ… + ظ…ط·ط§ط¨ط® ظ…ظˆط¯ط±ظ† ظ…ط¬ظ‡ط²ظ‡ ظ…ظ† ط§ظ„ط£ط¬ظ‡ط²ط© ط§ظ„ظƒظ‡ط±ط¨ط§ط¦ظٹط©  + ظ…ظƒظٹظپ ظ…ط±ظƒط²ظٹ ظ„ط¬ظ…ظٹط¹ ط§ظ„ط£ط¯ظˆط§ط± + ط§ط¶ط§ط،ظ‡ ط­ط¯ظٹط«ط© +ط§ط­ظˆط§ط¶ ط²ط±ط§ط¹ظٹط© + ط±ط®ط§ظ… 
ط¨ظ‡ط§ ظ…ط¬ظ„ط³ ط®ط§ط±ط¬ظٹ ظ…ط¹ ظ…ط؛ط§ط³ظ„ ظˆط­ظ…ط§ظ… 
8 ط؛ط±ظپ ظ…ط§ط³طھط± ظ…ط¹ ط؛ط±ظپ ظ…ظ„ط§ط¨ط³ ظˆط­ظ…ط§ظ…ط§طھ ظ…ط¹ظ„ظ‚ظ‡ + ط¬ظ…ظٹط¹ ط§ظ„ظ…ط؛ط§ط³ظ„ ط±ط®ط§ظ… ط§طµظ„ظٹ + ط§ط¨ظˆط§ط¨ ط®ط´ط¨ طھظٹظƒ 
طµط§ظ„ط§طھ ظ…ظپطھظˆط­ظ‡ 
ظ…ظ„ط§ط­ظ‚ ط®ط§ط±ط¬ظٹظ‡ ظˆط؛ط±ظپظ‡ ط؛ط³ظٹظ„ ط¥ط¶ط§ظپظٹط© 

ظˆط§طµظ„ظ‡ ظƒظ‡ط±ط¨ط§ط، ظˆظ…ط§ط، ظˆط§ظ„ظ…طµط¹ط¯ ط±ط§ظƒط¨ ظˆط§ظ„طھظƒظٹظٹظپ ظ…ط±ظƒط²ظٹ ط±ط§ظƒط¨ ظˆط´ط؛ط§ظ„ 

ط§ظ„ط³ط¹ط± 5 ظ…ظ„ظٹظˆظ†', 3, 2, 18, false, 1, 'ط§ظ„ط®ط±ظٹط·ظٹط§طھ ', 5000000.00, 8, 5, 600.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1758001974/uploads/asmklokhhtdevjhmnubq.jpg}', '2025-09-16 05:52:55.046807', '2025-09-16 05:52:55.046807', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'ط§ظ„ط®ط±ظٹط·ظٹط§طھ ', 936, NULL, NULL, NULL, NULL, '{uploads/asmklokhhtdevjhmnubq}');
INSERT INTO public.posts VALUES ('a073ac87-c6c1-49bc-b4ad-2e046ffa0ed4', 'ظ¦ ط؛ط±ظپ ظˆ ظ…ط¬ظ„ط³ ط¯ط§ط®ظ„ظ‰ ظˆ ظ§ ط­ظ…ط§ظ…ط§طھ ظˆ ظ…ط·ط¨ط® ظˆ طµط§ظ„ط© ظˆ ط­ظˆط´ ط®ط§ط±ط¬ظ‰ ظˆ ظ…ط·ط¨ط® ط®ط§ط±ط¬ظ‰ ظˆ طµط§ظ„طھظٹظ†', 1, 2, 18, true, 2, '', 15000.00, 6, 5, 500.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1752685761/uploads/qywhso7eejo8pmetpb9i.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1752685760/uploads/f2tabrtdo8jwe6yiamwy.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1752685760/uploads/cx5jxlbjyivxbyltotjh.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1752685761/uploads/rwymtcu9l6zylji3bphj.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1752685760/uploads/folpie6eu79qhmginkev.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1752685761/uploads/wibuon3tiqreoluheynh.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1752685761/uploads/b5mcenua2nygoog50ybq.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1752685761/uploads/mltv4mcwfoohmyyiapnb.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1752685761/uploads/ndqfklyylylavk7qrbtd.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1752685761/uploads/qs01n9jp1up0hlrl8zi2.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1752685761/uploads/c7ulpzqoipbqk6fxelau.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1752685761/uploads/ld64sdvh99wsbanb59tu.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1752685761/uploads/x6tjvjojlzvpyihcy5y8.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1752685761/uploads/d0zgngem3eelzduhjnjp.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1752685761/uploads/mpaslt6gjwafxhgff8kk.jpg}', '2025-07-16 17:09:22.761287', '2025-07-16 17:09:22.761287', '479690a3-da25-4188-bf72-eade4825f30c', '', 765, NULL, NULL, NULL, NULL, '{}');
INSERT INTO public.posts VALUES ('a78286c6-a060-4ce7-a855-799bb969dbef', 'ظ„ظ„ط¨ظٹط¹  ظ‚ط·ط¹ظ‡ ط§ط±ط¶ ظپظٹ ظ…ظ†ط·ظ‚ظ‡ ط§ظ„ط«ظ…ظٹط¯ ظ…ط³ط§ط­ظ‡ 1309 ظ…طھط± ظ…ط±ط¨ط¹ ط¹ظ„ظ‰ ط´ط§ط±ط¹ ظˆط§ط­ط¯ ظˆط§ط¬ظ‡ظ‡ ظƒط¨ظٹط±ظ‡ 
ظپظٹ ظ…ظˆظ‚ط¹ ظ…ظ…طھط§ط² ط¬ط¯ط§ ظˆط³ط· ط§ظ„ط¨ظ†ظٹط§ظ† ظˆط¨ط§ظ„ظ‚ط±ط¨ ظ…ظ† ط§ظ„ط§ط³ظˆط§ظ‚ ط§ظ„طھط¬ط§ط±ظٹظ‡ ط§ط³ظˆط§ظ‚ ط§ظ„ظپط±ط¬ط§ظ† 
', 2, 2, 19, false, 3, 'ط§ظ„ط«ظ…ظٹط¯ ', 4935000.00, NULL, NULL, 1309.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1774299227/uploads/ng4yixdggal2eusckxmh.jpg}', '2026-03-23 20:53:49.047285', '2026-03-23 20:53:49.047285', '00008d13-0bba-4508-b679-1fdee2890c14', 'ط§ظ„ط«ظ…ظٹط¯ ', 225, NULL, NULL, NULL, NULL, '{uploads/ng4yixdggal2eusckxmh}');
INSERT INTO public.posts VALUES ('a1cc6def-3125-4f59-9980-3852bdb35f6d', 'ظ„ظ„ط¨ظٹط¹  ظپظٹظ„طھظٹظ† ظ…طھظ„ط§طµظ‚ط§طھ ظپظ‰  ط­ط²ظ… ط§ظ„ظ…ط±ط®ظٹظ‡ ظ…ط³ط§ط­ط© ظ¨ظ¨ظ§ ظ…طŒ ط§ظ„ط¨ظ†ط§ط، ظپظ‰ ظ¢ظ ظ¢ظ¢ظ… ظƒظ„ ظپظٹظ„ط§ ظ¦ ط؛ط±ظپ ظˆظ…ط¬ظ„ط³ ظˆطµط§ظ„ط© ظˆظ…ظ„ط§ط­ظ‚ ظˆظ…ط¤ط¬ط±ظٹظ† ط¨ ظ£ظ¥ ط§ظ„ظپ ط´ظٹظƒ ظˆط§ط­ط¯ ط¹ظ‚ط¯ ظ£ ط³ظ†ظˆط§طھ طŒ ظ…ط·ظ„ظˆط¨ ظ¥.ظ¥ظ ظ  ظ…ظ„ظٹظˆظ†.*', 1, 2, 18, false, 1, 'ط­ط²ظ… ط§ظ„ظ…ط±ط®ظٹظ‡', 5500000.00, 8, 5, 887.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1762718611/uploads/as2n3tm4kxt8rmlgxn53.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1762718611/uploads/rzpv0stsdr08sndnud86.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1762718611/uploads/x4zrwah1nwnqvgh8s9di.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1762718611/uploads/tsixcloghmstso5n9uzu.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1762718611/uploads/fbmoproeqmncajhody6k.jpg}', '2025-11-09 20:03:34.129391', '2025-11-09 20:03:34.129391', '00008d13-0bba-4508-b679-1fdee2890c14', 'ط­ط²ظ… ط§ظ„ظ…ط±ط®ظٹظ‡', 738, NULL, NULL, NULL, NULL, '{uploads/as2n3tm4kxt8rmlgxn53,uploads/rzpv0stsdr08sndnud86,uploads/tsixcloghmstso5n9uzu,uploads/x4zrwah1nwnqvgh8s9di,uploads/fbmoproeqmncajhody6k}');
INSERT INTO public.posts VALUES ('6233dd76-471a-43ba-9220-7a818b1f669c', 'ظ„ظ„ط¨ظٹط¹ ظپظٹظ„ط§ ط¨ط§ظ„ظ…ط´ط§ظپ ط¨ظ…ط³ط§ط­ط© 500ظ… ظ…ط¹ 8 ط؛ط±ظپ ظ…ط§ط³طھط±طŒ ظ…ط¬ظ„ط³ ط¯ط§ط®ظ„ظٹطŒ ظˆطµط§ظ„ط© ظ…ظپطھظˆط­ط©طŒ ظ…ظ„ط­ظ‚طŒ ظ…ط·ط¨ط® ط®ط§ط±ط¬ظٹ ظˆظ…ط¬ظ„ط³ ط®ط§ط±ط¬ظٹطŒ ظˆظٹظˆط¬ط¯ ظ„ظٹظپطھ.  
ط§ظ„ط³ط¹ط± ط§ظ„ظ…ط·ظ„ظˆط¨: 3,300,000 ط±ظٹط§ظ„ ظ‚ط·ط±ظٹ ظپظ‚ط·! ًںڈ،âœ¨', 5, 2, 18, false, 1, 'ط¬ط±ظٹط§ظ† ظ…طµط¨ط­', 3300000.00, 8, 5, 500.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1758890371/uploads/yt5vd4nz30lttmqaw0uc.jpg}', '2025-09-26 12:39:32.302253', '2025-09-26 12:39:32.302253', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'ط§ظ„ظ…ط´ط§ظپ ', 1939, NULL, NULL, NULL, NULL, '{uploads/yt5vd4nz30lttmqaw0uc}');
INSERT INTO public.posts VALUES ('a91987ee-d038-46fb-b78c-e2f3b918fcd2', 'ظپظٹظ„ط§ ظ…ط³طھط¹ظ…ظ„ظ‡  
ظپظٹظ„ط§ ظ„ظ„ط¨ظٹط¹ ظپظٹ ط§ظ„ط¯ط­ظٹظ„ ظ…ط³ط§ط­ظ‡ 841 ظ… ط®ظ„ظپ ط§ظ„ط±ظٹظپظٹط±ط§  ط¹ظ…ط±ظ‡ط§ 16 ط³ظ†ظ‡ 
طھطھظƒظˆظ† ظ…ظ† 
7 ط؛ط±ظپ ظ…ط§ط³طھط± 
ظˆظ…ط¬ظ„ط³ ط¯ط§ط®ظ„ظٹ ظ…ظ†ظپطµظ„ 
ظˆط¨ظ†طھ ظ‡ط§ظˆط³ 
ظˆطµط§ظ„طھظٹظ† ظˆظ…ظ„ط­ظ‚ ط®ط§ط±ط¬ظٹ 
ظˆظ…ط·ط¨ط® ط¯ط§ط®ظ„ظٹ 
ظˆظ…ظ„ط­ظ‚ ط®ط§ط±ط¬ظٹ 

ط§ظ„ظپظٹظ„ط§ ظپط§ط¶ظٹظ‡ ظˆط¬ط§ظ‡ط²ظ‡ ظ„ظ„ط§ط³طھظ„ط§ظ… 
ظ…ط·ظ„ظˆط¨ 4 ظ…ظ„ظٹظˆظ† ظˆ50 ط§ظ„ظپ 
ط¨ط³ط¹ط± ط§ظ„ط§ط±ط¶ ط§ظ„ظپظٹظ„ط§', 1, 2, 18, false, 2, 'ط§ظ„ط¯ط­ظٹظ„ ', 4050000.00, 7, 5, 8.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1762956438/uploads/f2uxthhffnlqppzjob3k.jpg}', '2025-11-12 14:07:19.751125', '2025-11-12 14:07:19.751125', '00008d13-0bba-4508-b679-1fdee2890c14', 'ط§ظ„ط¯ط­ظٹظ„ ', 540, NULL, NULL, NULL, NULL, '{uploads/f2uxthhffnlqppzjob3k}');
INSERT INTO public.posts VALUES ('000a7b29-bb9e-43a7-b744-a558e51cbbef', '

ظ„ظ„ط§ظٹط¬ط§ط± ط³طھظˆط± ط¬ط¯ظٹط¯ ظپظٹ ط¨ط±ظƒط© ط§ظ„ط¹ظˆط§ظ…ط± 
- ظ…ظٹط²ط§ظ†ظٹظ† ط§ظ„ط§ظˆظ„ ظ¤ظ¨ظ ظ… ظ…طھط± ط§ظ„ط«ط§ظ†ظٹ ظ£ظ¥ظ ظ…
- ظٹظˆط¬ط¯ ظ…ظƒطھط¨ ظ…ظƒظٹظپ ط¨ظ…ظ„ط­ظ‚ط§طھظ‡
- ط؛ط±ظپظ‡ ط­ط§ط±ط³ ظ…ظƒظٹظپظ‡ ط¨ظ…ظ„ط­ظ‚ط§طھظ‡ط§
- ط§ظ„ط³ط¹ط± ظ،ظ£ ط§ظ„ظپ ظ†ظ‡ط§ط¦ظٹ', 5, 1, 13, false, 2, 'ط¨ط±ظƒظ‡ ط§ظ„ط¹ظˆط§ظ…ط± ', 13000.00, 4, 5, NULL, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1758362616/uploads/iyoy1otndcql6znjlaog.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1758362616/uploads/m4yhww6grupexedbdgsh.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1758362617/uploads/hqf4r7wnqvrlpgqtwetr.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1758362616/uploads/kzejah1kogcv4f7bmbwl.jpg}', '2025-09-20 10:03:38.474871', '2025-09-20 10:03:38.474871', '00008d13-0bba-4508-b679-1fdee2890c14', 'ط¨ط±ظƒظ‡ ط§ظ„ط¹ظˆط§ظ…ط± ', 1171, NULL, NULL, NULL, NULL, '{uploads/iyoy1otndcql6znjlaog,uploads/m4yhww6grupexedbdgsh,uploads/kzejah1kogcv4f7bmbwl,uploads/hqf4r7wnqvrlpgqtwetr}');
INSERT INTO public.posts VALUES ('ad630e42-5745-4ab6-add0-bdc5efaddc18', 'ظƒط§ظپظٹظ‡ ظ…ظ…ظٹط² ظ„ظ„ط¨ظٹط¹ ظ„ط¹ط¯ظ… ط§ظ„طھظپط±ط؛ ط¨ظƒط§ظ…ظ„ ظ…ط¹ط¯ط§طھظ‡ ظˆطھط¬ظ‡ظٹط²ط§طھظ‡

ظ…ظˆظ‚ط¹ ط§ظ„ظƒط§ظپظٹظ‡

https://goo.gl/maps/YyXReQSuMmGdu7r66

ط³ط¹ط± ط§ظ„ط¨ظٹط¹ 200 ط£ظ„ظپ ط±ظٹط§ظ„

ظ‚ظٹظ…ط© ط§ظ„ط¥ظٹط¬ط§ط± ط§ظ„ط´ظ‡ط±ظٹ
5767 ط±ظٹط§ظ„ ظپظ‚ط·

ظ„ظ„ط¬ط§ط¯ظٹظ† ظپظ‚ط· ط§ظ„طھظˆط§طµظ„ ط¹ط¨ط± ط§ظ„ظˆط§طھط³ ط§ط¨
66609797', 2, 2, 4, true, 2, '', 200000.00, NULL, NULL, 40.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1764167731/uploads/megifyc9gt9fnpzu8f3y.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1764167731/uploads/cquykosbll5b3ffwh8bc.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1764167731/uploads/tafy8js5l3vjjm0rk27h.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1764167731/uploads/yjnaqdb2e4feu99pzq89.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1764167731/uploads/lmoyatvlbwo51u6aehra.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1764167731/uploads/iu1vje1y0ny1x1wahps5.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1764167731/uploads/haainain3uwhtqf5ee8a.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1764167731/uploads/ebc17klgdkzfot1mfpee.jpg}', '2025-11-26 14:35:32.785544', '2025-11-26 14:35:32.785544', '29bece65-37c1-4a0b-b914-79a6946c25ae', 'near Education City ', 781, NULL, NULL, NULL, NULL, '{uploads/ebc17klgdkzfot1mfpee,uploads/megifyc9gt9fnpzu8f3y,uploads/yjnaqdb2e4feu99pzq89,uploads/lmoyatvlbwo51u6aehra,uploads/cquykosbll5b3ffwh8bc,uploads/tafy8js5l3vjjm0rk27h,uploads/iu1vje1y0ny1x1wahps5,uploads/haainain3uwhtqf5ee8a}');


--
-- Data for Name: sale_types; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.sale_types VALUES (1, 'rent');
INSERT INTO public.sale_types VALUES (2, 'sell');


--
-- Data for Name: saved_posts; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.saved_posts VALUES ('63f1bdf7-e4a3-4776-a39a-441db10520c3', '6233dd76-471a-43ba-9220-7a818b1f669c');
INSERT INTO public.saved_posts VALUES ('c39d7df4-4abb-4f74-8d95-b9311f628611', '9ae78732-1117-4dc3-b94e-36a050ffb852');
INSERT INTO public.saved_posts VALUES ('c39d7df4-4abb-4f74-8d95-b9311f628611', '60c5e109-fe62-4cef-8909-aff7a112ff65');
INSERT INTO public.saved_posts VALUES ('ddb44b72-275b-4fe6-b56b-5e7dd412d318', '1cfa83f0-26c5-43e5-bc31-385484854b7a');
INSERT INTO public.saved_posts VALUES ('aaf8f5fc-dca9-40c5-8002-07e8dd448d4e', '80911cea-cc06-414a-a260-14f2232312c8');
INSERT INTO public.saved_posts VALUES ('f896a9a3-43db-495e-b5da-b8128c91aa7e', '82277f44-c4db-4102-bfb1-6678ed871a0e');
INSERT INTO public.saved_posts VALUES ('64bdfb3c-d629-49a8-bb85-d01978cb09a9', '758e4d2a-6cbd-4bcb-8a9f-0da30ec1ef19');
INSERT INTO public.saved_posts VALUES ('6f68fd7c-0a10-45b0-8389-5d3e28c88fb9', '1cfa83f0-26c5-43e5-bc31-385484854b7a');


--
-- Data for Name: spatial_ref_sys; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.users VALUES ('2caad35c-8d76-4920-9c09-796de58392d9', '97431467666', 'individual', NULL, 'Alaaeldin mohamed ', 'ط¹ظ„ط§ط، ط§ظ„ط¯ظٹظ† ظ…ط­ظ…ط¯ ', NULL, NULL, NULL, true, '2025-08-11 03:18:00.63076', '2025-08-11 03:18:00.63076', NULL, false);
INSERT INTO public.users VALUES ('0d09855d-3534-4ef0-a8b4-486383b93775', '97430231318', 'business', NULL, 'Talaat Farag Ibrahim Khalil ', 'ط·ظ„ط¹طھ ظپط±ط¬ ط¥ط¨ط±ط§ظ‡ظٹظ… ط®ظ„ظٹظ„', '216960', 'JSWR ALMjd for Trading and Contracting ', 'ط¬ط³ظˆط± ط§ظ„ظ…ط¬ط¯ ظ„ظ„طھط¬ط§ط±ط© ظˆط§ظ„ظ…ظ‚ط§ظˆظ„ط§طھ', true, '2025-07-31 02:29:20.633279', '2025-07-31 02:29:20.633279', NULL, false);
INSERT INTO public.users VALUES ('a7b77bb9-8519-4201-8034-527b17d21de3', '97470401700', 'business', NULL, 'DOTA ALDOHA REAL ESTATE ', 'ط¯ط±ط© ط§ظ„ط¯ظˆط­ظ‡ ظ„ظ„ظˆط³ط§ط·ظ‡ ط§ظ„ط¹ظ‚ط§ط±ظٹظ‡ ', '162125', 'DOTA ALDOHA REAL ESTATE ', 'ط¯ط±ط© ط§ظ„ط¯ظˆط­ظ‡ ظ„ظ„ظˆط³ط§ط·ظ‡ ط§ظ„ط¹ظ‚ط§ط±ظٹظ‡ ', true, '2025-09-02 16:46:00.242733', '2025-09-02 16:46:00.242733', NULL, false);
INSERT INTO public.users VALUES ('7de65174-bc80-49bb-9c87-571fbea3888b', '97455230402', 'individual', NULL, 'Umsaleh ahmed', 'ط³ظ„ظˆظ‰ ط§ط­ظ…ط¯', NULL, NULL, NULL, true, '2025-08-03 20:31:28.789596', '2025-08-03 20:31:28.789596', NULL, false);
INSERT INTO public.users VALUES ('4aef6cd7-d470-42ef-a860-648e16aa6c08', '97433676637', 'individual', NULL, 'Ahmed', 'ط£ط­ظ…ط¯ ', NULL, NULL, NULL, true, '2025-08-28 06:07:06.859554', '2025-08-28 06:07:06.859554', NULL, false);
INSERT INTO public.users VALUES ('8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', '97471535247', 'business', NULL, 'abo gheith', 'ط§ط¨ظˆ ط؛ظٹط« ', '987897', 'AQARAT', 'ط¹ظ‚ط§ط±ط§طھ', true, '2025-07-26 15:07:17.7986', '2025-07-26 15:07:17.7986', NULL, false);
INSERT INTO public.users VALUES ('d26d5775-858b-4ceb-9aa7-e152c57ee233', '97466410475', 'individual', NULL, 'Ahmad ghazi Aljassim', 'ط§ط­ظ…ط¯ ط؛ط§ط²ظٹ ط§ظ„ط¬ط§ط³ظ… ', NULL, NULL, NULL, true, '2025-08-06 11:23:19.810248', '2025-08-06 11:23:19.810248', NULL, false);
INSERT INTO public.users VALUES ('4fc1d1d8-21fb-417f-8355-fe767777aae7', '97430662515', 'individual', NULL, 'ط¨ط´ظٹط± ', 'ظپظ‡ط¯ ', NULL, NULL, NULL, true, '2025-07-27 20:45:26.982389', '2025-07-27 20:45:26.982389', NULL, false);
INSERT INTO public.users VALUES ('18e15b48-2d06-47e9-b8ec-aa49ef39b847', '97466266005', 'individual', NULL, 'yousif', 'ظٹظˆط³ظپ', NULL, NULL, NULL, true, '2025-07-24 02:19:10.305636', '2025-07-24 02:19:10.305636', NULL, false);
INSERT INTO public.users VALUES ('a5c20520-86c4-4cb5-a13f-a5b621defa8b', '97455108707', 'individual', '$2b$10$J5Ad.peeC3WCLsOBC.W.OOd41t9AL8C.K8nLvRWLXDNe8RbI0iRg.', 'Umm abdull', 'ط§ظ… ط¹ط¨ط¯ط§ظ„ظ„ظ‡', NULL, NULL, NULL, true, '2025-07-02 19:56:26.391576', '2025-07-02 19:56:26.391576', NULL, false);
INSERT INTO public.users VALUES ('48d8d695-e182-430a-8721-8490e7b0852a', '97450411803', 'business', NULL, 'ABDALLAH EZZO', 'ط¹ط¨ط¯ط§ظ„ظ„ظ‡ ط¹ط²ظˆ', '158224', 'ABSHER REALSTATE BROKERGE ', 'ط£ط¨ط´ط± ظ„ظ„ظˆط³ط§ط·ط© ط§ظ„ط¹ظ‚ط§ط±ظٹط© ', true, '2025-07-08 05:31:36.238992', '2025-07-08 05:31:36.238992', NULL, false);
INSERT INTO public.users VALUES ('083fb897-9d85-4b71-9486-d6052b888148', '97455834895', 'business', '$2b$10$4yy.Pb39TrvT8wq7Don.IuJRHFe4g/CjAxxNqbzDtReSixckIzQdS', 'Ibrahim Ali Ali Saad', 'ط¥ط¨ط±ط§ظ‡ظٹظ… ط¹ظ„ظٹ ط¹ظ„ظٹ ط³ط¹ط¯', '17538', 'Jassim Trade Center ', 'ظ…ط±ظƒط² ط¬ط§ط³ظ… ط§ظ„طھط¬ط§ط±ظٹ', true, '2025-06-25 20:26:26.038569', '2025-06-25 20:26:26.038569', NULL, false);
INSERT INTO public.users VALUES ('7fe0870a-02ad-4c09-8548-78c1eba0172a', '97455832232', 'individual', '$2b$10$brRQnAvIhdqxRKCmG22zauCJMtIE4NpFfFlEguRzZ23YvQRp5O07y', 'Ali almohannadi ', 'ط¹ظ„ظٹ ط§ظ„ظ…ظ‡ظ†ط¯ظٹ', NULL, NULL, NULL, true, '2025-07-05 05:20:31.679644', '2025-07-05 05:20:31.679644', NULL, false);
INSERT INTO public.users VALUES ('69e24c97-9e3a-495b-9553-21aaf6731354', '97477182999', 'individual', '$2b$10$Hw5LvibjheVGOlpFPHQYEu3V4IuJhXwwNgtiMO3/xfj4aUAUaYyLC', 'Abo malek ', 'ط§ط¨ظˆ ظ…ط§ظ„ظƒ ', NULL, NULL, NULL, true, '2025-06-26 00:36:57.806117', '2025-06-26 00:36:57.806117', NULL, false);
INSERT INTO public.users VALUES ('a9b2b67f-699f-4d5c-a181-cc4339be7231', '97433032114', 'individual', NULL, 'Ammar Jawdat alkrad ', 'ط¹ظ…ط§ط± ط¬ظˆط¯ط§طھ ط§ظ„ظƒط±ط§ط¯ ', NULL, NULL, NULL, true, '2025-09-04 19:32:48.058612', '2025-09-04 19:32:48.058612', NULL, false);
INSERT INTO public.users VALUES ('18eee0be-32d4-4294-90b4-bd9e436c2045', '97470947008', 'individual', NULL, 'SAMl', 'ط³ط§ظ…ظٹ', NULL, NULL, NULL, true, '2025-07-08 06:26:18.617976', '2025-07-08 06:26:18.617976', NULL, false);
INSERT INTO public.users VALUES ('969f7636-60a1-4f9d-ba03-71e40036d334', '97455502214', 'individual', NULL, 'Ahmedhassan', 'ط§ط­ظ…ط¯ ط­ط³ظ† ', NULL, NULL, NULL, true, '2025-09-01 11:11:53.130006', '2025-09-01 11:11:53.130006', NULL, false);
INSERT INTO public.users VALUES ('faf09832-63a6-43d4-a57d-dd875f73ab52', '97455852650', 'individual', '$2b$10$vH1xU5EkVc5GTA7W1li2WeqWeQVU5utsAtBU1GHtzHwM.ktWhfehW', 'ABDULLA ALKUWARI ', 'ط¹ط¨ط¯ط§ظ„ظ„ظ‡ ط§ظ„ظƒظˆط§ط±ظٹ', NULL, NULL, NULL, true, '2025-07-03 10:17:24.589268', '2025-07-03 10:17:24.589268', NULL, false);
INSERT INTO public.users VALUES ('0644702f-39af-4d4c-a40a-c7829752db57', '97450008583', 'individual', '$2b$10$g6bx24a6mYoK5ep2Hl00EuXVQnRypcIkK76xzXEFymSFpD0RkgsAi', 'Hassan albdullh alkhalaf', 'ط­ط³ظ† ط¹ط¨ط¯ط§ظ„ظ„ظ‡ ط§ظ„ط®ظ„ظپ ', NULL, NULL, NULL, true, '2025-07-03 14:54:07.368666', '2025-07-03 14:54:07.368666', NULL, false);
INSERT INTO public.users VALUES ('beda8965-3d8f-4d38-89b7-341060e9ab96', '97455888273', 'individual', '$2b$10$lx9gHOGW9rp0mvF4qds32.eEqxIZk/LmnpGv8uklNLXOnRuFlg7Ma', 'Mohamed ', 'ظ…ط­ظ…ط¯', NULL, NULL, NULL, true, '2025-07-06 03:47:50.132159', '2025-07-06 03:47:50.132159', NULL, false);
INSERT INTO public.users VALUES ('8f78f1e8-7199-4073-bdf4-279a99161fc9', '97466060863', 'individual', '$2b$10$st7FHICQ2tB2LsZhsNam5eDp1zBMcV.rSL9mYzbTDuMrfk3IGel22', 'Muhammad Usman', 'ظ…ط­ظ…ط¯ ط¹ط«ظ…ط§ظ†', NULL, NULL, NULL, true, '2025-07-03 19:07:17.22117', '2025-07-03 19:07:17.22117', NULL, false);
INSERT INTO public.users VALUES ('04729d6f-77e4-461b-bb63-41bbd691ccc8', '97477771272', 'individual', '$2b$10$MS/ah7dbXqzS.FjhJwqmneGIbPTcalL..wYu7.EfD309YkqAtVG.G', 'Fatma alkuwari', 'ظپط§ط·ظ…ظ‡ ط§ظ„ظƒظˆط§ط±ظٹ', NULL, NULL, NULL, true, '2025-07-04 16:29:33.069174', '2025-07-04 16:29:33.069174', NULL, false);
INSERT INTO public.users VALUES ('36946934-b95e-45c5-96b0-f5f2bf3e8cec', '97455200095', 'individual', '$2b$10$rMktXQaGyD9zKRHpwNHQ3.bBN2.PaBWV5bd7Rp3EFefkBN1TEbFwO', 'Khaled', 'ط®ط§ظ„ط¯', NULL, NULL, NULL, true, '2025-07-07 08:55:06.929117', '2025-07-07 08:55:06.929117', NULL, false);
INSERT INTO public.users VALUES ('ce7a41fe-ff9b-4397-84cb-62c43e218769', '97455777716', 'individual', NULL, 'Saif Abujabra', 'ط³ظٹظپ ظ…ط­ظ…ط¯', NULL, NULL, NULL, true, '2025-09-09 20:54:33.691135', '2025-09-09 20:54:33.691135', NULL, false);
INSERT INTO public.users VALUES ('b44b6e18-08c0-4a2f-98de-b873b287ac82', '97433471003', 'individual', '$2b$10$YMsxQttfP7AuvInh2rPJd.Jawp7HYfhDlXX35AkVUzMIqqvMVU/WG', 'Fadia', 'ظپط§ط¯ظٹط© ط·ظ„ط¹طھ', NULL, NULL, NULL, true, '2025-06-25 20:37:54.245288', '2025-06-25 20:37:54.245288', NULL, false);
INSERT INTO public.users VALUES ('0b2e5742-a930-457b-a2be-3eb1bde03b17', '97455933280', 'individual', '$2b$10$pFfnTe8jro0vE4DsDHWr7OFERGhmGGTrvPzUnDtLHJIDw1cEO7Psy', 'Haneen Saad', 'ط­ظ†ظٹظ† ط³ط¹ط¯', NULL, NULL, NULL, true, '2025-06-19 23:39:38.635443', '2025-06-19 23:39:38.635443', NULL, false);
INSERT INTO public.users VALUES ('a1bd4efa-9b57-4726-8808-2b36f0830aa2', '97455888280', 'individual', NULL, 'SAAD', 'ط³ط¹ط¯', NULL, NULL, NULL, true, '2025-07-07 23:46:52.567841', '2025-07-07 23:46:52.567841', NULL, false);
INSERT INTO public.users VALUES ('fc0ac422-4716-4b3a-b722-8b330bfe88af', '97450316381', 'individual', NULL, 'Rana', 'ط±ظ†ط§', NULL, NULL, NULL, true, '2025-08-26 19:53:58.262439', '2025-08-26 19:53:58.262439', NULL, false);
INSERT INTO public.users VALUES ('30221241-6493-487d-a11d-74a10b396c4e', '97477114773', 'individual', NULL, 'Jasser Romdhana', 'ط¬ط§ط³ط± ط±ظ…ط¶ط§ظ†ط©', NULL, NULL, NULL, true, '2025-08-26 07:00:08.924611', '2025-08-26 07:00:08.924611', NULL, false);
INSERT INTO public.users VALUES ('f5a37da7-d74f-4b0f-9a65-1e82b52d7813', '97477240788', 'business', NULL, 'Marasy realestate ', 'ظ…ط±ط§ط³ظٹ ط§ظ„ط¹ظ‚ط§ط±ظٹط©', '1234567', 'Marasy realestate ', 'ظ…ط±ط§ط³ظٹ ط§ظ„ط¹ظ‚ط§ط±ظٹط©', true, '2025-09-23 05:50:41.176247', '2025-09-23 05:50:41.176247', NULL, false);
INSERT INTO public.users VALUES ('5086bce9-36c6-4cac-9b80-207f54e2ae00', '97477711918', 'individual', NULL, 'M', 'ظ…ظ‡ط§', NULL, NULL, NULL, true, '2025-09-14 11:32:04.171757', '2025-09-14 11:32:04.171757', NULL, false);
INSERT INTO public.users VALUES ('e03682c8-d708-47b3-98c0-6d74b3c16229', '97450000151', 'individual', NULL, 'Hassan', 'ط­ط³ظ†', NULL, NULL, NULL, true, '2025-09-16 18:12:05.151666', '2025-09-16 18:12:05.151666', NULL, false);
INSERT INTO public.users VALUES ('95528c3a-e08f-4a04-b126-e9229c7403c7', '97450081212', 'individual', NULL, 'Sultan Ali Nasser ', 'ط³ظ„ط·ط§ظ† ط¹ظ„ظٹ ظ†ط§طµط±', NULL, NULL, NULL, true, '2025-09-15 17:30:29.646046', '2025-09-15 17:30:29.646046', NULL, false);
INSERT INTO public.users VALUES ('e6831544-b929-4569-91cb-3c2c65a547d0', '97450928733', 'individual', NULL, 'Moaaz Abo Zeed', 'ظ…ط¹ط§ط° ط£ط¨ظˆ ط²ظٹط¯', NULL, NULL, NULL, true, '2025-09-10 09:47:57.671134', '2025-09-10 09:47:57.671134', NULL, false);
INSERT INTO public.users VALUES ('784d5743-2a16-4978-b44a-82997c1c5551', '97466748781', 'individual', NULL, 'Amal saif alamer', 'ط§ظ…ظ„ ط³ظٹظپ ط§ظ„ط¹ط§ظ…ط±', NULL, NULL, NULL, true, '2025-09-30 18:07:11.606267', '2025-09-30 18:07:11.606267', NULL, false);
INSERT INTO public.users VALUES ('7796422a-bbfe-4b6b-b062-0c1dab1ec5cc', '97450134867', 'individual', NULL, 'Hatem ramadan', 'ط­ط§طھظ… ط±ظ…ط¶ط§ظ†', NULL, NULL, NULL, true, '2025-08-15 14:46:46.397254', '2025-08-15 14:46:46.397254', NULL, false);
INSERT INTO public.users VALUES ('86b86666-45a8-4400-a4cb-a424e2059582', '97455822825', 'individual', NULL, 'Ali Hassan alali ', 'ط¹ظ„ظٹ ط­ط³ظ† ط§ظ„ط¹ظ„ظٹ', NULL, NULL, NULL, true, '2025-10-10 19:42:55.667975', '2025-10-10 19:42:55.667975', NULL, false);
INSERT INTO public.users VALUES ('c01ce1c0-9084-4721-8a5e-e09e492a991e', '97466669980', 'individual', NULL, 'Khalid Yousef  Aljehani ', 'ط®ط§ظ„ط¯ ظٹظˆط³ظپ ط§ظ„ظ…ط§ظ„ظƒظٹ ', NULL, NULL, NULL, true, '2025-10-15 20:07:47.058152', '2025-10-15 20:07:47.058152', NULL, false);
INSERT INTO public.users VALUES ('e4b109a5-083d-44ee-9095-732144e2e719', '97466094943', 'individual', NULL, 'ABDELRAHMAN ', 'ط¹ط¨ط¯ط§ظ„ط±ط­ظ…ظ† ', NULL, NULL, NULL, true, '2025-10-28 11:24:36.836892', '2025-10-28 11:24:36.836892', NULL, false);
INSERT INTO public.users VALUES ('c0461100-60ce-404a-86a6-86610b5c2f89', '97450067840', 'business', NULL, 'Marsana real estate', 'ظ…ط±ط³ط§ظ†ط§ ظ„ظ„ظˆط³ط§ط·ط© ط§ظ„ط¹ظ‚ط§ط±ظٹط© ', '150532', 'Marsana real estate', 'ظ…ط±ط³ط§ظ†ط§ ظ„ظ„ظˆط³ط§ط·ط© ط§ظ„ط¹ظ‚ط§ط±ظٹط© ', true, '2025-11-02 16:10:54.010124', '2025-11-02 16:10:54.010124', NULL, false);
INSERT INTO public.users VALUES ('d15a6fdd-2f8c-4897-a1d0-19bbdcdf1f85', '97455906666', 'individual', NULL, 'Abdulla AL Nuaimi', 'ط¹ط¨ط¯ط§ظ„ظ„ظ‡ ط§ظ„ظ†ط¹ظٹظ…ظٹ', NULL, NULL, NULL, true, '2025-11-08 08:24:56.257457', '2025-11-08 08:24:56.257457', NULL, false);
INSERT INTO public.users VALUES ('8fbae5c3-6aa5-45db-967d-f060405a92de', '97466141559', 'individual', NULL, 'ahmedkhater', 'ط§ظ„ط¹ظˆط¶ظ‰', NULL, NULL, NULL, true, '2025-07-08 08:07:55.159351', '2025-07-08 08:07:55.159351', NULL, false);
INSERT INTO public.users VALUES ('30589e15-eabe-457a-9914-764715dbf66e', '97466213332', 'individual', NULL, 'Sama Doha', 'ط³ظ…ط§ ط§ظ„ط¯ظˆط­ط©', NULL, NULL, NULL, true, '2025-07-31 09:55:58.090905', '2025-07-31 09:55:58.090905', NULL, false);
INSERT INTO public.users VALUES ('719ce1ed-1661-4b63-af99-d3cde43f5a13', '97430078494', 'individual', NULL, 'Darak Real Estate ', 'ط¯ط§ط±ظƒ ط§ظ„ط¹ظ‚ط§ط±ظٹط© ', NULL, NULL, NULL, true, '2025-10-29 11:26:47.91199', '2025-10-29 11:26:47.91199', NULL, false);
INSERT INTO public.users VALUES ('6570802e-2c1f-4d9f-9431-e9af80fe6c2f', '97477778866', 'individual', NULL, 'Ibrahim', 'ط§ط¨ط±ط§ظ‡ظٹظ…', NULL, NULL, NULL, true, '2025-08-03 21:32:44.109407', '2025-08-03 21:32:44.109407', NULL, false);
INSERT INTO public.users VALUES ('8405f0ac-0587-462d-a5ad-f2a14b41948a', '97431011015', 'individual', NULL, 'Lolwa Lolwa', 'ظ„ظˆظ„ظˆظ‡ ظ…ط­ظ…ط¯ ط§ظ„ظ…ط±ظٹ', NULL, NULL, NULL, true, '2025-09-04 21:43:56.053133', '2025-09-04 21:43:56.053133', NULL, false);
INSERT INTO public.users VALUES ('cedd9058-1505-4739-a584-4ba6badf04fd', '97455123842', 'individual', '$2b$10$yCw9eKDAUTx4oH1PtHaHIu/bkPQC9J6oQ4f0FpdJ6tIAbYC8HNKL2', 'Mohamed', 'ط§ط­ظ…ط¯ ط³ط¹ط¯', NULL, NULL, NULL, true, '2025-06-16 18:04:55.216835', '2025-06-16 18:04:55.216835', NULL, false);
INSERT INTO public.users VALUES ('2a205ea3-91f1-4dea-bf54-cf0aef0c3903', '97471376244', 'individual', NULL, 'Hosamameer alkhtim osman ', 'ط­ط³ط§ظ… ط§ظ…ظٹط± ط§ظ„ط®طھظ… ط¹ط«ظ…ط§ظ†', NULL, NULL, NULL, true, '2025-07-21 13:07:20.939863', '2025-07-21 13:07:20.939863', NULL, false);
INSERT INTO public.users VALUES ('ddb44b72-275b-4fe6-b56b-5e7dd412d318', '97477005511', 'individual', NULL, 'Hassan Ali Alaali', 'ط­ط³ظ† ط¹ظ„ظٹ ط§ظ„ط¹ط§ظ„ظٹ', NULL, NULL, NULL, true, '2025-11-30 10:25:59.362629', '2025-11-30 10:25:59.362629', NULL, false);
INSERT INTO public.users VALUES ('e96ee3a6-b66c-4c80-bbad-cf5e7f13a56a', '97466116361', 'individual', NULL, 'Fatima Ali', 'ظپط§ط·ظ…ط© ط¹ظ„ظٹ', NULL, NULL, NULL, true, '2025-07-29 09:33:07.812326', '2025-07-29 09:33:07.812326', NULL, false);
INSERT INTO public.users VALUES ('242a522e-232a-4291-aa31-c5177a726929', '97470766667', 'business', NULL, 'Naif aldosari', 'ظ†ط§ظٹظپ ط§ظ„ط¯ظˆط³ط±ظٹ', '191715', 'Nwe One Real Estate', 'ظ†ظٹظˆ ظˆظ† ط§ظ„ط¹ظ‚ط§ط±ظٹط©', true, '2025-07-29 17:59:04.69538', '2025-07-29 17:59:04.69538', NULL, false);
INSERT INTO public.users VALUES ('dc9572cb-b0d5-4f6b-ba95-de766bce3030', '97477278478', 'individual', NULL, 'Musab', 'ظ…طµط¹ط¨', NULL, NULL, NULL, true, '2025-09-12 12:15:05.109088', '2025-09-12 12:15:05.109088', NULL, false);
INSERT INTO public.users VALUES ('d5f15140-1fc3-4656-82a6-7404e3c42720', '97455980787', 'individual', NULL, 'Fahad Abdulla Almulla', 'ظپظ‡ط¯ ط¹ط¨ط¯ط§ظ„ظ„ظ‡ ط§ظ„ظ…ظ„ط§', NULL, NULL, NULL, true, '2025-08-17 18:09:30.833995', '2025-08-17 18:09:30.833995', NULL, false);
INSERT INTO public.users VALUES ('11c303ec-c375-4784-9c50-ad1ce523a66e', '97466664229', 'individual', NULL, 'Saleh', 'طµط§ظ„ط­', NULL, NULL, NULL, true, '2025-08-24 09:19:22.818211', '2025-08-24 09:19:22.818211', NULL, false);
INSERT INTO public.users VALUES ('e671a096-8ed8-4cc2-9f8f-adbeff9da47b', '97455411002', 'individual', NULL, 'Talal Nasser', 'ط·ظ„ط§ظ„ ظ†ط§طµط±', NULL, NULL, NULL, true, '2025-11-12 20:54:33.289471', '2025-11-12 20:54:33.289471', NULL, false);
INSERT INTO public.users VALUES ('64bdfb3c-d629-49a8-bb85-d01978cb09a9', '97455786848', 'individual', NULL, 'Nouf alhamad', 'ظ†ظˆظپ', NULL, NULL, NULL, true, '2025-09-15 20:13:57.981052', '2025-09-15 20:13:57.981052', NULL, false);
INSERT INTO public.users VALUES ('c50eb6e5-5f22-43c1-8be4-ebaa11b59d11', '97450501100', 'individual', NULL, 'Mohammad altamimi', 'ظ…ط­ظ…ط¯ ط§ظ„طھظ…ظٹظ…ظٹ', NULL, NULL, NULL, true, '2025-08-26 11:43:11.790501', '2025-08-26 11:43:11.790501', NULL, false);
INSERT INTO public.users VALUES ('e1ff8045-138b-4281-94ae-c98b1198af29', '97466333177', 'individual', NULL, 'Hamad almarri', 'ط­ظ…ط¯ ط§ظ„ظ…ط±ظٹ', NULL, NULL, NULL, true, '2025-08-28 18:07:10.276023', '2025-08-28 18:07:10.276023', NULL, false);
INSERT INTO public.users VALUES ('6b1a488d-8218-430c-89e3-aa87ac93caa9', '97477609915', 'individual', NULL, 'Mohammed mansour ', 'ظ…ط­ظ…ط¯ ظ…ظ†طµظˆط± ', NULL, NULL, NULL, true, '2025-09-01 18:16:47.239357', '2025-09-01 18:16:47.239357', NULL, false);
INSERT INTO public.users VALUES ('efd98c15-b61e-4b24-9bf6-80c358bb317b', '97430332112', 'individual', NULL, 'Mohammed Al Jaaidi', 'ظ…ط­ظ…ط¯ ط§ظ„ط¬ط¹ظٹط¯ظٹ', NULL, NULL, NULL, true, '2025-09-20 07:06:06.549634', '2025-09-20 07:06:06.549634', NULL, false);
INSERT INTO public.users VALUES ('a508a6b9-7544-4888-8bf5-70279cbd4785', '97477400095', 'business', NULL, 'Future Realstate ', 'ط§ظ„ظ…ط³طھظ‚ط¨ظ„ ظ„ظ„ظˆط³ط§ط·ظ‡ ط§ظ„ط¹ظ‚ط§ط±ظٹظ‡', '23843', 'Future Realstate ', 'ط§ظ„ظ…ط³طھظ‚ط¨ظ„ ظ„ظ„ظˆط³ط§ط·ط© ط§ظ„ط¹ظ‚ط§ط±ظٹظ‡ ', true, '2025-11-01 16:01:25.405576', '2025-11-01 16:01:25.405576', NULL, false);
INSERT INTO public.users VALUES ('6374f9d1-560c-4632-895a-9dff32ce2300', '97466660406', 'individual', NULL, 'SALEM', 'ط³ط§ظ„ظ…', NULL, NULL, NULL, true, '2025-09-26 23:23:22.075024', '2025-09-26 23:23:22.075024', NULL, false);
INSERT INTO public.users VALUES ('76a34cb5-52b8-46fd-a694-a8d5b05ab3f5', '97430004143', 'individual', NULL, 'Law farm', 'ظ…ظƒطھط¨ ظ…ط­ط§ظ…ط§ظ‡', NULL, NULL, NULL, true, '2025-10-01 20:41:52.083316', '2025-10-01 20:41:52.083316', NULL, false);
INSERT INTO public.users VALUES ('37d0163c-2fc9-4f30-99da-a7cfb3c8750e', '97431337131', 'individual', NULL, 'Fathi Ali Asideh ', 'ظپطھط­ظٹ ط¹ظ„ظٹ ط¹طµظٹط¯ط© ', NULL, NULL, NULL, true, '2025-11-13 23:27:30.440004', '2025-11-13 23:27:30.440004', NULL, false);
INSERT INTO public.users VALUES ('5141eb42-12e1-4c77-b51e-37504498bb51', '97433222509', 'business', NULL, 'Gnosis Real Estate', 'ط¬ظ†ظˆط³ظٹط³ ط§ظ„ط¹ظ‚ط§ط±ظٹط©', '141860', 'Gnosis Real Estate', 'ط¬ظ†ظˆط³ظٹط³ ط§ظ„ط¹ظ‚ط§ط±ظٹط©', true, '2025-11-06 04:13:00.591682', '2025-11-06 04:13:00.591682', NULL, false);
INSERT INTO public.users VALUES ('63f1bdf7-e4a3-4776-a39a-441db10520c3', '97433660336', 'individual', NULL, 'Amina Ali', 'ط£ظ…ظٹظ†ط© ط¹ظ„ظٹ', NULL, NULL, NULL, true, '2025-10-08 18:45:10.306249', '2025-10-08 18:45:10.306249', NULL, false);
INSERT INTO public.users VALUES ('25f0e324-8257-4aba-ad26-b2e72a97c32f', '97433599188', 'business', NULL, 'MOHAMMED ABDILAHAKEM ALYAFIE', 'ظ…ط­ظ…ط¯ ', '192232', 'Consultants', 'ط§ظ„ظ…ط³طھط´ظ€ظ€ظ€ظ€ط§ط±ظˆظ† ', true, '2025-10-11 01:04:58.819575', '2025-10-11 01:04:58.819575', NULL, false);
INSERT INTO public.users VALUES ('a88266cf-ec85-4c9a-9fdc-3baf51e2f5fc', '97430055532', 'business', NULL, 'Mohammed Zakaria Mohammed Hassan ', 'ظ…ط­ظ…ط¯ ط²ظƒط±ظٹط§ ظ…ط­ظ…ط¯ ط­ط³ظ†', '104431', 'NTS logistics ', 'ط§ظ† طھظٹ ط§ط³ ظ„ظˆط¬ظٹط³طھظٹظƒ', true, '2025-11-13 05:11:04.600414', '2025-11-13 05:11:04.600414', NULL, false);
INSERT INTO public.users VALUES ('d2e95f1e-ebbd-435a-8015-d6092b0031f6', '97455556036', 'individual', NULL, 'Om Ghanim', 'ط§ظ… ط؛ط§ظ†ظ…', NULL, NULL, NULL, true, '2025-11-10 12:24:29.787586', '2025-11-10 12:24:29.787586', NULL, false);
INSERT INTO public.users VALUES ('a8ae53eb-903c-4713-9430-b428f9ea17ab', '97466664032', 'individual', NULL, 'Hamad alsenaid', 'ط­ظ…ط¯ ط§ظ„ط³ظ†ظٹط¯', NULL, NULL, NULL, true, '2025-11-11 16:46:55.303497', '2025-11-11 16:46:55.303497', NULL, false);
INSERT INTO public.users VALUES ('050e30d1-9dde-425a-9e8b-6ae5a08387e4', '97455105232', 'individual', NULL, 'Ahmad Youssef', 'ط£ط­ظ…ط¯ ظٹظˆط³ظپ', NULL, NULL, NULL, true, '2025-11-11 17:35:04.43355', '2025-11-11 17:35:04.43355', NULL, false);
INSERT INTO public.users VALUES ('a017c507-2bfb-40c2-b126-5ca4c679ca5d', '97466451749', 'individual', NULL, 'Rana Ammoura', 'ط±ظ†ط§ ط­ط³ظ†', NULL, NULL, NULL, true, '2025-11-12 07:55:45.647529', '2025-11-12 07:55:45.647529', NULL, false);
INSERT INTO public.users VALUES ('13ccb56e-957d-496a-91cf-b70f9cf6d55e', '97477111520', 'individual', NULL, 'fahad almahmod', 'ظپظ‡ط¯ ط§ظ„ظ…ط­ظ…ظˆط¯ ', NULL, NULL, NULL, true, '2025-11-13 08:52:17.438121', '2025-11-13 08:52:17.438121', NULL, false);
INSERT INTO public.users VALUES ('5dd35d75-d357-4fba-8e2a-9428dd10b0ba', '97430544110', 'business', NULL, 'Medad for gifts and stationery trading ', 'ظ…ط¯ط§ط¯ ظ„ظ„ظ‡ط¯ط§ظٹط§ ظˆطھط¬ط§ط±ط© ط§ظ„ظ‚ط±ط·ط§ط³ظٹط© ', '150231', 'Medad ', 'ظ…ط¯ط§ط¯', true, '2025-11-14 19:41:47.880332', '2025-11-14 19:41:47.880332', NULL, false);
INSERT INTO public.users VALUES ('22122433-ac35-4af5-be80-88abf13af50c', '97431310200', 'individual', NULL, 'Wadeedjehg', 'ظˆط¯ظٹط¹ ط؛ظ„ط§ط¨ ', NULL, NULL, NULL, true, '2025-12-30 10:07:05.961957', '2025-12-30 10:07:05.961957', NULL, false);
INSERT INTO public.users VALUES ('d94bfae0-d3a9-46b5-828c-9988e0039ce7', '97430000966', 'individual', NULL, 'Mohammed Alkuwari ', 'ظ…ط­ظ…ط¯ ط§ظ„ظƒظˆط§ط±ظٹ', NULL, NULL, NULL, true, '2025-07-27 08:17:24.345053', '2025-07-27 08:17:24.345053', NULL, false);
INSERT INTO public.users VALUES ('26b36703-a959-43ac-bd01-affbfd3ba29c', '97455250866', 'individual', NULL, 'Abdulrahman almaristani', 'ط¹ط¨ط¯ط§ظ„ط±ط­ظ…ظ† ط§ظ„ظ…ط±ط³طھط§ظ†ظٹ ', NULL, NULL, NULL, true, '2025-11-16 10:39:06.978957', '2025-11-16 10:39:06.978957', NULL, false);
INSERT INTO public.users VALUES ('0714cb8f-55b3-4575-a8ec-b21e8b65611a', '97471418403', 'individual', NULL, 'keltoum ', 'ظƒظ„طھظˆظ…', NULL, NULL, NULL, true, '2025-11-19 19:22:29.676562', '2025-11-19 19:22:29.676562', NULL, false);
INSERT INTO public.users VALUES ('29bece65-37c1-4a0b-b914-79a6946c25ae', '97466609797', 'business', NULL, 'Hayat Cafe', 'ظ…ظ‚ظ‡ظ‰ ط­ظٹط§ط©', '168108', 'Hayat Cafe', 'ظ…ظ‚ظ‡ظ‰ ط­ظٹط§ط©', true, '2025-11-25 13:46:23.439738', '2025-11-25 13:46:23.439738', NULL, false);
INSERT INTO public.users VALUES ('3a42e4e9-5e2f-46d3-87a4-4905b510aaba', '97451160211', 'individual', NULL, 'Ahmad Al Ali', 'ط£ط­ظ…ط¯ ط§ظ„ط¹ظ„ظٹ', NULL, NULL, NULL, true, '2025-12-17 08:29:18.022332', '2025-12-17 08:29:18.022332', NULL, false);
INSERT INTO public.users VALUES ('f7865234-4328-4f1d-ab83-c0aba5cc5079', '97450055559', 'individual', NULL, 'Tamather Alhajri', 'طھظ…ط§ط¶ط± ط§ظ„ظ‡ط§ط¬ط±ظٹ', NULL, NULL, NULL, true, '2025-12-13 19:30:38.346666', '2025-12-13 19:30:38.346666', NULL, false);
INSERT INTO public.users VALUES ('e91e7a32-37f1-4285-8781-e6adfe517b94', '97466716676', 'individual', NULL, 'Rauof morad dorazaei', 'ط±ط¦ظˆظپ ظ…ط±ط§ط¯ ط¯ط±ط§ط²ط¦ظٹ', NULL, NULL, NULL, true, '2026-01-11 16:49:42.046736', '2026-01-11 16:49:42.046736', NULL, false);
INSERT INTO public.users VALUES ('b3a2e794-bc82-4979-8bfd-629cf21fe3b7', '97455541484', 'individual', NULL, 'Abdulla ', 'ط¹ط¨ط¯ط§ظ„ظ„ظ‡', NULL, NULL, NULL, true, '2026-01-11 18:21:59.464301', '2026-01-11 18:21:59.464301', NULL, false);
INSERT INTO public.users VALUES ('ff4bc451-29fe-4b9d-900f-416afe1c1823', '97466155551', 'individual', NULL, 'Aisha Almohannadi ', 'ط¹ط§ط¦ط´ط© ط§ظ„ظ…ظ‡ظ†ط¯ظٹ', NULL, NULL, NULL, true, '2026-01-12 10:40:26.512863', '2026-01-12 10:40:26.512863', NULL, false);
INSERT INTO public.users VALUES ('aabf956a-c6ad-4ccb-a79c-df54fe809792', '97466888872', 'individual', NULL, 'Fahad Salem ', 'ظپظ‡ط¯ ط¨ظ† ط³ط§ظ„ظ… ', NULL, NULL, NULL, true, '2026-01-11 21:04:53.768729', '2026-01-11 21:04:53.768729', NULL, false);
INSERT INTO public.users VALUES ('4539667a-ef0a-4bbf-97fd-8cc8ee0c996e', '97455025930', 'individual', NULL, 'Hadi', 'ظ‡ط§ط¯ظٹ', NULL, NULL, NULL, true, '2026-01-12 16:41:05.377899', '2026-01-12 16:41:05.377899', NULL, false);
INSERT INTO public.users VALUES ('15e7c0b8-4099-40e8-bbb5-c6835c7010fa', '97470433335', 'individual', NULL, 'Adnan ABDUL RAHMAN alshaikh ', 'ط¹ط¯ظ†ط§ظ† ط¹ط¨ط¯ط§ظ„ط±ط­ظ…ظ† ط§ظ„ط´ظٹط® ', NULL, NULL, NULL, true, '2025-08-01 23:09:25.285602', '2025-08-01 23:09:25.285602', NULL, false);
INSERT INTO public.users VALUES ('97015ec8-859c-41cf-94dc-e21c5dc975d2', '97466677882', 'individual', NULL, 'Adnan Fekri', 'ط¹ط¯ظ†ط§ظ† ظپظƒط±ظٹ', NULL, NULL, NULL, true, '2025-08-16 17:16:59.58446', '2025-08-16 17:16:59.58446', NULL, false);
INSERT INTO public.users VALUES ('8c35d390-0b62-47dc-934d-02201a4e4051', '97430298690', 'business', NULL, 'Ahmedkhater', 'ط§ط­ظ…ط¯ ط®ط§ط·ط±', '113650', 'Almamwn', 'ط§ظ„ظ…ط£ظ…ظˆظ† ', true, '2025-07-26 11:45:48.245861', '2025-07-26 11:45:48.245861', NULL, false);
INSERT INTO public.users VALUES ('90d9ee2e-4bbb-48e3-98ed-96c372791c53', '97477511960', 'individual', NULL, 'Oussama mebarkia', 'ط§ط³ط§ظ…ط© ظ…ط¨ط§ط±ظƒظٹط© ', NULL, NULL, NULL, true, '2025-07-29 13:24:20.830735', '2025-07-29 13:24:20.830735', NULL, false);
INSERT INTO public.users VALUES ('62a144aa-12ba-46ca-a359-f4eef5509af4', '97460041886', 'business', NULL, 'Abo kater', ' ط§ط¨ظˆ ط®ط§ط·ط±', '345265', 'AQARAT', 'ط¹ظ‚ط§ط±ط§طھ', true, '2025-07-26 15:11:22.734096', '2025-07-26 15:11:22.734096', NULL, false);
INSERT INTO public.users VALUES ('f896a9a3-43db-495e-b5da-b8128c91aa7e', '97450743728', 'individual', '$2b$10$febshBA6Hyhlo.jbHl42LOz72omK3srVE7NRJ7fM/Nqep39iuBidC', 'Fatma', 'ظپط§ط·ظ…ظ‡', NULL, NULL, NULL, true, '2025-06-16 18:15:57.050351', '2025-06-16 18:15:57.050351', NULL, false);
INSERT INTO public.users VALUES ('1fca63ef-7107-4171-b273-ca1451bba181', '97466306624', 'business', NULL, 'Mohamed Dabour', 'ظ…ط­ظ…ط¯ ط¯ط¨ظˆط± ط´ط±ظƒظ‡ ظ…ط±ط³ط§ظ†ط§ ', '49152', 'Marsana', 'ط´ط±ظƒظ‡ ظ…ط±ط³ط§ظ†ط§ ظ„ظ„ظˆط³ط§ط·ظ‡ ط§ظ„ط¹ظ‚ط§ط±ظٹظ‡ ', true, '2025-07-27 11:31:46.267719', '2025-07-27 11:31:46.267719', NULL, false);
INSERT INTO public.users VALUES ('3e3a8d06-0594-4619-a4d7-dd9b6ad4eb9e', '97477899919', 'individual', '$2b$10$f4H03fYUaf.qc3itQUryFOdsi5eLyIRxbKDQzw.C16PXj5cqUS3.O', 'Jassim Mohammed Alkuwari', 'ط¬ط§ط³ظ… ظ…ط­ظ…ط¯ ط§ظ„ظƒظˆط§ط±ظٹ', NULL, NULL, NULL, true, '2025-06-28 15:41:09.932463', '2025-06-28 15:41:09.932463', NULL, false);
INSERT INTO public.users VALUES ('cf44d3dd-8724-43ac-9421-a209c743ffff', '97455844463', 'individual', NULL, 'FAYSEL MASOUD', 'ظپظٹطµظ„ ظ…ط³ط¹ظˆط¯', NULL, NULL, NULL, true, '2025-09-02 09:18:07.915551', '2025-09-02 09:18:07.915551', NULL, false);
INSERT INTO public.users VALUES ('3ba38b73-9ca7-4eac-abae-4be1d350839d', '97430285392', 'individual', NULL, 'Hassan hashim', 'ط­ط³ظ† ظ‡ط§ط´ظ… ', NULL, NULL, NULL, true, '2025-09-05 00:49:34.929129', '2025-09-05 00:49:34.929129', NULL, false);
INSERT INTO public.users VALUES ('ef3f0df9-5c5a-4c00-b358-535b343a90d1', '97477077808', 'individual', NULL, 'Hamad Rashid Alkaabi', 'ط­ظ…ط¯ ط±ط§ط´ط¯ ط§ظ„ظƒط¹ط¨ظٹ', NULL, NULL, NULL, true, '2025-08-25 21:23:17.706724', '2025-08-25 21:23:17.706724', NULL, false);
INSERT INTO public.users VALUES ('d94ec90b-8a47-4387-ac35-82789ed8e7b1', '97477772626', 'individual', NULL, 'Abdulrhman Alkaabi ', 'ط¹ط¨ط¯ط§ظ„ط±ط­ظ…ظ† ط­ظ…ط¯ ط§ظ„ظƒط¹ط¨ظٹ', NULL, NULL, NULL, true, '2025-08-11 10:03:37.319811', '2025-08-11 10:03:37.319811', NULL, false);
INSERT INTO public.users VALUES ('409d35d1-4f3a-4786-886e-e02857fce76c', '97430166426', 'individual', NULL, 'Amer', 'ط¹ط§ظ…ط±', NULL, NULL, NULL, true, '2025-09-03 05:06:01.477939', '2025-09-03 05:06:01.477939', NULL, false);
INSERT INTO public.users VALUES ('704cb71e-6d50-4a49-9a73-ea2460b52b99', '97455006683', 'individual', NULL, 'Abdulla Almulla', 'ط¹ط¨ط¯ط§ظ„ظ„ظ‡ ط§ظ„ظ…ظ„ط§', NULL, NULL, NULL, true, '2025-08-17 18:36:20.705275', '2025-08-17 18:36:20.705275', NULL, false);
INSERT INTO public.users VALUES ('77489c44-6f04-4d74-9534-90d2785afa69', '97450731250', 'individual', '$2b$10$3hs96IgsPfkE2UAdjSRSg.yNZGhQtdJIDWxxOqJsCWHQeADOMOvB.', 'Personal account', 'ط­ط³ط§ط¨ ط´ط®طµظٹ', NULL, NULL, NULL, true, '2025-06-17 17:52:13.071644', '2025-06-17 17:52:13.071644', NULL, false);
INSERT INTO public.users VALUES ('801ae98c-66a3-40b6-a34b-9192d248636f', '97431222633', 'individual', '$2b$10$jWa0WltmCs0N7ZhQ5lNtCuLQ8r/SuIoi/UFSDRfLbKd9PMUsjp.JW', 'Ibrahim alkuwari', 'ط§ط¨ط±ط§ظ‡ظٹظ… ط§ظ„ظƒظˆط§ط±ظٹ', NULL, NULL, NULL, true, '2025-06-26 11:16:25.034133', '2025-06-26 11:16:25.034133', NULL, false);
INSERT INTO public.users VALUES ('a33d6479-9fa0-4629-9a30-dc76dbd17b6c', '97433375537', 'individual', '$2b$10$NyLGyIvoN5O.bKA096HtkeNocX.xvkqWkY/7J6CesPWbXLIuU5Tb6', 'Jassim Ali AlKuwari', 'ط¬ط§ط³ظ… ط¹ظ„ظٹ ط§ظ„ظƒظˆط§ط±ظٹ', NULL, NULL, NULL, true, '2025-06-28 11:48:36.345444', '2025-06-28 11:48:36.345444', NULL, false);
INSERT INTO public.users VALUES ('88d803a2-f156-49aa-80a0-a0d6d18c8e5c', '97466900020', 'individual', '$2b$10$vVZONDWoV9dM7BMXgbW/9.y2ydV0hrkGM6hAty75m6.0HQjqg3QfC', 'Abdulrahman ', 'ط¹ط¨ط¯ط§ظ„ط±ط­ظ…ظ† ط³ط¹ظˆط¯', NULL, NULL, NULL, true, '2025-06-28 11:15:50.218519', '2025-06-28 11:15:50.218519', NULL, false);
INSERT INTO public.users VALUES ('3fb32f03-99eb-4cd3-a7ed-9584059f27ea', '97433004050', 'individual', '$2b$10$xHucJk1r0SpHaPuRia9jEuNXsmu5nEHitXFU51NUgW9LVsu6C73F6', 'Hussen alansari', 'ط­ط³ظٹظ† ط§ظ„ط£ظ†طµط§ط±ظٹ ', NULL, NULL, NULL, true, '2025-06-28 11:55:07.478613', '2025-06-28 11:55:07.478613', NULL, false);
INSERT INTO public.users VALUES ('4e704897-0ea8-456b-bd0a-314ce2265486', '97477620011', 'individual', NULL, 'Ahmad numan alattar', 'ط§ط­ظ…ط¯ ظ†ط¹ظ…ط§ظ† ط§ظ„ط¹ط·ط§ط± ', NULL, NULL, NULL, true, '2025-09-13 02:11:46.322764', '2025-09-13 02:11:46.322764', NULL, false);
INSERT INTO public.users VALUES ('479690a3-da25-4188-bf72-eade4825f30c', '97430133359', 'individual', '$2b$10$rxea0rJ8F.LmYWzItEoLxO93v4MsXuK58CYVpUn8Os43BrfYd20Q2', 'Ambaear', 'ط§ظ…ط¨ط§ظٹط± ', NULL, NULL, NULL, true, '2025-06-28 11:38:26.226141', '2025-06-28 11:38:26.226141', NULL, false);
INSERT INTO public.users VALUES ('8c82c7df-cac2-478c-8aa9-938e6bfa32d4', '97455525229', 'individual', NULL, 'Jawaher Al Abdulla', 'ط¬ظˆط§ظ‡ط± ط§ظ„ط¹ط¨ط¯ط§ظ„ظ„ظ‡ ', NULL, NULL, NULL, true, '2025-09-15 09:57:35.547105', '2025-09-15 09:57:35.547105', NULL, false);
INSERT INTO public.users VALUES ('896876b6-f72e-4e03-8513-a29066826066', '97466014585', 'individual', '$2b$10$8hUTO7q8EkAspk652FXUKe8yB7Se6asS6nq4fovdQghAqtFmgOGdy', 'Al Abraz', 'ط§ظ„ط§ط¨ط±ط² ظ„ظ„ط¹ظ‚ط§ط±ط§طھ', NULL, NULL, NULL, true, '2025-06-29 12:28:18.59829', '2025-06-29 12:28:18.59829', NULL, false);
INSERT INTO public.users VALUES ('22c2e563-b6c7-46a9-93cd-975090546b9c', '97470000354', 'individual', '$2b$10$AWC7lWSR4sI86y.D08XBduHai9neZyTRjz5fWPEiMPyK4I087d.x.', 'Hassan altamimi', 'ط­ط³ظ† ط§ظ„طھظ…ظٹظ…ظٹ ', NULL, NULL, NULL, true, '2025-06-26 20:03:18.998962', '2025-06-26 20:03:18.998962', NULL, false);
INSERT INTO public.users VALUES ('71090023-e221-4ad6-b090-1edb82c6d1ff', '97433738294', 'business', '$2b$10$xhqrZzY4hcAKlwvCZZhmPODqEQvHzYUYjDrwGWeejaiNO0Hq1K0Ha', 'Hazem Abu Sultan ', 'ط­ط§ط²ظ… ط§ط¨ظˆ ط³ظ„ط·ط§ظ† ', '00090', 'Nelson Park ', 'ظ†ظٹظ„ط³ظˆظ† ط¨ط§ط±ظƒ ط§ظ„ط¹ظ‚ط§ط±ظٹظ‡ ', true, '2025-06-27 08:32:39.130576', '2025-06-27 08:32:39.130576', NULL, false);
INSERT INTO public.users VALUES ('bde66193-e76c-4942-861e-07052fd4e3aa', '97470001512', 'individual', '$2b$10$74TMm.u/aAymO4di.AOfWemOS4cXC8kPoDzbntr3WoG4s49s1Zce.', 'Mahmoud  O A Zourob ', 'ظ…ط­ظ…ظˆط¯ ط¹ظ…ط± ط§ط­ظ…ط¯ ط²ط¹ط±ط¨', NULL, NULL, NULL, true, '2025-06-27 09:35:20.457712', '2025-06-27 09:35:20.457712', NULL, false);
INSERT INTO public.users VALUES ('2819f0f0-45dd-43d4-bfe1-2aea4ba54f88', '97450455487', 'individual', '$2b$10$iSHpyldSAZBFxJ8UxDdUO.638EGZddZb2TMze7ecvxWPKRKTNvTHm', 'Mohammed jabor Alnaemi ', 'ظ…ط­ظ…ط¯ ط¬ط¨ط± ط§ظ„ظ†ط¹ظٹظ…ظٹ ', NULL, NULL, NULL, true, '2025-06-27 19:17:04.405969', '2025-06-27 19:17:04.405969', NULL, false);
INSERT INTO public.users VALUES ('fd28b463-54b3-47fd-a63c-64823673a97e', '97455455263', 'individual', '$2b$10$VqPc2xNQPIJF44pM5.OZiOcvYrvsEflXmX1DbJlsIuR.T26eQimEq', 'Abo Malek', 'ظ…ط§ظ„ظƒ  ط§ط­ظ…ط¯  ظ…ط­ظ…ط¯ ', NULL, NULL, NULL, true, '2025-06-27 23:30:15.013892', '2025-06-27 23:30:15.013892', NULL, false);
INSERT INTO public.users VALUES ('fd6dc08a-fbb5-4bbf-9c5e-7814ce20e2ff', '9746632 1757', 'individual', '$2b$10$Cd9j.SAFgi60SoSSpIDwsOoiEmDcmfds3Md3SAg.pGJwh75G8IFI6', 'SAMI ', 'ط³ط§ظ…ظٹ', NULL, NULL, NULL, true, '2025-06-28 13:13:45.227711', '2025-06-28 13:13:45.227711', NULL, false);
INSERT INTO public.users VALUES ('20929be2-6841-4599-8721-0ddd11682cce', '97466854262', 'individual', '$2b$10$FXPmtjT7/3TQSSWtw9HQLuCx2RKR2paCVK3JkbehqQsAa7wAW0N..', 'Jassim Rashid Al Kuwari', 'ط¬ط§ط³ظ… ط±ط§ط´ط¯ ط§ظ„ظƒظˆط§ط±ظٹ', NULL, NULL, NULL, true, '2025-06-28 12:21:49.905809', '2025-06-28 12:21:49.905809', NULL, false);
INSERT INTO public.users VALUES ('6f68fd7c-0a10-45b0-8389-5d3e28c88fb9', '97466005999', 'individual', NULL, 'Lolowa abdulla', 'ظ„ظˆظ„ظˆظ‡ ط¹ط¨ط¯ط§ظ„ظ„ظ‡ ', NULL, NULL, NULL, true, '2025-09-19 04:13:00.170041', '2025-09-19 04:13:00.170041', NULL, false);
INSERT INTO public.users VALUES ('00008d13-0bba-4508-b679-1fdee2890c14', '97451400102', 'business', NULL, 'Ahmed Ali ahmed', 'ط§ط­ظ…ط¯ ط¹ظ„ظ‰ ط§ط­ظ…ط¯ ', '62710', 'Royal link real estate services', 'ط±ظˆظٹط§ظ„ ظ„ظٹظ†ظƒ ظ„ظ„ط®ط¯ظ…ط§طھ ط§ظ„ط¹ظ‚ط§ط±ظٹظ‡', true, '2025-07-31 18:29:47.142043', '2025-07-31 18:29:47.142043', NULL, false);
INSERT INTO public.users VALUES ('04a51066-9a4e-4335-8c32-4298d11100e9', '97466333660', 'individual', '$2b$10$MMSFuOjKXN.xGsYMLCX2yOeU4Gx9/5oUBnBFFwFagegU5Utg8n2E6', 'Maryam Jeham Alkuwari', 'ظ…ط±ظٹظ… ط§ظ„ظƒظˆط§ط±ظٹ', NULL, NULL, NULL, true, '2025-06-27 10:01:18.405968', '2025-06-27 10:01:18.405968', NULL, false);
INSERT INTO public.users VALUES ('0780872e-15f7-4077-be2f-dc62a9b503e5', '97430303537', 'individual', NULL, 'Noora alrumaihi ', 'ظ†ظˆط±ط© ط§ظ„ط±ظ…ظٹط­ظٹ', NULL, NULL, NULL, true, '2025-10-11 01:55:47.627511', '2025-10-11 01:55:47.627511', NULL, false);
INSERT INTO public.users VALUES ('c2b9b6ea-c136-4960-a3fa-097c8cead840', '97431070405', 'individual', NULL, 'Al wasata real estate ', 'ط§ظ„ظˆط³ط§ط·ط© ظ„ظ„ظˆط³ط§ط·ط© ط§ظ„ط¹ظ‚ط§ط±ظٹط©', NULL, NULL, NULL, true, '2025-10-30 15:50:53.508085', '2025-10-30 15:50:53.508085', NULL, false);
INSERT INTO public.users VALUES ('783bd113-f64f-49d5-9fb8-300e3298fc4d', '97474748989', 'business', NULL, 'Abu Omar ', 'ط§ط¨ظˆ ط¹ظ…ط± ', '23843', 'Future real estate ', 'ط§ظ„ظ…ط³طھظ‚ط¨ظ„ ظ„ظ„ظˆط³ط§ط·ط© ط§ظ„ط¹ظ‚ط§ط±ظٹط© ', true, '2025-11-01 18:33:36.339658', '2025-11-01 18:33:36.339658', NULL, false);
INSERT INTO public.users VALUES ('aaf8f5fc-dca9-40c5-8002-07e8dd448d4e', '97455889479', 'individual', NULL, 'Mashael', 'ظ…ط´ط§ط¹ظ„', NULL, NULL, NULL, true, '2025-10-05 15:49:14.294775', '2025-10-05 15:49:14.294775', NULL, false);
INSERT INTO public.users VALUES ('e52d212b-5445-466c-a84d-cff878d9476b', '97477993379', 'individual', '$2b$10$uXTD8fOjQTUQHRsC9b340eyI1yYDhoOYz1bAV.98ajr05lezXnsn.', 'RASHID ALSULAITI', 'ط±ط§ط´ط¯ ظ…ط­ظ…ط¯ ط§ظ„ط³ظ„ظٹط·ظٹ', NULL, NULL, NULL, true, '2025-06-28 12:29:36.916167', '2025-06-28 12:29:36.916167', NULL, false);
INSERT INTO public.users VALUES ('d5a1b393-c8c1-4e27-ac6e-b6eaf2476eef', '97477889990', 'individual', '$2b$10$iLGRpYGlzzbTNRhlhdWc3ubqUou6hrEeLc3oV4M62cIJQh5dzZEOa', 'A', 'ط¹', NULL, NULL, NULL, true, '2025-06-28 12:41:21.999517', '2025-06-28 12:41:21.999517', NULL, false);
INSERT INTO public.users VALUES ('22d3e355-3245-427c-9267-6988a00e085e', '97451333317', 'individual', '$2b$10$8gElfHpJS8tJGP5PId/zV.FJGT1ZFKrzSmziEmBny/XxcxcXyJ7gm', 'mahmmad ', 'ظ…ط­ظ…ط¯ ط³ط§ظ„ظ… ', NULL, NULL, NULL, true, '2025-06-28 10:17:40.50919', '2025-06-28 10:17:40.50919', NULL, false);
INSERT INTO public.users VALUES ('4efe0eca-87d6-4b93-adf3-35e707a763b9', '97455236613', 'individual', '$2b$10$yzpjPZqS3RZawWxzFNRdvuOgpdHtpyXO0cr5ehwsf2pjQItnGJf9m', 'Umessa ', 'ط§ظ… ط¹ظٹط³ظ‰ ', NULL, NULL, NULL, true, '2025-06-28 16:25:02.482768', '2025-06-28 16:25:02.482768', NULL, false);
INSERT INTO public.users VALUES ('ef57aadd-48fd-41e0-8661-6cb410069ceb', '97433666012', 'individual', '$2b$10$uL5IO/SfjxNVlrQQS3cf7.ZYUEjvxcZmkh53606iCpOjr3CGb//vm', 'Mohamed Mahmoud ', 'ظ…ط­ظ…ط¯ ظ…ط­ظ…ظˆط¯', NULL, NULL, NULL, true, '2025-06-28 15:06:04.333229', '2025-06-28 15:06:04.333229', NULL, false);
INSERT INTO public.users VALUES ('9e217434-2dce-4177-9a3b-7a9b4ecf0828', '97455836500', 'individual', '$2b$10$F4TiK1dup7MrstndAS/TMeGql3Gg0ZWmX/Y08GzzLUEcDnY1suCvi', 'Fatma', 'ظپط§ط·ظ…ظ‡ ط§ظ„ط²ظٹط§ط±ظ‡', NULL, NULL, NULL, true, '2025-06-28 16:32:59.089695', '2025-06-28 16:32:59.089695', NULL, false);
INSERT INTO public.users VALUES ('b2e65cb3-d00b-43c6-91c7-4b37766b4a39', '97455525342', 'individual', '$2b$10$d8bYL2G3x00eVjDxL9DBPenOmnabxsTpiPZWL8v9yoj7QCwsivv8i', 'Ahmed Al Emadi', 'ط£ط­ظ…ط¯ ط§ظ„ط¹ظ…ط§ط¯ظٹ ', NULL, NULL, NULL, true, '2025-06-28 16:59:38.006357', '2025-06-28 16:59:38.006357', NULL, false);
INSERT INTO public.users VALUES ('de0072b5-690b-4e67-b250-dd4f178e4144', '97455859510', 'individual', '$2b$10$sovgC99ePmHqDCpNO6YSR.cMkH4BqY0pgt4Z.Wiq3SoDRTmIgwFU.', 'Muntasir Ali', 'ظ…ظ†طھطµط± ط¹ظ„ظٹ', NULL, NULL, NULL, true, '2025-06-29 01:07:40.153048', '2025-06-29 01:07:40.153048', NULL, false);
INSERT INTO public.users VALUES ('7469a120-e9ca-400d-b5c4-723ee6c261a9', '97455199922', 'individual', '$2b$10$temDq3oCKb9/h3h/97V4ieOW2P421s8fGRKFph6KHsEOKtrVjVORe', 'Mohammed ALSahli ', 'ظ…ط­ظ…ط¯ ط§ظ„ط³ظ‡ظ„ظٹ', NULL, NULL, NULL, true, '2025-06-29 05:33:39.329773', '2025-06-29 05:33:39.329773', NULL, false);
INSERT INTO public.users VALUES ('dad5668f-8804-494f-9d7d-3358a200a06a', '97455878887', 'individual', '$2b$10$g6pBMWZPm2Ps4RKpIO7pIuVldsDh74wPuZa9v1lTnUvbE5cKtt2oy', 'ALi Mohammed ALSaadi ', 'ط¹ظ„ظٹ ظ…ط­ظ…ط¯ ط§ظ„ط³ظ€ظ€ظ€ظ€ظ€ط¹ط¯ظٹ ', NULL, NULL, NULL, true, '2025-06-29 09:17:31.690894', '2025-06-29 09:17:31.690894', NULL, false);
INSERT INTO public.users VALUES ('53241b5b-ad7c-490b-9ac4-5d25cfbf6546', '97455519207', 'individual', '$2b$10$BFJHk/cJffqOyx48eNOsruEirXjBhEtXPeGnEGITTqJ6Haykm1nHW', 'Ali H Alemadi', 'ط¹ظ„ظٹ ط§ظ„ط¹ظ…ط§ط¯ظٹ', NULL, NULL, NULL, true, '2025-06-29 11:00:47.835273', '2025-06-29 11:00:47.835273', NULL, false);
INSERT INTO public.users VALUES ('b92d4573-ff59-4f73-a3fd-a77ba354644e', '97455550901', 'individual', '$2b$10$uc/a0Vyd/0OE2HcwOIRqWe9hzivwvMP3zdCAyiOaocMt0M/qAnozG', 'Salem Mubarak ALMOSALLAM ', 'ط³ط§ظ„ظ… ظ…ط¨ط§ط±ظƒ ط§ظ„ظ…ط³ظ„ظ…', NULL, NULL, NULL, true, '2025-06-29 00:41:53.019107', '2025-06-29 00:41:53.019107', NULL, false);
INSERT INTO public.users VALUES ('e8a265c9-4c27-46b2-a5c9-a492d3b0e8e1', '97433028280', 'individual', '$2b$10$MFZO.JulVd6WaUR46uPlSeJBRzgAbE1e47TkwogQeGhYUjDFZ.rD6', 'Mohammed', 'ظ…ط­ظ…ط¯ ', NULL, NULL, NULL, true, '2025-06-29 01:29:20.24356', '2025-06-29 01:29:20.24356', NULL, false);
INSERT INTO public.users VALUES ('623b7832-d1cf-46f5-8147-dcd3850e401f', '97455144332', 'business', '$2b$10$Q8ReDPA9IK/i8dS9GTTZuuyfjyWxQRJDQ9eVYodLyK6Z05hpKz4Ou', 'Edinburgh real estate ', 'ط£ط¯ظٹظ†ط¨ط±ط© ظ„ظ„ط¹ظ‚ط§ط±ط§طھ', '19696', 'Edinburgh real estate ', 'ط£ط¯ظٹظ†ط¨ط±ط© ظ„ظ„ط¹ظ‚ط§ط±ط§طھ', true, '2025-06-29 11:44:07.794698', '2025-06-29 11:44:07.794698', NULL, false);
INSERT INTO public.users VALUES ('f5002ca7-cefd-46b9-9897-a99512b09969', '97451516111', 'individual', '$2b$10$6qOtqt2kU5V6lubOvd01cO6vjJPVJsl1nCVCu86eAkQEiOXTniByC', 'Faisal M Alqahtani', 'ظپظٹطµظ„ ظ…ط·ظ„ظ‚ ط§ظ„ظ‚ط­ط·ط§ظ†ظٹ', NULL, NULL, NULL, true, '2025-06-29 10:48:33.898506', '2025-06-29 10:48:33.898506', NULL, false);
INSERT INTO public.users VALUES ('3dfb9c67-3567-41d9-8f67-5ac7d83adc20', '97470177289', 'business', '$2b$10$IGU9EN9lQJYCo4GF48926edUKZrQj/snQAP6bDWJNCDHiq3M.h4Iy', 'Tawheed real estat ', 'ط§ظ„طھظˆط­ظٹط¯ ظ„ظ„ط¹ظ‚ط§ط±ط§طھ ', '70478', 'Tawheed real estat', 'ط§ظ„طھظˆط­ظٹط¯ ظ„ظ„ط¹ظ‚ط§ط±ط§طھ ', true, '2025-06-28 21:04:16.911855', '2025-06-28 21:04:16.911855', NULL, false);
INSERT INTO public.users VALUES ('4e7f67da-06c8-41be-b7c9-0dfbb8f4a800', '97433115539', 'individual', '$2b$10$jM7IV2AD18R/7QxK2GA/RuweV0r8LPB1dgJuOCqmihK3AHhInRGD.', 'Ahmad Alkuwari ', 'ط§ط­ظ…ط¯ ط§ظ„ظƒظˆط§ط±ظٹ', NULL, NULL, NULL, true, '2025-06-29 13:15:21.496376', '2025-06-29 13:15:21.496376', NULL, false);
INSERT INTO public.users VALUES ('c8e83ebc-91ce-45c8-9429-111284110e19', '97466800538', 'individual', '$2b$10$IkZiCVFYrVIUCTWLbxhKpOwGeHPT77PouLy4sOWUxiKhKrTqPuMWi', 'Mohammed saad alghanim', 'ظ…ط­ظ…ط¯ ط³ط¹ط¯ ط§ظ„ط؛ط§ظ†ظ…', NULL, NULL, NULL, true, '2025-06-30 02:59:07.133582', '2025-06-30 02:59:07.133582', NULL, false);
INSERT INTO public.users VALUES ('577a2f88-a4b5-4e31-9c2d-38db3f8dff93', '97455354488', 'individual', '$2b$10$DON9pBfFgOkEeBXI3gF39ewGGNyaUjxVhNkMLO/QKtRjWP7UYLtv.', 'Jaber ALKUWARI ', 'ط¬ط§ط¨ط± ط§ظ„ظƒظˆط§ط±ظٹ ', NULL, NULL, NULL, true, '2025-07-02 15:29:45.013491', '2025-07-02 15:29:45.013491', NULL, false);
INSERT INTO public.users VALUES ('5361ff5c-a289-4efb-865e-bd720ebf71c3', '97466174008', 'business', '$2b$10$7jz.cTehateWzPAZoqaYIeDWBxNHvU9W8xzZjESIkTj7Gc7Bwae.y', 'AlFahd Real Estate Services', 'ط´ط±ظƒط© ط§ظ„ظپظ‡ط¯ ظ„ظ„ط®ط¯ظ…ط§طھ ط§ظ„ط¹ظ‚ط§ط±ظٹط© ', '185604', 'AlFahd Real Estate Services', 'ط´ط±ظƒط© ط§ظ„ظپظ‡ط¯ ظ„ظ„ط®ط¯ظ…ط§طھ ط§ظ„ط¹ظ‚ط§ط±ظٹط© ', true, '2025-07-05 04:43:04.561538', '2025-07-05 04:43:04.561538', NULL, false);
INSERT INTO public.users VALUES ('05072fcb-1a78-4ec6-bb1e-807deed7328b', '97466532220', 'individual', '$2b$10$kM4LUsVpE6UAvbLymDtBKePBGc3XW7XgMMMmkxl80su30DZNoGhc2', 'Moza k ', 'ظ…ظˆط²ط© ط§ظ„ط؛ط§ظ†ظ…', NULL, NULL, NULL, true, '2025-06-30 20:09:49.743537', '2025-06-30 20:09:49.743537', NULL, false);
INSERT INTO public.users VALUES ('79125d80-1341-41be-8c3b-d2876faa4bf0', '97466677722', 'individual', '$2b$10$/HBmp1g3YvbFkaYQwlWN4euUMM/zSKjJMPKMTZ5sEUXZac/YI4y3a', 'Abdulla Ahmad AlBinali', 'ط¹ط¨ط¯ط§ظ„ظ„ظ‡ ط§ط­ظ…ط¯ ط§ظ„ط¨ظ†ط¹ظ„ظٹ ', NULL, NULL, NULL, true, '2025-07-03 10:10:01.640548', '2025-07-03 10:10:01.640548', NULL, false);
INSERT INTO public.users VALUES ('0ab49dc3-6bf7-452f-8bb0-0f13d32583b5', '97470770006', 'individual', '$2b$10$wQk/xiBrzMK7QcF2VYJPnesybJuepJ4gFfkR5EMIo6iO/X657/.lO', 'Jawaher ', 'ط¬ظˆط§ظ‡ط±', NULL, NULL, NULL, true, '2025-07-05 20:46:30.811503', '2025-07-05 20:46:30.811503', NULL, false);
INSERT INTO public.users VALUES ('b35fe95c-50c6-48bc-917f-15fdb22f9251', '97455557405', 'individual', '$2b$10$5XMZJemxAx8nkERTYq0kZevpPB10YvDq7tmzOa2PP.DIcCITukb7m', 'Rashed alkaabi', 'ط±ط§ط´ط¯ ط§ظ„ظƒط¹ط¨ظٹ', NULL, NULL, NULL, true, '2025-07-03 15:29:27.422731', '2025-07-03 15:29:27.422731', NULL, false);
INSERT INTO public.users VALUES ('c3e9bc71-53a6-49f4-8dde-3819c025f52a', '97433223255', 'individual', '$2b$10$hUhYhuGLS5YiDkcNJSyaQOqXXNPKU100jQBlv5AgWn6stXZ41VpyO', 'Ibrahim Jassim Ibrahim AlBangith AlKuwari', 'ط§ط¨ط±ط§ظ‡ظٹظ… ط¬ط§ط³ظ… ط§ط¨ط±ط§ظ‡ظٹظ… ط§ظ„ط¨ظ†ط؛ظٹط« ط§ظ„ظƒظˆط§ط±ظٹ', NULL, NULL, NULL, true, '2025-07-03 16:49:55.443335', '2025-07-03 16:49:55.443335', NULL, false);
INSERT INTO public.users VALUES ('3444da7d-2a47-46fc-bfa8-305f1f1cd0f5', '97433245000', 'individual', '$2b$10$GhPenFngL7WJI0yixP/wrep.fTAnoi2bil49seeEY2zHR6yALhPVa', 'Fadel Mohamed ', 'ظپط¶ظ„ ظ…ط­ظ…ط¯ ', NULL, NULL, NULL, true, '2025-07-04 08:51:12.042854', '2025-07-04 08:51:12.042854', NULL, false);
INSERT INTO public.users VALUES ('f8e40090-869b-47dc-94ec-f1e2a13a9781', '97433443644', 'individual', '$2b$10$r8ksWVGZaaM/ka0NBru3t.XdIXP8uV1OcrYzQjBmGnHKyaQ66jcz6', 'Ibrahim saleh alkhalaf', 'ط¥ط¨ط±ط§ظ‡ظٹظ… طµط§ظ„ط­ ط§ظ„ط®ظ„ظپ ', NULL, NULL, NULL, true, '2025-07-04 16:35:22.932623', '2025-07-04 16:35:22.932623', NULL, false);
INSERT INTO public.users VALUES ('0b84d6dd-a098-4d39-a6e5-e1dc95b64c0c', '97430239000', 'business', NULL, 'Eltawhid Real Estate ', 'ط´ط±ظƒظ‡ ط§ظ„طھظˆط­ظٹط¯ ظ„ظ„ط¹ظ‚ط§ط±ط§طھ ', '42550', 'Eltawhid Real Estate ', 'ط´ط±ظƒظ‡ ط§ظ„طھظˆط­ظٹط¯ ظ„ظ„ط¹ظ‚ط§ط±ط§طھ ', true, '2025-07-08 01:07:51.488788', '2025-07-08 01:07:51.488788', NULL, false);
INSERT INTO public.users VALUES ('ffb9f47f-1211-45aa-83fb-b80fc95f641b', '97466306668', 'business', NULL, 'Ahmed alshataf', 'ط§ط­ظ…ط¯ ط§ظ„ط´ط·ظپ ', '38838', 'Hamdan Real Estate ', 'ظ‡ظ…ط¯ط§ظ† ظ„ظ„ظˆط³ط§ط·ط© ط§ظ„ط¹ظ‚ط§ط±ظٹط© ', true, '2025-07-08 02:33:26.869098', '2025-07-08 02:33:26.869098', NULL, false);
INSERT INTO public.users VALUES ('a2a4af59-a57c-4707-90b9-ccc96c3fc375', '97455532848', 'individual', '$2b$10$8QGZG9PN7pbvGZhNqAc1tOgrjmhGSvuBkXka0he8i6zxD7flg1PsC', 'Saeed Alkuwari', 'ط³ط¹ظٹط¯ ط§ظ„ظƒظˆط§ط±ظٹ', NULL, NULL, NULL, true, '2025-07-02 02:54:24.307787', '2025-07-02 02:54:24.307787', NULL, false);
INSERT INTO public.users VALUES ('56b75a8b-cdbd-4a83-886f-0ea82b211d94', '97459905959', 'individual', '$2b$10$xRL4Cs.PMam6mpcM8Y.9fOXlAXouGSwshGE9f.x/yfkRkNX.DtYgS', 'Noora', 'ظ†ظˆط±ظ‡', NULL, NULL, NULL, true, '2025-06-30 17:07:38.573199', '2025-06-30 17:07:38.573199', NULL, false);
INSERT INTO public.users VALUES ('3e52dcb2-56f3-40c5-abe6-e8635d66b747', '97466271860', 'individual', NULL, 'Noor ظ…ظ‚ط¯ط§ط¯', 'ظ†ظˆط± ظ…ط­ظ…ط¯', NULL, NULL, NULL, true, '2025-08-01 12:30:28.953529', '2025-08-01 12:30:28.953529', NULL, false);
INSERT INTO public.users VALUES ('639a1ec9-f683-4984-b899-35b02184e458', '97433412444', 'individual', NULL, 'Maryam', 'ظ…ط±ظٹظ…', NULL, NULL, NULL, true, '2025-08-07 13:13:04.668731', '2025-08-07 13:13:04.668731', NULL, false);
INSERT INTO public.users VALUES ('d0880d45-abd0-4ea5-b261-424165c53e68', '97477901126', 'individual', NULL, 'Aitizaz Arbab', 'ط§ط¹طھط²ط§ط² ط§ط±ط¨ط§ط¨', NULL, NULL, NULL, true, '2025-07-08 05:58:39.226023', '2025-07-08 05:58:39.226023', NULL, false);
INSERT INTO public.users VALUES ('424acb9c-f664-4787-848c-7f5feae62600', '97466777446', 'individual', NULL, 'Khalifa mohammed alsowaidi', 'ط®ظ„ظٹظپظ‡ ظ…ط­ظ…ط¯ ط§ظ„ط³ظˆظٹط¯ظٹ', NULL, NULL, NULL, true, '2025-08-03 03:52:48.467298', '2025-08-03 03:52:48.467298', NULL, false);
INSERT INTO public.users VALUES ('0c6662c0-34de-4bf7-94ae-7b3d716616b1', '97433037738', 'individual', NULL, 'Tony', 'ط·ظˆظ†ظٹ', NULL, NULL, NULL, true, '2025-07-22 11:17:28.273714', '2025-07-22 11:17:28.273714', NULL, false);
INSERT INTO public.users VALUES ('02189a7c-48a4-4636-8c4e-c2b0400b4148', '97470358928', 'individual', NULL, 'Muhammad ', 'ظ…ط­ظ…ط¯', NULL, NULL, NULL, true, '2026-01-14 23:27:53.38166', '2026-01-14 23:27:53.38166', NULL, false);
INSERT INTO public.users VALUES ('24800bb4-d6ef-4589-85c4-50461d24f3ef', '97466999080', 'individual', NULL, 'Saeed', 'ط³ط¹ظٹط¯ ط±ط§ط´ط¯ ط§ظ„ظ†ط¹ظٹظ…ظٹ', NULL, NULL, NULL, true, '2025-07-26 13:02:00.153056', '2025-07-26 13:02:00.153056', NULL, false);
INSERT INTO public.users VALUES ('f660dd0b-f66c-406a-a688-e30374396930', '97433736861', 'business', NULL, 'elsayed mohamed essa khater', 'ط§ظ„ط³ظٹط¯ ظ…ط­ظ…ط¯ ط¹ظٹط³ظٹ ط®ط§ط·ط±', '24502', 'bin mohsmed', 'ط¨ظ† ظ…ط­ظ…ط¯', true, '2025-07-26 16:09:29.942805', '2025-07-26 16:09:29.942805', NULL, false);
INSERT INTO public.users VALUES ('aebc34d1-314e-4a4a-99f7-dba29d312993', '97466911499', 'individual', NULL, 'Omer', 'ط¹ظ…ط± طµط§ظ„ط­ ', NULL, NULL, NULL, true, '2025-08-11 13:53:52.788883', '2025-08-11 13:53:52.788883', NULL, false);
INSERT INTO public.users VALUES ('6246c26b-f7e6-4ab3-add1-b47ad7a3e780', '97470608887', 'individual', NULL, 'Rouwaid jabbar', 'ط±ظˆظٹط¯ ط§ظ„ط¬ط¨ط§ط± ', NULL, NULL, NULL, true, '2025-07-26 05:06:34.069123', '2025-07-26 05:06:34.069123', NULL, false);
INSERT INTO public.users VALUES ('f16ca49e-bdb5-476b-a41c-609a768712da', '97455855494', 'individual', NULL, 'Khalid Mohammed Majed alkuwari', 'ط®ط§ظ„ط¯ ظ…ط­ظ…ط¯ ط§ظ„ظƒظˆط§ط±ظٹ', NULL, NULL, NULL, true, '2025-08-17 01:41:14.470172', '2025-08-17 01:41:14.470172', NULL, false);
INSERT INTO public.users VALUES ('3cea39f6-61b2-441b-81e4-ddc26681fb51', '97470280828', 'individual', NULL, 'Yacoub AlYacoub', 'ظٹط¹ظ‚ظˆط¨ ط§ظ„ظٹط¹ظ‚ظˆط¨', NULL, NULL, NULL, true, '2025-08-20 04:08:02.196501', '2025-08-20 04:08:02.196501', NULL, false);
INSERT INTO public.users VALUES ('6189477a-3da4-4848-8e82-73b886cf7220', '97433331995', 'individual', NULL, 'Fatma hassan', 'ظپط§ط·ظ…ظ‡ ط­ط³ظ†', NULL, NULL, NULL, true, '2025-09-14 10:49:14.997753', '2025-09-14 10:49:14.997753', NULL, false);
INSERT INTO public.users VALUES ('4c1bb78f-d6ea-4efd-ab64-713fffa06f65', '97466119966', 'individual', NULL, 'Nasser', 'ظ†ط§طµط±', NULL, NULL, NULL, true, '2025-11-12 23:24:34.957076', '2025-11-12 23:24:34.957076', NULL, false);
INSERT INTO public.users VALUES ('79c3350c-32cc-4fdf-832a-d8922e5341e3', '97466777761', 'individual', NULL, 'Yousef Alfakhroo ', 'ظٹظˆط³ظپ ط§ط¨ط±ط§ظ‡ظٹظ… ط§ظ„ظپط®ط±ظˆ', NULL, NULL, NULL, true, '2025-10-27 05:50:08.208495', '2025-10-27 05:50:08.208495', NULL, false);
INSERT INTO public.users VALUES ('3a1f8c9e-9616-4358-ae66-8ab68fe7e67d', '97455553575', 'individual', NULL, 'A j ', 'طµ ط¬ظƒ ', NULL, NULL, NULL, true, '2025-08-26 17:23:27.211536', '2025-08-26 17:23:27.211536', NULL, false);
INSERT INTO public.users VALUES ('4a66d5ab-3165-455b-a364-5125ca32d370', '97450135015', 'individual', NULL, 'Mahmoud Hashem ', 'ظ…ط­ظ…ظˆط¯ ظ‡ط§ط´ظ… ', NULL, NULL, NULL, true, '2025-09-16 16:11:13.260462', '2025-09-16 16:11:13.260462', NULL, false);
INSERT INTO public.users VALUES ('d143a3e6-1660-4d5e-bec3-9e4aaaf17dbc', '97430696668', 'business', NULL, 'Catalyst Technology and Services ', 'ظƒط§طھط§ظ„ظٹط³طھ طھظƒظ†ظˆظ„ظˆط¬ظٹ ط§ظ†ط¯ ط³ظٹط±ظپظٹط³ط² ', '276948', 'Catalyst Technology and Services ', 'ظƒط§طھط§ظ„ظٹط³طھ طھظƒظ†ظˆظ„ظˆط¬ظٹ ط§ظ†ط¯ ط³ظٹط±ظپظٹط³ط² ', true, '2025-08-27 21:37:04.426389', '2025-08-27 21:37:04.426389', NULL, false);
INSERT INTO public.users VALUES ('97867041-9d12-489d-8d22-18ef95644dc2', '97466617039', 'individual', NULL, 'Faisal Al Shamari', 'ظپظٹطµظ„ ط§ظ„ط´ظ…ط±ظٹ ', NULL, NULL, NULL, true, '2025-08-31 09:30:29.645386', '2025-08-31 09:30:29.645386', NULL, false);
INSERT INTO public.users VALUES ('167eb49e-8be0-4ad7-b425-70290b294c35', '97471770100', 'individual', NULL, 'Abdulrahman alhafiz', 'ط¹ط¨ط¯ط§ظ„ط±ط­ظ…ظ† ط¹ظ…ط§ط¯ ط§ظ„ط­ط§ظپط¸', NULL, NULL, NULL, true, '2025-08-26 00:19:23.73108', '2025-08-26 00:19:23.73108', NULL, false);
INSERT INTO public.users VALUES ('573e130f-af93-4c27-b46c-8931295ed5e0', '97455424617', 'individual', NULL, 'Ahmad Taha', 'ط£ط­ظ…ط¯ ط·ظ‡', NULL, NULL, NULL, true, '2025-11-13 07:42:38.6474', '2025-11-13 07:42:38.6474', NULL, false);
INSERT INTO public.users VALUES ('c8afe2c6-c384-4af4-aff7-714f4100bea2', '97477277292', 'individual', NULL, 'Mohamed Akram Zaidan', 'ظ…ط­ظ…ط¯ ط£ظƒط±ظ… ط²ظٹط¯ط§ظ†', NULL, NULL, NULL, true, '2025-09-19 09:41:03.412162', '2025-09-19 09:41:03.412162', NULL, false);
INSERT INTO public.users VALUES ('a6ac6c51-f18d-4d5b-ad55-bc621162dd65', '97433279898', 'business', NULL, 'Moustafa youssef Dandan', 'ظ…طµط·ظپظ‰ ظٹظˆط³ظپ ط¯ظ†ط¯ظ†', '103011', 'Ariane Properties', 'ط§ط±ظٹط§ظ† ظ„ظ„ط§طµظˆظ„ ', true, '2025-09-15 11:47:03.339574', '2025-09-15 11:47:03.339574', NULL, false);
INSERT INTO public.users VALUES ('fc100b83-b290-406b-b401-2496e791a0a3', '97477075382', 'individual', NULL, 'Khaled ababneh', 'ط®ط§ظ„ط¯ ط¹ط¨ط§ط¨ظ†ظ‡', NULL, NULL, NULL, true, '2025-11-02 14:31:58.035702', '2025-11-02 14:31:58.035702', NULL, false);
INSERT INTO public.users VALUES ('55db8085-c65d-4620-8a53-d4563e0f1df7', '97430808060', 'individual', NULL, 'Alshamari ', 'طھظ…ظٹظ…  ', NULL, NULL, NULL, true, '2025-09-29 19:58:56.729915', '2025-09-29 19:58:56.729915', NULL, false);
INSERT INTO public.users VALUES ('4b718a25-266a-4980-bc25-5c9a2bb69368', '97455061606', 'individual', NULL, 'Bandar Abdullah AlRaeissi', 'ط¨ظ†ط¯ط± ط¹ط¨ط¯ط§ظ„ظ„ظ‡ ط§ظ„ط±ط¦ظٹط³ظٹ', NULL, NULL, NULL, true, '2025-09-07 05:36:57.098638', '2025-09-07 05:36:57.098638', NULL, false);
INSERT INTO public.users VALUES ('e8b3ce15-6f83-4ce4-b3cc-bdfbfebe9cdc', '97477770812', 'individual', NULL, 'Fahad', 'ظپظ‡ط¯', NULL, NULL, NULL, true, '2026-01-12 01:13:57.226317', '2026-01-12 01:13:57.226317', NULL, false);
INSERT INTO public.users VALUES ('bb42f73f-787d-45cf-b9f9-d1b678736de3', '97466887546', 'individual', NULL, 'Mohamed agha Katerjy', 'ظ…ط­ظ…ط¯ط¢ط؛ط§ ', NULL, NULL, NULL, true, '2025-11-11 16:58:11.337709', '2025-11-11 16:58:11.337709', NULL, false);
INSERT INTO public.users VALUES ('cd26b5bd-bbdb-47de-91a1-79dd877dca54', '97431239122', 'individual', NULL, 'Houssam Guessoum ', 'ط­ط³ط§ظ… ظ‚ط³ظˆظ… ', NULL, NULL, NULL, true, '2025-11-11 03:36:49.360451', '2025-11-11 03:36:49.360451', NULL, false);
INSERT INTO public.users VALUES ('ec5813c9-19fe-42a9-a10f-5d0749120e19', '97459999940', 'individual', NULL, 'Mohammed', 'ظ…ط­ظ…ط¯', NULL, NULL, NULL, true, '2025-11-12 02:53:28.485338', '2025-11-12 02:53:28.485338', NULL, false);
INSERT INTO public.users VALUES ('5b903b88-44bc-44e4-a78d-7c04507fb4c0', '97477771209', 'individual', NULL, 'Abdulla Alkuwari', 'ط¹ط¨ط¯ط§ظ„ظ„ظ‡ ط§ظ„ظƒظˆط§ط±ظٹ ', NULL, NULL, NULL, true, '2025-11-21 07:36:50.506232', '2025-11-21 07:36:50.506232', NULL, false);
INSERT INTO public.users VALUES ('d084c5a3-a64e-4c61-a359-d7a8d3433bec', '97455503483', 'individual', NULL, 'Abdulla Alromaihi', 'ط¹ط¨ط¯ط§ظ„ظ„ظ‡ ط§ظ„ط±ظ…ظٹط­ظٹ', NULL, NULL, NULL, true, '2025-11-12 20:51:36.121989', '2025-11-12 20:51:36.121989', NULL, false);
INSERT INTO public.users VALUES ('3d16df30-a24a-4894-a8eb-afef8fcd3cbc', '97433333776', 'individual', '$2b$10$IOx83uf9MKTeTVnlzkmr6e7deQIkoEzII.ER/VZtzhUclV0ZdKYZO', 'Ibrahim Alkuwari ', 'ط§ط¨ط±ط§ظ‡ظٹظ… ط§ظ„ظƒظˆط§ط±ظٹ', NULL, NULL, NULL, true, '2025-06-25 23:26:15.037599', '2025-06-25 23:26:15.037599', NULL, false);
INSERT INTO public.users VALUES ('21c74c71-acb5-484c-96ba-fa9eb14b3af7', '97433233239', 'individual', NULL, 'Abdulla adnan zainal', 'ط¹ط¨ط¯ط§ظ„ظ„ظ‡ ط¹ط¯ظ†ط§ظ† ط²ظٹظ†ظ„ ', NULL, NULL, NULL, true, '2025-10-11 11:35:52.329359', '2025-10-11 11:35:52.329359', NULL, false);
INSERT INTO public.users VALUES ('01302322-812a-44e9-929d-89865c77cd77', '97455553975', 'individual', NULL, 'Mohamed', 'ظ…ط­ظ…ط¯', NULL, NULL, NULL, true, '2025-12-13 15:56:22.638793', '2025-12-13 15:56:22.638793', NULL, false);
INSERT INTO public.users VALUES ('c39d7df4-4abb-4f74-8d95-b9311f628611', '97470091092', 'business', '$2b$10$o/DE02l0iJhYVIURHC/Eke38NSSmZOXeK6Jak7WeBnl01.S0z47lC', 'Mostafa mahdi', 'ظ…طµط·ظپظ‰ ظ…ظ‡ط¯ظ‰', '257975', 'HAMMAT REAL STATE', 'ظ‡ط§ظ…ط§طھ', true, '2025-06-28 12:45:30.433921', '2025-06-28 12:45:30.433921', NULL, false);
INSERT INTO public.users VALUES ('ef919000-6ec3-460a-99af-6f7febf7d64d', '97455005484', 'individual', NULL, 'Sareea', 'ط®ط§ظ„ط¯ ط§ظ„ط´ظ‡ظˆط§ظ†ظٹ', NULL, NULL, NULL, true, '2026-01-11 19:21:08.405792', '2026-01-11 19:21:08.405792', NULL, false);
INSERT INTO public.users VALUES ('bed0ae7e-c4c3-4af6-863a-de42eca3481d', '97477704171', 'individual', NULL, 'Ahmad Saada', 'ط§ط­ظ…ط¯ ', NULL, NULL, NULL, true, '2026-01-16 14:04:20.477631', '2026-01-16 14:04:20.477631', NULL, false);
INSERT INTO public.users VALUES ('731a5aff-a956-462f-80a4-6b2b74c0d239', '97450505200', 'individual', NULL, 'Ameena almulla', 'ط§ظ…ظٹظ†ظ‡ ط§ظ„ظ…ظ„ط§', NULL, NULL, NULL, true, '2026-01-18 05:23:01.331155', '2026-01-18 05:23:01.331155', NULL, false);
INSERT INTO public.users VALUES ('895a4ae5-40a1-4f00-a018-2c382a77f2a0', '97466514800', 'individual', NULL, 'Saber Mbarek', 'طµط§ط¨ط± ظ…ط¨ط§ط±ظƒ', NULL, NULL, NULL, true, '2026-01-31 14:49:06.220492', '2026-01-31 14:49:06.220492', NULL, false);
INSERT INTO public.users VALUES ('69e1435f-cb72-41e2-8495-9a648264c81d', '97466127770', 'business', NULL, 'Wasem', 'ظˆط³ظ…', '131378', 'Wasem Real Estate ', 'ظˆط³ظ… ظ„ظ„ظˆط³ط§ط·ظ‡ ط§ظ„ط¹ظ‚ط§ط±ظٹط© ', true, '2026-01-30 21:06:06.097199', '2026-01-30 21:06:06.097199', NULL, false);
INSERT INTO public.users VALUES ('59586c56-803e-4a73-b28e-5cd75f81b9f2', '97433835133', 'individual', NULL, 'Meteb Alkubaisi', 'ظ…طھط¹ط¨ ط§ظ„ظƒط¨ظٹط³ظٹ', NULL, NULL, NULL, true, '2026-02-03 09:28:30.518223', '2026-02-03 09:28:30.518223', NULL, false);
INSERT INTO public.users VALUES ('2dec2ac2-c2cc-4a89-8608-28b45803d7f3', '97470792706', 'individual', NULL, 'nadir Boumrar', 'ظ†ط¯ظٹط± ط¨ظˆظ…ط±ط§ط±', NULL, NULL, NULL, true, '2026-02-03 13:24:39.829783', '2026-02-03 13:24:39.829783', NULL, false);
INSERT INTO public.users VALUES ('aa8df086-34f4-4a4d-8573-5ddb5ea6978a', '97450003067', 'individual', NULL, 'Umm thamer', 'ط§ظ… ط«ط§ظ…ط± ', NULL, NULL, NULL, true, '2026-02-03 09:41:44.718866', '2026-02-03 09:41:44.718866', NULL, false);
INSERT INTO public.users VALUES ('658ba3e3-2dca-4a35-b82e-7c7ddde13295', '97466057399', 'individual', NULL, 'Saba Ahmed', 'ط³ط¨ط£ ط§ط­ظ…ط¯ ', NULL, NULL, NULL, true, '2026-02-07 20:08:08.336705', '2026-02-07 20:08:08.336705', NULL, false);
INSERT INTO public.users VALUES ('768c34be-cf26-4b96-b679-e0134452a9a7', '97455600224', 'individual', NULL, 'Mohamed Saad', 'ظ…ط­ظ…ط¯ ط³ط¹ط¯ ', NULL, NULL, NULL, true, '2026-02-08 10:28:56.774563', '2026-02-08 10:28:56.774563', NULL, false);
INSERT INTO public.users VALUES ('ef3c139c-4f13-45b8-9e84-bedafc783b2b', '97431120031', 'individual', NULL, 'Samir Saqer ', 'ط³ظ…ظٹط± طµظ‚ط±', NULL, NULL, NULL, true, '2026-02-07 23:30:20.033835', '2026-02-07 23:30:20.033835', NULL, false);
INSERT INTO public.users VALUES ('cf17a3dd-9c8e-451f-ba28-80694a1d546b', '97430343404', 'individual', NULL, 'Noura Al-Kuwari', 'ظ†ظˆط±ظ‡ ط§ظ„ظƒظˆط§ط±ظٹ ', NULL, NULL, NULL, true, '2026-02-13 17:33:39.446641', '2026-02-13 17:33:39.446641', NULL, false);
INSERT INTO public.users VALUES ('806b2aba-4d90-4a2c-b438-99634dc9f028', '97466667844', 'individual', NULL, 'Khalid Ali Alahbabi', 'ط®ط§ظ„ط¯ ط¹ظ„ظٹ ط§ظ„ط£ط­ط¨ط§ط¨ظٹ', NULL, NULL, NULL, true, '2026-02-22 09:45:41.98661', '2026-02-22 09:45:41.98661', NULL, false);
INSERT INTO public.users VALUES ('7160f7bb-a60a-49b1-a188-629b7303a667', '97466676597', 'individual', NULL, 'Ahmad Alkuwari ', 'ط§ط­ظ…ط¯ ط§ظ„ظƒظˆط§ط±ظٹ', NULL, NULL, NULL, true, '2026-02-25 08:24:58.927802', '2026-02-25 08:24:58.927802', NULL, false);
INSERT INTO public.users VALUES ('bd6a512d-9630-4887-a653-67aa37e9e857', '97466607699', 'individual', NULL, 'Hhunn', 'طھط¨ظ†ط°', NULL, NULL, NULL, true, '2026-03-07 09:35:38.396639', '2026-03-07 09:35:38.396639', NULL, false);
INSERT INTO public.users VALUES ('adf6fa6c-f507-47e4-a080-cb13cb648c19', '97433303223', 'individual', NULL, 'mohamed', 'ظ…ط­ظ…ط¯', NULL, NULL, NULL, true, '2026-03-19 21:54:56.170541', '2026-03-19 21:54:56.170541', NULL, false);
INSERT INTO public.users VALUES ('80f2c372-4bd2-4812-8a81-c7e665c32a49', '97450044666', 'business', NULL, 'Rashed alkaabi', 'ط±ط§ط´ط¯ ط§ظ„ظƒط¹ط¨ظٹ', '148370', 'Rakovsky real estate', 'ط±ط§ظƒظˆظپط³ظƒظٹ ط§ظ„ط¹ظ‚ط§ط±ظٹظ‡', true, '2026-04-08 11:21:14.716625', '2026-04-08 11:21:14.716625', NULL, false);
INSERT INTO public.users VALUES ('3d5b5034-a6d7-4531-af1c-89a24c8b25ff', '97471022075', 'individual', NULL, 'amine hussein', 'ط§ظ…ظٹظ† ط§ظ„ط­ط³ظٹظ†', NULL, NULL, NULL, false, '2026-05-03 10:45:04.857901', '2026-05-03 10:45:04.857901', NULL, false);


--
-- Name: categories_category_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.categories_category_id_seq', 23, true);


--
-- Name: cities_city_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cities_city_id_seq', 8, true);


--
-- Name: conditions_condition_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.conditions_condition_id_seq', 3, true);


--
-- Name: otps_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.otps_id_seq', 845, true);


--
-- Name: sale_types_sale_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.sale_types_sale_type_id_seq', 2, true);


--
-- Name: admins admins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admins
    ADD CONSTRAINT admins_pkey PRIMARY KEY (admin_id);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (category_id);


--
-- Name: cities cities_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cities
    ADD CONSTRAINT cities_name_key UNIQUE (name);


--
-- Name: cities cities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cities
    ADD CONSTRAINT cities_pkey PRIMARY KEY (city_id);


--
-- Name: conditions conditions_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conditions
    ADD CONSTRAINT conditions_name_key UNIQUE (name);


--
-- Name: conditions conditions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conditions
    ADD CONSTRAINT conditions_pkey PRIMARY KEY (condition_id);


--
-- Name: otps otps_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.otps
    ADD CONSTRAINT otps_pkey PRIMARY KEY (id);


--
-- Name: posts posts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_pkey PRIMARY KEY (id);


--
-- Name: sale_types sale_types_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sale_types
    ADD CONSTRAINT sale_types_name_key UNIQUE (name);


--
-- Name: sale_types sale_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sale_types
    ADD CONSTRAINT sale_types_pkey PRIMARY KEY (sale_type_id);


--
-- Name: saved_posts saved_posts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.saved_posts
    ADD CONSTRAINT saved_posts_pkey PRIMARY KEY (user_id, post_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- Name: users users_user_phone_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_user_phone_key UNIQUE (user_phone);


--
-- Name: idx_otps_phone_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_otps_phone_created ON public.otps USING btree (phone, created_at);


--
-- Name: idx_posts_global_filter; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_posts_global_filter ON public.posts USING btree (city_id, sale_type_id, is_direct, condition_id, rooms, toilets, land_area, price);


--
-- Name: categories categories_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.categories(category_id);


--
-- Name: posts posts_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(category_id);


--
-- Name: posts posts_city_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_city_id_fkey FOREIGN KEY (city_id) REFERENCES public.cities(city_id);


--
-- Name: posts posts_condition_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_condition_id_fkey FOREIGN KEY (condition_id) REFERENCES public.conditions(condition_id);


--
-- Name: posts posts_sale_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_sale_type_id_fkey FOREIGN KEY (sale_type_id) REFERENCES public.sale_types(sale_type_id);


--
-- Name: posts posts_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- Name: saved_posts saved_posts_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.saved_posts
    ADD CONSTRAINT saved_posts_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.posts(id) ON DELETE CASCADE;


--
-- Name: saved_posts saved_posts_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.saved_posts
    ADD CONSTRAINT saved_posts_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--


