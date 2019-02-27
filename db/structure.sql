--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.2
-- Dumped by pg_dump version 9.6.2

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- Name: jurisdiction; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE jurisdiction AS ENUM (
    'none',
    'local',
    'state',
    'federal',
    'university',
    'private'
);


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: agencies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE agencies (
    id integer NOT NULL,
    name character varying NOT NULL,
    street_address character varying,
    city character varying,
    state_id integer,
    zipcode character varying,
    description text,
    telephone character varying,
    email character varying,
    website character varying,
    lead_officer character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    slug character varying,
    longitude double precision,
    latitude double precision,
    jurisdiction_type character varying,
    jurisdiction jurisdiction DEFAULT 'none'::jurisdiction
);


--
-- Name: agencies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE agencies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: agencies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE agencies_id_seq OWNED BY agencies.id;


--
-- Name: ahoy_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE ahoy_events (
    id uuid NOT NULL,
    visit_id uuid,
    user_id integer,
    name character varying,
    properties text,
    "time" timestamp without time zone
);


--
-- Name: article_documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE article_documents (
    id integer NOT NULL,
    article_id integer,
    document_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: article_documents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE article_documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: article_documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE article_documents_id_seq OWNED BY article_documents.id;


--
-- Name: calendar_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE calendar_events (
    id integer NOT NULL,
    title character varying,
    description text,
    start_time timestamp without time zone,
    end_time timestamp without time zone,
    latitude double precision,
    longitude double precision,
    slug character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id integer,
    address character varying,
    city character varying,
    state_id integer,
    zipcode character varying
);


--
-- Name: calendar_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE calendar_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: calendar_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE calendar_events_id_seq OWNED BY calendar_events.id;


--
-- Name: case_agencies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE case_agencies (
    id integer NOT NULL,
    case_id integer,
    agency_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: case_agencies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE case_agencies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: case_agencies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE case_agencies_id_seq OWNED BY case_agencies.id;


--
-- Name: case_officers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE case_officers (
    id integer NOT NULL,
    case_id integer,
    officer_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: case_officers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE case_officers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: case_officers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE case_officers_id_seq OWNED BY case_officers.id;


--
-- Name: cases; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE cases (
    id integer NOT NULL,
    title character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id integer,
    category_id integer,
    date date,
    state_id integer,
    city character varying NOT NULL,
    address character varying,
    zipcode character varying,
    longitude double precision,
    latitude double precision,
    avatar character varying,
    slug character varying,
    video_url character varying,
    state character varying,
    age integer,
    overview text NOT NULL,
    community_action text,
    litigation text,
    country character varying,
    remove_avatar boolean,
    summary text NOT NULL,
    follows_count integer DEFAULT 0 NOT NULL,
    default_avatar_url character varying,
    blurb text
);


--
-- Name: cases_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE cases_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cases_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE cases_id_seq OWNED BY cases.id;


--
-- Name: categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE categories (
    id integer NOT NULL,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE categories_id_seq OWNED BY categories.id;


--
-- Name: comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE comments (
    id integer NOT NULL,
    content text,
    commentable_id integer,
    commentable_type character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id integer
);


--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE comments_id_seq OWNED BY comments.id;


--
-- Name: documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE documents (
    id integer NOT NULL,
    title character varying,
    attachment character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: documents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE documents_id_seq OWNED BY documents.id;


--
-- Name: ethnicities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE ethnicities (
    id integer NOT NULL,
    title character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: ethnicities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE ethnicities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ethnicities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE ethnicities_id_seq OWNED BY ethnicities.id;


--
-- Name: event_photos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE event_photos (
    id integer NOT NULL,
    photo character varying,
    calendar_event_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: event_photos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE event_photos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: event_photos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE event_photos_id_seq OWNED BY event_photos.id;


--
-- Name: event_statuses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE event_statuses (
    id integer NOT NULL,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: event_statuses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE event_statuses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: event_statuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE event_statuses_id_seq OWNED BY event_statuses.id;


--
-- Name: follows; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE follows (
    id integer NOT NULL,
    followable_id integer NOT NULL,
    followable_type character varying NOT NULL,
    follower_id integer NOT NULL,
    follower_type character varying NOT NULL,
    blocked boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: follows_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE follows_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: follows_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE follows_id_seq OWNED BY follows.id;


--
-- Name: friendly_id_slugs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE friendly_id_slugs (
    id integer NOT NULL,
    slug character varying NOT NULL,
    sluggable_id integer NOT NULL,
    sluggable_type character varying(50),
    scope character varying,
    created_at timestamp without time zone
);


--
-- Name: friendly_id_slugs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE friendly_id_slugs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: friendly_id_slugs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE friendly_id_slugs_id_seq OWNED BY friendly_id_slugs.id;


--
-- Name: genders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE genders (
    id integer NOT NULL,
    sex character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: genders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE genders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: genders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE genders_id_seq OWNED BY genders.id;


--
-- Name: links; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE links (
    id integer NOT NULL,
    url character varying,
    linkable_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    title character varying,
    linkable_type character varying
);


--
-- Name: links_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: links_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE links_id_seq OWNED BY links.id;


--
-- Name: mailboxer_conversation_opt_outs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE mailboxer_conversation_opt_outs (
    id integer NOT NULL,
    unsubscriber_id integer,
    unsubscriber_type character varying,
    conversation_id integer
);


--
-- Name: mailboxer_conversation_opt_outs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE mailboxer_conversation_opt_outs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mailboxer_conversation_opt_outs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE mailboxer_conversation_opt_outs_id_seq OWNED BY mailboxer_conversation_opt_outs.id;


--
-- Name: mailboxer_conversations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE mailboxer_conversations (
    id integer NOT NULL,
    subject character varying DEFAULT ''::character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: mailboxer_conversations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE mailboxer_conversations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mailboxer_conversations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE mailboxer_conversations_id_seq OWNED BY mailboxer_conversations.id;


--
-- Name: mailboxer_notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE mailboxer_notifications (
    id integer NOT NULL,
    type character varying,
    body text,
    subject character varying DEFAULT ''::character varying,
    sender_id integer,
    sender_type character varying,
    conversation_id integer,
    draft boolean DEFAULT false,
    notification_code character varying,
    notified_object_id integer,
    notified_object_type character varying,
    attachment character varying,
    updated_at timestamp without time zone NOT NULL,
    created_at timestamp without time zone NOT NULL,
    global boolean DEFAULT false,
    expires timestamp without time zone
);


--
-- Name: mailboxer_notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE mailboxer_notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mailboxer_notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE mailboxer_notifications_id_seq OWNED BY mailboxer_notifications.id;


--
-- Name: mailboxer_receipts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE mailboxer_receipts (
    id integer NOT NULL,
    receiver_id integer,
    receiver_type character varying,
    notification_id integer NOT NULL,
    is_read boolean DEFAULT false,
    trashed boolean DEFAULT false,
    deleted boolean DEFAULT false,
    mailbox_type character varying(25),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: mailboxer_receipts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE mailboxer_receipts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mailboxer_receipts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE mailboxer_receipts_id_seq OWNED BY mailboxer_receipts.id;


--
-- Name: organizations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE organizations (
    id integer NOT NULL,
    name character varying,
    description text,
    website character varying,
    telephone character varying,
    avatar character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: organizations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE organizations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organizations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE organizations_id_seq OWNED BY organizations.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE sessions (
    id integer NOT NULL,
    session_id character varying NOT NULL,
    data text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE sessions_id_seq OWNED BY sessions.id;


--
-- Name: states; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE states (
    id integer NOT NULL,
    name character varying,
    iso character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    ansi_code character varying,
    slug character varying
);


--
-- Name: states_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE states_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: states_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE states_id_seq OWNED BY states.id;


--
-- Name: subjects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE subjects (
    id integer NOT NULL,
    name character varying NOT NULL,
    age integer,
    gender_id integer,
    ethnicity_id integer,
    unarmed boolean,
    mentally_ill boolean,
    veteran boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    case_id integer,
    homeless boolean
);


--
-- Name: subjects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE subjects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: subjects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE subjects_id_seq OWNED BY subjects.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE users (
    id integer NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip inet,
    last_sign_in_ip inet,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    admin boolean DEFAULT false,
    latitude double precision,
    longitude double precision,
    storytime_name character varying,
    name character varying NOT NULL,
    description text,
    state_id integer,
    state character varying,
    city character varying,
    facebook_url character varying,
    twitter_url character varying,
    linkedin character varying,
    slug character varying,
    subscribed boolean,
    analyst boolean DEFAULT false
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: version_associations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE version_associations (
    id integer NOT NULL,
    version_id integer,
    foreign_key_name character varying NOT NULL,
    foreign_key_id integer
);


--
-- Name: version_associations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE version_associations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: version_associations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE version_associations_id_seq OWNED BY version_associations.id;


--
-- Name: versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE versions (
    id integer NOT NULL,
    item_type character varying NOT NULL,
    item_id integer NOT NULL,
    event character varying NOT NULL,
    whodunnit character varying,
    object text,
    created_at timestamp without time zone,
    object_changes text,
    ip character varying,
    transaction_id integer,
    comment text DEFAULT ''::text,
    author_id integer
);


--
-- Name: versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE versions_id_seq OWNED BY versions.id;


--
-- Name: visits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE visits (
    id uuid NOT NULL,
    visitor_id uuid,
    ip character varying,
    user_agent text,
    referrer text,
    landing_page text,
    user_id integer,
    referring_domain character varying,
    search_keyword character varying,
    browser character varying,
    os character varying,
    device_type character varying,
    screen_height integer,
    screen_width integer,
    country character varying,
    region character varying,
    city character varying,
    utm_source character varying,
    utm_medium character varying,
    utm_term character varying,
    utm_content character varying,
    utm_campaign character varying,
    started_at timestamp without time zone
);


--
-- Name: agencies id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY agencies ALTER COLUMN id SET DEFAULT nextval('agencies_id_seq'::regclass);


--
-- Name: article_documents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY article_documents ALTER COLUMN id SET DEFAULT nextval('article_documents_id_seq'::regclass);


--
-- Name: calendar_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY calendar_events ALTER COLUMN id SET DEFAULT nextval('calendar_events_id_seq'::regclass);


--
-- Name: case_agencies id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY case_agencies ALTER COLUMN id SET DEFAULT nextval('case_agencies_id_seq'::regclass);


--
-- Name: case_officers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY case_officers ALTER COLUMN id SET DEFAULT nextval('case_officers_id_seq'::regclass);


--
-- Name: cases id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY cases ALTER COLUMN id SET DEFAULT nextval('cases_id_seq'::regclass);


--
-- Name: categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY categories ALTER COLUMN id SET DEFAULT nextval('categories_id_seq'::regclass);


--
-- Name: comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY comments ALTER COLUMN id SET DEFAULT nextval('comments_id_seq'::regclass);


--
-- Name: documents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY documents ALTER COLUMN id SET DEFAULT nextval('documents_id_seq'::regclass);


--
-- Name: ethnicities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY ethnicities ALTER COLUMN id SET DEFAULT nextval('ethnicities_id_seq'::regclass);


--
-- Name: event_photos id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY event_photos ALTER COLUMN id SET DEFAULT nextval('event_photos_id_seq'::regclass);


--
-- Name: event_statuses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY event_statuses ALTER COLUMN id SET DEFAULT nextval('event_statuses_id_seq'::regclass);


--
-- Name: follows id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY follows ALTER COLUMN id SET DEFAULT nextval('follows_id_seq'::regclass);


--
-- Name: friendly_id_slugs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY friendly_id_slugs ALTER COLUMN id SET DEFAULT nextval('friendly_id_slugs_id_seq'::regclass);


--
-- Name: genders id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY genders ALTER COLUMN id SET DEFAULT nextval('genders_id_seq'::regclass);


--
-- Name: links id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY links ALTER COLUMN id SET DEFAULT nextval('links_id_seq'::regclass);


--
-- Name: mailboxer_conversation_opt_outs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY mailboxer_conversation_opt_outs ALTER COLUMN id SET DEFAULT nextval('mailboxer_conversation_opt_outs_id_seq'::regclass);


--
-- Name: mailboxer_conversations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY mailboxer_conversations ALTER COLUMN id SET DEFAULT nextval('mailboxer_conversations_id_seq'::regclass);


--
-- Name: mailboxer_notifications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY mailboxer_notifications ALTER COLUMN id SET DEFAULT nextval('mailboxer_notifications_id_seq'::regclass);


--
-- Name: mailboxer_receipts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY mailboxer_receipts ALTER COLUMN id SET DEFAULT nextval('mailboxer_receipts_id_seq'::regclass);


--
-- Name: organizations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY organizations ALTER COLUMN id SET DEFAULT nextval('organizations_id_seq'::regclass);


--
-- Name: sessions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY sessions ALTER COLUMN id SET DEFAULT nextval('sessions_id_seq'::regclass);


--
-- Name: states id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY states ALTER COLUMN id SET DEFAULT nextval('states_id_seq'::regclass);


--
-- Name: subjects id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY subjects ALTER COLUMN id SET DEFAULT nextval('subjects_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: version_associations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY version_associations ALTER COLUMN id SET DEFAULT nextval('version_associations_id_seq'::regclass);


--
-- Name: versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY versions ALTER COLUMN id SET DEFAULT nextval('versions_id_seq'::regclass);


--
-- Name: agencies agencies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY agencies
    ADD CONSTRAINT agencies_pkey PRIMARY KEY (id);


--
-- Name: ahoy_events ahoy_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ahoy_events
    ADD CONSTRAINT ahoy_events_pkey PRIMARY KEY (id);


--
-- Name: article_documents article_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY article_documents
    ADD CONSTRAINT article_documents_pkey PRIMARY KEY (id);


--
-- Name: calendar_events calendar_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY calendar_events
    ADD CONSTRAINT calendar_events_pkey PRIMARY KEY (id);


--
-- Name: case_agencies case_agencies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY case_agencies
    ADD CONSTRAINT case_agencies_pkey PRIMARY KEY (id);


--
-- Name: case_officers case_officers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY case_officers
    ADD CONSTRAINT case_officers_pkey PRIMARY KEY (id);


--
-- Name: cases cases_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY cases
    ADD CONSTRAINT cases_pkey PRIMARY KEY (id);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: documents documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY documents
    ADD CONSTRAINT documents_pkey PRIMARY KEY (id);


--
-- Name: ethnicities ethnicities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ethnicities
    ADD CONSTRAINT ethnicities_pkey PRIMARY KEY (id);


--
-- Name: event_photos event_photos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY event_photos
    ADD CONSTRAINT event_photos_pkey PRIMARY KEY (id);


--
-- Name: event_statuses event_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY event_statuses
    ADD CONSTRAINT event_statuses_pkey PRIMARY KEY (id);


--
-- Name: follows follows_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY follows
    ADD CONSTRAINT follows_pkey PRIMARY KEY (id);


--
-- Name: friendly_id_slugs friendly_id_slugs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY friendly_id_slugs
    ADD CONSTRAINT friendly_id_slugs_pkey PRIMARY KEY (id);


--
-- Name: genders genders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY genders
    ADD CONSTRAINT genders_pkey PRIMARY KEY (id);


--
-- Name: links links_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY links
    ADD CONSTRAINT links_pkey PRIMARY KEY (id);


--
-- Name: mailboxer_conversation_opt_outs mailboxer_conversation_opt_outs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY mailboxer_conversation_opt_outs
    ADD CONSTRAINT mailboxer_conversation_opt_outs_pkey PRIMARY KEY (id);


--
-- Name: mailboxer_conversations mailboxer_conversations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY mailboxer_conversations
    ADD CONSTRAINT mailboxer_conversations_pkey PRIMARY KEY (id);


--
-- Name: mailboxer_notifications mailboxer_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY mailboxer_notifications
    ADD CONSTRAINT mailboxer_notifications_pkey PRIMARY KEY (id);


--
-- Name: mailboxer_receipts mailboxer_receipts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY mailboxer_receipts
    ADD CONSTRAINT mailboxer_receipts_pkey PRIMARY KEY (id);


--
-- Name: organizations organizations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY organizations
    ADD CONSTRAINT organizations_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: states states_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY states
    ADD CONSTRAINT states_pkey PRIMARY KEY (id);


--
-- Name: subjects subjects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY subjects
    ADD CONSTRAINT subjects_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: version_associations version_associations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY version_associations
    ADD CONSTRAINT version_associations_pkey PRIMARY KEY (id);


--
-- Name: versions versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY versions
    ADD CONSTRAINT versions_pkey PRIMARY KEY (id);


--
-- Name: visits visits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY visits
    ADD CONSTRAINT visits_pkey PRIMARY KEY (id);


--
-- Name: fk_followables; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX fk_followables ON follows USING btree (followable_id, followable_type);


--
-- Name: fk_follows; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX fk_follows ON follows USING btree (follower_id, follower_type);


--
-- Name: index_ahoy_events_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ahoy_events_on_name ON ahoy_events USING btree (name);


--
-- Name: index_ahoy_events_on_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ahoy_events_on_time ON ahoy_events USING btree ("time");


--
-- Name: index_ahoy_events_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ahoy_events_on_user_id ON ahoy_events USING btree (user_id);


--
-- Name: index_ahoy_events_on_visit_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ahoy_events_on_visit_id ON ahoy_events USING btree (visit_id);


--
-- Name: index_cases_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_cases_on_slug ON cases USING btree (slug);


--
-- Name: index_cases_on_title; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cases_on_title ON cases USING btree (title);


--
-- Name: index_cases_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cases_on_user_id ON cases USING btree (user_id);


--
-- Name: index_comments_on_commentable_id_and_commentable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comments_on_commentable_id_and_commentable_type ON comments USING btree (commentable_id, commentable_type);


--
-- Name: index_follows_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_follows_on_created_at ON follows USING btree (created_at);


--
-- Name: index_friendly_id_slugs_on_slug_and_sluggable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_friendly_id_slugs_on_slug_and_sluggable_type ON friendly_id_slugs USING btree (slug, sluggable_type);


--
-- Name: index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope ON friendly_id_slugs USING btree (slug, sluggable_type, scope);


--
-- Name: index_friendly_id_slugs_on_sluggable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_friendly_id_slugs_on_sluggable_id ON friendly_id_slugs USING btree (sluggable_id);


--
-- Name: index_friendly_id_slugs_on_sluggable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_friendly_id_slugs_on_sluggable_type ON friendly_id_slugs USING btree (sluggable_type);


--
-- Name: index_links_on_linkable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_links_on_linkable_id ON links USING btree (linkable_id);


--
-- Name: index_links_on_linkable_id_and_linkable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_links_on_linkable_id_and_linkable_type ON links USING btree (linkable_id, linkable_type);


--
-- Name: index_mailboxer_conversation_opt_outs_on_conversation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_mailboxer_conversation_opt_outs_on_conversation_id ON mailboxer_conversation_opt_outs USING btree (conversation_id);


--
-- Name: index_mailboxer_conversation_opt_outs_on_unsubscriber_id_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_mailboxer_conversation_opt_outs_on_unsubscriber_id_type ON mailboxer_conversation_opt_outs USING btree (unsubscriber_id, unsubscriber_type);


--
-- Name: index_mailboxer_notifications_on_conversation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_mailboxer_notifications_on_conversation_id ON mailboxer_notifications USING btree (conversation_id);


--
-- Name: index_mailboxer_notifications_on_notified_object_id_and_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_mailboxer_notifications_on_notified_object_id_and_type ON mailboxer_notifications USING btree (notified_object_id, notified_object_type);


--
-- Name: index_mailboxer_notifications_on_sender_id_and_sender_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_mailboxer_notifications_on_sender_id_and_sender_type ON mailboxer_notifications USING btree (sender_id, sender_type);


--
-- Name: index_mailboxer_notifications_on_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_mailboxer_notifications_on_type ON mailboxer_notifications USING btree (type);


--
-- Name: index_mailboxer_receipts_on_notification_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_mailboxer_receipts_on_notification_id ON mailboxer_receipts USING btree (notification_id);


--
-- Name: index_mailboxer_receipts_on_receiver_id_and_receiver_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_mailboxer_receipts_on_receiver_id_and_receiver_type ON mailboxer_receipts USING btree (receiver_id, receiver_type);


--
-- Name: index_sessions_on_session_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_sessions_on_session_id ON sessions USING btree (session_id);


--
-- Name: index_sessions_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sessions_on_updated_at ON sessions USING btree (updated_at);


--
-- Name: index_states_on_ansi_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_states_on_ansi_code ON states USING btree (ansi_code);


--
-- Name: index_states_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_states_on_name ON states USING btree (name);


--
-- Name: index_users_on_admin; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_admin ON users USING btree (admin);


--
-- Name: index_users_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_created_at ON users USING btree (created_at);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: index_users_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_slug ON users USING btree (slug);


--
-- Name: index_version_associations_on_foreign_key; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_version_associations_on_foreign_key ON version_associations USING btree (foreign_key_name, foreign_key_id);


--
-- Name: index_version_associations_on_version_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_version_associations_on_version_id ON version_associations USING btree (version_id);


--
-- Name: index_versions_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_versions_on_item_type_and_item_id ON versions USING btree (item_type, item_id);


--
-- Name: index_versions_on_transaction_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_versions_on_transaction_id ON versions USING btree (transaction_id);


--
-- Name: index_visits_on_started_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_visits_on_started_at ON visits USING btree (started_at);


--
-- Name: index_visits_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_visits_on_user_id ON visits USING btree (user_id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: links fk_rails_d221076f62; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY links
    ADD CONSTRAINT fk_rails_d221076f62 FOREIGN KEY (linkable_id) REFERENCES cases(id);


--
-- Name: mailboxer_conversation_opt_outs mb_opt_outs_on_conversations_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY mailboxer_conversation_opt_outs
    ADD CONSTRAINT mb_opt_outs_on_conversations_id FOREIGN KEY (conversation_id) REFERENCES mailboxer_conversations(id);


--
-- Name: mailboxer_notifications notifications_on_conversation_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY mailboxer_notifications
    ADD CONSTRAINT notifications_on_conversation_id FOREIGN KEY (conversation_id) REFERENCES mailboxer_conversations(id);


--
-- Name: mailboxer_receipts receipts_on_notification_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY mailboxer_receipts
    ADD CONSTRAINT receipts_on_notification_id FOREIGN KEY (notification_id) REFERENCES mailboxer_notifications(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO schema_migrations (version) VALUES ('20150411045119');

INSERT INTO schema_migrations (version) VALUES ('20150411054020');

INSERT INTO schema_migrations (version) VALUES ('20150411054517');

INSERT INTO schema_migrations (version) VALUES ('20150411060853');

INSERT INTO schema_migrations (version) VALUES ('20150411060938');

INSERT INTO schema_migrations (version) VALUES ('20150411122751');

INSERT INTO schema_migrations (version) VALUES ('20150411124715');

INSERT INTO schema_migrations (version) VALUES ('20150411130113');

INSERT INTO schema_migrations (version) VALUES ('20150412010636');

INSERT INTO schema_migrations (version) VALUES ('20150412011843');

INSERT INTO schema_migrations (version) VALUES ('20150412014130');

INSERT INTO schema_migrations (version) VALUES ('20150413164803');

INSERT INTO schema_migrations (version) VALUES ('20150413164945');

INSERT INTO schema_migrations (version) VALUES ('20150415032541');

INSERT INTO schema_migrations (version) VALUES ('20150415044450');

INSERT INTO schema_migrations (version) VALUES ('20150415044451');

INSERT INTO schema_migrations (version) VALUES ('20150415144255');

INSERT INTO schema_migrations (version) VALUES ('20150415171903');

INSERT INTO schema_migrations (version) VALUES ('20150415173749');

INSERT INTO schema_migrations (version) VALUES ('20150415182911');

INSERT INTO schema_migrations (version) VALUES ('20150415183753');

INSERT INTO schema_migrations (version) VALUES ('20150416173320');

INSERT INTO schema_migrations (version) VALUES ('20150419221553');

INSERT INTO schema_migrations (version) VALUES ('20150420183623');

INSERT INTO schema_migrations (version) VALUES ('20150427111411');

INSERT INTO schema_migrations (version) VALUES ('20150430114813');

INSERT INTO schema_migrations (version) VALUES ('20150430115058');

INSERT INTO schema_migrations (version) VALUES ('20150430115608');

INSERT INTO schema_migrations (version) VALUES ('20150501015011');

INSERT INTO schema_migrations (version) VALUES ('20150516015757');

INSERT INTO schema_migrations (version) VALUES ('20150516015758');

INSERT INTO schema_migrations (version) VALUES ('20150516015759');

INSERT INTO schema_migrations (version) VALUES ('20150516015760');

INSERT INTO schema_migrations (version) VALUES ('20150516015761');

INSERT INTO schema_migrations (version) VALUES ('20150516015762');

INSERT INTO schema_migrations (version) VALUES ('20150516015763');

INSERT INTO schema_migrations (version) VALUES ('20150516015764');

INSERT INTO schema_migrations (version) VALUES ('20150516015765');

INSERT INTO schema_migrations (version) VALUES ('20150516015766');

INSERT INTO schema_migrations (version) VALUES ('20150516015767');

INSERT INTO schema_migrations (version) VALUES ('20150516015768');

INSERT INTO schema_migrations (version) VALUES ('20150516015769');

INSERT INTO schema_migrations (version) VALUES ('20150516015770');

INSERT INTO schema_migrations (version) VALUES ('20150516015771');

INSERT INTO schema_migrations (version) VALUES ('20150516015772');

INSERT INTO schema_migrations (version) VALUES ('20150516015773');

INSERT INTO schema_migrations (version) VALUES ('20150516015774');

INSERT INTO schema_migrations (version) VALUES ('20150516015775');

INSERT INTO schema_migrations (version) VALUES ('20150516015776');

INSERT INTO schema_migrations (version) VALUES ('20150516015777');

INSERT INTO schema_migrations (version) VALUES ('20150516015778');

INSERT INTO schema_migrations (version) VALUES ('20150516015779');

INSERT INTO schema_migrations (version) VALUES ('20150516015780');

INSERT INTO schema_migrations (version) VALUES ('20150516015781');

INSERT INTO schema_migrations (version) VALUES ('20150516015782');

INSERT INTO schema_migrations (version) VALUES ('20150516015783');

INSERT INTO schema_migrations (version) VALUES ('20150516015784');

INSERT INTO schema_migrations (version) VALUES ('20150516015785');

INSERT INTO schema_migrations (version) VALUES ('20150516015786');

INSERT INTO schema_migrations (version) VALUES ('20150516015787');

INSERT INTO schema_migrations (version) VALUES ('20150516015788');

INSERT INTO schema_migrations (version) VALUES ('20150516015789');

INSERT INTO schema_migrations (version) VALUES ('20150516015790');

INSERT INTO schema_migrations (version) VALUES ('20150516015791');

INSERT INTO schema_migrations (version) VALUES ('20150516015792');

INSERT INTO schema_migrations (version) VALUES ('20150516015793');

INSERT INTO schema_migrations (version) VALUES ('20150516015794');

INSERT INTO schema_migrations (version) VALUES ('20150516015795');

INSERT INTO schema_migrations (version) VALUES ('20150516015796');

INSERT INTO schema_migrations (version) VALUES ('20150516015797');

INSERT INTO schema_migrations (version) VALUES ('20150516015798');

INSERT INTO schema_migrations (version) VALUES ('20150516015799');

INSERT INTO schema_migrations (version) VALUES ('20150516015800');

INSERT INTO schema_migrations (version) VALUES ('20150516015801');

INSERT INTO schema_migrations (version) VALUES ('20150516015802');

INSERT INTO schema_migrations (version) VALUES ('20150516015803');

INSERT INTO schema_migrations (version) VALUES ('20150516015804');

INSERT INTO schema_migrations (version) VALUES ('20150610134530');

INSERT INTO schema_migrations (version) VALUES ('20150610145558');

INSERT INTO schema_migrations (version) VALUES ('20150610152921');

INSERT INTO schema_migrations (version) VALUES ('20150610153742');

INSERT INTO schema_migrations (version) VALUES ('20150610155451');

INSERT INTO schema_migrations (version) VALUES ('20150613024616');

INSERT INTO schema_migrations (version) VALUES ('20150613024617');

INSERT INTO schema_migrations (version) VALUES ('20150616144746');

INSERT INTO schema_migrations (version) VALUES ('20150616145710');

INSERT INTO schema_migrations (version) VALUES ('20150620052647');

INSERT INTO schema_migrations (version) VALUES ('20150621123958');

INSERT INTO schema_migrations (version) VALUES ('20150627182101');

INSERT INTO schema_migrations (version) VALUES ('20150627214620');

INSERT INTO schema_migrations (version) VALUES ('20150627214621');

INSERT INTO schema_migrations (version) VALUES ('20150627214622');

INSERT INTO schema_migrations (version) VALUES ('20150628111851');

INSERT INTO schema_migrations (version) VALUES ('20150703173803');

INSERT INTO schema_migrations (version) VALUES ('20150704214350');

INSERT INTO schema_migrations (version) VALUES ('20150711165418');

INSERT INTO schema_migrations (version) VALUES ('20150711171226');

INSERT INTO schema_migrations (version) VALUES ('20150711220852');

INSERT INTO schema_migrations (version) VALUES ('20150711223508');

INSERT INTO schema_migrations (version) VALUES ('20150716081959');

INSERT INTO schema_migrations (version) VALUES ('20150721210914');

INSERT INTO schema_migrations (version) VALUES ('20150724221034');

INSERT INTO schema_migrations (version) VALUES ('20150728144434');

INSERT INTO schema_migrations (version) VALUES ('20150728144741');

INSERT INTO schema_migrations (version) VALUES ('20150728160532');

INSERT INTO schema_migrations (version) VALUES ('20150728160732');

INSERT INTO schema_migrations (version) VALUES ('20150728161406');

INSERT INTO schema_migrations (version) VALUES ('20150730023101');

INSERT INTO schema_migrations (version) VALUES ('20150731024304');

INSERT INTO schema_migrations (version) VALUES ('20150806203252');

INSERT INTO schema_migrations (version) VALUES ('20150806203403');

INSERT INTO schema_migrations (version) VALUES ('20150905173353');

INSERT INTO schema_migrations (version) VALUES ('20150906203304');

INSERT INTO schema_migrations (version) VALUES ('20160130190718');

INSERT INTO schema_migrations (version) VALUES ('20160130193631');

INSERT INTO schema_migrations (version) VALUES ('20160130200139');

INSERT INTO schema_migrations (version) VALUES ('20160316002607');

INSERT INTO schema_migrations (version) VALUES ('20160316005234');

INSERT INTO schema_migrations (version) VALUES ('20160316010947');

INSERT INTO schema_migrations (version) VALUES ('20160323064052');

INSERT INTO schema_migrations (version) VALUES ('20160515184220');

INSERT INTO schema_migrations (version) VALUES ('20160517083501');

INSERT INTO schema_migrations (version) VALUES ('20160517095316');

INSERT INTO schema_migrations (version) VALUES ('20160613161246');

INSERT INTO schema_migrations (version) VALUES ('20160627185018');

INSERT INTO schema_migrations (version) VALUES ('20160629194154');

INSERT INTO schema_migrations (version) VALUES ('20160629195510');

INSERT INTO schema_migrations (version) VALUES ('20160630162855');

INSERT INTO schema_migrations (version) VALUES ('20160708194753');

INSERT INTO schema_migrations (version) VALUES ('20160802133753');

INSERT INTO schema_migrations (version) VALUES ('20160802145517');

INSERT INTO schema_migrations (version) VALUES ('20170519002221');

INSERT INTO schema_migrations (version) VALUES ('20170520020651');

INSERT INTO schema_migrations (version) VALUES ('20170919051847');

INSERT INTO schema_migrations (version) VALUES ('20171225015639');

INSERT INTO schema_migrations (version) VALUES ('20171225223154');

INSERT INTO schema_migrations (version) VALUES ('20171229100803');

INSERT INTO schema_migrations (version) VALUES ('20171231160858');

INSERT INTO schema_migrations (version) VALUES ('20180101100036');

INSERT INTO schema_migrations (version) VALUES ('20180102193625');

INSERT INTO schema_migrations (version) VALUES ('20180108015327');

INSERT INTO schema_migrations (version) VALUES ('20180108120907');

INSERT INTO schema_migrations (version) VALUES ('20180108162335');

INSERT INTO schema_migrations (version) VALUES ('20180227022027');

INSERT INTO schema_migrations (version) VALUES ('20180508095145');

INSERT INTO schema_migrations (version) VALUES ('20180607033516');

INSERT INTO schema_migrations (version) VALUES ('20180703071052');

INSERT INTO schema_migrations (version) VALUES ('20180712191243');

INSERT INTO schema_migrations (version) VALUES ('20180716121459');

INSERT INTO schema_migrations (version) VALUES ('20180729010543');

INSERT INTO schema_migrations (version) VALUES ('20180816124609');

INSERT INTO schema_migrations (version) VALUES ('20180904123943');

INSERT INTO schema_migrations (version) VALUES ('20180911071251');

INSERT INTO schema_migrations (version) VALUES ('20180926083147');

INSERT INTO schema_migrations (version) VALUES ('20180926085044');

INSERT INTO schema_migrations (version) VALUES ('20180926091204');

INSERT INTO schema_migrations (version) VALUES ('20180926092536');

INSERT INTO schema_migrations (version) VALUES ('20180926123043');

INSERT INTO schema_migrations (version) VALUES ('20181001124317');

INSERT INTO schema_migrations (version) VALUES ('20181003112438');

INSERT INTO schema_migrations (version) VALUES ('20181003130555');

INSERT INTO schema_migrations (version) VALUES ('20181005060647');

INSERT INTO schema_migrations (version) VALUES ('20181008175901');

INSERT INTO schema_migrations (version) VALUES ('20181013103240');

INSERT INTO schema_migrations (version) VALUES ('20181025082828');

INSERT INTO schema_migrations (version) VALUES ('20181025220728');

INSERT INTO schema_migrations (version) VALUES ('20181026005352');

INSERT INTO schema_migrations (version) VALUES ('20190112221750');

INSERT INTO schema_migrations (version) VALUES ('20190112222534');

INSERT INTO schema_migrations (version) VALUES ('20190112223009');

INSERT INTO schema_migrations (version) VALUES ('20190112223318');

INSERT INTO schema_migrations (version) VALUES ('20190112223645');

INSERT INTO schema_migrations (version) VALUES ('20190112224118');

INSERT INTO schema_migrations (version) VALUES ('20190112224451');

INSERT INTO schema_migrations (version) VALUES ('20190112224801');

