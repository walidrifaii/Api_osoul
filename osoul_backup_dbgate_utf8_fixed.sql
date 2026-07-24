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

INSERT INTO public.posts VALUES ('82277f44-c4db-4102-bfb1-6678ed871a0e', 'ارض للبيع في روضة المطار موقع منتاز شارع وسكه', 1, 2, 19, true, 1, 'ارض فضاء', 2.40, 1, 1, 650.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1751223395/h29tu9jotvigbgsckoxd.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1751223395/ewebmyswvnjxikj8040x.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1751223395/tcd0go2txkxrqrpt6wdi.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1751223395/mbphpli3zmxr4qq0rdea.jpg}', '2025-06-29 18:56:36.821244', '2025-06-29 18:56:36.821244', 'f5002ca7-cefd-46b9-9897-a99512b09969', 'روضة المطار', 682, NULL, NULL, NULL, NULL, '{}');
INSERT INTO public.posts VALUES ('278f5c69-242d-42e5-82ad-359b73e2d63f', '
فيلا في ام قرن للايجار 
مساحة البنيان 460 متر 
٨ غرف وصالة ومجلس داخلى وملحق خارجى. 

مطلوب ١٢  ألف ريال
', 6, 1, 18, false, 2, 'ام قرن ', 12000.00, 8, 5, 460.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1761403325/uploads/cu5lfikvzb2q49q9d9vj.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1761403325/uploads/r3qzw7hwl02zsuq8tem5.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1761403326/uploads/lsqtvlwbayaswcgq3axc.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1761403325/uploads/c6ynkbrbdudngralojyu.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1761403325/uploads/nlsygiefwpje1qufzaip.jpg}', '2025-10-25 14:42:07.940626', '2025-10-25 14:42:07.940626', '00008d13-0bba-4508-b679-1fdee2890c14', 'ام قرن ', 1007, NULL, NULL, NULL, NULL, '{uploads/r3qzw7hwl02zsuq8tem5,uploads/cu5lfikvzb2q49q9d9vj,uploads/lsqtvlwbayaswcgq3axc,uploads/c6ynkbrbdudngralojyu,uploads/nlsygiefwpje1qufzaip}');
INSERT INTO public.posts VALUES ('82050a33-47cd-4704-b6df-4d941b6026c4', 'للايجار مكتب ببركه العوامر مساحه ٩٠ متر مطلوب ٢٨٠٠ ريال', 5, 1, 3, false, 2, 'بركه العوامر', 2800.00, 3, 2, 50.00, '{}', '2025-06-29 08:10:18.020401', '2025-06-29 08:10:18.020401', 'c39d7df4-4abb-4f74-8d95-b9311f628611', 'بركه العوامر', 329, NULL, NULL, NULL, NULL, '{}');
INSERT INTO public.posts VALUES ('a63644ed-0c88-4562-99c7-ec7766d39cc0', 'للبيع أراضي في الرويس أسعار متفاوته 
الفوت من ١٤٥ إلى ١٥٥ 
مساحات من ٩٥٠ لين ١١٥٠', 7, 2, 19, true, 1, '', 1400000.00, NULL, NULL, 960.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1763244725/uploads/cminhoypeht4xkgfwfbi.jpg}', '2025-11-15 22:12:06.014843', '2025-11-15 22:12:06.014843', '801ae98c-66a3-40b6-a34b-9192d248636f', 'الرويس', 479, NULL, NULL, NULL, NULL, '{uploads/cminhoypeht4xkgfwfbi}');
INSERT INTO public.posts VALUES ('ad984bba-787a-4c6e-8fba-09ca3066998f', 'للبيع فيلا فى الخيسه 
خلف الفيستيفال 
مساحه ٥٦٠ متر  
تتكون من :
الدور الارضي  
غرفة سائق 
صالات مفتوحة  + مجلس داخلي 
وغرفة  نوم  ومطبخ داخلي  
الدور الاول : 
صاله  + ٤ غرف نوم ماستر 
البنت هاوس 
صاله + غرفتين نوم ماستر 
الملحق 
مطبخ وغرفه خادمه

مطلوب  :   4.700.000', 1, 2, 18, false, 1, 'الخيسه', 4700000.00, 7, 5, 560.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1769168995/uploads/uhfkzwityjtnsjtghhja.jpg}', '2026-01-23 11:49:56.389006', '2026-01-23 11:49:56.389006', '00008d13-0bba-4508-b679-1fdee2890c14', 'الخيسه', 796, NULL, NULL, NULL, NULL, '{uploads/uhfkzwityjtnsjtghhja}');
INSERT INTO public.posts VALUES ('a0bdc4dc-ed5b-4d9d-ae94-42ca94a4fa3e', 'فرصه للاستثمار 
٣٠ الف ريال شيك واحد شهريا
للبيع فلتين متلاصقات في الريان ٧٥٠ م موقع ممتاز جدا
خلف ش ال شافي 
 كل فيلا  ٦ غرف نوم وصاله ومطبخ ومجلس
 مؤجرين عوائل 
 عقد ٣ سنوات', 2, 2, 18, false, 2, 'الريان', 4500000.00, 7, 5, 748.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1758493036/uploads/fkmmfgemsgynkconsmul.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1758493036/uploads/ccbpb4xplngv7rlzip75.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1758493036/uploads/w6jqgpqrmzrlvqowgypn.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1758493036/uploads/ttsthrf9cltudgk63pwr.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1758493036/uploads/iocy8z3nbj7kconmaafy.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1758493036/uploads/h4m7g2g738xykf8jrnva.jpg}', '2025-09-21 22:17:18.224309', '2025-09-21 22:17:18.224309', '00008d13-0bba-4508-b679-1fdee2890c14', 'الريان', 872, NULL, NULL, NULL, NULL, '{uploads/fkmmfgemsgynkconsmul,uploads/w6jqgpqrmzrlvqowgypn,uploads/ccbpb4xplngv7rlzip75,uploads/h4m7g2g738xykf8jrnva,uploads/ttsthrf9cltudgk63pwr,uploads/iocy8z3nbj7kconmaafy}');
INSERT INTO public.posts VALUES ('dc60e9c7-d842-443d-935d-59864bcc5dc9', 'للاستثمار فى موقع مميز 
فيلا مؤجره للبيع 
فى الخيسه خلف الفيستفال على شارعين امامى وخلفى 
مساحه ٤٤٦ متر ', 6, 2, 18, false, 2, 'الخيسه', 2900000.00, 7, 5, 448.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1777650349/uploads/oiedztxbwx2hr649bwlq.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1777650349/uploads/nvjbol1m7p3umrusmdm4.jpg}', '2026-05-01 15:45:51.219303', '2026-05-01 15:45:51.219303', '00008d13-0bba-4508-b679-1fdee2890c14', 'الخيسه', 3, NULL, NULL, NULL, NULL, '{uploads/nvjbol1m7p3umrusmdm4,uploads/oiedztxbwx2hr649bwlq}');
INSERT INTO public.posts VALUES ('7b7a8d1d-4c6f-481f-9403-dff0f1d415ca', 'للبيع ارض بام صلال محمد مساحات مختلفة سعر الفوت 330 ريال موقع ممتاز ', 3, 2, 19, false, 1, 'ام صلال محمد ', 3000000.00, 8, 5, 850.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1751926090/uploads/ewtu7r3cfzuxewux9l0d.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1751926090/uploads/niuwqzvcoldybie2hjwj.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1751926091/uploads/yrb5zykwv2qk2t0hmokc.jpg}', '2025-07-07 22:08:12.218865', '2025-07-07 22:08:12.218865', '69e24c97-9e3a-495b-9553-21aaf6731354', 'ام صلال محمد ', 712, NULL, NULL, NULL, NULL, '{}');
INSERT INTO public.posts VALUES ('7de33174-135a-46a7-8efc-a928804fc685', '*للبيع 

فيلا على خط الشمال جنب ايكيا مباشره على شارعين زاوية .

فيلا خدمية  640 متر فاضية
 عمر البناء سنتين.

مطلوب 6،000،000  ريال', 6, 2, 18, false, 1, 'الخيسه', 6000000.00, 7, 5, 640.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1756664590/uploads/fpj1eoi3fd5jef9m9f4y.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1756664590/uploads/rvzjibvflt5ljpzpsmfh.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1756664590/uploads/xoe5zoxv96porg1yi4nq.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1756664590/uploads/zk6i5ypdl06mnxzfeuvt.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1756664590/uploads/dyveopj6mzj9ip5ytnds.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1756664590/uploads/oit4vokktvccnon3tmrq.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1756664590/uploads/f6nrucuqfdeilkn96txp.jpg}', '2025-08-31 18:23:12.881186', '2025-08-31 18:23:12.881186', '00008d13-0bba-4508-b679-1fdee2890c14', 'الخيسه ', 1289, NULL, NULL, NULL, NULL, '{uploads/fpj1eoi3fd5jef9m9f4y,uploads/rvzjibvflt5ljpzpsmfh,uploads/f6nrucuqfdeilkn96txp,uploads/zk6i5ypdl06mnxzfeuvt,uploads/xoe5zoxv96porg1yi4nq,uploads/dyveopj6mzj9ip5ytnds,uploads/oit4vokktvccnon3tmrq}');
INSERT INTO public.posts VALUES ('96d075e5-8f1a-4de1-85e8-805f98bc5199', '', 6, 2, 18, false, 2, '1', 5200000.00, 1, 1, 1204.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1752264361/uploads/unfibw2yqhfpdbyut7fe.jpg}', '2025-07-11 20:06:02.500205', '2025-07-11 20:06:02.500205', '0b84d6dd-a098-4d39-a6e5-e1dc95b64c0c', 'الخيسه ', 697, NULL, NULL, NULL, NULL, '{}');
INSERT INTO public.posts VALUES ('80911cea-cc06-414a-a260-14f2232312c8', 'السلام عليكم للبيع ارض حزوم لوسيل ٤٠٠ م السعر المطلوب *مليون و٩٠٠ الف*', 6, 2, 19, false, 1, 'لوسيل', 1900000.00, NULL, NULL, 400.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1761981442/uploads/lhiyebxbwvz0wbfde4qk.jpg}', '2025-11-01 07:17:23.681036', '2025-11-01 07:17:23.681036', '00008d13-0bba-4508-b679-1fdee2890c14', 'لوسيل', 525, NULL, NULL, NULL, NULL, '{uploads/lhiyebxbwvz0wbfde4qk}');
INSERT INTO public.posts VALUES ('5b989cc7-c3a3-4b62-b881-29f653c67acf', 'السلام عليكم ورحمه الله وبركاته 
للبيع فلتين متلاصقات في فريج السودان مقابل نادي السد مباشرة  مساحة 737 م 
تشطيب راقي جداً فيلا مؤجرة علي مركز 
طبي ب  25 ألف ريال والثانية مؤجرة على صالون ب 18 الف ريال 
إجمالي  المدخول الشهري 43 الف', 1, 2, 14, false, 2, 'فريج السودان ', 5700000.00, 10, 5, 737.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1777650502/uploads/cuybkmw07c5uxgzef9si.jpg}', '2026-05-01 15:48:23.434525', '2026-05-01 15:48:23.434525', '00008d13-0bba-4508-b679-1fdee2890c14', 'فريج السودان', 2, NULL, NULL, NULL, NULL, '{uploads/cuybkmw07c5uxgzef9si}');
INSERT INTO public.posts VALUES ('6eef6caa-6f56-4e48-bc34-4f531eb8cf25', 'للبيع فيلا الثمامه القديمه 
مساحه الارض 426م مساحه البناء 557م
مقابل الميره مباشره 
موقع ممتاز جدا 

الدور الارضى 
مجلس داخلى مع مغاسل وحمام 
صاله منفصله مع مغاسل وحمام 
غرفه ماستر ومطبخ داخلى 

الدور الاول 
4 غرف ماستر وصاله 

البنت هاوس 
غرفتين ماستر وصاله كبيره 

الملحلق الخارجى 
مطبخ خارجى 
وغرفه خدامه 
ومغسله ملابس 

مصعد راكب 
الفيلا جبس بورد كامله 
واجهه مودرن حجر 
تشطيب سوبر ديلوكس 

غرفه سائق خارجيه

مكيفات 

مطلوب 3 مليون 800 الف


تواصل معنا 
محمد خاطر 
50067840
مرسانا للوساطة العقارية 
ترخيص وزاره العدل رقم 54', 1, 2, 18, false, 1, 'فيلا سكنيه ', 3800000.00, 7, 5, 426.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1762119088/uploads/tlkndnaumbzsaypjpn4j.jpg}', '2025-11-02 21:31:29.813983', '2025-11-02 21:31:29.813983', 'c0461100-60ce-404a-86a6-86610b5c2f89', 'الثمامه ', 331, NULL, NULL, NULL, NULL, '{uploads/tlkndnaumbzsaypjpn4j}');
INSERT INTO public.posts VALUES ('985b3a1d-a208-430c-9a3e-20b73578759a', '*السلام عليكم للبيع من المالك بيت شعبي فى معيذر المساحة ٨٧٧ م على شارع رئيسي  مؤجر ب ١٢ ألف  مطلوب ٢مليون و ٩٥٠ألف*هو', 2, 2, 18, false, 2, 'معيذر ', 2950000.00, 7, 5, 877.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1758092815/uploads/asimbzq0xcinoplnoi7h.jpg}', '2025-09-17 07:06:56.309063', '2025-09-17 07:06:56.309063', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'معيذر ', 877, NULL, NULL, NULL, NULL, '{uploads/asimbzq0xcinoplnoi7h}');
INSERT INTO public.posts VALUES ('9ae78732-1117-4dc3-b94e-36a050ffb852', 'السلام عليكم 
للببع ارض للبيع ارض بام صلال علي
مساحتها 6250متر
علي شارعين زاوية
مطلوب الفوت 250ريال', 3, 2, 19, false, 1, 'ارض', 17490000.00, 1, 1, 6250.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1753607498/uploads/fwtcgjwjhzbrengspgxt.jpg}', '2025-07-27 09:11:39.362537', '2025-07-27 09:11:39.362537', 'f660dd0b-f66c-406a-a688-e30374396930', 'ام صلال علي', 356, NULL, NULL, NULL, NULL, '{}');
INSERT INTO public.posts VALUES ('e70b30b5-15f4-4580-8bfc-68021b0b5c6b', '
فيلا للبيع في الدحيل مساحه 841 م خلف الريفيرا  عمرها 16 سنه 
تتكون من 
7 غرف ماستر 
ومجلس داخلي منفصل 
وبنت هاوس 
وصالتين وملحق خارجي 
ومطبخ داخلي 
وملحق خارجي 

الفيلا فاضيه وجاهزه للاستلام 
مطلوب 4 مليون و50 الف 
بسعر الارض الفيلا', 1, 2, 18, false, 2, 'الدحيل', 4050000.00, 7, 5, 841.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1761578564/uploads/ycwwd4x8fbrbn0s8hdnv.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1761578564/uploads/dutkbarfth5vlgzmkffw.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1761578564/uploads/bzpo8kaspr5b6gkrqshg.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1761578564/uploads/vsiytqcuyzfngkidw8np.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1761578564/uploads/nodriy1uupedyfm7x1nv.jpg}', '2025-10-27 15:22:45.982794', '2025-10-27 15:22:45.982794', '00008d13-0bba-4508-b679-1fdee2890c14', 'الدحيل', 496, NULL, NULL, NULL, NULL, '{uploads/vsiytqcuyzfngkidw8np,uploads/dutkbarfth5vlgzmkffw,uploads/bzpo8kaspr5b6gkrqshg,uploads/nodriy1uupedyfm7x1nv,uploads/ycwwd4x8fbrbn0s8hdnv}');
INSERT INTO public.posts VALUES ('6aa80bda-e80c-4cc1-9906-4af05885e20f', '🏡 للبيع
أرض في ام قرن علي شارعين زواية
▪️ المساحة: 569 متر 
ا', 6, 2, 19, false, 1, 'ام قرن', 2050000.00, NULL, NULL, 569.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1777671487/uploads/ceoh5anabjzv89psphb4.jpg}', '2026-05-01 21:38:09.151736', '2026-05-01 21:38:09.151736', '00008d13-0bba-4508-b679-1fdee2890c14', 'ام قرن', 3, NULL, NULL, NULL, NULL, '{uploads/ceoh5anabjzv89psphb4}');
INSERT INTO public.posts VALUES ('a678a4de-bc9d-4e3a-acc3-3132185c56f3', 'من المالك 
للبيع بيت في ابوسدره 906 م 
البيت فاضي 
موقع ممتاز قريب شارع الفروسيه الرائيسي
الفوت 276 ريال 
مطلوب 2700.000', 5, 2, 18, false, 3, 'ابوسدره ', 2700000.00, 7, 5, 906.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1758093174/uploads/tbcjjjksus2lxsohuycq.jpg}', '2025-09-17 07:12:55.384219', '2025-09-17 07:12:55.384219', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'ابوسدره ', 851, NULL, NULL, NULL, NULL, '{uploads/tbcjjjksus2lxsohuycq}');
INSERT INTO public.posts VALUES ('d5fd0e3d-c15b-4f64-afd8-52e7a485347b', 'السلام عليكم
للبيع بيت شعبي بالريان
مساحته 728 متر', 2, 2, 18, false, 3, 'بيت شعبي', 2200000.00, 5, 5, 728.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1753608619/uploads/eqkpymmbjerclhv8rmjr.jpg}', '2025-07-27 09:30:20.559492', '2025-07-27 09:30:20.559492', 'f660dd0b-f66c-406a-a688-e30374396930', 'الريان', 930, NULL, NULL, NULL, NULL, '{}');
INSERT INTO public.posts VALUES ('88d10cda-9416-4ae3-8596-04e0bbe78720', '*للبيع *فيلا مؤجره

فيلا بالثمامة الجديدة موقع ممتاز 
على امتداد مول سكوير 
مساحة الفيلا ٤٥٥ م 
مؤجرة بمدخول شهرى  ١٢٠٠٠  ريال (على شركة تقسيم )
على شارعين زاوية 
منهم شارع خدمى امتداد المول 

*اتمام البناء ٢٠١٨ م*

*مطلوب ٢.٩٠٠.٠٠٠  ريال*', 1, 2, 18, false, 1, 'الثمامه', 2900000.00, 7, 5, 455.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1762707341/uploads/vv74av1famjsqykwvgzh.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1762707341/uploads/zt21emfp8ivp6mq2td9f.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1762707341/uploads/xutvoglxiqfpmrojjort.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1762707341/uploads/pdmjhjqqwoxtxl2a8m3p.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1762707341/uploads/ijljfvmahu3jkxsbahtc.jpg}', '2025-11-09 16:55:43.509557', '2025-11-09 16:55:43.509557', '00008d13-0bba-4508-b679-1fdee2890c14', 'الثمامه', 496, NULL, NULL, NULL, NULL, '{uploads/ijljfvmahu3jkxsbahtc,uploads/pdmjhjqqwoxtxl2a8m3p,uploads/vv74av1famjsqykwvgzh,uploads/xutvoglxiqfpmrojjort,uploads/zt21emfp8ivp6mq2td9f}');
INSERT INTO public.posts VALUES ('c018a5bb-b9f4-4ce1-a6fd-534ec9d113ab', 'للبيع 
ستور فى بركة العوامر
مساحة الأرض 2000 متر 
المخزن 1100 متر 
مساحة خارجية كبيرة مع غرفة حارس 
ورخصة سكن عمال 12 غرفة 
يمكن تحويل النشاط لأى نشاط الا النشاط الكيميائي 
رخصة خالصه من الدفاع المدنى
المساحة المغطاة 1000 متر 
مطلوب 3 مليون 100 ألف', 8, 1, 13, false, 2, 'بركة العوامر ', 3100000.00, 1, 1, NULL, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1756058630/uploads/cwc9jwnh66eh9lotcb3g.jpg}', '2025-08-24 18:03:51.265951', '2025-08-24 18:03:51.265951', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'بركة العوامر', 1082, NULL, NULL, NULL, NULL, '{uploads/cwc9jwnh66eh9lotcb3g}');
INSERT INTO public.posts VALUES ('3631b9a9-4f46-4aa9-b4d8-edf279cba882', 'للبيع بيت شعبي بالمره الشرقيه المساحه 1493م البيت بحاله ممتازه ومؤجر ب17الف البيت واجهته كبيره 39م يصلح للفرز او بناء 3 فلل متلاصقه البيع بسعر الارض سعر الفوت 240 ريال نهائي غير قابل', 2, 2, 18, false, 3, 'المرة الشرقية ', 3856000.00, 7, 5, 1493.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1758443329/uploads/ui3dtijm1um9s81vills.jpg}', '2025-09-21 08:28:49.874942', '2025-09-21 08:28:49.874942', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'المرة الشرقية ', 654, NULL, NULL, NULL, NULL, '{uploads/ui3dtijm1um9s81vills}');
INSERT INTO public.posts VALUES ('54d9df10-85cd-455a-a7fc-2baa1b892c5d', 'للبيع فيلا بام قرن ٤٩٩متر والبناء٥٨٠متر
واجهات حجرطبيعي 
تشطيب سوبرديلوكس
اسانسير راكب
واصله ماء وكهرباء
قريب خط الشمال
الدور الارضي ::
مجلس خارجى منفصل
حوش كبير
مجلس داخلي مفتوحه على الصاله 
وغرفتين نوم
وغرفه طعام
الدور الاول ::
٤ غرف نوم ماستر
وصاله 
البنت هاووس::
غرفتين نوم ماستر وصاله
الفلل جديده اول ساكن
جاهزه للسكن واصله ماء وكهرباء


مطلوب للفيلا  3 مليون 350 الف 


تواصل معنا
محمد خاطر 
50067840
مرسانا للوساطه العقارية
ترخيص وزاره العدل رقم 54
', 6, 2, 18, false, 1, 'فيلا سكنيه ', 3350000.00, 7, 5, 499.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1762119614/uploads/rtn1nhu0wcyqglwzq0s5.jpg}', '2025-11-02 21:40:15.972252', '2025-11-02 21:40:15.972252', 'c0461100-60ce-404a-86a6-86610b5c2f89', 'ام قرن ', 423, NULL, NULL, NULL, NULL, '{uploads/rtn1nhu0wcyqglwzq0s5}');
INSERT INTO public.posts VALUES ('0d083aa7-a329-4353-b841-574919aeaf0d', 'للبيع مباشر 

ارض في مدينة خليفة الشمالية مساحه 748م علي شارعين أمامي وخلفي موقع ممتاز جدا 
مقابل مركز صحي مدينة خليفة 

مطلوب نهائي 

3.150.000', 1, 2, 19, false, 1, 'مدينة خليفة الشمالية ', 3150000.00, NULL, NULL, 748.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1756836037/uploads/buydxoueltwi2sapnmps.jpg}', '2025-09-02 18:00:38.852382', '2025-09-02 18:00:38.852382', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'مدينة خليفة الشمالية ', 842, NULL, NULL, NULL, NULL, '{uploads/buydxoueltwi2sapnmps}');
INSERT INTO public.posts VALUES ('5da6563b-1c48-49d3-a5b5-1ebc286d6f15', '
للبيع فيلا فخمة في منطقة ام قرن
مساحة الارض ٤٩٩ تصميم مصمم سعودي خرايط متميزه و تشطيب عالي صالات مفتوحة مع ملحق خارجي و مطبخ داخلي و خارجي غرفة اسانسير و ثلاث غرف نوم فوق و بنت هاوس فيها غرفتين و غرفة سايق و غرفة شغالات مساحة البناء ٤٧٠ و السعر ٣ مليون و ٣٥٠ نهائي', 6, 2, 18, false, 1, 'ام قرن', 3350000.00, 7, 5, 499.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1762593208/uploads/uhgkzqixtyvrpz6nqnlc.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1762593208/uploads/tmd6yhxaqini362eukco.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1762593208/uploads/pztthkuf8z66uuextcvs.jpg}', '2025-11-08 09:13:29.866596', '2025-11-08 09:13:29.866596', '00008d13-0bba-4508-b679-1fdee2890c14', 'ام قرن ', 468, NULL, NULL, NULL, NULL, '{uploads/uhgkzqixtyvrpz6nqnlc,uploads/pztthkuf8z66uuextcvs,uploads/tmd6yhxaqini362eukco}');
INSERT INTO public.posts VALUES ('20c3c516-3483-476c-b938-dfeaff50a92a', 'للبيع فلتين في ام صلال علي مساحة الارض 450 متر ومساحة البناء 437 متر.. صالة ومجلس ومطعم  وعدد 7 غرف 7 حمامات ومطبخ خارجي  وغرفة غسيل وغرفة خادمة وغرفة سائق 
الموقع مميز علي شارعين امامي و خلفي بجانب المسجد 
السعر 3,100,000 ريال  
قابل للجاد', 3, 2, 18, false, 1, 'ام صلال على ', 3100000.00, 8, 5, 450.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1756649899/uploads/q9rms0svg1clv3ndnkyy.jpg}', '2025-08-31 14:18:21.387122', '2025-08-31 14:18:21.387122', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'ام صلال على ', 1065, NULL, NULL, NULL, NULL, '{uploads/q9rms0svg1clv3ndnkyy}');
INSERT INTO public.posts VALUES ('e2c38e12-a684-4f5f-9584-ecdaddd07b57', 'للبيع بيت شعبى بأم صلال محمد شارعين زاويه موقع ممتاز   مساحه 722م مؤجر 16800 الكهروماء 2000 ريال شهرى على المالك صافى الايجار 14800 مطلوب 2500000 
', 3, 2, 19, false, 3, 'ام صلال محمد ', 2500000.00, NULL, NULL, 722.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1763568369/uploads/tenrgaa3i1ltxhnadesh.jpg}', '2025-11-19 16:06:11.240416', '2025-11-19 16:06:11.240416', '00008d13-0bba-4508-b679-1fdee2890c14', 'ام صلال محمد ', 443, NULL, NULL, NULL, NULL, '{uploads/tenrgaa3i1ltxhnadesh}');
INSERT INTO public.posts VALUES ('f069a3bf-2228-45f2-a9be-793edfe534eb', 'للبيع بيت شعبى فى الدفنه 
على شارع وسكه 
موقع مميز ', 1, 2, 19, false, 3, 'الدفنه', 3600000.00, NULL, NULL, 875.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1758495948/uploads/yxnf8exk1luc5cbcsesf.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1758495947/uploads/nc9w8d1h3nmxfn4bfbok.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1758495948/uploads/mcpaiz8dulfehtavoueh.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1758495947/uploads/go8n5a7ehj3kaznb5dao.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1758495947/uploads/tp6ffqfgit5ueqrhxuxc.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1758495948/uploads/l8kgizmalxeodeiokocc.jpg}', '2025-09-21 23:05:49.876712', '2025-09-21 23:05:49.876712', '00008d13-0bba-4508-b679-1fdee2890c14', 'الدفنه', 682, NULL, NULL, NULL, NULL, '{uploads/tp6ffqfgit5ueqrhxuxc,uploads/go8n5a7ehj3kaznb5dao,uploads/l8kgizmalxeodeiokocc,uploads/nc9w8d1h3nmxfn4bfbok,uploads/mcpaiz8dulfehtavoueh,uploads/yxnf8exk1luc5cbcsesf}');
INSERT INTO public.posts VALUES ('7adb1c2c-41df-4bfe-b591-d2ba33207b3e', 'للبيع فيلا ام قرن ٣٧٥ ريال 
٦ غرف ومجلس وصاله ومطبخ خارجي وملحق خارجي 
عمرها ٨ سنوات 
مطلوب ٢٣٠٠٠٠٠', 6, 2, 18, false, 2, 'ام قرن', 2300000.00, 7, 5, 375.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1763572937/uploads/w8nv6c9kamquzhilpqat.jpg}', '2025-11-19 17:22:18.458455', '2025-11-19 17:22:18.458455', '00008d13-0bba-4508-b679-1fdee2890c14', 'ام قرن', 514, NULL, NULL, NULL, NULL, '{uploads/w8nv6c9kamquzhilpqat}');
INSERT INTO public.posts VALUES ('296f6b84-fbcb-4f7c-aecb-adf975a583f3', 'السلام عليكم 
للبيع ارض ب لوسيل ووترفرونت  الوجهة البحرية
مساحتها 1500متر علي شارعين', 6, 2, 19, false, 1, 'ارض', 7500000.00, 1, 1, 1500.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1753607791/uploads/s7lfdnhmpn2miggmqjep.jpg}', '2025-07-27 09:16:32.079499', '2025-07-27 09:16:32.079499', 'f660dd0b-f66c-406a-a688-e30374396930', 'لوسيل', 276, NULL, NULL, NULL, NULL, '{}');
INSERT INTO public.posts VALUES ('85e59f59-7793-455c-8208-bb8ec1640ce8', '🔹 فيلا راقية للبيع في الخيسة🔹

✨ المواصفات:
🏡 المساحة:508م² | مساحة البناء: 588 م²
🏗️ تصميم فريد وتشطيب سوبر ديلوكس

🔸 الخارج:
✅ مجلس خارجي مستقل
✅ مواقف سيارات واسعة
✅حديقة صغيرة في الحوش خلفي
✅غرفة سائق مع حمام 
🔸 الدور الأرضي:
✅ صالة كبيرة بتصميم فاخر
✅ غرفتان ماستر
✅ مطبخ رئيسي مجهز
✅ ملحق خارجي (مطبخ إضافي + غرفة بحمام + مخزن)

🔸 الدور الأول:
✅ 4 غرف ماستر واسعة
✅ صالة عائلية
✅ بلكونة بإطلالة رائعة

🔸 البنتهاوس:
✅ غرفتان ماستر
✅ بانتري (مطبخ صغير)

❄️ التكييف: للفيلا بالكامل
🏡 التشطيب: سوبر ديلوكس بواجهات حجرية
📍 الموقع: مميز الخيسة 

💰 السعر: 4,350,000ريال', 2, 1, 18, false, 1, '', 4350000.00, 6, 5, 508.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1753570440/uploads/cd6odn2dabsksuxtxina.jpg}', '2025-07-26 22:54:01.394847', '2025-07-26 22:54:01.394847', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'الخيسة ', 911, NULL, NULL, NULL, NULL, '{}');
INSERT INTO public.posts VALUES ('9113bec1-3f00-49aa-8e91-320d9036f26c', 'السلام عليكم
للبيع ارض بشعبية خليفة
مساحتها 607 متر', 2, 2, 19, false, 1, 'ارض', 2500000.00, 1, 1, 607.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1753608434/uploads/rvjgqqeqn9mc4jifwjmd.jpg}', '2025-07-27 09:27:15.659161', '2025-07-27 09:27:15.659161', 'f660dd0b-f66c-406a-a688-e30374396930', 'شعبية خليفة', 469, NULL, NULL, NULL, NULL, '{}');
INSERT INTO public.posts VALUES ('e17039e4-51d0-4d57-896e-66f11d1c6c94', 'للبيع بيت شعبى فى معيزر الجنوبى', 1, 1, 18, false, 3, '', 3700000.00, 6, 5, 1019.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1753558576/uploads/tjsmbfblel2kjfjmucjj.jpg}', '2025-07-26 19:36:17.261768', '2025-07-26 19:36:17.261768', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'معيزر الجنوبى', 783, NULL, NULL, NULL, NULL, '{}');
INSERT INTO public.posts VALUES ('908e646a-02e5-4970-94fb-e6c2b5f8aebd', 'السلام عليكم ورحمة الله وبركاته 
للإيجار استور  
في بركة العوامر 
مساحة الارض 1000 م 
مساحة الطابق الارضي 440 م
مساحة الطابق  الميزانين 313 م
يتكون 
1-الارضي معرض+مكتب +حمام 
2- طابق الاول مكاتب مع حمام
3-  8 غرف 
4- 4 حمامات
5- 1 مطابخ 
6- غرفة حارس + حمام +مطبخ
مطلوب 18 ألف ريال', 5, 1, 13, false, 1, 'بركة العوامر ', 18000.00, 9, 5, 0.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1758361901/uploads/u3qsz742ga0tyomybmfi.jpg}', '2025-09-20 09:51:42.18912', '2025-09-20 09:51:42.18912', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'بركة العوامر ', 1260, NULL, NULL, NULL, NULL, '{uploads/u3qsz742ga0tyomybmfi}');
INSERT INTO public.posts VALUES ('52a9cb96-def0-4df2-a9e0-3539e89d0e42', 'السلام عليكم 
للبيع بيت في الخيسه (جريان جنيحات )
مساحه 1195م علي 3 شوارع 
مقابل مسجد موقع ممتاز 
عليه مقترح فرز قطعتين 
المالك ساكن فيه وبيطلع ', 6, 2, 19, false, 2, 'الخيسه ', 5500000.00, NULL, NULL, 1195.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1763650685/uploads/pasdkqwc2p7sudtxqcim.jpg}', '2025-11-20 14:58:06.266204', '2025-11-20 14:58:06.266204', '00008d13-0bba-4508-b679-1fdee2890c14', 'الخيسه.', 292, NULL, NULL, NULL, NULL, '{uploads/pasdkqwc2p7sudtxqcim}');
INSERT INTO public.posts VALUES ('ce20b91c-e690-4054-9984-918bb703594e', '*للبيع من المالك* 

فيلا على خط الشمال جنب ايكيا مباشره على شارعين زاوية .

فيلا خدمية  640 متر فاضية
 عمر البناء سنتين.

مطلوب 6،000،000  ريال', 1, 1, 14, false, 2, 'بجوار ايكيا', 6000000.00, 6, 3, 640.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1755806699/uploads/vqgmh3bwdqptwvnoapzr.jpg}', '2025-08-21 20:05:00.48376', '2025-08-21 20:05:00.48376', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'الخيسة ', 1079, NULL, NULL, NULL, NULL, '{uploads/vqgmh3bwdqptwvnoapzr}');
INSERT INTO public.posts VALUES ('4e19f191-e0cf-4b4f-95ee-d27576048c31', 'فيلا جديدة للبيع بمنطقة ام قرن 
مساحة الارض  ٤٩٩
مساحة البنيان ٤٤٠
سبع غرف ماستر
وملحق خارجي مطبخ وغرفة خدم 
واجهة حجر
مطلوب 3 مليون
', 6, 2, 18, false, 1, 'ام قرن', 3000000.00, 7, 5, 499.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1758001416/uploads/rwzolppeu9bccjzgnrfm.jpg}', '2025-09-16 05:43:37.759543', '2025-09-16 05:43:37.759543', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'أم قرن', 999, NULL, NULL, NULL, NULL, '{uploads/rwzolppeu9bccjzgnrfm}');
INSERT INTO public.posts VALUES ('51a19e99-9490-4e65-be7d-3dd689719748', 'فيلا للايجار فى ام قرن على الاسكان 6 غرف ومجلس وصالة وملحق بالمكيفات', 6, 2, 18, true, 2, 'فيلا', 11000.00, 6, 5, 500.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1753605799/uploads/qzwax6ep4jmpuz85yqbr.jpg}', '2025-07-27 08:43:20.841393', '2025-07-27 08:43:20.841393', 'f660dd0b-f66c-406a-a688-e30374396930', 'ام قرن', 601, NULL, NULL, NULL, NULL, '{}');
INSERT INTO public.posts VALUES ('8e7d8048-9edd-4231-83c2-78f6988d6276', 'للبيع ارضين في شعبية خليفة 
680 متر شارعين امامي وخلفي
 شارع  الشاهينية الخدمي 
', 1, 2, 19, false, 3, 'شعبيه خليفه ', 2560000.00, NULL, NULL, 680.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1761580879/uploads/mt6qcy6ji1gczavp7yg5.jpg}', '2025-10-27 16:01:20.913413', '2025-10-27 16:01:20.913413', '00008d13-0bba-4508-b679-1fdee2890c14', 'شعبيه خليفه', 495, NULL, NULL, NULL, NULL, '{uploads/mt6qcy6ji1gczavp7yg5}');
INSERT INTO public.posts VALUES ('e6035054-a4db-4c45-b816-594fdc2d4989', '', 1, 1, 18, false, 1, '', 4400000.00, 6, 5, 525.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1753570277/uploads/wzuckoefgzx74hhzn6nv.jpg}', '2025-07-26 22:51:18.169342', '2025-07-26 22:51:18.169342', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'الخيسة الجديدة ', 873, NULL, NULL, NULL, NULL, '{}');
INSERT INTO public.posts VALUES ('7ae2e2fb-10c8-41fd-8994-899a63575591', 'للايجار فى سميسمة فيلا ممتازة 
  ٦ غرف ماستر كل غرفه مع حمام
مجلس + حمام 
صالتين 
مطبخ كبير فالطابق الارضي وواحد ثاني صغير فالطابق الاول 
المساحة ٤٠٣م 
طابقين + بنت هاوس
مطلوب ١١ الف ريال قطري فالشهر', 6, 1, 18, false, 2, 'سميسمة ', 11000.00, 6, 5, 500.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1756526686/uploads/xk0n0xera9rkj2vqrqwq.jpg}', '2025-08-30 04:04:48.336121', '2025-08-30 04:04:48.336121', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'سميسمة ', 1874, NULL, NULL, NULL, NULL, '{uploads/xk0n0xera9rkj2vqrqwq}');
INSERT INTO public.posts VALUES ('60c5e109-fe62-4cef-8909-aff7a112ff65', 'السلام عليكم
للبيع ارض بام صلال علي مساحتها 8509متر
علي 3شوارع الفوت 260 ريال', 3, 2, 19, false, 1, 'ارض', 23800000.00, 1, 1, 8509.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1753607896/uploads/xs2odezzivldrhcwjixw.jpg}', '2025-07-27 09:18:17.07104', '2025-07-27 09:18:17.07104', 'f660dd0b-f66c-406a-a688-e30374396930', 'ام صلال علي', 388, NULL, NULL, NULL, NULL, '{}');
INSERT INTO public.posts VALUES ('1cfa83f0-26c5-43e5-bc31-385484854b7a', 'السلام عليكم ورحمة الله
 
للبيع فيلا بأم صلال علي
بحاله جيده جدا 
مساحه الارض 400 متر 

مؤجره علي وزارة الأوقاف
 ب 8000 ريال شهري
 
 عمرها 9 سنوات فقط 
 مطلوب2,200,000 ريال', 3, 2, 18, false, 2, 'ام صلال على ', 2200000.00, 7, 5, 400.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1758199227/uploads/fk2pealmw3jq0hmiqvi3.jpg}', '2025-09-18 12:40:28.101189', '2025-09-18 12:40:28.101189', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'ام صلال على ', 1042, NULL, NULL, NULL, NULL, '{uploads/fk2pealmw3jq0hmiqvi3}');
INSERT INTO public.posts VALUES ('3bc81f11-a702-4947-bfe3-6f3ad16891ba', 'للبيع من المالك مباشرا …
بيت شعبي في منطقه معيذر الجنوبي اللي خلف نادي معيذر في طابق واحد من فوق كيربي 
مساحه 1200م
مؤجر 13 الف ريال شهريا عقد بينتهي في شهر 8 القادم
مساحه الارض / 1196م 
عباره عن ٦ غرف ماستر وصاله ومجلس ومقلد رجالي وغرفه   
واصل السعر 2.800.000 ورفض
المطلوب  2.900.000 غير قابل
شركه التوحيد للعقارات 
ترخيص / 387

تواصل علي الخاص ', 2, 2, 18, false, 3, 'بيت', 2900000.00, 6, 4, 1200.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1757891823/uploads/jantxox2qfzj6dwrkprp.jpg}', '2025-09-14 23:17:04.069915', '2025-09-14 23:17:04.069915', '0b84d6dd-a098-4d39-a6e5-e1dc95b64c0c', 'معيذر', 1100, NULL, NULL, NULL, NULL, '{uploads/jantxox2qfzj6dwrkprp}');
INSERT INTO public.posts VALUES ('375770d8-83a8-4f35-a337-16696f07ba4e', '*للبيع *
بلوك اراضي سكنيه في الوكره 
الجبل قريب من البحر عدد 28
قطعه مساحه القطعه 600م 
تأخذ فلتين متلاصقات واجهه كل قطعه 22 م تقريبا موقع ممتاز 
مطلوب 300 ريال للفوت نهائي 
', 5, 1, 19, false, 1, 'قريب البحر', 1937000.00, NULL, NULL, 600.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1755688415/uploads/juy3hdymdqsnq5qyq5xp.jpg}', '2025-08-20 11:13:35.916047', '2025-08-20 11:13:35.916047', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'الوكرة الجبل', 1073, NULL, NULL, NULL, NULL, '{uploads/juy3hdymdqsnq5qyq5xp}');
INSERT INTO public.posts VALUES ('fbe82a85-cec5-423f-8a4d-47bb38657753', 'للبيع فيلا في منطقة جريان جنيحات 
مساحة الفيلا 508م ومساحة البناء 575م واصل الخدمات شارع قار 20 متر 
تتكون من :- 
الدور الأرضي عباره عن مجلس خارجي 
ومجلس داخلي مع صاله /غرفة ماستر/ مطبخ داخلي / حديقه خلفيه / ملحق خارجي مع مطبخ
الدور الاول / عباره عن ٤ غرف ماستر 
البنت هاوس / عباره عن غرفتين ماستر / صاله / مطبخ تحضيري 
واجهات الفيلا حجر / جيبسبورد / مصعد /غرفة سايق
مطلوب 4,350,000
4,200,000 نهائي', 1, 1, 18, false, 1, '', 4200000.00, 6, 5, 508.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1753570681/uploads/wilqkfd0mnkmn6mvxyls.jpg}', '2025-07-26 22:58:02.459809', '2025-07-26 22:58:02.459809', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'الخيسة جريان جنيحات', 858, NULL, NULL, NULL, NULL, '{}');
INSERT INTO public.posts VALUES ('b6533582-e805-4670-b46f-934a2539b793', 'للإيجار 
فيلا فى الثمامه القديمه 
موقع ممتاز 
تتكون من :- 
الدور  الارضي  :-
صالات مفتوحة مع حمام + غرفتين منهم غرفه ماستر مع ستور
 وغرفه بحمام خارجي
الدور الاول :- 
صالة  + ٤ غرف كل غرفتين  بحمام مشترك  

مطلوب :   ١١٠٠٠  ريال', 1, 1, 18, false, 2, 'الثمامه', 11000.00, 6, 5, 0.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1761993479/uploads/ohc7n2lnq0oxszcxp9n9.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1761993479/uploads/zmr2cwj8ygljqtchj8fp.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1761993479/uploads/lksq82sdwyjpoznx7gbz.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1761993479/uploads/zt4rfphgu4mazjw5vb5p.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1761993479/uploads/oh5p2gucoo2pclksabyr.jpg}', '2025-11-01 10:38:01.546859', '2025-11-01 10:38:01.546859', '00008d13-0bba-4508-b679-1fdee2890c14', 'الثمامه ', 909, NULL, NULL, NULL, NULL, '{uploads/ohc7n2lnq0oxszcxp9n9,uploads/zmr2cwj8ygljqtchj8fp,uploads/lksq82sdwyjpoznx7gbz,uploads/oh5p2gucoo2pclksabyr,uploads/zt4rfphgu4mazjw5vb5p}');
INSERT INTO public.posts VALUES ('8f4b037a-eb1d-44c5-9dd9-cfa84be004b2', 'للبيع فيلا مريخ مقابل اسباير موقع ممتاز جدا 
مساحه الارض / 606م .
على شارعين امامي وخلفي واجهة حجر  
8 غرف نوم ومجلس خارجي 
لفت رخام وتكيف مركزي
ارضي مجلس صالة حمام ومغاسل  غرفة طعام  وغرفة ماستر
مطبخ خارجي وغرفة سايق  وحوش من الخلف
الدور الأول 4 غرف ماستر وصالة 
بنتهاوس 3 غرف  ماستر وصالة ومطبخ تحضيري
 
مطلوب / 5.300.000
للتواصل ع الخاص 
شركه التوحيد للعقارات
ترخيص / 387', 2, 2, 18, false, 1, 'فيلا', 5300000.00, 8, 5, 606.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1757891937/uploads/uqkuaxneetpytpne3lnz.jpg}', '2025-09-14 23:18:58.39125', '2025-09-14 23:18:58.39125', '0b84d6dd-a098-4d39-a6e5-e1dc95b64c0c', 'مريخ', 1244, NULL, NULL, NULL, NULL, '{uploads/uqkuaxneetpytpne3lnz}');
INSERT INTO public.posts VALUES ('d5baff4a-0074-4674-b625-7f97478bb7c9', 'للبيع سوق تجاري في الغرافة مساحة 517 م
عدد المكاتب 8
مؤجرة علي شركة مدخول شهري 83 الف ريال 
عدد المحلات التجارية 4
أستور 2
عمر البناية وبداية الايجار 2017
مطلوب 16 مليون 
', 1, 2, 12, false, 2, 'الغرافه ', 16000000.00, NULL, NULL, NULL, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1770582849/uploads/jpvymccyedu8f4otlsoc.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1770582850/uploads/dldq3smq6y2axzap6pvt.jpg}', '2026-02-08 20:34:11.625255', '2026-02-08 20:34:11.625255', '00008d13-0bba-4508-b679-1fdee2890c14', '', 453, NULL, NULL, NULL, NULL, '{uploads/jpvymccyedu8f4otlsoc,uploads/dldq3smq6y2axzap6pvt}');
INSERT INTO public.posts VALUES ('43bb3afc-5227-4dda-9d12-7d5738044418', ' 
للبيع فيلا الثمامه القديمه 
مساحه الارض 426م مساحه البناء 557م
مقابل الميره مباشره 
موقع ممتاز جدا 

الدور الارضى 
مجلس داخلى مع مغاسل وحمام 
صاله منفصله مع مغاسل وحمام 
غرفه ماستر ومطبخ داخلى 

الدور الاول 
4 غرف ماستر وصاله 

البنت هاوس 
غرفتين ماستر وصاله كبيره 

الملحلق الخارجى 
مطبخ خارجى 
وغرفه خدامه 
ومغسله ملابس 

مصعد راكب 
مكيفات 
الفيلا جبس بورد كامله 
واجهه مودرن حجر 
تشطيب سوبر ديلوكس 
غرفه سائق خارجيه
مكيفات
واصله ماء وكهرباء
اسانسير راكب
مطلوب 3 مليون 750 الف', 1, 2, 18, false, 1, 'الثمامه', 3750000.00, 7, 5, 426.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1766665543/uploads/m1f9uidk7z2mznucecn8.jpg}', '2025-12-25 12:25:43.990492', '2025-12-25 12:25:43.990492', '00008d13-0bba-4508-b679-1fdee2890c14', 'الثمامه', 1183, NULL, NULL, NULL, NULL, '{uploads/m1f9uidk7z2mznucecn8}');
INSERT INTO public.posts VALUES ('0bef2049-b775-472a-846f-a12eeda9527e', '
للبيع  فيلا جديدة في ام قرن مساحة الارض 420 م مساحة البناء 510 م 
تشطيب ممتاز بها مجلس خارجي 

تتكون من :- 
مجلس خارجي
الطابق الأرضي: مجلس خارجي و مجلس داخلي منفصل وصاله كبيره وغرفة طعام و غرفة ماستر

الدور الاول : 4 غرف ماستر وصاله 

البنت هاوس: غرفتين ماستر وصاله 
الملحق الخارجي : مطبخ خارجي، وغرفة غسيل، وغرفة للخادمة،
مجلس خارجي
موقف سيارة مع مظلة
تشطيب ممتاز جبس بالكامل درايش بوبي في سي 
', 1, 2, 18, false, 1, 'ام قرن', 2900000.00, 7, 5, 420.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1763712586/uploads/fgn0l2hdct2tfp8kxudk.jpg}', '2025-11-21 08:09:47.357106', '2025-11-21 08:09:47.357106', '00008d13-0bba-4508-b679-1fdee2890c14', 'ام قرن', 502, NULL, NULL, NULL, NULL, '{uploads/fgn0l2hdct2tfp8kxudk}');
INSERT INTO public.posts VALUES ('469299cf-f9df-4b3b-a967-be56d38915de', 'السلام عليكم
للبيع ارض بروضة قديم مساحتها 1175متر
الفوت 360ريال', 2, 2, 19, false, 1, 'ارض', 4458000.00, 1, 1, 1157.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1753608109/uploads/tall0wbtbb2ha342h9v0.jpg}', '2025-07-27 09:21:50.44505', '2025-07-27 09:21:50.44505', 'f660dd0b-f66c-406a-a688-e30374396930', 'روضة قديم', 315, NULL, NULL, NULL, NULL, '{}');
INSERT INTO public.posts VALUES ('7c39bbfc-4a07-4fb4-87d5-0691d4666f4a', 'السلام عليكم للبيع ارض بالوعب مساحتها 2456متر 
علي الشارع العام للوعب 64متر
الارض علي 3شوارع مطلوب الفوت 540ريال قابل', 2, 2, 19, false, 1, 'ارض', 14275000.00, 1, 1, 2456.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1753606067/uploads/kdbwvxvxwfkn0e47seg2.jpg}', '2025-07-27 08:47:48.445892', '2025-07-27 08:47:48.445892', 'f660dd0b-f66c-406a-a688-e30374396930', 'الوعب', 343, NULL, NULL, NULL, NULL, '{}');
INSERT INTO public.posts VALUES ('ba716ca4-0864-44e0-8e6f-a23f8d923ac6', 'للبيع ارض  بالوكير 
على شارع رئيسي
قابل للفرز قطعتين
عليها بيت شعبي فاضي 
مساحه 1500 متر شارع أمامي وخلفي
 مقابل ازدان 21
عالشارع الرئيسي
مطلوب 4 مليون نهائي
الفوت 247
جوال 70401700 //
33833660', 5, 2, 19, false, 3, '', 4000000.00, NULL, NULL, 1500.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1756845154/uploads/qukwkbmetypqlponlteo.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1756845154/uploads/mhnpgeryhtzdrrvomhsk.jpg}', '2025-09-02 20:32:36.231695', '2025-09-02 20:32:36.231695', 'a7b77bb9-8519-4201-8034-527b17d21de3', 'الوكير مقابل ازدان 21', 602, NULL, NULL, NULL, NULL, '{uploads/qukwkbmetypqlponlteo,uploads/mhnpgeryhtzdrrvomhsk}');
INSERT INTO public.posts VALUES ('97c3b770-9fe5-4526-9ac8-c6783608e332', 'للبيع مباشر 

بيت شعبي قديم فاضي  ف الوكرة مساحة ٥٠٥ متر شارعين زاوية  موقع ممتاز
 مطلوب
 مليون و ٨٥٠ الف', 5, 2, 18, false, 3, 'الوكرة', 1850000.00, 5, 4, 505.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1755696801/uploads/q0xgloq6gdj8bjqt7bln.jpg}', '2025-08-20 13:33:23.285521', '2025-08-20 13:33:23.285521', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'الوكرة', 1091, NULL, NULL, NULL, NULL, '{uploads/q0xgloq6gdj8bjqt7bln}');
INSERT INTO public.posts VALUES ('402a6775-fdd1-4c91-b0ef-c751e3b5389c', 'للبيع عقار تجاري على شارع راس أبو عبود على شارعين زوية مساحة العقار 353متر يتكون العقار من 6 شقق كلها 5 غرف نوم 3 حمام وصاله مع وجود عدد خمسه محلات تجاريه اجمالى الايجار سبعين الف ريال شهري والدخل السنوي
 840000 ريال
ثمان مائه واربعين الف
', 1, 2, 20, false, 2, 'راس ابو عبود', 13000000.00, 10, NULL, 353.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1763816268/uploads/xvagvvzzh2nq9pbwbjqj.jpg}', '2025-11-22 12:57:49.545481', '2025-11-22 12:57:49.545481', '00008d13-0bba-4508-b679-1fdee2890c14', 'راس ابو عبود', 405, NULL, NULL, NULL, NULL, '{uploads/xvagvvzzh2nq9pbwbjqj}');
INSERT INTO public.posts VALUES ('9218f1da-73c7-4a52-9442-d74e00383f7d', 'فيــــلا مستعملة الخريطيات للبيع

 مساحه 650م على شارع وسكة
مؤجرة على شركة عقد جديد 3سنوات عوائل 
ب 15الف ريال 
عمر الفيلا ١٢ سنه
مطلــوب
 3.200.000', 1, 2, 18, false, 2, 'الخريطيات ', 3200000.00, 7, 5, 650.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1756527422/uploads/uevzghhpb82hb590uqcx.jpg}', '2025-08-30 04:17:03.134574', '2025-08-30 04:17:03.134574', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'الخريطيات ', 1123, NULL, NULL, NULL, NULL, '{uploads/uevzghhpb82hb590uqcx}');
INSERT INTO public.posts VALUES ('cc48e097-554c-4bf6-9ae6-bfe9c4893211', 'السلام عليكم
للبيع ارض بالوكير
مساحتها 600متر
علي شارع عام 40,متر', 5, 2, 19, false, 1, 'ارض', 1743000.00, 1, 1, 600.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1753608227/uploads/xgkcfvjo4wyyiwvmo0hx.jpg}', '2025-07-27 09:23:48.193023', '2025-07-27 09:23:48.193023', 'f660dd0b-f66c-406a-a688-e30374396930', 'الوكير', 304, NULL, NULL, NULL, NULL, '{}');
INSERT INTO public.posts VALUES ('ccd0b489-1009-4bb0-9d80-4f941009b42f', '
بيت شعبي للبيع
📍 الغرافة 

بالقرب من حديقة الغرافة موقع ممتاز 

📐 مساحته  683 متر زاوية على شارع وسكة

👈🏻مؤجر 22 الف باقي في العقد سنة 

5 عدادات كهرباء مفصولة
موقع 

مطلوب ٣٩٠٠٠٠٠


ا', 2, 2, 19, false, 3, 'الغرافه', 3900000.00, NULL, NULL, 683.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1768586732/uploads/u5rtyyf3qefblowzvs2z.jpg}', '2026-01-16 18:05:33.169217', '2026-01-16 18:05:33.169217', '00008d13-0bba-4508-b679-1fdee2890c14', 'الغرافه', 1149, NULL, NULL, NULL, NULL, '{uploads/u5rtyyf3qefblowzvs2z}');
INSERT INTO public.posts VALUES ('5e048df3-4d79-498f-ab61-bbb88ad36805', 'للايجار فيلا ارضية سيليه المعراض  
مساحة 925م على شارعين زاوية عبارة عن 6 غرف 
6 حمام يوجد غرفتين ماستر مطبخ خارجى 
غرفة وغرفة سائق مستقلة يوجد 
مجلس خارجى عبارة عن خيمة وحوش واسع 
الفيلا بالمكيفات 

مطلوب 16000 ريال 
تمشى ايجار شخصى او على الإسكان الحكومى
السعـر قـابل', 2, 1, 18, false, 2, 'المعراض', 16000.00, 6, 5, 925.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1756526435/uploads/a0dpwfvxbvdtct0dmph1.jpg}', '2025-08-30 04:00:36.438998', '2025-08-30 04:00:36.438998', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'السيلية ', 1438, NULL, NULL, NULL, NULL, '{uploads/a0dpwfvxbvdtct0dmph1}');
INSERT INTO public.posts VALUES ('be87438f-60b9-4341-aaeb-2133c3226071', '
للايجار

فيلا في ام قرن
مساحة البنيان 460 متر 
٨ غرف وصالة ومجلس داخلى وملحق خارجى. 

مطلوب ١٢  ألف ريال
', 1, 1, 18, false, 2, 'ام قرن', 12000.00, 6, 5, 460.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1763827002/uploads/sdvtighnxftf2ktaogvb.jpg}', '2025-11-22 15:56:42.91222', '2025-11-22 15:56:42.91222', '00008d13-0bba-4508-b679-1fdee2890c14', 'ام قرن', 953, NULL, NULL, NULL, NULL, '{uploads/sdvtighnxftf2ktaogvb}');
INSERT INTO public.posts VALUES ('4bfba044-5337-4642-aeb2-69ac2925ff71', 'من المالك 
للبيع بام عبيريه ثلاث اراضي  
مساحه كل قطعه 613 م شارع قار 
رخص وخرايط جاهزه
مطلوب ٢٥٥ ريال  للفوت', 3, 2, 19, false, 1, 'ام عبيرية', 1680000.00, NULL, NULL, 613.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1755700164/uploads/rvktsgvfxdfvhq6bujgp.jpg}', '2025-08-20 14:29:25.998239', '2025-08-20 14:29:25.998239', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'ام عبيرية', 847, NULL, NULL, NULL, NULL, '{uploads/rvktsgvfxdfvhq6bujgp}');
INSERT INTO public.posts VALUES ('d50f79cb-3ae4-47fe-abd8-109507d547c7', 'السلام عليكم
للبيع ارض بروضة الحمامة
مساحتها 1471متر
مطلوب الفوت 340ريال', 6, 2, 19, false, 1, 'ارض', 5385008.00, 1, 1, 1471.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1753606943/uploads/rfkdang8rnvgoozzs7an.jpg}', '2025-07-27 09:02:24.124306', '2025-07-27 09:02:24.124306', 'f660dd0b-f66c-406a-a688-e30374396930', 'روضة الحمامة', 201, NULL, NULL, NULL, NULL, '{}');
INSERT INTO public.posts VALUES ('4f236d89-6dd0-444c-8621-c27021da3844', 'ارض للبيع فى لجميليه
ارض قريبه من جميع الخدمات 
', 8, 2, 19, false, 3, 'لجميليه', 1425000.00, NULL, NULL, 873.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1766918213/uploads/lirfsaprrz1ula0dpy2d.jpg}', '2025-12-28 10:36:56.18708', '2025-12-28 10:36:56.18708', '00008d13-0bba-4508-b679-1fdee2890c14', 'لجميليه', 1142, NULL, NULL, NULL, NULL, '{uploads/lirfsaprrz1ula0dpy2d}');
INSERT INTO public.posts VALUES ('64c3043e-2169-4bda-8f27-9fbcd049109a', 'للبيع  
بيت شعبي في الخيسه 1204م 
علي شارعين زاوية منهم شارع عرض 40م وشارع عرض 16م ينفرز قطعتين 
مؤجر حاليا بقيمه ١٣.٥٠٠ شهريا بينتهي عقده شهر 10 القادم
واصل 5.100  
مطلوب 5.100.000 الف ريال نهائي 
شركه التوحيد للعقارات 
ترخيص / 387', 6, 2, 19, false, 3, 'بيت', 5100000.00, NULL, NULL, 1204.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1757891437/uploads/ytjr1osmrkcldwnwf19e.jpg}', '2025-09-14 23:10:38.423091', '2025-09-14 23:10:38.423091', '0b84d6dd-a098-4d39-a6e5-e1dc95b64c0c', 'الخيسه ', 793, NULL, NULL, NULL, NULL, '{uploads/ytjr1osmrkcldwnwf19e}');
INSERT INTO public.posts VALUES ('a53a2465-060f-436a-a123-8852437cab43', 'ارض في المشاف للبيع 

مساحة ٤٩٩م
علي شارع كبير
خدمي ٤٠م
 ارض تفتح علي شارع العام
مطلوب الفوت ٣١٠
للبيع مباشر 

ارض في المشاف
٤٩٩م
علي شارع كبير
خدمي ٤٠م
 ارض تفتح علي شارع العام
مطلوب الفوت ٣١٠
1665000', 5, 2, 19, false, 1, 'المشاف ', 1665000.00, NULL, NULL, 499.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1756527811/uploads/qx4xsoqqqp3twgs54di0.jpg}', '2025-08-30 04:23:32.781569', '2025-08-30 04:23:32.781569', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'المشاف ', 584, NULL, NULL, NULL, NULL, '{uploads/qx4xsoqqqp3twgs54di0}');
INSERT INTO public.posts VALUES ('d9cd05fb-4aa5-44cb-8fbf-90af6a9caec2', 'السلام علبكم
للبيع ارض بخليفة الجنوبية
مساحتها 603متر
', 1, 2, 19, false, 1, 'ارض', 2800000.00, 1, 1, 603.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1753608326/uploads/outkg2cmbfrzvfhx1ulo.jpg}', '2025-07-27 09:25:27.815329', '2025-07-27 09:25:27.815329', 'f660dd0b-f66c-406a-a688-e30374396930', 'خليفة الجنوبية', 481, NULL, NULL, NULL, NULL, '{}');
INSERT INTO public.posts VALUES ('14cabc01-e099-46a4-9e84-dd5e4d4c6ca4', 'للبيع ارض فى الوكره 
مقابل المستشفى ', 5, 2, 19, false, 1, 'الوكره ', 1650000.00, NULL, NULL, 509.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1770143868/uploads/lirhtrsj4g6mdqcvjrvm.jpg}', '2026-02-03 18:37:48.944361', '2026-02-03 18:37:48.944361', '00008d13-0bba-4508-b679-1fdee2890c14', 'الوكره ', 669, NULL, NULL, NULL, NULL, '{uploads/lirhtrsj4g6mdqcvjrvm}');
INSERT INTO public.posts VALUES ('6461adb7-6ed2-4065-ac5c-66444c43522b', 'للبيع بيت شعبي ف الدحيل موقع ممتاز
مساحه الارض / 1225م 
البيت حالته كويسه جدا يصلح للسكن 

مطلوب / 5.500.000
اللي عنده سعر جاد ببلغ بيه المالك 

شركه التوحيد للعقارات 
ترخيص / 387', 1, 2, 18, false, 2, 'بيت', 5500000.00, 5, 5, 1225.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1757891711/uploads/wm8nbn53lowrndeputjq.jpg}', '2025-09-14 23:15:12.539088', '2025-09-14 23:15:12.539088', '0b84d6dd-a098-4d39-a6e5-e1dc95b64c0c', 'الدحيل ', 1181, NULL, NULL, NULL, NULL, '{uploads/wm8nbn53lowrndeputjq}');
INSERT INTO public.posts VALUES ('c3f743bb-92f6-410c-a0cc-eced13f7b16e', 'للبيع آرض في فريج المره علي ثلاث شوارع خلف طريق سلوي موقع ممتاز جدا وتنفرز 4 قطع 
 مساحه الارض / 1997م
 مطلوب ف الفوت / 300 ريال

https://google.com/maps/search/?api=1&query=25.232950,51.437810', 1, 2, 19, false, 3, '10', 300.00, NULL, NULL, 1997.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1757431877/uploads/m91uliimhfxd9xroxbi4.jpg}', '2025-09-09 15:31:18.151807', '2025-09-09 15:31:18.151807', '0b84d6dd-a098-4d39-a6e5-e1dc95b64c0c', 'المره', 1250, NULL, NULL, NULL, NULL, '{uploads/m91uliimhfxd9xroxbi4}');
INSERT INTO public.posts VALUES ('189e2d33-0f78-4b2e-8f8b-2bd8ccb74a5e', 'للايجار فيلا في روضة الحمام على الشارع  العام  عبارة عن 
طابق أرضي :مجلس كبير مقلط وصالة وغرفتين ماستر

مطبخ داخلي  
 
طابق اول : 5 غرف  
 ماستر 
صالة كبيرة
بنت هاوس عبارة عن : 
مكون من ٤ غرف  ماستر 
ومطبخ تحضيري 
بسمنت عبارة عن مطبخ تحضيري وستور وحمام ومجلس كبير وغرفة طعام 
مصعد 
الفيلا بالمكيفات شهر مجانا 
مطلوب 22الف', 6, 1, 18, false, 2, 'روضه الحمامه', 22000.00, 8, 5, 1000.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1759842899/uploads/a17zsmkgewhz1lri1ssq.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1759842899/uploads/mltyih2yuehjqacuwhtv.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1759842898/uploads/nndi4ai02ylao2x2ytek.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1759842899/uploads/krhydqjnafm6kilrsy7q.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1759842898/uploads/jucwpe8g2p8sn53kvheq.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1759842898/uploads/bimg4dlbrzgovdsjhrxp.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1759842898/uploads/epemxsexdsfrwrjnluep.jpg}', '2025-10-07 13:15:00.363561', '2025-10-07 13:15:00.363561', '00008d13-0bba-4508-b679-1fdee2890c14', 'روضه الحمامه', 2545, NULL, NULL, NULL, NULL, '{uploads/jucwpe8g2p8sn53kvheq,uploads/a17zsmkgewhz1lri1ssq,uploads/bimg4dlbrzgovdsjhrxp,uploads/nndi4ai02ylao2x2ytek,uploads/krhydqjnafm6kilrsy7q,uploads/epemxsexdsfrwrjnluep,uploads/mltyih2yuehjqacuwhtv}');
INSERT INTO public.posts VALUES ('2b1af9bd-2ee9-453f-bce9-3ed3a569ab70', 'للبيع ارض عمارات في الدوحه الجديده على شارعين والمنطقه عليها ارتفاعات ارضي 7طابق مساحه 881 متر 
من المالك مباشر 
مطلوب 8.500.000
عليها مقترح من مكتب الاستشاري ٢١ شقه واذا عملت بيسمنت يصير ٢٤ شقه
قابل التفاوض', 1, 2, 19, false, 1, 'المجمع ', 850000.00, NULL, NULL, 881.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1765367093/uploads/akpdnkgjbucpl47caspn.jpg}', '2025-12-10 11:44:54.171802', '2025-12-10 11:44:54.171802', '18e15b48-2d06-47e9-b8ec-aa49ef39b847', 'الدوحة الجديده', 477, NULL, NULL, NULL, NULL, '{uploads/akpdnkgjbucpl47caspn}');
INSERT INTO public.posts VALUES ('084a8995-b0a2-4056-9959-366253c37a71', 'للبيع 
فيلا ازغوى 
مساحه 609م والبناء 700م 
شارعين امامى وخلفى 
واجهه حجر طبيعى من الجهتين 
الدور الارضى 
صالتين كبار وغرفه ماستر
مصعد كهربائى 
الدور الاول 
4 غرف ماستر وصاله 
البنت هاوس غرفتين ماستر وصاله 
مطبخ خارجى مع ملحق ماستر 
ومغسله 
ارضيات رخام 
جبس بورد بالكامل 
تكييف مركزى بالكامل 
يو بي في سي 
موقع ممتاز جدا 
تشطيب سوبر 
مطلوب 5 مليون 500 الف', 2, 2, 18, false, 1, 'ازغوى', 5500000.00, 6, 5, 610.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1766175219/uploads/yx2tumkpryx4hfse1zgz.jpg}', '2025-12-19 20:13:40.339061', '2025-12-19 20:13:40.339061', '00008d13-0bba-4508-b679-1fdee2890c14', 'ازغوى', 1024, NULL, NULL, NULL, NULL, '{uploads/yx2tumkpryx4hfse1zgz}');
INSERT INTO public.posts VALUES ('404c3210-b8b9-4580-ba9d-e5c2b3477403', '*للبيع *

 شقة في البرج المتعرج B ( للاجونا ). Zigzag*

 
المساحه: 165م
صافي المساحه:140م
*الطابق الثلاثه والثلاثون.
مفروشة بالكامل 
*عدد الغرف : ٢ ماستر كل غرفة مع حمام 
*صالة + حمام ضيوف. 
*مطبخ مجهز بكامل المعدات مغلق ومفصول عن الصاله. 
*مطلة على اللؤلؤه وفندق جراند حياة 
*الرسوم السنوية على صيانه البرج يتحملها  المالك
*الصيانه العاديه وجميع مصاريف الكهرباء والماء وقطر كول والانترنت واوريدو يتحملها المستأجر 

مؤجره عقد جديد/ الاجار الشهري ٧،٥٠٠ لمدة سنتين ابتدأ من شهر ٩ سنة ٢٠٢٥ م

*مطلوب  1,450,000 ريال*', 1, 2, 17, false, 2, 'الدوحه', 1500000.00, 2, 2, 165.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1762605254/uploads/ubn9diopax9tqmbtrxdu.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1762605252/uploads/ozy3rjelz4kl9jzfhwmh.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1762605252/uploads/bqr6xfpijjpwghmvhnwp.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1762605252/uploads/jbcojuudgawdaqivwmqv.jpg}', '2025-11-08 12:34:15.014479', '2025-11-08 12:34:15.014479', '00008d13-0bba-4508-b679-1fdee2890c14', 'الدوحه', 533, NULL, NULL, NULL, NULL, '{uploads/ozy3rjelz4kl9jzfhwmh,uploads/bqr6xfpijjpwghmvhnwp,uploads/jbcojuudgawdaqivwmqv,uploads/ubn9diopax9tqmbtrxdu}');
INSERT INTO public.posts VALUES ('2eededae-898f-40f8-a2bf-01379ef40863', '*للبيع من المالك بيت شعبى فى شعبية خليفة ٦٠٤ م على زاوية و مؤجر ب ٩ الاف مطلوب ٢.٣٠٠ مليون.*', 1, 2, 18, false, 2, 'شعبية خليفة ', 2300000.00, 6, 5, 604.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1758015860/uploads/cmr5cfikrrkdd4stopsm.jpg}', '2025-09-16 09:44:21.099388', '2025-09-16 09:44:21.099388', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'شعبية خليفة ', 1117, NULL, NULL, NULL, NULL, '{uploads/cmr5cfikrrkdd4stopsm}');
INSERT INTO public.posts VALUES ('576df839-08eb-447f-adff-a9d94c518193', '*للبيع*

*فيلا  ٤٧٩ متر بالخريطيات على شارعين زاوية موقع ممتاز*

*عبارة عن ٦ غرف وصالة ومجلس داخلى وملحق خارجى وحوش*

الدور الارضى 
غرفة وصالة ومجلس وغرفة طعام 

الدور الاول 
٤ غرف وصالة 

بنتهاوس غرفة ماستر 

ملحق خارجي: مطبخ وستور وغرفة خدم.


*مطلوب نهائى ٣.٥٠٠.٠٠٠ ريال*

أول ساكن اتمام البناء ٢٠٢٢ م', 3, 2, 18, false, 1, 'الخريطيات', 3500000.00, 7, 5, 480.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1758990462/uploads/ble6xiwvyodqkjteyei4.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1758990462/uploads/jm4ovnuiukiieihp7qk9.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1758990462/uploads/ahlnk58zub4g8qrpzsph.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1758990462/uploads/ta9q55o67feu0tqaerlf.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1758990462/uploads/svo9tl7zvbztvshnher0.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1758990462/uploads/ygalp0s9tk0odtmkcyhr.jpg}', '2025-09-27 16:27:44.253947', '2025-09-27 16:27:44.253947', '00008d13-0bba-4508-b679-1fdee2890c14', 'الخريطيات', 2130, NULL, NULL, NULL, NULL, '{uploads/ble6xiwvyodqkjteyei4,uploads/svo9tl7zvbztvshnher0,uploads/ta9q55o67feu0tqaerlf,uploads/ygalp0s9tk0odtmkcyhr,uploads/jm4ovnuiukiieihp7qk9,uploads/ahlnk58zub4g8qrpzsph}');
INSERT INTO public.posts VALUES ('fab5c16c-92f6-4b02-85a3-23f5ba529eea', 'للبيع اراضي فى مريخ مساحات 600م موقع وسعر ممتاز قريب من سباير
المأمون للوساطة العقارية ترخيص رقم 201 ', 2, 2, 19, false, 1, 'اراضى', 380.00, NULL, NULL, 600.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1765460626/uploads/wntrr7go4v86cf3wdxrb.jpg}', '2025-12-11 13:43:47.844726', '2025-12-11 13:43:47.844726', '8c35d390-0b62-47dc-934d-02201a4e4051', 'مريخ ', 477, NULL, NULL, NULL, NULL, '{uploads/wntrr7go4v86cf3wdxrb}');
INSERT INTO public.posts VALUES ('84bec0f2-9266-4a71-afc3-71c40aaea9e9', 'للايجار فيلا ارضية سيليه المعراض مساحة 
925م على شارعين زاوية عبارة عن 6 غرف 
6 حمام يوجد غرفتين ماستر مطبخ خارجى 
غرفة وغرفة سائق مستقلة يوجد 
مجلس خارجى عبارة عن خيمة وحوش واسع 
الفيلا بالمكيفات 

مطلوب 16000 ريال 
تمشى ايجار شخصى او على الإسكان الحكومى
السعـر قـابل', 1, 1, 18, true, 2, 'المعراض', 16000.00, 6, 3, 925.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1755806818/uploads/p2nj3bxuslyr7cnljgcb.jpg}', '2025-08-21 20:06:59.775848', '2025-08-21 20:06:59.775848', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'سيلية المعراض', 1257, NULL, NULL, NULL, NULL, '{uploads/p2nj3bxuslyr7cnljgcb}');
INSERT INTO public.posts VALUES ('348a4273-84cd-4ad5-b7dd-8bb8b6767d16', 'للبيع بيت شعبي بالوكرة منطقة كبار الموظفين ناحية الجبل موقع ممتاز ١٢٠٠ متر يصلح للفرز عليه رخصة هدم وتم ازالة عدادات الكهرباء والمياة', 5, 2, 19, false, 2, '', 3681000.00, NULL, NULL, 1200.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1758379871/uploads/yt5i64quzusdt7as4oy9.jpg}', '2025-09-20 14:51:12.299864', '2025-09-20 14:51:12.299864', '896876b6-f72e-4e03-8513-a29066826066', '', 758, NULL, NULL, NULL, NULL, '{uploads/yt5i64quzusdt7as4oy9}');
INSERT INTO public.posts VALUES ('ecc91751-1d48-4fcf-b278-94b7554dacaa', 'للبيع فيلا فى الخور تشطيب سوبر لوكس واجهه حجر 8 غرف ماستر وصالة ومجلس مفتوحين على بعض ومجلس خارجى وملحق ومصعد جاهزة للسكن على شارع عام
المأمون للوساطة العقارية ترخيص رقم 201
للتواصل
66141559 ', 4, 2, 18, false, 1, 'فيلا', 3200000.00, 8, 5, 490.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1769859255/uploads/k7wvt1svau1vlgsaxl3k.jpg}', '2026-01-31 11:34:16.658698', '2026-01-31 11:34:16.658698', '8c35d390-0b62-47dc-934d-02201a4e4051', 'الخور', 652, NULL, NULL, NULL, NULL, '{uploads/k7wvt1svau1vlgsaxl3k}');
INSERT INTO public.posts VALUES ('a359669a-f3a8-47f4-8188-e93e72c2f119', 'للبيع فيلا فى المشاف 7 غرف و 3 صالات وملحق عمرها 6 سنوات بحالة ممتازة فاضية
المأمون للوساطة العقارية ترخيص رقم 201 ', 5, 2, 18, false, 2, 'فيلا', 2700000.00, 7, 5, 500.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1765460769/uploads/lr6pgtkpe8nuxlemnntq.jpg}', '2025-12-11 13:46:10.713683', '2025-12-11 13:46:10.713683', '8c35d390-0b62-47dc-934d-02201a4e4051', 'المشاف ', 631, NULL, NULL, NULL, NULL, '{uploads/lr6pgtkpe8nuxlemnntq}');
INSERT INTO public.posts VALUES ('7f6dbb6f-d096-420a-af5d-d00bf0f45197', '1. ارض سكنيه في سميسمه بمساحة 1,218 م.م. (واجهة 25 متر وعمق 50 متر، على شارعين امامي وخلفي + سكه بالجانب ومسجد، تصلح للفرز).
السعر = 3,800,000 ر.ق. نهائي (290 ر.ق. للفوت).
وعموله الشركة
جوال 70401700', 6, 2, 19, false, 1, '', 3800000.00, NULL, NULL, 1218.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1756845298/uploads/ueolpyrccflnesot8yno.jpg}', '2025-09-02 20:34:59.321457', '2025-09-02 20:34:59.321457', 'a7b77bb9-8519-4201-8034-527b17d21de3', 'سميسمة', 862, NULL, NULL, NULL, NULL, '{uploads/ueolpyrccflnesot8yno}');
INSERT INTO public.posts VALUES ('bf9b368d-f4c9-4a31-8996-7c0eb61c5dcb', 'للبيع من المالك ارض بمعيذر الوكير مساحة ٩٦٠ متر ع شارعين زاوية مطلوب ٢ مليون و ٥٠٠ الف قابل شىء بسيط', 5, 2, 19, false, 1, 'معيذر الوكير ', 2500000.00, NULL, NULL, 960.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1758351047/uploads/ywflruu71g23pspg5jua.jpg}', '2025-09-20 06:50:48.099539', '2025-09-20 06:50:48.099539', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'الوكير', 581, NULL, NULL, NULL, NULL, '{uploads/ywflruu71g23pspg5jua}');
INSERT INTO public.posts VALUES ('61c29b45-3f5c-4e38-ab82-1f95732be148', 'السلام عليكم 
للبيع  من المالك مباشررررر فيلا بالمطار مساحة 431م 
مكونه من ٦ غرف وملاحق 
مؤجرة 9000ريال 
معمول ليها صيانه بالكامل 
مطلوب 2,400,000', 1, 2, 18, false, 2, 'المطار ', 2400000.00, 6, 5, 431.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1758955780/uploads/ohkczt3mlyer4emcxldz.jpg}', '2025-09-27 06:49:41.279824', '2025-09-27 06:49:41.279824', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'المطار', 2092, NULL, NULL, NULL, NULL, '{uploads/ohkczt3mlyer4emcxldz}');
INSERT INTO public.posts VALUES ('f4e8b359-30df-4600-b55a-20996e9b64e7', 'للبيع ارض فى ام العمد مساحة 616م على شارع موقع ممتاز
المأمون للوساطة العقارية ترخيص رقم 201 للتواصل
66141559 ', 3, 2, 19, false, 1, 'ارض', 1820000.00, NULL, NULL, 616.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1769859348/uploads/xfmvzsswrhugfseqljh7.jpg}', '2026-01-31 11:35:50.774442', '2026-01-31 11:35:50.774442', '8c35d390-0b62-47dc-934d-02201a4e4051', 'ام العمد ', 647, NULL, NULL, NULL, NULL, '{uploads/xfmvzsswrhugfseqljh7}');
INSERT INTO public.posts VALUES ('7f5a42d3-625a-4157-b675-40efafbedb43', 'من المالك 
للبيع فيلا في منطقة ام قرن  مساحة الفيلا الارض 500 م الواجهة حجر طبيعي تشطيب ممتاز 

تتكون الفيلا من :-   
الدور الأرضي : مجلس داخلي منفصل وصاله مع حمام ومغاسل  مفتوحين علي بعض 
غرفة  ماستر وغرفه طعام  
 
الدور الاول : 4 غرف ماستر وصالة 
البنت هاوس : 2  ماستر مع صالة كبيره 

الملحق الخارجي : مطبخ خارجي وغرفه ماستر وستور  

جديده الفيلا 
السعر 2850.000', 1, 2, 18, false, 1, 'ام قرن', 2850000.00, 7, 5, 500.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1757168890/uploads/kcuxiamhv128dyqta6mq.jpg}', '2025-09-06 14:28:10.93262', '2025-09-06 14:28:10.93262', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'ام قرن', 1679, NULL, NULL, NULL, NULL, '{uploads/kcuxiamhv128dyqta6mq}');
INSERT INTO public.posts VALUES ('758e4d2a-6cbd-4bcb-8a9f-0da30ec1ef19', '*للبيع من المالك*
*فيلا ام قرن  مساحة الأرض 500 م مساحة البناء 600 م* *تشطيب سوبر ديلوكس وجهات حجر طبيعى +اسقف جبس بورد* *شبابيك وأبواب يوبي في سي*
 .
*تتكون من:- 7 غرف ماستر*  3 *مطابخ بالفيلا داخلى وخارجي بالملحق ومطبخ بين الغرف 3* *صالات ومجلس داخل الفيلا*
*مجلس خارجى وغرفة سايق بباب _ خارجى منفصل اسانسير راكب*


*مطلوب 3 مليون 400 الف*', 6, 2, 18, false, 1, 'ام قرن', 3400000.00, 8, 5, 500.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1756649990/uploads/uwxduogfcxhhew2oqvss.jpg}', '2025-08-31 14:19:51.041982', '2025-08-31 14:19:51.041982', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'ام قرن', 1348, NULL, NULL, NULL, NULL, '{uploads/uwxduogfcxhhew2oqvss}');
INSERT INTO public.posts VALUES ('fe56a96c-de96-4da8-b398-23f243f96413', '*للبيع*

*ارض عمارات بالخور*
 افاده
 ( ارضي + ٣ طوابق + طابق سطح مع ( محل تجاري ).
المساحه ٥١٦ متر مربع 
شارع امامي وخلفي.

حاليا عليها فيلا دور ارضي 
 مساحه ٢١٤ متر .
* مؤجرة ب ٥٥٠٠ ( شيكات ) العقد ينتهي شهر ٨/ ٢٠٢٦ ..  قابل للتجديد.
*', 4, 2, 15, false, 3, 'الخور', 2900000.00, NULL, NULL, 516.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1771183454/uploads/d02tfplqz45i3xsffmui.jpg}', '2026-02-15 19:24:15.35986', '2026-02-15 19:24:15.35986', '00008d13-0bba-4508-b679-1fdee2890c14', 'الخور', 288, NULL, NULL, NULL, NULL, '{uploads/d02tfplqz45i3xsffmui}');
INSERT INTO public.posts VALUES ('1899713e-2b01-43b5-bf8d-b136d9f26059', 'للبيع عمارة جديدة في بن عمران 6 شقق وواستوديو شقتين غرفتين وصاله وحمامين ومطبخ و4 شقق غرفة وصالة وحمامين ومطبخ +استديو
المأمون للوساطة العقارية ترخيص رقم 201 ', 1, 2, 20, false, 1, 'عمارة', 4600000.00, 2, NULL, 241.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1765460880/uploads/hetxtokgeuwemfsp4jkn.jpg}', '2025-12-11 13:48:00.722919', '2025-12-11 13:48:00.722919', '8c35d390-0b62-47dc-934d-02201a4e4051', 'بن عمران', 840, NULL, NULL, NULL, NULL, '{uploads/hetxtokgeuwemfsp4jkn}');
INSERT INTO public.posts VALUES ('a5cb24ae-691d-4bc5-a812-e09dc1a91875', 'للبيع ارض فى ام العمد مساحة 750م على شارع موقع ممتاز
المأمون للوساطة العقارية ترخيص رقم 201 للتواصل
66141559 ', 3, 2, 19, false, 1, 'ارض', 2220000.00, NULL, NULL, 750.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1769859445/uploads/tszrgp7gnthnoyso02nc.jpg}', '2026-01-31 11:37:26.118913', '2026-01-31 11:37:26.118913', '8c35d390-0b62-47dc-934d-02201a4e4051', 'ام العمد ', 796, NULL, NULL, NULL, NULL, '{uploads/tszrgp7gnthnoyso02nc}');
INSERT INTO public.posts VALUES ('0233be76-41d1-4e50-9c95-f137cde8d18e', 'للبيع ارضين في منطقه اللقطه مساحه كل ارض 453م علي شارع وسكه 
موقع ممتاز بجوارها مدرسه 
ومقابلها مسجد 🕌 
قريب من المدينه التعليمه 
ومستشفي سدره 
', 1, 2, 19, false, 3, 'اللقطه ', 1900000.00, NULL, NULL, 453.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1771852001/uploads/dd6rfzbz6sdqgq3q48wc.jpg}', '2026-02-23 13:06:42.313112', '2026-02-23 13:06:42.313112', '00008d13-0bba-4508-b679-1fdee2890c14', 'اللقطه', 296, NULL, NULL, NULL, NULL, '{uploads/dd6rfzbz6sdqgq3q48wc}');
INSERT INTO public.posts VALUES ('41bb6eee-1701-437d-a9bd-a9db507121bb', 'للاستثمار بسعر ممتاز 
للبيع بيت شعبي في المره الغربيه قريب الشارع العام المساحه : 904 م 
فاضي حاليا ويوجد مستاجر 16 الف جاهز لتوقيع العقد 

السعر : 2,350,000', 1, 2, 18, false, 2, '', 235000.00, 9, 5, 904.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1765532374/uploads/xuj8nclfoxzqwf1zfuhz.jpg}', '2025-12-12 09:39:35.418503', '2025-12-12 09:39:35.418503', '18e15b48-2d06-47e9-b8ec-aa49ef39b847', '', 1004, NULL, NULL, NULL, NULL, '{uploads/xuj8nclfoxzqwf1zfuhz}');
INSERT INTO public.posts VALUES ('b441544f-e327-4888-9dc6-d2f7a121a7b8', 'للبيع من المالك
فيلا بالوكير جديده
مساحه الارض 720 م والبناء 780 م
واجهات حجر
مجلس خارجى
واصله كهرباء وماء وجاهزه للسكن
اسانسير
الدور الارضى؛
مجلس داخلى بالمغاسل + صاله كبيره + غرفه ماستر + مطبخ داخلى
الدور الاول :
صاله + 4 غرف ماستر + بانترى
البنت هاوس:
صاله + غرفتين ماستر + بانترى
الملاحق الخارجيه:
مطبخ خارجى+ غرفتين بحمام

مطلوب 4.500.000 ريال', 5, 2, 18, false, 1, 'الوكير ', 4500000.00, 8, 5, 720.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1758350832/uploads/ygdqcoe7npvwsuohcy09.jpg}', '2025-09-20 06:47:13.80536', '2025-09-20 06:47:13.80536', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'الوكير ', 713, NULL, NULL, NULL, NULL, '{uploads/ygdqcoe7npvwsuohcy09}');
INSERT INTO public.posts VALUES ('8d0307aa-70ee-412e-9b2b-8d9384c432ef', 'للإيجار محلات في فريج كليب قريبة من شارع المرخية التجاريه  ٩ + ٤ وحمام ومطبخ مشترك لجميع المحلات
الايجار ٨.٥٠٠ ريال 
مباشر بدون عموله 
', 1, 1, 16, true, 1, '', 8500.00, 1, 1, NULL, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1768424233/uploads/o6jpbtgcgup2drdahgro.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1768424233/uploads/rgn71lnmxzd9lyxiocvj.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1768424233/uploads/mv34ggqx0a0xpcgpclwi.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1768424233/uploads/da1cyci5gi7gwf1pfqzy.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1768424233/uploads/koolurybd7nvsmz3fyu0.jpg}', '2026-01-14 20:57:14.720606', '2026-01-14 20:57:14.720606', '801ae98c-66a3-40b6-a34b-9192d248636f', '', 1209, NULL, NULL, NULL, NULL, '{uploads/o6jpbtgcgup2drdahgro,uploads/mv34ggqx0a0xpcgpclwi,uploads/koolurybd7nvsmz3fyu0,uploads/da1cyci5gi7gwf1pfqzy,uploads/rgn71lnmxzd9lyxiocvj}');
INSERT INTO public.posts VALUES ('576b0623-4c18-48c6-8dd7-d712aa5f3e3b', 'للبيع ثلاث فيلل للبيع  في معيذر خلف الفروسيه مساحه كل فيلا الفيلا الارض 440 م والبناء 560م تشطيب راقي واجهه حجر طبيعي جبس بالكامل بها مجلس خارجي وغرفه للسائق جديده تتكون الفيلا من :-الدور الارضى : مجلس  خارجي وغرفه للسائق ومجلس داخلى وصاله كبيره مفتوحين علي بعض وغرفه ماستر وغرفه طعام الدور الاول : 4 غرف ماستر وصاله كبيره البنت هاوس :- غرفتين ماستر وصاله كبيره الملحق الخارجي :- مطبخ خارجى وغرفه ماستر ومغسله وستور تشطيب راقي وخاص بها مجلس خارجي وغرفه للسائق موقع ممتاز خلف الفروسيه مطلوب 3 مليون و250

شركه التوحيد للعقارات 
ترخيص / 387', 2, 2, 18, false, 1, 'فيلا', 3250000.00, 7, 5, NULL, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1757891362/uploads/kcrsrm4khkn12se8qkxe.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1757891362/uploads/vb4dequhjuuysk4zodia.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1757891362/uploads/jpi68hwco7f2bdholmya.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1757891362/uploads/qynh6opevqfja27pjytk.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1757891362/uploads/h2njbp2oxqlwbgv0arfi.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1757891362/uploads/ksvofpbdpigemmyuq4xd.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1757891362/uploads/fnua0bb5jnnajpbmqlfl.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1757891362/uploads/cwlmfdsd5hceg4ix0jly.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1757891363/uploads/uu6q0p88wmo2qqms2mdt.jpg}', '2025-09-14 23:09:24.986646', '2025-09-14 23:09:24.986646', '0b84d6dd-a098-4d39-a6e5-e1dc95b64c0c', 'معيذر ', 961, NULL, NULL, NULL, NULL, '{uploads/kcrsrm4khkn12se8qkxe,uploads/ksvofpbdpigemmyuq4xd,uploads/vb4dequhjuuysk4zodia,uploads/fnua0bb5jnnajpbmqlfl,uploads/qynh6opevqfja27pjytk,uploads/jpi68hwco7f2bdholmya,uploads/cwlmfdsd5hceg4ix0jly,uploads/h2njbp2oxqlwbgv0arfi,uploads/uu6q0p88wmo2qqms2mdt}');
INSERT INTO public.posts VALUES ('ed52c449-444f-455e-a239-73a89b05ca5e', 'للبيع 
فيلا بالريان مساحه 442 م 
مؤجره ( 22700 ريال )
موقعها ممتاز جدا
عمرها 8 سنوات
مقسمه 6 شقق نظاميه على عوائل 
كل شقه شيكاتها بروحها
الكهرباء والماء على المالك
مطلوب 2.800.000 ريال', 2, 2, 18, false, 2, 'الريان ', 2800000.00, 7, 5, 442.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1758995527/uploads/ejghg8uuwuqycfymbueh.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1758995527/uploads/otwkge54lycaqslcmsks.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1758995527/uploads/uozucjltgckwhosboafs.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1758995527/uploads/bavbk7qoabji5zt0hhwl.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1758995527/uploads/iniaz0bf5vcoojityynf.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1758995527/uploads/xyfuemnd0knmo8k354lh.jpg}', '2025-09-27 17:52:08.59625', '2025-09-27 17:52:08.59625', '00008d13-0bba-4508-b679-1fdee2890c14', 'الريان', 2197, NULL, NULL, NULL, NULL, '{uploads/otwkge54lycaqslcmsks,uploads/ejghg8uuwuqycfymbueh,uploads/bavbk7qoabji5zt0hhwl,uploads/iniaz0bf5vcoojityynf,uploads/uozucjltgckwhosboafs,uploads/xyfuemnd0knmo8k354lh}');
INSERT INTO public.posts VALUES ('2e8af654-fada-4522-b894-c5c16c564164', 'للبيع فيلا حلوة وواسعة ومجدده بالكامل في السيليه مموقع مميز مساحة 1320 م اتمام البناء 2010
11غرفه 9 حمامات 4 صالات داخلى وخارجي ومجلس خارجي ومقلط وغرفة دريول ومطبخ واستور خارجي وعدد 2 مطبخ رئيسي و2مطبخ تحضيري وملحقين  وحديقة في الحوش وطبيلات الفله 
كان المالك ساكن فيها جاهزه للسكن ماتحتاج صيانه
مطلوب للبيع 4 مليون و 200 الف', 1, 1, 18, false, 2, '', 4000000.00, 10, 5, 1320.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1753605825/uploads/fyqitnd8gjhdcdnfsusv.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1753605825/uploads/ohibrlrs4cs8mhye7qje.jpg}', '2025-07-27 08:43:46.646514', '2025-07-27 08:43:46.646514', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'المعراض ', 775, NULL, NULL, NULL, NULL, '{}');
INSERT INTO public.posts VALUES ('1d67d7de-9346-4be7-8149-935de681ea40', 'للبيع فيلا ازغوى
مساحه  645م الارض 
البناء 700م 

الدور الارضى 
مجلس خارجى وغرفه سائق 
مجلس داخلى كبير وصاله كبيره 
غرفه ماستر 
الدور الاول 
4 غرف ماستر وصاله 

البنت هاوس 
غرفتين ماستر وصاله 

تكييف مركزى 
مصعد 
ارضيات رخام 
وجهات حجر 
جبس بورد كامله 
تشطيب سوبر ديلوكس 

موقع ممتاز جدا 
مقابل المسجد
قريب الميره
درايش يو بي في سي 
غرفه سائق 

تشطيب راقى جدا وخاص 
واصله كهرماء ومكيفات 

مطلوب 5 مليون 600 الف


تواصل معنا 
محمد خاطر 
50067840
مرسانا للوساطة العقاريه 
ترخيص وزاره العدل رقم ', 2, 2, 18, false, 1, 'فيلا سكنيه ', 5600000.00, 7, 5, 645.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1762118991/uploads/cp7adz6iqg31jean4cta.jpg}', '2025-11-02 21:29:52.896351', '2025-11-02 21:29:52.896351', 'c0461100-60ce-404a-86a6-86610b5c2f89', 'ازغوى', 329, NULL, NULL, NULL, NULL, '{uploads/cp7adz6iqg31jean4cta}');
INSERT INTO public.posts VALUES ('1b940a3d-a9b8-4baa-b2a8-69c52e92cfd8', 'للبيع من المالك

فيلا بالوكير جديده
على شارعين زاويه
مساحه الارض 758 م والبناء 900 م
واجهات حجر
مجلس خارجى
اسانسير
غرفه سائق
الدور الارضى:
مجلس داخلى وصاله مفتوحين فى بعض + غرفتين ماستر + مطبخ داخلى
الدور الاول:
صاله كبيره + 4 غرف ماستر 
البنت هاوس:
صاله + غرفتين ماستر + غرفه غسيل واستور

الملاحق الخارجيه:
مطبخ خارجى + غرفه بحمام

مطلول 5.200.000 ريال', 5, 2, 18, false, 1, 'الوكير ', 5200000.00, 9, 5, 758.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1758351195/uploads/dioktkh8cgaqv5rofvpl.jpg}', '2025-09-20 06:53:16.8039', '2025-09-20 06:53:16.8039', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'الوكير ', 715, NULL, NULL, NULL, NULL, '{uploads/dioktkh8cgaqv5rofvpl}');
INSERT INTO public.posts VALUES ('aea23fbd-0e96-4b7d-b052-62650d7724f6', 'من المالك 
للبيع فيلا فاخرة بام قرن 
مساحة الارض ٤٢٠ متر مربع مساحة البناء ٤٣٥ متر مربع
موقع مميز بالقرب من الطريق الساحلي

مجلس خارجي منفصل 
الطابق الأرضي: مجلس داخلي مع غرفة طعام + صالة + غرفة ماستر
الطابق الثاني: ٤ غرف ماستر وصاله
البنت هاوس: غرفتين ماستر واستور وصاله 
الملحق الخلفي: مطبخ خارجي، وغرفة غسيل، وغرفة للخادمة،
مجلس خارجي منفصل 
موقف سيارة ياخذ ٣سيارات
تشطيب مميز ، جبس بورد 
يوبي في سي
مطلوب
٢.٩٠٠مليون', 6, 2, 18, false, 1, 'ام قرن', 2900000.00, 7, 5, 420.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1758199073/uploads/rjnjvdngbfleze8koece.jpg}', '2025-09-18 12:37:54.085112', '2025-09-18 12:37:54.085112', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'ام قرن', 1032, NULL, NULL, NULL, NULL, '{uploads/rjnjvdngbfleze8koece}');
INSERT INTO public.posts VALUES ('9116b2c7-1d47-49d3-9b05-ea7a20e3e17c', 'فيلا للبيع في الصخامة ممتازه
مساحة الارض 565
مساحة البناء 701 
الدور الارضي: صالة و مجلس مفتوحين على بعض مع مغاسل و حمام ومطبخ داخلي وغرفة طعام+ غرفة نوم ماستر
الدور الأول: صالة + 4 غرف نوم ماستر مع غرف الملابس
بنت هاوس: صالة + غرفتين نوم ماستر
الملحق: غرفة وحمام و مطبخ خارجي و غرفة الغسيل
غرفة للسايق مع حمامها
مجلس خارجي مع مغاسل وحمام
مصعد
تشطيب راقى  
السعر 4.200.000 ريال قطري', 6, 2, 18, false, 1, 'الصخامه', 4200000.00, 8, 5, 565.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1772100441/uploads/rzl5kduguahfcq4j62bt.jpg}', '2026-02-26 10:07:22.962482', '2026-02-26 10:07:22.962482', '00008d13-0bba-4508-b679-1fdee2890c14', 'الصخامه', 268, NULL, NULL, NULL, NULL, '{uploads/rzl5kduguahfcq4j62bt}');
INSERT INTO public.posts VALUES ('878096d3-f73e-4f3e-89a8-56f4d1540ba5', 'للبيع ارض للبيع ارض في الذخيره 1616 م 
علي ثلاث شوارع وسكه يجوز فرزها حسب المالك الى ثلاث قطع ', 4, 2, 19, false, 3, 'الذخيره', 3565000.00, NULL, NULL, 1616.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1762878038/uploads/wjz8mfmcbglvrhlirhrb.jpg}', '2025-11-11 16:20:38.959587', '2025-11-11 16:20:38.959587', '00008d13-0bba-4508-b679-1fdee2890c14', 'الذخيره', 452, NULL, NULL, NULL, NULL, '{uploads/wjz8mfmcbglvrhlirhrb}');
INSERT INTO public.posts VALUES ('713612a3-9e01-449a-95a3-7dbf56c70f5a', 'للبيع من المالك 

فيلا فى الوكير  
مساحة الارض  516  متر 
مساحه البناء   550   متر 
تتكون من :- 
الدور الارضي : 
مجلس داخلي وصاله مفتوحين  
وغرفه ماستر  ومطبخ داخلي 
الدور الاول :
٤ غرف ماستر وصاله 
البنت هاوس : 
٢  غرفة  ماستر 
الملحق:
غرفة خادمه + مطبخ خارجى  +مغسلة

مطلوب  :  3.100.000  ريال', 5, 2, 18, false, 1, 'الوكير ', 3100000.00, 8, 5, 516.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1758351347/uploads/utljwlyxnklycicms7pn.jpg}', '2025-09-20 06:55:48.76236', '2025-09-20 06:55:48.76236', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'الوكير ', 824, NULL, NULL, NULL, NULL, '{uploads/utljwlyxnklycicms7pn}');
INSERT INTO public.posts VALUES ('8532c9d1-5461-4212-9e6d-9db189291f85', 'فيلا للبيع الصخامه 
مساحه  619م 
شارعين  زاويه 
تشطيب سوبر 
ارضيات رخام 
جبس بورد 

تتكون من :- 
الدور الارضى: 
مجلس داخلى وصاله وغرفه ماستر 
الدور الاول : 
4 غرف ماستر وصاله 
البنت هاوس :غرفه ماستر 
ملحق خارجي : 
مطبخ خارجى وغرفه ماستر 
مجلس خارجى 
واجهه حجر طبيعى ارضيات رخام 
جبس بورد كامل الفيلا 
موقع ممتاز جدا

مطلوب   
3 مليون 800 الف

تواصل معنا 
محمد خاطر 
50067840
مرسانا للوساطة العقاريه 
ترخيص وزاره العدل رقم 54
', 6, 2, 18, false, 1, 'فيلا سكنيه ', 3800000.00, 6, 5, 619.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1762119374/uploads/mztejrzgabihwuvm1fb9.jpg}', '2025-11-02 21:36:15.935057', '2025-11-02 21:36:15.935057', 'c0461100-60ce-404a-86a6-86610b5c2f89', 'الصخامه ', 383, NULL, NULL, NULL, NULL, '{uploads/mztejrzgabihwuvm1fb9}');
INSERT INTO public.posts VALUES ('b077aa5a-0259-4e57-9fd3-bd7e18b20fa5', ' 

السلام عليكم 
للبيع بيت شعبي في الناصريه 
مساحه 1200م(ينفرز)
شارعين امامي وخلفي 
شارع 16م وشارع 24م
موقع ممتاز مقابل (مركز صحي الغرافه)
المالك ساكن فيه 
مطلوب 5,200,000', 2, 2, 19, false, 3, 'الغرافه', 5200000.00, NULL, NULL, 1200.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1762879996/uploads/bpbipry9pm54jamwifvg.jpg}', '2025-11-11 16:53:17.652924', '2025-11-11 16:53:17.652924', '00008d13-0bba-4508-b679-1fdee2890c14', 'الغرافه ', 377, NULL, NULL, NULL, NULL, '{uploads/bpbipry9pm54jamwifvg}');
INSERT INTO public.posts VALUES ('49d6444b-e3c7-493a-bdef-d248f6e67d7f', '*السلام عليكم للبيع أرض الوعب ٩١٩ م 
على شارعين أمامى وخلفى 
منهم شارع رئيسي ٣٢ م  
وسكة موقع ممتاز 
قريب سباير 
مطلوب ٥ مليون*', 1, 2, 19, false, 1, 'الوعب ', 5000000.00, NULL, NULL, 919.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1762244765/uploads/djtbp2s50rgherfprban.jpg}', '2025-11-04 08:26:05.956801', '2025-11-04 08:26:05.956801', '00008d13-0bba-4508-b679-1fdee2890c14', 'الوعب ', 298, NULL, NULL, NULL, NULL, '{uploads/djtbp2s50rgherfprban}');
INSERT INTO public.posts VALUES ('77dee17f-ca12-47df-80da-d3d5ccd6aebf', 'بيت ارضى على شارعين زاويه 
فى مريخ موقع ممتاز 
مقابل مسجد 
مجدد بالكامل ', 2, 2, 19, false, 3, 'مريخ ', 2600000.00, NULL, NULL, 550.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1773009538/uploads/i0vnrcckzs7kcunxx76f.jpg}', '2026-03-08 22:38:59.50925', '2026-03-08 22:38:59.50925', '00008d13-0bba-4508-b679-1fdee2890c14', 'مريخ ', 340, NULL, NULL, NULL, NULL, '{uploads/i0vnrcckzs7kcunxx76f}');
INSERT INTO public.posts VALUES ('c082624b-3cc1-470a-9a5f-21c8476b6fdd', 'فيلا مستقلة بالغرافة  ٦ غرف و ٧ حمامات و مجلس داخلى و صالتين و حوش امامى و مجلس داخلى', 1, 2, 18, true, 2, '', 15000.00, 6, 5, 45050.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1752686321/uploads/oywzjkxc5ws0cq23ntgx.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1752686321/uploads/utrinihhwmihzujlly3o.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1752686321/uploads/rs0sbrrtrgo8xur9etxt.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1752686321/uploads/cglukbuyfxrtnxuukfv7.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1752686320/uploads/cw5qv1sbzeubymynnqdu.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1752686320/uploads/p0tz8l45xaquverklat3.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1752686320/uploads/p30ea816p1enaueq0tpf.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1752686320/uploads/qtzxp0mraehta6iajgho.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1752686320/uploads/c8v9d7b3yp48jkymznje.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1752686320/uploads/bvpiegilnhmpqsnnhzms.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1752686320/uploads/cw19ckfcvdhlafjtwffm.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1752686320/uploads/oc7mgw0p0fp2lpw3nobh.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1752686320/uploads/gqssboewjihpcdb6hvqh.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1752686321/uploads/u7ubso3o2jzec25kawgt.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1752686320/uploads/geh31cb0y8lpegi7vdcb.jpg}', '2025-07-16 17:18:43.262722', '2025-07-16 17:18:43.262722', '479690a3-da25-4188-bf72-eade4825f30c', '', 817, NULL, NULL, NULL, NULL, '{}');
INSERT INTO public.posts VALUES ('614ea843-7165-4c42-87a3-ee873d26b15e', ' 
للبيع عماره مميزه فى السد جديده العماره مساحة الارض 350 م ارضى و5 طوابق 
تتكون من 10 شقه وستديو 
كل شقة بها 2 غرف نوم و2 حمام وصالة ومطبخ 
مفروشه الفرش جديد 
المالك مقدم علي ترخيص شقق فندقه بتاخذ ترخيص شقق فندقيه 

مطلوب 9 مليون و500 الف', 1, 2, 20, false, 1, 'السد ', 9500000.00, 10, NULL, 350.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1762782157/uploads/k0t4n2qtexriffo1mijb.jpg}', '2025-11-10 13:42:38.953136', '2025-11-10 13:42:38.953136', '00008d13-0bba-4508-b679-1fdee2890c14', 'السد ', 655, NULL, NULL, NULL, NULL, '{uploads/k0t4n2qtexriffo1mijb}');
INSERT INTO public.posts VALUES ('9b93b91f-e8ef-49bb-bae0-c4b2f889c6cd', '*للبيع*
مؤجره شيك واحد
عماره في المنصوره 35 شقة
 مساحه ٩٠٦ متر على شارعين.

*عبارة عن*
( بسمنت + ارضي + 7 ادوار طوابق متكرره).
 القبو والطابق الارضي عباره عن مواقف للسيارات بعدد 40 موقف.
 والطوابق من الاول الى السابع يحتوي كل طابق على عدد 5 شقق.
 *وكل شقه عباره عن غرفتين نوم وصاله ومطبخ وحمامين*

 *مؤجره على شركه شيك واحد           يقدر المدخول الشهري للبنايه ب 160,000 الف شهريا*   

     
*عقد جديد مدته 4 سنوات*                         
بدأ من شهر ٨  / ٢٠٢٥ 

*مطلوب ٢٣ مليون ريال*', 1, 2, 20, false, 2, 'المنصوره', 23000000.00, 10, NULL, 906.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1765820637/uploads/rdjekxkx3fegv6k2dbau.jpg}', '2025-12-15 17:43:59.240063', '2025-12-15 17:43:59.240063', '00008d13-0bba-4508-b679-1fdee2890c14', 'المنصوره', 849, NULL, NULL, NULL, NULL, '{uploads/rdjekxkx3fegv6k2dbau}');
INSERT INTO public.posts VALUES ('710ffe32-a096-4f2e-b412-27da4a2e0647', 'للبيع 

عمارة  في المطار القديم  مساحه 505 م
 .قريب من الشارع الرئيسي وشارع المطار التجاري

مفروشة بالكامل 
مؤجرة بعقد  وبشيك واحد مع شركة 
من 2024/6/15 إلى 2027/6/15 
ولمدة 3 سنوات 
ب مبلغ  ( 48000 شهريا  )
تتكون العماره من :
10 شقق كل شقة من 2 نوم 2 حمام وصالة ومطبخ وغرفة حارس مع الحمام

مطلوب : 8,300,000

', 1, 2, 20, false, 2, 'المطار القديم', 8300000.00, 10, NULL, 505.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1762272126/uploads/m86rgk8uqewww0xosmrv.jpg}', '2025-11-04 16:02:08.25755', '2025-11-04 16:02:08.25755', '00008d13-0bba-4508-b679-1fdee2890c14', 'المطار القديم ', 464, NULL, NULL, NULL, NULL, '{uploads/m86rgk8uqewww0xosmrv}');
INSERT INTO public.posts VALUES ('9cb9d33a-bb13-4ea3-b549-1e22d4a1c405', 'للبيع بيت الخريطيات 960 م 

علي شارعين امامي وخلفي 

موقع ممتاز جدا

منهم شارع عام  

مقابل المسجد 

البيت مؤجر علي عائله 9000 الاف

بسعر الارض الفوت 377

مطلوب 3.900.000', 3, 2, 19, false, 3, 'الخريطيات', 3900000.00, NULL, NULL, 960.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1762880463/uploads/lg51axmwogt74wwxoawr.jpg}', '2025-11-11 17:01:04.553109', '2025-11-11 17:01:04.553109', '00008d13-0bba-4508-b679-1fdee2890c14', 'الخريطيات', 401, NULL, NULL, NULL, NULL, '{uploads/lg51axmwogt74wwxoawr}');
INSERT INTO public.posts VALUES ('04b624c2-6033-44f9-a6eb-66b36ab2ed15', 'للبيع مباشر 
فيلا في  الوكرة مساحة ٥٨٤ متر
شارعين زاوية  تتكون من :-
مجلس خارجي مع حمام 
الدور الارضي :-
صالتين فاتحين على بعض مع حمام 
وغرفة ماستر  + غرفه بدون حمام
الدور الاول :- 
٤ غرف  ٣ غرف حمام مشترك 
وغرفة ماستر 
البنت هاوس :- 
غرفتين ماستر +  صاله صغيرة 
الملحق :- 
مطبخ خارجي
مطلوب :  ٢.٥٠٠.٠٠٠  الف ريال', 5, 1, 18, false, 3, 'الوكرة', 2500000.00, 8, 5, 584.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1756312125/uploads/xjdynpsq44messa1ozbc.jpg}', '2025-08-27 16:28:46.675038', '2025-08-27 16:28:46.675038', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'الوكرة ', 1361, NULL, NULL, NULL, NULL, '{uploads/xjdynpsq44messa1ozbc}');
INSERT INTO public.posts VALUES ('c87c3189-354c-426b-87eb-ae2dabc2d11b', 'للبيع مباشر
فيلا راقية للبيع في الخيسة
المساحة:507 م² | مساحة البناء: 588 م²
الواجهة حجر بالكامل
تشطيب سوبر ديلوكس
بها مجلس خارجي مستقل
حديقة صغيرة في الحوش خلفي
غرفة سائق مع حمام 
 الدور الأرضي 
صالة كبيرة وعدد 2 غرفة ماستر
ومطبخ رئيسي مجهز
وملحق خارجي (مطبخ إضافي + غرفة بحمام + مخزن)
 الدور الأول:
 4 غرف ماستر وصالة كبيرة
 بنت هاوس:
 غرفتين ماستر
ومطبخ
 السعر: 4,300,000 ريال', 6, 2, 18, false, 1, 'الخيسة ', 4300000.00, 8, 5, 507.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1756903195/uploads/whouqt2qtxiptacawrik.jpg}', '2025-09-03 12:39:56.907375', '2025-09-03 12:39:56.907375', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'الخيسة ', 1536, NULL, NULL, NULL, NULL, '{uploads/whouqt2qtxiptacawrik}');
INSERT INTO public.posts VALUES ('1ccc2170-9add-487f-95a7-de3f38c159da', 'ارض فى المشاف 
قابل للفرز 
موقع ممتاز جدا ', 5, 2, 19, false, 3, 'المشاف', 3100000.00, NULL, NULL, 1190.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1773777006/uploads/cp7heudmrvplefpp39hw.jpg}', '2026-03-17 19:50:08.143331', '2026-03-17 19:50:08.143331', '00008d13-0bba-4508-b679-1fdee2890c14', 'المشاف', 270, NULL, NULL, NULL, NULL, '{uploads/cp7heudmrvplefpp39hw}');
INSERT INTO public.posts VALUES ('86157917-6091-4b5e-a957-b291cd97341d', 'للايجار بالمشاف مقابل وقود المشاف 
فيلا بوجهه حجر 
الفيلا مكونه من مجلس مفصول عن الصاله 
وصاله بالدور الارضي 
غرفه  نوم ومطبخ 
والدور العلوي ٤ غرف ماستر مع صاله 
بنت هاوس غرفه بحمام 
وملحق خارجي غرفه وحمام ومطبخ 
مطلوب ١٣ الف اسكان حكومي', 5, 1, 18, false, 2, '', 13000.00, 7, 5, 500.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1751110955/r69td3psfcszjtsmojjy.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1751110955/bhko5wckrrdxyrkaawiv.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1751110955/bspmhc0h8mpdzn0qr7ud.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1751110955/qos0n29yl9tntht1gns2.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1751110955/ciet1ghrae68ofacao5o.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1751110955/o6tpxknq51qmw4hzlhfx.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1751110955/jlk0dbtwwzaicqrldrta.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1751110955/zpvocluak0eemqpwvz62.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1751110955/uo7ot3wwsynxl9fbotlb.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1751110955/ugz8ej6qd3o0hw61xzkz.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1751110955/l7uhq98qqlnp0nziileu.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1751110955/gnh4yhlkeqjx2evkda72.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1751110955/vteinuadspr5gd2kuxu1.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1751110955/ap4rxnwkv1xhewzcqkhc.jpg}', '2025-06-28 11:42:36.667563', '2025-06-28 11:42:36.667563', '479690a3-da25-4188-bf72-eade4825f30c', '', 821, NULL, NULL, NULL, NULL, '{}');
INSERT INTO public.posts VALUES ('a027543b-16e4-44c5-bb39-1d3689a2cabe', '*للبيع *

عمارة بالدوحة الجديدة 
٩ شقق
 [ غرفة وصالة وحمام ومطبخ]
مؤجرة ب ٢٧ ألف ريال 
بحالة ممتازة ومرتبة ونظيفة
مدخل رخام 
عقود وشيكات ٩ عوائل 

*مطلوب ٥ مليون*', 1, 2, 20, false, 2, 'الدوحه الجديده', 5000000.00, 9, NULL, 303.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1762707796/uploads/gga45nyzal5f9dt5e6lj.jpg}', '2025-11-09 17:03:17.575624', '2025-11-09 17:03:17.575624', '00008d13-0bba-4508-b679-1fdee2890c14', 'الدوحه الجديده', 649, NULL, NULL, NULL, NULL, '{uploads/gga45nyzal5f9dt5e6lj}');
INSERT INTO public.posts VALUES ('2ee8d467-86fd-4f70-99c7-5e3d4366b772', 'للايجار فلتين خدمى 
على الشارع العام بالمرخية
٦غرف وريسبشن وصالات
وملحق ومطبخ داخلى
موقع ممتاز 
مطلوب بالفيلا 20 الف', 1, 1, 14, false, 2, 'المرخيه', 20000.00, 6, 5, 0.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1762881082/uploads/veslmn5hbgjqqtidmxpt.jpg}', '2025-11-11 17:11:24.732811', '2025-11-11 17:11:24.732811', '00008d13-0bba-4508-b679-1fdee2890c14', 'حزم المرخيه', 923, NULL, NULL, NULL, NULL, '{uploads/veslmn5hbgjqqtidmxpt}');
INSERT INTO public.posts VALUES ('68847e6c-afb0-4166-b46b-345e65238f4c', '1 bedroom for sale with flexible payment plan for 7 years near boulevard, facind lusail stadium, above commercial mall with luxary facilities 
pool, gym, spa, garden

غرفة و صالة للبيع بأقساط مريحة لمدة ٧ سنين في مشروع جديد
جنب البلفارد، مقابل الاستاد ،  فوق مول تجاري مع جميع النشاطات الترفيهية من حمام سباحة، صالة جيم، سبا، حديقة.', 6, 2, 17, false, 1, 'City avenue', 1150000.00, 1, 2, 90.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1758715337/uploads/jowspmglvcgkg4igs1qq.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1758715337/uploads/fkhfyuv9qtn0vjizrdjo.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1758715337/uploads/xistfxgqaphavyuyucfe.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1758715337/uploads/u08v9r8jlurhefeunuil.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1758715337/uploads/rfofogc8wfluz2xai5mt.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1758715337/uploads/uoh0po8nucsf5pfghulo.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1758715337/uploads/qr0v8mnpizhszevjk9du.jpg}', '2025-09-24 12:02:18.708848', '2025-09-24 12:02:18.708848', 'a6ac6c51-f18d-4d5b-ad55-bc621162dd65', 'lusail', 1612, NULL, NULL, NULL, NULL, '{uploads/uoh0po8nucsf5pfghulo,uploads/u08v9r8jlurhefeunuil,uploads/fkhfyuv9qtn0vjizrdjo,uploads/rfofogc8wfluz2xai5mt,uploads/xistfxgqaphavyuyucfe,uploads/jowspmglvcgkg4igs1qq,uploads/qr0v8mnpizhszevjk9du}');
INSERT INTO public.posts VALUES ('a00a1714-65ae-444a-976a-d5493cc26fa6', 'السلام عليكم 
للبيع بيت شعبي في الناصريه 
مساحه 1200م(ينفرز)
شارعين امامي وخلفي 
شارع 16م وشارع 24م
موقع ممتاز مقابل (مركز صحي الغرافه)
المالك ساكن فيه 
مطلوب 5,200,000', 1, 2, 19, false, 3, 'الغرافه', 5200000.00, NULL, NULL, 1200.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1762799414/uploads/inazszdwryvdudzw2ss8.jpg}', '2025-11-10 18:30:16.019669', '2025-11-10 18:30:16.019669', '00008d13-0bba-4508-b679-1fdee2890c14', 'الغرافه', 598, NULL, NULL, NULL, NULL, '{uploads/inazszdwryvdudzw2ss8}');
INSERT INTO public.posts VALUES ('9439b4b8-3e61-4622-9154-40707f3769bd', 'للبيع فلتين جداد في ام صلال علي 
 مساحة الارض 450 متر ومساحة البناء 437 متر.. صالة ومجلس ومطعم  وعدد 7 غرف 7 حمامات ومطبخ خارجي  وغرفة غسيل وغرفة وغرفة سائق 
الموقع مميز علي شارعين امامي و خلفي بجانب المسجد 
السعر 3,100,000 ريال  
قابل للجاد', 3, 2, 18, false, 1, 'ام صلال على ', 3100000.00, 7, 5, 450.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1756526064/uploads/hzagxcw6ztfbhezhxl6l.jpg}', '2025-08-30 03:54:24.964729', '2025-08-30 03:54:24.964729', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'ام صلال على', 599, NULL, NULL, NULL, NULL, '{uploads/hzagxcw6ztfbhezhxl6l}');
INSERT INTO public.posts VALUES ('270f91ae-cc7b-4843-8a15-b9cbc7a1fe6d', 'من المالك 
للبيع فيلا في الخريطيات تشطيب VIB سوبر ديلوكس (راقي جدا على آعلى مستوى ) مساحه الارض 600 م والبناء 650 م الفيلا حجر طبيعي + لفت ذهبي + واجهات رخام + مطابخ مودرن مجهزه من الأجهزة الكهربائية  + مكيف مركزي لجميع الأدوار + اضاءه حديثة +احواض زراعية + رخام 
بها مجلس خارجي مع مغاسل وحمام 
8 غرف ماستر مع غرف ملابس وحمامات معلقه + جميع المغاسل رخام اصلي + ابواب خشب تيك 
صالات مفتوحه 
ملاحق خارجيه وغرفه غسيل إضافية 

واصله كهرباء وماء والمصعد راكب والتكييف مركزي راكب وشغال 

السعر 5 مليون', 3, 2, 18, false, 1, 'الخريطيات ', 5000000.00, 8, 5, 600.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1758001974/uploads/asmklokhhtdevjhmnubq.jpg}', '2025-09-16 05:52:55.046807', '2025-09-16 05:52:55.046807', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'الخريطيات ', 936, NULL, NULL, NULL, NULL, '{uploads/asmklokhhtdevjhmnubq}');
INSERT INTO public.posts VALUES ('a073ac87-c6c1-49bc-b4ad-2e046ffa0ed4', '٦ غرف و مجلس داخلى و ٧ حمامات و مطبخ و صالة و حوش خارجى و مطبخ خارجى و صالتين', 1, 2, 18, true, 2, '', 15000.00, 6, 5, 500.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1752685761/uploads/qywhso7eejo8pmetpb9i.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1752685760/uploads/f2tabrtdo8jwe6yiamwy.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1752685760/uploads/cx5jxlbjyivxbyltotjh.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1752685761/uploads/rwymtcu9l6zylji3bphj.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1752685760/uploads/folpie6eu79qhmginkev.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1752685761/uploads/wibuon3tiqreoluheynh.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1752685761/uploads/b5mcenua2nygoog50ybq.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1752685761/uploads/mltv4mcwfoohmyyiapnb.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1752685761/uploads/ndqfklyylylavk7qrbtd.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1752685761/uploads/qs01n9jp1up0hlrl8zi2.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1752685761/uploads/c7ulpzqoipbqk6fxelau.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1752685761/uploads/ld64sdvh99wsbanb59tu.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1752685761/uploads/x6tjvjojlzvpyihcy5y8.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1752685761/uploads/d0zgngem3eelzduhjnjp.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1752685761/uploads/mpaslt6gjwafxhgff8kk.jpg}', '2025-07-16 17:09:22.761287', '2025-07-16 17:09:22.761287', '479690a3-da25-4188-bf72-eade4825f30c', '', 765, NULL, NULL, NULL, NULL, '{}');
INSERT INTO public.posts VALUES ('a78286c6-a060-4ce7-a855-799bb969dbef', 'للبيع  قطعه ارض في منطقه الثميد مساحه 1309 متر مربع على شارع واحد واجهه كبيره 
في موقع ممتاز جدا وسط البنيان وبالقرب من الاسواق التجاريه اسواق الفرجان 
', 2, 2, 19, false, 3, 'الثميد ', 4935000.00, NULL, NULL, 1309.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1774299227/uploads/ng4yixdggal2eusckxmh.jpg}', '2026-03-23 20:53:49.047285', '2026-03-23 20:53:49.047285', '00008d13-0bba-4508-b679-1fdee2890c14', 'الثميد ', 225, NULL, NULL, NULL, NULL, '{uploads/ng4yixdggal2eusckxmh}');
INSERT INTO public.posts VALUES ('a1cc6def-3125-4f59-9980-3852bdb35f6d', 'للبيع  فيلتين متلاصقات فى  حزم المرخيه مساحة ٨٨٧ م، البناء فى ٢٠٢٢م كل فيلا ٦ غرف ومجلس وصالة وملاحق ومؤجرين ب ٣٥ الف شيك واحد عقد ٣ سنوات ، مطلوب ٥.٥٠٠ مليون.*', 1, 2, 18, false, 1, 'حزم المرخيه', 5500000.00, 8, 5, 887.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1762718611/uploads/as2n3tm4kxt8rmlgxn53.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1762718611/uploads/rzpv0stsdr08sndnud86.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1762718611/uploads/x4zrwah1nwnqvgh8s9di.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1762718611/uploads/tsixcloghmstso5n9uzu.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1762718611/uploads/fbmoproeqmncajhody6k.jpg}', '2025-11-09 20:03:34.129391', '2025-11-09 20:03:34.129391', '00008d13-0bba-4508-b679-1fdee2890c14', 'حزم المرخيه', 738, NULL, NULL, NULL, NULL, '{uploads/as2n3tm4kxt8rmlgxn53,uploads/rzpv0stsdr08sndnud86,uploads/tsixcloghmstso5n9uzu,uploads/x4zrwah1nwnqvgh8s9di,uploads/fbmoproeqmncajhody6k}');
INSERT INTO public.posts VALUES ('6233dd76-471a-43ba-9220-7a818b1f669c', 'للبيع فيلا بالمشاف بمساحة 500م مع 8 غرف ماستر، مجلس داخلي، وصالة مفتوحة، ملحق، مطبخ خارجي ومجلس خارجي، ويوجد ليفت.  
السعر المطلوب: 3,300,000 ريال قطري فقط! 🏡✨', 5, 2, 18, false, 1, 'جريان مصبح', 3300000.00, 8, 5, 500.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1758890371/uploads/yt5vd4nz30lttmqaw0uc.jpg}', '2025-09-26 12:39:32.302253', '2025-09-26 12:39:32.302253', '8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', 'المشاف ', 1939, NULL, NULL, NULL, NULL, '{uploads/yt5vd4nz30lttmqaw0uc}');
INSERT INTO public.posts VALUES ('a91987ee-d038-46fb-b78c-e2f3b918fcd2', 'فيلا مستعمله  
فيلا للبيع في الدحيل مساحه 841 م خلف الريفيرا  عمرها 16 سنه 
تتكون من 
7 غرف ماستر 
ومجلس داخلي منفصل 
وبنت هاوس 
وصالتين وملحق خارجي 
ومطبخ داخلي 
وملحق خارجي 

الفيلا فاضيه وجاهزه للاستلام 
مطلوب 4 مليون و50 الف 
بسعر الارض الفيلا', 1, 2, 18, false, 2, 'الدحيل ', 4050000.00, 7, 5, 8.00, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1762956438/uploads/f2uxthhffnlqppzjob3k.jpg}', '2025-11-12 14:07:19.751125', '2025-11-12 14:07:19.751125', '00008d13-0bba-4508-b679-1fdee2890c14', 'الدحيل ', 540, NULL, NULL, NULL, NULL, '{uploads/f2uxthhffnlqppzjob3k}');
INSERT INTO public.posts VALUES ('000a7b29-bb9e-43a7-b744-a558e51cbbef', '

للايجار ستور جديد في بركة العوامر 
- ميزانين الاول ٤٨٠م متر الثاني ٣٥٠م
- يوجد مكتب مكيف بملحقاته
- غرفه حارس مكيفه بملحقاتها
- السعر ١٣ الف نهائي', 5, 1, 13, false, 2, 'بركه العوامر ', 13000.00, 4, 5, NULL, '{https://res.cloudinary.com/dewlycvqs/image/upload/v1758362616/uploads/iyoy1otndcql6znjlaog.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1758362616/uploads/m4yhww6grupexedbdgsh.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1758362617/uploads/hqf4r7wnqvrlpgqtwetr.jpg,https://res.cloudinary.com/dewlycvqs/image/upload/v1758362616/uploads/kzejah1kogcv4f7bmbwl.jpg}', '2025-09-20 10:03:38.474871', '2025-09-20 10:03:38.474871', '00008d13-0bba-4508-b679-1fdee2890c14', 'بركه العوامر ', 1171, NULL, NULL, NULL, NULL, '{uploads/iyoy1otndcql6znjlaog,uploads/m4yhww6grupexedbdgsh,uploads/kzejah1kogcv4f7bmbwl,uploads/hqf4r7wnqvrlpgqtwetr}');
INSERT INTO public.posts VALUES ('ad630e42-5745-4ab6-add0-bdc5efaddc18', 'كافيه مميز للبيع لعدم التفرغ بكامل معداته وتجهيزاته

موقع الكافيه

https://goo.gl/maps/YyXReQSuMmGdu7r66

سعر البيع 200 ألف ريال

قيمة الإيجار الشهري
5767 ريال فقط

للجادين فقط التواصل عبر الواتس اب
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

INSERT INTO public.users VALUES ('2caad35c-8d76-4920-9c09-796de58392d9', '97431467666', 'individual', NULL, 'Alaaeldin mohamed ', 'علاء الدين محمد ', NULL, NULL, NULL, true, '2025-08-11 03:18:00.63076', '2025-08-11 03:18:00.63076', NULL, false);
INSERT INTO public.users VALUES ('0d09855d-3534-4ef0-a8b4-486383b93775', '97430231318', 'business', NULL, 'Talaat Farag Ibrahim Khalil ', 'طلعت فرج إبراهيم خليل', '216960', 'JSWR ALMjd for Trading and Contracting ', 'جسور المجد للتجارة والمقاولات', true, '2025-07-31 02:29:20.633279', '2025-07-31 02:29:20.633279', NULL, false);
INSERT INTO public.users VALUES ('a7b77bb9-8519-4201-8034-527b17d21de3', '97470401700', 'business', NULL, 'DOTA ALDOHA REAL ESTATE ', 'درة الدوحه للوساطه العقاريه ', '162125', 'DOTA ALDOHA REAL ESTATE ', 'درة الدوحه للوساطه العقاريه ', true, '2025-09-02 16:46:00.242733', '2025-09-02 16:46:00.242733', NULL, false);
INSERT INTO public.users VALUES ('7de65174-bc80-49bb-9c87-571fbea3888b', '97455230402', 'individual', NULL, 'Umsaleh ahmed', 'سلوى احمد', NULL, NULL, NULL, true, '2025-08-03 20:31:28.789596', '2025-08-03 20:31:28.789596', NULL, false);
INSERT INTO public.users VALUES ('4aef6cd7-d470-42ef-a860-648e16aa6c08', '97433676637', 'individual', NULL, 'Ahmed', 'أحمد ', NULL, NULL, NULL, true, '2025-08-28 06:07:06.859554', '2025-08-28 06:07:06.859554', NULL, false);
INSERT INTO public.users VALUES ('8851b2e5-50d2-4795-b5c4-05b7a9ffe90f', '97471535247', 'business', NULL, 'abo gheith', 'ابو غيث ', '987897', 'AQARAT', 'عقارات', true, '2025-07-26 15:07:17.7986', '2025-07-26 15:07:17.7986', NULL, false);
INSERT INTO public.users VALUES ('d26d5775-858b-4ceb-9aa7-e152c57ee233', '97466410475', 'individual', NULL, 'Ahmad ghazi Aljassim', 'احمد غازي الجاسم ', NULL, NULL, NULL, true, '2025-08-06 11:23:19.810248', '2025-08-06 11:23:19.810248', NULL, false);
INSERT INTO public.users VALUES ('4fc1d1d8-21fb-417f-8355-fe767777aae7', '97430662515', 'individual', NULL, 'بشير ', 'فهد ', NULL, NULL, NULL, true, '2025-07-27 20:45:26.982389', '2025-07-27 20:45:26.982389', NULL, false);
INSERT INTO public.users VALUES ('18e15b48-2d06-47e9-b8ec-aa49ef39b847', '97466266005', 'individual', NULL, 'yousif', 'يوسف', NULL, NULL, NULL, true, '2025-07-24 02:19:10.305636', '2025-07-24 02:19:10.305636', NULL, false);
INSERT INTO public.users VALUES ('a5c20520-86c4-4cb5-a13f-a5b621defa8b', '97455108707', 'individual', '$2b$10$J5Ad.peeC3WCLsOBC.W.OOd41t9AL8C.K8nLvRWLXDNe8RbI0iRg.', 'Umm abdull', 'ام عبدالله', NULL, NULL, NULL, true, '2025-07-02 19:56:26.391576', '2025-07-02 19:56:26.391576', NULL, false);
INSERT INTO public.users VALUES ('48d8d695-e182-430a-8721-8490e7b0852a', '97450411803', 'business', NULL, 'ABDALLAH EZZO', 'عبدالله عزو', '158224', 'ABSHER REALSTATE BROKERGE ', 'أبشر للوساطة العقارية ', true, '2025-07-08 05:31:36.238992', '2025-07-08 05:31:36.238992', NULL, false);
INSERT INTO public.users VALUES ('083fb897-9d85-4b71-9486-d6052b888148', '97455834895', 'business', '$2b$10$4yy.Pb39TrvT8wq7Don.IuJRHFe4g/CjAxxNqbzDtReSixckIzQdS', 'Ibrahim Ali Ali Saad', 'إبراهيم علي علي سعد', '17538', 'Jassim Trade Center ', 'مركز جاسم التجاري', true, '2025-06-25 20:26:26.038569', '2025-06-25 20:26:26.038569', NULL, false);
INSERT INTO public.users VALUES ('7fe0870a-02ad-4c09-8548-78c1eba0172a', '97455832232', 'individual', '$2b$10$brRQnAvIhdqxRKCmG22zauCJMtIE4NpFfFlEguRzZ23YvQRp5O07y', 'Ali almohannadi ', 'علي المهندي', NULL, NULL, NULL, true, '2025-07-05 05:20:31.679644', '2025-07-05 05:20:31.679644', NULL, false);
INSERT INTO public.users VALUES ('69e24c97-9e3a-495b-9553-21aaf6731354', '97477182999', 'individual', '$2b$10$Hw5LvibjheVGOlpFPHQYEu3V4IuJhXwwNgtiMO3/xfj4aUAUaYyLC', 'Abo malek ', 'ابو مالك ', NULL, NULL, NULL, true, '2025-06-26 00:36:57.806117', '2025-06-26 00:36:57.806117', NULL, false);
INSERT INTO public.users VALUES ('a9b2b67f-699f-4d5c-a181-cc4339be7231', '97433032114', 'individual', NULL, 'Ammar Jawdat alkrad ', 'عمار جودات الكراد ', NULL, NULL, NULL, true, '2025-09-04 19:32:48.058612', '2025-09-04 19:32:48.058612', NULL, false);
INSERT INTO public.users VALUES ('18eee0be-32d4-4294-90b4-bd9e436c2045', '97470947008', 'individual', NULL, 'SAMl', 'سامي', NULL, NULL, NULL, true, '2025-07-08 06:26:18.617976', '2025-07-08 06:26:18.617976', NULL, false);
INSERT INTO public.users VALUES ('969f7636-60a1-4f9d-ba03-71e40036d334', '97455502214', 'individual', NULL, 'Ahmedhassan', 'احمد حسن ', NULL, NULL, NULL, true, '2025-09-01 11:11:53.130006', '2025-09-01 11:11:53.130006', NULL, false);
INSERT INTO public.users VALUES ('faf09832-63a6-43d4-a57d-dd875f73ab52', '97455852650', 'individual', '$2b$10$vH1xU5EkVc5GTA7W1li2WeqWeQVU5utsAtBU1GHtzHwM.ktWhfehW', 'ABDULLA ALKUWARI ', 'عبدالله الكواري', NULL, NULL, NULL, true, '2025-07-03 10:17:24.589268', '2025-07-03 10:17:24.589268', NULL, false);
INSERT INTO public.users VALUES ('0644702f-39af-4d4c-a40a-c7829752db57', '97450008583', 'individual', '$2b$10$g6bx24a6mYoK5ep2Hl00EuXVQnRypcIkK76xzXEFymSFpD0RkgsAi', 'Hassan albdullh alkhalaf', 'حسن عبدالله الخلف ', NULL, NULL, NULL, true, '2025-07-03 14:54:07.368666', '2025-07-03 14:54:07.368666', NULL, false);
INSERT INTO public.users VALUES ('beda8965-3d8f-4d38-89b7-341060e9ab96', '97455888273', 'individual', '$2b$10$lx9gHOGW9rp0mvF4qds32.eEqxIZk/LmnpGv8uklNLXOnRuFlg7Ma', 'Mohamed ', 'محمد', NULL, NULL, NULL, true, '2025-07-06 03:47:50.132159', '2025-07-06 03:47:50.132159', NULL, false);
INSERT INTO public.users VALUES ('8f78f1e8-7199-4073-bdf4-279a99161fc9', '97466060863', 'individual', '$2b$10$st7FHICQ2tB2LsZhsNam5eDp1zBMcV.rSL9mYzbTDuMrfk3IGel22', 'Muhammad Usman', 'محمد عثمان', NULL, NULL, NULL, true, '2025-07-03 19:07:17.22117', '2025-07-03 19:07:17.22117', NULL, false);
INSERT INTO public.users VALUES ('04729d6f-77e4-461b-bb63-41bbd691ccc8', '97477771272', 'individual', '$2b$10$MS/ah7dbXqzS.FjhJwqmneGIbPTcalL..wYu7.EfD309YkqAtVG.G', 'Fatma alkuwari', 'فاطمه الكواري', NULL, NULL, NULL, true, '2025-07-04 16:29:33.069174', '2025-07-04 16:29:33.069174', NULL, false);
INSERT INTO public.users VALUES ('36946934-b95e-45c5-96b0-f5f2bf3e8cec', '97455200095', 'individual', '$2b$10$rMktXQaGyD9zKRHpwNHQ3.bBN2.PaBWV5bd7Rp3EFefkBN1TEbFwO', 'Khaled', 'خالد', NULL, NULL, NULL, true, '2025-07-07 08:55:06.929117', '2025-07-07 08:55:06.929117', NULL, false);
INSERT INTO public.users VALUES ('ce7a41fe-ff9b-4397-84cb-62c43e218769', '97455777716', 'individual', NULL, 'Saif Abujabra', 'سيف محمد', NULL, NULL, NULL, true, '2025-09-09 20:54:33.691135', '2025-09-09 20:54:33.691135', NULL, false);
INSERT INTO public.users VALUES ('b44b6e18-08c0-4a2f-98de-b873b287ac82', '97433471003', 'individual', '$2b$10$YMsxQttfP7AuvInh2rPJd.Jawp7HYfhDlXX35AkVUzMIqqvMVU/WG', 'Fadia', 'فادية طلعت', NULL, NULL, NULL, true, '2025-06-25 20:37:54.245288', '2025-06-25 20:37:54.245288', NULL, false);
INSERT INTO public.users VALUES ('0b2e5742-a930-457b-a2be-3eb1bde03b17', '97455933280', 'individual', '$2b$10$pFfnTe8jro0vE4DsDHWr7OFERGhmGGTrvPzUnDtLHJIDw1cEO7Psy', 'Haneen Saad', 'حنين سعد', NULL, NULL, NULL, true, '2025-06-19 23:39:38.635443', '2025-06-19 23:39:38.635443', NULL, false);
INSERT INTO public.users VALUES ('a1bd4efa-9b57-4726-8808-2b36f0830aa2', '97455888280', 'individual', NULL, 'SAAD', 'سعد', NULL, NULL, NULL, true, '2025-07-07 23:46:52.567841', '2025-07-07 23:46:52.567841', NULL, false);
INSERT INTO public.users VALUES ('fc0ac422-4716-4b3a-b722-8b330bfe88af', '97450316381', 'individual', NULL, 'Rana', 'رنا', NULL, NULL, NULL, true, '2025-08-26 19:53:58.262439', '2025-08-26 19:53:58.262439', NULL, false);
INSERT INTO public.users VALUES ('30221241-6493-487d-a11d-74a10b396c4e', '97477114773', 'individual', NULL, 'Jasser Romdhana', 'جاسر رمضانة', NULL, NULL, NULL, true, '2025-08-26 07:00:08.924611', '2025-08-26 07:00:08.924611', NULL, false);
INSERT INTO public.users VALUES ('f5a37da7-d74f-4b0f-9a65-1e82b52d7813', '97477240788', 'business', NULL, 'Marasy realestate ', 'مراسي العقارية', '1234567', 'Marasy realestate ', 'مراسي العقارية', true, '2025-09-23 05:50:41.176247', '2025-09-23 05:50:41.176247', NULL, false);
INSERT INTO public.users VALUES ('5086bce9-36c6-4cac-9b80-207f54e2ae00', '97477711918', 'individual', NULL, 'M', 'مها', NULL, NULL, NULL, true, '2025-09-14 11:32:04.171757', '2025-09-14 11:32:04.171757', NULL, false);
INSERT INTO public.users VALUES ('e03682c8-d708-47b3-98c0-6d74b3c16229', '97450000151', 'individual', NULL, 'Hassan', 'حسن', NULL, NULL, NULL, true, '2025-09-16 18:12:05.151666', '2025-09-16 18:12:05.151666', NULL, false);
INSERT INTO public.users VALUES ('95528c3a-e08f-4a04-b126-e9229c7403c7', '97450081212', 'individual', NULL, 'Sultan Ali Nasser ', 'سلطان علي ناصر', NULL, NULL, NULL, true, '2025-09-15 17:30:29.646046', '2025-09-15 17:30:29.646046', NULL, false);
INSERT INTO public.users VALUES ('e6831544-b929-4569-91cb-3c2c65a547d0', '97450928733', 'individual', NULL, 'Moaaz Abo Zeed', 'معاذ أبو زيد', NULL, NULL, NULL, true, '2025-09-10 09:47:57.671134', '2025-09-10 09:47:57.671134', NULL, false);
INSERT INTO public.users VALUES ('784d5743-2a16-4978-b44a-82997c1c5551', '97466748781', 'individual', NULL, 'Amal saif alamer', 'امل سيف العامر', NULL, NULL, NULL, true, '2025-09-30 18:07:11.606267', '2025-09-30 18:07:11.606267', NULL, false);
INSERT INTO public.users VALUES ('7796422a-bbfe-4b6b-b062-0c1dab1ec5cc', '97450134867', 'individual', NULL, 'Hatem ramadan', 'حاتم رمضان', NULL, NULL, NULL, true, '2025-08-15 14:46:46.397254', '2025-08-15 14:46:46.397254', NULL, false);
INSERT INTO public.users VALUES ('86b86666-45a8-4400-a4cb-a424e2059582', '97455822825', 'individual', NULL, 'Ali Hassan alali ', 'علي حسن العلي', NULL, NULL, NULL, true, '2025-10-10 19:42:55.667975', '2025-10-10 19:42:55.667975', NULL, false);
INSERT INTO public.users VALUES ('c01ce1c0-9084-4721-8a5e-e09e492a991e', '97466669980', 'individual', NULL, 'Khalid Yousef  Aljehani ', 'خالد يوسف المالكي ', NULL, NULL, NULL, true, '2025-10-15 20:07:47.058152', '2025-10-15 20:07:47.058152', NULL, false);
INSERT INTO public.users VALUES ('e4b109a5-083d-44ee-9095-732144e2e719', '97466094943', 'individual', NULL, 'ABDELRAHMAN ', 'عبدالرحمن ', NULL, NULL, NULL, true, '2025-10-28 11:24:36.836892', '2025-10-28 11:24:36.836892', NULL, false);
INSERT INTO public.users VALUES ('c0461100-60ce-404a-86a6-86610b5c2f89', '97450067840', 'business', NULL, 'Marsana real estate', 'مرسانا للوساطة العقارية ', '150532', 'Marsana real estate', 'مرسانا للوساطة العقارية ', true, '2025-11-02 16:10:54.010124', '2025-11-02 16:10:54.010124', NULL, false);
INSERT INTO public.users VALUES ('d15a6fdd-2f8c-4897-a1d0-19bbdcdf1f85', '97455906666', 'individual', NULL, 'Abdulla AL Nuaimi', 'عبدالله النعيمي', NULL, NULL, NULL, true, '2025-11-08 08:24:56.257457', '2025-11-08 08:24:56.257457', NULL, false);
INSERT INTO public.users VALUES ('8fbae5c3-6aa5-45db-967d-f060405a92de', '97466141559', 'individual', NULL, 'ahmedkhater', 'العوضى', NULL, NULL, NULL, true, '2025-07-08 08:07:55.159351', '2025-07-08 08:07:55.159351', NULL, false);
INSERT INTO public.users VALUES ('30589e15-eabe-457a-9914-764715dbf66e', '97466213332', 'individual', NULL, 'Sama Doha', 'سما الدوحة', NULL, NULL, NULL, true, '2025-07-31 09:55:58.090905', '2025-07-31 09:55:58.090905', NULL, false);
INSERT INTO public.users VALUES ('719ce1ed-1661-4b63-af99-d3cde43f5a13', '97430078494', 'individual', NULL, 'Darak Real Estate ', 'دارك العقارية ', NULL, NULL, NULL, true, '2025-10-29 11:26:47.91199', '2025-10-29 11:26:47.91199', NULL, false);
INSERT INTO public.users VALUES ('6570802e-2c1f-4d9f-9431-e9af80fe6c2f', '97477778866', 'individual', NULL, 'Ibrahim', 'ابراهيم', NULL, NULL, NULL, true, '2025-08-03 21:32:44.109407', '2025-08-03 21:32:44.109407', NULL, false);
INSERT INTO public.users VALUES ('8405f0ac-0587-462d-a5ad-f2a14b41948a', '97431011015', 'individual', NULL, 'Lolwa Lolwa', 'لولوه محمد المري', NULL, NULL, NULL, true, '2025-09-04 21:43:56.053133', '2025-09-04 21:43:56.053133', NULL, false);
INSERT INTO public.users VALUES ('cedd9058-1505-4739-a584-4ba6badf04fd', '97455123842', 'individual', '$2b$10$yCw9eKDAUTx4oH1PtHaHIu/bkPQC9J6oQ4f0FpdJ6tIAbYC8HNKL2', 'Mohamed', 'احمد سعد', NULL, NULL, NULL, true, '2025-06-16 18:04:55.216835', '2025-06-16 18:04:55.216835', NULL, false);
INSERT INTO public.users VALUES ('2a205ea3-91f1-4dea-bf54-cf0aef0c3903', '97471376244', 'individual', NULL, 'Hosamameer alkhtim osman ', 'حسام امير الختم عثمان', NULL, NULL, NULL, true, '2025-07-21 13:07:20.939863', '2025-07-21 13:07:20.939863', NULL, false);
INSERT INTO public.users VALUES ('ddb44b72-275b-4fe6-b56b-5e7dd412d318', '97477005511', 'individual', NULL, 'Hassan Ali Alaali', 'حسن علي العالي', NULL, NULL, NULL, true, '2025-11-30 10:25:59.362629', '2025-11-30 10:25:59.362629', NULL, false);
INSERT INTO public.users VALUES ('e96ee3a6-b66c-4c80-bbad-cf5e7f13a56a', '97466116361', 'individual', NULL, 'Fatima Ali', 'فاطمة علي', NULL, NULL, NULL, true, '2025-07-29 09:33:07.812326', '2025-07-29 09:33:07.812326', NULL, false);
INSERT INTO public.users VALUES ('242a522e-232a-4291-aa31-c5177a726929', '97470766667', 'business', NULL, 'Naif aldosari', 'نايف الدوسري', '191715', 'Nwe One Real Estate', 'نيو ون العقارية', true, '2025-07-29 17:59:04.69538', '2025-07-29 17:59:04.69538', NULL, false);
INSERT INTO public.users VALUES ('dc9572cb-b0d5-4f6b-ba95-de766bce3030', '97477278478', 'individual', NULL, 'Musab', 'مصعب', NULL, NULL, NULL, true, '2025-09-12 12:15:05.109088', '2025-09-12 12:15:05.109088', NULL, false);
INSERT INTO public.users VALUES ('d5f15140-1fc3-4656-82a6-7404e3c42720', '97455980787', 'individual', NULL, 'Fahad Abdulla Almulla', 'فهد عبدالله الملا', NULL, NULL, NULL, true, '2025-08-17 18:09:30.833995', '2025-08-17 18:09:30.833995', NULL, false);
INSERT INTO public.users VALUES ('11c303ec-c375-4784-9c50-ad1ce523a66e', '97466664229', 'individual', NULL, 'Saleh', 'صالح', NULL, NULL, NULL, true, '2025-08-24 09:19:22.818211', '2025-08-24 09:19:22.818211', NULL, false);
INSERT INTO public.users VALUES ('e671a096-8ed8-4cc2-9f8f-adbeff9da47b', '97455411002', 'individual', NULL, 'Talal Nasser', 'طلال ناصر', NULL, NULL, NULL, true, '2025-11-12 20:54:33.289471', '2025-11-12 20:54:33.289471', NULL, false);
INSERT INTO public.users VALUES ('64bdfb3c-d629-49a8-bb85-d01978cb09a9', '97455786848', 'individual', NULL, 'Nouf alhamad', 'نوف', NULL, NULL, NULL, true, '2025-09-15 20:13:57.981052', '2025-09-15 20:13:57.981052', NULL, false);
INSERT INTO public.users VALUES ('c50eb6e5-5f22-43c1-8be4-ebaa11b59d11', '97450501100', 'individual', NULL, 'Mohammad altamimi', 'محمد التميمي', NULL, NULL, NULL, true, '2025-08-26 11:43:11.790501', '2025-08-26 11:43:11.790501', NULL, false);
INSERT INTO public.users VALUES ('e1ff8045-138b-4281-94ae-c98b1198af29', '97466333177', 'individual', NULL, 'Hamad almarri', 'حمد المري', NULL, NULL, NULL, true, '2025-08-28 18:07:10.276023', '2025-08-28 18:07:10.276023', NULL, false);
INSERT INTO public.users VALUES ('6b1a488d-8218-430c-89e3-aa87ac93caa9', '97477609915', 'individual', NULL, 'Mohammed mansour ', 'محمد منصور ', NULL, NULL, NULL, true, '2025-09-01 18:16:47.239357', '2025-09-01 18:16:47.239357', NULL, false);
INSERT INTO public.users VALUES ('efd98c15-b61e-4b24-9bf6-80c358bb317b', '97430332112', 'individual', NULL, 'Mohammed Al Jaaidi', 'محمد الجعيدي', NULL, NULL, NULL, true, '2025-09-20 07:06:06.549634', '2025-09-20 07:06:06.549634', NULL, false);
INSERT INTO public.users VALUES ('a508a6b9-7544-4888-8bf5-70279cbd4785', '97477400095', 'business', NULL, 'Future Realstate ', 'المستقبل للوساطه العقاريه', '23843', 'Future Realstate ', 'المستقبل للوساطة العقاريه ', true, '2025-11-01 16:01:25.405576', '2025-11-01 16:01:25.405576', NULL, false);
INSERT INTO public.users VALUES ('6374f9d1-560c-4632-895a-9dff32ce2300', '97466660406', 'individual', NULL, 'SALEM', 'سالم', NULL, NULL, NULL, true, '2025-09-26 23:23:22.075024', '2025-09-26 23:23:22.075024', NULL, false);
INSERT INTO public.users VALUES ('76a34cb5-52b8-46fd-a694-a8d5b05ab3f5', '97430004143', 'individual', NULL, 'Law farm', 'مكتب محاماه', NULL, NULL, NULL, true, '2025-10-01 20:41:52.083316', '2025-10-01 20:41:52.083316', NULL, false);
INSERT INTO public.users VALUES ('37d0163c-2fc9-4f30-99da-a7cfb3c8750e', '97431337131', 'individual', NULL, 'Fathi Ali Asideh ', 'فتحي علي عصيدة ', NULL, NULL, NULL, true, '2025-11-13 23:27:30.440004', '2025-11-13 23:27:30.440004', NULL, false);
INSERT INTO public.users VALUES ('5141eb42-12e1-4c77-b51e-37504498bb51', '97433222509', 'business', NULL, 'Gnosis Real Estate', 'جنوسيس العقارية', '141860', 'Gnosis Real Estate', 'جنوسيس العقارية', true, '2025-11-06 04:13:00.591682', '2025-11-06 04:13:00.591682', NULL, false);
INSERT INTO public.users VALUES ('63f1bdf7-e4a3-4776-a39a-441db10520c3', '97433660336', 'individual', NULL, 'Amina Ali', 'أمينة علي', NULL, NULL, NULL, true, '2025-10-08 18:45:10.306249', '2025-10-08 18:45:10.306249', NULL, false);
INSERT INTO public.users VALUES ('25f0e324-8257-4aba-ad26-b2e72a97c32f', '97433599188', 'business', NULL, 'MOHAMMED ABDILAHAKEM ALYAFIE', 'محمد ', '192232', 'Consultants', 'المستشــــارون ', true, '2025-10-11 01:04:58.819575', '2025-10-11 01:04:58.819575', NULL, false);
INSERT INTO public.users VALUES ('a88266cf-ec85-4c9a-9fdc-3baf51e2f5fc', '97430055532', 'business', NULL, 'Mohammed Zakaria Mohammed Hassan ', 'محمد زكريا محمد حسن', '104431', 'NTS logistics ', 'ان تي اس لوجيستيك', true, '2025-11-13 05:11:04.600414', '2025-11-13 05:11:04.600414', NULL, false);
INSERT INTO public.users VALUES ('d2e95f1e-ebbd-435a-8015-d6092b0031f6', '97455556036', 'individual', NULL, 'Om Ghanim', 'ام غانم', NULL, NULL, NULL, true, '2025-11-10 12:24:29.787586', '2025-11-10 12:24:29.787586', NULL, false);
INSERT INTO public.users VALUES ('a8ae53eb-903c-4713-9430-b428f9ea17ab', '97466664032', 'individual', NULL, 'Hamad alsenaid', 'حمد السنيد', NULL, NULL, NULL, true, '2025-11-11 16:46:55.303497', '2025-11-11 16:46:55.303497', NULL, false);
INSERT INTO public.users VALUES ('050e30d1-9dde-425a-9e8b-6ae5a08387e4', '97455105232', 'individual', NULL, 'Ahmad Youssef', 'أحمد يوسف', NULL, NULL, NULL, true, '2025-11-11 17:35:04.43355', '2025-11-11 17:35:04.43355', NULL, false);
INSERT INTO public.users VALUES ('a017c507-2bfb-40c2-b126-5ca4c679ca5d', '97466451749', 'individual', NULL, 'Rana Ammoura', 'رنا حسن', NULL, NULL, NULL, true, '2025-11-12 07:55:45.647529', '2025-11-12 07:55:45.647529', NULL, false);
INSERT INTO public.users VALUES ('13ccb56e-957d-496a-91cf-b70f9cf6d55e', '97477111520', 'individual', NULL, 'fahad almahmod', 'فهد المحمود ', NULL, NULL, NULL, true, '2025-11-13 08:52:17.438121', '2025-11-13 08:52:17.438121', NULL, false);
INSERT INTO public.users VALUES ('5dd35d75-d357-4fba-8e2a-9428dd10b0ba', '97430544110', 'business', NULL, 'Medad for gifts and stationery trading ', 'مداد للهدايا وتجارة القرطاسية ', '150231', 'Medad ', 'مداد', true, '2025-11-14 19:41:47.880332', '2025-11-14 19:41:47.880332', NULL, false);
INSERT INTO public.users VALUES ('22122433-ac35-4af5-be80-88abf13af50c', '97431310200', 'individual', NULL, 'Wadeedjehg', 'وديع غلاب ', NULL, NULL, NULL, true, '2025-12-30 10:07:05.961957', '2025-12-30 10:07:05.961957', NULL, false);
INSERT INTO public.users VALUES ('d94bfae0-d3a9-46b5-828c-9988e0039ce7', '97430000966', 'individual', NULL, 'Mohammed Alkuwari ', 'محمد الكواري', NULL, NULL, NULL, true, '2025-07-27 08:17:24.345053', '2025-07-27 08:17:24.345053', NULL, false);
INSERT INTO public.users VALUES ('26b36703-a959-43ac-bd01-affbfd3ba29c', '97455250866', 'individual', NULL, 'Abdulrahman almaristani', 'عبدالرحمن المرستاني ', NULL, NULL, NULL, true, '2025-11-16 10:39:06.978957', '2025-11-16 10:39:06.978957', NULL, false);
INSERT INTO public.users VALUES ('0714cb8f-55b3-4575-a8ec-b21e8b65611a', '97471418403', 'individual', NULL, 'keltoum ', 'كلتوم', NULL, NULL, NULL, true, '2025-11-19 19:22:29.676562', '2025-11-19 19:22:29.676562', NULL, false);
INSERT INTO public.users VALUES ('29bece65-37c1-4a0b-b914-79a6946c25ae', '97466609797', 'business', NULL, 'Hayat Cafe', 'مقهى حياة', '168108', 'Hayat Cafe', 'مقهى حياة', true, '2025-11-25 13:46:23.439738', '2025-11-25 13:46:23.439738', NULL, false);
INSERT INTO public.users VALUES ('3a42e4e9-5e2f-46d3-87a4-4905b510aaba', '97451160211', 'individual', NULL, 'Ahmad Al Ali', 'أحمد العلي', NULL, NULL, NULL, true, '2025-12-17 08:29:18.022332', '2025-12-17 08:29:18.022332', NULL, false);
INSERT INTO public.users VALUES ('f7865234-4328-4f1d-ab83-c0aba5cc5079', '97450055559', 'individual', NULL, 'Tamather Alhajri', 'تماضر الهاجري', NULL, NULL, NULL, true, '2025-12-13 19:30:38.346666', '2025-12-13 19:30:38.346666', NULL, false);
INSERT INTO public.users VALUES ('e91e7a32-37f1-4285-8781-e6adfe517b94', '97466716676', 'individual', NULL, 'Rauof morad dorazaei', 'رئوف مراد درازئي', NULL, NULL, NULL, true, '2026-01-11 16:49:42.046736', '2026-01-11 16:49:42.046736', NULL, false);
INSERT INTO public.users VALUES ('b3a2e794-bc82-4979-8bfd-629cf21fe3b7', '97455541484', 'individual', NULL, 'Abdulla ', 'عبدالله', NULL, NULL, NULL, true, '2026-01-11 18:21:59.464301', '2026-01-11 18:21:59.464301', NULL, false);
INSERT INTO public.users VALUES ('ff4bc451-29fe-4b9d-900f-416afe1c1823', '97466155551', 'individual', NULL, 'Aisha Almohannadi ', 'عائشة المهندي', NULL, NULL, NULL, true, '2026-01-12 10:40:26.512863', '2026-01-12 10:40:26.512863', NULL, false);
INSERT INTO public.users VALUES ('aabf956a-c6ad-4ccb-a79c-df54fe809792', '97466888872', 'individual', NULL, 'Fahad Salem ', 'فهد بن سالم ', NULL, NULL, NULL, true, '2026-01-11 21:04:53.768729', '2026-01-11 21:04:53.768729', NULL, false);
INSERT INTO public.users VALUES ('4539667a-ef0a-4bbf-97fd-8cc8ee0c996e', '97455025930', 'individual', NULL, 'Hadi', 'هادي', NULL, NULL, NULL, true, '2026-01-12 16:41:05.377899', '2026-01-12 16:41:05.377899', NULL, false);
INSERT INTO public.users VALUES ('15e7c0b8-4099-40e8-bbb5-c6835c7010fa', '97470433335', 'individual', NULL, 'Adnan ABDUL RAHMAN alshaikh ', 'عدنان عبدالرحمن الشيخ ', NULL, NULL, NULL, true, '2025-08-01 23:09:25.285602', '2025-08-01 23:09:25.285602', NULL, false);
INSERT INTO public.users VALUES ('97015ec8-859c-41cf-94dc-e21c5dc975d2', '97466677882', 'individual', NULL, 'Adnan Fekri', 'عدنان فكري', NULL, NULL, NULL, true, '2025-08-16 17:16:59.58446', '2025-08-16 17:16:59.58446', NULL, false);
INSERT INTO public.users VALUES ('8c35d390-0b62-47dc-934d-02201a4e4051', '97430298690', 'business', NULL, 'Ahmedkhater', 'احمد خاطر', '113650', 'Almamwn', 'المأمون ', true, '2025-07-26 11:45:48.245861', '2025-07-26 11:45:48.245861', NULL, false);
INSERT INTO public.users VALUES ('90d9ee2e-4bbb-48e3-98ed-96c372791c53', '97477511960', 'individual', NULL, 'Oussama mebarkia', 'اسامة مباركية ', NULL, NULL, NULL, true, '2025-07-29 13:24:20.830735', '2025-07-29 13:24:20.830735', NULL, false);
INSERT INTO public.users VALUES ('62a144aa-12ba-46ca-a359-f4eef5509af4', '97460041886', 'business', NULL, 'Abo kater', ' ابو خاطر', '345265', 'AQARAT', 'عقارات', true, '2025-07-26 15:11:22.734096', '2025-07-26 15:11:22.734096', NULL, false);
INSERT INTO public.users VALUES ('f896a9a3-43db-495e-b5da-b8128c91aa7e', '97450743728', 'individual', '$2b$10$febshBA6Hyhlo.jbHl42LOz72omK3srVE7NRJ7fM/Nqep39iuBidC', 'Fatma', 'فاطمه', NULL, NULL, NULL, true, '2025-06-16 18:15:57.050351', '2025-06-16 18:15:57.050351', NULL, false);
INSERT INTO public.users VALUES ('1fca63ef-7107-4171-b273-ca1451bba181', '97466306624', 'business', NULL, 'Mohamed Dabour', 'محمد دبور شركه مرسانا ', '49152', 'Marsana', 'شركه مرسانا للوساطه العقاريه ', true, '2025-07-27 11:31:46.267719', '2025-07-27 11:31:46.267719', NULL, false);
INSERT INTO public.users VALUES ('3e3a8d06-0594-4619-a4d7-dd9b6ad4eb9e', '97477899919', 'individual', '$2b$10$f4H03fYUaf.qc3itQUryFOdsi5eLyIRxbKDQzw.C16PXj5cqUS3.O', 'Jassim Mohammed Alkuwari', 'جاسم محمد الكواري', NULL, NULL, NULL, true, '2025-06-28 15:41:09.932463', '2025-06-28 15:41:09.932463', NULL, false);
INSERT INTO public.users VALUES ('cf44d3dd-8724-43ac-9421-a209c743ffff', '97455844463', 'individual', NULL, 'FAYSEL MASOUD', 'فيصل مسعود', NULL, NULL, NULL, true, '2025-09-02 09:18:07.915551', '2025-09-02 09:18:07.915551', NULL, false);
INSERT INTO public.users VALUES ('3ba38b73-9ca7-4eac-abae-4be1d350839d', '97430285392', 'individual', NULL, 'Hassan hashim', 'حسن هاشم ', NULL, NULL, NULL, true, '2025-09-05 00:49:34.929129', '2025-09-05 00:49:34.929129', NULL, false);
INSERT INTO public.users VALUES ('ef3f0df9-5c5a-4c00-b358-535b343a90d1', '97477077808', 'individual', NULL, 'Hamad Rashid Alkaabi', 'حمد راشد الكعبي', NULL, NULL, NULL, true, '2025-08-25 21:23:17.706724', '2025-08-25 21:23:17.706724', NULL, false);
INSERT INTO public.users VALUES ('d94ec90b-8a47-4387-ac35-82789ed8e7b1', '97477772626', 'individual', NULL, 'Abdulrhman Alkaabi ', 'عبدالرحمن حمد الكعبي', NULL, NULL, NULL, true, '2025-08-11 10:03:37.319811', '2025-08-11 10:03:37.319811', NULL, false);
INSERT INTO public.users VALUES ('409d35d1-4f3a-4786-886e-e02857fce76c', '97430166426', 'individual', NULL, 'Amer', 'عامر', NULL, NULL, NULL, true, '2025-09-03 05:06:01.477939', '2025-09-03 05:06:01.477939', NULL, false);
INSERT INTO public.users VALUES ('704cb71e-6d50-4a49-9a73-ea2460b52b99', '97455006683', 'individual', NULL, 'Abdulla Almulla', 'عبدالله الملا', NULL, NULL, NULL, true, '2025-08-17 18:36:20.705275', '2025-08-17 18:36:20.705275', NULL, false);
INSERT INTO public.users VALUES ('77489c44-6f04-4d74-9534-90d2785afa69', '97450731250', 'individual', '$2b$10$3hs96IgsPfkE2UAdjSRSg.yNZGhQtdJIDWxxOqJsCWHQeADOMOvB.', 'Personal account', 'حساب شخصي', NULL, NULL, NULL, true, '2025-06-17 17:52:13.071644', '2025-06-17 17:52:13.071644', NULL, false);
INSERT INTO public.users VALUES ('801ae98c-66a3-40b6-a34b-9192d248636f', '97431222633', 'individual', '$2b$10$jWa0WltmCs0N7ZhQ5lNtCuLQ8r/SuIoi/UFSDRfLbKd9PMUsjp.JW', 'Ibrahim alkuwari', 'ابراهيم الكواري', NULL, NULL, NULL, true, '2025-06-26 11:16:25.034133', '2025-06-26 11:16:25.034133', NULL, false);
INSERT INTO public.users VALUES ('a33d6479-9fa0-4629-9a30-dc76dbd17b6c', '97433375537', 'individual', '$2b$10$NyLGyIvoN5O.bKA096HtkeNocX.xvkqWkY/7J6CesPWbXLIuU5Tb6', 'Jassim Ali AlKuwari', 'جاسم علي الكواري', NULL, NULL, NULL, true, '2025-06-28 11:48:36.345444', '2025-06-28 11:48:36.345444', NULL, false);
INSERT INTO public.users VALUES ('88d803a2-f156-49aa-80a0-a0d6d18c8e5c', '97466900020', 'individual', '$2b$10$vVZONDWoV9dM7BMXgbW/9.y2ydV0hrkGM6hAty75m6.0HQjqg3QfC', 'Abdulrahman ', 'عبدالرحمن سعود', NULL, NULL, NULL, true, '2025-06-28 11:15:50.218519', '2025-06-28 11:15:50.218519', NULL, false);
INSERT INTO public.users VALUES ('3fb32f03-99eb-4cd3-a7ed-9584059f27ea', '97433004050', 'individual', '$2b$10$xHucJk1r0SpHaPuRia9jEuNXsmu5nEHitXFU51NUgW9LVsu6C73F6', 'Hussen alansari', 'حسين الأنصاري ', NULL, NULL, NULL, true, '2025-06-28 11:55:07.478613', '2025-06-28 11:55:07.478613', NULL, false);
INSERT INTO public.users VALUES ('4e704897-0ea8-456b-bd0a-314ce2265486', '97477620011', 'individual', NULL, 'Ahmad numan alattar', 'احمد نعمان العطار ', NULL, NULL, NULL, true, '2025-09-13 02:11:46.322764', '2025-09-13 02:11:46.322764', NULL, false);
INSERT INTO public.users VALUES ('479690a3-da25-4188-bf72-eade4825f30c', '97430133359', 'individual', '$2b$10$rxea0rJ8F.LmYWzItEoLxO93v4MsXuK58CYVpUn8Os43BrfYd20Q2', 'Ambaear', 'امباير ', NULL, NULL, NULL, true, '2025-06-28 11:38:26.226141', '2025-06-28 11:38:26.226141', NULL, false);
INSERT INTO public.users VALUES ('8c82c7df-cac2-478c-8aa9-938e6bfa32d4', '97455525229', 'individual', NULL, 'Jawaher Al Abdulla', 'جواهر العبدالله ', NULL, NULL, NULL, true, '2025-09-15 09:57:35.547105', '2025-09-15 09:57:35.547105', NULL, false);
INSERT INTO public.users VALUES ('896876b6-f72e-4e03-8513-a29066826066', '97466014585', 'individual', '$2b$10$8hUTO7q8EkAspk652FXUKe8yB7Se6asS6nq4fovdQghAqtFmgOGdy', 'Al Abraz', 'الابرز للعقارات', NULL, NULL, NULL, true, '2025-06-29 12:28:18.59829', '2025-06-29 12:28:18.59829', NULL, false);
INSERT INTO public.users VALUES ('22c2e563-b6c7-46a9-93cd-975090546b9c', '97470000354', 'individual', '$2b$10$AWC7lWSR4sI86y.D08XBduHai9neZyTRjz5fWPEiMPyK4I087d.x.', 'Hassan altamimi', 'حسن التميمي ', NULL, NULL, NULL, true, '2025-06-26 20:03:18.998962', '2025-06-26 20:03:18.998962', NULL, false);
INSERT INTO public.users VALUES ('71090023-e221-4ad6-b090-1edb82c6d1ff', '97433738294', 'business', '$2b$10$xhqrZzY4hcAKlwvCZZhmPODqEQvHzYUYjDrwGWeejaiNO0Hq1K0Ha', 'Hazem Abu Sultan ', 'حازم ابو سلطان ', '00090', 'Nelson Park ', 'نيلسون بارك العقاريه ', true, '2025-06-27 08:32:39.130576', '2025-06-27 08:32:39.130576', NULL, false);
INSERT INTO public.users VALUES ('bde66193-e76c-4942-861e-07052fd4e3aa', '97470001512', 'individual', '$2b$10$74TMm.u/aAymO4di.AOfWemOS4cXC8kPoDzbntr3WoG4s49s1Zce.', 'Mahmoud  O A Zourob ', 'محمود عمر احمد زعرب', NULL, NULL, NULL, true, '2025-06-27 09:35:20.457712', '2025-06-27 09:35:20.457712', NULL, false);
INSERT INTO public.users VALUES ('2819f0f0-45dd-43d4-bfe1-2aea4ba54f88', '97450455487', 'individual', '$2b$10$iSHpyldSAZBFxJ8UxDdUO.638EGZddZb2TMze7ecvxWPKRKTNvTHm', 'Mohammed jabor Alnaemi ', 'محمد جبر النعيمي ', NULL, NULL, NULL, true, '2025-06-27 19:17:04.405969', '2025-06-27 19:17:04.405969', NULL, false);
INSERT INTO public.users VALUES ('fd28b463-54b3-47fd-a63c-64823673a97e', '97455455263', 'individual', '$2b$10$VqPc2xNQPIJF44pM5.OZiOcvYrvsEflXmX1DbJlsIuR.T26eQimEq', 'Abo Malek', 'مالك  احمد  محمد ', NULL, NULL, NULL, true, '2025-06-27 23:30:15.013892', '2025-06-27 23:30:15.013892', NULL, false);
INSERT INTO public.users VALUES ('fd6dc08a-fbb5-4bbf-9c5e-7814ce20e2ff', '9746632 1757', 'individual', '$2b$10$Cd9j.SAFgi60SoSSpIDwsOoiEmDcmfds3Md3SAg.pGJwh75G8IFI6', 'SAMI ', 'سامي', NULL, NULL, NULL, true, '2025-06-28 13:13:45.227711', '2025-06-28 13:13:45.227711', NULL, false);
INSERT INTO public.users VALUES ('20929be2-6841-4599-8721-0ddd11682cce', '97466854262', 'individual', '$2b$10$FXPmtjT7/3TQSSWtw9HQLuCx2RKR2paCVK3JkbehqQsAa7wAW0N..', 'Jassim Rashid Al Kuwari', 'جاسم راشد الكواري', NULL, NULL, NULL, true, '2025-06-28 12:21:49.905809', '2025-06-28 12:21:49.905809', NULL, false);
INSERT INTO public.users VALUES ('6f68fd7c-0a10-45b0-8389-5d3e28c88fb9', '97466005999', 'individual', NULL, 'Lolowa abdulla', 'لولوه عبدالله ', NULL, NULL, NULL, true, '2025-09-19 04:13:00.170041', '2025-09-19 04:13:00.170041', NULL, false);
INSERT INTO public.users VALUES ('00008d13-0bba-4508-b679-1fdee2890c14', '97451400102', 'business', NULL, 'Ahmed Ali ahmed', 'احمد على احمد ', '62710', 'Royal link real estate services', 'رويال لينك للخدمات العقاريه', true, '2025-07-31 18:29:47.142043', '2025-07-31 18:29:47.142043', NULL, false);
INSERT INTO public.users VALUES ('04a51066-9a4e-4335-8c32-4298d11100e9', '97466333660', 'individual', '$2b$10$MMSFuOjKXN.xGsYMLCX2yOeU4Gx9/5oUBnBFFwFagegU5Utg8n2E6', 'Maryam Jeham Alkuwari', 'مريم الكواري', NULL, NULL, NULL, true, '2025-06-27 10:01:18.405968', '2025-06-27 10:01:18.405968', NULL, false);
INSERT INTO public.users VALUES ('0780872e-15f7-4077-be2f-dc62a9b503e5', '97430303537', 'individual', NULL, 'Noora alrumaihi ', 'نورة الرميحي', NULL, NULL, NULL, true, '2025-10-11 01:55:47.627511', '2025-10-11 01:55:47.627511', NULL, false);
INSERT INTO public.users VALUES ('c2b9b6ea-c136-4960-a3fa-097c8cead840', '97431070405', 'individual', NULL, 'Al wasata real estate ', 'الوساطة للوساطة العقارية', NULL, NULL, NULL, true, '2025-10-30 15:50:53.508085', '2025-10-30 15:50:53.508085', NULL, false);
INSERT INTO public.users VALUES ('783bd113-f64f-49d5-9fb8-300e3298fc4d', '97474748989', 'business', NULL, 'Abu Omar ', 'ابو عمر ', '23843', 'Future real estate ', 'المستقبل للوساطة العقارية ', true, '2025-11-01 18:33:36.339658', '2025-11-01 18:33:36.339658', NULL, false);
INSERT INTO public.users VALUES ('aaf8f5fc-dca9-40c5-8002-07e8dd448d4e', '97455889479', 'individual', NULL, 'Mashael', 'مشاعل', NULL, NULL, NULL, true, '2025-10-05 15:49:14.294775', '2025-10-05 15:49:14.294775', NULL, false);
INSERT INTO public.users VALUES ('e52d212b-5445-466c-a84d-cff878d9476b', '97477993379', 'individual', '$2b$10$uXTD8fOjQTUQHRsC9b340eyI1yYDhoOYz1bAV.98ajr05lezXnsn.', 'RASHID ALSULAITI', 'راشد محمد السليطي', NULL, NULL, NULL, true, '2025-06-28 12:29:36.916167', '2025-06-28 12:29:36.916167', NULL, false);
INSERT INTO public.users VALUES ('d5a1b393-c8c1-4e27-ac6e-b6eaf2476eef', '97477889990', 'individual', '$2b$10$iLGRpYGlzzbTNRhlhdWc3ubqUou6hrEeLc3oV4M62cIJQh5dzZEOa', 'A', 'ع', NULL, NULL, NULL, true, '2025-06-28 12:41:21.999517', '2025-06-28 12:41:21.999517', NULL, false);
INSERT INTO public.users VALUES ('22d3e355-3245-427c-9267-6988a00e085e', '97451333317', 'individual', '$2b$10$8gElfHpJS8tJGP5PId/zV.FJGT1ZFKrzSmziEmBny/XxcxcXyJ7gm', 'mahmmad ', 'محمد سالم ', NULL, NULL, NULL, true, '2025-06-28 10:17:40.50919', '2025-06-28 10:17:40.50919', NULL, false);
INSERT INTO public.users VALUES ('4efe0eca-87d6-4b93-adf3-35e707a763b9', '97455236613', 'individual', '$2b$10$yzpjPZqS3RZawWxzFNRdvuOgpdHtpyXO0cr5ehwsf2pjQItnGJf9m', 'Umessa ', 'ام عيسى ', NULL, NULL, NULL, true, '2025-06-28 16:25:02.482768', '2025-06-28 16:25:02.482768', NULL, false);
INSERT INTO public.users VALUES ('ef57aadd-48fd-41e0-8661-6cb410069ceb', '97433666012', 'individual', '$2b$10$uL5IO/SfjxNVlrQQS3cf7.ZYUEjvxcZmkh53606iCpOjr3CGb//vm', 'Mohamed Mahmoud ', 'محمد محمود', NULL, NULL, NULL, true, '2025-06-28 15:06:04.333229', '2025-06-28 15:06:04.333229', NULL, false);
INSERT INTO public.users VALUES ('9e217434-2dce-4177-9a3b-7a9b4ecf0828', '97455836500', 'individual', '$2b$10$F4TiK1dup7MrstndAS/TMeGql3Gg0ZWmX/Y08GzzLUEcDnY1suCvi', 'Fatma', 'فاطمه الزياره', NULL, NULL, NULL, true, '2025-06-28 16:32:59.089695', '2025-06-28 16:32:59.089695', NULL, false);
INSERT INTO public.users VALUES ('b2e65cb3-d00b-43c6-91c7-4b37766b4a39', '97455525342', 'individual', '$2b$10$d8bYL2G3x00eVjDxL9DBPenOmnabxsTpiPZWL8v9yoj7QCwsivv8i', 'Ahmed Al Emadi', 'أحمد العمادي ', NULL, NULL, NULL, true, '2025-06-28 16:59:38.006357', '2025-06-28 16:59:38.006357', NULL, false);
INSERT INTO public.users VALUES ('de0072b5-690b-4e67-b250-dd4f178e4144', '97455859510', 'individual', '$2b$10$sovgC99ePmHqDCpNO6YSR.cMkH4BqY0pgt4Z.Wiq3SoDRTmIgwFU.', 'Muntasir Ali', 'منتصر علي', NULL, NULL, NULL, true, '2025-06-29 01:07:40.153048', '2025-06-29 01:07:40.153048', NULL, false);
INSERT INTO public.users VALUES ('7469a120-e9ca-400d-b5c4-723ee6c261a9', '97455199922', 'individual', '$2b$10$temDq3oCKb9/h3h/97V4ieOW2P421s8fGRKFph6KHsEOKtrVjVORe', 'Mohammed ALSahli ', 'محمد السهلي', NULL, NULL, NULL, true, '2025-06-29 05:33:39.329773', '2025-06-29 05:33:39.329773', NULL, false);
INSERT INTO public.users VALUES ('dad5668f-8804-494f-9d7d-3358a200a06a', '97455878887', 'individual', '$2b$10$g6pBMWZPm2Ps4RKpIO7pIuVldsDh74wPuZa9v1lTnUvbE5cKtt2oy', 'ALi Mohammed ALSaadi ', 'علي محمد الســـــعدي ', NULL, NULL, NULL, true, '2025-06-29 09:17:31.690894', '2025-06-29 09:17:31.690894', NULL, false);
INSERT INTO public.users VALUES ('53241b5b-ad7c-490b-9ac4-5d25cfbf6546', '97455519207', 'individual', '$2b$10$BFJHk/cJffqOyx48eNOsruEirXjBhEtXPeGnEGITTqJ6Haykm1nHW', 'Ali H Alemadi', 'علي العمادي', NULL, NULL, NULL, true, '2025-06-29 11:00:47.835273', '2025-06-29 11:00:47.835273', NULL, false);
INSERT INTO public.users VALUES ('b92d4573-ff59-4f73-a3fd-a77ba354644e', '97455550901', 'individual', '$2b$10$uc/a0Vyd/0OE2HcwOIRqWe9hzivwvMP3zdCAyiOaocMt0M/qAnozG', 'Salem Mubarak ALMOSALLAM ', 'سالم مبارك المسلم', NULL, NULL, NULL, true, '2025-06-29 00:41:53.019107', '2025-06-29 00:41:53.019107', NULL, false);
INSERT INTO public.users VALUES ('e8a265c9-4c27-46b2-a5c9-a492d3b0e8e1', '97433028280', 'individual', '$2b$10$MFZO.JulVd6WaUR46uPlSeJBRzgAbE1e47TkwogQeGhYUjDFZ.rD6', 'Mohammed', 'محمد ', NULL, NULL, NULL, true, '2025-06-29 01:29:20.24356', '2025-06-29 01:29:20.24356', NULL, false);
INSERT INTO public.users VALUES ('623b7832-d1cf-46f5-8147-dcd3850e401f', '97455144332', 'business', '$2b$10$Q8ReDPA9IK/i8dS9GTTZuuyfjyWxQRJDQ9eVYodLyK6Z05hpKz4Ou', 'Edinburgh real estate ', 'أدينبرة للعقارات', '19696', 'Edinburgh real estate ', 'أدينبرة للعقارات', true, '2025-06-29 11:44:07.794698', '2025-06-29 11:44:07.794698', NULL, false);
INSERT INTO public.users VALUES ('f5002ca7-cefd-46b9-9897-a99512b09969', '97451516111', 'individual', '$2b$10$6qOtqt2kU5V6lubOvd01cO6vjJPVJsl1nCVCu86eAkQEiOXTniByC', 'Faisal M Alqahtani', 'فيصل مطلق القحطاني', NULL, NULL, NULL, true, '2025-06-29 10:48:33.898506', '2025-06-29 10:48:33.898506', NULL, false);
INSERT INTO public.users VALUES ('3dfb9c67-3567-41d9-8f67-5ac7d83adc20', '97470177289', 'business', '$2b$10$IGU9EN9lQJYCo4GF48926edUKZrQj/snQAP6bDWJNCDHiq3M.h4Iy', 'Tawheed real estat ', 'التوحيد للعقارات ', '70478', 'Tawheed real estat', 'التوحيد للعقارات ', true, '2025-06-28 21:04:16.911855', '2025-06-28 21:04:16.911855', NULL, false);
INSERT INTO public.users VALUES ('4e7f67da-06c8-41be-b7c9-0dfbb8f4a800', '97433115539', 'individual', '$2b$10$jM7IV2AD18R/7QxK2GA/RuweV0r8LPB1dgJuOCqmihK3AHhInRGD.', 'Ahmad Alkuwari ', 'احمد الكواري', NULL, NULL, NULL, true, '2025-06-29 13:15:21.496376', '2025-06-29 13:15:21.496376', NULL, false);
INSERT INTO public.users VALUES ('c8e83ebc-91ce-45c8-9429-111284110e19', '97466800538', 'individual', '$2b$10$IkZiCVFYrVIUCTWLbxhKpOwGeHPT77PouLy4sOWUxiKhKrTqPuMWi', 'Mohammed saad alghanim', 'محمد سعد الغانم', NULL, NULL, NULL, true, '2025-06-30 02:59:07.133582', '2025-06-30 02:59:07.133582', NULL, false);
INSERT INTO public.users VALUES ('577a2f88-a4b5-4e31-9c2d-38db3f8dff93', '97455354488', 'individual', '$2b$10$DON9pBfFgOkEeBXI3gF39ewGGNyaUjxVhNkMLO/QKtRjWP7UYLtv.', 'Jaber ALKUWARI ', 'جابر الكواري ', NULL, NULL, NULL, true, '2025-07-02 15:29:45.013491', '2025-07-02 15:29:45.013491', NULL, false);
INSERT INTO public.users VALUES ('5361ff5c-a289-4efb-865e-bd720ebf71c3', '97466174008', 'business', '$2b$10$7jz.cTehateWzPAZoqaYIeDWBxNHvU9W8xzZjESIkTj7Gc7Bwae.y', 'AlFahd Real Estate Services', 'شركة الفهد للخدمات العقارية ', '185604', 'AlFahd Real Estate Services', 'شركة الفهد للخدمات العقارية ', true, '2025-07-05 04:43:04.561538', '2025-07-05 04:43:04.561538', NULL, false);
INSERT INTO public.users VALUES ('05072fcb-1a78-4ec6-bb1e-807deed7328b', '97466532220', 'individual', '$2b$10$kM4LUsVpE6UAvbLymDtBKePBGc3XW7XgMMMmkxl80su30DZNoGhc2', 'Moza k ', 'موزة الغانم', NULL, NULL, NULL, true, '2025-06-30 20:09:49.743537', '2025-06-30 20:09:49.743537', NULL, false);
INSERT INTO public.users VALUES ('79125d80-1341-41be-8c3b-d2876faa4bf0', '97466677722', 'individual', '$2b$10$/HBmp1g3YvbFkaYQwlWN4euUMM/zSKjJMPKMTZ5sEUXZac/YI4y3a', 'Abdulla Ahmad AlBinali', 'عبدالله احمد البنعلي ', NULL, NULL, NULL, true, '2025-07-03 10:10:01.640548', '2025-07-03 10:10:01.640548', NULL, false);
INSERT INTO public.users VALUES ('0ab49dc3-6bf7-452f-8bb0-0f13d32583b5', '97470770006', 'individual', '$2b$10$wQk/xiBrzMK7QcF2VYJPnesybJuepJ4gFfkR5EMIo6iO/X657/.lO', 'Jawaher ', 'جواهر', NULL, NULL, NULL, true, '2025-07-05 20:46:30.811503', '2025-07-05 20:46:30.811503', NULL, false);
INSERT INTO public.users VALUES ('b35fe95c-50c6-48bc-917f-15fdb22f9251', '97455557405', 'individual', '$2b$10$5XMZJemxAx8nkERTYq0kZevpPB10YvDq7tmzOa2PP.DIcCITukb7m', 'Rashed alkaabi', 'راشد الكعبي', NULL, NULL, NULL, true, '2025-07-03 15:29:27.422731', '2025-07-03 15:29:27.422731', NULL, false);
INSERT INTO public.users VALUES ('c3e9bc71-53a6-49f4-8dde-3819c025f52a', '97433223255', 'individual', '$2b$10$hUhYhuGLS5YiDkcNJSyaQOqXXNPKU100jQBlv5AgWn6stXZ41VpyO', 'Ibrahim Jassim Ibrahim AlBangith AlKuwari', 'ابراهيم جاسم ابراهيم البنغيث الكواري', NULL, NULL, NULL, true, '2025-07-03 16:49:55.443335', '2025-07-03 16:49:55.443335', NULL, false);
INSERT INTO public.users VALUES ('3444da7d-2a47-46fc-bfa8-305f1f1cd0f5', '97433245000', 'individual', '$2b$10$GhPenFngL7WJI0yixP/wrep.fTAnoi2bil49seeEY2zHR6yALhPVa', 'Fadel Mohamed ', 'فضل محمد ', NULL, NULL, NULL, true, '2025-07-04 08:51:12.042854', '2025-07-04 08:51:12.042854', NULL, false);
INSERT INTO public.users VALUES ('f8e40090-869b-47dc-94ec-f1e2a13a9781', '97433443644', 'individual', '$2b$10$r8ksWVGZaaM/ka0NBru3t.XdIXP8uV1OcrYzQjBmGnHKyaQ66jcz6', 'Ibrahim saleh alkhalaf', 'إبراهيم صالح الخلف ', NULL, NULL, NULL, true, '2025-07-04 16:35:22.932623', '2025-07-04 16:35:22.932623', NULL, false);
INSERT INTO public.users VALUES ('0b84d6dd-a098-4d39-a6e5-e1dc95b64c0c', '97430239000', 'business', NULL, 'Eltawhid Real Estate ', 'شركه التوحيد للعقارات ', '42550', 'Eltawhid Real Estate ', 'شركه التوحيد للعقارات ', true, '2025-07-08 01:07:51.488788', '2025-07-08 01:07:51.488788', NULL, false);
INSERT INTO public.users VALUES ('ffb9f47f-1211-45aa-83fb-b80fc95f641b', '97466306668', 'business', NULL, 'Ahmed alshataf', 'احمد الشطف ', '38838', 'Hamdan Real Estate ', 'همدان للوساطة العقارية ', true, '2025-07-08 02:33:26.869098', '2025-07-08 02:33:26.869098', NULL, false);
INSERT INTO public.users VALUES ('a2a4af59-a57c-4707-90b9-ccc96c3fc375', '97455532848', 'individual', '$2b$10$8QGZG9PN7pbvGZhNqAc1tOgrjmhGSvuBkXka0he8i6zxD7flg1PsC', 'Saeed Alkuwari', 'سعيد الكواري', NULL, NULL, NULL, true, '2025-07-02 02:54:24.307787', '2025-07-02 02:54:24.307787', NULL, false);
INSERT INTO public.users VALUES ('56b75a8b-cdbd-4a83-886f-0ea82b211d94', '97459905959', 'individual', '$2b$10$xRL4Cs.PMam6mpcM8Y.9fOXlAXouGSwshGE9f.x/yfkRkNX.DtYgS', 'Noora', 'نوره', NULL, NULL, NULL, true, '2025-06-30 17:07:38.573199', '2025-06-30 17:07:38.573199', NULL, false);
INSERT INTO public.users VALUES ('3e52dcb2-56f3-40c5-abe6-e8635d66b747', '97466271860', 'individual', NULL, 'Noor مقداد', 'نور محمد', NULL, NULL, NULL, true, '2025-08-01 12:30:28.953529', '2025-08-01 12:30:28.953529', NULL, false);
INSERT INTO public.users VALUES ('639a1ec9-f683-4984-b899-35b02184e458', '97433412444', 'individual', NULL, 'Maryam', 'مريم', NULL, NULL, NULL, true, '2025-08-07 13:13:04.668731', '2025-08-07 13:13:04.668731', NULL, false);
INSERT INTO public.users VALUES ('d0880d45-abd0-4ea5-b261-424165c53e68', '97477901126', 'individual', NULL, 'Aitizaz Arbab', 'اعتزاز ارباب', NULL, NULL, NULL, true, '2025-07-08 05:58:39.226023', '2025-07-08 05:58:39.226023', NULL, false);
INSERT INTO public.users VALUES ('424acb9c-f664-4787-848c-7f5feae62600', '97466777446', 'individual', NULL, 'Khalifa mohammed alsowaidi', 'خليفه محمد السويدي', NULL, NULL, NULL, true, '2025-08-03 03:52:48.467298', '2025-08-03 03:52:48.467298', NULL, false);
INSERT INTO public.users VALUES ('0c6662c0-34de-4bf7-94ae-7b3d716616b1', '97433037738', 'individual', NULL, 'Tony', 'طوني', NULL, NULL, NULL, true, '2025-07-22 11:17:28.273714', '2025-07-22 11:17:28.273714', NULL, false);
INSERT INTO public.users VALUES ('02189a7c-48a4-4636-8c4e-c2b0400b4148', '97470358928', 'individual', NULL, 'Muhammad ', 'محمد', NULL, NULL, NULL, true, '2026-01-14 23:27:53.38166', '2026-01-14 23:27:53.38166', NULL, false);
INSERT INTO public.users VALUES ('24800bb4-d6ef-4589-85c4-50461d24f3ef', '97466999080', 'individual', NULL, 'Saeed', 'سعيد راشد النعيمي', NULL, NULL, NULL, true, '2025-07-26 13:02:00.153056', '2025-07-26 13:02:00.153056', NULL, false);
INSERT INTO public.users VALUES ('f660dd0b-f66c-406a-a688-e30374396930', '97433736861', 'business', NULL, 'elsayed mohamed essa khater', 'السيد محمد عيسي خاطر', '24502', 'bin mohsmed', 'بن محمد', true, '2025-07-26 16:09:29.942805', '2025-07-26 16:09:29.942805', NULL, false);
INSERT INTO public.users VALUES ('aebc34d1-314e-4a4a-99f7-dba29d312993', '97466911499', 'individual', NULL, 'Omer', 'عمر صالح ', NULL, NULL, NULL, true, '2025-08-11 13:53:52.788883', '2025-08-11 13:53:52.788883', NULL, false);
INSERT INTO public.users VALUES ('6246c26b-f7e6-4ab3-add1-b47ad7a3e780', '97470608887', 'individual', NULL, 'Rouwaid jabbar', 'رويد الجبار ', NULL, NULL, NULL, true, '2025-07-26 05:06:34.069123', '2025-07-26 05:06:34.069123', NULL, false);
INSERT INTO public.users VALUES ('f16ca49e-bdb5-476b-a41c-609a768712da', '97455855494', 'individual', NULL, 'Khalid Mohammed Majed alkuwari', 'خالد محمد الكواري', NULL, NULL, NULL, true, '2025-08-17 01:41:14.470172', '2025-08-17 01:41:14.470172', NULL, false);
INSERT INTO public.users VALUES ('3cea39f6-61b2-441b-81e4-ddc26681fb51', '97470280828', 'individual', NULL, 'Yacoub AlYacoub', 'يعقوب اليعقوب', NULL, NULL, NULL, true, '2025-08-20 04:08:02.196501', '2025-08-20 04:08:02.196501', NULL, false);
INSERT INTO public.users VALUES ('6189477a-3da4-4848-8e82-73b886cf7220', '97433331995', 'individual', NULL, 'Fatma hassan', 'فاطمه حسن', NULL, NULL, NULL, true, '2025-09-14 10:49:14.997753', '2025-09-14 10:49:14.997753', NULL, false);
INSERT INTO public.users VALUES ('4c1bb78f-d6ea-4efd-ab64-713fffa06f65', '97466119966', 'individual', NULL, 'Nasser', 'ناصر', NULL, NULL, NULL, true, '2025-11-12 23:24:34.957076', '2025-11-12 23:24:34.957076', NULL, false);
INSERT INTO public.users VALUES ('79c3350c-32cc-4fdf-832a-d8922e5341e3', '97466777761', 'individual', NULL, 'Yousef Alfakhroo ', 'يوسف ابراهيم الفخرو', NULL, NULL, NULL, true, '2025-10-27 05:50:08.208495', '2025-10-27 05:50:08.208495', NULL, false);
INSERT INTO public.users VALUES ('3a1f8c9e-9616-4358-ae66-8ab68fe7e67d', '97455553575', 'individual', NULL, 'A j ', 'ص جك ', NULL, NULL, NULL, true, '2025-08-26 17:23:27.211536', '2025-08-26 17:23:27.211536', NULL, false);
INSERT INTO public.users VALUES ('4a66d5ab-3165-455b-a364-5125ca32d370', '97450135015', 'individual', NULL, 'Mahmoud Hashem ', 'محمود هاشم ', NULL, NULL, NULL, true, '2025-09-16 16:11:13.260462', '2025-09-16 16:11:13.260462', NULL, false);
INSERT INTO public.users VALUES ('d143a3e6-1660-4d5e-bec3-9e4aaaf17dbc', '97430696668', 'business', NULL, 'Catalyst Technology and Services ', 'كاتاليست تكنولوجي اند سيرفيسز ', '276948', 'Catalyst Technology and Services ', 'كاتاليست تكنولوجي اند سيرفيسز ', true, '2025-08-27 21:37:04.426389', '2025-08-27 21:37:04.426389', NULL, false);
INSERT INTO public.users VALUES ('97867041-9d12-489d-8d22-18ef95644dc2', '97466617039', 'individual', NULL, 'Faisal Al Shamari', 'فيصل الشمري ', NULL, NULL, NULL, true, '2025-08-31 09:30:29.645386', '2025-08-31 09:30:29.645386', NULL, false);
INSERT INTO public.users VALUES ('167eb49e-8be0-4ad7-b425-70290b294c35', '97471770100', 'individual', NULL, 'Abdulrahman alhafiz', 'عبدالرحمن عماد الحافظ', NULL, NULL, NULL, true, '2025-08-26 00:19:23.73108', '2025-08-26 00:19:23.73108', NULL, false);
INSERT INTO public.users VALUES ('573e130f-af93-4c27-b46c-8931295ed5e0', '97455424617', 'individual', NULL, 'Ahmad Taha', 'أحمد طه', NULL, NULL, NULL, true, '2025-11-13 07:42:38.6474', '2025-11-13 07:42:38.6474', NULL, false);
INSERT INTO public.users VALUES ('c8afe2c6-c384-4af4-aff7-714f4100bea2', '97477277292', 'individual', NULL, 'Mohamed Akram Zaidan', 'محمد أكرم زيدان', NULL, NULL, NULL, true, '2025-09-19 09:41:03.412162', '2025-09-19 09:41:03.412162', NULL, false);
INSERT INTO public.users VALUES ('a6ac6c51-f18d-4d5b-ad55-bc621162dd65', '97433279898', 'business', NULL, 'Moustafa youssef Dandan', 'مصطفى يوسف دندن', '103011', 'Ariane Properties', 'اريان للاصول ', true, '2025-09-15 11:47:03.339574', '2025-09-15 11:47:03.339574', NULL, false);
INSERT INTO public.users VALUES ('fc100b83-b290-406b-b401-2496e791a0a3', '97477075382', 'individual', NULL, 'Khaled ababneh', 'خالد عبابنه', NULL, NULL, NULL, true, '2025-11-02 14:31:58.035702', '2025-11-02 14:31:58.035702', NULL, false);
INSERT INTO public.users VALUES ('55db8085-c65d-4620-8a53-d4563e0f1df7', '97430808060', 'individual', NULL, 'Alshamari ', 'تميم  ', NULL, NULL, NULL, true, '2025-09-29 19:58:56.729915', '2025-09-29 19:58:56.729915', NULL, false);
INSERT INTO public.users VALUES ('4b718a25-266a-4980-bc25-5c9a2bb69368', '97455061606', 'individual', NULL, 'Bandar Abdullah AlRaeissi', 'بندر عبدالله الرئيسي', NULL, NULL, NULL, true, '2025-09-07 05:36:57.098638', '2025-09-07 05:36:57.098638', NULL, false);
INSERT INTO public.users VALUES ('e8b3ce15-6f83-4ce4-b3cc-bdfbfebe9cdc', '97477770812', 'individual', NULL, 'Fahad', 'فهد', NULL, NULL, NULL, true, '2026-01-12 01:13:57.226317', '2026-01-12 01:13:57.226317', NULL, false);
INSERT INTO public.users VALUES ('bb42f73f-787d-45cf-b9f9-d1b678736de3', '97466887546', 'individual', NULL, 'Mohamed agha Katerjy', 'محمدآغا ', NULL, NULL, NULL, true, '2025-11-11 16:58:11.337709', '2025-11-11 16:58:11.337709', NULL, false);
INSERT INTO public.users VALUES ('cd26b5bd-bbdb-47de-91a1-79dd877dca54', '97431239122', 'individual', NULL, 'Houssam Guessoum ', 'حسام قسوم ', NULL, NULL, NULL, true, '2025-11-11 03:36:49.360451', '2025-11-11 03:36:49.360451', NULL, false);
INSERT INTO public.users VALUES ('ec5813c9-19fe-42a9-a10f-5d0749120e19', '97459999940', 'individual', NULL, 'Mohammed', 'محمد', NULL, NULL, NULL, true, '2025-11-12 02:53:28.485338', '2025-11-12 02:53:28.485338', NULL, false);
INSERT INTO public.users VALUES ('5b903b88-44bc-44e4-a78d-7c04507fb4c0', '97477771209', 'individual', NULL, 'Abdulla Alkuwari', 'عبدالله الكواري ', NULL, NULL, NULL, true, '2025-11-21 07:36:50.506232', '2025-11-21 07:36:50.506232', NULL, false);
INSERT INTO public.users VALUES ('d084c5a3-a64e-4c61-a359-d7a8d3433bec', '97455503483', 'individual', NULL, 'Abdulla Alromaihi', 'عبدالله الرميحي', NULL, NULL, NULL, true, '2025-11-12 20:51:36.121989', '2025-11-12 20:51:36.121989', NULL, false);
INSERT INTO public.users VALUES ('3d16df30-a24a-4894-a8eb-afef8fcd3cbc', '97433333776', 'individual', '$2b$10$IOx83uf9MKTeTVnlzkmr6e7deQIkoEzII.ER/VZtzhUclV0ZdKYZO', 'Ibrahim Alkuwari ', 'ابراهيم الكواري', NULL, NULL, NULL, true, '2025-06-25 23:26:15.037599', '2025-06-25 23:26:15.037599', NULL, false);
INSERT INTO public.users VALUES ('21c74c71-acb5-484c-96ba-fa9eb14b3af7', '97433233239', 'individual', NULL, 'Abdulla adnan zainal', 'عبدالله عدنان زينل ', NULL, NULL, NULL, true, '2025-10-11 11:35:52.329359', '2025-10-11 11:35:52.329359', NULL, false);
INSERT INTO public.users VALUES ('01302322-812a-44e9-929d-89865c77cd77', '97455553975', 'individual', NULL, 'Mohamed', 'محمد', NULL, NULL, NULL, true, '2025-12-13 15:56:22.638793', '2025-12-13 15:56:22.638793', NULL, false);
INSERT INTO public.users VALUES ('c39d7df4-4abb-4f74-8d95-b9311f628611', '97470091092', 'business', '$2b$10$o/DE02l0iJhYVIURHC/Eke38NSSmZOXeK6Jak7WeBnl01.S0z47lC', 'Mostafa mahdi', 'مصطفى مهدى', '257975', 'HAMMAT REAL STATE', 'هامات', true, '2025-06-28 12:45:30.433921', '2025-06-28 12:45:30.433921', NULL, false);
INSERT INTO public.users VALUES ('ef919000-6ec3-460a-99af-6f7febf7d64d', '97455005484', 'individual', NULL, 'Sareea', 'خالد الشهواني', NULL, NULL, NULL, true, '2026-01-11 19:21:08.405792', '2026-01-11 19:21:08.405792', NULL, false);
INSERT INTO public.users VALUES ('bed0ae7e-c4c3-4af6-863a-de42eca3481d', '97477704171', 'individual', NULL, 'Ahmad Saada', 'احمد ', NULL, NULL, NULL, true, '2026-01-16 14:04:20.477631', '2026-01-16 14:04:20.477631', NULL, false);
INSERT INTO public.users VALUES ('731a5aff-a956-462f-80a4-6b2b74c0d239', '97450505200', 'individual', NULL, 'Ameena almulla', 'امينه الملا', NULL, NULL, NULL, true, '2026-01-18 05:23:01.331155', '2026-01-18 05:23:01.331155', NULL, false);
INSERT INTO public.users VALUES ('895a4ae5-40a1-4f00-a018-2c382a77f2a0', '97466514800', 'individual', NULL, 'Saber Mbarek', 'صابر مبارك', NULL, NULL, NULL, true, '2026-01-31 14:49:06.220492', '2026-01-31 14:49:06.220492', NULL, false);
INSERT INTO public.users VALUES ('69e1435f-cb72-41e2-8495-9a648264c81d', '97466127770', 'business', NULL, 'Wasem', 'وسم', '131378', 'Wasem Real Estate ', 'وسم للوساطه العقارية ', true, '2026-01-30 21:06:06.097199', '2026-01-30 21:06:06.097199', NULL, false);
INSERT INTO public.users VALUES ('59586c56-803e-4a73-b28e-5cd75f81b9f2', '97433835133', 'individual', NULL, 'Meteb Alkubaisi', 'متعب الكبيسي', NULL, NULL, NULL, true, '2026-02-03 09:28:30.518223', '2026-02-03 09:28:30.518223', NULL, false);
INSERT INTO public.users VALUES ('2dec2ac2-c2cc-4a89-8608-28b45803d7f3', '97470792706', 'individual', NULL, 'nadir Boumrar', 'ندير بومرار', NULL, NULL, NULL, true, '2026-02-03 13:24:39.829783', '2026-02-03 13:24:39.829783', NULL, false);
INSERT INTO public.users VALUES ('aa8df086-34f4-4a4d-8573-5ddb5ea6978a', '97450003067', 'individual', NULL, 'Umm thamer', 'ام ثامر ', NULL, NULL, NULL, true, '2026-02-03 09:41:44.718866', '2026-02-03 09:41:44.718866', NULL, false);
INSERT INTO public.users VALUES ('658ba3e3-2dca-4a35-b82e-7c7ddde13295', '97466057399', 'individual', NULL, 'Saba Ahmed', 'سبأ احمد ', NULL, NULL, NULL, true, '2026-02-07 20:08:08.336705', '2026-02-07 20:08:08.336705', NULL, false);
INSERT INTO public.users VALUES ('768c34be-cf26-4b96-b679-e0134452a9a7', '97455600224', 'individual', NULL, 'Mohamed Saad', 'محمد سعد ', NULL, NULL, NULL, true, '2026-02-08 10:28:56.774563', '2026-02-08 10:28:56.774563', NULL, false);
INSERT INTO public.users VALUES ('ef3c139c-4f13-45b8-9e84-bedafc783b2b', '97431120031', 'individual', NULL, 'Samir Saqer ', 'سمير صقر', NULL, NULL, NULL, true, '2026-02-07 23:30:20.033835', '2026-02-07 23:30:20.033835', NULL, false);
INSERT INTO public.users VALUES ('cf17a3dd-9c8e-451f-ba28-80694a1d546b', '97430343404', 'individual', NULL, 'Noura Al-Kuwari', 'نوره الكواري ', NULL, NULL, NULL, true, '2026-02-13 17:33:39.446641', '2026-02-13 17:33:39.446641', NULL, false);
INSERT INTO public.users VALUES ('806b2aba-4d90-4a2c-b438-99634dc9f028', '97466667844', 'individual', NULL, 'Khalid Ali Alahbabi', 'خالد علي الأحبابي', NULL, NULL, NULL, true, '2026-02-22 09:45:41.98661', '2026-02-22 09:45:41.98661', NULL, false);
INSERT INTO public.users VALUES ('7160f7bb-a60a-49b1-a188-629b7303a667', '97466676597', 'individual', NULL, 'Ahmad Alkuwari ', 'احمد الكواري', NULL, NULL, NULL, true, '2026-02-25 08:24:58.927802', '2026-02-25 08:24:58.927802', NULL, false);
INSERT INTO public.users VALUES ('bd6a512d-9630-4887-a653-67aa37e9e857', '97466607699', 'individual', NULL, 'Hhunn', 'تبنذ', NULL, NULL, NULL, true, '2026-03-07 09:35:38.396639', '2026-03-07 09:35:38.396639', NULL, false);
INSERT INTO public.users VALUES ('adf6fa6c-f507-47e4-a080-cb13cb648c19', '97433303223', 'individual', NULL, 'mohamed', 'محمد', NULL, NULL, NULL, true, '2026-03-19 21:54:56.170541', '2026-03-19 21:54:56.170541', NULL, false);
INSERT INTO public.users VALUES ('80f2c372-4bd2-4812-8a81-c7e665c32a49', '97450044666', 'business', NULL, 'Rashed alkaabi', 'راشد الكعبي', '148370', 'Rakovsky real estate', 'راكوفسكي العقاريه', true, '2026-04-08 11:21:14.716625', '2026-04-08 11:21:14.716625', NULL, false);
INSERT INTO public.users VALUES ('3d5b5034-a6d7-4531-af1c-89a24c8b25ff', '97471022075', 'individual', NULL, 'amine hussein', 'امين الحسين', NULL, NULL, NULL, false, '2026-05-03 10:45:04.857901', '2026-05-03 10:45:04.857901', NULL, false);


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


