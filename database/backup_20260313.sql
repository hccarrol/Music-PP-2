--
-- PostgreSQL database dump
--

\restrict arB7rKIKuyB1o4gxUwESCRu7bI34qveDvoeUvJ41pFSvGcenVINesOK2mFvODEY

-- Dumped from database version 16.13
-- Dumped by pg_dump version 16.13

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
-- Name: ratings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ratings (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    sequence_id uuid NOT NULL,
    rating smallint NOT NULL,
    notes text,
    listen_duration numeric(6,2),
    rated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT ratings_rating_check CHECK (((rating >= 1) AND (rating <= 5)))
);


ALTER TABLE public.ratings OWNER TO postgres;

--
-- Name: sequences; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sequences (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    filename character varying(255) NOT NULL,
    file_path text NOT NULL,
    key_signature character varying(3) NOT NULL,
    scale character varying(30) NOT NULL,
    tempo integer NOT NULL,
    time_sig_num smallint NOT NULL,
    time_sig_den smallint NOT NULL,
    num_bars smallint NOT NULL,
    octave_low smallint NOT NULL,
    octave_high smallint NOT NULL,
    rhythm_pattern character varying(30) NOT NULL,
    duration_variety character varying(10) NOT NULL,
    rest_probability numeric(4,3) NOT NULL,
    instrument smallint DEFAULT 0 NOT NULL,
    velocity_variation boolean DEFAULT true NOT NULL,
    note_count integer,
    duration_seconds numeric(8,2),
    pitch_histogram integer[],
    config_json jsonb NOT NULL,
    stats_json jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT sequences_num_bars_check CHECK (((num_bars >= 4) AND (num_bars <= 16))),
    CONSTRAINT sequences_tempo_check CHECK (((tempo >= 40) AND (tempo <= 300)))
);


ALTER TABLE public.sequences OWNER TO postgres;

--
-- Data for Name: ratings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ratings (id, sequence_id, rating, notes, listen_duration, rated_at) FROM stdin;
a2439aee-5e2f-45b7-8f8b-2c4e712d0922	51d073f7-9385-4ab9-a7c7-001d4723b6f2	2		2.91	2026-03-13 15:39:43.434314+00
08118844-bf80-4326-a3d5-dc2cb6f9f1be	3a142449-0918-43a1-a08e-56f81b4e4c51	3		13.26	2026-03-13 15:45:31.8403+00
e4ada7a0-9894-403f-be09-b9ef556b9292	9e6965a7-1760-4c96-955d-99423765786d	3		12.07	2026-03-13 15:45:47.279911+00
83260dc9-c98d-4425-8a25-86c5ab91ebdf	12de7e71-6663-4d33-b3c1-67221c6635db	2		12.07	2026-03-13 15:46:00.950901+00
4f12e8bf-49c7-4c2c-a9d2-cf0400cc9e14	4de00df1-714b-4471-ac1a-e67f70810e26	2		8.03	2026-03-13 15:46:10.084508+00
1e77caf9-afe6-416a-88e5-999fcbe144bb	89a164de-9873-4c68-a988-3a467aca3a5c	1		28.04	2026-03-13 15:46:39.209836+00
c9ba6f13-e6e5-49f4-9a08-c77fe972be5d	2c3b7a63-14ee-4ffc-9d47-e7da686d699e	2		23.90	2026-03-13 15:47:03.978241+00
1c36a9bb-d689-4e43-b620-31762c754630	0a8c3a65-58ec-4124-93ff-5360ebd18b95	1		13.13	2026-03-13 15:47:18.004617+00
543fe53d-8c9e-44ff-aa29-b7c43a9d5e93	6dc2f893-d7ad-4b7f-8590-5571c852a422	1		16.53	2026-03-13 15:47:35.486737+00
b26010d2-c6ad-491f-a74f-97f799428fd2	2dbaf8e4-9a84-4395-b34e-0a391fdf6edf	1		15.64	2026-03-13 15:48:32.829226+00
f3162d7b-f17d-4767-8462-8f57856d93d3	3e933588-49df-4351-ae10-d49643ce7c9f	1		27.39	2026-03-13 15:50:36.596715+00
51653087-bfe9-441e-add7-3e1c87d7eb3f	c2308eed-2e20-441f-83ad-40be74fff16f	3		23.28	2026-03-13 15:51:00.825349+00
cfd34377-a3e5-4248-ac44-fe52463c57f8	20ccef1d-3ac6-4b09-80f7-c338702d8901	2		19.97	2026-03-13 15:51:21.861051+00
1c1696e8-f4b1-4eeb-9ac5-bb1311cbd26b	b5ffd572-0e0c-466f-84e8-daaad108723f	2		14.10	2026-03-13 15:52:42.680462+00
46379c94-0b9c-44db-824f-106bb53388cd	b23b030b-eddd-4eed-ae18-4cf08ce3cb43	1		16.67	2026-03-13 15:53:00.379062+00
7f5d0e67-ff24-4e42-8fbf-633c45b2e30d	4a815517-855a-410a-94fe-2807335ed4de	1		25.73	2026-03-13 15:53:26.905999+00
f93549d3-def3-4773-a6c7-5c3fecd2094c	1392856d-986a-4fcb-b2c1-c7e9dcbc6fff	4		16.66	2026-03-13 15:53:44.746183+00
ae2797db-8502-4cc2-bf1f-43d17ddd661c	da971862-2500-46d2-989e-825b974b4c4f	3		23.43	2026-03-13 15:54:09.143275+00
1e4853b7-0f90-4a75-be8e-adc02f43f3c3	0d059910-94cb-4aaa-96ac-dedf083fe8d9	3		14.52	2026-03-13 15:56:06.472345+00
401262ef-63e9-4e08-ae38-e977e3910adb	8fc35079-f856-4a77-bcf3-48b9eed356c4	2		41.53	2026-03-13 15:56:48.848717+00
84f983ea-bcfa-4eb8-85c5-d6f31dea2d0a	35a056a6-fd17-4bf0-9071-654b65acf563	1		18.43	2026-03-13 15:57:08.117391+00
5f28cb28-ed68-449c-b21a-51ec9aa79b6f	dcd11f23-0e27-4076-877d-955ee7de7a69	1		19.11	2026-03-13 15:57:27.936131+00
7649f77e-bbf2-40e0-bea1-32818479e332	0e75fc19-5f8a-4be8-99f0-8d45de719ad8	1		6.03	2026-03-13 15:58:12.157015+00
2a7df4c3-9323-463f-896d-2e6c54173611	8407f937-10fd-45c9-9664-614a53f2d031	3		22.28	2026-03-13 15:58:35.527439+00
ba4e9f44-4e99-4ee3-8047-169795f2b609	d89060ba-cf93-48fb-bca5-3d22e60a8f10	1		25.62	2026-03-13 15:59:02.340442+00
1f603f0f-d6c1-4364-ab45-61ab94579fdd	1c1e0fbd-6d6f-435f-ba92-0238b245e5b5	4		8.44	2026-03-13 15:59:11.662106+00
23c36012-075a-4716-8796-71d251631e0a	095cad67-7752-4f98-a9dc-95d26138a562	4		9.35	2026-03-13 15:59:21.87575+00
ba80a31c-6383-416f-802b-865b69244df5	9c813d19-b066-401a-a478-6fb42c186721	2		11.72	2026-03-13 15:59:34.451549+00
8ce3c482-fcc4-4a2b-a78e-9d7b63078110	bfd130ec-e8e2-48e5-bde6-21145c1607c2	1		46.91	2026-03-13 16:00:22.830159+00
a18a8ea5-69b8-4528-90ac-1d5d36592799	16552e5d-6e78-4c40-a42e-978684383501	3		3.30	2026-03-13 16:01:38.971355+00
a23fdbcd-d2f1-4c07-8eab-d41e330f0b26	071f9301-56f9-42c3-ba7d-48371c7ee8e1	2		16.75	2026-03-13 16:01:56.513884+00
e45ed3b3-7671-435e-a37f-39dcc8f5725a	8594ec48-3c49-4452-b418-db254e4c048d	2		21.58	2026-03-13 16:02:18.904346+00
ad327ca8-b47b-4443-ad1d-9786c4632621	39052153-7f30-492b-a9de-5f92cf718926	3		22.99	2026-03-13 16:02:42.681423+00
75e77311-5e92-4721-8193-6745b4c04102	2277d156-72c6-4a3c-8ca2-aeef22a15299	2		11.90	2026-03-13 16:02:57.023663+00
1034f02c-27b3-4fc8-b5d2-5f21be6a4a2a	e6e01a5f-5b39-4c79-b61d-948b3c224204	2		21.18	2026-03-13 16:03:19.089835+00
a37bf3cf-1013-40c1-9c84-a806c1b03d3f	f42c7786-e3f3-4738-af1d-208d4cb1687c	1		31.50	2026-03-13 16:03:51.389221+00
6ae37216-8f94-4c05-96e9-eeac72b0baa3	31741eb0-a4e6-4e0a-846f-f09a9653add1	1		28.78	2026-03-13 16:04:20.894024+00
077bb98e-bca3-430c-8446-74e278ba0cd2	5d3513ef-8bc0-4afc-abdd-1d6176cd141a	1		21.51	2026-03-13 16:04:43.154954+00
27801e17-b21e-4a1c-8289-4d4ce167dc15	f73d6399-0f63-451a-99a0-e8662cc08bf3	1		16.13	2026-03-13 16:05:00.040582+00
eb048af6-49bf-4279-9fcd-1ae8053cec67	03bc0013-cbe5-460c-a76a-b92776196154	3		9.89	2026-03-13 16:05:10.686535+00
aa1efc64-4a6e-4b5e-9a1b-82668fa89175	87aefd21-45ed-4177-bba3-2577b6ee0e0f	4		16.05	2026-03-13 16:05:27.697438+00
f5974f36-b199-403e-9432-5a9618ea4354	e93a9018-3d21-49d9-9e10-6e06532c92a9	2		12.87	2026-03-13 16:05:41.468867+00
af52ff58-5505-40c2-934b-2f820f8f78be	b6f1dd6b-d6cf-49cf-9870-7fc08eac12be	3		21.00	2026-03-13 16:06:03.273493+00
1939ac6e-809e-4f73-81f6-0083969aa760	4bcdebd9-88f2-47d6-8e78-123e8a61c44d	2		13.14	2026-03-13 16:07:43.196326+00
6709e18d-accf-44d9-aef7-45fa6ef08df2	b80b1644-db79-4afe-a6c4-9eca344f450e	3		13.39	2026-03-13 16:07:57.34734+00
08ac62ff-34b3-4cc4-9722-40f2dcb19b17	d2dc1af0-6d60-40b4-812b-5dff7f8f8bb3	4		21.55	2026-03-13 16:08:19.677961+00
d5493e8c-0999-492f-8f70-2f67aaae877f	87d310eb-0542-46a4-b965-34c83961f1e5	1		5.00	2026-03-13 16:08:25.331825+00
211af340-dcec-494c-b6ab-095c30173a2a	f8fee211-4112-4add-af2d-9404828c0948	1		12.20	2026-03-13 16:08:38.307296+00
c23597a0-52b6-4e75-8ff7-f957ab1b523c	d7907af7-b246-4fe6-abd4-bab5b0738f81	1		11.91	2026-03-13 16:08:50.967584+00
b944c0ab-d110-44a1-a6b5-095c1a088368	851c2e9d-3490-47b8-917d-f4931aea6cb4	3		9.55	2026-03-13 16:09:01.26274+00
\.


--
-- Data for Name: sequences; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sequences (id, filename, file_path, key_signature, scale, tempo, time_sig_num, time_sig_den, num_bars, octave_low, octave_high, rhythm_pattern, duration_variety, rest_probability, instrument, velocity_variation, note_count, duration_seconds, pitch_histogram, config_json, stats_json, created_at, updated_at) FROM stdin;
851c2e9d-3490-47b8-917d-f4931aea6cb4	851c2e9d-3490-47b8-917d-f4931aea6cb4.mid	/app/sequences/851c2e9d-3490-47b8-917d-f4931aea6cb4.mid	Db	blues	148	3	4	8	3	6	waltz	low	0.230	12	f	19	9.73	{0,4,0,0,8,0,1,4,2,0,0,0}	{"key": "Db", "scale": "blues", "tempo": 148, "num_bars": 8, "instrument": 12, "octave_range": [3, 6], "rhythm_pattern": "waltz", "rest_probability": 0.23, "time_signature_den": 4, "time_signature_num": 3, "velocity_variation": false, "note_duration_variety": "low"}	{"note_count": 19, "pitch_histogram": [0, 4, 0, 0, 8, 0, 1, 4, 2, 0, 0, 0], "duration_seconds": 9.73, "scale_notes_used": [49, 52, 54, 55, 56, 59, 61, 64, 66, 67, 68, 71, 73, 76, 78, 79, 80, 83, 85, 88, 90, 91, 92, 95]}	2026-03-13 15:39:35.260263+00	2026-03-13 15:39:35.260263+00
d7907af7-b246-4fe6-abd4-bab5b0738f81	d7907af7-b246-4fe6-abd4-bab5b0738f81.mid	/app/sequences/d7907af7-b246-4fe6-abd4-bab5b0738f81.mid	Gb	pentatonic_major	68	4	4	8	3	6	swing	high	0.130	40	f	28	28.24	{0,5,0,7,0,0,5,0,7,0,4,0}	{"key": "Gb", "scale": "pentatonic_major", "tempo": 68, "num_bars": 8, "instrument": 40, "octave_range": [3, 6], "rhythm_pattern": "swing", "rest_probability": 0.13, "time_signature_den": 4, "time_signature_num": 4, "velocity_variation": false, "note_duration_variety": "high"}	{"note_count": 28, "pitch_histogram": [0, 5, 0, 7, 0, 0, 5, 0, 7, 0, 4, 0], "duration_seconds": 28.24, "scale_notes_used": [54, 56, 58, 61, 63, 66, 68, 70, 73, 75, 78, 80, 82, 85, 87, 90, 92, 94, 97, 99]}	2026-03-13 15:39:35.268191+00	2026-03-13 15:39:35.268191+00
f8fee211-4112-4add-af2d-9404828c0948	f8fee211-4112-4add-af2d-9404828c0948.mid	/app/sequences/f8fee211-4112-4add-af2d-9404828c0948.mid	F	blues	86	4	4	12	4	6	syncopated	medium	0.240	12	t	39	33.49	{3,0,0,7,0,6,0,0,9,0,6,8}	{"key": "F", "scale": "blues", "tempo": 86, "num_bars": 12, "instrument": 12, "octave_range": [4, 6], "rhythm_pattern": "syncopated", "rest_probability": 0.24, "time_signature_den": 4, "time_signature_num": 4, "velocity_variation": true, "note_duration_variety": "medium"}	{"note_count": 39, "pitch_histogram": [3, 0, 0, 7, 0, 6, 0, 0, 9, 0, 6, 8], "duration_seconds": 33.49, "scale_notes_used": [65, 68, 70, 71, 72, 75, 77, 80, 82, 83, 84, 87, 89, 92, 94, 95, 96, 99]}	2026-03-13 15:39:35.270915+00	2026-03-13 15:39:35.270915+00
87d310eb-0542-46a4-b965-34c83961f1e5	87d310eb-0542-46a4-b965-34c83961f1e5.mid	/app/sequences/87d310eb-0542-46a4-b965-34c83961f1e5.mid	A	minor	113	6	4	8	3	6	swing	low	0.150	24	t	35	25.49	{5,0,3,0,10,5,0,6,0,2,0,4}	{"key": "A", "scale": "minor", "tempo": 113, "num_bars": 8, "instrument": 24, "octave_range": [3, 6], "rhythm_pattern": "swing", "rest_probability": 0.15, "time_signature_den": 4, "time_signature_num": 6, "velocity_variation": true, "note_duration_variety": "low"}	{"note_count": 35, "pitch_histogram": [5, 0, 3, 0, 10, 5, 0, 6, 0, 2, 0, 4], "duration_seconds": 25.49, "scale_notes_used": [57, 59, 60, 62, 64, 65, 67, 69, 71, 72, 74, 76, 77, 79, 81, 83, 84, 86, 88, 89, 91, 93, 95, 96, 98, 100, 101, 103]}	2026-03-13 15:39:35.273764+00	2026-03-13 15:39:35.273764+00
d2dc1af0-6d60-40b4-812b-5dff7f8f8bb3	d2dc1af0-6d60-40b4-812b-5dff7f8f8bb3.mid	/app/sequences/d2dc1af0-6d60-40b4-812b-5dff7f8f8bb3.mid	Gb	mixolydian	136	4	4	12	4	6	straight	low	0.240	24	f	30	21.18	{0,8,0,0,6,0,5,0,5,0,3,3}	{"key": "Gb", "scale": "mixolydian", "tempo": 136, "num_bars": 12, "instrument": 24, "octave_range": [4, 6], "rhythm_pattern": "straight", "rest_probability": 0.24, "time_signature_den": 4, "time_signature_num": 4, "velocity_variation": false, "note_duration_variety": "low"}	{"note_count": 30, "pitch_histogram": [0, 8, 0, 0, 6, 0, 5, 0, 5, 0, 3, 3], "duration_seconds": 21.18, "scale_notes_used": [66, 68, 70, 71, 73, 75, 76, 78, 80, 82, 83, 85, 87, 88, 90, 92, 94, 95, 97, 99, 100]}	2026-03-13 15:39:35.276712+00	2026-03-13 15:39:35.276712+00
b80b1644-db79-4afe-a6c4-9eca344f450e	b80b1644-db79-4afe-a6c4-9eca344f450e.mid	/app/sequences/b80b1644-db79-4afe-a6c4-9eca344f450e.mid	Db	blues	96	4	4	12	4	6	swing	low	0.090	19	f	45	30.00	{0,4,0,0,11,0,8,7,8,0,0,7}	{"key": "Db", "scale": "blues", "tempo": 96, "num_bars": 12, "instrument": 19, "octave_range": [4, 6], "rhythm_pattern": "swing", "rest_probability": 0.09, "time_signature_den": 4, "time_signature_num": 4, "velocity_variation": false, "note_duration_variety": "low"}	{"note_count": 45, "pitch_histogram": [0, 4, 0, 0, 11, 0, 8, 7, 8, 0, 0, 7], "duration_seconds": 30.0, "scale_notes_used": [61, 64, 66, 67, 68, 71, 73, 76, 78, 79, 80, 83, 85, 88, 90, 91, 92, 95]}	2026-03-13 15:39:35.280085+00	2026-03-13 15:39:35.280085+00
5d3513ef-8bc0-4afc-abdd-1d6176cd141a	5d3513ef-8bc0-4afc-abdd-1d6176cd141a.mid	/app/sequences/5d3513ef-8bc0-4afc-abdd-1d6176cd141a.mid	A#	pentatonic_major	120	4	4	8	3	5	waltz	high	0.200	24	f	30	16.00	{6,0,7,0,0,5,0,8,0,0,4,0}	{"key": "A#", "scale": "pentatonic_major", "tempo": 120, "num_bars": 8, "instrument": 24, "octave_range": [3, 5], "rhythm_pattern": "waltz", "rest_probability": 0.2, "time_signature_den": 4, "time_signature_num": 4, "velocity_variation": false, "note_duration_variety": "high"}	{"note_count": 30, "pitch_histogram": [6, 0, 7, 0, 0, 5, 0, 8, 0, 0, 4, 0], "duration_seconds": 16.0, "scale_notes_used": [58, 60, 62, 65, 67, 70, 72, 74, 77, 79, 82, 84, 86, 89, 91]}	2026-03-13 15:39:47.770599+00	2026-03-13 15:39:47.770599+00
4bcdebd9-88f2-47d6-8e78-123e8a61c44d	4bcdebd9-88f2-47d6-8e78-123e8a61c44d.mid	/app/sequences/4bcdebd9-88f2-47d6-8e78-123e8a61c44d.mid	G	minor	146	4	4	8	4	6	syncopated	low	0.120	48	f	25	13.15	{2,0,5,1,0,2,0,3,0,5,7,0}	{"key": "G", "scale": "minor", "tempo": 146, "num_bars": 8, "instrument": 48, "octave_range": [4, 6], "rhythm_pattern": "syncopated", "rest_probability": 0.12, "time_signature_den": 4, "time_signature_num": 4, "velocity_variation": false, "note_duration_variety": "low"}	{"note_count": 25, "pitch_histogram": [2, 0, 5, 1, 0, 2, 0, 3, 0, 5, 7, 0], "duration_seconds": 13.15, "scale_notes_used": [67, 69, 70, 72, 74, 75, 77, 79, 81, 82, 84, 86, 87, 89, 91, 93, 94, 96, 98, 99, 101]}	2026-03-13 15:39:35.282269+00	2026-03-13 15:39:35.282269+00
b6f1dd6b-d6cf-49cf-9870-7fc08eac12be	b6f1dd6b-d6cf-49cf-9870-7fc08eac12be.mid	/app/sequences/b6f1dd6b-d6cf-49cf-9870-7fc08eac12be.mid	F#	pentatonic_major	136	6	4	8	3	5	mixed	medium	0.140	0	f	48	21.18	{0,3,0,13,0,0,12,0,10,0,10,0}	{"key": "F#", "scale": "pentatonic_major", "tempo": 136, "num_bars": 8, "instrument": 0, "octave_range": [3, 5], "rhythm_pattern": "mixed", "rest_probability": 0.14, "time_signature_den": 4, "time_signature_num": 6, "velocity_variation": false, "note_duration_variety": "medium"}	{"note_count": 48, "pitch_histogram": [0, 3, 0, 13, 0, 0, 12, 0, 10, 0, 10, 0], "duration_seconds": 21.18, "scale_notes_used": [54, 56, 58, 61, 63, 66, 68, 70, 73, 75, 78, 80, 82, 85, 87]}	2026-03-13 15:39:35.28636+00	2026-03-13 15:39:35.28636+00
e93a9018-3d21-49d9-9e10-6e06532c92a9	e93a9018-3d21-49d9-9e10-6e06532c92a9.mid	/app/sequences/e93a9018-3d21-49d9-9e10-6e06532c92a9.mid	Ab	minor	94	4	4	8	3	6	dotted	low	0.230	48	t	19	20.43	{0,2,0,3,2,0,4,0,5,0,2,1}	{"key": "Ab", "scale": "minor", "tempo": 94, "num_bars": 8, "instrument": 48, "octave_range": [3, 6], "rhythm_pattern": "dotted", "rest_probability": 0.23, "time_signature_den": 4, "time_signature_num": 4, "velocity_variation": true, "note_duration_variety": "low"}	{"note_count": 19, "pitch_histogram": [0, 2, 0, 3, 2, 0, 4, 0, 5, 0, 2, 1], "duration_seconds": 20.43, "scale_notes_used": [56, 58, 59, 61, 63, 64, 66, 68, 70, 71, 73, 75, 76, 78, 80, 82, 83, 85, 87, 88, 90, 92, 94, 95, 97, 99, 100, 102]}	2026-03-13 15:39:35.289495+00	2026-03-13 15:39:35.289495+00
51d073f7-9385-4ab9-a7c7-001d4723b6f2	51d073f7-9385-4ab9-a7c7-001d4723b6f2.mid	/app/sequences/51d073f7-9385-4ab9-a7c7-001d4723b6f2.mid	Db	pentatonic_major	148	4	4	4	4	5	syncopated	medium	0.090	25	f	20	6.49	{0,4,0,4,0,2,0,0,7,0,3,0}	{"key": "Db", "scale": "pentatonic_major", "tempo": 148, "num_bars": 4, "instrument": 25, "octave_range": [4, 5], "rhythm_pattern": "syncopated", "rest_probability": 0.09, "time_signature_den": 4, "time_signature_num": 4, "velocity_variation": false, "note_duration_variety": "medium"}	{"note_count": 20, "pitch_histogram": [0, 4, 0, 4, 0, 2, 0, 0, 7, 0, 3, 0], "duration_seconds": 6.49, "scale_notes_used": [61, 63, 65, 68, 70, 73, 75, 77, 80, 82]}	2026-03-13 15:39:35.291378+00	2026-03-13 15:39:35.291378+00
87aefd21-45ed-4177-bba3-2577b6ee0e0f	87aefd21-45ed-4177-bba3-2577b6ee0e0f.mid	/app/sequences/87aefd21-45ed-4177-bba3-2577b6ee0e0f.mid	Db	minor	123	4	4	8	4	5	mixed	low	0.130	48	t	24	15.61	{0,3,0,3,4,0,1,0,6,5,0,2}	{"key": "Db", "scale": "minor", "tempo": 123, "num_bars": 8, "instrument": 48, "octave_range": [4, 5], "rhythm_pattern": "mixed", "rest_probability": 0.13, "time_signature_den": 4, "time_signature_num": 4, "velocity_variation": true, "note_duration_variety": "low"}	{"note_count": 24, "pitch_histogram": [0, 3, 0, 3, 4, 0, 1, 0, 6, 5, 0, 2], "duration_seconds": 15.61, "scale_notes_used": [61, 63, 64, 66, 68, 69, 71, 73, 75, 76, 78, 80, 81, 83]}	2026-03-13 15:39:47.760021+00	2026-03-13 15:39:47.760021+00
03bc0013-cbe5-460c-a76a-b92776196154	03bc0013-cbe5-460c-a76a-b92776196154.mid	/app/sequences/03bc0013-cbe5-460c-a76a-b92776196154.mid	C#	blues	99	4	4	12	4	5	mixed	low	0.190	12	t	33	29.09	{0,0,0,0,7,0,8,6,6,0,0,6}	{"key": "C#", "scale": "blues", "tempo": 99, "num_bars": 12, "instrument": 12, "octave_range": [4, 5], "rhythm_pattern": "mixed", "rest_probability": 0.19, "time_signature_den": 4, "time_signature_num": 4, "velocity_variation": true, "note_duration_variety": "low"}	{"note_count": 33, "pitch_histogram": [0, 0, 0, 0, 7, 0, 8, 6, 6, 0, 0, 6], "duration_seconds": 29.09, "scale_notes_used": [61, 64, 66, 67, 68, 71, 73, 76, 78, 79, 80, 83]}	2026-03-13 15:39:47.766043+00	2026-03-13 15:39:47.766043+00
f73d6399-0f63-451a-99a0-e8662cc08bf3	f73d6399-0f63-451a-99a0-e8662cc08bf3.mid	/app/sequences/f73d6399-0f63-451a-99a0-e8662cc08bf3.mid	Gb	blues	86	4	4	4	4	5	triplet	medium	0.050	73	f	13	11.16	{4,2,0,0,0,0,2,0,0,2,0,3}	{"key": "Gb", "scale": "blues", "tempo": 86, "num_bars": 4, "instrument": 73, "octave_range": [4, 5], "rhythm_pattern": "triplet", "rest_probability": 0.05, "time_signature_den": 4, "time_signature_num": 4, "velocity_variation": false, "note_duration_variety": "medium"}	{"note_count": 13, "pitch_histogram": [4, 2, 0, 0, 0, 0, 2, 0, 0, 2, 0, 3], "duration_seconds": 11.16, "scale_notes_used": [66, 69, 71, 72, 73, 76, 78, 81, 83, 84, 85, 88]}	2026-03-13 15:39:47.76828+00	2026-03-13 15:39:47.76828+00
31741eb0-a4e6-4e0a-846f-f09a9653add1	31741eb0-a4e6-4e0a-846f-f09a9653add1.mid	/app/sequences/31741eb0-a4e6-4e0a-846f-f09a9653add1.mid	Db	mixolydian	110	4	4	12	3	6	waltz	low	0.130	48	t	41	26.18	{0,5,0,11,0,4,6,0,5,0,5,5}	{"key": "Db", "scale": "mixolydian", "tempo": 110, "num_bars": 12, "instrument": 48, "octave_range": [3, 6], "rhythm_pattern": "waltz", "rest_probability": 0.13, "time_signature_den": 4, "time_signature_num": 4, "velocity_variation": true, "note_duration_variety": "low"}	{"note_count": 41, "pitch_histogram": [0, 5, 0, 11, 0, 4, 6, 0, 5, 0, 5, 5], "duration_seconds": 26.18, "scale_notes_used": [49, 51, 53, 54, 56, 58, 59, 61, 63, 65, 66, 68, 70, 71, 73, 75, 77, 78, 80, 82, 83, 85, 87, 89, 90, 92, 94, 95]}	2026-03-13 15:39:47.77655+00	2026-03-13 15:39:47.77655+00
f42c7786-e3f3-4738-af1d-208d4cb1687c	f42c7786-e3f3-4738-af1d-208d4cb1687c.mid	/app/sequences/f42c7786-e3f3-4738-af1d-208d4cb1687c.mid	D#	minor	139	3	4	16	3	6	triplet	low	0.080	4	t	36	20.72	{0,8,0,1,0,7,4,0,5,0,5,6}	{"key": "D#", "scale": "minor", "tempo": 139, "num_bars": 16, "instrument": 4, "octave_range": [3, 6], "rhythm_pattern": "triplet", "rest_probability": 0.08, "time_signature_den": 4, "time_signature_num": 3, "velocity_variation": true, "note_duration_variety": "low"}	{"note_count": 36, "pitch_histogram": [0, 8, 0, 1, 0, 7, 4, 0, 5, 0, 5, 6], "duration_seconds": 20.72, "scale_notes_used": [51, 53, 54, 56, 58, 59, 61, 63, 65, 66, 68, 70, 71, 73, 75, 77, 78, 80, 82, 83, 85, 87, 89, 90, 92, 94, 95, 97]}	2026-03-13 15:39:47.778693+00	2026-03-13 15:39:47.778693+00
e6e01a5f-5b39-4c79-b61d-948b3c224204	e6e01a5f-5b39-4c79-b61d-948b3c224204.mid	/app/sequences/e6e01a5f-5b39-4c79-b61d-948b3c224204.mid	D#	minor	78	3	4	8	4	6	mixed	low	0.150	25	t	21	18.46	{0,2,0,6,0,1,0,0,5,0,4,3}	{"key": "D#", "scale": "minor", "tempo": 78, "num_bars": 8, "instrument": 25, "octave_range": [4, 6], "rhythm_pattern": "mixed", "rest_probability": 0.15, "time_signature_den": 4, "time_signature_num": 3, "velocity_variation": true, "note_duration_variety": "low"}	{"note_count": 21, "pitch_histogram": [0, 2, 0, 6, 0, 1, 0, 0, 5, 0, 4, 3], "duration_seconds": 18.46, "scale_notes_used": [63, 65, 66, 68, 70, 71, 73, 75, 77, 78, 80, 82, 83, 85, 87, 89, 90, 92, 94, 95, 97]}	2026-03-13 15:39:47.780693+00	2026-03-13 15:39:47.780693+00
2277d156-72c6-4a3c-8ca2-aeef22a15299	2277d156-72c6-4a3c-8ca2-aeef22a15299.mid	/app/sequences/2277d156-72c6-4a3c-8ca2-aeef22a15299.mid	C	mixolydian	103	4	4	8	4	6	mixed	high	0.120	40	t	27	18.64	{1,0,3,0,4,1,0,7,0,4,7,0}	{"key": "C", "scale": "mixolydian", "tempo": 103, "num_bars": 8, "instrument": 40, "octave_range": [4, 6], "rhythm_pattern": "mixed", "rest_probability": 0.12, "time_signature_den": 4, "time_signature_num": 4, "velocity_variation": true, "note_duration_variety": "high"}	{"note_count": 27, "pitch_histogram": [1, 0, 3, 0, 4, 1, 0, 7, 0, 4, 7, 0], "duration_seconds": 18.64, "scale_notes_used": [60, 62, 64, 65, 67, 69, 70, 72, 74, 76, 77, 79, 81, 82, 84, 86, 88, 89, 91, 93, 94]}	2026-03-13 15:39:47.782813+00	2026-03-13 15:39:47.782813+00
39052153-7f30-492b-a9de-5f92cf718926	39052153-7f30-492b-a9de-5f92cf718926.mid	/app/sequences/39052153-7f30-492b-a9de-5f92cf718926.mid	G	pentatonic_major	148	4	4	12	4	5	swing	low	0.160	25	f	36	19.46	{0,0,9,0,7,0,0,9,0,5,0,6}	{"key": "G", "scale": "pentatonic_major", "tempo": 148, "num_bars": 12, "instrument": 25, "octave_range": [4, 5], "rhythm_pattern": "swing", "rest_probability": 0.16, "time_signature_den": 4, "time_signature_num": 4, "velocity_variation": false, "note_duration_variety": "low"}	{"note_count": 36, "pitch_histogram": [0, 0, 9, 0, 7, 0, 0, 9, 0, 5, 0, 6], "duration_seconds": 19.46, "scale_notes_used": [67, 69, 71, 74, 76, 79, 81, 83, 86, 88]}	2026-03-13 15:39:47.784818+00	2026-03-13 15:39:47.784818+00
8594ec48-3c49-4452-b418-db254e4c048d	8594ec48-3c49-4452-b418-db254e4c048d.mid	/app/sequences/8594ec48-3c49-4452-b418-db254e4c048d.mid	C#	pentatonic_minor	95	4	4	12	3	6	syncopated	low	0.090	4	f	33	30.32	{0,6,0,0,6,0,7,0,3,0,0,11}	{"key": "C#", "scale": "pentatonic_minor", "tempo": 95, "num_bars": 12, "instrument": 4, "octave_range": [3, 6], "rhythm_pattern": "syncopated", "rest_probability": 0.09, "time_signature_den": 4, "time_signature_num": 4, "velocity_variation": false, "note_duration_variety": "low"}	{"note_count": 33, "pitch_histogram": [0, 6, 0, 0, 6, 0, 7, 0, 3, 0, 0, 11], "duration_seconds": 30.32, "scale_notes_used": [49, 52, 54, 56, 59, 61, 64, 66, 68, 71, 73, 76, 78, 80, 83, 85, 88, 90, 92, 95]}	2026-03-13 15:39:47.787198+00	2026-03-13 15:39:47.787198+00
da971862-2500-46d2-989e-825b974b4c4f	da971862-2500-46d2-989e-825b974b4c4f.mid	/app/sequences/da971862-2500-46d2-989e-825b974b4c4f.mid	F	pentatonic_minor	149	6	4	4	4	5	waltz	medium	0.070	73	t	18	9.66	{4,0,0,2,0,5,0,0,3,0,4,0}	{"key": "F", "scale": "pentatonic_minor", "tempo": 149, "num_bars": 4, "instrument": 73, "octave_range": [4, 5], "rhythm_pattern": "waltz", "rest_probability": 0.07, "time_signature_den": 4, "time_signature_num": 6, "velocity_variation": true, "note_duration_variety": "medium"}	{"note_count": 18, "pitch_histogram": [4, 0, 0, 2, 0, 5, 0, 0, 3, 0, 4, 0], "duration_seconds": 9.66, "scale_notes_used": [65, 68, 70, 72, 75, 77, 80, 82, 84, 87]}	2026-03-13 15:44:43.480751+00	2026-03-13 15:44:43.480751+00
071f9301-56f9-42c3-ba7d-48371c7ee8e1	071f9301-56f9-42c3-ba7d-48371c7ee8e1.mid	/app/sequences/071f9301-56f9-42c3-ba7d-48371c7ee8e1.mid	D#	major	165	3	4	12	3	5	waltz	high	0.080	40	f	42	13.09	{8,0,3,5,0,5,0,7,8,0,6,0}	{"key": "D#", "scale": "major", "tempo": 165, "num_bars": 12, "instrument": 40, "octave_range": [3, 5], "rhythm_pattern": "waltz", "rest_probability": 0.08, "time_signature_den": 4, "time_signature_num": 3, "velocity_variation": false, "note_duration_variety": "high"}	{"note_count": 42, "pitch_histogram": [8, 0, 3, 5, 0, 5, 0, 7, 8, 0, 6, 0], "duration_seconds": 13.09, "scale_notes_used": [51, 53, 55, 56, 58, 60, 62, 63, 65, 67, 68, 70, 72, 74, 75, 77, 79, 80, 82, 84, 86]}	2026-03-13 15:44:42.63925+00	2026-03-13 15:44:42.63925+00
16552e5d-6e78-4c40-a42e-978684383501	16552e5d-6e78-4c40-a42e-978684383501.mid	/app/sequences/16552e5d-6e78-4c40-a42e-978684383501.mid	C	minor	122	3	4	12	4	6	straight	medium	0.070	12	f	34	17.70	{6,0,4,6,0,7,0,5,3,0,3,0}	{"key": "C", "scale": "minor", "tempo": 122, "num_bars": 12, "instrument": 12, "octave_range": [4, 6], "rhythm_pattern": "straight", "rest_probability": 0.07, "time_signature_den": 4, "time_signature_num": 3, "velocity_variation": false, "note_duration_variety": "medium"}	{"note_count": 34, "pitch_histogram": [6, 0, 4, 6, 0, 7, 0, 5, 3, 0, 3, 0], "duration_seconds": 17.7, "scale_notes_used": [60, 62, 63, 65, 67, 68, 70, 72, 74, 75, 77, 79, 80, 82, 84, 86, 87, 89, 91, 92, 94]}	2026-03-13 15:44:42.646999+00	2026-03-13 15:44:42.646999+00
bfd130ec-e8e2-48e5-bde6-21145c1607c2	bfd130ec-e8e2-48e5-bde6-21145c1607c2.mid	/app/sequences/bfd130ec-e8e2-48e5-bde6-21145c1607c2.mid	B	blues	66	6	4	16	3	6	dotted	high	0.060	0	f	91	87.27	{0,0,10,0,18,17,12,0,0,18,0,16}	{"key": "B", "scale": "blues", "tempo": 66, "num_bars": 16, "instrument": 0, "octave_range": [3, 6], "rhythm_pattern": "dotted", "rest_probability": 0.06, "time_signature_den": 4, "time_signature_num": 6, "velocity_variation": false, "note_duration_variety": "high"}	{"note_count": 91, "pitch_histogram": [0, 0, 10, 0, 18, 17, 12, 0, 0, 18, 0, 16], "duration_seconds": 87.27, "scale_notes_used": [59, 62, 64, 65, 66, 69, 71, 74, 76, 77, 78, 81, 83, 86, 88, 89, 90, 93, 95, 98, 100, 101, 102, 105]}	2026-03-13 15:44:42.651435+00	2026-03-13 15:44:42.651435+00
9c813d19-b066-401a-a478-6fb42c186721	9c813d19-b066-401a-a478-6fb42c186721.mid	/app/sequences/9c813d19-b066-401a-a478-6fb42c186721.mid	F	blues	68	4	4	4	3	6	triplet	low	0.060	24	t	13	14.12	{2,0,0,2,0,3,0,0,1,0,3,2}	{"key": "F", "scale": "blues", "tempo": 68, "num_bars": 4, "instrument": 24, "octave_range": [3, 6], "rhythm_pattern": "triplet", "rest_probability": 0.06, "time_signature_den": 4, "time_signature_num": 4, "velocity_variation": true, "note_duration_variety": "low"}	{"note_count": 13, "pitch_histogram": [2, 0, 0, 2, 0, 3, 0, 0, 1, 0, 3, 2], "duration_seconds": 14.12, "scale_notes_used": [53, 56, 58, 59, 60, 63, 65, 68, 70, 71, 72, 75, 77, 80, 82, 83, 84, 87, 89, 92, 94, 95, 96, 99]}	2026-03-13 15:44:42.653405+00	2026-03-13 15:44:42.653405+00
095cad67-7752-4f98-a9dc-95d26138a562	095cad67-7752-4f98-a9dc-95d26138a562.mid	/app/sequences/095cad67-7752-4f98-a9dc-95d26138a562.mid	Eb	major	119	3	4	4	3	5	triplet	low	0.100	25	f	12	6.05	{0,0,3,2,0,0,0,2,3,0,2,0}	{"key": "Eb", "scale": "major", "tempo": 119, "num_bars": 4, "instrument": 25, "octave_range": [3, 5], "rhythm_pattern": "triplet", "rest_probability": 0.1, "time_signature_den": 4, "time_signature_num": 3, "velocity_variation": false, "note_duration_variety": "low"}	{"note_count": 12, "pitch_histogram": [0, 0, 3, 2, 0, 0, 0, 2, 3, 0, 2, 0], "duration_seconds": 6.05, "scale_notes_used": [51, 53, 55, 56, 58, 60, 62, 63, 65, 67, 68, 70, 72, 74, 75, 77, 79, 80, 82, 84, 86]}	2026-03-13 15:44:42.654662+00	2026-03-13 15:44:42.654662+00
1c1e0fbd-6d6f-435f-ba92-0238b245e5b5	1c1e0fbd-6d6f-435f-ba92-0238b245e5b5.mid	/app/sequences/1c1e0fbd-6d6f-435f-ba92-0238b245e5b5.mid	E	pentatonic_major	135	4	4	4	3	6	syncopated	medium	0.210	25	t	17	7.11	{0,2,0,0,4,0,2,0,6,0,0,3}	{"key": "E", "scale": "pentatonic_major", "tempo": 135, "num_bars": 4, "instrument": 25, "octave_range": [3, 6], "rhythm_pattern": "syncopated", "rest_probability": 0.21, "time_signature_den": 4, "time_signature_num": 4, "velocity_variation": true, "note_duration_variety": "medium"}	{"note_count": 17, "pitch_histogram": [0, 2, 0, 0, 4, 0, 2, 0, 6, 0, 0, 3], "duration_seconds": 7.11, "scale_notes_used": [52, 54, 56, 59, 61, 64, 66, 68, 71, 73, 76, 78, 80, 83, 85, 88, 90, 92, 95, 97]}	2026-03-13 15:44:42.656056+00	2026-03-13 15:44:42.656056+00
d89060ba-cf93-48fb-bca5-3d22e60a8f10	d89060ba-cf93-48fb-bca5-3d22e60a8f10.mid	/app/sequences/d89060ba-cf93-48fb-bca5-3d22e60a8f10.mid	F	dorian	127	4	4	12	3	6	swing	high	0.130	73	t	57	22.68	{10,0,6,4,0,7,0,16,6,0,8,0}	{"key": "F", "scale": "dorian", "tempo": 127, "num_bars": 12, "instrument": 73, "octave_range": [3, 6], "rhythm_pattern": "swing", "rest_probability": 0.13, "time_signature_den": 4, "time_signature_num": 4, "velocity_variation": true, "note_duration_variety": "high"}	{"note_count": 57, "pitch_histogram": [10, 0, 6, 4, 0, 7, 0, 16, 6, 0, 8, 0], "duration_seconds": 22.68, "scale_notes_used": [53, 55, 56, 58, 60, 62, 63, 65, 67, 68, 70, 72, 74, 75, 77, 79, 80, 82, 84, 86, 87, 89, 91, 92, 94, 96, 98, 99]}	2026-03-13 15:44:42.659044+00	2026-03-13 15:44:42.659044+00
8407f937-10fd-45c9-9664-614a53f2d031	8407f937-10fd-45c9-9664-614a53f2d031.mid	/app/sequences/8407f937-10fd-45c9-9664-614a53f2d031.mid	Bb	pentatonic_minor	125	6	4	8	3	6	mixed	medium	0.110	0	t	47	23.04	{0,10,0,7,0,6,0,0,14,0,10,0}	{"key": "Bb", "scale": "pentatonic_minor", "tempo": 125, "num_bars": 8, "instrument": 0, "octave_range": [3, 6], "rhythm_pattern": "mixed", "rest_probability": 0.11, "time_signature_den": 4, "time_signature_num": 6, "velocity_variation": true, "note_duration_variety": "medium"}	{"note_count": 47, "pitch_histogram": [0, 10, 0, 7, 0, 6, 0, 0, 14, 0, 10, 0], "duration_seconds": 23.04, "scale_notes_used": [58, 61, 63, 65, 68, 70, 73, 75, 77, 80, 82, 85, 87, 89, 92, 94, 97, 99, 101, 104]}	2026-03-13 15:44:42.66152+00	2026-03-13 15:44:42.66152+00
0e75fc19-5f8a-4be8-99f0-8d45de719ad8	0e75fc19-5f8a-4be8-99f0-8d45de719ad8.mid	/app/sequences/0e75fc19-5f8a-4be8-99f0-8d45de719ad8.mid	A	pentatonic_major	168	3	4	4	4	6	triplet	medium	0.100	19	f	12	4.29	{0,1,0,0,4,0,2,0,0,0,0,5}	{"key": "A", "scale": "pentatonic_major", "tempo": 168, "num_bars": 4, "instrument": 19, "octave_range": [4, 6], "rhythm_pattern": "triplet", "rest_probability": 0.1, "time_signature_den": 4, "time_signature_num": 3, "velocity_variation": false, "note_duration_variety": "medium"}	{"note_count": 12, "pitch_histogram": [0, 1, 0, 0, 4, 0, 2, 0, 0, 0, 0, 5], "duration_seconds": 4.29, "scale_notes_used": [69, 71, 73, 76, 78, 81, 83, 85, 88, 90, 93, 95, 97, 100, 102]}	2026-03-13 15:44:42.662787+00	2026-03-13 15:44:42.662787+00
dcd11f23-0e27-4076-877d-955ee7de7a69	dcd11f23-0e27-4076-877d-955ee7de7a69.mid	/app/sequences/dcd11f23-0e27-4076-877d-955ee7de7a69.mid	F	minor	129	4	4	8	4	5	dotted	medium	0.140	19	t	32	14.88	{3,9,0,5,0,3,0,8,2,0,2,0}	{"key": "F", "scale": "minor", "tempo": 129, "num_bars": 8, "instrument": 19, "octave_range": [4, 5], "rhythm_pattern": "dotted", "rest_probability": 0.14, "time_signature_den": 4, "time_signature_num": 4, "velocity_variation": true, "note_duration_variety": "medium"}	{"note_count": 32, "pitch_histogram": [3, 9, 0, 5, 0, 3, 0, 8, 2, 0, 2, 0], "duration_seconds": 14.88, "scale_notes_used": [65, 67, 68, 70, 72, 73, 75, 77, 79, 80, 82, 84, 85, 87]}	2026-03-13 15:44:42.664616+00	2026-03-13 15:44:42.664616+00
35a056a6-fd17-4bf0-9071-654b65acf563	35a056a6-fd17-4bf0-9071-654b65acf563.mid	/app/sequences/35a056a6-fd17-4bf0-9071-654b65acf563.mid	Gb	dorian	154	3	4	8	3	5	straight	high	0.160	48	f	19	9.35	{0,7,0,2,2,0,2,0,3,0,0,3}	{"key": "Gb", "scale": "dorian", "tempo": 154, "num_bars": 8, "instrument": 48, "octave_range": [3, 5], "rhythm_pattern": "straight", "rest_probability": 0.16, "time_signature_den": 4, "time_signature_num": 3, "velocity_variation": false, "note_duration_variety": "high"}	{"note_count": 19, "pitch_histogram": [0, 7, 0, 2, 2, 0, 2, 0, 3, 0, 0, 3], "duration_seconds": 9.35, "scale_notes_used": [54, 56, 57, 59, 61, 63, 64, 66, 68, 69, 71, 73, 75, 76, 78, 80, 81, 83, 85, 87, 88]}	2026-03-13 15:44:43.458654+00	2026-03-13 15:44:43.458654+00
8fc35079-f856-4a77-bcf3-48b9eed356c4	8fc35079-f856-4a77-bcf3-48b9eed356c4.mid	/app/sequences/8fc35079-f856-4a77-bcf3-48b9eed356c4.mid	E	pentatonic_major	164	6	4	16	3	6	syncopated	medium	0.160	4	t	94	35.12	{0,21,0,0,14,0,20,0,26,0,0,13}	{"key": "E", "scale": "pentatonic_major", "tempo": 164, "num_bars": 16, "instrument": 4, "octave_range": [3, 6], "rhythm_pattern": "syncopated", "rest_probability": 0.16, "time_signature_den": 4, "time_signature_num": 6, "velocity_variation": true, "note_duration_variety": "medium"}	{"note_count": 94, "pitch_histogram": [0, 21, 0, 0, 14, 0, 20, 0, 26, 0, 0, 13], "duration_seconds": 35.12, "scale_notes_used": [52, 54, 56, 59, 61, 64, 66, 68, 71, 73, 76, 78, 80, 83, 85, 88, 90, 92, 95, 97]}	2026-03-13 15:44:43.475753+00	2026-03-13 15:44:43.475753+00
0d059910-94cb-4aaa-96ac-dedf083fe8d9	0d059910-94cb-4aaa-96ac-dedf083fe8d9.mid	/app/sequences/0d059910-94cb-4aaa-96ac-dedf083fe8d9.mid	Gb	pentatonic_minor	132	4	4	8	4	6	waltz	medium	0.240	4	f	32	14.55	{0,8,0,0,7,0,7,0,0,5,0,5}	{"key": "Gb", "scale": "pentatonic_minor", "tempo": 132, "num_bars": 8, "instrument": 4, "octave_range": [4, 6], "rhythm_pattern": "waltz", "rest_probability": 0.24, "time_signature_den": 4, "time_signature_num": 4, "velocity_variation": false, "note_duration_variety": "medium"}	{"note_count": 32, "pitch_histogram": [0, 8, 0, 0, 7, 0, 7, 0, 0, 5, 0, 5], "duration_seconds": 14.55, "scale_notes_used": [66, 69, 71, 73, 76, 78, 81, 83, 85, 88, 90, 93, 95, 97, 100]}	2026-03-13 15:44:43.478809+00	2026-03-13 15:44:43.478809+00
1392856d-986a-4fcb-b2c1-c7e9dcbc6fff	1392856d-986a-4fcb-b2c1-c7e9dcbc6fff.mid	/app/sequences/1392856d-986a-4fcb-b2c1-c7e9dcbc6fff.mid	F#	pentatonic_major	168	6	4	12	4	6	syncopated	medium	0.080	24	f	70	25.71	{0,17,0,14,0,0,12,0,13,0,14,0}	{"key": "F#", "scale": "pentatonic_major", "tempo": 168, "num_bars": 12, "instrument": 24, "octave_range": [4, 6], "rhythm_pattern": "syncopated", "rest_probability": 0.08, "time_signature_den": 4, "time_signature_num": 6, "velocity_variation": false, "note_duration_variety": "medium"}	{"note_count": 70, "pitch_histogram": [0, 17, 0, 14, 0, 0, 12, 0, 13, 0, 14, 0], "duration_seconds": 25.71, "scale_notes_used": [66, 68, 70, 73, 75, 78, 80, 82, 85, 87, 90, 92, 94, 97, 99]}	2026-03-13 15:44:43.484284+00	2026-03-13 15:44:43.484284+00
4a815517-855a-410a-94fe-2807335ed4de	4a815517-855a-410a-94fe-2807335ed4de.mid	/app/sequences/4a815517-855a-410a-94fe-2807335ed4de.mid	Gb	pentatonic_minor	170	4	4	16	3	6	mixed	medium	0.100	73	f	60	22.59	{0,8,0,0,12,0,14,0,0,16,0,10}	{"key": "Gb", "scale": "pentatonic_minor", "tempo": 170, "num_bars": 16, "instrument": 73, "octave_range": [3, 6], "rhythm_pattern": "mixed", "rest_probability": 0.1, "time_signature_den": 4, "time_signature_num": 4, "velocity_variation": false, "note_duration_variety": "medium"}	{"note_count": 60, "pitch_histogram": [0, 8, 0, 0, 12, 0, 14, 0, 0, 16, 0, 10], "duration_seconds": 22.59, "scale_notes_used": [54, 57, 59, 61, 64, 66, 69, 71, 73, 76, 78, 81, 83, 85, 88, 90, 93, 95, 97, 100]}	2026-03-13 15:44:43.487298+00	2026-03-13 15:44:43.487298+00
b23b030b-eddd-4eed-ae18-4cf08ce3cb43	b23b030b-eddd-4eed-ae18-4cf08ce3cb43.mid	/app/sequences/b23b030b-eddd-4eed-ae18-4cf08ce3cb43.mid	B	minor	139	4	4	8	4	6	straight	medium	0.110	4	f	31	13.81	{0,5,8,0,6,0,3,3,0,3,0,3}	{"key": "B", "scale": "minor", "tempo": 139, "num_bars": 8, "instrument": 4, "octave_range": [4, 6], "rhythm_pattern": "straight", "rest_probability": 0.11, "time_signature_den": 4, "time_signature_num": 4, "velocity_variation": false, "note_duration_variety": "medium"}	{"note_count": 31, "pitch_histogram": [0, 5, 8, 0, 6, 0, 3, 3, 0, 3, 0, 3], "duration_seconds": 13.81, "scale_notes_used": [71, 73, 74, 76, 78, 79, 81, 83, 85, 86, 88, 90, 91, 93, 95, 97, 98, 100, 102, 103, 105]}	2026-03-13 15:44:43.489243+00	2026-03-13 15:44:43.489243+00
b5ffd572-0e0c-466f-84e8-daaad108723f	b5ffd572-0e0c-466f-84e8-daaad108723f.mid	/app/sequences/b5ffd572-0e0c-466f-84e8-daaad108723f.mid	A#	major	90	4	4	8	3	6	mixed	low	0.180	0	t	22	21.33	{3,0,5,2,0,4,0,0,0,1,7,0}	{"key": "A#", "scale": "major", "tempo": 90, "num_bars": 8, "instrument": 0, "octave_range": [3, 6], "rhythm_pattern": "mixed", "rest_probability": 0.18, "time_signature_den": 4, "time_signature_num": 4, "velocity_variation": true, "note_duration_variety": "low"}	{"note_count": 22, "pitch_histogram": [3, 0, 5, 2, 0, 4, 0, 0, 0, 1, 7, 0], "duration_seconds": 21.33, "scale_notes_used": [58, 60, 62, 63, 65, 67, 69, 70, 72, 74, 75, 77, 79, 81, 82, 84, 86, 87, 89, 91, 93, 94, 96, 98, 99, 101, 103, 105]}	2026-03-13 15:44:43.490779+00	2026-03-13 15:44:43.490779+00
20ccef1d-3ac6-4b09-80f7-c338702d8901	20ccef1d-3ac6-4b09-80f7-c338702d8901.mid	/app/sequences/20ccef1d-3ac6-4b09-80f7-c338702d8901.mid	C#	pentatonic_major	68	4	4	4	4	6	syncopated	low	0.060	48	t	14	14.12	{0,4,0,3,0,0,0,0,2,0,5,0}	{"key": "C#", "scale": "pentatonic_major", "tempo": 68, "num_bars": 4, "instrument": 48, "octave_range": [4, 6], "rhythm_pattern": "syncopated", "rest_probability": 0.06, "time_signature_den": 4, "time_signature_num": 4, "velocity_variation": true, "note_duration_variety": "low"}	{"note_count": 14, "pitch_histogram": [0, 4, 0, 3, 0, 0, 0, 0, 2, 0, 5, 0], "duration_seconds": 14.12, "scale_notes_used": [61, 63, 65, 68, 70, 73, 75, 77, 80, 82, 85, 87, 89, 92, 94]}	2026-03-13 15:44:43.492011+00	2026-03-13 15:44:43.492011+00
c2308eed-2e20-441f-83ad-40be74fff16f	c2308eed-2e20-441f-83ad-40be74fff16f.mid	/app/sequences/c2308eed-2e20-441f-83ad-40be74fff16f.mid	F	dorian	72	4	4	12	3	5	straight	medium	0.210	19	t	41	40.00	{0,0,7,10,0,4,0,4,9,0,7,0}	{"key": "F", "scale": "dorian", "tempo": 72, "num_bars": 12, "instrument": 19, "octave_range": [3, 5], "rhythm_pattern": "straight", "rest_probability": 0.21, "time_signature_den": 4, "time_signature_num": 4, "velocity_variation": true, "note_duration_variety": "medium"}	{"note_count": 41, "pitch_histogram": [0, 0, 7, 10, 0, 4, 0, 4, 9, 0, 7, 0], "duration_seconds": 40.0, "scale_notes_used": [53, 55, 56, 58, 60, 62, 63, 65, 67, 68, 70, 72, 74, 75, 77, 79, 80, 82, 84, 86, 87]}	2026-03-13 15:44:43.494057+00	2026-03-13 15:44:43.494057+00
3e933588-49df-4351-ae10-d49643ce7c9f	3e933588-49df-4351-ae10-d49643ce7c9f.mid	/app/sequences/3e933588-49df-4351-ae10-d49643ce7c9f.mid	E	dorian	123	4	4	8	4	5	dotted	low	0.200	19	f	22	15.61	{0,4,3,0,4,0,3,1,0,2,0,5}	{"key": "E", "scale": "dorian", "tempo": 123, "num_bars": 8, "instrument": 19, "octave_range": [4, 5], "rhythm_pattern": "dotted", "rest_probability": 0.2, "time_signature_den": 4, "time_signature_num": 4, "velocity_variation": false, "note_duration_variety": "low"}	{"note_count": 22, "pitch_histogram": [0, 4, 3, 0, 4, 0, 3, 1, 0, 2, 0, 5], "duration_seconds": 15.61, "scale_notes_used": [64, 66, 67, 69, 71, 73, 74, 76, 78, 79, 81, 83, 85, 86]}	2026-03-13 15:44:44.203458+00	2026-03-13 15:44:44.203458+00
2dbaf8e4-9a84-4395-b34e-0a391fdf6edf	2dbaf8e4-9a84-4395-b34e-0a391fdf6edf.mid	/app/sequences/2dbaf8e4-9a84-4395-b34e-0a391fdf6edf.mid	Gb	pentatonic_major	119	6	4	4	3	5	waltz	medium	0.120	40	f	19	12.10	{0,4,0,4,0,0,4,0,4,0,3,0}	{"key": "Gb", "scale": "pentatonic_major", "tempo": 119, "num_bars": 4, "instrument": 40, "octave_range": [3, 5], "rhythm_pattern": "waltz", "rest_probability": 0.12, "time_signature_den": 4, "time_signature_num": 6, "velocity_variation": false, "note_duration_variety": "medium"}	{"note_count": 19, "pitch_histogram": [0, 4, 0, 4, 0, 0, 4, 0, 4, 0, 3, 0], "duration_seconds": 12.1, "scale_notes_used": [54, 56, 58, 61, 63, 66, 68, 70, 73, 75, 78, 80, 82, 85, 87]}	2026-03-13 15:44:44.209766+00	2026-03-13 15:44:44.209766+00
6dc2f893-d7ad-4b7f-8590-5571c852a422	6dc2f893-d7ad-4b7f-8590-5571c852a422.mid	/app/sequences/6dc2f893-d7ad-4b7f-8590-5571c852a422.mid	Gb	blues	87	4	4	16	4	6	triplet	medium	0.120	24	f	58	44.14	{8,10,0,0,5,0,16,0,0,13,0,6}	{"key": "Gb", "scale": "blues", "tempo": 87, "num_bars": 16, "instrument": 24, "octave_range": [4, 6], "rhythm_pattern": "triplet", "rest_probability": 0.12, "time_signature_den": 4, "time_signature_num": 4, "velocity_variation": false, "note_duration_variety": "medium"}	{"note_count": 58, "pitch_histogram": [8, 10, 0, 0, 5, 0, 16, 0, 0, 13, 0, 6], "duration_seconds": 44.14, "scale_notes_used": [66, 69, 71, 72, 73, 76, 78, 81, 83, 84, 85, 88, 90, 93, 95, 96, 97, 100]}	2026-03-13 15:44:44.213833+00	2026-03-13 15:44:44.213833+00
0a8c3a65-58ec-4124-93ff-5360ebd18b95	0a8c3a65-58ec-4124-93ff-5360ebd18b95.mid	/app/sequences/0a8c3a65-58ec-4124-93ff-5360ebd18b95.mid	G#	major	93	4	4	4	4	5	waltz	low	0.120	25	f	13	10.32	{2,2,0,2,0,2,0,3,2,0,0,0}	{"key": "G#", "scale": "major", "tempo": 93, "num_bars": 4, "instrument": 25, "octave_range": [4, 5], "rhythm_pattern": "waltz", "rest_probability": 0.12, "time_signature_den": 4, "time_signature_num": 4, "velocity_variation": false, "note_duration_variety": "low"}	{"note_count": 13, "pitch_histogram": [2, 2, 0, 2, 0, 2, 0, 3, 2, 0, 0, 0], "duration_seconds": 10.32, "scale_notes_used": [68, 70, 72, 73, 75, 77, 79, 80, 82, 84, 85, 87, 89, 91]}	2026-03-13 15:44:44.215926+00	2026-03-13 15:44:44.215926+00
2c3b7a63-14ee-4ffc-9d47-e7da686d699e	2c3b7a63-14ee-4ffc-9d47-e7da686d699e.mid	/app/sequences/2c3b7a63-14ee-4ffc-9d47-e7da686d699e.mid	A#	dorian	95	4	4	12	4	5	mixed	high	0.150	73	t	36	30.32	{7,6,0,4,0,7,0,2,3,0,7,0}	{"key": "A#", "scale": "dorian", "tempo": 95, "num_bars": 12, "instrument": 73, "octave_range": [4, 5], "rhythm_pattern": "mixed", "rest_probability": 0.15, "time_signature_den": 4, "time_signature_num": 4, "velocity_variation": true, "note_duration_variety": "high"}	{"note_count": 36, "pitch_histogram": [7, 6, 0, 4, 0, 7, 0, 2, 3, 0, 7, 0], "duration_seconds": 30.32, "scale_notes_used": [70, 72, 73, 75, 77, 79, 80, 82, 84, 85, 87, 89, 91, 92]}	2026-03-13 15:44:44.218502+00	2026-03-13 15:44:44.218502+00
89a164de-9873-4c68-a988-3a467aca3a5c	89a164de-9873-4c68-a988-3a467aca3a5c.mid	/app/sequences/89a164de-9873-4c68-a988-3a467aca3a5c.mid	A	minor	108	6	4	8	4	5	triplet	high	0.250	0	f	42	26.67	{4,0,9,0,7,9,0,5,0,2,0,6}	{"key": "A", "scale": "minor", "tempo": 108, "num_bars": 8, "instrument": 0, "octave_range": [4, 5], "rhythm_pattern": "triplet", "rest_probability": 0.25, "time_signature_den": 4, "time_signature_num": 6, "velocity_variation": false, "note_duration_variety": "high"}	{"note_count": 42, "pitch_histogram": [4, 0, 9, 0, 7, 9, 0, 5, 0, 2, 0, 6], "duration_seconds": 26.67, "scale_notes_used": [69, 71, 72, 74, 76, 77, 79, 81, 83, 84, 86, 88, 89, 91]}	2026-03-13 15:44:44.221216+00	2026-03-13 15:44:44.221216+00
4de00df1-714b-4471-ac1a-e67f70810e26	4de00df1-714b-4471-ac1a-e67f70810e26.mid	/app/sequences/4de00df1-714b-4471-ac1a-e67f70810e26.mid	Db	dorian	107	3	4	4	3	5	syncopated	high	0.140	12	f	13	6.73	{0,2,0,2,2,0,0,0,1,0,2,4}	{"key": "Db", "scale": "dorian", "tempo": 107, "num_bars": 4, "instrument": 12, "octave_range": [3, 5], "rhythm_pattern": "syncopated", "rest_probability": 0.14, "time_signature_den": 4, "time_signature_num": 3, "velocity_variation": false, "note_duration_variety": "high"}	{"note_count": 13, "pitch_histogram": [0, 2, 0, 2, 2, 0, 0, 0, 1, 0, 2, 4], "duration_seconds": 6.73, "scale_notes_used": [49, 51, 52, 54, 56, 58, 59, 61, 63, 64, 66, 68, 70, 71, 73, 75, 76, 78, 80, 82, 83]}	2026-03-13 15:44:44.222698+00	2026-03-13 15:44:44.222698+00
12de7e71-6663-4d33-b3c1-67221c6635db	12de7e71-6663-4d33-b3c1-67221c6635db.mid	/app/sequences/12de7e71-6663-4d33-b3c1-67221c6635db.mid	B	blues	179	3	4	8	3	6	triplet	low	0.180	0	f	18	8.04	{0,0,1,0,3,5,3,0,0,5,0,1}	{"key": "B", "scale": "blues", "tempo": 179, "num_bars": 8, "instrument": 0, "octave_range": [3, 6], "rhythm_pattern": "triplet", "rest_probability": 0.18, "time_signature_den": 4, "time_signature_num": 3, "velocity_variation": false, "note_duration_variety": "low"}	{"note_count": 18, "pitch_histogram": [0, 0, 1, 0, 3, 5, 3, 0, 0, 5, 0, 1], "duration_seconds": 8.04, "scale_notes_used": [59, 62, 64, 65, 66, 69, 71, 74, 76, 77, 78, 81, 83, 86, 88, 89, 90, 93, 95, 98, 100, 101, 102, 105]}	2026-03-13 15:44:44.224129+00	2026-03-13 15:44:44.224129+00
9e6965a7-1760-4c96-955d-99423765786d	9e6965a7-1760-4c96-955d-99423765786d.mid	/app/sequences/9e6965a7-1760-4c96-955d-99423765786d.mid	Ab	major	71	3	4	4	4	6	waltz	medium	0.230	40	t	7	10.14	{0,1,0,3,0,1,0,1,1,0,0,0}	{"key": "Ab", "scale": "major", "tempo": 71, "num_bars": 4, "instrument": 40, "octave_range": [4, 6], "rhythm_pattern": "waltz", "rest_probability": 0.23, "time_signature_den": 4, "time_signature_num": 3, "velocity_variation": true, "note_duration_variety": "medium"}	{"note_count": 7, "pitch_histogram": [0, 1, 0, 3, 0, 1, 0, 1, 1, 0, 0, 0], "duration_seconds": 10.14, "scale_notes_used": [68, 70, 72, 73, 75, 77, 79, 80, 82, 84, 85, 87, 89, 91, 92, 94, 96, 97, 99, 101, 103]}	2026-03-13 15:44:44.225709+00	2026-03-13 15:44:44.225709+00
3a142449-0918-43a1-a08e-56f81b4e4c51	3a142449-0918-43a1-a08e-56f81b4e4c51.mid	/app/sequences/3a142449-0918-43a1-a08e-56f81b4e4c51.mid	G	minor	163	4	4	8	3	6	waltz	high	0.080	0	f	39	11.78	{2,0,4,3,0,8,0,5,0,5,12,0}	{"key": "G", "scale": "minor", "tempo": 163, "num_bars": 8, "instrument": 0, "octave_range": [3, 6], "rhythm_pattern": "waltz", "rest_probability": 0.08, "time_signature_den": 4, "time_signature_num": 4, "velocity_variation": false, "note_duration_variety": "high"}	{"note_count": 39, "pitch_histogram": [2, 0, 4, 3, 0, 8, 0, 5, 0, 5, 12, 0], "duration_seconds": 11.78, "scale_notes_used": [55, 57, 58, 60, 62, 63, 65, 67, 69, 70, 72, 74, 75, 77, 79, 81, 82, 84, 86, 87, 89, 91, 93, 94, 96, 98, 99, 101]}	2026-03-13 15:44:44.227791+00	2026-03-13 15:44:44.227791+00
\.


--
-- Name: ratings ratings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ratings
    ADD CONSTRAINT ratings_pkey PRIMARY KEY (id);


--
-- Name: sequences sequences_filename_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sequences
    ADD CONSTRAINT sequences_filename_key UNIQUE (filename);


--
-- Name: sequences sequences_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sequences
    ADD CONSTRAINT sequences_pkey PRIMARY KEY (id);


--
-- Name: idx_ratings_rated_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_ratings_rated_at ON public.ratings USING btree (rated_at DESC);


--
-- Name: idx_ratings_rating; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_ratings_rating ON public.ratings USING btree (rating);


--
-- Name: idx_ratings_sequence; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_ratings_sequence ON public.ratings USING btree (sequence_id);


--
-- Name: idx_sequences_bars; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sequences_bars ON public.sequences USING btree (num_bars);


--
-- Name: idx_sequences_config; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sequences_config ON public.sequences USING gin (config_json);


--
-- Name: idx_sequences_created; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sequences_created ON public.sequences USING btree (created_at DESC);


--
-- Name: idx_sequences_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sequences_key ON public.sequences USING btree (key_signature);


--
-- Name: idx_sequences_scale; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sequences_scale ON public.sequences USING btree (scale);


--
-- Name: idx_sequences_tempo; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sequences_tempo ON public.sequences USING btree (tempo);


--
-- Name: sequences trg_sequences_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_sequences_updated_at BEFORE UPDATE ON public.sequences FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();


--
-- Name: ratings ratings_sequence_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ratings
    ADD CONSTRAINT ratings_sequence_id_fkey FOREIGN KEY (sequence_id) REFERENCES public.sequences(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict arB7rKIKuyB1o4gxUwESCRu7bI34qveDvoeUvJ41pFSvGcenVINesOK2mFvODEY

