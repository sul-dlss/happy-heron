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
    type character varying
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
    checksum character varying NOT NULL,
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
    label character varying,
    hide boolean DEFAULT false NOT NULL,
    work_version_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
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
-- Name: collections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.collections (
    id bigint NOT NULL,
    name character varying NOT NULL,
    description character varying,
    release_option character varying,
    release_duration character varying,
    release_date date,
    access character varying,
    required_license character varying,
    default_license character varying,
    email_when_participants_changed boolean,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    creator_id bigint NOT NULL,
    state character varying DEFAULT 'new'::character varying NOT NULL,
    druid character varying,
    version integer DEFAULT 0 NOT NULL,
    email_depositors_status_changed boolean,
    review_enabled boolean DEFAULT false,
    license_option character varying DEFAULT 'required'::character varying NOT NULL
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
    user_id bigint NOT NULL,
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
    updated_at timestamp(6) without time zone NOT NULL
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
-- Name: managers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.managers (
    collection_id bigint NOT NULL,
    user_id bigint NOT NULL
);


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notifications (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    opened_at timestamp without time zone,
    text character varying NOT NULL
);


--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.notifications_id_seq OWNED BY public.notifications.id;


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
    name character varying
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
    title character varying NOT NULL,
    work_type character varying NOT NULL,
    created_edtf character varying,
    abstract text NOT NULL,
    citation character varying,
    access public.work_access DEFAULT 'world'::public.work_access NOT NULL,
    embargo_date date,
    license character varying NOT NULL,
    agree_to_terms boolean DEFAULT false,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    state character varying NOT NULL,
    published_edtf character varying,
    subtype text[] DEFAULT '{}'::text[],
    work_id bigint NOT NULL
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
    updated_at timestamp(6) without time zone NOT NULL
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
-- Name: notifications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications ALTER COLUMN id SET DEFAULT nextval('public.notifications_id_seq'::regclass);


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
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


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
-- Name: index_collections_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collections_on_creator_id ON public.collections USING btree (creator_id);


--
-- Name: index_collections_on_druid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_collections_on_druid ON public.collections USING btree (druid);


--
-- Name: index_collections_on_state; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collections_on_state ON public.collections USING btree (state);


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
-- Name: index_managers_on_collection_id_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_managers_on_collection_id_and_user_id ON public.managers USING btree (collection_id, user_id);


--
-- Name: index_notifications_on_opened_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notifications_on_opened_at ON public.notifications USING btree (opened_at);


--
-- Name: index_notifications_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notifications_on_user_id ON public.notifications USING btree (user_id);


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
-- Name: abstract_contributors fk_rails_736fa9cbfb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.abstract_contributors
    ADD CONSTRAINT fk_rails_736fa9cbfb FOREIGN KEY (work_version_id) REFERENCES public.work_versions(id);


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
-- Name: notifications fk_rails_b080fb4855; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT fk_rails_b080fb4855 FOREIGN KEY (user_id) REFERENCES public.users(id);


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
('20210211170008');


