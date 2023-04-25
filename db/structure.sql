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
-- Name: work_access; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.work_access AS ENUM (
    'stanford',
    'world'
);


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: abstract_contributors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.abstract_contributors (
    id bigint NOT NULL,
    work_version_id bigint NOT NULL,
    first_name character varying,
    last_name character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    contributor_type character varying NOT NULL,
    role character varying NOT NULL,
    full_name character varying,
    type character varying,
    weight integer,
    orcid character varying
);


--
-- Name: abstract_contributors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.abstract_contributors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: abstract_contributors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.abstract_contributors_id_seq OWNED BY public.abstract_contributors.id;


--
-- Name: active_storage_attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_attachments (
    id bigint NOT NULL,
    name character varying NOT NULL,
    record_type character varying NOT NULL,
    record_id bigint NOT NULL,
    blob_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_attachments_id_seq OWNED BY public.active_storage_attachments.id;


--
-- Name: active_storage_blobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_blobs (
    id bigint NOT NULL,
    key character varying NOT NULL,
    filename character varying NOT NULL,
    content_type character varying,
    metadata text,
    byte_size bigint NOT NULL,
    checksum character varying,
    created_at timestamp without time zone NOT NULL,
    service_name character varying NOT NULL
);


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_blobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_blobs_id_seq OWNED BY public.active_storage_blobs.id;


--
-- Name: active_storage_variant_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_variant_records (
    id bigint NOT NULL,
    blob_id bigint NOT NULL,
    variation_digest character varying NOT NULL
);


--
-- Name: active_storage_variant_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_variant_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_variant_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_variant_records_id_seq OWNED BY public.active_storage_variant_records.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: attached_files; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.attached_files (
    id bigint NOT NULL,
    label character varying DEFAULT ''::character varying,
    hide boolean DEFAULT false NOT NULL,
    work_version_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    path character varying
);


--
-- Name: attached_files_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.attached_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: attached_files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.attached_files_id_seq OWNED BY public.attached_files.id;


--
-- Name: collection_versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.collection_versions (
    id bigint NOT NULL,
    version integer DEFAULT 1 NOT NULL,
    state character varying NOT NULL,
    name character varying NOT NULL,
    description character varying,
    collection_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    version_description character varying
);


--
-- Name: collection_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.collection_versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: collection_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.collection_versions_id_seq OWNED BY public.collection_versions.id;


--
-- Name: collections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.collections (
    id bigint NOT NULL,
    release_option character varying,
    release_duration character varying,
    access character varying,
    required_license character varying,
    default_license character varying,
    email_when_participants_changed boolean,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    creator_id bigint NOT NULL,
    druid character varying,
    email_depositors_status_changed boolean,
    review_enabled boolean DEFAULT false,
    license_option character varying DEFAULT 'required'::character varying NOT NULL,
    head_id bigint,
    doi_option character varying DEFAULT 'yes'::character varying
);


--
-- Name: collections_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.collections_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: collections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.collections_id_seq OWNED BY public.collections.id;


--
-- Name: contact_emails; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.contact_emails (
    id bigint NOT NULL,
    email character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    emailable_type character varying,
    emailable_id bigint
);


--
-- Name: contact_emails_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.contact_emails_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contact_emails_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.contact_emails_id_seq OWNED BY public.contact_emails.id;


--
-- Name: depositors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.depositors (
    collection_id bigint NOT NULL,
    user_id bigint NOT NULL
);


--
-- Name: events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.events (
    id bigint NOT NULL,
    description character varying,
    event_type character varying NOT NULL,
    user_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    eventable_type character varying,
    eventable_id bigint
);


--
-- Name: events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.events_id_seq OWNED BY public.events.id;


--
-- Name: keywords; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.keywords (
    id bigint NOT NULL,
    work_version_id bigint NOT NULL,
    label character varying,
    uri character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    cocina_type character varying
);


--
-- Name: keywords_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.keywords_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: keywords_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.keywords_id_seq OWNED BY public.keywords.id;


--
-- Name: mail_preferences; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mail_preferences (
    id bigint NOT NULL,
    wanted boolean DEFAULT true NOT NULL,
    email character varying NOT NULL,
    user_id bigint NOT NULL,
    collection_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: mail_preferences_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mail_preferences_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mail_preferences_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mail_preferences_id_seq OWNED BY public.mail_preferences.id;


--
-- Name: managers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.managers (
    collection_id bigint NOT NULL,
    user_id bigint NOT NULL
);


--
-- Name: page_contents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.page_contents (
    id bigint NOT NULL,
    page character varying NOT NULL,
    value text DEFAULT ''::text,
    visible boolean DEFAULT false,
    link_visible boolean DEFAULT false,
    link_text character varying DEFAULT ''::character varying,
    link_url character varying DEFAULT ''::character varying,
    "user" character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: page_contents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.page_contents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: page_contents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.page_contents_id_seq OWNED BY public.page_contents.id;


--
-- Name: related_links; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.related_links (
    id bigint NOT NULL,
    link_title character varying,
    url character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    linkable_type character varying,
    linkable_id bigint
);


--
-- Name: related_links_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.related_links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: related_links_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.related_links_id_seq OWNED BY public.related_links.id;


--
-- Name: related_works; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.related_works (
    id bigint NOT NULL,
    work_version_id bigint NOT NULL,
    citation character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: related_works_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.related_works_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: related_works_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.related_works_id_seq OWNED BY public.related_works.id;


--
-- Name: reviewers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reviewers (
    collection_id bigint NOT NULL,
    user_id bigint NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    name character varying,
    last_work_terms_agreement timestamp without time zone,
    first_name character varying
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: work_versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.work_versions (
    id bigint NOT NULL,
    version integer DEFAULT 1,
    title character varying,
    work_type character varying NOT NULL,
    created_edtf character varying,
    abstract text,
    citation character varying,
    access public.work_access DEFAULT 'world'::public.work_access NOT NULL,
    embargo_date date,
    license character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    state character varying NOT NULL,
    published_edtf character varying,
    subtype text[] DEFAULT '{}'::text[],
    work_id bigint NOT NULL,
    version_description character varying,
    published_at timestamp(6) without time zone,
    upload_type character varying,
    globus_endpoint character varying
);


--
-- Name: work_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.work_versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: work_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.work_versions_id_seq OWNED BY public.work_versions.id;


--
-- Name: works; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.works (
    id bigint NOT NULL,
    druid character varying,
    head_id bigint,
    collection_id bigint,
    depositor_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    assign_doi boolean DEFAULT true NOT NULL,
    doi character varying,
    owner_id bigint NOT NULL,
    locked boolean DEFAULT false NOT NULL
);


--
-- Name: works_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.works_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: works_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.works_id_seq OWNED BY public.works.id;


--
-- Name: abstract_contributors id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.abstract_contributors ALTER COLUMN id SET DEFAULT nextval('public.abstract_contributors_id_seq'::regclass);


--
-- Name: active_storage_attachments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments ALTER COLUMN id SET DEFAULT nextval('public.active_storage_attachments_id_seq'::regclass);


--
-- Name: active_storage_blobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs ALTER COLUMN id SET DEFAULT nextval('public.active_storage_blobs_id_seq'::regclass);


--
-- Name: active_storage_variant_records id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records ALTER COLUMN id SET DEFAULT nextval('public.active_storage_variant_records_id_seq'::regclass);


--
-- Name: attached_files id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attached_files ALTER COLUMN id SET DEFAULT nextval('public.attached_files_id_seq'::regclass);


--
-- Name: collection_versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_versions ALTER COLUMN id SET DEFAULT nextval('public.collection_versions_id_seq'::regclass);


--
-- Name: collections id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collections ALTER COLUMN id SET DEFAULT nextval('public.collections_id_seq'::regclass);


--
-- Name: contact_emails id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contact_emails ALTER COLUMN id SET DEFAULT nextval('public.contact_emails_id_seq'::regclass);


--
-- Name: events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events ALTER COLUMN id SET DEFAULT nextval('public.events_id_seq'::regclass);


--
-- Name: keywords id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.keywords ALTER COLUMN id SET DEFAULT nextval('public.keywords_id_seq'::regclass);


--
-- Name: mail_preferences id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mail_preferences ALTER COLUMN id SET DEFAULT nextval('public.mail_preferences_id_seq'::regclass);


--
-- Name: page_contents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_contents ALTER COLUMN id SET DEFAULT nextval('public.page_contents_id_seq'::regclass);


--
-- Name: related_links id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.related_links ALTER COLUMN id SET DEFAULT nextval('public.related_links_id_seq'::regclass);


--
-- Name: related_works id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.related_works ALTER COLUMN id SET DEFAULT nextval('public.related_works_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: work_versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_versions ALTER COLUMN id SET DEFAULT nextval('public.work_versions_id_seq'::regclass);


--
-- Name: works id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.works ALTER COLUMN id SET DEFAULT nextval('public.works_id_seq'::regclass);


--
-- Name: abstract_contributors abstract_contributors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.abstract_contributors
    ADD CONSTRAINT abstract_contributors_pkey PRIMARY KEY (id);


--
-- Name: active_storage_attachments active_storage_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT active_storage_attachments_pkey PRIMARY KEY (id);


--
-- Name: active_storage_blobs active_storage_blobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs
    ADD CONSTRAINT active_storage_blobs_pkey PRIMARY KEY (id);


--
-- Name: active_storage_variant_records active_storage_variant_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records
    ADD CONSTRAINT active_storage_variant_records_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: attached_files attached_files_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attached_files
    ADD CONSTRAINT attached_files_pkey PRIMARY KEY (id);


--
-- Name: collection_versions collection_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_versions
    ADD CONSTRAINT collection_versions_pkey PRIMARY KEY (id);


--
-- Name: collections collections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collections
    ADD CONSTRAINT collections_pkey PRIMARY KEY (id);


--
-- Name: contact_emails contact_emails_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contact_emails
    ADD CONSTRAINT contact_emails_pkey PRIMARY KEY (id);


--
-- Name: events events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: keywords keywords_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.keywords
    ADD CONSTRAINT keywords_pkey PRIMARY KEY (id);


--
-- Name: mail_preferences mail_preferences_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mail_preferences
    ADD CONSTRAINT mail_preferences_pkey PRIMARY KEY (id);


--
-- Name: page_contents page_contents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_contents
    ADD CONSTRAINT page_contents_pkey PRIMARY KEY (id);


--
-- Name: related_links related_links_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.related_links
    ADD CONSTRAINT related_links_pkey PRIMARY KEY (id);


--
-- Name: related_works related_works_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.related_works
    ADD CONSTRAINT related_works_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: work_versions work_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_versions
    ADD CONSTRAINT work_versions_pkey PRIMARY KEY (id);


--
-- Name: works works_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.works
    ADD CONSTRAINT works_pkey PRIMARY KEY (id);


--
-- Name: index_abstract_contributors_on_work_version_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_abstract_contributors_on_work_version_id ON public.abstract_contributors USING btree (work_version_id);


--
-- Name: index_active_storage_attachments_on_blob_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_storage_attachments_on_blob_id ON public.active_storage_attachments USING btree (blob_id);


--
-- Name: index_active_storage_attachments_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_attachments_uniqueness ON public.active_storage_attachments USING btree (record_type, record_id, name, blob_id);


--
-- Name: index_active_storage_blobs_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_blobs_on_key ON public.active_storage_blobs USING btree (key);


--
-- Name: index_active_storage_variant_records_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_variant_records_uniqueness ON public.active_storage_variant_records USING btree (blob_id, variation_digest);


--
-- Name: index_attached_files_on_work_version_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_attached_files_on_work_version_id ON public.attached_files USING btree (work_version_id);


--
-- Name: index_collection_versions_on_collection_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collection_versions_on_collection_id ON public.collection_versions USING btree (collection_id);


--
-- Name: index_collections_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collections_on_creator_id ON public.collections USING btree (creator_id);


--
-- Name: index_collections_on_druid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_collections_on_druid ON public.collections USING btree (druid);


--
-- Name: index_collections_on_head_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collections_on_head_id ON public.collections USING btree (head_id);


--
-- Name: index_contact_emails_on_emailable_type_and_emailable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contact_emails_on_emailable_type_and_emailable_id ON public.contact_emails USING btree (emailable_type, emailable_id);


--
-- Name: index_depositors_on_collection_id_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_depositors_on_collection_id_and_user_id ON public.depositors USING btree (collection_id, user_id);


--
-- Name: index_events_on_eventable_type_and_eventable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_events_on_eventable_type_and_eventable_id ON public.events USING btree (eventable_type, eventable_id);


--
-- Name: index_events_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_events_on_user_id ON public.events USING btree (user_id);


--
-- Name: index_keywords_on_work_version_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_keywords_on_work_version_id ON public.keywords USING btree (work_version_id);


--
-- Name: index_mail_preferences_on_collection_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_mail_preferences_on_collection_id ON public.mail_preferences USING btree (collection_id);


--
-- Name: index_mail_preferences_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_mail_preferences_on_user_id ON public.mail_preferences USING btree (user_id);


--
-- Name: index_mail_preferences_on_user_id_and_collection_id_and_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_mail_preferences_on_user_id_and_collection_id_and_email ON public.mail_preferences USING btree (user_id, collection_id, email);


--
-- Name: index_managers_on_collection_id_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_managers_on_collection_id_and_user_id ON public.managers USING btree (collection_id, user_id);


--
-- Name: index_related_links_on_linkable_type_and_linkable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_related_links_on_linkable_type_and_linkable_id ON public.related_links USING btree (linkable_type, linkable_id);


--
-- Name: index_related_works_on_work_version_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_related_works_on_work_version_id ON public.related_works USING btree (work_version_id);


--
-- Name: index_reviewers_on_collection_id_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_reviewers_on_collection_id_and_user_id ON public.reviewers USING btree (collection_id, user_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- Name: index_work_versions_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_work_versions_on_created_at ON public.work_versions USING btree (created_at);


--
-- Name: index_work_versions_on_state; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_work_versions_on_state ON public.work_versions USING btree (state);


--
-- Name: index_work_versions_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_work_versions_on_updated_at ON public.work_versions USING btree (updated_at);


--
-- Name: index_work_versions_on_work_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_work_versions_on_work_id ON public.work_versions USING btree (work_id);


--
-- Name: index_works_on_collection_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_works_on_collection_id ON public.works USING btree (collection_id);


--
-- Name: index_works_on_depositor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_works_on_depositor_id ON public.works USING btree (depositor_id);


--
-- Name: index_works_on_druid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_works_on_druid ON public.works USING btree (druid);


--
-- Name: index_works_on_head_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_works_on_head_id ON public.works USING btree (head_id);


--
-- Name: index_works_on_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_works_on_owner_id ON public.works USING btree (owner_id);


--
-- Name: events fk_rails_0cb5590091; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT fk_rails_0cb5590091 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: related_works fk_rails_357f313015; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.related_works
    ADD CONSTRAINT fk_rails_357f313015 FOREIGN KEY (work_version_id) REFERENCES public.work_versions(id);


--
-- Name: works fk_rails_3aa29f8d19; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.works
    ADD CONSTRAINT fk_rails_3aa29f8d19 FOREIGN KEY (head_id) REFERENCES public.work_versions(id);


--
-- Name: works fk_rails_6d81a5f2b3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.works
    ADD CONSTRAINT fk_rails_6d81a5f2b3 FOREIGN KEY (owner_id) REFERENCES public.users(id);


--
-- Name: abstract_contributors fk_rails_736fa9cbfb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.abstract_contributors
    ADD CONSTRAINT fk_rails_736fa9cbfb FOREIGN KEY (work_version_id) REFERENCES public.work_versions(id);


--
-- Name: mail_preferences fk_rails_7af7ffa212; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mail_preferences
    ADD CONSTRAINT fk_rails_7af7ffa212 FOREIGN KEY (collection_id) REFERENCES public.collections(id);


--
-- Name: works fk_rails_7ea9207fbe; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.works
    ADD CONSTRAINT fk_rails_7ea9207fbe FOREIGN KEY (collection_id) REFERENCES public.collections(id);


--
-- Name: attached_files fk_rails_84b18313d5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attached_files
    ADD CONSTRAINT fk_rails_84b18313d5 FOREIGN KEY (work_version_id) REFERENCES public.work_versions(id);


--
-- Name: active_storage_variant_records fk_rails_993965df05; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records
    ADD CONSTRAINT fk_rails_993965df05 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id);


--
-- Name: mail_preferences fk_rails_a29efdf4fd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mail_preferences
    ADD CONSTRAINT fk_rails_a29efdf4fd FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: work_versions fk_rails_a69381adb6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_versions
    ADD CONSTRAINT fk_rails_a69381adb6 FOREIGN KEY (work_id) REFERENCES public.works(id);


--
-- Name: collections fk_rails_ab2fec83b3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collections
    ADD CONSTRAINT fk_rails_ab2fec83b3 FOREIGN KEY (creator_id) REFERENCES public.users(id);


--
-- Name: active_storage_attachments fk_rails_c3b3935057; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT fk_rails_c3b3935057 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id);


--
-- Name: works fk_rails_db22aa4202; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.works
    ADD CONSTRAINT fk_rails_db22aa4202 FOREIGN KEY (depositor_id) REFERENCES public.users(id);


--
-- Name: keywords fk_rails_ddae867842; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.keywords
    ADD CONSTRAINT fk_rails_ddae867842 FOREIGN KEY (work_version_id) REFERENCES public.work_versions(id);


--
-- Name: collection_versions fk_rails_e110e4f591; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_versions
    ADD CONSTRAINT fk_rails_e110e4f591 FOREIGN KEY (collection_id) REFERENCES public.collections(id);


--
-- Name: collections fk_rails_eafc3da026; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collections
    ADD CONSTRAINT fk_rails_eafc3da026 FOREIGN KEY (head_id) REFERENCES public.collection_versions(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20200911170014'),
('20200911170056'),
('20200911170148'),
('20200911170338'),
('20200911170402'),
('20200913005756'),
('20201005230137'),
('20201005231842'),
('20201009042617'),
('20201009194116'),
('20201009194443'),
('20201013170323'),
('20201014223440'),
('20201018003611'),
('20201020162212'),
('20201020211040'),
('20201022194547'),
('20201023123700'),
('20201023212141'),
('20201026222437'),
('20201027203358'),
('20201028205711'),
('20201105141009'),
('20201105191840'),
('20201110133105'),
('20201112131704'),
('20201117205532'),
('20201119215418'),
('20201119215854'),
('20201201203229'),
('20201202161823'),
('20201202195426'),
('20201204214055'),
('20201207223546'),
('20201211051829'),
('20201214213408'),
('20210104185452'),
('20210104185453'),
('20210113173329'),
('20210114221943'),
('20210127133325'),
('20210201155622'),
('20210202044303'),
('20210208201246'),
('20210209204542'),
('20210211170008'),
('20210216220559'),
('20210218234733'),
('20210219142356'),
('20210520161846'),
('20210527193102'),
('20210608161622'),
('20210616201626'),
('20210709182654'),
('20210709184325'),
('20210715161256'),
('20210719185721'),
('20210721164925'),
('20210802203252'),
('20210816133101'),
('20210827165420'),
('20220113144801'),
('20220808145502'),
('20220808221011'),
('20220808222722'),
('20220812205204'),
('20220824225302'),
('20220829114247'),
('20220901184555'),
('20220914211415'),
('20221115215744'),
('20221117233130'),
('20221201204010'),
('20221206194032'),
('20221213211305'),
('20230420204926');


