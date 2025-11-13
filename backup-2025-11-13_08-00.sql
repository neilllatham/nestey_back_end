--
-- PostgreSQL database dump
--

\restrict hvMqd3l257bgVh5SdnfsApByBC6uaqLHZD7isJkdYUJt2lkQvX1f6KNxMOFdebt

-- Dumped from database version 14.19 (Homebrew)
-- Dumped by pg_dump version 14.19 (Homebrew)

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
-- Name: count_weekdays(date, date); Type: FUNCTION; Schema: public; Owner: neill
--

CREATE FUNCTION public.count_weekdays(start_date date, end_date date) RETURNS integer
    LANGUAGE plpgsql IMMUTABLE
    AS $$
BEGIN
  RETURN (
    SELECT COUNT(*)
    FROM generate_series(start_date, end_date, interval '1 day') AS g(day)
    WHERE EXTRACT(ISODOW FROM g.day) < 6  -- Monday(1) to Friday(5)
  );
END;
$$;


ALTER FUNCTION public.count_weekdays(start_date date, end_date date) OWNER TO neill;

--
-- Name: update_accrual_balance(); Type: FUNCTION; Schema: public; Owner: neill
--

CREATE FUNCTION public.update_accrual_balance() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  workdays INTEGER;
BEGIN
  -- Calculate weekdays between start and end date
  workdays := count_weekdays(NEW.start_date, NEW.end_date);
  NEW.days_requested := workdays;  -- ✅ sets value before insert

  -- Update accruals immediately
  UPDATE time_off_accruals
  SET
    used_days = used_days + workdays,
    remaining_days = GREATEST(accrued_days - (used_days + workdays), 0),
    last_updated = CURRENT_DATE
  WHERE employee_id = NEW.employee_id
    AND type = NEW.type
    AND year = EXTRACT(YEAR FROM NEW.start_date);

  RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_accrual_balance() OWNER TO neill;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: applications; Type: TABLE; Schema: public; Owner: neill
--

CREATE TABLE public.applications (
    application_id integer NOT NULL,
    candidate_id integer,
    job_posting_id integer,
    source character varying,
    status character varying,
    applied_date date,
    last_updated timestamp without time zone
);


ALTER TABLE public.applications OWNER TO neill;

--
-- Name: applications_application_id_seq; Type: SEQUENCE; Schema: public; Owner: neill
--

CREATE SEQUENCE public.applications_application_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.applications_application_id_seq OWNER TO neill;

--
-- Name: applications_application_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neill
--

ALTER SEQUENCE public.applications_application_id_seq OWNED BY public.applications.application_id;


--
-- Name: benefit_plan; Type: TABLE; Schema: public; Owner: neill
--

CREATE TABLE public.benefit_plan (
    benefit_plan_id integer NOT NULL,
    plan_name character varying,
    coverage_level character varying,
    region character varying,
    employer_contribution numeric(3,2),
    employee_contribution numeric(3,2),
    effective_date date,
    expiry_date date,
    type character varying
);


ALTER TABLE public.benefit_plan OWNER TO neill;

--
-- Name: benefit_plan_benefit_plan_id_seq; Type: SEQUENCE; Schema: public; Owner: neill
--

CREATE SEQUENCE public.benefit_plan_benefit_plan_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.benefit_plan_benefit_plan_id_seq OWNER TO neill;

--
-- Name: benefit_plan_benefit_plan_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neill
--

ALTER SEQUENCE public.benefit_plan_benefit_plan_id_seq OWNED BY public.benefit_plan.benefit_plan_id;


--
-- Name: benefits_catalog; Type: TABLE; Schema: public; Owner: neill
--

CREATE TABLE public.benefits_catalog (
    benefit_catalog_id integer NOT NULL,
    benefit_name character varying,
    benefit_category character varying,
    description character varying,
    employer_contribution numeric(3,2),
    employee_contribution numeric(3,2),
    dependent_coverage_allowed boolean,
    eligibility_criteria character varying,
    created_at date,
    updated_at date,
    benefit_plan_id integer,
    employee_pays numeric(10,2),
    employer_pays numeric(10,2),
    total_plan_cost numeric(10,2),
    enrollment_start_date date DEFAULT '2025-11-01'::date,
    enrollment_end_date date DEFAULT '2025-11-30'::date
);


ALTER TABLE public.benefits_catalog OWNER TO neill;

--
-- Name: benefits_catalog_benefit_catalog_id_seq; Type: SEQUENCE; Schema: public; Owner: neill
--

CREATE SEQUENCE public.benefits_catalog_benefit_catalog_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.benefits_catalog_benefit_catalog_id_seq OWNER TO neill;

--
-- Name: benefits_catalog_benefit_catalog_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neill
--

ALTER SEQUENCE public.benefits_catalog_benefit_catalog_id_seq OWNED BY public.benefits_catalog.benefit_catalog_id;


--
-- Name: candidates; Type: TABLE; Schema: public; Owner: neill
--

CREATE TABLE public.candidates (
    candidate_id integer NOT NULL,
    first_name character varying,
    last_name character varying,
    email character varying,
    phone character varying,
    resume_url character varying,
    linkedin_profile character varying,
    referred_by integer,
    current_company character varying,
    notes text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.candidates OWNER TO neill;

--
-- Name: candidates_candidate_id_seq; Type: SEQUENCE; Schema: public; Owner: neill
--

CREATE SEQUENCE public.candidates_candidate_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.candidates_candidate_id_seq OWNER TO neill;

--
-- Name: candidates_candidate_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neill
--

ALTER SEQUENCE public.candidates_candidate_id_seq OWNED BY public.candidates.candidate_id;


--
-- Name: competencies; Type: TABLE; Schema: public; Owner: neill
--

CREATE TABLE public.competencies (
    competency_id integer NOT NULL,
    competency_name character varying NOT NULL,
    description text
);


ALTER TABLE public.competencies OWNER TO neill;

--
-- Name: competencies_competency_id_seq; Type: SEQUENCE; Schema: public; Owner: neill
--

CREATE SEQUENCE public.competencies_competency_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.competencies_competency_id_seq OWNER TO neill;

--
-- Name: competencies_competency_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neill
--

ALTER SEQUENCE public.competencies_competency_id_seq OWNED BY public.competencies.competency_id;


--
-- Name: competency_definitions; Type: TABLE; Schema: public; Owner: neill
--

CREATE TABLE public.competency_definitions (
    competency_def_id integer NOT NULL,
    role_level_code character varying(10) NOT NULL,
    competency_id integer NOT NULL,
    expected_behavior text NOT NULL
);


ALTER TABLE public.competency_definitions OWNER TO neill;

--
-- Name: competency_definitions_competency_def_id_seq; Type: SEQUENCE; Schema: public; Owner: neill
--

CREATE SEQUENCE public.competency_definitions_competency_def_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.competency_definitions_competency_def_id_seq OWNER TO neill;

--
-- Name: competency_definitions_competency_def_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neill
--

ALTER SEQUENCE public.competency_definitions_competency_def_id_seq OWNED BY public.competency_definitions.competency_def_id;


--
-- Name: core_competencies; Type: TABLE; Schema: public; Owner: neill
--

CREATE TABLE public.core_competencies (
    competency_id integer NOT NULL,
    competency_name character varying(100) NOT NULL,
    description text
);


ALTER TABLE public.core_competencies OWNER TO neill;

--
-- Name: core_competencies_competency_id_seq; Type: SEQUENCE; Schema: public; Owner: neill
--

CREATE SEQUENCE public.core_competencies_competency_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.core_competencies_competency_id_seq OWNER TO neill;

--
-- Name: core_competencies_competency_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neill
--

ALTER SEQUENCE public.core_competencies_competency_id_seq OWNED BY public.core_competencies.competency_id;


--
-- Name: departments; Type: TABLE; Schema: public; Owner: neill
--

CREATE TABLE public.departments (
    department_id integer NOT NULL,
    department_name character varying,
    function_id integer
);


ALTER TABLE public.departments OWNER TO neill;

--
-- Name: departments_department_id_seq; Type: SEQUENCE; Schema: public; Owner: neill
--

CREATE SEQUENCE public.departments_department_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.departments_department_id_seq OWNER TO neill;

--
-- Name: departments_department_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neill
--

ALTER SEQUENCE public.departments_department_id_seq OWNED BY public.departments.department_id;


--
-- Name: employee_benefits; Type: TABLE; Schema: public; Owner: neill
--

CREATE TABLE public.employee_benefits (
    employee_benefit_id integer NOT NULL,
    employee_id integer,
    benefit_plan_id integer,
    dependants integer,
    effective_date date,
    expiry_date date,
    date_created date,
    date_updated date
);


ALTER TABLE public.employee_benefits OWNER TO neill;

--
-- Name: employee_benefits_employee_benefit_id_seq; Type: SEQUENCE; Schema: public; Owner: neill
--

CREATE SEQUENCE public.employee_benefits_employee_benefit_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.employee_benefits_employee_benefit_id_seq OWNER TO neill;

--
-- Name: employee_benefits_employee_benefit_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neill
--

ALTER SEQUENCE public.employee_benefits_employee_benefit_id_seq OWNED BY public.employee_benefits.employee_benefit_id;


--
-- Name: employee_competencies; Type: TABLE; Schema: public; Owner: neill
--

CREATE TABLE public.employee_competencies (
    employee_competency_id integer NOT NULL,
    review_id integer,
    competency_id integer,
    employee_rating integer,
    manager_rating integer,
    employee_comments text,
    manager_comments text
);


ALTER TABLE public.employee_competencies OWNER TO neill;

--
-- Name: employee_competencies_employee_competency_id_seq; Type: SEQUENCE; Schema: public; Owner: neill
--

CREATE SEQUENCE public.employee_competencies_employee_competency_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.employee_competencies_employee_competency_id_seq OWNER TO neill;

--
-- Name: employee_competencies_employee_competency_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neill
--

ALTER SEQUENCE public.employee_competencies_employee_competency_id_seq OWNED BY public.employee_competencies.employee_competency_id;


--
-- Name: employee_goals; Type: TABLE; Schema: public; Owner: neill
--

CREATE TABLE public.employee_goals (
    goal_id integer NOT NULL,
    review_id integer,
    strategy_id integer,
    objective text NOT NULL,
    goal_description text NOT NULL,
    target_date date,
    employee_rating integer,
    manager_rating integer,
    employee_comments text,
    manager_comments text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.employee_goals OWNER TO neill;

--
-- Name: employee_goals_goal_id_seq; Type: SEQUENCE; Schema: public; Owner: neill
--

CREATE SEQUENCE public.employee_goals_goal_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.employee_goals_goal_id_seq OWNER TO neill;

--
-- Name: employee_goals_goal_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neill
--

ALTER SEQUENCE public.employee_goals_goal_id_seq OWNED BY public.employee_goals.goal_id;


--
-- Name: employee_reviews; Type: TABLE; Schema: public; Owner: neill
--

CREATE TABLE public.employee_reviews (
    review_id integer NOT NULL,
    employee_id integer NOT NULL,
    review_cycle_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    review_status character varying,
    submitted_at timestamp without time zone,
    finalized_at timestamp without time zone,
    CONSTRAINT employee_reviews_review_status_check CHECK (((review_status)::text = ANY ((ARRAY['Draft'::character varying, 'Submitted'::character varying, 'Finalized'::character varying])::text[])))
);


ALTER TABLE public.employee_reviews OWNER TO neill;

--
-- Name: employee_reviews_review_id_seq; Type: SEQUENCE; Schema: public; Owner: neill
--

CREATE SEQUENCE public.employee_reviews_review_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.employee_reviews_review_id_seq OWNER TO neill;

--
-- Name: employee_reviews_review_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neill
--

ALTER SEQUENCE public.employee_reviews_review_id_seq OWNED BY public.employee_reviews.review_id;


--
-- Name: employees; Type: TABLE; Schema: public; Owner: neill
--

CREATE TABLE public.employees (
    employee_id integer NOT NULL,
    employee_number character varying,
    first_name character varying,
    middle_initial character varying,
    last_name character varying,
    full_name character varying,
    preferred_name character varying,
    job_title character varying,
    email character varying,
    hire_date timestamp without time zone,
    department_id integer,
    role_id integer,
    manager_id integer,
    status character varying,
    base_salary numeric(10,2),
    bonus_eligible boolean,
    target_bonus numeric(10,2),
    commission_eligible boolean,
    commission_target numeric(4,2),
    compensation_currency character varying,
    date_of_birth date,
    employment_type character varying,
    gender character varying,
    home_address character varying,
    mobile_number character varying,
    hours_per_week numeric(3,1)
);


ALTER TABLE public.employees OWNER TO neill;

--
-- Name: employees_employee_id_seq; Type: SEQUENCE; Schema: public; Owner: neill
--

CREATE SEQUENCE public.employees_employee_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.employees_employee_id_seq OWNER TO neill;

--
-- Name: employees_employee_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neill
--

ALTER SEQUENCE public.employees_employee_id_seq OWNED BY public.employees.employee_id;


--
-- Name: functions; Type: TABLE; Schema: public; Owner: neill
--

CREATE TABLE public.functions (
    function_id integer NOT NULL,
    function_name character varying
);


ALTER TABLE public.functions OWNER TO neill;

--
-- Name: functions_function_id_seq; Type: SEQUENCE; Schema: public; Owner: neill
--

CREATE SEQUENCE public.functions_function_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.functions_function_id_seq OWNER TO neill;

--
-- Name: functions_function_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neill
--

ALTER SEQUENCE public.functions_function_id_seq OWNED BY public.functions.function_id;


--
-- Name: interviews; Type: TABLE; Schema: public; Owner: neill
--

CREATE TABLE public.interviews (
    interview_id integer NOT NULL,
    application_id integer,
    interviewer_id integer,
    interview_date timestamp without time zone,
    interview_type character varying,
    feedback text,
    rating integer,
    decision character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.interviews OWNER TO neill;

--
-- Name: interviews_interview_id_seq; Type: SEQUENCE; Schema: public; Owner: neill
--

CREATE SEQUENCE public.interviews_interview_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.interviews_interview_id_seq OWNER TO neill;

--
-- Name: interviews_interview_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neill
--

ALTER SEQUENCE public.interviews_interview_id_seq OWNED BY public.interviews.interview_id;


--
-- Name: job_families; Type: TABLE; Schema: public; Owner: neill
--

CREATE TABLE public.job_families (
    job_family_id integer NOT NULL,
    job_family_name character varying,
    description character varying
);


ALTER TABLE public.job_families OWNER TO neill;

--
-- Name: job_families_job_family_id_seq; Type: SEQUENCE; Schema: public; Owner: neill
--

CREATE SEQUENCE public.job_families_job_family_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.job_families_job_family_id_seq OWNER TO neill;

--
-- Name: job_families_job_family_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neill
--

ALTER SEQUENCE public.job_families_job_family_id_seq OWNED BY public.job_families.job_family_id;


--
-- Name: job_offers; Type: TABLE; Schema: public; Owner: neill
--

CREATE TABLE public.job_offers (
    offer_id integer NOT NULL,
    application_id integer,
    offered_role_id integer,
    offered_salary numeric(10,2),
    offered_bonus numeric(10,2),
    start_date date,
    offer_status character varying,
    sent_date date,
    accepted_date date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.job_offers OWNER TO neill;

--
-- Name: job_offers_offer_id_seq; Type: SEQUENCE; Schema: public; Owner: neill
--

CREATE SEQUENCE public.job_offers_offer_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.job_offers_offer_id_seq OWNER TO neill;

--
-- Name: job_offers_offer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neill
--

ALTER SEQUENCE public.job_offers_offer_id_seq OWNED BY public.job_offers.offer_id;


--
-- Name: job_postings; Type: TABLE; Schema: public; Owner: neill
--

CREATE TABLE public.job_postings (
    job_posting_id integer NOT NULL,
    title character varying,
    department_id integer,
    role_id integer,
    hiring_manager_id integer,
    location character varying,
    employment_type character varying,
    description text,
    requirements text,
    salary_range_min numeric(10,2),
    salary_range_max numeric(10,2),
    currency character varying,
    status character varying,
    date_posted date,
    date_closed date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.job_postings OWNER TO neill;

--
-- Name: job_postings_job_posting_id_seq; Type: SEQUENCE; Schema: public; Owner: neill
--

CREATE SEQUENCE public.job_postings_job_posting_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.job_postings_job_posting_id_seq OWNER TO neill;

--
-- Name: job_postings_job_posting_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neill
--

ALTER SEQUENCE public.job_postings_job_posting_id_seq OWNED BY public.job_postings.job_posting_id;


--
-- Name: rating_scale; Type: TABLE; Schema: public; Owner: neill
--

CREATE TABLE public.rating_scale (
    rating_value integer NOT NULL,
    rating_label character varying NOT NULL,
    description text
);


ALTER TABLE public.rating_scale OWNER TO neill;

--
-- Name: review_cycles; Type: TABLE; Schema: public; Owner: neill
--

CREATE TABLE public.review_cycles (
    review_cycle_id integer NOT NULL,
    name character varying,
    cycle_type character varying NOT NULL,
    period_start date NOT NULL,
    period_end date NOT NULL,
    midyear_start date,
    midyear_end date,
    status character varying,
    is_active boolean DEFAULT false,
    CONSTRAINT review_cycles_cycle_type_check CHECK (((cycle_type)::text = ANY ((ARRAY['Mid-Year'::character varying, 'Annual'::character varying])::text[]))),
    CONSTRAINT review_cycles_status_check CHECK (((status)::text = ANY ((ARRAY['Draft'::character varying, 'Open'::character varying, 'Closed'::character varying])::text[])))
);


ALTER TABLE public.review_cycles OWNER TO neill;

--
-- Name: review_cycles_review_cycle_id_seq; Type: SEQUENCE; Schema: public; Owner: neill
--

CREATE SEQUENCE public.review_cycles_review_cycle_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.review_cycles_review_cycle_id_seq OWNER TO neill;

--
-- Name: review_cycles_review_cycle_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neill
--

ALTER SEQUENCE public.review_cycles_review_cycle_id_seq OWNED BY public.review_cycles.review_cycle_id;


--
-- Name: role_levels; Type: TABLE; Schema: public; Owner: neill
--

CREATE TABLE public.role_levels (
    role_level_code character varying(10) NOT NULL,
    role_level_name character varying(50) NOT NULL,
    hierarchy_rank integer NOT NULL,
    description text
);


ALTER TABLE public.role_levels OWNER TO neill;

--
-- Name: roles; Type: TABLE; Schema: public; Owner: neill
--

CREATE TABLE public.roles (
    role_id integer NOT NULL,
    role_name character varying,
    parent_role_id integer,
    job_family_id integer,
    description character varying,
    date_created date DEFAULT CURRENT_DATE,
    date_updated date DEFAULT CURRENT_DATE,
    department_id integer,
    role_level_code character varying(10),
    role_level_id integer NOT NULL
);


ALTER TABLE public.roles OWNER TO neill;

--
-- Name: roles_role_id_seq; Type: SEQUENCE; Schema: public; Owner: neill
--

CREATE SEQUENCE public.roles_role_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.roles_role_id_seq OWNER TO neill;

--
-- Name: roles_role_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neill
--

ALTER SEQUENCE public.roles_role_id_seq OWNED BY public.roles.role_id;


--
-- Name: roles_role_level_id_seq; Type: SEQUENCE; Schema: public; Owner: neill
--

CREATE SEQUENCE public.roles_role_level_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.roles_role_level_id_seq OWNER TO neill;

--
-- Name: roles_role_level_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neill
--

ALTER SEQUENCE public.roles_role_level_id_seq OWNED BY public.roles.role_level_id;


--
-- Name: strategies; Type: TABLE; Schema: public; Owner: neill
--

CREATE TABLE public.strategies (
    strategy_id integer NOT NULL,
    strategy_name character varying NOT NULL,
    description text
);


ALTER TABLE public.strategies OWNER TO neill;

--
-- Name: strategies_strategy_id_seq; Type: SEQUENCE; Schema: public; Owner: neill
--

CREATE SEQUENCE public.strategies_strategy_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.strategies_strategy_id_seq OWNER TO neill;

--
-- Name: strategies_strategy_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neill
--

ALTER SEQUENCE public.strategies_strategy_id_seq OWNED BY public.strategies.strategy_id;


--
-- Name: time_off_accruals; Type: TABLE; Schema: public; Owner: neill
--

CREATE TABLE public.time_off_accruals (
    accrual_id integer NOT NULL,
    employee_id integer,
    type character varying,
    year integer,
    accrued_days numeric(5,1),
    used_days numeric(5,1) DEFAULT 0.0,
    remaining_days numeric(5,1),
    last_updated date DEFAULT CURRENT_DATE
);


ALTER TABLE public.time_off_accruals OWNER TO neill;

--
-- Name: time_off_accruals_accrual_id_seq; Type: SEQUENCE; Schema: public; Owner: neill
--

CREATE SEQUENCE public.time_off_accruals_accrual_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.time_off_accruals_accrual_id_seq OWNER TO neill;

--
-- Name: time_off_accruals_accrual_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neill
--

ALTER SEQUENCE public.time_off_accruals_accrual_id_seq OWNED BY public.time_off_accruals.accrual_id;


--
-- Name: time_off_backup; Type: TABLE; Schema: public; Owner: neill
--

CREATE TABLE public.time_off_backup (
    time_off_id integer,
    employee_id integer,
    start_date date,
    end_date date,
    type character varying,
    time_off_amount numeric(5,1),
    time_off_accrued numeric(5,1),
    time_off_balance numeric(5,1),
    date_created date,
    date_updated date
);


ALTER TABLE public.time_off_backup OWNER TO neill;

--
-- Name: time_off_requests; Type: TABLE; Schema: public; Owner: neill
--

CREATE TABLE public.time_off_requests (
    request_id integer NOT NULL,
    employee_id integer,
    type character varying,
    start_date date,
    end_date date,
    days_requested numeric(5,1),
    status character varying DEFAULT 'Approved'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.time_off_requests OWNER TO neill;

--
-- Name: time_off_requests_request_id_seq; Type: SEQUENCE; Schema: public; Owner: neill
--

CREATE SEQUENCE public.time_off_requests_request_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.time_off_requests_request_id_seq OWNER TO neill;

--
-- Name: time_off_requests_request_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neill
--

ALTER SEQUENCE public.time_off_requests_request_id_seq OWNED BY public.time_off_requests.request_id;


--
-- Name: vw_employee_competency_summary; Type: VIEW; Schema: public; Owner: neill
--

CREATE VIEW public.vw_employee_competency_summary AS
 SELECT e.full_name,
    e.employee_id,
    r.role_name,
    r.role_level_code,
    rc.name AS review_cycle,
    rc.cycle_type,
    c.competency_name,
    c.description AS competency_description,
    cd.expected_behavior,
    ec.employee_rating,
    ec.manager_rating,
    ec.employee_comments,
    ec.manager_comments
   FROM ((((((public.employee_competencies ec
     JOIN public.employee_reviews er ON ((ec.review_id = er.review_id)))
     JOIN public.employees e ON ((er.employee_id = e.employee_id)))
     JOIN public.roles r ON ((e.role_id = r.role_id)))
     JOIN public.core_competencies c ON ((ec.competency_id = c.competency_id)))
     JOIN public.review_cycles rc ON ((er.review_cycle_id = rc.review_cycle_id)))
     JOIN public.competency_definitions cd ON (((cd.competency_id = c.competency_id) AND ((cd.role_level_code)::text = (r.role_level_code)::text))))
  ORDER BY e.full_name, c.competency_name;


ALTER TABLE public.vw_employee_competency_summary OWNER TO neill;

--
-- Name: applications application_id; Type: DEFAULT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.applications ALTER COLUMN application_id SET DEFAULT nextval('public.applications_application_id_seq'::regclass);


--
-- Name: benefit_plan benefit_plan_id; Type: DEFAULT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.benefit_plan ALTER COLUMN benefit_plan_id SET DEFAULT nextval('public.benefit_plan_benefit_plan_id_seq'::regclass);


--
-- Name: benefits_catalog benefit_catalog_id; Type: DEFAULT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.benefits_catalog ALTER COLUMN benefit_catalog_id SET DEFAULT nextval('public.benefits_catalog_benefit_catalog_id_seq'::regclass);


--
-- Name: candidates candidate_id; Type: DEFAULT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.candidates ALTER COLUMN candidate_id SET DEFAULT nextval('public.candidates_candidate_id_seq'::regclass);


--
-- Name: competencies competency_id; Type: DEFAULT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.competencies ALTER COLUMN competency_id SET DEFAULT nextval('public.competencies_competency_id_seq'::regclass);


--
-- Name: competency_definitions competency_def_id; Type: DEFAULT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.competency_definitions ALTER COLUMN competency_def_id SET DEFAULT nextval('public.competency_definitions_competency_def_id_seq'::regclass);


--
-- Name: core_competencies competency_id; Type: DEFAULT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.core_competencies ALTER COLUMN competency_id SET DEFAULT nextval('public.core_competencies_competency_id_seq'::regclass);


--
-- Name: departments department_id; Type: DEFAULT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.departments ALTER COLUMN department_id SET DEFAULT nextval('public.departments_department_id_seq'::regclass);


--
-- Name: employee_benefits employee_benefit_id; Type: DEFAULT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.employee_benefits ALTER COLUMN employee_benefit_id SET DEFAULT nextval('public.employee_benefits_employee_benefit_id_seq'::regclass);


--
-- Name: employee_competencies employee_competency_id; Type: DEFAULT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.employee_competencies ALTER COLUMN employee_competency_id SET DEFAULT nextval('public.employee_competencies_employee_competency_id_seq'::regclass);


--
-- Name: employee_goals goal_id; Type: DEFAULT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.employee_goals ALTER COLUMN goal_id SET DEFAULT nextval('public.employee_goals_goal_id_seq'::regclass);


--
-- Name: employee_reviews review_id; Type: DEFAULT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.employee_reviews ALTER COLUMN review_id SET DEFAULT nextval('public.employee_reviews_review_id_seq'::regclass);


--
-- Name: employees employee_id; Type: DEFAULT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.employees ALTER COLUMN employee_id SET DEFAULT nextval('public.employees_employee_id_seq'::regclass);


--
-- Name: functions function_id; Type: DEFAULT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.functions ALTER COLUMN function_id SET DEFAULT nextval('public.functions_function_id_seq'::regclass);


--
-- Name: interviews interview_id; Type: DEFAULT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.interviews ALTER COLUMN interview_id SET DEFAULT nextval('public.interviews_interview_id_seq'::regclass);


--
-- Name: job_families job_family_id; Type: DEFAULT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.job_families ALTER COLUMN job_family_id SET DEFAULT nextval('public.job_families_job_family_id_seq'::regclass);


--
-- Name: job_offers offer_id; Type: DEFAULT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.job_offers ALTER COLUMN offer_id SET DEFAULT nextval('public.job_offers_offer_id_seq'::regclass);


--
-- Name: job_postings job_posting_id; Type: DEFAULT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.job_postings ALTER COLUMN job_posting_id SET DEFAULT nextval('public.job_postings_job_posting_id_seq'::regclass);


--
-- Name: review_cycles review_cycle_id; Type: DEFAULT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.review_cycles ALTER COLUMN review_cycle_id SET DEFAULT nextval('public.review_cycles_review_cycle_id_seq'::regclass);


--
-- Name: roles role_id; Type: DEFAULT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.roles ALTER COLUMN role_id SET DEFAULT nextval('public.roles_role_id_seq'::regclass);


--
-- Name: roles role_level_id; Type: DEFAULT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.roles ALTER COLUMN role_level_id SET DEFAULT nextval('public.roles_role_level_id_seq'::regclass);


--
-- Name: strategies strategy_id; Type: DEFAULT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.strategies ALTER COLUMN strategy_id SET DEFAULT nextval('public.strategies_strategy_id_seq'::regclass);


--
-- Name: time_off_accruals accrual_id; Type: DEFAULT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.time_off_accruals ALTER COLUMN accrual_id SET DEFAULT nextval('public.time_off_accruals_accrual_id_seq'::regclass);


--
-- Name: time_off_requests request_id; Type: DEFAULT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.time_off_requests ALTER COLUMN request_id SET DEFAULT nextval('public.time_off_requests_request_id_seq'::regclass);


--
-- Data for Name: applications; Type: TABLE DATA; Schema: public; Owner: neill
--

COPY public.applications (application_id, candidate_id, job_posting_id, source, status, applied_date, last_updated) FROM stdin;
\.


--
-- Data for Name: benefit_plan; Type: TABLE DATA; Schema: public; Owner: neill
--

COPY public.benefit_plan (benefit_plan_id, plan_name, coverage_level, region, employer_contribution, employee_contribution, effective_date, expiry_date, type) FROM stdin;
1	Aetna PPO Gold	Gold	National	0.80	0.20	2024-01-01	2024-12-31	Medical
2	Blue Cross PPO Silver	Silver	National	0.75	0.25	2024-01-01	2024-12-31	Medical
3	Kaiser HMO Basic	Basic	CA Region	0.85	0.15	2024-01-01	2024-12-31	Medical
4	VSP Vision Premier	Gold	National	0.80	0.20	2024-01-01	2024-12-31	Vision
5	EyeMed Vision Standard	Silver	National	0.75	0.25	2024-01-01	2024-12-31	Vision
6	Delta Dental PPO Premium	Gold	National	0.75	0.25	2024-01-01	2024-12-31	Dental
7	Cigna Dental HMO Basic	Basic	National	0.80	0.20	2024-01-01	2024-12-31	Dental
8	MetLife Basic Life	Standard	National	1.00	0.00	2024-01-01	2024-12-31	Life Insurance
9	Fidelity 401(k) Standard	Standard	National	0.50	0.50	2024-01-01	2024-12-31	Retirement
\.


--
-- Data for Name: benefits_catalog; Type: TABLE DATA; Schema: public; Owner: neill
--

COPY public.benefits_catalog (benefit_catalog_id, benefit_name, benefit_category, description, employer_contribution, employee_contribution, dependent_coverage_allowed, eligibility_criteria, created_at, updated_at, benefit_plan_id, employee_pays, employer_pays, total_plan_cost, enrollment_start_date, enrollment_end_date) FROM stdin;
1	Aetna PPO Gold	Medical	High-tier PPO plan offering broad provider access and low copays.	0.80	0.20	t	Full-time employees	2024-01-01	2024-01-01	1	120.00	480.00	600.00	2025-11-01	2025-11-30
2	Blue Cross PPO Silver	Medical	Mid-tier PPO plan balancing cost and coverage with national network.	0.75	0.25	t	Full-time employees	2024-01-01	2024-01-01	2	150.00	450.00	600.00	2025-11-01	2025-11-30
3	Kaiser HMO Basic	Medical	Managed-care HMO plan offering cost-effective care through Kaiser network providers.	0.85	0.15	t	Full-time employees in CA Region	2024-01-01	2024-01-01	3	90.00	510.00	600.00	2025-11-01	2025-11-30
4	VSP Vision Premier	Vision	Premium vision plan with full-frame allowance and contacts coverage.	0.80	0.20	t	Full-time employees	2024-01-01	2024-01-01	4	2.00	8.00	10.00	2025-11-01	2025-11-30
5	EyeMed Vision Standard	Vision	Affordable plan covering routine eye exams and basic lenses.	0.75	0.25	t	Full-time employees	2024-01-01	2024-01-01	5	2.50	7.50	10.00	2025-11-01	2025-11-30
6	Delta Dental PPO Premium	Dental	Comprehensive PPO dental plan with national coverage and orthodontia options.	0.75	0.25	t	Full-time employees	2024-01-01	2024-01-01	6	5.00	15.00	20.00	2025-11-01	2025-11-30
7	Cigna Dental HMO Basic	Dental	Affordable HMO dental plan with low premiums and in-network coverage.	0.80	0.20	t	Full-time employees	2024-01-01	2024-01-01	7	4.00	16.00	20.00	2025-11-01	2025-11-30
8	MetLife Basic Life	Life Insurance	Company-provided life insurance covering 1x annual salary, fully employer-paid.	1.00	0.00	f	All employees	2024-01-01	2024-01-01	8	0.00	5.00	5.00	2025-11-01	2025-11-30
9	Fidelity 401(k) Standard	Retirement	401(k) retirement savings plan with 50% employer match up to 6% of salary.	0.50	0.50	f	Full-time employees	2024-01-01	2024-01-01	9	\N	\N	\N	2025-11-01	2025-11-30
\.


--
-- Data for Name: candidates; Type: TABLE DATA; Schema: public; Owner: neill
--

COPY public.candidates (candidate_id, first_name, last_name, email, phone, resume_url, linkedin_profile, referred_by, current_company, notes, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: competencies; Type: TABLE DATA; Schema: public; Owner: neill
--

COPY public.competencies (competency_id, competency_name, description) FROM stdin;
\.


--
-- Data for Name: competency_definitions; Type: TABLE DATA; Schema: public; Owner: neill
--

COPY public.competency_definitions (competency_def_id, role_level_code, competency_id, expected_behavior) FROM stdin;
1	IC1	1	Communicates clearly within their team and keeps manager informed.
2	IC2	1	Presents ideas clearly to peers and contributes effectively in team discussions.
3	IC3	1	Influences cross-functional stakeholders through clear and persuasive communication.
4	M1	1	Tailors messaging for different audiences and provides timely, actionable feedback.
5	M2	1	Aligns teams around priorities and communicates organizational direction clearly.
6	E1	1	Inspires and aligns large groups; represents the organization externally.
7	IC1	2	Works well with peers and supports shared goals.
8	IC2	2	Collaborates across teams to deliver shared outcomes.
9	IC3	2	Leads peer collaboration and resolves cross-functional issues.
10	M1	2	Builds cross-functional relationships and resolves conflicts.
11	M2	2	Drives enterprise-wide collaboration and removes barriers.
12	E1	2	Fosters organizational unity and breaks down silos company-wide.
13	IC1	3	Meets deadlines and takes responsibility for completing assigned work.
14	IC2	3	Takes ownership of outcomes and consistently delivers high-quality results.
15	IC3	3	Models accountability and helps others meet team goals.
16	M1	3	Holds self and team accountable; sets clear expectations and monitors progress.
17	M2	3	Creates a culture of ownership and drives accountability across departments.
18	E1	3	Owns strategic outcomes and fosters an enterprise-wide culture of accountability.
19	IC1	4	Analyzes information to solve routine problems and seeks guidance when needed.
20	IC2	4	Identifies root causes and develops practical solutions to moderately complex issues.
21	IC3	4	Solves complex problems using data, insight, and sound judgment.
22	M1	4	Anticipates issues, evaluates alternatives, and implements effective solutions for the team.
23	M2	4	Develops systemic solutions that improve efficiency and mitigate risks across functions.
24	E1	4	Makes high-impact strategic decisions balancing long-term and operational considerations.
25	IC1	5	Learns new systems and processes quickly; adjusts easily to changing priorities.
26	IC2	5	Adapts to shifting demands and seeks feedback to continuously improve.
27	IC3	5	Demonstrates resilience in ambiguous situations and helps others adapt to change.
28	M1	5	Guides team through change and models a positive, flexible mindset.
29	M2	5	Leads organizational change initiatives and builds adaptability within the workforce.
30	E1	5	Champions transformation, setting direction and confidence during times of uncertainty.
31	IC1	6	Suggests improvements to existing processes and seeks opportunities to innovate within their role.
32	IC2	6	Applies creative thinking to develop new ideas or enhance current practices.
33	IC3	6	Drives innovation by experimenting with new methods and sharing best practices across teams.
34	M1	6	Encourages creativity and experimentation; supports the team in testing new approaches.
35	M2	6	Fosters an innovative culture by investing in new ideas and removing barriers to experimentation.
36	E1	6	Sets the enterprise innovation agenda; champions bold ideas and allocates resources to bring them to life.
\.


--
-- Data for Name: core_competencies; Type: TABLE DATA; Schema: public; Owner: neill
--

COPY public.core_competencies (competency_id, competency_name, description) FROM stdin;
1	Communication	Effectively conveys information and ideas.
2	Collaboration / Teamwork	Works effectively with others to achieve common goals.
3	Accountability / Ownership	Takes responsibility for results and commitments.
4	Problem Solving / Critical Thinking	Analyzes and resolves problems effectively.
5	Adaptability / Learning Agility	Responds to change and learns quickly.
6	Innovation / Creativity	Generates new ideas and improves processes.
\.


--
-- Data for Name: departments; Type: TABLE DATA; Schema: public; Owner: neill
--

COPY public.departments (department_id, department_name, function_id) FROM stdin;
1	Product Development	1
2	Product Management	2
3	Information Technology	1
4	Research & Development (R&D)	1
5	Sales	3
6	Marketing	3
7	Customer Service	4
8	Human Resources	5
9	Finance	6
10	Legal	7
11	Executive Administration	8
\.


--
-- Data for Name: employee_benefits; Type: TABLE DATA; Schema: public; Owner: neill
--

COPY public.employee_benefits (employee_benefit_id, employee_id, benefit_plan_id, dependants, effective_date, expiry_date, date_created, date_updated) FROM stdin;
263	107	7	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
2	1	4	2	2024-01-01	2024-12-31	2024-01-01	2024-01-01
3	1	6	2	2024-01-01	2024-12-31	2024-01-01	2024-01-01
4	1	8	0	2024-01-01	2024-12-31	2024-01-01	2024-01-01
5	1	9	0	2024-01-01	2024-12-31	2024-01-01	2024-01-01
264	108	6	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
7	10	5	1	2024-01-01	2024-12-31	2024-01-01	2024-01-01
8	10	7	1	2024-01-01	2024-12-31	2024-01-01	2024-01-01
265	109	7	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
10	301	4	3	2024-01-01	2024-12-31	2024-01-01	2024-01-01
11	301	6	3	2024-01-01	2024-12-31	2024-01-01	2024-01-01
266	110	6	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
13	385	5	1	2024-01-01	2024-12-31	2024-01-01	2024-01-01
267	111	7	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
268	112	6	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
269	302	7	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
270	303	6	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
271	304	7	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
272	305	6	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
273	306	7	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
274	307	6	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
275	308	7	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
276	309	6	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
277	310	7	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
278	311	6	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
279	312	7	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
280	313	6	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
281	314	7	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
282	315	6	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
283	316	7	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
284	317	6	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
285	318	7	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
286	319	6	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
287	320	7	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
288	321	6	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
289	322	7	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
290	323	6	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
291	324	7	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
292	325	6	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
293	326	7	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
294	327	6	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
295	328	7	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
296	329	6	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
297	330	7	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
298	331	6	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
299	332	7	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
300	333	6	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
301	334	7	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
302	335	6	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
303	336	7	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
304	337	6	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
305	338	7	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
306	339	6	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
307	340	7	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
308	341	6	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
309	343	7	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
310	344	6	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
311	345	7	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
312	346	6	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
313	347	7	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
314	348	6	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
315	349	7	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
316	350	6	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
317	356	7	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
318	357	6	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
319	358	7	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
320	359	6	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
321	360	7	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
322	361	6	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
323	362	7	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
324	363	6	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
325	364	7	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
326	365	6	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
327	366	7	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
328	367	6	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
329	368	7	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
330	369	6	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
331	370	7	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
332	371	6	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
333	372	7	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
334	373	6	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
335	374	7	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
336	375	6	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
337	376	7	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
338	377	6	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
339	378	7	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
340	379	6	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
341	380	7	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
342	381	6	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
343	382	7	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
344	383	6	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
345	384	7	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
180	107	2	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
181	108	3	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
182	109	1	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
183	110	2	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
184	111	3	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
185	112	1	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
186	302	2	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
187	303	3	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
188	304	1	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
189	305	2	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
190	306	3	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
191	307	1	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
192	308	2	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
193	309	3	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
194	310	1	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
195	311	2	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
196	312	3	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
197	313	1	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
198	314	2	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
199	315	3	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
200	316	1	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
201	317	2	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
202	318	3	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
203	319	1	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
204	320	2	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
205	321	3	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
206	322	1	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
207	323	2	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
208	324	3	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
209	325	1	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
210	326	2	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
211	327	3	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
212	328	1	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
213	329	2	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
214	330	3	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
215	331	1	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
216	332	2	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
217	333	3	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
218	334	1	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
219	335	2	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
220	336	3	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
221	337	1	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
222	338	2	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
223	339	3	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
224	340	1	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
225	341	2	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
226	343	3	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
227	344	1	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
228	345	2	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
229	346	3	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
230	347	1	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
231	348	2	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
232	349	3	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
233	350	1	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
234	356	2	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
235	357	3	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
236	358	1	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
237	359	2	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
238	360	3	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
239	361	1	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
240	362	2	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
241	363	3	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
242	364	1	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
243	365	2	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
244	366	3	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
245	367	1	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
246	368	2	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
247	369	3	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
248	370	1	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
249	371	2	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
250	372	3	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
251	373	1	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
252	374	2	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
253	375	3	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
254	376	1	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
255	377	2	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
256	378	3	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
257	379	1	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
258	380	2	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
259	381	3	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
260	382	1	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
261	383	2	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
262	384	3	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
346	385	6	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
347	107	5	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
348	108	4	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
349	109	5	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
350	110	4	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
351	111	5	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
352	112	4	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
353	302	5	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
354	303	4	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
355	304	5	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
356	305	4	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
357	306	5	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
358	307	4	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
359	308	5	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
360	309	4	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
361	310	5	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
362	311	4	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
363	312	5	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
364	313	4	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
365	314	5	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
366	315	4	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
367	316	5	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
368	317	4	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
369	318	5	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
370	319	4	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
371	320	5	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
372	321	4	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
373	322	5	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
374	323	4	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
375	324	5	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
376	325	4	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
377	326	5	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
378	327	4	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
379	328	5	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
380	329	4	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
381	330	5	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
382	331	4	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
383	332	5	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
384	333	4	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
385	334	5	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
386	335	4	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
387	336	5	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
388	337	4	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
389	338	5	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
390	339	4	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
391	340	5	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
392	341	4	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
393	343	5	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
394	344	4	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
395	345	5	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
396	346	4	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
397	347	5	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
398	348	4	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
399	349	5	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
400	350	4	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
401	356	5	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
402	357	4	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
403	358	5	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
404	359	4	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
405	360	5	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
406	361	4	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
407	362	5	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
408	363	4	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
409	364	5	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
410	365	4	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
411	366	5	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
412	367	4	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
413	368	5	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
414	369	4	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
415	370	5	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
416	371	4	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
417	372	5	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
418	373	4	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
419	374	5	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
420	375	4	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
421	376	5	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
422	377	4	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
423	378	5	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
424	379	4	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
425	380	5	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
426	381	4	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
427	382	5	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
428	383	4	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
429	384	5	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
430	4	2	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
431	17	3	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
432	18	1	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
433	47	2	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
434	48	3	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
435	49	1	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
436	50	2	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
437	51	3	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
438	92	1	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
439	93	2	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
440	94	3	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
441	95	1	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
442	96	2	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
443	97	3	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
444	98	1	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
445	99	2	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
446	219	3	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
447	220	1	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
448	221	2	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
449	222	3	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
450	223	1	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
451	224	2	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
452	225	3	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
453	226	1	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
454	227	2	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
455	228	3	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
456	229	1	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
457	230	2	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
458	231	3	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
459	232	1	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
460	233	2	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
461	234	3	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
462	235	1	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
463	236	2	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
464	237	3	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
465	238	1	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
466	239	2	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
467	240	3	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
468	241	1	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
469	242	2	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
470	243	3	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
471	244	1	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
472	245	2	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
473	246	3	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
474	247	1	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
475	4	7	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
476	17	6	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
477	18	7	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
478	47	6	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
479	48	7	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
480	49	6	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
481	50	7	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
482	51	6	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
483	92	7	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
484	93	6	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
485	94	7	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
486	95	6	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
487	96	7	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
488	97	6	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
489	98	7	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
490	99	6	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
491	219	7	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
492	220	6	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
493	221	7	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
494	222	6	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
495	223	7	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
496	224	6	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
497	225	7	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
498	226	6	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
499	227	7	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
500	228	6	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
501	229	7	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
502	230	6	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
503	231	7	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
504	232	6	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
505	233	7	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
506	234	6	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
507	235	7	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
508	236	6	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
509	237	7	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
510	238	6	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
511	239	7	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
512	240	6	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
513	241	7	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
514	242	6	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
515	243	7	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
516	244	6	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
517	245	7	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
518	246	6	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
519	247	7	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
520	4	5	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
521	17	4	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
522	18	5	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
523	47	4	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
524	48	5	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
525	49	4	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
526	50	5	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
527	51	4	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
528	92	5	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
529	93	4	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
530	94	5	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
531	95	4	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
532	96	5	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
533	97	4	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
534	98	5	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
535	99	4	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
536	219	5	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
537	220	4	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
538	221	5	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
539	222	4	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
540	223	5	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
541	224	4	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
542	225	5	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
543	226	4	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
544	227	5	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
545	228	4	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
546	229	5	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
547	230	4	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
548	231	5	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
549	232	4	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
550	233	5	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
551	234	4	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
552	235	5	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
553	236	4	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
554	237	5	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
555	238	4	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
556	239	5	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
557	240	4	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
558	241	5	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
559	242	4	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
560	243	5	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
561	244	4	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
562	245	5	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
563	246	4	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
564	247	5	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
565	5	2	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
566	52	3	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
567	53	1	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
568	103	2	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
569	104	3	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
570	105	1	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
571	106	2	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
572	248	3	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
573	249	1	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
574	250	2	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
575	251	3	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
576	252	1	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
577	253	2	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
578	254	3	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
579	255	1	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
580	256	2	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
581	257	3	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
582	258	1	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
583	259	2	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
584	260	3	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
585	5	7	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
586	52	6	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
587	53	7	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
588	103	6	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
589	104	7	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
590	105	6	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
591	106	7	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
592	248	6	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
593	249	7	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
594	250	6	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
595	251	7	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
596	252	6	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
597	253	7	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
598	254	6	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
599	255	7	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
600	256	6	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
601	257	7	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
602	258	6	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
603	259	7	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
604	260	6	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
605	5	5	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
606	52	4	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
607	53	5	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
608	103	4	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
609	104	5	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
610	105	4	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
611	106	5	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
612	248	4	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
613	249	5	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
614	250	4	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
615	251	5	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
616	252	4	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
617	253	5	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
618	254	4	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
619	255	5	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
620	256	4	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
621	257	5	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
622	258	4	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
623	259	5	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
624	260	4	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
625	33	2	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
626	34	3	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
627	113	1	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
628	114	2	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
629	115	3	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
630	116	1	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
631	351	2	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
632	352	3	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
633	353	1	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
634	354	2	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
635	355	3	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
636	33	7	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
637	34	6	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
638	113	7	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
639	114	6	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
640	115	7	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
641	116	6	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
642	351	7	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
643	352	6	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
644	353	7	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
645	354	6	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
646	355	7	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
647	33	5	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
648	34	4	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
649	113	5	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
650	114	4	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
651	115	5	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
652	116	4	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
653	351	5	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
654	352	4	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
655	353	5	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
656	354	4	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
657	355	5	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
658	3	2	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
659	13	3	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
660	14	1	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
661	15	2	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
662	16	3	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
663	39	1	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
664	40	2	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
665	41	3	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
666	42	1	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
667	43	2	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
668	44	3	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
669	45	1	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
670	46	2	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
671	73	3	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
672	74	1	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
673	75	2	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
674	76	3	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
675	77	1	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
676	78	2	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
677	79	3	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
678	80	1	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
679	81	2	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
680	82	3	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
681	83	1	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
682	84	2	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
683	85	3	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
684	86	1	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
685	87	2	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
686	88	3	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
687	89	1	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
688	90	2	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
689	91	3	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
690	152	1	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
691	153	2	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
692	154	3	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
693	155	1	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
694	156	2	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
695	157	3	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
696	158	1	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
697	159	2	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
698	160	3	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
699	161	1	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
700	162	2	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
701	163	3	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
702	164	1	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
703	165	2	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
704	166	3	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
705	167	1	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
706	168	2	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
707	169	3	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
708	170	1	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
709	171	2	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
710	172	3	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
711	173	1	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
712	174	2	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
713	175	3	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
714	176	1	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
715	177	2	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
716	178	3	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
717	179	1	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
718	180	2	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
719	181	3	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
720	182	1	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
721	183	2	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
722	184	3	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
723	185	1	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
724	186	2	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
725	187	3	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
726	188	1	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
727	193	2	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
728	194	3	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
729	195	1	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
730	196	2	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
731	197	3	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
732	198	1	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
733	199	2	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
734	200	3	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
735	201	1	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
736	202	2	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
737	203	3	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
738	204	1	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
739	205	2	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
740	206	3	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
741	207	1	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
742	208	2	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
743	209	3	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
744	210	1	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
745	211	2	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
746	212	3	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
747	213	1	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
748	214	2	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
749	215	3	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
750	216	1	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
751	217	2	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
752	218	3	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
753	3	7	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
754	13	6	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
755	14	7	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
756	15	6	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
757	16	7	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
758	39	6	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
759	40	7	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
760	41	6	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
761	42	7	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
762	43	6	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
763	44	7	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
764	45	6	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
765	46	7	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
766	73	6	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
767	74	7	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
768	75	6	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
769	76	7	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
770	77	6	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
771	78	7	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
772	79	6	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
773	80	7	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
774	81	6	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
775	82	7	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
776	83	6	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
777	84	7	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
778	85	6	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
779	86	7	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
780	87	6	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
781	88	7	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
782	89	6	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
783	90	7	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
784	91	6	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
785	152	7	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
786	153	6	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
787	154	7	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
788	155	6	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
789	156	7	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
790	157	6	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
791	158	7	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
792	159	6	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
793	160	7	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
794	161	6	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
795	162	7	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
796	163	6	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
797	164	7	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
798	165	6	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
799	166	7	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
800	167	6	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
801	168	7	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
802	169	6	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
803	170	7	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
804	171	6	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
805	172	7	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
806	173	6	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
807	174	7	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
808	175	6	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
809	176	7	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
810	177	6	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
811	178	7	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
812	179	6	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
813	180	7	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
814	181	6	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
815	182	7	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
816	183	6	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
817	184	7	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
818	185	6	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
819	186	7	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
820	187	6	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
821	188	7	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
822	193	6	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
823	194	7	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
824	195	6	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
825	196	7	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
826	197	6	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
827	198	7	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
828	199	6	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
829	200	7	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
830	201	6	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
831	202	7	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
832	203	6	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
833	204	7	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
834	205	6	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
835	206	7	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
836	207	6	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
837	208	7	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
838	209	6	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
839	210	7	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
840	211	6	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
841	212	7	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
842	213	6	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
843	214	7	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
844	215	6	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
845	216	7	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
846	217	6	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
847	218	7	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
848	3	5	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
849	13	4	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
850	14	5	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
851	15	4	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
852	16	5	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
853	39	4	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
854	40	5	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
855	41	4	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
856	42	5	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
857	43	4	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
858	44	5	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
859	45	4	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
860	46	5	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
861	73	4	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
862	74	5	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
863	75	4	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
864	76	5	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
865	77	4	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
866	78	5	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
867	79	4	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
868	80	5	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
869	81	4	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
870	82	5	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
871	83	4	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
872	84	5	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
873	85	4	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
874	86	5	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
875	87	4	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
876	88	5	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
877	89	4	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
878	90	5	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
879	91	4	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
880	152	5	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
881	153	4	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
882	154	5	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
883	155	4	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
884	156	5	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
885	157	4	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
886	158	5	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
887	159	4	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
888	160	5	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
889	161	4	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
890	162	5	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
891	163	4	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
892	164	5	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
893	165	4	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
894	166	5	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
895	167	4	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
896	168	5	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
897	169	4	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
898	170	5	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
899	171	4	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
900	172	5	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
901	173	4	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
902	174	5	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
903	175	4	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
904	176	5	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
905	177	4	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
906	178	5	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
907	179	4	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
908	180	5	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
909	181	4	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
910	182	5	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
911	183	4	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
912	184	5	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
913	185	4	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
914	186	5	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
915	187	4	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
916	188	5	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
917	193	4	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
918	194	5	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
919	195	4	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
920	196	5	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
921	197	4	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
922	198	5	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
923	199	4	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
924	200	5	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
925	201	4	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
926	202	5	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
927	203	4	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
928	204	5	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
929	205	4	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
930	206	5	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
931	207	4	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
932	208	5	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
933	209	4	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
934	210	5	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
935	211	4	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
936	212	5	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
937	213	4	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
938	214	5	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
939	215	4	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
940	216	5	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
941	217	4	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
942	218	5	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
943	10	2	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
944	7	3	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
945	29	1	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
946	30	2	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
947	133	3	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
948	134	1	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
949	135	2	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
950	136	3	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
951	137	1	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
952	138	2	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
953	139	3	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
954	268	1	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
955	269	2	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
956	270	3	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
957	271	1	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
958	272	2	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
959	273	3	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
960	274	1	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
961	275	2	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
962	276	3	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
963	277	1	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
964	278	2	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
965	279	3	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
966	280	1	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
967	281	2	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
968	282	3	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
969	283	1	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
970	284	2	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
971	285	3	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
972	286	1	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
973	287	2	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
974	288	3	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
975	289	1	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
976	290	2	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
977	291	3	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
978	292	1	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
979	293	2	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
980	294	3	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
981	295	1	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
982	296	2	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
983	7	7	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
984	29	6	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
985	30	7	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
986	133	6	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
987	134	7	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
988	135	6	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
989	136	7	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
990	137	6	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
991	138	7	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
992	139	6	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
993	268	7	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
994	269	6	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
995	270	7	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
996	271	6	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
997	272	7	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
998	273	6	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
999	274	7	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1000	275	6	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1001	276	7	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1002	277	6	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1003	278	7	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1004	279	6	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1005	280	7	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1006	281	6	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1007	282	7	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1008	283	6	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1009	284	7	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1010	285	6	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1011	286	7	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1012	287	6	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1013	288	7	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1014	289	6	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1015	290	7	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1016	291	6	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1017	292	7	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1018	293	6	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1019	294	7	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1020	295	6	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1021	296	7	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1022	7	5	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1023	29	4	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1024	30	5	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1025	133	4	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1026	134	5	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1027	135	4	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1028	136	5	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1029	137	4	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1030	138	5	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1031	139	4	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1032	268	5	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1033	269	4	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1034	270	5	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1035	271	4	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1036	272	5	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1037	273	4	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1038	274	5	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1039	275	4	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1040	276	5	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1041	277	4	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1042	278	5	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1043	279	4	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1044	280	5	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1045	281	4	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1046	282	5	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1047	283	4	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1048	284	5	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1049	285	4	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1050	286	5	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1051	287	4	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1052	288	5	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1053	289	4	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1054	290	5	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1055	291	4	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1056	292	5	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1057	293	4	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1058	294	5	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1059	295	4	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1060	296	5	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1061	9	2	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1062	26	3	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1063	27	1	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1064	31	2	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1065	32	3	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1066	68	1	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1067	69	2	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1068	261	3	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1069	262	1	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1070	263	2	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1071	264	3	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1072	265	1	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1073	266	2	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1074	267	3	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1075	297	1	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1076	298	2	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1077	299	3	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1078	300	1	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1079	9	7	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1080	26	6	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1081	27	7	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1082	31	6	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1083	32	7	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1084	68	6	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1085	69	7	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1086	261	6	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1087	262	7	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1088	263	6	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1089	264	7	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1090	265	6	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1091	266	7	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1092	267	6	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1093	297	7	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1094	298	6	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1095	299	7	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1096	300	6	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1097	9	5	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1098	26	4	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1099	27	5	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1100	31	4	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1101	32	5	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1102	68	4	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1103	69	5	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1104	261	4	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1105	262	5	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1106	263	4	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1107	264	5	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1108	265	4	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1109	266	5	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1110	267	4	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1111	297	5	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1112	298	4	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1113	299	5	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1114	300	4	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1115	2	2	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1116	6	3	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1117	28	1	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1118	66	2	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1119	67	3	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1120	70	1	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1121	71	2	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1122	72	3	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1123	126	1	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1124	127	2	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1125	128	3	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1126	129	1	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1127	130	2	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1128	131	3	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1129	132	1	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1130	2	7	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1131	6	6	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1132	28	7	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1133	66	6	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1134	67	7	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1135	70	6	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1136	71	7	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1137	72	6	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1138	126	7	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1139	127	6	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1140	128	7	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1141	129	6	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1142	130	7	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1143	131	6	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1144	132	7	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1145	2	5	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1146	6	4	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1147	28	5	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1148	66	4	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1149	67	5	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1150	70	4	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1151	71	5	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1152	72	4	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1153	126	5	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1154	127	4	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1155	128	5	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1156	129	4	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1157	130	5	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1158	131	4	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1159	132	5	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1160	1	2	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1161	8	2	1	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1162	8	7	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1163	8	5	3	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1164	301	2	2	2024-01-01	2024-12-31	2025-11-01	2025-11-01
1165	385	3	0	2024-01-01	2024-12-31	2025-11-01	2025-11-01
\.


--
-- Data for Name: employee_competencies; Type: TABLE DATA; Schema: public; Owner: neill
--

COPY public.employee_competencies (employee_competency_id, review_id, competency_id, employee_rating, manager_rating, employee_comments, manager_comments) FROM stdin;
19	1	1	\N	\N	\N	\N
20	1	2	\N	\N	\N	\N
21	1	3	\N	\N	\N	\N
22	1	4	\N	\N	\N	\N
23	1	5	\N	\N	\N	\N
24	1	6	\N	\N	\N	\N
25	2	1	\N	\N	\N	\N
26	2	2	\N	\N	\N	\N
27	2	3	\N	\N	\N	\N
28	2	4	\N	\N	\N	\N
29	2	5	\N	\N	\N	\N
30	2	6	\N	\N	\N	\N
31	3	1	\N	\N	\N	\N
32	3	2	\N	\N	\N	\N
33	3	3	\N	\N	\N	\N
34	3	4	\N	\N	\N	\N
35	3	5	\N	\N	\N	\N
36	3	6	\N	\N	\N	\N
\.


--
-- Data for Name: employee_goals; Type: TABLE DATA; Schema: public; Owner: neill
--

COPY public.employee_goals (goal_id, review_id, strategy_id, objective, goal_description, target_date, employee_rating, manager_rating, employee_comments, manager_comments, created_at, updated_at) FROM stdin;
4	1	1	Enhance customer experience	Achieve a 15% increase in customer satisfaction scores by end of FY25	2025-12-31	\N	\N	\N	\N	2025-11-07 14:44:51.112438	2025-11-07 14:44:51.112438
5	1	2	Improve employee engagement	Implement quarterly feedback surveys and increase engagement by 10%	2025-12-31	\N	\N	\N	\N	2025-11-07 14:44:51.112438	2025-11-07 14:44:51.112438
6	1	3	Drive operational efficiency	Reduce operating cost per transaction to $5.00 through automation initiatives	2025-12-31	\N	\N	\N	\N	2025-11-07 14:44:51.112438	2025-11-07 14:44:51.112438
7	2	1	Support customer experience improvement	Lead UX feedback sessions and identify 3 areas for portal enhancement	2025-06-30	\N	\N	\N	\N	2025-11-07 14:50:47.119711	2025-11-07 14:50:47.119711
8	2	2	Strengthen team collaboration and retention	Implement peer mentoring and support onboarding for 2 new team members	2025-09-30	\N	\N	\N	\N	2025-11-07 14:50:47.119711	2025-11-07 14:50:47.119711
9	2	3	Contribute to operational efficiency	Automate weekly report process to reduce manual effort by 20%	2025-12-31	\N	\N	\N	\N	2025-11-07 14:50:47.119711	2025-11-07 14:50:47.119711
13	3	1	Transform the customer experience	Deliver a unified customer experience strategy across all business units, targeting a 20% improvement in Net Promoter Score (NPS) and faster digital adoption.	2025-12-31	\N	\N	\N	\N	2025-11-07 14:59:47.807375	2025-11-07 14:59:47.807375
14	3	2	Elevate employee engagement and culture	Achieve top-quartile employee engagement by launching the "One Company" culture initiative and increasing retention among top performers by 15%.	2025-12-31	\N	\N	\N	\N	2025-11-07 14:59:47.807375	2025-11-07 14:59:47.807375
15	3	3	Enhance enterprise value through innovation and efficiency	Drive 10% EBITDA growth and 12% revenue growth by scaling automation, optimizing cost structure, and expanding into two new market segments.	2025-12-31	\N	\N	\N	\N	2025-11-07 14:59:47.807375	2025-11-07 14:59:47.807375
\.


--
-- Data for Name: employee_reviews; Type: TABLE DATA; Schema: public; Owner: neill
--

COPY public.employee_reviews (review_id, employee_id, review_cycle_id, created_at, updated_at, review_status, submitted_at, finalized_at) FROM stdin;
1	301	1	2025-11-07 14:43:08.336848	2025-11-07 14:43:08.336848	Draft	\N	\N
2	107	1	2025-11-07 14:50:47.116862	2025-11-07 14:50:47.116862	Draft	\N	\N
3	1	1	2025-11-07 14:54:57.912721	2025-11-07 14:54:57.912721	Draft	\N	\N
\.


--
-- Data for Name: employees; Type: TABLE DATA; Schema: public; Owner: neill
--

COPY public.employees (employee_id, employee_number, first_name, middle_initial, last_name, full_name, preferred_name, job_title, email, hire_date, department_id, role_id, manager_id, status, base_salary, bonus_eligible, target_bonus, commission_eligible, commission_target, compensation_currency, date_of_birth, employment_type, gender, home_address, mobile_number, hours_per_week) FROM stdin;
1	EMP00000001	Amanda	J	Thomopson	Amanda Thompson	Amanda Thompson	Chief Executive Officier	amanda.thompson@nestey.co	2011-03-13 00:00:00	11	45	\N	active	452241.23	t	8.10	f	0.00	USD	1968-12-14	Full-time	Female	2541 E Palm Canyon, Palm Springs, CA 92262	1-917-635-2272	40.0
10	EMP00000010	Erin	M	Sauer	Erin Sauer	Erin Sauer	Vice President	erin.sauer@nestey.co	2023-06-24 00:00:00	1	10	1	active	256000.00	t	0.75	f	0.00	USD	1984-10-11	Full-time	Female	254 Hill Road, Rancho Santa Margarita, TX 88412	1-305-719-2846	40.0
301	EMP00000301	Nader	I	Logos	Nader Logos	Nader Logos	Chief Customer Officier	nader.logos@nestey.co	2020-03-11 00:00:00	7	31	1	active	310000.00	t	4.10	f	0.00	USD	1994-10-25	Full-time	Male	2343 E Camden Street, Longbeach, NC 19714	1-212-458-9342	40.0
2	EMP00000002	Claudia	T	Schmeler	Claudia Schmeler	Claudia Schmeler	Chief Technology Officer	claudia.schmeler@nestey.co	2016-03-13 00:00:00	3	15	1	active	284571.72	t	5.20	f	0.00	USD	1966-12-14	Full-time	Female	4439 W 12th Street, Janelleland, ID 88867	1-213-605-4972	40.0
3	EMP00000003	Tamara	M	Bins	Tamara Bins	Tamara Bins	Chief Revenue Officier	tamara.bins@nestey.co	2017-08-13 00:00:00	5	23	1	active	315108.36	t	4.60	t	1.00	USD	1967-07-31	Full-time	Female	5934 Kaleigh Extension, Nedrafort, NM 37711	1-212-743-6819	40.0
4	EMP00000004	Everett	K	Wilderman	Everett Wilderman	Everett Wilderman	Chief Financial Officer	everett.wilderman@nestey.co	2016-07-17 00:00:00	9	39	1	active	267863.58	t	4.10	f	0.00	USD	1967-10-20	Full-time	Male	460 Minnie Bridge, Temecula, GA 86535	1-212-795-6039	40.0
5	EMP00000005	Juanita	O	Berge	Juanita Berge	Juanita Berge	Chief People Officer	juanita.berge@nestey.co	2018-03-11 00:00:00	8	35	1	active	276957.32	t	3.80	f	0.00	USD	1966-02-23	Full-time	Female	7114 E Maple Street, South Anna, PA 97897	1-347-912-6804	40.0
6	EMP00000006	Dennis	K	Schroeder	Dennis Schroeder	Dennis Schroeder	Director of  IT	dennis.schroeder@nestey.co	2022-09-09 00:00:00	3	14	2	active	210686.59	t	0.75	f	0.00	USD	1984-05-14	Full-time	Male	57804 Valley Road, Tremblayboro, VT 20342	1-305-874-6139	40.0
7	EMP00000007	Ernest	P	Roberts	Ernest Roberts	Ernest Roberts	Vice President of Product Development	ernest.roberts@nestey.co	2020-04-19 00:00:00	1	10	2	active	210909.34	t	1.20	f	0.00	USD	1991-08-18	Full-time	Male	658 McDermott Hills, South Leila, MI 97478	1-415-720-9348	40.0
8	EMP00000008	Carmen	I	Roberts	Carmen Roberts	Carmen Roberts	Director of R&D	carmen.roberts@nestey.co	2024-11-11 00:00:00	4	19	2	active	202495.89	t	0.75	f	0.00	USD	1983-05-08	Full-time	Female	41527 Cambridge Street, Streichboro, IA 89110	1-602-951-7480	40.0
9	EMP00000009	Alonzo	H	Krajcik	Alonzo Krajcik	Alonzo Krajcik	Vice President of Product 	alonzo.krajcik@nestey.co	2016-03-27 00:00:00	2	5	2	active	217181.49	t	0.75	f	0.00	USD	1961-11-25	Full-time	Male	674 Yundt Glens, New Joelhaven, ID 63623	1-720-341-6509	40.0
13	EMP00000013	Fred	F	Cummings	Fred Cummings	Fred Cummings	Vice President	fred.cummings@nestey.co	2019-10-27 00:00:00	5	22	3	active	214605.70	t	1.20	t	3.00	USD	1962-07-02	Full-time	Male	1005 W 6th Street, New Claudiahaven, OK 40976	1-305-672-5048	40.0
14	EMP00000014	Thomas	I	Windler	Thomas Windler	Thomas Windler	Vice President	thomas.windler@nestey.co	2021-10-15 00:00:00	5	22	3	active	212481.62	t	1.20	t	3.00	USD	1986-01-19	Full-time	Male	443 Marcia Corners, Lake Kaylie, CA 53124	1-415-978-2431	40.0
15	EMP00000015	Agnes	E	Kertzmann	Agnes Kertzmann	Agnes Kertzmann	Vice President	agnes.kertzmann@nestey.co	2017-02-04 00:00:00	5	22	3	active	229709.15	t	0.75	t	3.00	USD	1984-06-21	Full-time	Female	4915 Davis Fields, Mozellecester, AL 73119	1-602-359-7182	40.0
16	EMP00000016	Beulah	P	Wolff	Beulah Wolff	Beulah Wolff	Vice President	beulah.wolff@nestey.co	2016-12-05 00:00:00	5	22	3	active	204497.41	t	0.75	t	3.00	USD	1974-10-23	Full-time	Female	74681 Sycamore Street, Lake Meaghanville, NH 99988	1-720-568-4097	40.0
17	EMP00000017	Betsy	S	Bernhard	Betsy Bernhard	Betsy Bernhard	Director FPA	betsy.bernhard@nestey.co	2016-02-01 00:00:00	9	38	4	active	243366.51	t	0.75	f	0.00	USD	1999-06-13	Full-time	Female	447 W 9th Street, Jenningsside, ND 63739	1-305-731-8490	40.0
18	EMP00000018	Eunice	Q	Jacobson	Eunice Jacobson	Eunice Jacobson	Director FPA	eunice.jacobson@nestey.co	2019-07-21 00:00:00	9	38	4	active	249392.00	t	0.75	f	0.00	USD	1987-05-24	Full-time	Female	1827 W Broadway Avenue, West Cartermouth, KY 31051	1-415-984-2736	40.0
26	EMP00000026	Natasha	Q	Marvin	Natasha Marvin	Natasha Marvin	Director	natasha.marvin@nestey.co	2022-11-15 00:00:00	2	4	6	active	189201.39	t	0.30	f	0.00	USD	1962-01-19	Full-time	Female	7755 Water Lane, Graycefield, OH 85253	1-831-962-4305	40.0
27	EMP00000027	Nellie	T	Murphy	Nellie Murphy	Nellie Murphy	Director	nellie.murphy@nestey.co	2016-03-06 00:00:00	2	4	6	active	184688.72	t	0.30	f	0.00	USD	1999-05-15	Full-time	Female	857 Herzog Street, Fort Donnie, MN 06760	1-929-578-6412	40.0
28	EMP00000028	Kim	X	Bogisich	Kim Bogisich	Kim Bogisich	Director	kim.bogisich@nestey.co	2017-04-11 00:00:00	3	13	6	active	162240.34	t	0.30	f	0.00	USD	1965-05-04	Full-time	Male	45138 Blair Ridge, Brannonhaven, OR 05319	1-617-825-9743	40.0
29	EMP00000029	Floyd	D	Hyatt-Torp	Floyd Hyatt-Torp	Floyd Hyatt-Torp	Director	floyd.hyatt-torp@nestey.co	2020-02-27 00:00:00	1	9	7	active	182359.23	t	0.30	f	0.00	USD	1995-11-05	Full-time	Male	775 O'Reilly Manor, Landenview, KS 89168	1-713-640-9825	40.0
30	EMP00000030	Andrew	M	Bashirian	Andrew Bashirian	Andrew Bashirian	Director	andrew.bashirian@nestey.co	2018-01-25 00:00:00	1	9	7	active	175408.37	t	0.30	f	0.00	USD	1971-12-09	Full-time	Male	9074 Blaze Flat, Yucaipa, MI 30178	1-469-783-2149	40.0
31	EMP00000031	Jake	O	Roberts	Jake Roberts	Jake Roberts	Director	jake.roberts@nestey.co	2018-06-06 00:00:00	2	4	9	active	158837.02	t	0.30	f	0.00	USD	1960-02-06	Full-time	Male	72180 Cumberland Street, South Russell, DE 07352	1-804-735-6810	40.0
32	EMP00000032	Everett	J	Romaguera	Everett Romaguera	Everett Romaguera	Director	everett.romaguera@nestey.co	2017-05-18 00:00:00	2	4	9	active	169847.15	t	0.30	f	0.00	USD	1984-05-11	Full-time	Male	8313 Neva Station, Atlanta, NY 88786	1-215-924-7036	40.0
33	EMP00000033	Lori	D	Dietrich	Lori Dietrich	Lori Dietrich	Director	lori.dietrich@nestey.co	2020-03-07 00:00:00	6	10	10	active	187839.22	t	0.30	f	0.00	USD	1986-08-05	Full-time	Female	3902 Raleigh Crossing, Richardson, FL 98837	1-602-349-1875	40.0
34	EMP00000034	Ellen	S	O'Hara	Ellen O'Hara	Ellen O'Hara	Director	ellen.o'hara@nestey.co	2018-09-10 00:00:00	6	10	10	active	157722.74	t	0.30	f	0.00	USD	1967-01-10	Full-time	Female	35908 Bridge Street, New Carmellaland, ND 77029	1-713-492-6708	40.0
39	EMP00000039	Rickey	R	Schimmel	Rickey Schimmel	Rickey Schimmel	Director	rickey.schimmel@nestey.co	2023-01-17 00:00:00	5	21	13	active	198541.34	t	0.30	t	3.00	USD	1967-03-06	Full-time	Male	9061 Feest Burg, Travisview, AL 71333	1-831-247-3950	40.0
40	EMP00000040	Sheryl	D	Daugherty	Sheryl Daugherty	Sheryl Daugherty	Director	sheryl.daugherty@nestey.co	2022-01-15 00:00:00	5	21	13	active	188394.25	t	0.30	t	2.00	USD	1994-11-12	Full-time	Female	117 Georgette Street, Fort Athena, MO 24394	1-929-683-1425	40.0
41	EMP00000041	Winifred	E	Powlowski-Schmidt	Winifred Powlowski-Schmidt	Winifred Powlowski-Schmidt	Director	winifred.powlowski-schmidt@nestey.co	2017-12-30 00:00:00	5	21	14	active	181840.89	t	0.30	t	2.00	USD	1999-02-27	Full-time	Female	7579 E 10th Street, Selenaborough, NC 09381	1-617-439-5720	40.0
42	EMP00000042	Alfonso	\N	Bogan	Alfonso Bogan	Alfonso Bogan	Director	alfonso.bogan@nestey.co	2017-03-12 00:00:00	5	21	14	active	190463.30	t	0.30	t	2.00	USD	1994-09-18	Full-time	Male	85852 Brook Lane, West Elmofield, MO 17237	1-713-842-6973	40.0
43	EMP00000043	Jan	N	Feest	Jan Feest	Jan Feest	Director	jan.feest@nestey.co	2016-11-10 00:00:00	5	21	15	active	193601.06	t	0.30	t	2.00	USD	1961-01-26	Full-time	Female	4504 W Pine Street, Wolfmouth, LA 30038	1-469-231-5089	40.0
44	EMP00000044	Mary	R	Wehner	Mary Wehner	Mary Wehner	Director	mary.wehner@nestey.co	2019-08-31 00:00:00	5	21	15	active	176032.50	t	0.30	t	2.00	USD	1975-08-25	Full-time	Female	5953 Collin Street, Providencicester, NY 50487	1-804-639-5728	40.0
45	EMP00000045	Ella	Q	Block-McKenzie	Ella Block-McKenzie	Ella Block-McKenzie	Director	ella.block-mckenzie@nestey.co	2017-07-24 00:00:00	5	21	16	active	159976.76	t	0.30	t	2.00	USD	1991-01-07	Full-time	Female	582 The Orchard, Lake Norastead, SC 82667	1-215-394-8063	40.0
46	EMP00000046	Frances	Y	Parisian	Frances Parisian	Frances Parisian	Director	frances.parisian@nestey.co	2016-08-06 00:00:00	5	21	16	active	154272.21	t	0.30	t	2.00	USD	1980-02-14	Full-time	Female	4452 Braun Parkway, Denver, OH 54529	1-714-582-4960	40.0
47	EMP00000047	Brandon	T	Olson	Brandon Olson	Brandon Olson	Director	brandon.olson@nestey.co	2023-06-29 00:00:00	9	37	17	active	168649.31	t	0.30	f	0.00	USD	1976-08-21	Full-time	Male	2386 Daugherty View, Donnyshire, NV 16661	1-602-451-7902	40.0
48	EMP00000048	Glenda	K	Zulauf	Glenda Zulauf	Glenda Zulauf	Director	glenda.zulauf@nestey.co	2016-10-23 00:00:00	9	37	17	active	178368.26	t	0.30	f	0.00	USD	1981-04-13	Full-time	Female	95557 Mertz Fork, O'Konville, NC 62708	1-720-612-3497	40.0
49	EMP00000049	Dave	T	Rohan	Dave Rohan	Dave Rohan	Director	dave.rohan@nestey.co	2022-07-14 00:00:00	9	37	18	active	180136.46	t	0.30	f	0.00	USD	1992-11-06	Full-time	Male	9448 W High Street, South Celine, MN 99166	1-831-728-5023	40.0
50	EMP00000050	Genevieve	C	Mohr	Genevieve Mohr	Genevieve Mohr	Director	genevieve.mohr@nestey.co	2021-12-19 00:00:00	9	37	18	active	150766.47	t	0.30	f	0.00	USD	1999-04-22	Full-time	Female	2961 Catharine Crescent, Runolfssonborough, WA 71775	1-929-573-8045	40.0
51	EMP00000051	Lucy	W	Bauch	Lucy Bauch	Lucy Bauch	Director	lucy.bauch@nestey.co	2021-09-25 00:00:00	9	37	18	active	193031.33	t	0.30	f	0.00	USD	1977-04-09	Full-time	Female	941 Everett Circles, Abshirestad, CA 78180	1-617-832-9407	40.0
52	EMP00000052	Caroline	E	Romaguera	Caroline Romaguera	Caroline Romaguera	Director	caroline.romaguera@nestey.co	2022-07-15 00:00:00	8	34	5	active	190705.02	t	0.30	f	0.00	USD	1978-02-23	Full-time	Female	893 Ashleigh Plaza, South Hellen, MA 45569	1-213-874-3951	40.0
53	EMP00000053	Robyn	S	Zemlak	Robyn Zemlak	Robyn Zemlak	Director	robyn.zemlak@nestey.co	2022-11-22 00:00:00	8	34	5	active	180454.17	t	0.30	f	0.00	USD	1969-12-12	Full-time	Female	2216 Brice Lane, East Dameonstead, TX 40537	1-808-526-7439	40.0
66	EMP00000066	Colin	M	Kris	Colin Kris	Colin Kris	Manager	colin.kris@nestey.co	2016-01-01 00:00:00	3	11	26	active	90550.63	t	0.25	f	0.00	USD	1979-10-18	Full-time	Male	702 S Water Street, Streichstad, LA 93951	1-714-689-9342	40.0
67	EMP00000067	Adam	T	Nitzsche	Adam Nitzsche	Adam Nitzsche	Manager	adam.nitzsche@nestey.co	2022-05-13 00:00:00	3	11	26	active	117461.85	t	0.25	f	0.00	USD	1989-03-16	Full-time	Male	466 Cormier Mountain, Fort Kaylichester, HI 52346	1-503-278-4501	40.0
68	EMP00000068	Nicolas	S	Steuber	Nicolas Steuber	Nicolas Steuber	Manager	nicolas.steuber@nestey.co	2017-11-26 00:00:00	2	8	27	active	126997.93	t	0.25	f	0.00	USD	1978-07-04	Full-time	Male	63919 St George's Road, Port Sandrastead, AR 35808	1-646-372-5809	40.0
69	EMP00000069	Wilbert	F	Smith	Wilbert Smith	Wilbert Smith	Manager	wilbert.smith@nestey.co	2020-04-18 00:00:00	2	8	27	active	136733.24	t	0.25	f	0.00	USD	1996-06-27	Full-time	Male	79668 Predovic Shore, Rempelbury, SC 41290	1-702-543-8927	40.0
70	EMP00000070	Jason	A	Streich	Jason Streich	Jason Streich	Manager	jason.streich@nestey.co	2020-08-23 00:00:00	3	12	28	active	100739.81	t	0.25	f	0.00	USD	1985-11-02	Full-time	Male	23697 Douglas Squares, Otiliaport, DE 50573	1-312-847-6903	40.0
71	EMP00000071	Olive	N	Swaniawski	Olive Swaniawski	Olive Swaniawski	Manager	olive.swaniawski@nestey.co	2024-09-15 00:00:00	3	12	28	active	123988.04	t	0.25	f	0.00	USD	1971-04-22	Full-time	Female	7527 Vivienne Expressway, Taylorsville, VA 96306	1-512-705-9841	40.0
72	EMP00000072	Joann	P	Schuppe	Joann Schuppe	Joann Schuppe	Manager	joann.schuppe@nestey.co	2018-01-17 00:00:00	3	12	28	active	115025.03	t	0.25	f	0.00	USD	1980-03-04	Full-time	Female	75353 Stanley Road, West Isaiah, WI 38894	1-817-248-6950	40.0
73	EMP00000073	Randall	\N	Crooks	Randall Crooks	Randall Crooks	Manager	randall.crooks@nestey.co	2020-12-30 00:00:00	5	20	39	active	110461.67	t	0.25	t	1.40	USD	1991-10-02	Full-time	Male	54196 N Jackson Street, Lake Lolitaport, IL 06865	1-503-294-8071	40.0
74	EMP00000074	Harold	N	Roob	Harold Roob	Harold Roob	Manager	harold.roob@nestey.co	2021-03-07 00:00:00	5	20	39	active	124936.24	t	0.25	t	1.40	USD	1975-12-26	Full-time	Male	7914 Ernser Loop, Weberstead, OH 07892	1-646-972-5408	40.0
75	EMP00000075	Veronica	Y	Herman	Veronica Herman	Veronica Herman	Manager	veronica.herman@nestey.co	2024-03-02 00:00:00	5	20	40	active	125306.07	t	0.25	t	1.40	USD	1988-03-24	Full-time	Female	892 Wisozk Locks, Bednarfield, WI 48262	1-702-340-7965	40.0
76	EMP00000076	Kristie	\N	Torp	Kristie Torp	Kristie Torp	Manager	kristie.torp@nestey.co	2023-08-10 00:00:00	5	20	40	active	147037.77	t	0.25	t	1.40	USD	1962-08-21	Full-time	Female	3088 N Lincoln Street, Warner Robins, SD 49956	1-312-748-5094	40.0
77	EMP00000077	Aaron	T	McCullough	Aaron McCullough	Aaron McCullough	Manager	aaron.mccullough@nestey.co	2016-09-30 00:00:00	5	20	40	active	129888.04	t	0.25	t	1.40	USD	1977-03-20	Full-time	Male	235 Heidenreich Circles, Lefflerboro, CA 65362	1-512-873-6904	40.0
78	EMP00000078	Danielle	S	Kilback	Danielle Kilback	Danielle Kilback	Manager	danielle.kilback@nestey.co	2024-11-07 00:00:00	5	20	41	active	112058.98	t	0.25	t	1.40	USD	1977-12-12	Full-time	Female	8159 Emely Burgs, Norvalfurt, MA 92399	1-817-295-7461	40.0
79	EMP00000079	Craig	J	Powlowski	Craig Powlowski	Craig Powlowski	Manager	craig.powlowski@nestey.co	2023-09-04 00:00:00	5	20	41	active	132604.90	t	0.25	t	1.40	USD	1961-10-04	Full-time	Male	8679 Madalyn Locks, Lake Ledachester, HI 28132	1-919-285-4306	40.0
80	EMP00000080	Deborah	L	Schamberger	Deborah Schamberger	Deborah Schamberger	Manager	deborah.schamberger@nestey.co	2023-03-05 00:00:00	5	20	42	active	124606.14	t	0.25	t	1.40	USD	1979-02-25	Full-time	Female	495 E Washington Street, Port Aniyah, NV 10577	1-213-693-2049	40.0
81	EMP00000081	Hugo	B	Will	Hugo Will	Hugo Will	Manager	hugo.will@nestey.co	2016-01-16 00:00:00	5	20	42	active	123064.02	t	0.25	t	1.40	USD	1992-02-14	Full-time	Male	6900 N Broadway, Ann Arbor, MO 85630	1-904-752-9305	40.0
82	EMP00000082	Terry	H	Romaguera	Terry Romaguera	Terry Romaguera	Manager	terry.romaguera@nestey.co	2016-07-26 00:00:00	5	20	42	active	94766.82	t	0.25	t	1.40	USD	1975-03-12	Full-time	Male	30738 Williamson Union, Schmidtcester, UT 54118	1-508-381-2640	40.0
83	EMP00000083	Velma	F	Cassin	Velma Cassin	Velma Cassin	Manager	velma.cassin@nestey.co	2018-02-12 00:00:00	5	20	43	active	144073.09	t	0.25	t	1.40	USD	1982-07-29	Full-time	Female	88678 Marcelino Radial, Jaydonboro, ND 64072	1-602-894-5176	40.0
84	EMP00000084	Danielle	W	Gislason	Danielle Gislason	Danielle Gislason	Manager	danielle.gislason@nestey.co	2023-03-16 00:00:00	5	20	43	active	148291.21	t	0.25	t	1.40	USD	1961-04-09	Full-time	Female	73362 E Washington Avenue, Tacoma, KY 64878	1-425-713-8049	40.0
85	EMP00000085	Elbert	D	Gleichner	Elbert Gleichner	Elbert Gleichner	Manager	elbert.gleichner@nestey.co	2022-02-21 00:00:00	5	20	44	active	109921.69	t	0.25	t	1.40	USD	1965-05-13	Full-time	Male	8528 Hall Lane, North Lilian, OR 73747	1-801-375-9420	40.0
86	EMP00000086	Kelly	\N	Connelly	Kelly Connelly	Kelly Connelly	Manager	kelly.connelly@nestey.co	2016-07-22 00:00:00	5	20	44	active	148854.42	t	0.25	t	1.40	USD	1979-11-19	Full-time	Male	82922 Roob Canyon, Swaniawskistead, IN 83481	1-323-685-1709	40.0
87	EMP00000087	Abraham	\N	Doyle	Abraham Doyle	Abraham Doyle	Manager	abraham.doyle@nestey.co	2023-06-21 00:00:00	5	20	45	active	145183.99	t	0.25	t	1.40	USD	1968-08-22	Full-time	Male	771 Antone Burgs, Port Lonnyberg, NE 99889	1-718-329-6401	40.0
88	EMP00000088	Darlene	\N	Predovic	Darlene Predovic	Darlene Predovic	Manager	darlene.predovic@nestey.co	2020-09-20 00:00:00	5	20	45	active	127233.17	t	0.25	t	1.40	USD	1962-04-25	Full-time	Female	353 Legros Shoals, Lorenview, CO 58514	1-214-732-8569	40.0
89	EMP00000089	Randolph	D	Hoppe	Randolph Hoppe	Randolph Hoppe	Manager	randolph.hoppe@nestey.co	2018-06-21 00:00:00	5	20	46	active	115244.53	t	0.25	t	1.40	USD	1962-12-26	Full-time	Male	398 Carter Knoll, Marcelton, OR 40250	1-510-479-6132	40.0
90	EMP00000090	Arnold	G	Maggio	Arnold Maggio	Arnold Maggio	Manager	arnold.maggio@nestey.co	2023-05-19 00:00:00	5	20	46	active	102667.02	t	0.25	t	1.40	USD	1979-02-11	Full-time	Male	603 Noemie Plain, Edmond, CA 18863	1-612-349-7250	40.0
91	EMP00000091	Kelley	H	Beatty	Kelley Beatty	Kelley Beatty	Manager	kelley.beatty@nestey.co	2017-03-29 00:00:00	5	20	46	active	101517.94	t	0.25	t	1.40	USD	1968-05-29	Full-time	Female	105 Hill Road, Kihnboro, ME 52923	1-404-879-2308	40.0
92	EMP00000092	Rodolfo	C	Bartoletti	Rodolfo Bartoletti	Rodolfo Bartoletti	Manager	rodolfo.bartoletti@nestey.co	2021-11-11 00:00:00	9	37	47	active	93677.36	t	0.25	f	0.00	USD	1964-05-04	Full-time	Male	881 Carlie Mall, New Thora, TX 45089	1-713-925-3478	40.0
93	EMP00000093	Willie	S	Sawayn	Willie Sawayn	Willie Sawayn	Manager	willie.sawayn@nestey.co	2017-04-07 00:00:00	9	37	47	active	120386.84	t	0.25	f	0.00	USD	1979-12-24	Full-time	Male	6154 Kuhn Garden, Hermistonton, NV 40858	1-469-280-5791	40.0
94	EMP00000094	Terry	C	Harris	Terry Harris	Terry Harris	Manager	terry.harris@nestey.co	2019-02-19 00:00:00	9	37	48	active	136282.13	t	0.25	f	0.00	USD	1981-10-29	Full-time	Male	6581 Cicero Parkways, Darrickport, ID 51577	1-804-912-7306	40.0
95	EMP00000095	Cody	T	Nikolaus	Cody Nikolaus	Cody Nikolaus	Manager	cody.nikolaus@nestey.co	2021-11-22 00:00:00	9	37	48	active	132594.65	t	0.25	f	0.00	USD	1988-06-16	Full-time	Male	7416 Post Road, Beaverton, NY 50597	1-215-671-4285	40.0
96	EMP00000096	Lela	U	Morissette	Lela Morissette	Lela Morissette	Manager	lela.morissette@nestey.co	2017-10-23 00:00:00	9	37	49	active	148367.10	t	0.25	f	0.00	USD	1965-06-09	Full-time	Female	233 Huel Plains, Paoloberg, DE 36963	1-714-923-8507	40.0
97	EMP00000097	Whitney	V	Purdy	Whitney Purdy	Whitney Purdy	Manager	whitney.purdy@nestey.co	2018-08-25 00:00:00	9	37	49	active	124746.32	t	0.25	f	0.00	USD	1969-06-02	Full-time	Female	48677 Crooks Ports, Schinnerstead, NH 11069	1-503-314-9708	40.0
98	EMP00000098	Ryan	I	Fahey	Ryan Fahey	Ryan Fahey	Manager	ryan.fahey@nestey.co	2018-07-04 00:00:00	9	37	50	active	103410.74	t	0.25	f	0.00	USD	1966-05-13	Full-time	Male	458 Spring Gardens, New Mitchel, WV 14680	1-646-284-3519	40.0
99	EMP00000099	Bryan	N	Paucek	Bryan Paucek	Bryan Paucek	Manager	bryan.paucek@nestey.co	2020-06-13 00:00:00	9	37	50	active	128953.68	t	0.25	f	0.00	USD	1987-12-25	Full-time	Male	9480 Upton Points, Pico Rivera, NE 09315	1-702-583-1740	40.0
103	EMP00000103	Elaine	K	Haley	Elaine Haley	Elaine Haley	Manager	elaine.haley@nestey.co	2017-03-16 00:00:00	8	33	52	active	147780.67	t	0.25	f	0.00	USD	1996-04-20	Full-time	Female	49820 School Close, West Krystal, CA 72795	1-512-946-2308	40.0
104	EMP00000104	Diana	M	Smitham	Diana Smitham	Diana Smitham	Manager	diana.smitham@nestey.co	2016-06-22 00:00:00	8	33	52	active	90621.64	t	0.25	f	0.00	USD	1965-01-31	Full-time	Female	377 Cruickshank Pass, North Pierceland, SC 30746	1-415-763-5927	40.0
105	EMP00000105	Manuel	Z	Predovic	Manuel Predovic	Manuel Predovic	Manager	manuel.predovic@nestey.co	2023-10-28 00:00:00	8	33	53	active	98737.78	t	0.25	f	0.00	USD	1967-08-17	Full-time	Male	33543 Moore Branch, Port Linnieton, AR 23123	1-602-315-4890	40.0
106	EMP00000106	David	T	Streich	David Streich	David Streich	Manager	david.streich@nestey.co	2023-01-31 00:00:00	8	33	53	active	107152.51	t	0.25	f	0.00	USD	1962-03-02	Full-time	Male	36446 Pansy Neck, South Chandlerport, VA 05753	1-718-924-3706	40.0
107	EMP00000107	Ashley	K	Beier	Ashley Beier	Ashley Beier	Manager	ashley.beier@nestey.co	2020-10-24 00:00:00	7	9	301	active	145040.40	t	0.25	f	0.00	USD	1992-05-18	Full-time	Female	706 Bedford Road, Willview, AL 93559	1-916-273-8540	40.0
108	EMP00000108	Earnest	C	Ward-Feil	Earnest Ward-Feil	Earnest Ward-Feil	Manager	earnest.ward-feil@nestey.co	2017-03-26 00:00:00	7	9	301	active	149595.03	t	0.25	f	0.00	USD	1966-05-28	Full-time	Male	2664 Toy Corners, McGlynnworth, VT 60361	1-503-472-6195	40.0
109	EMP00000109	Tom	J	Spencer	Tom Spencer	Tom Spencer	Manager	tom.spencer@nestey.co	2020-01-07 00:00:00	7	9	301	active	102494.83	t	0.25	f	0.00	USD	1976-01-25	Full-time	Male	5518 State Avenue, Inglewood, OK 76023	1-617-894-3206	40.0
110	EMP00000110	Rolando	F	Kassulke	Rolando Kassulke	Rolando Kassulke	Manager	rolando.kassulke@nestey.co	2017-01-11 00:00:00	7	9	301	active	121601.03	t	0.25	f	0.00	USD	1978-08-14	Full-time	Male	679 Poplar Close, Mattburgh, LA 36055	1-808-233-7851	40.0
111	EMP00000111	Barbara	N	Stiedemann	Barbara Stiedemann	Barbara Stiedemann	Manager	barbara.stiedemann@nestey.co	2020-10-25 00:00:00	7	9	301	active	110867.00	t	0.25	f	0.00	USD	1975-05-30	Full-time	Female	11115 Western Avenue, Jonesview, NJ 30093	1-404-662-1794	40.0
112	EMP00000112	Lance	Z	Ferry	Lance Ferry	Lance Ferry	Manager	lance.ferry@nestey.co	2016-06-09 00:00:00	7	9	301	active	137554.99	t	0.25	f	0.00	USD	1976-01-20	Full-time	Male	31843 Charles Street, Labadiestad, SC 13068	1-214-398-5207	40.0
113	EMP00000113	Gina	C	Nicolas	Gina Nicolas	Gina Nicolas	Manager	gina.nicolas@nestey.co	2017-10-27 00:00:00	6	9	33	active	137802.39	t	0.25	f	0.00	USD	1996-11-04	Full-time	Female	19610 S 1st Avenue, Hubertworth, NV 98102	1-720-541-3982	40.0
114	EMP00000114	Minnie	K	Quitzon-Walsh	Minnie Quitzon-Walsh	Minnie Quitzon-Walsh	Manager	minnie.quitzon-walsh@nestey.co	2016-11-05 00:00:00	6	9	33	active	115869.43	t	0.25	f	0.00	USD	1978-08-24	Full-time	Female	1896 Andres Shoal, Stokesland, MN 99030	1-971-628-0375	40.0
115	EMP00000115	Michele	Y	Carter	Michele Carter	Michele Carter	Manager	michele.carter@nestey.co	2024-06-18 00:00:00	6	9	34	active	100544.17	t	0.25	f	0.00	USD	1996-02-24	Full-time	Female	711 Birch Avenue, Evanston, WY 96243	1-832-915-7043	40.0
116	EMP00000116	Stanley	Z	Hilll	Stanley Hilll	Stanley Hilll	Manager	stanley.hilll@nestey.co	2022-11-20 00:00:00	6	9	34	active	132080.59	t	0.25	f	0.00	USD	1979-07-27	Full-time	Male	198 Jaycee Loaf, Hillardboro, MI 08285	1-919-406-5829	40.0
126	EMP00000126	Myrna	X	Kuhlman	Myrna Kuhlman	Myrna Kuhlman	Individual Contributor	myrna.kuhlman@nestey.co	2022-03-03 00:00:00	3	11	66	active	57961.15	t	0.30	f	0.00	USD	1991-10-14	Full-time	Non-Binary	4039 Grimes Fork, North Adrienneworth, MN 62174	1-510-847-2360	40.0
127	EMP00000127	Jasmine	V	Altenwerth	Jasmine Altenwerth	Jasmine Altenwerth	Individual Contributor	jasmine.altenwerth@nestey.co	2020-10-05 00:00:00	3	11	66	active	87211.95	t	0.30	f	0.00	USD	1971-11-14	Full-time	Female	464 Wood Street, Lake Brainboro, ID 01900	1-612-294-7085	40.0
128	EMP00000128	Rafael	V	Swift	Rafael Swift	Rafael Swift	Individual Contributor	rafael.swift@nestey.co	2021-09-12 00:00:00	3	11	66	active	70351.24	f	0.00	f	0.00	USD	1979-04-22	Full-time	Male	781 Salvador Field, Madera, KS 72112	1-404-895-3074	40.0
129	EMP00000129	Deborah	D	Zulauf	Deborah Zulauf	Deborah Zulauf	Individual Contributor	deborah.zulauf@nestey.co	2018-11-12 00:00:00	3	11	66	active	78793.07	f	0.00	f	0.00	USD	1991-11-26	Full-time	Female	745 Schinner Extension, Bayamon, KS 26348	1-973-248-6905	40.0
130	EMP00000130	Dana	P	Zulauf	Dana Zulauf	Dana Zulauf	Individual Contributor	dana.zulauf@nestey.co	2018-01-24 00:00:00	3	11	66	active	81298.95	t	0.30	f	0.00	USD	1996-11-24	Full-time	Male	19045 Woodland Road, Iowa City, WA 28440	1-971-419-8752	40.0
131	EMP00000131	Taylor	H	Pagac	Taylor Pagac	Taylor Pagac	Individual Contributor	taylor.pagac@nestey.co	2019-05-03 00:00:00	3	11	67	active	65217.44	t	0.30	f	0.00	USD	1961-05-21	Full-time	Male	324 Larkin Crest, Goodwinshire, NV 06843	1-702-978-3405	40.0
132	EMP00000132	Eileen	T	O'Kon	Eileen O'Kon	Eileen O'Kon	Individual Contributor	eileen.o'kon@nestey.co	2023-02-15 00:00:00	3	11	67	active	71778.59	t	0.30	f	0.00	USD	1980-05-22	Full-time	Female	5136 Marlborough Road, Bedford, CA 57483	1-206-579-2481	40.0
133	EMP00000133	Donald	I	Cremin	Donald Cremin	Donald Cremin	Individual Contributor	donald.cremin@nestey.co	2021-06-01 00:00:00	1	6	29	active	63757.08	t	0.30	f	0.00	USD	1970-12-02	Full-time	Male	32764 Homenick Point, Jarenborough, NH 68275	1-858-612-9703	40.0
134	EMP00000134	Toni	G	Kovacek	Toni Kovacek	Toni Kovacek	Individual Contributor	toni.kovacek@nestey.co	2018-06-16 00:00:00	1	6	29	active	58473.90	f	0.20	f	0.00	USD	1980-11-12	Full-time	Female	7002 Melvin Inlet, Padbergborough, TN 12356	1-503-784-6914	40.0
135	EMP00000135	Bradley	J	McLaughlin-Ruecker	Bradley McLaughlin-Ruecker	Bradley McLaughlin-Ruecker	Individual Contributor	bradley.mclaughlin-ruecker@nestey.co	2017-10-25 00:00:00	1	7	29	active	73948.44	t	0.30	f	0.00	USD	1997-12-18	Full-time	Male	884 Cronin Mews, Round Rock, AR 87589	1-407-290-6718	40.0
136	EMP00000136	Betsy	Q	Cole	Betsy Cole	Betsy Cole	Individual Contributor	betsy.cole@nestey.co	2024-11-08 00:00:00	1	7	29	active	57263.69	f	0.00	f	0.00	USD	1983-11-27	Full-time	Female	300 Stokes Falls, Amparofurt, VT 46659	1-513-486-2937	40.0
137	EMP00000137	Bradford	U	Weber	Bradford Weber	Bradford Weber	Individual Contributor	bradford.weber@nestey.co	2023-05-21 00:00:00	1	7	30	active	78150.86	t	0.30	f	0.00	USD	1998-01-28	Full-time	Male	91027 Satterfield Gateway, East Pansyboro, RI 72521	1-917-925-4870	40.0
138	EMP00000138	Annette	Z	Gorczany-Bednar	Annette Gorczany-Bednar	Annette Gorczany-Bednar	Individual Contributor	annette.gorczany-bednar@nestey.co	2023-12-17 00:00:00	1	7	30	active	82609.30	t	0.30	f	0.00	USD	1980-02-04	Full-time	Female	54479 Clemmie Fall, Terryshire, AR 68559	1-760-943-2819	40.0
139	EMP00000139	Benjamin	T	Homenick	Benjamin Homenick	Benjamin Homenick	Individual Contributor	benjamin.homenick@nestey.co	2016-04-21 00:00:00	1	7	30	active	85981.23	t	0.30	f	0.00	USD	1998-09-24	Full-time	Male	70206 Dessie Extension, Baltimore, GA 02723	1-615-974-8035	40.0
152	EMP00000152	Ronald	\N	Hagenes	Ronald Hagenes	Ronald Hagenes	Individual Contributor	ronald.hagenes@nestey.co	2018-11-20 00:00:00	5	20	75	active	83628.66	f	0.00	t	1.20	USD	1971-01-17	Full-time	Male	3410 Giovanni Motorway, Gildaport, CA 30062	1-312-703-9208	40.0
153	EMP00000153	Brittany	\N	Rice	Brittany Rice	Brittany Rice	Individual Contributor	brittany.rice@nestey.co	2020-06-18 00:00:00	5	20	75	active	81712.48	f	0.00	t	1.20	USD	1970-08-24	Full-time	Female	7122 Jedidiah Circles, Quigleyfield, MO 24035	1-925-846-7913	40.0
154	EMP00000154	Gwendolyn	M	Zemlak	Gwendolyn Zemlak	Gwendolyn Zemlak	Individual Contributor	gwendolyn.zemlak@nestey.co	2019-06-10 00:00:00	5	20	75	active	71468.80	f	0.20	t	1.20	USD	1976-10-02	Full-time	Female	767 Baumbach Cape, Port Whitneybury, ND 53050	1-978-654-2379	40.0
155	EMP00000155	Allen	G	Quigley	Allen Quigley	Allen Quigley	Individual Contributor	allen.quigley@nestey.co	2016-12-16 00:00:00	5	20	75	active	75965.75	f	0.30	t	1.20	USD	1979-11-04	Full-time	Male	3156 The Mews, West Myrafurt, KY 97381	1-714-690-8457	40.0
156	EMP00000156	Diana	L	Runolfsdottir	Diana Runolfsdottir	Diana Runolfsdottir	Individual Contributor	diana.runolfsdottir@nestey.co	2023-03-23 00:00:00	5	20	76	active	76110.70	f	0.20	t	1.20	USD	1994-07-07	Full-time	Non-Binary	23762 Osinski Streets, Rocky Mount, MI 05905	1-843-972-3168	40.0
157	EMP00000157	Guillermo	X	Padberg	Guillermo Padberg	Guillermo Padberg	Individual Contributor	guillermo.padberg@nestey.co	2022-08-18 00:00:00	5	20	76	active	72767.27	f	0.20	t	1.20	USD	1992-03-08	Full-time	Male	86978 Medhurst Courts, Konopelskishire, ME 08833	1-408-279-5630	40.0
158	EMP00000158	Shayne	J	Ward	Shayne Ward	Shayne Ward	Individual Contributor	shayne.ward@nestey.co	2022-09-16 00:00:00	5	20	76	active	78539.84	f	0.00	t	1.20	USD	1987-02-15	Full-time	Non-Binary	241 Mertz Squares, Jakaylastad, MO 97298	1-707-981-3506	40.0
159	EMP00000159	Raymond	S	Parisian	Raymond Parisian	Raymond Parisian	Individual Contributor	raymond.parisian@nestey.co	2023-03-25 00:00:00	5	20	77	active	84115.32	f	0.00	t	1.20	USD	1978-10-07	Full-time	Male	6842 Ritchie Motorway, Chicopee, ME 25765	1-323-604-2895	40.0
160	EMP00000160	Josefina	L	Braun	Josefina Braun	Josefina Braun	Individual Contributor	josefina.braun@nestey.co	2020-07-23 00:00:00	5	20	77	active	58195.50	f	0.00	t	1.20	USD	1996-12-29	Full-time	Female	70467 Pollich Rapids, Josianeside, MT 02351	1-718-993-4270	40.0
161	EMP00000161	Cleora	Z	Lowe	Cleora Lowe	Cleora Lowe	Individual Contributor	cleora.lowe@nestey.co	2024-01-27 00:00:00	5	20	78	active	72377.58	f	0.00	t	1.20	USD	1990-11-05	Full-time	Non-Binary	973 Orchard Drive, Port Lesley, AR 27649	1-202-738-5419	40.0
162	EMP00000162	Suzanne	M	Padberg	Suzanne Padberg	Suzanne Padberg	Individual Contributor	suzanne.padberg@nestey.co	2019-12-15 00:00:00	5	20	78	active	77509.73	f	0.00	t	1.20	USD	1984-06-30	Full-time	Female	71438 Bettie Course, North Sabina, AR 20072	1-213-758-9061	40.0
163	EMP00000163	Elbert	W	Wuckert	Elbert Wuckert	Elbert Wuckert	Individual Contributor	elbert.wuckert@nestey.co	2024-05-05 00:00:00	5	20	78	active	77986.86	f	0.00	t	1.20	USD	1970-08-01	Full-time	Male	529 Moen Divide, Phoenix, MT 42339	1-703-621-5870	40.0
164	EMP00000164	Dave	C	Renner	Dave Renner	Dave Renner	Individual Contributor	dave.renner@nestey.co	2021-06-18 00:00:00	5	20	78	active	76426.15	f	0.00	t	1.20	USD	1981-01-03	Full-time	Male	1331 Hazel Close, Gideonton, PA 88902	1-805-741-2083	40.0
165	EMP00000165	Devin	O	Leannon	Devin Leannon	Devin Leannon	Individual Contributor	devin.leannon@nestey.co	2022-03-04 00:00:00	5	20	79	active	86232.63	f	0.00	t	1.20	USD	1996-05-31	Full-time	Male	300 The Paddocks, Liamview, MI 52752	1-970-642-3905	40.0
166	EMP00000166	Kayla	W	Harvey	Kayla Harvey	Kayla Harvey	Individual Contributor	kayla.harvey@nestey.co	2016-06-18 00:00:00	5	20	79	active	83493.17	f	0.00	t	1.20	USD	1966-08-27	Full-time	Female	3280 N Railroad Street, West Kearastad, CA 74517	1-847-925-3648	40.0
167	EMP00000167	Leroy	I	Ruecker	Leroy Ruecker	Leroy Ruecker	Individual Contributor	leroy.ruecker@nestey.co	2019-06-10 00:00:00	5	20	79	active	84530.87	f	0.00	t	1.20	USD	1970-01-14	Full-time	Male	77258 Weston Drive, Fort Sophiemouth, ME 58171	1-602-783-4916	40.0
168	EMP00000168	Juana	X	Haley	Juana Haley	Juana Haley	Individual Contributor	juana.haley@nestey.co	2020-12-12 00:00:00	5	20	80	active	76297.87	f	0.00	t	1.20	USD	1983-02-01	Full-time	Female	2889 Lindsay Springs, Alfredcester, MA 65109	1-646-290-8034	40.0
169	EMP00000169	Wilma	B	Romaguera	Wilma Romaguera	Wilma Romaguera	Individual Contributor	wilma.romaguera@nestey.co	2022-10-11 00:00:00	5	20	80	active	88251.69	f	0.00	t	1.20	USD	1964-02-19	Full-time	Female	433 Maggio Parkway, Port Floridastead, WV 61496	1-504-972-4610	40.0
170	EMP00000170	Marcella	J	Hilll	Marcella Hilll	Marcella Hilll	Individual Contributor	marcella.hilll@nestey.co	2024-04-08 00:00:00	5	20	80	active	60195.79	f	0.00	t	1.20	USD	1984-01-26	Full-time	Female	8562 Sycamore Avenue, Feeneyburgh, MS 29649	1-917-470-9532	40.0
171	EMP00000171	Derrick	E	Beier	Derrick Beier	Derrick Beier	Individual Contributor	derrick.beier@nestey.co	2021-05-07 00:00:00	5	20	80	active	72658.20	f	0.20	t	1.20	USD	1983-08-22	Full-time	Male	18217 St Andrew's Road, North Ayla, HI 46890	1-512-642-9130	40.0
172	EMP00000172	Jacquelyn	E	Quigley	Jacquelyn Quigley	Jacquelyn Quigley	Individual Contributor	jacquelyn.quigley@nestey.co	2018-11-10 00:00:00	5	20	80	active	78450.73	f	0.00	t	1.20	USD	1981-03-06	Full-time	Female	605 Mraz Court, New Orleans, TN 09740	1-415-628-4931	40.0
173	EMP00000173	Doyle	Q	Gusikowski	Doyle Gusikowski	Doyle Gusikowski	Individual Contributor	doyle.gusikowski@nestey.co	2023-03-23 00:00:00	5	20	81	active	64415.04	f	0.00	t	1.20	USD	1986-04-11	Full-time	Male	902 Morissette Harbors, Port Orange, ND 52551	1-305-948-7293	40.0
174	EMP00000174	Priscilla	D	Von	Priscilla Von	Priscilla Von	Individual Contributor	priscilla.von@nestey.co	2021-03-14 00:00:00	5	20	81	active	80060.06	f	0.00	t	1.20	USD	1988-01-13	Full-time	Female	2040 Park View, Rosenbaumtown, MI 58703	1-763-520-1874	40.0
175	EMP00000175	Harriet	I	Quigley	Harriet Quigley	Harriet Quigley	Individual Contributor	harriet.quigley@nestey.co	2021-03-05 00:00:00	5	20	81	active	83533.51	f	0.00	t	1.20	USD	1964-04-08	Full-time	Female	47877 Wilmer Keys, Burleson, VT 24245	1-209-481-9325	40.0
176	EMP00000176	Travis	B	Lynch	Travis Lynch	Travis Lynch	Individual Contributor	travis.lynch@nestey.co	2016-07-15 00:00:00	5	20	81	active	55419.62	f	0.20	t	1.20	USD	1967-05-07	Full-time	Male	971 Yundt Shore, Jevontown, ME 17749	1-407-892-6301	40.0
177	EMP00000177	Devin	G	Denesik	Devin Denesik	Devin Denesik	Individual Contributor	devin.denesik@nestey.co	2019-11-13 00:00:00	5	20	82	active	76935.52	f	0.00	t	1.20	USD	2000-12-30	Full-time	Male	3751 Marks Port, Fort Naomie, MO 54433	1-808-941-2370	40.0
178	EMP00000178	Lamont	T	Langosh	Lamont Langosh	Lamont Langosh	Individual Contributor	lamont.langosh@nestey.co	2019-07-03 00:00:00	5	20	82	active	74814.83	f	0.00	t	1.20	USD	1961-09-30	Full-time	Non-Binary	436 Cassandra Valleys, Veumcester, NJ 09277	1-214-890-7609	40.0
179	EMP00000179	Salvador	G	Shields	Salvador Shields	Salvador Shields	Individual Contributor	salvador.shields@nestey.co	2016-08-07 00:00:00	5	20	82	active	75487.06	f	0.00	t	1.20	USD	1964-10-02	Full-time	Male	82338 Bart Bridge, Fort Jettieside, WI 24290	1-516-473-9028	40.0
180	EMP00000180	Wilbur	U	Hickle	Wilbur Hickle	Wilbur Hickle	Individual Contributor	wilbur.hickle@nestey.co	2021-09-22 00:00:00	5	20	83	active	86654.19	f	0.00	t	1.20	USD	1981-11-22	Full-time	Male	4389 Yundt Rue, Port Julieville, CA 61192	1-612-720-5830	40.0
181	EMP00000181	Calvin	O	Ullrich	Calvin Ullrich	Calvin Ullrich	Individual Contributor	calvin.ullrich@nestey.co	2024-03-25 00:00:00	5	20	83	active	74315.18	f	0.00	t	1.20	USD	1994-01-13	Full-time	Male	787 Karine Pine, Lake Carleton, DE 83899	1-347-329-4078	40.0
182	EMP00000182	Caterina	I	Frami	Caterina Frami	Caterina Frami	Individual Contributor	caterina.frami@nestey.co	2022-08-22 00:00:00	5	20	83	active	72747.29	f	0.00	t	1.20	USD	2000-03-24	Full-time	Non-Binary	738 Sonny Road, Hermannworth, VT 58038	1-502-394-7825	40.0
183	EMP00000183	Sammy	U	Kuhic	Sammy Kuhic	Sammy Kuhic	Individual Contributor	sammy.kuhic@nestey.co	2018-07-05 00:00:00	5	20	83	active	84426.70	f	0.00	t	1.20	USD	1965-05-19	Full-time	Male	9026 E 11th Street, Aliyafort, VT 33400	1-617-701-3942	40.0
184	EMP00000184	Casey	G	Mann	Casey Mann	Casey Mann	Individual Contributor	casey.mann@nestey.co	2016-11-22 00:00:00	5	20	83	active	78354.03	f	0.00	t	1.20	USD	1979-11-22	Full-time	Male	856 Derby Road, Murphyfort, FL 47184	1-781-913-6402	40.0
185	EMP00000185	Amanda	Q	Towne	Amanda Towne	Amanda Towne	Individual Contributor	amanda.towne@nestey.co	2016-04-24 00:00:00	5	20	84	active	82845.12	f	0.00	t	1.20	USD	1998-04-15	Full-time	Female	593 Wilfredo Crest, East Margaretfurt, AR 35796	1-702-638-7053	40.0
186	EMP00000186	Lorena	O	Dibbert	Lorena Dibbert	Lorena Dibbert	Individual Contributor	lorena.dibbert@nestey.co	2019-06-29 00:00:00	5	20	85	active	69500.29	f	0.00	t	1.20	USD	2000-01-14	Full-time	Female	615 State Line Road, Veumville, NY 92235	1-832-790-2614	40.0
187	EMP00000187	Katrina	Z	Bogan	Katrina Bogan	Katrina Bogan	Individual Contributor	katrina.bogan@nestey.co	2024-11-23 00:00:00	5	20	84	active	64012.87	f	0.00	t	1.20	USD	1981-12-27	Full-time	Female	878 Dach Corners, Port Julianboro, WI 47774	1-503-876-4207	40.0
188	EMP00000188	Duane	A	Purdy	Duane Purdy	Duane Purdy	Individual Contributor	duane.purdy@nestey.co	2021-05-23 00:00:00	5	20	84	active	64300.38	f	0.00	t	1.20	USD	1974-06-19	Full-time	Male	48057 Mitchell Meadow, North Murielshire, OH 21280	1-615-934-7208	40.0
193	EMP00000193	Dewey	K	Friesen	Dewey Friesen	Dewey Friesen	Individual Contributor	dewey.friesen@nestey.co	2018-08-10 00:00:00	5	20	86	active	85983.17	f	0.00	t	1.20	USD	1969-11-30	Full-time	Male	57460 Lake Street, Sunrise, HI 21484	1-818-279-6509	40.0
194	EMP00000194	Sophie	N	Kuhlman	Sophie Kuhlman	Sophie Kuhlman	Individual Contributor	sophie.kuhlman@nestey.co	2020-04-25 00:00:00	5	20	86	active	66912.55	f	0.00	t	1.20	USD	1961-09-10	Full-time	Female	440 Lucius Crescent, Croninberg, TX 37540	1-719-593-7428	40.0
195	EMP00000195	Earnest	Z	Fritsch	Earnest Fritsch	Earnest Fritsch	Individual Contributor	earnest.fritsch@nestey.co	2017-04-01 00:00:00	5	20	86	active	68717.21	f	0.00	t	1.20	USD	1989-03-12	Full-time	Male	9151 Christiansen Bridge, Watersstead, MT 86187	1-646-205-9830	40.0
196	EMP00000196	Matt	T	Terry	Matt Terry	Matt Terry	Individual Contributor	matt.terry@nestey.co	2019-05-27 00:00:00	5	20	86	active	67357.06	f	0.00	t	1.20	USD	1997-07-08	Full-time	Male	889 Destiny Neck, Tulsa, PA 38700	1-602-495-2371	40.0
197	EMP00000197	Jonathan	C	Fisher	Jonathan Fisher	Jonathan Fisher	Individual Contributor	jonathan.fisher@nestey.co	2016-11-22 00:00:00	5	20	86	active	58416.24	f	0.00	t	1.20	USD	1989-06-14	Full-time	Male	2075 Willow Drive, Sandy, HI 26560	1-407-642-8350	40.0
198	EMP00000198	Leslie	S	Doyle	Leslie Doyle	Leslie Doyle	Individual Contributor	leslie.doyle@nestey.co	2016-03-29 00:00:00	5	20	87	active	71600.90	f	0.00	t	1.20	USD	1975-05-15	Full-time	Female	2217 Vance Views, Hickleworth, ND 32545	1-503-924-1789	40.0
199	EMP00000199	Hazel	X	Doyle	Hazel Doyle	Hazel Doyle	Individual Contributor	hazel.doyle@nestey.co	2020-01-06 00:00:00	5	20	87	active	83004.11	f	0.00	t	1.20	USD	1979-05-28	Full-time	Female	725 Cherry Tree Close, Port Maidaport, OR 37913	1-312-790-5482	40.0
200	EMP00000200	Mitchell	Z	Hansen	Mitchell Hansen	Mitchell Hansen	Individual Contributor	mitchell.hansen@nestey.co	2021-11-11 00:00:00	5	20	87	active	83443.69	f	0.00	t	1.20	USD	1971-04-24	Full-time	Male	8465 Doyle Rue, Anibalburgh, GA 02065	1-510-237-4061	40.0
201	EMP00000201	Donna	S	Nolan	Donna Nolan	Donna Nolan	Individual Contributor	donna.nolan@nestey.co	2020-03-12 00:00:00	5	20	88	active	69035.23	f	0.00	t	1.20	USD	1995-07-31	Full-time	Female	889 Breitenberg Port, O'Connellchester, MI 70348	1-925-983-5049	40.0
202	EMP00000202	Ernest	A	Mann	Ernest Mann	Ernest Mann	Individual Contributor	ernest.mann@nestey.co	2021-08-29 00:00:00	5	20	88	active	81652.90	f	0.00	t	1.20	USD	1978-08-07	Full-time	Male	935 Nienow Harbors, North Verna, TN 48513	1-561-293-8704	40.0
203	EMP00000203	Pat	W	Kovacek	Pat Kovacek	Pat Kovacek	Individual Contributor	pat.kovacek@nestey.co	2024-10-03 00:00:00	5	20	88	active	73112.26	f	0.00	t	1.20	USD	1972-03-02	Full-time	Female	724 St George's Road, Wilkinsonland, ND 72712	1-206-320-7953	40.0
204	EMP00000204	Sabrina	Y	Kirlin	Sabrina Kirlin	Sabrina Kirlin	Individual Contributor	sabrina.kirlin@nestey.co	2018-02-14 00:00:00	5	20	88	active	65186.80	f	0.00	t	1.20	USD	1978-09-16	Full-time	Female	5665 Casper Rest, Shreveport, AL 25283	1-323-910-4837	40.0
205	EMP00000205	Anthony	S	Miller	Anthony Miller	Anthony Miller	Individual Contributor	anthony.miller@nestey.co	2024-12-25 00:00:00	5	20	88	active	62952.39	f	0.00	t	1.20	USD	1961-05-12	Full-time	Male	8596 Konopelski Skyway, West Rebekastad, WA 92715	1-971-680-4205	40.0
206	EMP00000206	Kelly	Y	Hoeger	Kelly Hoeger	Kelly Hoeger	Individual Contributor	kelly.hoeger@nestey.co	2021-02-09 00:00:00	5	20	89	active	72373.08	f	0.00	t	1.20	USD	1988-04-10	Full-time	Male	30568 Audie Lane, Lowell, MN 96273	1-646-801-5973	40.0
207	EMP00000207	Stewart	R	Heidenreich	Stewart Heidenreich	Stewart Heidenreich	Individual Contributor	stewart.heidenreich@nestey.co	2020-07-01 00:00:00	5	20	89	active	57046.82	f	0.00	t	1.20	USD	1991-03-03	Full-time	Male	843 Oceane Knolls, South Maymie, VT 04184	1-714-679-3058	40.0
208	EMP00000208	Alicia	D	Hermann	Alicia Hermann	Alicia Hermann	Individual Contributor	alicia.hermann@nestey.co	2020-03-11 00:00:00	5	20	89	active	82267.15	f	0.20	t	1.20	USD	1966-04-05	Full-time	Female	57954 Oak Avenue, Lake Beau, TX 53115	1-702-874-2496	40.0
209	EMP00000209	Stanley	Y	Dach	Stanley Dach	Stanley Dach	Individual Contributor	stanley.dach@nestey.co	2017-08-11 00:00:00	5	20	89	active	82279.86	f	0.20	t	1.20	USD	1991-04-14	Full-time	Male	37101 Keeling Highway, South Reidfort, NE 84155	1-504-721-3084	40.0
210	EMP00000210	Laverne	U	Monahan	Laverne Monahan	Laverne Monahan	Individual Contributor	laverne.monahan@nestey.co	2023-12-12 00:00:00	5	20	90	active	83634.82	f	0.00	t	1.20	USD	1973-05-09	Full-time	Female	9799 Botsford Club, North Adrianaport, SD 67615	1-808-436-9720	40.0
211	EMP00000211	Jane	V	Lemke	Jane Lemke	Jane Lemke	Individual Contributor	jane.lemke@nestey.co	2023-10-21 00:00:00	5	20	90	active	59583.78	f	0.00	t	1.20	USD	1990-06-28	Full-time	Female	543 Prosacco Fields, Wichita, DE 59038	1-347-809-5427	40.0
212	EMP00000212	Rodolfo	L	Cruickshank	Rodolfo Cruickshank	Rodolfo Cruickshank	Individual Contributor	rodolfo.cruickshank@nestey.co	2017-07-01 00:00:00	5	20	90	active	88611.41	f	0.00	t	1.20	USD	1987-03-03	Full-time	Male	376 Alvina Hill, Fort Isomberg, ID 54540	1-415-826-9072	40.0
213	EMP00000213	Dallas	W	Bosco	Dallas Bosco	Dallas Bosco	Individual Contributor	dallas.bosco@nestey.co	2021-07-30 00:00:00	5	20	91	active	87466.91	f	0.00	t	1.20	USD	1985-01-15	Full-time	Male	2198 Gerlach Knolls, Kemmerfurt, MA 57629	1-516-290-6438	40.0
214	EMP00000214	Max	V	Barton	Max Barton	Max Barton	Individual Contributor	max.barton@nestey.co	2022-03-15 00:00:00	5	20	91	active	61181.89	f	0.00	t	1.20	USD	1982-01-24	Full-time	Male	5914 Beier Bridge, South Tremayne, ND 44291	1-720-603-5794	40.0
215	EMP00000215	Bradley	V	McKenzie	Bradley McKenzie	Bradley McKenzie	Individual Contributor	bradley.mckenzie@nestey.co	2022-12-01 00:00:00	5	20	91	active	80457.47	f	0.00	t	1.20	USD	1964-04-30	Full-time	Male	9097 S Water Street, South Tobyport, ND 84678	1-805-413-6928	40.0
216	EMP00000216	Anne	Q	McDermott	Anne McDermott	Anne McDermott	Individual Contributor	anne.mcdermott@nestey.co	2016-08-07 00:00:00	5	20	91	active	70840.26	f	0.00	t	1.20	USD	1981-05-08	Full-time	Female	2549 Dooley Spurs, Georgetown, OR 00160	1-512-539-7810	40.0
217	EMP00000217	Allan	F	Kozey	Allan Kozey	Allan Kozey	Individual Contributor	allan.kozey@nestey.co	2019-12-28 00:00:00	5	20	91	active	78924.09	f	0.00	t	1.20	USD	1992-06-17	Full-time	Male	3951 Kuvalis Cliffs, Katrinebury, WV 00105	1-702-331-6409	40.0
218	EMP00000218	Destany	G	Kassulke	Destany Kassulke	Destany Kassulke	Individual Contributor	destany.kassulke@nestey.co	2023-03-31 00:00:00	5	20	91	active	63287.78	f	0.00	t	1.20	USD	1983-04-01	Full-time	Non-Binary	33521 Kamille Point, East Gerhardburgh, TN 00829	1-213-940-7628	40.0
219	EMP00000219	Chaim	B	Kiehn	Chaim Kiehn	Chaim Kiehn	Individual Contributor	chaim.kiehn@nestey.co	2020-06-03 00:00:00	9	36	92	active	88736.34	f	0.00	f	0.00	USD	1995-06-04	Full-time	Non-Binary	95135 River Road, East Kailey, NH 77372	1-817-492-6308	40.0
220	EMP00000220	Danny	Q	Schaefer	Danny Schaefer	Danny Schaefer	Individual Contributor	danny.schaefer@nestey.co	2017-10-26 00:00:00	9	36	92	active	77726.25	f	0.00	f	0.00	USD	1963-05-09	Full-time	Male	734 Rohan Trail, Rohanport, OH 82772	1-919-764-3082	40.0
221	EMP00000221	Elias	\N	Barrows	Elias Barrows	Elias Barrows	Individual Contributor	elias.barrows@nestey.co	2019-10-02 00:00:00	9	36	92	active	79859.05	f	0.00	f	0.00	USD	1974-07-07	Full-time	Male	448 Boyle Tunnel, Cedar Hill, OK 84698	1-213-748-9153	40.0
222	EMP00000222	Guillermo	F	McKenzie	Guillermo McKenzie	Guillermo McKenzie	Individual Contributor	guillermo.mckenzie@nestey.co	2018-04-27 00:00:00	9	36	93	active	75635.36	f	0.00	f	0.00	USD	1970-03-09	Full-time	Male	4410 Heller Mount, Robynberg, VT 37280	1-904-621-7309	40.0
223	EMP00000223	Jacqueline	H	Blick	Jacqueline Blick	Jacqueline Blick	Individual Contributor	jacqueline.blick@nestey.co	2022-09-27 00:00:00	9	36	93	active	70193.74	f	0.00	f	0.00	USD	1982-09-05	Full-time	Female	383 Bridge Road, Willmsville, CA 40336	1-508-692-3470	40.0
224	EMP00000224	Roy	N	Stehr	Roy Stehr	Roy Stehr	Individual Contributor	roy.stehr@nestey.co	2019-08-23 00:00:00	9	36	94	active	78307.18	f	0.00	f	0.00	USD	1969-06-28	Full-time	Male	928 Johnson Street, Lake Quinton, AK 50629	1-602-817-4962	40.0
225	EMP00000225	Roderick	W	Kautzer	Roderick Kautzer	Roderick Kautzer	Individual Contributor	roderick.kautzer@nestey.co	2024-06-22 00:00:00	9	36	94	active	56989.84	f	0.00	f	0.00	USD	1970-03-25	Full-time	Male	282 O'Kon Ridge, New Johnathon, CO 56402	1-425-372-9406	40.0
226	EMP00000226	Louise	R	Heaney	Louise Heaney	Louise Heaney	Individual Contributor	louise.heaney@nestey.co	2021-12-15 00:00:00	9	36	94	active	88299.30	f	0.00	f	0.00	USD	1989-01-09	Full-time	Female	46363 Hills Mount, Highland, WY 61590	1-801-972-5810	40.0
227	EMP00000227	April	U	Heller	April Heller	April Heller	Individual Contributor	april.heller@nestey.co	2021-08-04 00:00:00	9	36	94	active	63076.61	f	0.00	f	0.00	USD	1964-06-29	Full-time	Female	525 Cleve Stream, Tyraboro, TN 24310	1-323-714-9523	40.0
228	EMP00000228	Dana	D	Ratke	Dana Ratke	Dana Ratke	Individual Contributor	dana.ratke@nestey.co	2018-08-29 00:00:00	9	36	95	active	78860.42	f	0.00	f	0.00	USD	1960-10-23	Full-time	Female	342 Charley Port, Lawrence, NV 57085	1-718-405-6702	40.0
229	EMP00000229	Margaret	G	Armstrong	Margaret Armstrong	Margaret Armstrong	Individual Contributor	margaret.armstrong@nestey.co	2021-05-20 00:00:00	9	36	95	active	89829.21	f	0.00	f	0.00	USD	1994-07-14	Full-time	Female	3868 Deangelo Shoal, New Stanleyland, OK 62690	1-214-603-8195	40.0
230	EMP00000230	Victoria	C	Auer	Victoria Auer	Victoria Auer	Individual Contributor	victoria.auer@nestey.co	2024-04-08 00:00:00	9	36	96	active	79595.26	f	0.00	f	0.00	USD	1960-07-12	Full-time	Female	112 Pine Close, Trantowport, NV 36197	1-510-671-4920	40.0
231	EMP00000231	Billie	C	McDermott	Billie McDermott	Billie McDermott	Individual Contributor	billie.mcdermott@nestey.co	2019-10-03 00:00:00	9	36	96	active	61312.96	f	0.00	f	0.00	USD	1989-03-03	Full-time	Female	3291 Franecki Views, Goyettestead, RI 65038	1-612-972-4537	40.0
232	EMP00000232	Connie	R	Bergstrom	Connie Bergstrom	Connie Bergstrom	Individual Contributor	connie.bergstrom@nestey.co	2019-01-17 00:00:00	9	36	96	active	85566.96	f	0.00	f	0.00	USD	1961-04-12	Full-time	Female	4229 Church Road, Johnsonworth, NH 82420	1-404-572-6084	40.0
233	EMP00000233	Lorene	W	McDermott	Lorene McDermott	Lorene McDermott	Individual Contributor	lorene.mcdermott@nestey.co	2020-11-17 00:00:00	9	36	97	active	66437.51	f	0.20	f	0.00	USD	1978-05-30	Full-time	Female	801 Prospect Place, Yadiraborough, WI 17799	1-973-324-9507	40.0
234	EMP00000234	Dave	U	Leannon	Dave Leannon	Dave Leannon	Individual Contributor	dave.leannon@nestey.co	2022-08-04 00:00:00	9	36	97	active	76090.05	f	0.20	f	0.00	USD	1997-04-08	Full-time	Male	988 Priory Road, Taylor, MT 49354	1-971-310-8429	40.0
235	EMP00000235	Agnes	\N	Anderson	Agnes Anderson	Agnes Anderson	Individual Contributor	agnes.anderson@nestey.co	2019-07-01 00:00:00	9	36	98	active	75533.84	f	0.20	f	0.00	USD	1980-10-30	Full-time	Female	630 Kobe Fields, Gislasonfurt, MT 95423	1-702-713-9852	40.0
236	EMP00000236	Gaetano	P	Cummings	Gaetano Cummings	Gaetano Cummings	Individual Contributor	gaetano.cummings@nestey.co	2020-05-30 00:00:00	9	36	98	active	87524.84	f	0.00	f	0.00	USD	1971-05-10	Full-time	Non-Binary	93061 Clinton Street, Fort Millertown, NH 09888	1-206-391-7485	40.0
237	EMP00000237	Rafael	K	Zemlak	Rafael Zemlak	Rafael Zemlak	Individual Contributor	rafael.zemlak@nestey.co	2024-01-02 00:00:00	9	36	98	active	62831.54	f	0.00	f	0.00	USD	1990-04-20	Full-time	Male	9129 St George's Road, Reston, WI 66719	1-858-319-4750	40.0
238	EMP00000238	Eunice	F	Maggio	Eunice Maggio	Eunice Maggio	Individual Contributor	eunice.maggio@nestey.co	2022-11-25 00:00:00	9	36	98	active	71347.09	f	0.00	f	0.00	USD	1965-11-28	Full-time	Female	68667 Cherry Tree Close, Millshaven, AL 95411	1-503-952-7809	40.0
239	EMP00000239	Eleanor	M	Mueller	Eleanor Mueller	Eleanor Mueller	Individual Contributor	eleanor.mueller@nestey.co	2018-01-21 00:00:00	9	36	99	active	73409.73	f	0.00	f	0.00	USD	1970-11-10	Full-time	Female	40649 Blick Forest, North Sylvesterstad, OK 38153	1-407-934-2196	40.0
240	EMP00000240	Chelsea	N	Denesik	Chelsea Denesik	Chelsea Denesik	Individual Contributor	chelsea.denesik@nestey.co	2020-03-02 00:00:00	9	36	99	active	67720.49	f	0.00	f	0.00	USD	1992-10-02	Full-time	Female	42635 Kessler Crossroad, Garrettland, OR 68800	1-513-720-4381	40.0
241	EMP00000241	Dean	I	Haag	Dean Haag	Dean Haag	Individual Contributor	dean.haag@nestey.co	2023-07-30 00:00:00	9	36	99	active	67113.30	f	0.00	f	0.00	USD	1973-07-05	Full-time	Male	4855 The Sidings, Jaskolskistad, AK 96922	1-917-809-6324	40.0
242	EMP00000242	Myron	U	Rath	Myron Rath	Myron Rath	Individual Contributor	myron.rath@nestey.co	2024-05-02 00:00:00	9	36	99	active	85482.08	f	0.00	f	0.00	USD	1992-10-05	Full-time	Male	401 Jaden View, Fort Cali, CO 52825	1-760-394-8710	40.0
243	EMP00000243	Karen	\N	Altenwerth	Karen Altenwerth	Karen Altenwerth	Individual Contributor	karen.altenwerth@nestey.co	2022-08-11 00:00:00	9	36	99	active	68428.98	f	0.00	f	0.00	USD	1976-08-09	Full-time	Female	45000 Bath Road, Port Karolannville, CT 13073	1-615-823-9543	40.0
244	EMP00000244	Sheryl	C	Anderson	Sheryl Anderson	Sheryl Anderson	Individual Contributor	sheryl.anderson@nestey.co	2018-06-03 00:00:00	9	36	99	active	66268.62	f	0.00	f	0.00	USD	1977-12-23	Full-time	Female	51150 W 3rd Street, Fort Smith, FL 72610	1-727-592-3409	40.0
245	EMP00000245	Ressie	V	King	Ressie King	Ressie King	Individual Contributor	ressie.king@nestey.co	2023-07-30 00:00:00	9	36	99	active	72748.56	f	0.00	f	0.00	USD	1982-12-21	Full-time	Non-Binary	95432 Depot Street, West Kasandra, ND 83611	1-312-864-9571	40.0
246	EMP00000246	Paula	O	Greenfelder	Paula Greenfelder	Paula Greenfelder	Individual Contributor	paula.greenfelder@nestey.co	2023-10-16 00:00:00	9	36	99	active	82932.61	f	0.20	f	0.00	USD	1982-08-31	Full-time	Female	312 Lilian Ville, New Pietro, NC 57702	1-925-793-6842	40.0
247	EMP00000247	Kent	F	Mayer	Kent Mayer	Kent Mayer	Individual Contributor	kent.mayer@nestey.co	2016-12-06 00:00:00	9	36	99	active	70835.22	f	0.20	f	0.00	USD	1981-11-11	Full-time	Male	880 Donnelly Flats, Montgomery, KS 69870	1-978-602-5374	40.0
248	EMP00000248	Velda	G	Lehner	Velda Lehner	Velda Lehner	Individual Contributor	velda.lehner@nestey.co	2024-04-01 00:00:00	8	32	103	active	55181.81	f	0.00	f	0.00	USD	1960-09-28	Full-time	Non-Binary	6504 Oak Road, Lake Mireya, ME 28550	1-404-782-5193	40.0
249	EMP00000249	Herbert	M	Russel	Herbert Russel	Herbert Russel	Individual Contributor	herbert.russel@nestey.co	2024-05-09 00:00:00	8	32	103	active	74057.93	f	0.00	f	0.00	USD	1987-02-22	Full-time	Male	520 S Walnut Street, Carrollton, NY 91310	1-503-892-6741	40.0
250	EMP00000250	Sharon	U	Will	Sharon Will	Sharon Will	Individual Contributor	sharon.will@nestey.co	2020-07-20 00:00:00	8	32	103	active	73432.96	f	0.20	f	0.00	USD	1971-10-14	Full-time	Female	57888 Gusikowski Court, West Gabriellehaven, IA 17162	1-702-539-2864	40.0
251	EMP00000251	Mitchell	K	Flatley	Mitchell Flatley	Mitchell Flatley	Individual Contributor	mitchell.flatley@nestey.co	2016-08-03 00:00:00	8	32	103	active	83777.02	f	0.00	f	0.00	USD	1984-01-10	Full-time	Male	2399 Candice Fields, Greenholtcester, GA 65057	1-323-709-8530	40.0
252	EMP00000252	Geneva	K	Mayert	Geneva Mayert	Geneva Mayert	Individual Contributor	geneva.mayert@nestey.co	2020-01-22 00:00:00	8	32	104	active	66401.06	f	0.00	f	0.00	USD	1995-11-10	Full-time	Female	48362 S College Street, Port Ceasarview, SC 70911	1-617-384-9752	40.0
253	EMP00000253	Linda	Z	Waters	Linda Waters	Linda Waters	Individual Contributor	linda.waters@nestey.co	2020-05-29 00:00:00	8	32	104	active	72348.68	f	0.00	f	0.00	USD	1967-06-30	Full-time	Female	26832 Ciara Highway, Port Brennanhaven, OH 29310	1-925-741-6038	40.0
254	EMP00000254	Mona	G	Kemmer	Mona Kemmer	Mona Kemmer	Individual Contributor	mona.kemmer@nestey.co	2020-06-20 00:00:00	8	32	104	active	55193.74	f	0.20	f	0.00	USD	2000-04-02	Full-time	Female	89470 Jada Corners, Karlhaven, IN 78418	1-305-689-4721	40.0
255	EMP00000255	Isabel	D	Bogisich	Isabel Bogisich	Isabel Bogisich	Individual Contributor	isabel.bogisich@nestey.co	2022-04-22 00:00:00	8	32	105	active	83708.92	f	0.20	f	0.00	USD	1997-11-05	Full-time	Female	6067 Mueller Neck, New Toyside, ND 72376	1-708-934-2517	40.0
256	EMP00000256	Wilbert	L	Abshire	Wilbert Abshire	Wilbert Abshire	Individual Contributor	wilbert.abshire@nestey.co	2019-07-25 00:00:00	8	32	105	active	83226.81	f	0.20	f	0.00	USD	1992-01-29	Full-time	Male	588 Emely Freeway, Jayceview, NV 65817	1-971-608-3945	40.0
257	EMP00000257	Dixie	F	Padberg	Dixie Padberg	Dixie Padberg	Individual Contributor	dixie.padberg@nestey.co	2020-12-15 00:00:00	8	32	105	active	79483.16	f	0.00	f	0.00	USD	1969-03-11	Full-time	Female	66789 W Elm Street, Edina, NM 12073	1-206-874-9103	40.0
258	EMP00000258	Dexter	P	Streich	Dexter Streich	Dexter Streich	Individual Contributor	dexter.streich@nestey.co	2018-11-06 00:00:00	8	32	105	active	70420.23	f	0.00	f	0.00	USD	1972-10-29	Full-time	Non-Binary	779 O'Connell Key, O'Keefeport, IL 82370	1-214-682-4305	40.0
259	EMP00000259	Kristine	X	Goldner	Kristine Goldner	Kristine Goldner	Individual Contributor	kristine.goldner@nestey.co	2018-08-05 00:00:00	8	32	106	active	78942.90	f	0.20	f	0.00	USD	1986-01-12	Full-time	Female	14900 Richmond Road, Douglaston, VA 11630	1-760-912-5780	40.0
260	EMP00000260	Angelina	R	Klocko	Angelina Klocko	Angelina Klocko	Individual Contributor	angelina.klocko@nestey.co	2022-01-14 00:00:00	8	32	106	active	78207.59	f	0.20	f	0.00	USD	1987-12-07	Full-time	Female	860 West View, Karishire, NV 79316	1-646-901-3472	40.0
261	EMP00000261	Jesus	E	Prosacco	Jesus Prosacco	Jesus Prosacco	Individual Contributor	jesus.prosacco@nestey.co	2024-05-19 00:00:00	2	1	68	active	78021.54	t	0.40	f	0.00	USD	1970-08-22	Full-time	Male	7747 Isidro Prairie, Sibylfurt, ND 65757	1-727-684-5703	40.0
262	EMP00000262	Adam	Z	Hermann-Kozey	Adam Hermann-Kozey	Adam Hermann-Kozey	Individual Contributor	adam.hermann-kozey@nestey.co	2023-05-15 00:00:00	2	2	69	active	56021.26	t	0.40	f	0.00	USD	1985-04-28	Full-time	Male	786 Paucek Keys, Pascalechester, AR 07802	1-312-930-8457	40.0
263	EMP00000263	Sandy	Z	D'Amore	Sandy D'Amore	Sandy D'Amore	Individual Contributor	sandy.d'amore@nestey.co	2018-10-18 00:00:00	2	1	69	active	62100.64	t	0.30	f	0.00	USD	1993-10-29	Full-time	Female	445 Maple Street, Alishaworth, NH 74383	1-925-574-9283	40.0
264	EMP00000264	Spencer	F	Torphy	Spencer Torphy	Spencer Torphy	Individual Contributor	spencer.torphy@nestey.co	2024-02-06 00:00:00	2	2	69	active	74464.86	t	0.30	f	0.00	USD	1976-11-09	Full-time	Male	7383 E Park Avenue, Fort Chrisbury, MA 93349	1-978-243-7108	40.0
265	EMP00000265	Johnny	R	Quitzon	Johnny Quitzon	Johnny Quitzon	Individual Contributor	johnny.quitzon@nestey.co	2022-01-01 00:00:00	2	1	69	active	73156.04	f	0.20	f	0.00	USD	1969-10-21	Full-time	Male	850 Jast Freeway, West Prestonton, NY 63454	1-714-280-6954	40.0
266	EMP00000266	Miranda	T	Kub	Miranda Kub	Miranda Kub	Individual Contributor	miranda.kub@nestey.co	2022-01-22 00:00:00	2	2	69	active	80153.31	f	0.00	f	0.00	USD	1976-09-06	Full-time	Female	9845 Dare Walks, West Taya, RI 31973	1-843-960-4287	40.0
267	EMP00000267	Fabiola	W	Mueller	Fabiola Mueller	Fabiola Mueller	Individual Contributor	fabiola.mueller@nestey.co	2024-12-16 00:00:00	2	1	69	active	66708.12	f	0.00	f	0.00	USD	1992-04-16	Full-time	Non-Binary	5079 Clinton Street, North Westleyberg, NY 33012	1-408-739-6085	40.0
268	EMP00000268	Janis	M	Raynor	Janis Raynor	Janis Raynor	Individual Contributor	janis.raynor@nestey.co	2016-08-28 00:00:00	1	7	30	active	73911.30	f	0.20	f	0.00	USD	1994-10-18	Full-time	Female	608 16th Street, Mesa, TN 57372	1-707-982-4136	40.0
269	EMP00000269	Verna	C	Haley-Veum	Verna Haley-Veum	Verna Haley-Veum	Individual Contributor	verna.haley-veum@nestey.co	2019-12-18 00:00:00	1	6	30	active	77356.22	f	0.00	f	0.00	USD	1971-05-17	Full-time	Female	21857 Everette Flats, Lake Ludwigberg, GA 39891	1-323-745-6918	40.0
270	EMP00000270	Myra	F	Pfannerstill	Myra Pfannerstill	Myra Pfannerstill	Individual Contributor	myra.pfannerstill@nestey.co	2023-11-27 00:00:00	1	6	30	active	83688.01	t	0.30	f	0.00	USD	1965-07-09	Full-time	Female	85702 S Main Street, Downers Grove, CA 34859	1-718-362-9071	40.0
271	EMP00000271	Christie	Q	Cremin	Christie Cremin	Christie Cremin	Individual Contributor	christie.cremin@nestey.co	2018-08-16 00:00:00	1	6	30	active	79810.07	f	0.00	f	0.00	USD	1990-03-07	Full-time	Female	4643 Schaden Hill, Beahanburgh, ID 32201	1-202-934-7605	40.0
272	EMP00000272	Angelina	L	Rempel	Angelina Rempel	Angelina Rempel	Individual Contributor	angelina.rempel@nestey.co	2019-04-15 00:00:00	1	7	30	active	61651.38	f	0.00	f	0.00	USD	1970-06-01	Full-time	Female	47667 Rogers Viaduct, Newport News, NV 76785	1-213-739-5820	40.0
273	EMP00000273	Merle	U	Jacobs	Merle Jacobs	Merle Jacobs	Individual Contributor	merle.jacobs@nestey.co	2018-08-17 00:00:00	1	7	30	active	70119.51	f	0.00	f	0.00	USD	1993-03-14	Full-time	Male	55501 Roob Meadow, Venaburgh, HI 51020	1-703-874-6951	40.0
274	EMP00000274	Louise	S	Mosciski	Louise Mosciski	Louise Mosciski	Individual Contributor	louise.mosciski@nestey.co	2023-06-22 00:00:00	1	6	30	active	89944.19	f	0.20	f	0.00	USD	1986-09-12	Full-time	Female	24149 Zboncak Square, Vivianeboro, WV 76235	1-805-394-5783	40.0
275	EMP00000275	Vickie	B	Kulas	Vickie Kulas	Vickie Kulas	Individual Contributor	vickie.kulas@nestey.co	2021-10-10 00:00:00	1	7	30	active	88601.62	f	0.00	f	0.00	USD	1960-06-14	Full-time	Female	123 Ritchie Extensions, Kshlerinburgh, GA 23891	1-970-241-6507	40.0
276	EMP00000276	Elmer	A	Romaguera	Elmer Romaguera	Elmer Romaguera	Individual Contributor	elmer.romaguera@nestey.co	2018-05-21 00:00:00	1	7	30	active	78501.73	t	0.30	f	0.00	USD	1971-01-19	Full-time	Male	970 Howard Street, Billiestad, AZ 18168	1-847-732-5809	40.0
277	EMP00000277	Danielle	E	Collier	Danielle Collier	Danielle Collier	Individual Contributor	danielle.collier@nestey.co	2019-06-15 00:00:00	1	6	30	active	84925.40	t	0.30	f	0.00	USD	1990-07-30	Full-time	Female	2766 Alba Gardens, Lake Sterlington, PA 48429	1-602-783-9142	40.0
278	EMP00000278	Carla	V	Wehner-Kuhlman	Carla Wehner-Kuhlman	Carla Wehner-Kuhlman	Individual Contributor	carla.wehner-kuhlman@nestey.co	2016-08-27 00:00:00	1	6	30	active	81376.64	t	0.40	f	0.00	USD	1969-06-15	Full-time	Female	38672 Alfred Street, New Portercester, MN 38206	1-646-915-7023	40.0
279	EMP00000279	Josephine	T	Langosh	Josephine Langosh	Josephine Langosh	Individual Contributor	josephine.langosh@nestey.co	2017-10-27 00:00:00	1	6	30	active	75343.05	t	0.40	f	0.00	USD	1992-08-30	Full-time	Female	52169 Smitham Grove, West Bridgetmouth, IA 47321	1-504-739-6801	40.0
280	EMP00000280	Morris	M	Ebert	Morris Ebert	Morris Ebert	Individual Contributor	morris.ebert@nestey.co	2024-02-14 00:00:00	1	6	30	active	85643.82	f	0.00	f	0.00	USD	1998-09-07	Full-time	Male	314 Green Street, West Myrtiscester, NH 89457	1-917-273-8049	40.0
281	EMP00000281	Lynne	G	Schaden	Lynne Schaden	Lynne Schaden	Individual Contributor	lynne.schaden@nestey.co	2024-07-11 00:00:00	1	6	29	active	55377.70	t	0.40	f	0.00	USD	1961-06-11	Full-time	Female	36898 Clyde Ranch, Durham, LA 38601	1-512-642-9358	40.0
282	EMP00000282	Patrick	P	Mosciski	Patrick Mosciski	Patrick Mosciski	Individual Contributor	patrick.mosciski@nestey.co	2017-11-21 00:00:00	1	6	29	active	80789.88	t	0.40	f	0.00	USD	1998-12-08	Full-time	Male	126 Darian Ranch, Julietland, WI 64901	1-415-783-2096	40.0
283	EMP00000283	Clifford	E	Kunde	Clifford Kunde	Clifford Kunde	Individual Contributor	clifford.kunde@nestey.co	2018-02-27 00:00:00	1	6	29	active	71637.34	f	0.20	f	0.00	USD	1988-03-20	Full-time	Male	15862 W Jackson Street, Yolandashire, SD 81602	1-305-724-9835	40.0
284	EMP00000284	Beatrice	M	Moen	Beatrice Moen	Beatrice Moen	Individual Contributor	beatrice.moen@nestey.co	2023-08-13 00:00:00	1	6	29	active	66304.08	f	0.20	f	0.00	USD	1983-01-09	Full-time	Female	6006 Fahey Points, New Marilouton, IN 16907	1-763-298-6072	40.0
285	EMP00000285	Doug	R	Hermiston	Doug Hermiston	Doug Hermiston	Individual Contributor	doug.hermiston@nestey.co	2020-07-11 00:00:00	1	7	29	active	65844.82	f	0.00	f	0.00	USD	1969-06-30	Full-time	Male	12366 Luther Streets, Omaha, WI 37164	1-209-874-6903	40.0
286	EMP00000286	Nick	G	Torphy	Nick Torphy	Nick Torphy	Individual Contributor	nick.torphy@nestey.co	2023-07-02 00:00:00	1	7	29	active	80107.62	f	0.00	f	0.00	USD	1995-08-13	Full-time	Male	97439 N Water Street, Rachaelhaven, RI 89710	1-407-621-5748	40.0
287	EMP00000287	Andres	M	King	Andres King	Andres King	Individual Contributor	andres.king@nestey.co	2019-04-03 00:00:00	1	6	29	active	86608.16	f	0.00	f	0.00	USD	1984-11-05	Full-time	Male	6031 Hirthe Crossroad, New Alannaville, MN 49075	1-808-924-8301	40.0
288	EMP00000288	Sandra	P	Fisher	Sandra Fisher	Sandra Fisher	Individual Contributor	sandra.fisher@nestey.co	2020-06-30 00:00:00	1	6	29	active	69832.51	f	0.20	f	0.00	USD	1998-05-06	Full-time	Non-Binary	86747 Myrtice Point, Port Palmatown, AL 92288	1-214-693-9708	40.0
289	EMP00000289	Tabitha	V	Herman	Tabitha Herman	Tabitha Herman	Individual Contributor	tabitha.herman@nestey.co	2022-10-06 00:00:00	1	6	29	active	74225.83	t	0.30	f	0.00	USD	1994-09-18	Full-time	Female	15272 Wren Close, North Elenaland, DE 85069	1-516-874-5209	40.0
290	EMP00000290	Derrick	J	Altenwerth	Derrick Altenwerth	Derrick Altenwerth	Individual Contributor	derrick.altenwerth@nestey.co	2021-08-09 00:00:00	1	7	29	active	85122.41	f	0.20	f	0.00	USD	1979-08-21	Full-time	Male	951 Shaina Ports, DeSoto, CT 76939	1-612-937-8203	40.0
291	EMP00000291	Darlene	B	Corkery	Darlene Corkery	Darlene Corkery	Individual Contributor	darlene.corkery@nestey.co	2024-09-15 00:00:00	1	6	29	active	86852.92	t	0.40	f	0.00	USD	1987-12-05	Full-time	Female	209 Reagan Lane, Veronicashire, NE 61499	1-919-384-2763	40.0
292	EMP00000292	Rita	G	Kub	Rita Kub	Rita Kub	Individual Contributor	rita.kub@nestey.co	2021-11-05 00:00:00	1	6	29	active	68635.69	t	0.50	f	0.00	USD	1965-03-12	Full-time	Female	3226 Joshua Flat, Bogisichchester, HI 88992	1-213-975-8146	40.0
293	EMP00000293	Delia	R	Murphy	Delia Murphy	Delia Murphy	Individual Contributor	delia.murphy@nestey.co	2021-12-26 00:00:00	1	6	29	active	61083.74	t	0.40	f	0.00	USD	1992-05-04	Full-time	Female	7337 Gutmann Trail, Grapevine, HI 36409	1-904-823-5794	40.0
294	EMP00000294	Darla	W	Nitzsche	Darla Nitzsche	Darla Nitzsche	Individual Contributor	darla.nitzsche@nestey.co	2020-07-05 00:00:00	1	6	30	active	57068.26	t	0.30	f	0.00	USD	1962-07-16	Full-time	Female	23458 Church View, Russelstad, NM 59995	1-508-295-6132	40.0
295	EMP00000295	Jody	V	Labadie	Jody Labadie	Jody Labadie	Individual Contributor	jody.labadie@nestey.co	2023-10-24 00:00:00	1	6	30	active	81968.19	t	0.30	f	0.00	USD	1968-07-10	Full-time	Male	9830 Predovic Cape, Spencermouth, AK 49249	1-602-974-5801	40.0
296	EMP00000296	Gertrude	C	Tromp	Gertrude Tromp	Gertrude Tromp	Individual Contributor	gertrude.tromp@nestey.co	2019-12-08 00:00:00	1	7	30	active	76993.66	t	0.30	f	0.00	USD	1991-05-14	Full-time	Female	786 Tracey Corner, Abbigailbury, LA 66812	1-425-890-3429	40.0
297	EMP00000297	Melody	S	Wyman	Melody Wyman	Melody Wyman	Individual Contributor	melody.wyman@nestey.co	2021-06-11 00:00:00	2	1	31	active	55840.76	t	0.30	f	0.00	USD	2000-11-25	Full-time	Female	9137 St Andrews Close, North Timmyborough, MA 46708	1-801-694-3208	40.0
298	EMP00000298	Angel	C	Cassin	Angel Cassin	Angel Cassin	Individual Contributor	angel.cassin@nestey.co	2022-11-09 00:00:00	2	2	31	active	55593.77	t	0.50	f	0.00	USD	1989-04-13	Full-time	Male	862 Castle Street, Wuckertburgh, AK 69652	1-323-964-5087	40.0
299	EMP00000299	Derek	S	Monahan-Rohan	Derek Monahan-Rohan	Derek Monahan-Rohan	Individual Contributor	derek.monahan-rohan@nestey.co	2023-01-19 00:00:00	2	3	32	active	62425.28	t	0.30	f	0.00	USD	1960-05-02	Full-time	Male	801 Garden Close, Federal Way, VT 02397	1-718-540-6921	40.0
300	EMP00000300	Pamela	B	Little	Pamela Little	Pamela Little	Individual Contributor	pamela.little@nestey.co	2018-11-08 00:00:00	2	3	32	active	60980.47	t	0.30	f	0.00	USD	1991-05-14	Full-time	Female	870 Henry Street, Gislasonside, WY 45011	1-214-795-3094	40.0
302	EMP00000302	Eric	Q	Perry	Eric Perry	Eric Perry	Individual Contributor	eric.perry@nestey.co	2023-11-23 00:00:00	7	28	107	active	74980.69	f	0.00	f	0.00	USD	1994-09-30	Full-time	Female	889 Gary Forest Suite 318, Port Christinetown, MD 28153	1-305-879-1142	40.0
303	EMP00000303	Kenneth	S	Ferguson	Kenneth Ferguson	Kenneth Ferguson	Individual Contributor	kenneth.ferguson@nestey.co	2022-05-11 00:00:00	7	28	107	active	86133.22	t	0.00	f	0.00	USD	1984-09-16	Full-time	Female	0815 Daniels Meadow, Williamstown, TX 37096	1-415-327-5639	40.0
304	EMP00000304	Cody	S	Steele	Cody Steele	Cody Steele	Individual Contributor	cody.steele@nestey.co	2024-01-15 00:00:00	7	28	107	active	90954.00	f	0.00	f	0.00	USD	1990-08-08	Full-time	Male	24691 Jennifer Vista, West Katie, MN 91833	1-602-745-3290	40.0
305	EMP00000305	David	J	Dillon	David Dillon	David Dillon	Individual Contributor	david.dillon@nestey.co	2024-12-28 00:00:00	7	28	107	active	90275.14	f	0.20	f	0.00	USD	1986-07-11	Full-time	Female	904 Baldwin Pike, Davidmouth, RI 51349	1-708-934-2075	40.0
306	EMP00000306	Christine	O	Jones	Christine Jones	Christine Jones	Individual Contributor	christine.jones@nestey.co	2023-06-08 00:00:00	7	28	107	active	104790.32	t	0.00	f	0.00	USD	1966-12-16	Full-time	Female	738 Valerie Court, Riceton, ND 28980	1-718-594-6621	40.0
307	EMP00000307	Kaylee	D	Holder	Kaylee Holder	Kaylee Holder	Individual Contributor	kaylee.holder@nestey.co	2022-12-15 00:00:00	7	28	107	active	56995.34	t	0.00	f	0.00	USD	1986-08-17	Full-time	Male	88239 White Alley Apt. 302, North Shaunstad, NY 25974	1-971-820-3198	40.0
308	EMP00000308	Tina	J	Murray	Tina Murray	Tina Murray	Individual Contributor	tina.murray@nestey.co	2025-07-13 00:00:00	7	28	107	active	103409.00	t	0.00	f	0.00	USD	1996-02-22	Full-time	Male	7441 Olivia Throughway, New Elizabeth, SD 63098	1-408-219-4765	40.0
309	EMP00000309	Reginald	E	Warner	Reginald Warner	Reginald Warner	Individual Contributor	reginald.warner@nestey.co	2024-08-18 00:00:00	7	28	107	active	82187.01	t	0.00	f	0.00	USD	1992-04-23	Full-time	Female	08347 Edward Lakes, New Jennifer, MD 94060	1-702-594-1937	40.0
310	EMP00000310	Jeffrey	K	Hendricks	Jeffrey Hendricks	Jeffrey Hendricks	Individual Contributor	jeffrey.hendricks@nestey.co	2023-02-05 00:00:00	7	28	107	active	79721.80	f	0.00	f	0.00	USD	1966-05-03	Full-time	Male	85380 Maria Mills, Kathyburgh, AZ 31121	1-206-372-8564	40.0
311	EMP00000311	Daniel	A	Torres	Daniel Torres	Daniel Torres	Individual Contributor	daniel.torres@nestey.co	2021-07-01 00:00:00	7	28	107	active	78066.61	t	0.00	f	0.00	USD	1975-12-31	Full-time	Female	798 Wyatt Rest Suite 605, South Cassandraburgh, NY 44181	1-617-948-2390	40.0
312	EMP00000312	Nicole	L	Peterson	Nicole Peterson	Nicole Peterson	Individual Contributor	nicole.peterson@nestey.co	2021-10-11 00:00:00	7	28	107	active	98530.96	f	0.00	f	0.00	USD	1978-07-20	Full-time	Male	542 Christopher Fields Apt. 022, Lake Shannon, PA 08351	1-504-617-9402	40.0
313	EMP00000313	Jorge	Z	Carr	Jorge Carr	Jorge Carr	Individual Contributor	jorge.carr@nestey.co	2024-02-01 00:00:00	7	28	107	active	55595.34	f	0.00	f	0.00	USD	1975-05-05	Full-time	Female	9394 Henderson Harbor, Chavezburgh, NE 01866	1-858-723-4058	40.0
314	EMP00000314	Marc	J	Brown	Marc Brown	Marc Brown	Individual Contributor	marc.brown@nestey.co	2021-03-01 00:00:00	7	28	107	active	112218.38	t	0.00	f	0.00	USD	1975-12-26	Full-time	Female	4108 Luke River Suite 607, Jordanberg, HI 24357	1-312-910-5473	40.0
315	EMP00000315	Megan	G	Holland	Megan Holland	Megan Holland	Individual Contributor	megan.holland@nestey.co	2020-12-31 00:00:00	7	28	107	active	111324.87	t	0.00	f	0.00	USD	1996-10-10	Full-time	Male	599 Herrera Villages, Lake Miguelville, ID 44860	1-512-675-9021	40.0
316	EMP00000316	Amber	Z	Davenport	Amber Davenport	Amber Davenport	Individual Contributor	amber.davenport@nestey.co	2024-12-31 00:00:00	7	28	107	active	64864.00	t	0.00	f	0.00	USD	1978-07-30	Full-time	Female	56261 Makayla Estates Suite 751, Delgadoland, RI 88491	1-801-258-7436	40.0
317	EMP00000317	Bryan	F	Foster	Bryan Foster	Bryan Foster	Individual Contributor	bryan.foster@nestey.co	2024-02-12 00:00:00	7	29	107	active	72757.63	f	0.00	f	0.00	USD	1996-01-30	Full-time	Female	729 Mary Courts Apt. 306, South Jonathanside, MD 80272	1-713-482-6915	40.0
318	EMP00000318	Nathaniel	G	Brooks	Nathaniel Brooks	Nathaniel Brooks	Individual Contributor	nathaniel.brooks@nestey.co	2022-09-14 00:00:00	7	29	107	active	103513.40	f	0.00	f	0.00	USD	1979-07-02	Full-time	Female	04839 Martin Mountain, Brittneyhaven, MI 43342	1-323-715-9034	40.0
319	EMP00000319	Joseph	C	Yates	Joseph Yates	Joseph Yates	Individual Contributor	joseph.yates@nestey.co	2024-01-15 00:00:00	7	28	108	active	83969.82	t	0.00	f	0.00	USD	1978-12-03	Full-time	Female	83008 Moore Circles, Bradleymouth, NJ 86785	1-415-932-6721	40.0
320	EMP00000320	Holly	O	Gutierrez	Holly Gutierrez	Holly Gutierrez	Individual Contributor	holly.gutierrez@nestey.co	2023-04-04 00:00:00	7	28	108	active	55121.77	f	0.00	f	0.00	USD	1966-05-10	Full-time	Female	373 Christopher Shore, East Christophermouth, CA 66231	1-646-205-4789	40.0
321	EMP00000321	Nicholas	W	Vasquez	Nicholas Vasquez	Nicholas Vasquez	Individual Contributor	nicholas.vasquez@nestey.co	2022-01-17 00:00:00	7	28	108	active	78463.84	f	0.00	f	0.00	USD	1987-06-08	Full-time	Female	75160 Christopher Creek Suite 680, Fergusonfurt, IN 71730	1-720-483-5107	40.0
322	EMP00000322	Ann	R	Hobbs	Ann Hobbs	Ann Hobbs	Individual Contributor	ann.hobbs@nestey.co	2024-03-25 00:00:00	7	28	108	active	94351.95	t	0.00	f	0.00	USD	1977-01-06	Full-time	Male	173 Maureen Field, Thomasborough, RI 70928	1-513-298-6594	40.0
323	EMP00000323	Peter	E	Marshall	Peter Marshall	Peter Marshall	Individual Contributor	peter.marshall@nestey.co	2024-08-23 00:00:00	7	28	108	active	56590.57	t	0.00	f	0.00	USD	1980-07-20	Full-time	Female	2819 Hawkins Ridge, Lake Julie, IN 99213	1-404-927-3186	40.0
324	EMP00000324	Melissa	V	Woods	Melissa Woods	Melissa Woods	Individual Contributor	melissa.woods@nestey.co	2023-02-14 00:00:00	7	28	108	active	86567.25	f	0.00	f	0.00	USD	1980-12-29	Full-time	Male	52999 Martinez Falls Apt. 051, Leonardberg, ID 13165	1-214-783-4502	40.0
325	EMP00000325	Justin	I	Hamilton	Justin Hamilton	Justin Hamilton	Individual Contributor	justin.hamilton@nestey.co	2025-06-09 00:00:00	7	28	108	active	77980.03	t	0.00	f	0.00	USD	1968-04-27	Full-time	Female	823 Manning Shores Suite 637, New Ray, LA 47925	1-510-396-8245	40.0
326	EMP00000326	Kyle	O	Matthews	Kyle Matthews	Kyle Matthews	Individual Contributor	kyle.matthews@nestey.co	2022-08-29 00:00:00	7	28	108	active	106962.33	t	0.00	f	0.00	USD	1992-10-26	Full-time	Female	89504 Crystal Drive Suite 483, West Davidton, IN 40514	1-702-819-3250	40.0
327	EMP00000327	Jeanne	H	Crawford	Jeanne Crawford	Jeanne Crawford	Individual Contributor	jeanne.crawford@nestey.co	2021-11-16 00:00:00	7	29	108	active	95031.12	t	0.00	f	0.00	USD	1993-09-22	Full-time	Male	640 Jason Courts Suite 635, East Ryan, KS 37222	1-818-623-9501	40.0
328	EMP00000328	Penny	Q	Cisneros	Penny Cisneros	Penny Cisneros	Individual Contributor	penny.cisneros@nestey.co	2021-02-27 00:00:00	7	28	109	active	102382.62	t	0.00	f	0.00	USD	1994-03-17	Full-time	Male	051 Gutierrez Haven Apt. 874, Sandrabury, OR 94953	1-305-764-2389	40.0
329	EMP00000329	Nancy	S	Smith	Nancy Smith	Nancy Smith	Individual Contributor	nancy.smith@nestey.co	2021-06-12 00:00:00	7	28	109	active	97110.63	f	0.00	f	0.00	USD	1988-04-06	Full-time	Female	351 Allison Place Suite 149, Harperport, MD 75859	1-312-284-9760	40.0
330	EMP00000330	Roger	Y	Lopez	Roger Lopez	Roger Lopez	Individual Contributor	roger.lopez@nestey.co	2025-01-09 00:00:00	7	28	109	active	80214.11	f	0.00	f	0.00	USD	1973-08-22	Full-time	Male	60095 Julie Knoll, Alishaborough, IL 10435	1-512-607-4981	40.0
331	EMP00000331	Scott	H	Jackson	Scott Jackson	Scott Jackson	Individual Contributor	scott.jackson@nestey.co	2023-01-02 00:00:00	7	28	109	active	67386.47	f	0.00	f	0.00	USD	1972-11-15	Full-time	Female	15042 Katherine Gateway, Allenton, VT 90287	1-626-341-8052	40.0
332	EMP00000332	Rhonda	V	Hardin	Rhonda Hardin	Rhonda Hardin	Individual Contributor	rhonda.hardin@nestey.co	2022-01-24 00:00:00	7	28	109	active	106811.17	f	0.00	f	0.00	USD	1994-10-28	Full-time	Female	PSC 8164, Box 1161, APO AA 49450	1-323-598-4307	40.0
333	EMP00000333	Alejandro	A	Gibson	Alejandro Gibson	Alejandro Gibson	Individual Contributor	alejandro.gibson@nestey.co	2023-08-21 00:00:00	7	28	109	active	109188.42	f	0.00	f	0.00	USD	1979-11-04	Full-time	Male	2051 Gray Orchard, New Mary, VT 87263	1-617-412-9850	40.0
334	EMP00000334	Julie	Y	Ross	Julie Ross	Julie Ross	Individual Contributor	julie.ross@nestey.co	2024-12-04 00:00:00	7	28	109	active	73740.22	t	0.00	f	0.00	USD	2002-05-25	Full-time	Male	638 Ricardo Shores Apt. 593, Aaronshire, AZ 97719	1-704-238-9673	40.0
335	EMP00000335	Emily	U	Watson	Emily Watson	Emily Watson	Individual Contributor	emily.watson@nestey.co	2025-04-02 00:00:00	7	28	109	active	65945.58	t	0.00	f	0.00	USD	1986-11-01	Full-time	Male	49427 Kline Center, Griffinhaven, IN 16065	1-919-804-5269	40.0
336	EMP00000336	Steven	D	Martinez	Steven Martinez	Steven Martinez	Individual Contributor	steven.martinez@nestey.co	2023-12-02 00:00:00	7	28	109	active	92060.79	t	0.00	f	0.00	USD	1967-10-07	Full-time	Male	USS Nielsen, FPO AE 90697	1-614-219-4385	40.0
337	EMP00000337	Tonya	F	Young	Tonya Young	Tonya Young	Individual Contributor	tonya.young@nestey.co	2022-08-19 00:00:00	7	29	109	active	63032.96	t	0.00	f	0.00	USD	1986-05-17	Full-time	Female	15640 Monica Terrace Suite 283, Wrightton, OK 23870	1-858-760-3942	40.0
338	EMP00000338	Matthew	Q	Kim	Matthew Kim	Matthew Kim	Individual Contributor	matthew.kim@nestey.co	2025-01-20 00:00:00	7	28	110	active	56991.93	f	0.00	f	0.00	USD	1983-01-12	Full-time	Male	500 Alexander Square, North Edwin, RI 34723	1-718-926-5038	40.0
339	EMP00000339	Tracy	J	Pham	Tracy Pham	Tracy Pham	Individual Contributor	tracy.pham@nestey.co	2023-11-14 00:00:00	7	28	110	active	90684.79	f	0.00	f	0.00	USD	1992-04-05	Full-time	Male	958 Boyle Ranch, West Roberttown, AZ 31006	1-202-749-3175	40.0
340	EMP00000340	Regina	R	Rodriguez	Regina Rodriguez	Regina Rodriguez	Individual Contributor	regina.rodriguez@nestey.co	2022-02-01 00:00:00	7	28	110	active	93651.22	t	0.00	f	0.00	USD	1977-07-19	Full-time	Female	49575 Carol Loaf Suite 269, Philipview, FL 70214	1-213-640-5782	40.0
341	EMP00000341	Richard	R	Ortega	Richard Ortega	Richard Ortega	Individual Contributor	richard.ortega@nestey.co	2023-09-18 00:00:00	7	28	110	active	68423.98	f	0.20	f	0.00	USD	1966-05-24	Full-time	Female	4268 Heather Island Suite 374, Madisonfort, OH 30484	1-808-329-1746	40.0
343	EMP00000343	Darryl	N	Baker	Darryl Baker	Darryl Baker	Individual Contributor	darryl.baker@nestey.co	2024-02-16 00:00:00	7	28	111	active	82520.11	t	0.00	f	0.00	USD	1982-05-21	Full-time	Female	9758 Solis Square, Kimberlytown, NC 56834	1-973-598-6270	40.0
344	EMP00000344	Chase	X	Reed	Chase Reed	Chase Reed	Individual Contributor	chase.reed@nestey.co	2021-08-24 00:00:00	7	28	111	active	79126.31	t	0.20	f	0.00	USD	1998-01-09	Full-time	Female	USS Cameron, FPO AE 59861	1-602-519-4826	40.0
345	EMP00000345	Erin	M	Martin	Erin Martin	Erin Martin	Individual Contributor	erin.martin@nestey.co	2024-06-16 00:00:00	7	28	111	active	119750.76	t	0.00	f	0.00	USD	1973-03-08	Full-time	Female	431 Nichols Route, Lake Miguelfort, PA 16379	1-512-731-9405	40.0
346	EMP00000346	Maureen	B	Lawson	Maureen Lawson	Maureen Lawson	Individual Contributor	maureen.lawson@nestey.co	2024-03-05 00:00:00	7	28	111	active	67298.50	t	0.00	f	0.00	USD	1975-05-20	Full-time	Male	USS Yang, FPO AA 16483	1-206-835-4923	40.0
347	EMP00000347	Barbara	U	Davidson	Barbara Davidson	Barbara Davidson	Individual Contributor	barbara.davidson@nestey.co	2022-03-02 00:00:00	7	28	111	active	58904.73	f	0.20	f	0.00	USD	1971-03-12	Full-time	Female	0603 Taylor Brooks Apt. 413, East Rachelfort, AK 31870	1-702-298-3741	40.0
348	EMP00000348	Mallory	T	Moss	Mallory Moss	Mallory Moss	Individual Contributor	mallory.moss@nestey.co	2025-01-07 00:00:00	7	28	112	active	98000.98	f	0.20	f	0.00	USD	1973-04-03	Full-time	Female	4775 Dylan Drive Apt. 369, Lake Eric, AL 42362	1-714-675-8209	40.0
349	EMP00000349	Krystal	H	Edwards	Krystal Edwards	Krystal Edwards	Individual Contributor	krystal.edwards@nestey.co	2023-04-02 00:00:00	7	28	112	active	111781.86	f	0.20	f	0.00	USD	1987-08-26	Full-time	Female	57218 Morris Port Suite 776, Lake William, MS 23094	1-813-509-2436	40.0
350	EMP00000350	Bianca	Y	Miranda	Bianca Miranda	Bianca Miranda	Individual Contributor	bianca.miranda@nestey.co	2022-02-17 00:00:00	7	28	112	active	62187.50	f	0.20	f	0.00	USD	1977-11-18	Full-time	Female	Unit 3509 Box 9718, DPO AA 26963	1-404-692-5730	40.0
351	EMP00000351	Michael	H	Parker	Michael Parker	Michael Parker	Individual Contributor	michael.parker@nestey.co	2021-04-12 00:00:00	6	24	113	active	82643.67	t	0.00	f	0.00	USD	1973-01-21	Full-time	Female	2716 Ashley Divide Apt. 254, Sextonfort, LA 99399	1-503-928-1045	40.0
352	EMP00000352	Stephanie	B	Small	Stephanie Small	Stephanie Small	Individual Contributor	stephanie.small@nestey.co	2022-06-25 00:00:00	6	24	113	active	74006.86	f	0.00	f	0.00	USD	1970-12-14	Full-time	Female	20384 Sarah Grove Suite 279, New Brandiview, AR 48548	1-312-872-4093	40.0
353	EMP00000353	Dawn	B	Simpson	Dawn Simpson	Dawn Simpson	Individual Contributor	dawn.simpson@nestey.co	2022-08-20 00:00:00	6	24	113	active	118042.89	f	0.00	f	0.00	USD	1982-06-08	Full-time	Female	55984 Sherri Roads, New Maryville, MI 98925	1-213-714-5308	40.0
354	EMP00000354	Kevin	Z	Estrada	Kevin Estrada	Kevin Estrada	Individual Contributor	kevin.estrada@nestey.co	2024-03-27 00:00:00	6	25	113	active	71031.98	t	0.20	f	0.00	USD	2002-05-21	Full-time	Female	42847 Fox Village Suite 112, Lake Heather, IA 00968	1-801-349-6709	40.0
355	EMP00000355	Andre	H	Floyd	Andre Floyd	Andre Floyd	Individual Contributor	andre.floyd@nestey.co	2023-04-27 00:00:00	6	24	114	active	71945.69	t	0.00	f	0.00	USD	1985-02-02	Full-time	Male	18438 Anderson Well, Lake Jamesside, DC 47552	1-617-435-7821	40.0
356	EMP00000356	Aaron	A	Long	Aaron Long	Aaron Long	Individual Contributor	aaron.long@nestey.co	2023-02-06 00:00:00	7	24	114	active	72535.05	f	0.00	f	0.00	USD	1984-11-05	Full-time	Male	52909 Copeland Via Suite 448, North Patrick, ME 82805	1-323-695-4170	40.0
357	EMP00000357	Beverly	R	Goodwin	Beverly Goodwin	Beverly Goodwin	Individual Contributor	beverly.goodwin@nestey.co	2021-03-14 00:00:00	7	24	114	active	80854.05	t	0.00	f	0.00	USD	1974-08-11	Full-time	Female	83638 Benjamin Meadow, Leonardmouth, NV 78368	1-720-398-2641	40.0
358	EMP00000358	Christina	S	Delgado	Christina Delgado	Christina Delgado	Individual Contributor	christina.delgado@nestey.co	2024-11-12 00:00:00	7	24	114	active	61404.42	f	0.00	f	0.00	USD	1977-02-04	Full-time	Male	635 Traci Roads, Dudleystad, MN 13977	1-503-741-9086	40.0
359	EMP00000359	Randy	F	Carter	Randy Carter	Randy Carter	Individual Contributor	randy.carter@nestey.co	2023-03-07 00:00:00	7	24	114	active	113132.62	f	0.00	f	0.00	USD	1999-10-27	Full-time	Female	016 Jeffrey Parks Suite 204, Jonathanville, OK 18130	1-415-690-5238	40.0
360	EMP00000360	Frank	Y	Ramos	Frank Ramos	Frank Ramos	Individual Contributor	frank.ramos@nestey.co	2025-02-22 00:00:00	7	24	115	active	85045.10	t	0.00	f	0.00	USD	2001-08-13	Full-time	Female	88696 Kathryn Radial, Port Sheila, ME 31079	1-408-562-9701	40.0
361	EMP00000361	Ivan	L	Kelley	Ivan Kelley	Ivan Kelley	Individual Contributor	ivan.kelley@nestey.co	2022-05-24 00:00:00	7	24	115	active	104962.91	t	0.00	f	0.00	USD	1971-01-26	Full-time	Female	218 Carlos Manors Suite 321, Sarahside, WV 99724	1-305-281-6075	40.0
362	EMP00000362	Brian	Z	Griffin	Brian Griffin	Brian Griffin	Individual Contributor	brian.griffin@nestey.co	2023-04-12 00:00:00	7	24	115	active	70484.69	f	0.00	f	0.00	USD	1977-09-25	Full-time	Female	3648 Lisa Ways Suite 167, Basshaven, PA 44770	1-512-734-6924	40.0
363	EMP00000363	Madeline	Q	Villarreal	Madeline Villarreal	Madeline Villarreal	Individual Contributor	madeline.villarreal@nestey.co	2020-11-05 00:00:00	7	25	115	active	74832.15	t	0.00	f	0.00	USD	1978-02-14	Full-time	Male	271 Williams Flat Suite 562, West Erin, TX 30056	1-404-952-3078	40.0
364	EMP00000364	Mary	G	Acevedo	Mary Acevedo	Mary Acevedo	Individual Contributor	mary.acevedo@nestey.co	2025-10-14 00:00:00	7	25	116	active	107510.16	t	0.00	f	0.00	USD	1980-09-19	Full-time	Female	4183 Howell Rapid, Lynchtown, NJ 58213	1-713-245-8073	40.0
365	EMP00000365	Valerie	B	Mcdowell	Valerie Mcdowell	Valerie Mcdowell	Individual Contributor	valerie.mcdowell@nestey.co	2022-09-14 00:00:00	7	25	116	active	107271.65	f	0.00	f	0.00	USD	1984-03-17	Full-time	Male	648 Pineda Ports, Aliceville, MA 11657	1-971-649-5048	40.0
366	EMP00000366	Latoya	A	Lee	Latoya Lee	Latoya Lee	Individual Contributor	latoya.lee@nestey.co	2024-03-28 00:00:00	7	25	116	active	62377.90	t	0.00	f	0.00	USD	1972-05-19	Full-time	Female	50842 Davis Divide Suite 560, South Charleschester, KS 69851	1-206-573-9140	40.0
367	EMP00000367	Geoffrey	L	Arnold	Geoffrey Arnold	Geoffrey Arnold	Individual Contributor	geoffrey.arnold@nestey.co	2024-01-02 00:00:00	7	25	116	active	94023.29	f	0.00	f	0.00	USD	1991-04-28	Full-time	Female	4237 Donald Green Suite 660, Codymouth, MN 74227	1-617-708-2591	40.0
368	EMP00000368	Felicia	G	Castillo	Felicia Castillo	Felicia Castillo	Individual Contributor	felicia.castillo@nestey.co	2020-10-25 00:00:00	7	28	108	active	108112.62	f	0.00	f	0.00	USD	1978-06-18	Full-time	Male	PSC 1316, Box 8049, APO AP 95741	1-312-893-4715	40.0
369	EMP00000369	Gail	L	Payne	Gail Payne	Gail Payne	Individual Contributor	gail.payne@nestey.co	2024-07-03 00:00:00	7	28	108	active	67815.35	t	0.00	f	0.00	USD	1997-01-19	Full-time	Female	184 Burke Mission Suite 600, Port Stephen, OR 55775	1-408-271-6402	40.0
370	EMP00000370	Shawn	U	Gonzalez	Shawn Gonzalez	Shawn Gonzalez	Individual Contributor	shawn.gonzalez@nestey.co	2022-01-15 00:00:00	7	28	108	active	114776.65	f	0.00	f	0.00	USD	1998-05-09	Full-time	Female	91150 Martin Street Suite 045, Barnesville, AZ 56879	1-702-491-8079	40.0
371	EMP00000371	Brett	X	Anthony	Brett Anthony	Brett Anthony	Individual Contributor	brett.anthony@nestey.co	2021-02-21 00:00:00	7	28	108	active	61721.96	t	0.20	f	0.00	USD	1968-04-30	Full-time	Male	3321 Dunn Place, Washingtonton, FL 79048	1-213-527-9314	40.0
372	EMP00000372	Anna	M	Salazar	Anna Salazar	Anna Salazar	Individual Contributor	anna.salazar@nestey.co	2020-11-23 00:00:00	7	28	108	active	109835.15	f	0.00	f	0.00	USD	1988-03-15	Full-time	Female	425 Eric Ramp Apt. 893, West Michael, OH 43956	1-646-801-2490	40.0
373	EMP00000373	Joshua	L	West	Joshua West	Joshua West	Individual Contributor	joshua.west@nestey.co	2021-08-06 00:00:00	7	28	108	active	57454.65	f	0.20	f	0.00	USD	2003-10-01	Full-time	Male	3272 Caitlin Rapid, Port Sheilaport, DC 93363	1-503-729-3824	40.0
374	EMP00000374	Lauren	R	Rowe	Lauren Rowe	Lauren Rowe	Individual Contributor	lauren.rowe@nestey.co	2024-12-23 00:00:00	7	28	108	active	103093.88	t	0.00	f	0.00	USD	1968-03-12	Full-time	Female	69908 Cynthia Via, South Jennifermouth, IA 76561	1-512-603-7850	40.0
375	EMP00000375	Caleb	G	Evans	Caleb Evans	Caleb Evans	Individual Contributor	caleb.evans@nestey.co	2020-12-30 00:00:00	7	28	108	active	99324.56	f	0.00	f	0.00	USD	1983-06-17	Full-time	Female	5212 Mack Coves Apt. 045, Howardburgh, RI 20504	1-415-820-3649	40.0
376	EMP00000376	Amy	M	Meyers	Amy Meyers	Amy Meyers	Individual Contributor	amy.meyers@nestey.co	2021-04-22 00:00:00	7	29	108	active	110240.95	t	0.00	f	0.00	USD	1993-10-18	Full-time	Male	USS Carroll, FPO AP 09281	1-713-548-9201	40.0
377	EMP00000377	Charles	E	Keith	Charles Keith	Charles Keith	Individual Contributor	charles.keith@nestey.co	2025-04-24 00:00:00	7	28	109	active	64744.13	f	0.00	f	0.00	USD	1994-08-28	Full-time	Male	779 Miller Square, Kelleychester, MN 08902	1-404-739-2603	40.0
378	EMP00000378	Samantha	R	Becker	Samantha Becker	Samantha Becker	Individual Contributor	samantha.becker@nestey.co	2024-04-08 00:00:00	7	28	109	active	62722.66	t	0.00	f	0.00	USD	1980-05-30	Full-time	Female	384 Denise Fall, New Ryan, ID 73922	1-305-683-5174	40.0
379	EMP00000379	Desiree	H	Coleman	Desiree Coleman	Desiree Coleman	Individual Contributor	desiree.coleman@nestey.co	2025-04-26 00:00:00	7	28	109	active	111830.69	t	0.00	f	0.00	USD	1996-04-17	Full-time	Male	631 Mark Flat Suite 727, Garzastad, IL 44721	1-626-281-9432	40.0
380	EMP00000380	Carol	J	Hodges	Carol Hodges	Carol Hodges	Individual Contributor	carol.hodges@nestey.co	2021-01-09 00:00:00	7	28	109	active	62616.48	t	0.00	f	0.00	USD	1979-02-04	Full-time	Female	696 Andrew Highway, Singhstad, IL 43315	1-213-789-4206	40.0
381	EMP00000381	Susan	I	Dawson	Susan Dawson	Susan Dawson	Individual Contributor	susan.dawson@nestey.co	2024-01-08 00:00:00	7	28	109	active	101904.33	f	0.00	f	0.00	USD	2001-03-14	Full-time	Male	USS Roberts, FPO AP 89683	1-718-692-5198	40.0
382	EMP00000382	Evan	S	Perez	Evan Perez	Evan Perez	Individual Contributor	evan.perez@nestey.co	2023-12-03 00:00:00	7	28	109	active	109380.89	t	0.00	f	0.00	USD	1994-07-07	Full-time	Female	379 Alyssa Parks Apt. 264, South Brianside, NC 84112	1-206-548-9730	40.0
383	EMP00000383	Mark	G	Glenn	Mark Glenn	Mark Glenn	Individual Contributor	mark.glenn@nestey.co	2023-10-03 00:00:00	7	28	109	active	109656.03	t	0.00	f	0.00	USD	1989-08-12	Full-time	Female	0486 Garcia Flats Apt. 026, North David, LA 19964	1-512-781-4027	40.0
384	EMP00000384	Peggy	Q	Duncan	Peggy Duncan	Peggy Duncan	Individual Contributor	peggy.duncan@nestey.co	2024-05-29 00:00:00	7	28	109	active	82899.39	f	0.00	f	0.00	USD	1989-05-14	Full-time	Female	70474 Patricia Loaf, Port Vanessa, KY 45049	1-323-925-6078	40.0
385	EMP00000385	Michelle	I	Maldonado	Michelle Maldonado	Michelle Maldonado	Individual Contributor	michelle.maldonado@nestey.co	2021-06-30 00:00:00	7	29	109	active	112817.90	t	0.00	f	0.00	USD	1975-12-02	Full-time	Male	1355 Kristine Landing, Bethmouth, OR 73663	1-213-562-4908	40.0
\.


--
-- Data for Name: functions; Type: TABLE DATA; Schema: public; Owner: neill
--

COPY public.functions (function_id, function_name) FROM stdin;
1	Technology
2	Product
3	Commercial
4	Customer Success
5	People & Culture
6	Finance
7	Legal & Compliance
8	Executive Leadership
\.


--
-- Data for Name: interviews; Type: TABLE DATA; Schema: public; Owner: neill
--

COPY public.interviews (interview_id, application_id, interviewer_id, interview_date, interview_type, feedback, rating, decision, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: job_families; Type: TABLE DATA; Schema: public; Owner: neill
--

COPY public.job_families (job_family_id, job_family_name, description) FROM stdin;
1	Product Management	Product strategy, roadmap definition, and lifecycle ownership
2	Product Development	Software development and execution of product vision
3	Technology	IT operations, infrastructure, and security
4	Research & Development	Innovation, experimentation, and new product design
5	Sales	Revenue generation through new business and renewals
6	Marketing	Brand, communications, and demand generation
7	Customer Service	Customer support and service excellence
8	Human Resources	Employee lifecycle, recruiting, and development
9	Finance	Accounting, FP&A, audit, and procurement
10	Legal & Compliance	Corporate legal affairs and risk management
11	Executive Leadership	Corporate governance and enterprise oversight
\.


--
-- Data for Name: job_offers; Type: TABLE DATA; Schema: public; Owner: neill
--

COPY public.job_offers (offer_id, application_id, offered_role_id, offered_salary, offered_bonus, start_date, offer_status, sent_date, accepted_date, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: job_postings; Type: TABLE DATA; Schema: public; Owner: neill
--

COPY public.job_postings (job_posting_id, title, department_id, role_id, hiring_manager_id, location, employment_type, description, requirements, salary_range_min, salary_range_max, currency, status, date_posted, date_closed, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: rating_scale; Type: TABLE DATA; Schema: public; Owner: neill
--

COPY public.rating_scale (rating_value, rating_label, description) FROM stdin;
1	Does Not Meet Expectations	Performance does not meet role requirements
2	Partially Meets Expectations	Some goals achieved but not consistently
3	Meets Expectations	Consistently meets performance standards
4	Exceeds Expectations	Frequently exceeds performance standards
5	Outstanding	Consistently exceeds expectations and sets new standards
\.


--
-- Data for Name: review_cycles; Type: TABLE DATA; Schema: public; Owner: neill
--

COPY public.review_cycles (review_cycle_id, name, cycle_type, period_start, period_end, midyear_start, midyear_end, status, is_active) FROM stdin;
1	FY2025 Annual	Annual	2025-01-01	2025-12-31	\N	\N	Open	t
\.


--
-- Data for Name: role_levels; Type: TABLE DATA; Schema: public; Owner: neill
--

COPY public.role_levels (role_level_code, role_level_name, hierarchy_rank, description) FROM stdin;
IC1	Entry / Individual Contributor	1	Learns and applies skills under supervision; focuses on developing core competencies.
IC2	Experienced Individual Contributor	2	Independently performs complex tasks; contributes expertise and mentors peers.
IC3	Senior Individual Contributor	3	Recognized expert; influences across teams and leads key projects.
M1	Manager	4	Leads a small team; manages deliverables and provides feedback and coaching.
M2	Senior Manager / Director	5	Oversees multiple teams or functions; drives strategic execution.
E1	Executive / C-Level	6	Defines organizational strategy and vision; leads enterprise-wide initiatives.
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: neill
--

COPY public.roles (role_id, role_name, parent_role_id, job_family_id, description, date_created, date_updated, department_id, role_level_code, role_level_id) FROM stdin;
1	Associate Product Manager	\N	1	Supports product research and feature development	2025-10-30	2025-10-30	2	IC1	1
2	Product Manager	\N	1	Owns product roadmap and delivery priorities	2025-10-30	2025-10-30	2	IC2	2
3	Senior Product Manager	\N	1	Leads cross-functional product strategy	2025-10-30	2025-10-30	2	IC3	3
4	Director of Product Management	\N	1	Oversees product portfolio and roadmap	2025-10-30	2025-10-30	2	M2	4
5	VP of Product	\N	1	Owns overall product vision and direction	2025-10-30	2025-10-30	2	E1	5
6	Software Engineer	\N	2	Builds and maintains software features	2025-10-30	2025-10-30	1	IC1	6
7	Senior Software Engineer	\N	2	Leads complex system design and architecture	2025-10-30	2025-10-30	1	IC2	7
8	Engineering Manager	\N	2	Leads development teams and technical delivery	2025-10-30	2025-10-30	1	M1	8
9	Director of Product Development	\N	2	Oversees product build and release processes	2025-10-30	2025-10-30	1	M2	9
10	VP of Product Development	\N	2	Leads engineering and delivery for all products	2025-10-30	2025-10-30	1	E1	10
11	IT Support Specialist	\N	3	Provides user and systems support	2025-10-30	2025-10-30	3	IC1	11
12	Systems Administrator	\N	3	Manages infrastructure and enterprise systems	2025-10-30	2025-10-30	3	IC2	12
13	IT Manager	\N	3	Oversees IT operations and service management	2025-10-30	2025-10-30	3	M1	13
14	Director of IT	\N	3	Leads enterprise technology operations	2025-10-30	2025-10-30	3	M2	14
15	CTO	\N	3	Defines technology vision and architecture	2025-10-30	2025-10-30	3	E1	15
16	R&D Engineer	\N	4	Designs and prototypes new technologies	2025-10-30	2025-10-30	4	IC1	16
17	Research Scientist	\N	4	Conducts technical and market research	2025-10-30	2025-10-30	4	IC2	17
18	R&D Manager	\N	4	Leads research and innovation teams	2025-10-30	2025-10-30	4	M1	18
19	Director of R&D	\N	4	Oversees research initiatives and partnerships	2025-10-30	2025-10-30	4	M2	19
20	Sales Representative	\N	5	Manages outreach and prospecting	2025-10-30	2025-10-30	5	IC1	20
21	Account Executive	\N	5	Closes deals and manages customer pipeline	2025-10-30	2025-10-30	5	IC2	21
22	Sales Manager	\N	5	Leads sales teams and regional goals	2025-10-30	2025-10-30	5	M1	22
23	VP of Sales	\N	5	Owns revenue and growth strategy	2025-10-30	2025-10-30	5	E1	23
24	Marketing Coordinator	\N	6	Supports campaigns and content creation	2025-10-30	2025-10-30	6	IC1	24
25	Marketing Manager	\N	6	Oversees programs and campaign execution	2025-10-30	2025-10-30	6	M1	25
26	Director of Marketing	\N	6	Leads marketing strategy and performance	2025-10-30	2025-10-30	6	M2	26
27	Chief Marketing Officer	\N	6	Owns brand and go-to-market strategy	2025-10-30	2025-10-30	6	E1	27
28	Customer Support Specialist	\N	7	Resolves customer issues and inquiries	2025-10-30	2025-10-30	7	IC1	28
29	Customer Service Team Lead	\N	7	Oversees service team workflow	2025-10-30	2025-10-30	7	IC2	29
30	Customer Service Manager	\N	7	Manages service KPIs and escalation processes	2025-10-30	2025-10-30	7	M1	30
31	Director of Customer Service	\N	7	Leads overall service operations	2025-10-30	2025-10-30	7	M2	31
32	HR Coordinator	\N	8	Supports HR operations	2025-10-30	2025-10-30	8	IC1	32
33	HR Business Partner	\N	8	Advises business units on people strategy	2025-10-30	2025-10-30	8	IC2	33
34	Director of HR	\N	8	Oversees HR programs and compliance	2025-10-30	2025-10-30	8	M2	34
35	Chief People Officer	\N	8	Leads company culture and people strategy	2025-10-30	2025-10-30	8	E1	35
36	Financial Analyst	\N	9	Prepares reports and forecasts	2025-10-30	2025-10-30	9	IC1	36
37	Accounting Manager	\N	9	Manages accounting processes	2025-10-30	2025-10-30	9	M1	37
38	Director of FP&A	\N	9	Oversees planning and financial modeling	2025-10-30	2025-10-30	9	M2	38
39	Chief Financial Officer	\N	9	Leads financial and investment strategy	2025-10-30	2025-10-30	9	E1	39
40	Legal Counsel	\N	10	Manages contracts and legal issues	2025-10-30	2025-10-30	10	IC2	40
41	Director of Compliance	\N	10	Oversees compliance and policy programs	2025-10-30	2025-10-30	10	M2	41
42	General Counsel	\N	10	Leads legal and governance strategy	2025-10-30	2025-10-30	10	E1	42
43	Chief of Staff	\N	11	Coordinates executive priorities	2025-10-30	2025-10-30	11	M2	43
44	VP, Strategy & Transformation	\N	11	Drives enterprise strategy and change	2025-10-30	2025-10-30	11	E1	44
45	CEO	\N	11	Leads overall company performance and vision	2025-10-30	2025-10-30	11	E1	45
\.


--
-- Data for Name: strategies; Type: TABLE DATA; Schema: public; Owner: neill
--

COPY public.strategies (strategy_id, strategy_name, description) FROM stdin;
1	Customer	Improve customer satisfaction and experience
2	People	Engage and develop employees
3	Shareholder	Grow revenue and enhance profitability
\.


--
-- Data for Name: time_off_accruals; Type: TABLE DATA; Schema: public; Owner: neill
--

COPY public.time_off_accruals (accrual_id, employee_id, type, year, accrued_days, used_days, remaining_days, last_updated) FROM stdin;
335	2	Sick Leave	2025	5.0	4.0	1.0	2025-11-04
2	10	PTO	2025	11.6	0.0	11.6	2025-11-02
4	2	PTO	2025	17.0	15.0	2.0	2025-11-05
3	301	PTO	2025	14.6	0.0	14.6	2025-11-02
5	3	PTO	2025	16.4	0.0	16.4	2025-11-02
6	4	PTO	2025	17.0	0.0	17.0	2025-11-02
7	5	PTO	2025	15.8	0.0	15.8	2025-11-02
8	6	PTO	2025	12.4	0.0	12.4	2025-11-02
9	7	PTO	2025	14.6	0.0	14.6	2025-11-02
10	8	PTO	2025	10.8	0.0	10.8	2025-11-02
11	9	PTO	2025	17.0	0.0	17.0	2025-11-02
12	13	PTO	2025	15.2	0.0	15.2	2025-11-02
13	14	PTO	2025	14.0	0.0	14.0	2025-11-02
14	15	PTO	2025	16.4	0.0	16.4	2025-11-02
15	16	PTO	2025	17.0	0.0	17.0	2025-11-02
16	17	PTO	2025	17.0	0.0	17.0	2025-11-02
17	18	PTO	2025	15.2	0.0	15.2	2025-11-02
18	26	PTO	2025	12.4	0.0	12.4	2025-11-02
19	27	PTO	2025	17.0	0.0	17.0	2025-11-02
20	28	PTO	2025	16.4	0.0	16.4	2025-11-02
21	29	PTO	2025	14.6	0.0	14.6	2025-11-02
22	30	PTO	2025	15.8	0.0	15.8	2025-11-02
23	31	PTO	2025	15.8	0.0	15.8	2025-11-02
24	32	PTO	2025	16.4	0.0	16.4	2025-11-02
25	33	PTO	2025	14.6	0.0	14.6	2025-11-02
26	34	PTO	2025	15.8	0.0	15.8	2025-11-02
27	39	PTO	2025	11.6	0.0	11.6	2025-11-02
28	40	PTO	2025	12.4	0.0	12.4	2025-11-02
29	41	PTO	2025	16.4	0.0	16.4	2025-11-02
30	42	PTO	2025	16.4	0.0	16.4	2025-11-02
31	43	PTO	2025	17.0	0.0	17.0	2025-11-02
32	44	PTO	2025	15.2	0.0	15.2	2025-11-02
33	45	PTO	2025	16.4	0.0	16.4	2025-11-02
34	46	PTO	2025	17.0	0.0	17.0	2025-11-02
35	47	PTO	2025	11.6	0.0	11.6	2025-11-02
36	48	PTO	2025	17.0	0.0	17.0	2025-11-02
37	49	PTO	2025	12.4	0.0	12.4	2025-11-02
38	50	PTO	2025	14.0	0.0	14.0	2025-11-02
39	51	PTO	2025	14.0	0.0	14.0	2025-11-02
40	52	PTO	2025	12.4	0.0	12.4	2025-11-02
41	53	PTO	2025	12.4	0.0	12.4	2025-11-02
42	66	PTO	2025	17.0	0.0	17.0	2025-11-02
43	67	PTO	2025	12.4	0.0	12.4	2025-11-02
44	68	PTO	2025	16.4	0.0	16.4	2025-11-02
45	69	PTO	2025	14.6	0.0	14.6	2025-11-02
46	70	PTO	2025	14.6	0.0	14.6	2025-11-02
47	71	PTO	2025	10.8	0.0	10.8	2025-11-02
48	72	PTO	2025	15.8	0.0	15.8	2025-11-02
49	73	PTO	2025	14.6	0.0	14.6	2025-11-02
50	74	PTO	2025	14.0	0.0	14.0	2025-11-02
51	75	PTO	2025	10.8	0.0	10.8	2025-11-02
52	76	PTO	2025	11.6	0.0	11.6	2025-11-02
53	77	PTO	2025	17.0	0.0	17.0	2025-11-02
54	78	PTO	2025	10.8	0.0	10.8	2025-11-02
55	79	PTO	2025	11.6	0.0	11.6	2025-11-02
56	80	PTO	2025	11.6	0.0	11.6	2025-11-02
57	81	PTO	2025	17.0	0.0	17.0	2025-11-02
58	82	PTO	2025	17.0	0.0	17.0	2025-11-02
59	83	PTO	2025	15.8	0.0	15.8	2025-11-02
60	84	PTO	2025	11.6	0.0	11.6	2025-11-02
61	85	PTO	2025	12.4	0.0	12.4	2025-11-02
62	86	PTO	2025	17.0	0.0	17.0	2025-11-02
63	87	PTO	2025	11.6	0.0	11.6	2025-11-02
64	88	PTO	2025	14.6	0.0	14.6	2025-11-02
65	89	PTO	2025	15.8	0.0	15.8	2025-11-02
66	90	PTO	2025	11.6	0.0	11.6	2025-11-02
67	91	PTO	2025	16.4	0.0	16.4	2025-11-02
68	92	PTO	2025	14.0	0.0	14.0	2025-11-02
69	93	PTO	2025	16.4	0.0	16.4	2025-11-02
70	94	PTO	2025	15.2	0.0	15.2	2025-11-02
71	95	PTO	2025	14.0	0.0	14.0	2025-11-02
72	96	PTO	2025	16.4	0.0	16.4	2025-11-02
73	97	PTO	2025	15.8	0.0	15.8	2025-11-02
74	98	PTO	2025	15.8	0.0	15.8	2025-11-02
75	99	PTO	2025	14.6	0.0	14.6	2025-11-02
76	103	PTO	2025	16.4	0.0	16.4	2025-11-02
77	104	PTO	2025	17.0	0.0	17.0	2025-11-02
78	105	PTO	2025	11.6	0.0	11.6	2025-11-02
79	106	PTO	2025	11.6	0.0	11.6	2025-11-02
80	107	PTO	2025	14.6	0.0	14.6	2025-11-02
81	108	PTO	2025	16.4	0.0	16.4	2025-11-02
82	109	PTO	2025	14.6	0.0	14.6	2025-11-02
83	110	PTO	2025	16.4	0.0	16.4	2025-11-02
84	111	PTO	2025	14.6	0.0	14.6	2025-11-02
85	112	PTO	2025	17.0	0.0	17.0	2025-11-02
86	113	PTO	2025	16.4	0.0	16.4	2025-11-02
87	114	PTO	2025	17.0	0.0	17.0	2025-11-02
88	115	PTO	2025	10.8	0.0	10.8	2025-11-02
89	116	PTO	2025	12.4	0.0	12.4	2025-11-02
90	126	PTO	2025	12.4	0.0	12.4	2025-11-02
91	127	PTO	2025	14.6	0.0	14.6	2025-11-02
92	128	PTO	2025	14.0	0.0	14.0	2025-11-02
93	129	PTO	2025	15.8	0.0	15.8	2025-11-02
94	130	PTO	2025	15.8	0.0	15.8	2025-11-02
95	131	PTO	2025	15.2	0.0	15.2	2025-11-02
96	132	PTO	2025	11.6	0.0	11.6	2025-11-02
97	133	PTO	2025	14.0	0.0	14.0	2025-11-02
98	134	PTO	2025	15.8	0.0	15.8	2025-11-02
99	135	PTO	2025	16.4	0.0	16.4	2025-11-02
100	136	PTO	2025	10.8	0.0	10.8	2025-11-02
101	137	PTO	2025	11.6	0.0	11.6	2025-11-02
102	138	PTO	2025	11.6	0.0	11.6	2025-11-02
103	139	PTO	2025	17.0	0.0	17.0	2025-11-02
104	152	PTO	2025	15.8	0.0	15.8	2025-11-02
105	153	PTO	2025	14.6	0.0	14.6	2025-11-02
106	154	PTO	2025	15.2	0.0	15.2	2025-11-02
107	155	PTO	2025	17.0	0.0	17.0	2025-11-02
108	156	PTO	2025	11.6	0.0	11.6	2025-11-02
109	157	PTO	2025	12.4	0.0	12.4	2025-11-02
110	158	PTO	2025	12.4	0.0	12.4	2025-11-02
111	159	PTO	2025	11.6	0.0	11.6	2025-11-02
112	160	PTO	2025	14.6	0.0	14.6	2025-11-02
113	161	PTO	2025	10.8	0.0	10.8	2025-11-02
114	162	PTO	2025	15.2	0.0	15.2	2025-11-02
115	163	PTO	2025	10.8	0.0	10.8	2025-11-02
116	164	PTO	2025	14.0	0.0	14.0	2025-11-02
117	165	PTO	2025	12.4	0.0	12.4	2025-11-02
118	166	PTO	2025	17.0	0.0	17.0	2025-11-02
119	167	PTO	2025	15.2	0.0	15.2	2025-11-02
120	168	PTO	2025	14.6	0.0	14.6	2025-11-02
121	169	PTO	2025	12.4	0.0	12.4	2025-11-02
122	170	PTO	2025	10.8	0.0	10.8	2025-11-02
123	171	PTO	2025	14.0	0.0	14.0	2025-11-02
124	172	PTO	2025	15.8	0.0	15.8	2025-11-02
125	173	PTO	2025	11.6	0.0	11.6	2025-11-02
126	174	PTO	2025	14.0	0.0	14.0	2025-11-02
127	175	PTO	2025	14.0	0.0	14.0	2025-11-02
128	176	PTO	2025	17.0	0.0	17.0	2025-11-02
129	177	PTO	2025	15.2	0.0	15.2	2025-11-02
130	178	PTO	2025	15.2	0.0	15.2	2025-11-02
131	179	PTO	2025	17.0	0.0	17.0	2025-11-02
132	180	PTO	2025	14.0	0.0	14.0	2025-11-02
133	181	PTO	2025	10.8	0.0	10.8	2025-11-02
134	182	PTO	2025	12.4	0.0	12.4	2025-11-02
135	183	PTO	2025	15.8	0.0	15.8	2025-11-02
136	184	PTO	2025	17.0	0.0	17.0	2025-11-02
137	185	PTO	2025	17.0	0.0	17.0	2025-11-02
138	186	PTO	2025	15.2	0.0	15.2	2025-11-02
139	187	PTO	2025	10.8	0.0	10.8	2025-11-02
140	188	PTO	2025	14.0	0.0	14.0	2025-11-02
141	193	PTO	2025	15.8	0.0	15.8	2025-11-02
142	194	PTO	2025	14.6	0.0	14.6	2025-11-02
143	195	PTO	2025	16.4	0.0	16.4	2025-11-02
144	196	PTO	2025	15.2	0.0	15.2	2025-11-02
145	197	PTO	2025	17.0	0.0	17.0	2025-11-02
146	198	PTO	2025	17.0	0.0	17.0	2025-11-02
147	199	PTO	2025	14.6	0.0	14.6	2025-11-02
148	200	PTO	2025	14.0	0.0	14.0	2025-11-02
149	201	PTO	2025	14.6	0.0	14.6	2025-11-02
150	202	PTO	2025	14.0	0.0	14.0	2025-11-02
151	203	PTO	2025	10.8	0.0	10.8	2025-11-02
152	204	PTO	2025	15.8	0.0	15.8	2025-11-02
153	205	PTO	2025	10.8	0.0	10.8	2025-11-02
154	206	PTO	2025	14.0	0.0	14.0	2025-11-02
155	207	PTO	2025	14.6	0.0	14.6	2025-11-02
156	208	PTO	2025	14.6	0.0	14.6	2025-11-02
157	209	PTO	2025	16.4	0.0	16.4	2025-11-02
158	210	PTO	2025	11.6	0.0	11.6	2025-11-02
159	211	PTO	2025	11.6	0.0	11.6	2025-11-02
160	212	PTO	2025	16.4	0.0	16.4	2025-11-02
161	213	PTO	2025	14.0	0.0	14.0	2025-11-02
162	214	PTO	2025	12.4	0.0	12.4	2025-11-02
163	215	PTO	2025	12.4	0.0	12.4	2025-11-02
164	216	PTO	2025	17.0	0.0	17.0	2025-11-02
165	217	PTO	2025	15.2	0.0	15.2	2025-11-02
166	218	PTO	2025	11.6	0.0	11.6	2025-11-02
167	219	PTO	2025	14.6	0.0	14.6	2025-11-02
168	220	PTO	2025	16.4	0.0	16.4	2025-11-02
169	221	PTO	2025	15.2	0.0	15.2	2025-11-02
170	222	PTO	2025	15.8	0.0	15.8	2025-11-02
171	223	PTO	2025	12.4	0.0	12.4	2025-11-02
172	224	PTO	2025	15.2	0.0	15.2	2025-11-02
173	225	PTO	2025	10.8	0.0	10.8	2025-11-02
174	226	PTO	2025	14.0	0.0	14.0	2025-11-02
175	227	PTO	2025	14.0	0.0	14.0	2025-11-02
176	228	PTO	2025	15.8	0.0	15.8	2025-11-02
177	229	PTO	2025	14.0	0.0	14.0	2025-11-02
178	230	PTO	2025	10.8	0.0	10.8	2025-11-02
179	231	PTO	2025	15.2	0.0	15.2	2025-11-02
180	232	PTO	2025	15.2	0.0	15.2	2025-11-02
181	233	PTO	2025	14.6	0.0	14.6	2025-11-02
182	234	PTO	2025	12.4	0.0	12.4	2025-11-02
183	235	PTO	2025	15.2	0.0	15.2	2025-11-02
184	236	PTO	2025	14.6	0.0	14.6	2025-11-02
185	237	PTO	2025	10.8	0.0	10.8	2025-11-02
186	238	PTO	2025	12.4	0.0	12.4	2025-11-02
187	239	PTO	2025	15.8	0.0	15.8	2025-11-02
188	240	PTO	2025	14.6	0.0	14.6	2025-11-02
189	241	PTO	2025	11.6	0.0	11.6	2025-11-02
190	242	PTO	2025	10.8	0.0	10.8	2025-11-02
191	243	PTO	2025	12.4	0.0	12.4	2025-11-02
192	244	PTO	2025	15.8	0.0	15.8	2025-11-02
193	245	PTO	2025	11.6	0.0	11.6	2025-11-02
194	246	PTO	2025	11.6	0.0	11.6	2025-11-02
195	247	PTO	2025	17.0	0.0	17.0	2025-11-02
196	248	PTO	2025	10.8	0.0	10.8	2025-11-02
197	249	PTO	2025	10.8	0.0	10.8	2025-11-02
198	250	PTO	2025	14.6	0.0	14.6	2025-11-02
199	251	PTO	2025	17.0	0.0	17.0	2025-11-02
200	252	PTO	2025	14.6	0.0	14.6	2025-11-02
201	253	PTO	2025	14.6	0.0	14.6	2025-11-02
202	254	PTO	2025	14.6	0.0	14.6	2025-11-02
203	255	PTO	2025	12.4	0.0	12.4	2025-11-02
204	256	PTO	2025	15.2	0.0	15.2	2025-11-02
205	257	PTO	2025	14.6	0.0	14.6	2025-11-02
206	258	PTO	2025	15.8	0.0	15.8	2025-11-02
207	259	PTO	2025	15.8	0.0	15.8	2025-11-02
208	260	PTO	2025	12.4	0.0	12.4	2025-11-02
209	261	PTO	2025	10.8	0.0	10.8	2025-11-02
210	262	PTO	2025	11.6	0.0	11.6	2025-11-02
211	263	PTO	2025	15.8	0.0	15.8	2025-11-02
212	264	PTO	2025	10.8	0.0	10.8	2025-11-02
213	265	PTO	2025	12.4	0.0	12.4	2025-11-02
214	266	PTO	2025	12.4	0.0	12.4	2025-11-02
215	267	PTO	2025	10.8	0.0	10.8	2025-11-02
216	268	PTO	2025	17.0	0.0	17.0	2025-11-02
217	269	PTO	2025	15.2	0.0	15.2	2025-11-02
218	270	PTO	2025	11.6	0.0	11.6	2025-11-02
219	271	PTO	2025	15.8	0.0	15.8	2025-11-02
220	272	PTO	2025	15.2	0.0	15.2	2025-11-02
221	273	PTO	2025	15.8	0.0	15.8	2025-11-02
222	274	PTO	2025	11.6	0.0	11.6	2025-11-02
223	275	PTO	2025	14.0	0.0	14.0	2025-11-02
224	276	PTO	2025	15.8	0.0	15.8	2025-11-02
225	277	PTO	2025	15.2	0.0	15.2	2025-11-02
226	278	PTO	2025	17.0	0.0	17.0	2025-11-02
227	279	PTO	2025	16.4	0.0	16.4	2025-11-02
228	280	PTO	2025	10.8	0.0	10.8	2025-11-02
229	281	PTO	2025	10.8	0.0	10.8	2025-11-02
230	282	PTO	2025	16.4	0.0	16.4	2025-11-02
231	283	PTO	2025	15.8	0.0	15.8	2025-11-02
232	284	PTO	2025	11.6	0.0	11.6	2025-11-02
233	285	PTO	2025	14.6	0.0	14.6	2025-11-02
234	286	PTO	2025	11.6	0.0	11.6	2025-11-02
235	287	PTO	2025	15.2	0.0	15.2	2025-11-02
236	288	PTO	2025	14.6	0.0	14.6	2025-11-02
237	289	PTO	2025	12.4	0.0	12.4	2025-11-02
238	290	PTO	2025	14.0	0.0	14.0	2025-11-02
239	291	PTO	2025	10.8	0.0	10.8	2025-11-02
240	292	PTO	2025	14.0	0.0	14.0	2025-11-02
241	293	PTO	2025	14.0	0.0	14.0	2025-11-02
242	294	PTO	2025	14.6	0.0	14.6	2025-11-02
243	295	PTO	2025	11.6	0.0	11.6	2025-11-02
244	296	PTO	2025	15.2	0.0	15.2	2025-11-02
245	297	PTO	2025	14.0	0.0	14.0	2025-11-02
246	298	PTO	2025	12.4	0.0	12.4	2025-11-02
247	299	PTO	2025	11.6	0.0	11.6	2025-11-02
248	300	PTO	2025	15.8	0.0	15.8	2025-11-02
249	302	PTO	2025	11.6	0.0	11.6	2025-11-02
250	303	PTO	2025	12.4	0.0	12.4	2025-11-02
251	304	PTO	2025	10.8	0.0	10.8	2025-11-02
252	305	PTO	2025	10.8	0.0	10.8	2025-11-02
253	306	PTO	2025	11.6	0.0	11.6	2025-11-02
254	307	PTO	2025	12.4	0.0	12.4	2025-11-02
255	308	PTO	2025	10.0	0.0	10.0	2025-11-02
256	309	PTO	2025	10.8	0.0	10.8	2025-11-02
257	310	PTO	2025	11.6	0.0	11.6	2025-11-02
258	311	PTO	2025	14.0	0.0	14.0	2025-11-02
259	312	PTO	2025	14.0	0.0	14.0	2025-11-02
260	313	PTO	2025	10.8	0.0	10.8	2025-11-02
261	314	PTO	2025	14.0	0.0	14.0	2025-11-02
262	315	PTO	2025	14.6	0.0	14.6	2025-11-02
263	316	PTO	2025	10.8	0.0	10.8	2025-11-02
264	317	PTO	2025	10.8	0.0	10.8	2025-11-02
265	318	PTO	2025	12.4	0.0	12.4	2025-11-02
266	319	PTO	2025	10.8	0.0	10.8	2025-11-02
267	320	PTO	2025	11.6	0.0	11.6	2025-11-02
268	321	PTO	2025	12.4	0.0	12.4	2025-11-02
269	322	PTO	2025	10.8	0.0	10.8	2025-11-02
270	323	PTO	2025	10.8	0.0	10.8	2025-11-02
271	324	PTO	2025	11.6	0.0	11.6	2025-11-02
272	325	PTO	2025	10.0	0.0	10.0	2025-11-02
273	326	PTO	2025	12.4	0.0	12.4	2025-11-02
274	327	PTO	2025	14.0	0.0	14.0	2025-11-02
275	328	PTO	2025	14.0	0.0	14.0	2025-11-02
276	329	PTO	2025	14.0	0.0	14.0	2025-11-02
277	330	PTO	2025	10.0	0.0	10.0	2025-11-02
278	331	PTO	2025	11.6	0.0	11.6	2025-11-02
279	332	PTO	2025	12.4	0.0	12.4	2025-11-02
280	333	PTO	2025	11.6	0.0	11.6	2025-11-02
281	334	PTO	2025	10.8	0.0	10.8	2025-11-02
282	335	PTO	2025	10.0	0.0	10.0	2025-11-02
283	336	PTO	2025	11.6	0.0	11.6	2025-11-02
284	337	PTO	2025	12.4	0.0	12.4	2025-11-02
285	338	PTO	2025	10.0	0.0	10.0	2025-11-02
286	339	PTO	2025	11.6	0.0	11.6	2025-11-02
287	340	PTO	2025	12.4	0.0	12.4	2025-11-02
288	341	PTO	2025	11.6	0.0	11.6	2025-11-02
289	343	PTO	2025	10.8	0.0	10.8	2025-11-02
290	344	PTO	2025	14.0	0.0	14.0	2025-11-02
291	345	PTO	2025	10.8	0.0	10.8	2025-11-02
292	346	PTO	2025	10.8	0.0	10.8	2025-11-02
293	347	PTO	2025	12.4	0.0	12.4	2025-11-02
294	348	PTO	2025	10.0	0.0	10.0	2025-11-02
295	349	PTO	2025	11.6	0.0	11.6	2025-11-02
296	350	PTO	2025	12.4	0.0	12.4	2025-11-02
297	351	PTO	2025	14.0	0.0	14.0	2025-11-02
298	352	PTO	2025	12.4	0.0	12.4	2025-11-02
299	353	PTO	2025	12.4	0.0	12.4	2025-11-02
300	354	PTO	2025	10.8	0.0	10.8	2025-11-02
301	355	PTO	2025	11.6	0.0	11.6	2025-11-02
302	356	PTO	2025	11.6	0.0	11.6	2025-11-02
303	357	PTO	2025	14.0	0.0	14.0	2025-11-02
304	358	PTO	2025	10.8	0.0	10.8	2025-11-02
305	359	PTO	2025	11.6	0.0	11.6	2025-11-02
306	360	PTO	2025	10.0	0.0	10.0	2025-11-02
307	361	PTO	2025	12.4	0.0	12.4	2025-11-02
308	362	PTO	2025	11.6	0.0	11.6	2025-11-02
309	363	PTO	2025	14.6	0.0	14.6	2025-11-02
310	364	PTO	2025	10.0	0.0	10.0	2025-11-02
311	365	PTO	2025	12.4	0.0	12.4	2025-11-02
312	366	PTO	2025	10.8	0.0	10.8	2025-11-02
313	367	PTO	2025	10.8	0.0	10.8	2025-11-02
314	368	PTO	2025	14.6	0.0	14.6	2025-11-02
315	369	PTO	2025	10.8	0.0	10.8	2025-11-02
316	370	PTO	2025	12.4	0.0	12.4	2025-11-02
317	371	PTO	2025	14.0	0.0	14.0	2025-11-02
318	372	PTO	2025	14.6	0.0	14.6	2025-11-02
319	373	PTO	2025	14.0	0.0	14.0	2025-11-02
320	374	PTO	2025	10.8	0.0	10.8	2025-11-02
321	375	PTO	2025	14.6	0.0	14.6	2025-11-02
322	376	PTO	2025	14.0	0.0	14.0	2025-11-02
323	377	PTO	2025	10.0	0.0	10.0	2025-11-02
324	378	PTO	2025	10.8	0.0	10.8	2025-11-02
325	379	PTO	2025	10.0	0.0	10.0	2025-11-02
326	380	PTO	2025	14.0	0.0	14.0	2025-11-02
327	381	PTO	2025	10.8	0.0	10.8	2025-11-02
328	382	PTO	2025	11.6	0.0	11.6	2025-11-02
329	383	PTO	2025	11.6	0.0	11.6	2025-11-02
330	384	PTO	2025	10.8	0.0	10.8	2025-11-02
331	385	PTO	2025	14.0	0.0	14.0	2025-11-02
332	1	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
333	10	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
334	301	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
336	3	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
337	4	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
338	5	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
339	6	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
340	7	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
341	8	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
342	9	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
343	13	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
344	14	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
345	15	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
346	16	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
347	17	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
348	18	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
349	26	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
350	27	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
351	28	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
352	29	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
353	30	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
354	31	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
355	32	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
356	33	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
357	34	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
358	39	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
359	40	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
360	41	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
361	42	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
362	43	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
363	44	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
364	45	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
365	46	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
366	47	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
367	48	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
368	49	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
369	50	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
370	51	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
371	52	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
372	53	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
373	66	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
374	67	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
375	68	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
376	69	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
377	70	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
378	71	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
379	72	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
380	73	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
381	74	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
382	75	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
383	76	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
384	77	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
385	78	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
386	79	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
387	80	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
388	81	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
389	82	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
390	83	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
391	84	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
392	85	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
393	86	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
394	87	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
395	88	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
396	89	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
397	90	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
398	91	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
399	92	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
400	93	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
401	94	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
402	95	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
403	96	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
404	97	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
405	98	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
406	99	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
407	103	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
408	104	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
409	105	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
410	106	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
411	107	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
412	108	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
413	109	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
414	110	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
415	111	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
416	112	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
417	113	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
418	114	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
419	115	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
420	116	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
421	126	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
422	127	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
423	128	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
424	129	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
425	130	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
426	131	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
427	132	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
428	133	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
429	134	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
430	135	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
431	136	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
432	137	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
433	138	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
434	139	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
435	152	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
436	153	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
437	154	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
438	155	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
439	156	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
440	157	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
441	158	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
442	159	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
443	160	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
444	161	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
445	162	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
446	163	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
447	164	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
448	165	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
449	166	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
450	167	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
451	168	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
452	169	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
453	170	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
454	171	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
455	172	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
456	173	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
457	174	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
458	175	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
459	176	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
460	177	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
461	178	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
462	179	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
463	180	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
464	181	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
465	182	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
466	183	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
467	184	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
468	185	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
469	186	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
470	187	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
471	188	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
472	193	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
473	194	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
474	195	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
475	196	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
476	197	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
477	198	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
478	199	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
479	200	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
480	201	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
481	202	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
482	203	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
483	204	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
484	205	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
485	206	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
486	207	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
487	208	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
488	209	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
489	210	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
490	211	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
491	212	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
492	213	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
493	214	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
494	215	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
495	216	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
496	217	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
497	218	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
498	219	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
499	220	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
500	221	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
501	222	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
502	223	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
503	224	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
504	225	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
505	226	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
506	227	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
507	228	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
508	229	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
509	230	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
510	231	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
511	232	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
512	233	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
513	234	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
514	235	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
515	236	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
516	237	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
517	238	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
518	239	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
519	240	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
520	241	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
521	242	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
522	243	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
523	244	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
524	245	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
525	246	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
526	247	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
527	248	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
528	249	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
529	250	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
530	251	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
531	252	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
532	253	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
533	254	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
534	255	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
535	256	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
536	257	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
537	258	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
538	259	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
539	260	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
540	261	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
541	262	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
542	263	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
543	264	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
544	265	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
545	266	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
546	267	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
547	268	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
548	269	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
549	270	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
550	271	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
551	272	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
552	273	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
553	274	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
554	275	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
555	276	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
556	277	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
557	278	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
558	279	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
559	280	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
560	281	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
561	282	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
562	283	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
563	284	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
564	285	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
565	286	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
566	287	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
567	288	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
568	289	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
569	290	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
570	291	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
571	292	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
572	293	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
573	294	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
574	295	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
575	296	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
576	297	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
577	298	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
578	299	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
579	300	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
580	302	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
581	303	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
582	304	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
583	305	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
584	306	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
585	307	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
586	308	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
587	309	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
588	310	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
589	311	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
590	312	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
591	313	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
592	314	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
593	315	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
594	316	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
595	317	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
596	318	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
597	319	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
598	320	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
599	321	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
600	322	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
601	323	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
602	324	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
603	325	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
604	326	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
605	327	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
606	328	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
607	329	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
608	330	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
609	331	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
610	332	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
611	333	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
612	334	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
613	335	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
614	336	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
615	337	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
616	338	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
617	339	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
618	340	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
619	341	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
620	343	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
621	344	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
622	345	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
623	346	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
624	347	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
625	348	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
626	349	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
627	350	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
628	351	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
629	352	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
630	353	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
631	354	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
632	355	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
633	356	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
634	357	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
635	358	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
636	359	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
637	360	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
638	361	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
639	362	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
640	363	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
641	364	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
642	365	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
643	366	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
644	367	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
645	368	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
646	369	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
647	370	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
648	371	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
649	372	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
650	373	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
651	374	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
652	375	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
653	376	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
654	377	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
655	378	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
656	379	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
657	380	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
658	381	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
659	382	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
660	383	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
661	384	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
662	385	Sick Leave	2025	5.0	0.0	5.0	2025-11-02
1	1	PTO	2025	18.5	5.0	13.5	2025-11-02
\.


--
-- Data for Name: time_off_backup; Type: TABLE DATA; Schema: public; Owner: neill
--

COPY public.time_off_backup (time_off_id, employee_id, start_date, end_date, type, time_off_amount, time_off_accrued, time_off_balance, date_created, date_updated) FROM stdin;
342	9	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
343	13	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
344	14	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
345	15	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
346	16	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
347	17	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
348	18	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
349	26	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
350	27	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
351	28	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
352	29	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
353	30	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
354	31	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
355	32	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
356	33	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
357	34	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
358	39	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
359	40	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
360	41	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
361	42	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
362	43	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
363	44	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
364	45	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
365	46	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
366	47	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
367	48	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
368	49	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
369	50	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
370	51	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
371	52	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
372	53	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
373	66	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
374	67	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
375	68	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
376	69	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
377	70	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
378	71	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
379	72	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
380	73	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
381	74	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
382	75	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
383	76	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
384	77	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
385	78	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
386	79	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
387	80	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
388	81	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
389	82	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
390	83	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
391	84	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
392	85	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
393	86	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
394	87	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
395	88	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
396	89	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
397	90	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
398	91	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
399	92	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
400	93	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
401	94	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
402	95	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
403	96	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
404	97	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
405	98	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
406	99	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
407	103	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
408	104	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
409	105	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
410	106	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
411	107	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
412	108	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
413	109	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
414	110	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
415	111	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
416	112	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
417	113	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
418	114	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
419	115	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
420	116	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
421	126	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
422	127	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
423	128	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
424	129	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
425	130	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
426	131	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
427	132	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
428	133	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
429	134	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
430	135	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
431	136	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
432	137	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
433	138	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
434	139	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
435	152	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
436	153	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
437	154	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
438	155	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
439	156	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
440	157	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
441	158	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
442	159	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
443	160	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
444	161	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
445	162	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
446	163	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
447	164	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
448	165	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
449	166	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
450	167	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
451	168	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
452	169	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
453	170	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
454	171	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
455	172	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
456	173	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
457	174	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
458	175	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
459	176	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
460	177	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
461	178	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
462	179	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
463	180	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
464	181	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
465	182	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
466	183	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
467	184	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
468	185	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
469	186	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
470	187	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
471	188	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
472	193	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
473	194	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
474	195	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
475	196	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
476	197	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
477	198	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
478	199	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
479	200	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
480	201	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
481	202	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
482	203	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
483	204	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
484	205	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
485	206	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
486	207	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
487	208	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
488	209	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
489	210	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
490	211	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
491	212	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
492	213	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
493	214	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
494	215	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
495	216	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
496	217	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
497	218	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
498	219	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
499	220	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
500	221	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
501	222	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
502	223	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
503	224	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
504	225	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
505	226	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
506	227	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
507	228	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
508	229	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
509	230	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
510	231	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
511	232	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
512	233	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
513	234	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
514	235	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
515	236	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
516	237	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
517	238	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
518	239	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
519	240	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
520	241	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
521	242	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
522	243	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
523	244	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
524	245	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
525	246	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
526	247	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
527	248	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
528	249	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
529	250	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
530	251	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
531	252	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
532	253	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
533	254	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
534	255	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
535	256	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
536	257	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
537	258	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
538	259	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
539	260	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
540	261	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
541	262	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
542	263	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
543	264	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
544	265	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
545	266	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
546	267	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
547	268	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
548	269	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
549	270	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
550	271	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
551	272	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
552	273	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
553	274	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
554	275	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
555	276	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
556	277	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
557	278	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
558	279	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
559	280	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
560	281	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
561	282	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
562	283	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
563	284	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
564	285	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
565	286	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
566	287	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
567	288	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
568	289	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
569	290	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
570	291	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
571	292	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
572	293	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
573	294	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
574	295	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
575	296	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
576	297	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
577	298	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
578	299	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
579	300	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
580	302	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
581	303	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
582	304	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
583	305	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
584	306	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
585	307	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
586	308	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
587	309	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
588	310	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
589	311	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
590	312	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
591	313	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
592	314	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
593	315	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
594	316	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
595	317	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
596	318	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
597	319	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
598	320	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
599	321	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
600	322	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
601	323	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
602	324	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
603	325	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
604	326	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
605	327	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
606	328	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
607	329	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
608	330	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
609	331	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
610	332	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
611	333	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
612	334	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
613	335	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
332	1	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
333	10	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
334	301	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
335	2	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
336	3	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
337	4	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
338	5	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
339	6	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
340	7	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
341	8	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
664	2	2025-10-10	2025-10-21	PTO	30.0	30.0	25.7	2025-11-02	2025-11-02
614	336	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
615	337	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
616	338	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
617	339	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
618	340	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
619	341	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
620	343	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
621	344	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
622	345	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
623	346	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
624	347	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
625	348	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
626	349	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
627	350	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
628	351	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
629	352	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
630	353	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
631	354	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
632	355	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
633	356	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
634	357	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
635	358	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
636	359	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
637	360	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
638	361	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
639	362	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
640	363	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
641	364	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
642	365	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
643	366	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
644	367	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
645	368	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
646	369	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
647	370	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
648	371	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
649	372	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
650	373	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
651	374	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
652	375	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
653	376	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
654	377	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
655	378	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
656	379	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
657	380	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
658	381	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
659	382	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
660	383	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
661	384	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
662	385	2025-01-01	2025-12-31	Sick Leave	0.0	5.0	5.0	2025-11-02	2025-11-02
2	10	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
3	301	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
4	2	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
5	3	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
6	4	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
7	5	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
8	6	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
9	7	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
10	8	2025-01-01	2025-12-31	PTO	0.0	10.0	10.0	2025-11-02	2025-11-02
11	9	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
12	13	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
13	14	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
14	15	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
15	16	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
16	17	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
17	18	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
18	26	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
19	27	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
20	28	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
21	29	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
22	30	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
23	31	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
24	32	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
25	33	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
26	34	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
27	39	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
28	40	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
29	41	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
30	42	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
31	43	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
32	44	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
33	45	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
34	46	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
35	47	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
36	48	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
37	49	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
38	50	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
39	51	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
40	52	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
41	53	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
42	66	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
43	67	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
44	68	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
45	69	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
46	70	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
47	71	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
48	72	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
49	73	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
50	74	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
51	75	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
52	76	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
53	77	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
54	78	2025-01-01	2025-12-31	PTO	0.0	10.0	10.0	2025-11-02	2025-11-02
55	79	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
56	80	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
57	81	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
58	82	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
59	83	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
60	84	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
61	85	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
62	86	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
63	87	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
64	88	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
65	89	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
66	90	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
67	91	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
68	92	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
69	93	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
70	94	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
71	95	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
72	96	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
73	97	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
74	98	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
75	99	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
76	103	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
77	104	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
78	105	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
79	106	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
80	107	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
81	108	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
82	109	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
83	110	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
84	111	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
85	112	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
86	113	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
87	114	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
88	115	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
89	116	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
90	126	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
91	127	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
92	128	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
93	129	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
94	130	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
95	131	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
96	132	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
97	133	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
98	134	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
99	135	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
100	136	2025-01-01	2025-12-31	PTO	0.0	10.0	10.0	2025-11-02	2025-11-02
101	137	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
102	138	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
103	139	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
104	152	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
105	153	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
106	154	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
107	155	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
108	156	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
109	157	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
110	158	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
111	159	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
112	160	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
113	161	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
114	162	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
115	163	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
116	164	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
117	165	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
118	166	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
119	167	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
120	168	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
121	169	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
122	170	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
123	171	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
124	172	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
125	173	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
126	174	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
127	175	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
128	176	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
129	177	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
130	178	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
131	179	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
132	180	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
133	181	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
134	182	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
135	183	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
136	184	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
137	185	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
138	186	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
139	187	2025-01-01	2025-12-31	PTO	0.0	10.0	10.0	2025-11-02	2025-11-02
140	188	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
141	193	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
142	194	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
143	195	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
144	196	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
145	197	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
146	198	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
147	199	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
148	200	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
149	201	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
150	202	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
151	203	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
152	204	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
153	205	2025-01-01	2025-12-31	PTO	0.0	10.0	10.0	2025-11-02	2025-11-02
154	206	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
155	207	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
156	208	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
157	209	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
158	210	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
159	211	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
160	212	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
161	213	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
162	214	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
163	215	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
164	216	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
165	217	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
166	218	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
167	219	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
168	220	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
169	221	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
170	222	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
171	223	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
172	224	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
173	225	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
174	226	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
175	227	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
176	228	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
177	229	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
178	230	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
179	231	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
180	232	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
181	233	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
182	234	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
183	235	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
184	236	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
185	237	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
186	238	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
187	239	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
188	240	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
189	241	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
190	242	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
191	243	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
192	244	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
193	245	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
194	246	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
195	247	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
196	248	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
197	249	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
198	250	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
199	251	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
200	252	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
201	253	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
202	254	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
203	255	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
204	256	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
205	257	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
206	258	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
207	259	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
208	260	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
209	261	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
210	262	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
211	263	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
212	264	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
213	265	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
214	266	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
215	267	2025-01-01	2025-12-31	PTO	0.0	10.0	10.0	2025-11-02	2025-11-02
216	268	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
217	269	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
218	270	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
219	271	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
220	272	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
221	273	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
222	274	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
223	275	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
224	276	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
225	277	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
226	278	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
227	279	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
228	280	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
229	281	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
230	282	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
231	283	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
232	284	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
233	285	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
234	286	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
235	287	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
236	288	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
237	289	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
238	290	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
239	291	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
240	292	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
241	293	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
242	294	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
243	295	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
244	296	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
245	297	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
246	298	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
247	299	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
248	300	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
249	302	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
250	303	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
251	304	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
252	305	2025-01-01	2025-12-31	PTO	0.0	10.0	10.0	2025-11-02	2025-11-02
253	306	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
254	307	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
255	308	2025-01-01	2025-12-31	PTO	0.0	10.0	10.0	2025-11-02	2025-11-02
256	309	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
257	310	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
258	311	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
259	312	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
260	313	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
261	314	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
262	315	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
263	316	2025-01-01	2025-12-31	PTO	0.0	10.0	10.0	2025-11-02	2025-11-02
264	317	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
265	318	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
266	319	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
267	320	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
268	321	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
269	322	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
270	323	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
271	324	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
272	325	2025-01-01	2025-12-31	PTO	0.0	10.0	10.0	2025-11-02	2025-11-02
273	326	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
274	327	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
275	328	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
276	329	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
277	330	2025-01-01	2025-12-31	PTO	0.0	10.0	10.0	2025-11-02	2025-11-02
278	331	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
279	332	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
280	333	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
281	334	2025-01-01	2025-12-31	PTO	0.0	10.0	10.0	2025-11-02	2025-11-02
282	335	2025-01-01	2025-12-31	PTO	0.0	10.0	10.0	2025-11-02	2025-11-02
283	336	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
284	337	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
285	338	2025-01-01	2025-12-31	PTO	0.0	10.0	10.0	2025-11-02	2025-11-02
286	339	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
287	340	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
288	341	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
289	343	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
290	344	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
291	345	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
292	346	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
293	347	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
294	348	2025-01-01	2025-12-31	PTO	0.0	10.0	10.0	2025-11-02	2025-11-02
295	349	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
296	350	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
297	351	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
298	352	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
299	353	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
300	354	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
301	355	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
302	356	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
303	357	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
304	358	2025-01-01	2025-12-31	PTO	0.0	10.0	10.0	2025-11-02	2025-11-02
305	359	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
306	360	2025-01-01	2025-12-31	PTO	0.0	10.0	10.0	2025-11-02	2025-11-02
307	361	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
308	362	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
309	363	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
310	364	2025-01-01	2025-12-31	PTO	0.0	10.0	10.0	2025-11-02	2025-11-02
311	365	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
312	366	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
313	367	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
314	368	2025-01-01	2025-12-31	PTO	0.0	30.0	30.0	2025-11-02	2025-11-02
315	369	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
316	370	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
317	371	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
318	372	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
319	373	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
320	374	2025-01-01	2025-12-31	PTO	0.0	10.0	10.0	2025-11-02	2025-11-02
321	375	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
322	376	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
323	377	2025-01-01	2025-12-31	PTO	0.0	10.0	10.0	2025-11-02	2025-11-02
324	378	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
325	379	2025-01-01	2025-12-31	PTO	0.0	10.0	10.0	2025-11-02	2025-11-02
326	380	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
327	381	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
328	382	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
329	383	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
330	384	2025-01-01	2025-12-31	PTO	0.0	15.0	15.0	2025-11-02	2025-11-02
331	385	2025-01-01	2025-12-31	PTO	0.0	20.0	20.0	2025-11-02	2025-11-02
665	1	2025-01-01	2025-12-31	PTO	0.0	18.5	18.5	2025-11-02	2025-11-02
666	10	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
667	301	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
668	2	2025-01-01	2025-12-31	PTO	0.0	17.0	17.0	2025-11-02	2025-11-02
669	3	2025-01-01	2025-12-31	PTO	0.0	16.4	16.4	2025-11-02	2025-11-02
670	4	2025-01-01	2025-12-31	PTO	0.0	17.0	17.0	2025-11-02	2025-11-02
671	5	2025-01-01	2025-12-31	PTO	0.0	15.8	15.8	2025-11-02	2025-11-02
672	6	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
673	7	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
674	8	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
675	9	2025-01-01	2025-12-31	PTO	0.0	17.0	17.0	2025-11-02	2025-11-02
676	13	2025-01-01	2025-12-31	PTO	0.0	15.2	15.2	2025-11-02	2025-11-02
677	14	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
678	15	2025-01-01	2025-12-31	PTO	0.0	16.4	16.4	2025-11-02	2025-11-02
679	16	2025-01-01	2025-12-31	PTO	0.0	17.0	17.0	2025-11-02	2025-11-02
680	17	2025-01-01	2025-12-31	PTO	0.0	17.0	17.0	2025-11-02	2025-11-02
681	18	2025-01-01	2025-12-31	PTO	0.0	15.2	15.2	2025-11-02	2025-11-02
682	26	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
683	27	2025-01-01	2025-12-31	PTO	0.0	17.0	17.0	2025-11-02	2025-11-02
684	28	2025-01-01	2025-12-31	PTO	0.0	16.4	16.4	2025-11-02	2025-11-02
685	29	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
686	30	2025-01-01	2025-12-31	PTO	0.0	15.8	15.8	2025-11-02	2025-11-02
687	31	2025-01-01	2025-12-31	PTO	0.0	15.8	15.8	2025-11-02	2025-11-02
688	32	2025-01-01	2025-12-31	PTO	0.0	16.4	16.4	2025-11-02	2025-11-02
689	33	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
690	34	2025-01-01	2025-12-31	PTO	0.0	15.8	15.8	2025-11-02	2025-11-02
691	39	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
692	40	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
693	41	2025-01-01	2025-12-31	PTO	0.0	16.4	16.4	2025-11-02	2025-11-02
694	42	2025-01-01	2025-12-31	PTO	0.0	16.4	16.4	2025-11-02	2025-11-02
695	43	2025-01-01	2025-12-31	PTO	0.0	17.0	17.0	2025-11-02	2025-11-02
696	44	2025-01-01	2025-12-31	PTO	0.0	15.2	15.2	2025-11-02	2025-11-02
697	45	2025-01-01	2025-12-31	PTO	0.0	16.4	16.4	2025-11-02	2025-11-02
698	46	2025-01-01	2025-12-31	PTO	0.0	17.0	17.0	2025-11-02	2025-11-02
699	47	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
700	48	2025-01-01	2025-12-31	PTO	0.0	17.0	17.0	2025-11-02	2025-11-02
701	49	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
702	50	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
703	51	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
704	52	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
705	53	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
706	66	2025-01-01	2025-12-31	PTO	0.0	18.5	18.5	2025-11-02	2025-11-02
707	67	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
708	68	2025-01-01	2025-12-31	PTO	0.0	16.4	16.4	2025-11-02	2025-11-02
709	69	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
710	70	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
711	71	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
712	72	2025-01-01	2025-12-31	PTO	0.0	15.8	15.8	2025-11-02	2025-11-02
713	73	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
714	74	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
715	75	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
716	76	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
717	77	2025-01-01	2025-12-31	PTO	0.0	17.0	17.0	2025-11-02	2025-11-02
718	78	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
719	79	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
720	80	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
721	81	2025-01-01	2025-12-31	PTO	0.0	17.0	17.0	2025-11-02	2025-11-02
722	82	2025-01-01	2025-12-31	PTO	0.0	17.0	17.0	2025-11-02	2025-11-02
723	83	2025-01-01	2025-12-31	PTO	0.0	15.8	15.8	2025-11-02	2025-11-02
724	84	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
725	85	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
726	86	2025-01-01	2025-12-31	PTO	0.0	17.0	17.0	2025-11-02	2025-11-02
727	87	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
728	88	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
729	89	2025-01-01	2025-12-31	PTO	0.0	15.8	15.8	2025-11-02	2025-11-02
730	90	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
731	91	2025-01-01	2025-12-31	PTO	0.0	16.4	16.4	2025-11-02	2025-11-02
732	92	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
733	93	2025-01-01	2025-12-31	PTO	0.0	16.4	16.4	2025-11-02	2025-11-02
734	94	2025-01-01	2025-12-31	PTO	0.0	15.2	15.2	2025-11-02	2025-11-02
735	95	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
736	96	2025-01-01	2025-12-31	PTO	0.0	16.4	16.4	2025-11-02	2025-11-02
737	97	2025-01-01	2025-12-31	PTO	0.0	15.8	15.8	2025-11-02	2025-11-02
738	98	2025-01-01	2025-12-31	PTO	0.0	15.8	15.8	2025-11-02	2025-11-02
739	99	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
740	103	2025-01-01	2025-12-31	PTO	0.0	16.4	16.4	2025-11-02	2025-11-02
741	104	2025-01-01	2025-12-31	PTO	0.0	17.0	17.0	2025-11-02	2025-11-02
742	105	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
743	106	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
744	107	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
745	108	2025-01-01	2025-12-31	PTO	0.0	16.4	16.4	2025-11-02	2025-11-02
746	109	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
747	110	2025-01-01	2025-12-31	PTO	0.0	16.4	16.4	2025-11-02	2025-11-02
748	111	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
749	112	2025-01-01	2025-12-31	PTO	0.0	17.0	17.0	2025-11-02	2025-11-02
750	113	2025-01-01	2025-12-31	PTO	0.0	16.4	16.4	2025-11-02	2025-11-02
751	114	2025-01-01	2025-12-31	PTO	0.0	17.0	17.0	2025-11-02	2025-11-02
752	115	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
753	116	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
754	126	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
755	127	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
756	128	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
757	129	2025-01-01	2025-12-31	PTO	0.0	15.8	15.8	2025-11-02	2025-11-02
758	130	2025-01-01	2025-12-31	PTO	0.0	15.8	15.8	2025-11-02	2025-11-02
759	131	2025-01-01	2025-12-31	PTO	0.0	15.2	15.2	2025-11-02	2025-11-02
760	132	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
761	133	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
762	134	2025-01-01	2025-12-31	PTO	0.0	15.8	15.8	2025-11-02	2025-11-02
763	135	2025-01-01	2025-12-31	PTO	0.0	16.4	16.4	2025-11-02	2025-11-02
764	136	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
765	137	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
766	138	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
767	139	2025-01-01	2025-12-31	PTO	0.0	17.0	17.0	2025-11-02	2025-11-02
768	152	2025-01-01	2025-12-31	PTO	0.0	15.8	15.8	2025-11-02	2025-11-02
769	153	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
770	154	2025-01-01	2025-12-31	PTO	0.0	15.2	15.2	2025-11-02	2025-11-02
771	155	2025-01-01	2025-12-31	PTO	0.0	17.0	17.0	2025-11-02	2025-11-02
772	156	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
773	157	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
774	158	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
775	159	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
776	160	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
777	161	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
778	162	2025-01-01	2025-12-31	PTO	0.0	15.2	15.2	2025-11-02	2025-11-02
779	163	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
780	164	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
781	165	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
782	166	2025-01-01	2025-12-31	PTO	0.0	17.0	17.0	2025-11-02	2025-11-02
783	167	2025-01-01	2025-12-31	PTO	0.0	15.2	15.2	2025-11-02	2025-11-02
784	168	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
785	169	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
786	170	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
787	171	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
788	172	2025-01-01	2025-12-31	PTO	0.0	15.8	15.8	2025-11-02	2025-11-02
789	173	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
790	174	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
791	175	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
792	176	2025-01-01	2025-12-31	PTO	0.0	17.0	17.0	2025-11-02	2025-11-02
793	177	2025-01-01	2025-12-31	PTO	0.0	15.2	15.2	2025-11-02	2025-11-02
794	178	2025-01-01	2025-12-31	PTO	0.0	15.2	15.2	2025-11-02	2025-11-02
795	179	2025-01-01	2025-12-31	PTO	0.0	17.0	17.0	2025-11-02	2025-11-02
796	180	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
797	181	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
798	182	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
799	183	2025-01-01	2025-12-31	PTO	0.0	15.8	15.8	2025-11-02	2025-11-02
800	184	2025-01-01	2025-12-31	PTO	0.0	17.0	17.0	2025-11-02	2025-11-02
801	185	2025-01-01	2025-12-31	PTO	0.0	17.0	17.0	2025-11-02	2025-11-02
802	186	2025-01-01	2025-12-31	PTO	0.0	15.2	15.2	2025-11-02	2025-11-02
803	187	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
804	188	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
805	193	2025-01-01	2025-12-31	PTO	0.0	15.8	15.8	2025-11-02	2025-11-02
806	194	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
807	195	2025-01-01	2025-12-31	PTO	0.0	16.4	16.4	2025-11-02	2025-11-02
808	196	2025-01-01	2025-12-31	PTO	0.0	15.2	15.2	2025-11-02	2025-11-02
809	197	2025-01-01	2025-12-31	PTO	0.0	17.0	17.0	2025-11-02	2025-11-02
810	198	2025-01-01	2025-12-31	PTO	0.0	17.0	17.0	2025-11-02	2025-11-02
811	199	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
812	200	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
813	201	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
814	202	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
815	203	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
816	204	2025-01-01	2025-12-31	PTO	0.0	15.8	15.8	2025-11-02	2025-11-02
817	205	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
818	206	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
819	207	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
820	208	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
821	209	2025-01-01	2025-12-31	PTO	0.0	16.4	16.4	2025-11-02	2025-11-02
822	210	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
823	211	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
824	212	2025-01-01	2025-12-31	PTO	0.0	16.4	16.4	2025-11-02	2025-11-02
825	213	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
826	214	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
827	215	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
828	216	2025-01-01	2025-12-31	PTO	0.0	17.0	17.0	2025-11-02	2025-11-02
829	217	2025-01-01	2025-12-31	PTO	0.0	15.2	15.2	2025-11-02	2025-11-02
830	218	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
831	219	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
832	220	2025-01-01	2025-12-31	PTO	0.0	16.4	16.4	2025-11-02	2025-11-02
833	221	2025-01-01	2025-12-31	PTO	0.0	15.2	15.2	2025-11-02	2025-11-02
834	222	2025-01-01	2025-12-31	PTO	0.0	15.8	15.8	2025-11-02	2025-11-02
835	223	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
836	224	2025-01-01	2025-12-31	PTO	0.0	15.2	15.2	2025-11-02	2025-11-02
837	225	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
838	226	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
839	227	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
840	228	2025-01-01	2025-12-31	PTO	0.0	15.8	15.8	2025-11-02	2025-11-02
841	229	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
842	230	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
843	231	2025-01-01	2025-12-31	PTO	0.0	15.2	15.2	2025-11-02	2025-11-02
844	232	2025-01-01	2025-12-31	PTO	0.0	15.2	15.2	2025-11-02	2025-11-02
845	233	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
846	234	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
847	235	2025-01-01	2025-12-31	PTO	0.0	15.2	15.2	2025-11-02	2025-11-02
848	236	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
849	237	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
850	238	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
851	239	2025-01-01	2025-12-31	PTO	0.0	15.8	15.8	2025-11-02	2025-11-02
852	240	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
853	241	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
854	242	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
855	243	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
856	244	2025-01-01	2025-12-31	PTO	0.0	15.8	15.8	2025-11-02	2025-11-02
857	245	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
858	246	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
859	247	2025-01-01	2025-12-31	PTO	0.0	17.0	17.0	2025-11-02	2025-11-02
860	248	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
861	249	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
862	250	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
863	251	2025-01-01	2025-12-31	PTO	0.0	17.0	17.0	2025-11-02	2025-11-02
864	252	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
865	253	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
866	254	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
867	255	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
868	256	2025-01-01	2025-12-31	PTO	0.0	15.2	15.2	2025-11-02	2025-11-02
869	257	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
870	258	2025-01-01	2025-12-31	PTO	0.0	15.8	15.8	2025-11-02	2025-11-02
871	259	2025-01-01	2025-12-31	PTO	0.0	15.8	15.8	2025-11-02	2025-11-02
872	260	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
873	261	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
874	262	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
875	263	2025-01-01	2025-12-31	PTO	0.0	15.8	15.8	2025-11-02	2025-11-02
876	264	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
877	265	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
878	266	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
879	267	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
880	268	2025-01-01	2025-12-31	PTO	0.0	17.0	17.0	2025-11-02	2025-11-02
881	269	2025-01-01	2025-12-31	PTO	0.0	15.2	15.2	2025-11-02	2025-11-02
882	270	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
883	271	2025-01-01	2025-12-31	PTO	0.0	15.8	15.8	2025-11-02	2025-11-02
884	272	2025-01-01	2025-12-31	PTO	0.0	15.2	15.2	2025-11-02	2025-11-02
885	273	2025-01-01	2025-12-31	PTO	0.0	15.8	15.8	2025-11-02	2025-11-02
886	274	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
887	275	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
888	276	2025-01-01	2025-12-31	PTO	0.0	15.8	15.8	2025-11-02	2025-11-02
889	277	2025-01-01	2025-12-31	PTO	0.0	15.2	15.2	2025-11-02	2025-11-02
890	278	2025-01-01	2025-12-31	PTO	0.0	17.0	17.0	2025-11-02	2025-11-02
891	279	2025-01-01	2025-12-31	PTO	0.0	16.4	16.4	2025-11-02	2025-11-02
892	280	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
893	281	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
894	282	2025-01-01	2025-12-31	PTO	0.0	16.4	16.4	2025-11-02	2025-11-02
895	283	2025-01-01	2025-12-31	PTO	0.0	15.8	15.8	2025-11-02	2025-11-02
896	284	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
897	285	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
898	286	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
899	287	2025-01-01	2025-12-31	PTO	0.0	15.2	15.2	2025-11-02	2025-11-02
900	288	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
901	289	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
902	290	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
903	291	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
904	292	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
905	293	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
906	294	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
907	295	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
908	296	2025-01-01	2025-12-31	PTO	0.0	15.2	15.2	2025-11-02	2025-11-02
909	297	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
910	298	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
911	299	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
912	300	2025-01-01	2025-12-31	PTO	0.0	15.8	15.8	2025-11-02	2025-11-02
913	302	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
914	303	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
915	304	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
916	305	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
917	306	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
918	307	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
919	308	2025-01-01	2025-12-31	PTO	0.0	10.0	10.0	2025-11-02	2025-11-02
920	309	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
921	310	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
922	311	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
923	312	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
924	313	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
925	314	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
926	315	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
927	316	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
928	317	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
929	318	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
930	319	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
931	320	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
932	321	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
933	322	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
934	323	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
935	324	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
936	325	2025-01-01	2025-12-31	PTO	0.0	10.0	10.0	2025-11-02	2025-11-02
937	326	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
938	327	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
939	328	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
940	329	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
941	330	2025-01-01	2025-12-31	PTO	0.0	10.0	10.0	2025-11-02	2025-11-02
942	331	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
943	332	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
944	333	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
945	334	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
946	335	2025-01-01	2025-12-31	PTO	0.0	10.0	10.0	2025-11-02	2025-11-02
947	336	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
948	337	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
949	338	2025-01-01	2025-12-31	PTO	0.0	10.0	10.0	2025-11-02	2025-11-02
950	339	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
951	340	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
952	341	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
953	343	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
954	344	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
955	345	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
956	346	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
957	347	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
958	348	2025-01-01	2025-12-31	PTO	0.0	10.0	10.0	2025-11-02	2025-11-02
959	349	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
960	350	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
961	351	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
962	352	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
963	353	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
964	354	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
965	355	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
966	356	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
967	357	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
968	358	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
969	359	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
970	360	2025-01-01	2025-12-31	PTO	0.0	10.0	10.0	2025-11-02	2025-11-02
971	361	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
972	362	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
973	363	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
974	364	2025-01-01	2025-12-31	PTO	0.0	10.0	10.0	2025-11-02	2025-11-02
975	365	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
976	366	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
977	367	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
978	368	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
979	369	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
980	370	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
981	371	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
982	372	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
983	373	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
984	374	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
985	375	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
986	376	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
987	377	2025-01-01	2025-12-31	PTO	0.0	10.0	10.0	2025-11-02	2025-11-02
988	378	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
989	379	2025-01-01	2025-12-31	PTO	0.0	10.0	10.0	2025-11-02	2025-11-02
990	380	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
991	381	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
992	382	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
993	383	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
994	384	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
995	385	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
997	10	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
998	301	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
999	2	2025-01-01	2025-12-31	PTO	0.0	17.0	17.0	2025-11-02	2025-11-02
1000	3	2025-01-01	2025-12-31	PTO	0.0	16.4	16.4	2025-11-02	2025-11-02
1001	4	2025-01-01	2025-12-31	PTO	0.0	17.0	17.0	2025-11-02	2025-11-02
1002	5	2025-01-01	2025-12-31	PTO	0.0	15.8	15.8	2025-11-02	2025-11-02
1003	6	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
1004	7	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
1005	8	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
1006	9	2025-01-01	2025-12-31	PTO	0.0	17.0	17.0	2025-11-02	2025-11-02
1007	13	2025-01-01	2025-12-31	PTO	0.0	15.2	15.2	2025-11-02	2025-11-02
1008	14	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
1009	15	2025-01-01	2025-12-31	PTO	0.0	16.4	16.4	2025-11-02	2025-11-02
1010	16	2025-01-01	2025-12-31	PTO	0.0	17.0	17.0	2025-11-02	2025-11-02
1011	17	2025-01-01	2025-12-31	PTO	0.0	17.0	17.0	2025-11-02	2025-11-02
1012	18	2025-01-01	2025-12-31	PTO	0.0	15.2	15.2	2025-11-02	2025-11-02
1013	26	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
1014	27	2025-01-01	2025-12-31	PTO	0.0	17.0	17.0	2025-11-02	2025-11-02
1015	28	2025-01-01	2025-12-31	PTO	0.0	16.4	16.4	2025-11-02	2025-11-02
1016	29	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
1017	30	2025-01-01	2025-12-31	PTO	0.0	15.8	15.8	2025-11-02	2025-11-02
1018	31	2025-01-01	2025-12-31	PTO	0.0	15.8	15.8	2025-11-02	2025-11-02
1019	32	2025-01-01	2025-12-31	PTO	0.0	16.4	16.4	2025-11-02	2025-11-02
1020	33	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
1021	34	2025-01-01	2025-12-31	PTO	0.0	15.8	15.8	2025-11-02	2025-11-02
1022	39	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
1023	40	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
1024	41	2025-01-01	2025-12-31	PTO	0.0	16.4	16.4	2025-11-02	2025-11-02
1025	42	2025-01-01	2025-12-31	PTO	0.0	16.4	16.4	2025-11-02	2025-11-02
1026	43	2025-01-01	2025-12-31	PTO	0.0	17.0	17.0	2025-11-02	2025-11-02
1027	44	2025-01-01	2025-12-31	PTO	0.0	15.2	15.2	2025-11-02	2025-11-02
1028	45	2025-01-01	2025-12-31	PTO	0.0	16.4	16.4	2025-11-02	2025-11-02
1029	46	2025-01-01	2025-12-31	PTO	0.0	17.0	17.0	2025-11-02	2025-11-02
1030	47	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
1031	48	2025-01-01	2025-12-31	PTO	0.0	17.0	17.0	2025-11-02	2025-11-02
1032	49	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
1033	50	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
1034	51	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
1035	52	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
1036	53	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
1037	66	2025-01-01	2025-12-31	PTO	0.0	18.5	18.5	2025-11-02	2025-11-02
1038	67	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
1039	68	2025-01-01	2025-12-31	PTO	0.0	16.4	16.4	2025-11-02	2025-11-02
1040	69	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
1041	70	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
1042	71	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
1043	72	2025-01-01	2025-12-31	PTO	0.0	15.8	15.8	2025-11-02	2025-11-02
1044	73	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
1045	74	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
1046	75	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
1047	76	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
1048	77	2025-01-01	2025-12-31	PTO	0.0	17.0	17.0	2025-11-02	2025-11-02
1049	78	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
1050	79	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
1051	80	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
1052	81	2025-01-01	2025-12-31	PTO	0.0	17.0	17.0	2025-11-02	2025-11-02
1053	82	2025-01-01	2025-12-31	PTO	0.0	17.0	17.0	2025-11-02	2025-11-02
1054	83	2025-01-01	2025-12-31	PTO	0.0	15.8	15.8	2025-11-02	2025-11-02
1055	84	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
1056	85	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
1057	86	2025-01-01	2025-12-31	PTO	0.0	17.0	17.0	2025-11-02	2025-11-02
1058	87	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
1059	88	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
1060	89	2025-01-01	2025-12-31	PTO	0.0	15.8	15.8	2025-11-02	2025-11-02
1061	90	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
1062	91	2025-01-01	2025-12-31	PTO	0.0	16.4	16.4	2025-11-02	2025-11-02
1063	92	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
1064	93	2025-01-01	2025-12-31	PTO	0.0	16.4	16.4	2025-11-02	2025-11-02
1065	94	2025-01-01	2025-12-31	PTO	0.0	15.2	15.2	2025-11-02	2025-11-02
1066	95	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
1067	96	2025-01-01	2025-12-31	PTO	0.0	16.4	16.4	2025-11-02	2025-11-02
1068	97	2025-01-01	2025-12-31	PTO	0.0	15.8	15.8	2025-11-02	2025-11-02
1069	98	2025-01-01	2025-12-31	PTO	0.0	15.8	15.8	2025-11-02	2025-11-02
1070	99	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
1071	103	2025-01-01	2025-12-31	PTO	0.0	16.4	16.4	2025-11-02	2025-11-02
1072	104	2025-01-01	2025-12-31	PTO	0.0	17.0	17.0	2025-11-02	2025-11-02
1073	105	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
1074	106	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
1075	107	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
1076	108	2025-01-01	2025-12-31	PTO	0.0	16.4	16.4	2025-11-02	2025-11-02
1077	109	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
1078	110	2025-01-01	2025-12-31	PTO	0.0	16.4	16.4	2025-11-02	2025-11-02
1079	111	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
1080	112	2025-01-01	2025-12-31	PTO	0.0	17.0	17.0	2025-11-02	2025-11-02
1081	113	2025-01-01	2025-12-31	PTO	0.0	16.4	16.4	2025-11-02	2025-11-02
1082	114	2025-01-01	2025-12-31	PTO	0.0	17.0	17.0	2025-11-02	2025-11-02
1083	115	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
1084	116	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
1085	126	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
1086	127	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
1087	128	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
1088	129	2025-01-01	2025-12-31	PTO	0.0	15.8	15.8	2025-11-02	2025-11-02
1089	130	2025-01-01	2025-12-31	PTO	0.0	15.8	15.8	2025-11-02	2025-11-02
1090	131	2025-01-01	2025-12-31	PTO	0.0	15.2	15.2	2025-11-02	2025-11-02
1091	132	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
1092	133	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
1093	134	2025-01-01	2025-12-31	PTO	0.0	15.8	15.8	2025-11-02	2025-11-02
1094	135	2025-01-01	2025-12-31	PTO	0.0	16.4	16.4	2025-11-02	2025-11-02
1095	136	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
1096	137	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
1097	138	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
1098	139	2025-01-01	2025-12-31	PTO	0.0	17.0	17.0	2025-11-02	2025-11-02
1099	152	2025-01-01	2025-12-31	PTO	0.0	15.8	15.8	2025-11-02	2025-11-02
1100	153	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
1101	154	2025-01-01	2025-12-31	PTO	0.0	15.2	15.2	2025-11-02	2025-11-02
1102	155	2025-01-01	2025-12-31	PTO	0.0	17.0	17.0	2025-11-02	2025-11-02
1103	156	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
1104	157	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
1105	158	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
1106	159	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
1107	160	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
1108	161	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
1109	162	2025-01-01	2025-12-31	PTO	0.0	15.2	15.2	2025-11-02	2025-11-02
1110	163	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
1111	164	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
1112	165	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
1113	166	2025-01-01	2025-12-31	PTO	0.0	17.0	17.0	2025-11-02	2025-11-02
1114	167	2025-01-01	2025-12-31	PTO	0.0	15.2	15.2	2025-11-02	2025-11-02
1115	168	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
1116	169	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
1117	170	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
1118	171	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
1119	172	2025-01-01	2025-12-31	PTO	0.0	15.8	15.8	2025-11-02	2025-11-02
1120	173	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
1121	174	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
1122	175	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
1123	176	2025-01-01	2025-12-31	PTO	0.0	17.0	17.0	2025-11-02	2025-11-02
1124	177	2025-01-01	2025-12-31	PTO	0.0	15.2	15.2	2025-11-02	2025-11-02
1125	178	2025-01-01	2025-12-31	PTO	0.0	15.2	15.2	2025-11-02	2025-11-02
1126	179	2025-01-01	2025-12-31	PTO	0.0	17.0	17.0	2025-11-02	2025-11-02
1127	180	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
1128	181	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
1129	182	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
1130	183	2025-01-01	2025-12-31	PTO	0.0	15.8	15.8	2025-11-02	2025-11-02
1131	184	2025-01-01	2025-12-31	PTO	0.0	17.0	17.0	2025-11-02	2025-11-02
1132	185	2025-01-01	2025-12-31	PTO	0.0	17.0	17.0	2025-11-02	2025-11-02
1133	186	2025-01-01	2025-12-31	PTO	0.0	15.2	15.2	2025-11-02	2025-11-02
1134	187	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
1135	188	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
1136	193	2025-01-01	2025-12-31	PTO	0.0	15.8	15.8	2025-11-02	2025-11-02
1137	194	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
1138	195	2025-01-01	2025-12-31	PTO	0.0	16.4	16.4	2025-11-02	2025-11-02
1139	196	2025-01-01	2025-12-31	PTO	0.0	15.2	15.2	2025-11-02	2025-11-02
1140	197	2025-01-01	2025-12-31	PTO	0.0	17.0	17.0	2025-11-02	2025-11-02
1141	198	2025-01-01	2025-12-31	PTO	0.0	17.0	17.0	2025-11-02	2025-11-02
1142	199	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
1143	200	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
1144	201	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
1145	202	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
1146	203	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
1147	204	2025-01-01	2025-12-31	PTO	0.0	15.8	15.8	2025-11-02	2025-11-02
1148	205	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
1149	206	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
1150	207	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
1151	208	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
1152	209	2025-01-01	2025-12-31	PTO	0.0	16.4	16.4	2025-11-02	2025-11-02
1153	210	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
1154	211	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
1155	212	2025-01-01	2025-12-31	PTO	0.0	16.4	16.4	2025-11-02	2025-11-02
1156	213	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
1157	214	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
1158	215	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
1159	216	2025-01-01	2025-12-31	PTO	0.0	17.0	17.0	2025-11-02	2025-11-02
1160	217	2025-01-01	2025-12-31	PTO	0.0	15.2	15.2	2025-11-02	2025-11-02
1161	218	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
1162	219	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
1163	220	2025-01-01	2025-12-31	PTO	0.0	16.4	16.4	2025-11-02	2025-11-02
1164	221	2025-01-01	2025-12-31	PTO	0.0	15.2	15.2	2025-11-02	2025-11-02
1165	222	2025-01-01	2025-12-31	PTO	0.0	15.8	15.8	2025-11-02	2025-11-02
1166	223	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
1167	224	2025-01-01	2025-12-31	PTO	0.0	15.2	15.2	2025-11-02	2025-11-02
1168	225	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
1169	226	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
1170	227	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
1171	228	2025-01-01	2025-12-31	PTO	0.0	15.8	15.8	2025-11-02	2025-11-02
1172	229	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
1173	230	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
1174	231	2025-01-01	2025-12-31	PTO	0.0	15.2	15.2	2025-11-02	2025-11-02
1175	232	2025-01-01	2025-12-31	PTO	0.0	15.2	15.2	2025-11-02	2025-11-02
1176	233	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
1177	234	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
1178	235	2025-01-01	2025-12-31	PTO	0.0	15.2	15.2	2025-11-02	2025-11-02
1179	236	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
1180	237	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
1181	238	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
1182	239	2025-01-01	2025-12-31	PTO	0.0	15.8	15.8	2025-11-02	2025-11-02
1183	240	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
1184	241	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
1185	242	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
1186	243	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
1187	244	2025-01-01	2025-12-31	PTO	0.0	15.8	15.8	2025-11-02	2025-11-02
1188	245	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
1189	246	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
1190	247	2025-01-01	2025-12-31	PTO	0.0	17.0	17.0	2025-11-02	2025-11-02
1191	248	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
1192	249	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
1193	250	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
1194	251	2025-01-01	2025-12-31	PTO	0.0	17.0	17.0	2025-11-02	2025-11-02
1195	252	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
1196	253	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
1197	254	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
1198	255	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
1199	256	2025-01-01	2025-12-31	PTO	0.0	15.2	15.2	2025-11-02	2025-11-02
1200	257	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
1201	258	2025-01-01	2025-12-31	PTO	0.0	15.8	15.8	2025-11-02	2025-11-02
1202	259	2025-01-01	2025-12-31	PTO	0.0	15.8	15.8	2025-11-02	2025-11-02
1203	260	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
1204	261	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
1205	262	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
1206	263	2025-01-01	2025-12-31	PTO	0.0	15.8	15.8	2025-11-02	2025-11-02
1207	264	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
1208	265	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
1209	266	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
1210	267	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
1211	268	2025-01-01	2025-12-31	PTO	0.0	17.0	17.0	2025-11-02	2025-11-02
1212	269	2025-01-01	2025-12-31	PTO	0.0	15.2	15.2	2025-11-02	2025-11-02
1213	270	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
1214	271	2025-01-01	2025-12-31	PTO	0.0	15.8	15.8	2025-11-02	2025-11-02
1215	272	2025-01-01	2025-12-31	PTO	0.0	15.2	15.2	2025-11-02	2025-11-02
1216	273	2025-01-01	2025-12-31	PTO	0.0	15.8	15.8	2025-11-02	2025-11-02
1217	274	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
1218	275	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
1219	276	2025-01-01	2025-12-31	PTO	0.0	15.8	15.8	2025-11-02	2025-11-02
1220	277	2025-01-01	2025-12-31	PTO	0.0	15.2	15.2	2025-11-02	2025-11-02
1221	278	2025-01-01	2025-12-31	PTO	0.0	17.0	17.0	2025-11-02	2025-11-02
1222	279	2025-01-01	2025-12-31	PTO	0.0	16.4	16.4	2025-11-02	2025-11-02
1223	280	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
1224	281	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
1225	282	2025-01-01	2025-12-31	PTO	0.0	16.4	16.4	2025-11-02	2025-11-02
1226	283	2025-01-01	2025-12-31	PTO	0.0	15.8	15.8	2025-11-02	2025-11-02
1227	284	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
1228	285	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
1229	286	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
1230	287	2025-01-01	2025-12-31	PTO	0.0	15.2	15.2	2025-11-02	2025-11-02
1231	288	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
1232	289	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
1233	290	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
1234	291	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
1235	292	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
1236	293	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
1237	294	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
1238	295	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
1239	296	2025-01-01	2025-12-31	PTO	0.0	15.2	15.2	2025-11-02	2025-11-02
1240	297	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
1241	298	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
1242	299	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
1243	300	2025-01-01	2025-12-31	PTO	0.0	15.8	15.8	2025-11-02	2025-11-02
1244	302	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
1245	303	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
1246	304	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
1247	305	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
1248	306	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
1249	307	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
1250	308	2025-01-01	2025-12-31	PTO	0.0	10.0	10.0	2025-11-02	2025-11-02
1251	309	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
1252	310	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
1253	311	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
1254	312	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
1255	313	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
1256	314	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
1257	315	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
1258	316	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
1259	317	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
1260	318	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
1261	319	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
1262	320	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
1263	321	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
1264	322	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
1265	323	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
1266	324	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
1267	325	2025-01-01	2025-12-31	PTO	0.0	10.0	10.0	2025-11-02	2025-11-02
1268	326	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
1269	327	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
1270	328	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
1271	329	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
1272	330	2025-01-01	2025-12-31	PTO	0.0	10.0	10.0	2025-11-02	2025-11-02
1273	331	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
1274	332	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
1275	333	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
1276	334	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
1277	335	2025-01-01	2025-12-31	PTO	0.0	10.0	10.0	2025-11-02	2025-11-02
1278	336	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
1279	337	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
1280	338	2025-01-01	2025-12-31	PTO	0.0	10.0	10.0	2025-11-02	2025-11-02
1281	339	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
1282	340	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
1283	341	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
1284	343	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
1285	344	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
1286	345	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
1287	346	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
1288	347	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
1289	348	2025-01-01	2025-12-31	PTO	0.0	10.0	10.0	2025-11-02	2025-11-02
1290	349	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
1291	350	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
1292	351	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
1293	352	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
1294	353	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
1295	354	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
1296	355	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
1297	356	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
1298	357	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
1299	358	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
1300	359	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
1301	360	2025-01-01	2025-12-31	PTO	0.0	10.0	10.0	2025-11-02	2025-11-02
1302	361	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
1303	362	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
1304	363	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
1305	364	2025-01-01	2025-12-31	PTO	0.0	10.0	10.0	2025-11-02	2025-11-02
1306	365	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
1307	366	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
1308	367	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
1309	368	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
1310	369	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
1311	370	2025-01-01	2025-12-31	PTO	0.0	12.4	12.4	2025-11-02	2025-11-02
1312	371	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
1313	372	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
1314	373	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
1315	374	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
1316	375	2025-01-01	2025-12-31	PTO	0.0	14.6	14.6	2025-11-02	2025-11-02
1317	376	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
1318	377	2025-01-01	2025-12-31	PTO	0.0	10.0	10.0	2025-11-02	2025-11-02
1319	378	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
1320	379	2025-01-01	2025-12-31	PTO	0.0	10.0	10.0	2025-11-02	2025-11-02
1321	380	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
1322	381	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
1323	382	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
1324	383	2025-01-01	2025-12-31	PTO	0.0	11.6	11.6	2025-11-02	2025-11-02
1325	384	2025-01-01	2025-12-31	PTO	0.0	10.8	10.8	2025-11-02	2025-11-02
1326	385	2025-01-01	2025-12-31	PTO	0.0	14.0	14.0	2025-11-02	2025-11-02
\.


--
-- Data for Name: time_off_requests; Type: TABLE DATA; Schema: public; Owner: neill
--

COPY public.time_off_requests (request_id, employee_id, type, start_date, end_date, days_requested, status, created_at, updated_at) FROM stdin;
2	1	PTO	2025-02-10	2025-02-12	3.0	Approved	2025-11-02 15:20:01.977534	2025-11-02 15:20:01.977534
3	1	PTO	2025-02-17	2025-02-18	2.0	Approved	2025-11-02 15:22:18.230964	2025-11-02 15:22:18.230964
4	2	PTO	2025-12-23	2025-12-27	4.0	Pending	2025-11-04 21:46:11.002	2025-11-04 21:46:11.002
5	2	PTO	2025-11-10	2025-11-12	3.0	Pending	2025-11-04 22:00:19.701	2025-11-04 22:00:19.701
6	2	Sick Leave	2025-10-20	2025-10-23	4.0	Pending	2025-11-04 22:01:11.08	2025-11-04 22:01:11.08
7	2	PTO	2025-12-08	2025-12-09	2.0	Pending	2025-11-04 22:24:53.065	2025-11-04 22:24:53.065
8	2	PTO	2025-12-15	2025-12-17	3.0	Pending	2025-11-05 02:01:39.298	2025-11-05 02:01:39.298
9	2	PTO	2025-12-15	2025-12-17	3.0	Pending	2025-11-05 22:09:11.32	2025-11-05 22:09:11.32
\.


--
-- Name: applications_application_id_seq; Type: SEQUENCE SET; Schema: public; Owner: neill
--

SELECT pg_catalog.setval('public.applications_application_id_seq', 1, false);


--
-- Name: benefit_plan_benefit_plan_id_seq; Type: SEQUENCE SET; Schema: public; Owner: neill
--

SELECT pg_catalog.setval('public.benefit_plan_benefit_plan_id_seq', 1, false);


--
-- Name: benefits_catalog_benefit_catalog_id_seq; Type: SEQUENCE SET; Schema: public; Owner: neill
--

SELECT pg_catalog.setval('public.benefits_catalog_benefit_catalog_id_seq', 1, false);


--
-- Name: candidates_candidate_id_seq; Type: SEQUENCE SET; Schema: public; Owner: neill
--

SELECT pg_catalog.setval('public.candidates_candidate_id_seq', 1, false);


--
-- Name: competencies_competency_id_seq; Type: SEQUENCE SET; Schema: public; Owner: neill
--

SELECT pg_catalog.setval('public.competencies_competency_id_seq', 1, false);


--
-- Name: competency_definitions_competency_def_id_seq; Type: SEQUENCE SET; Schema: public; Owner: neill
--

SELECT pg_catalog.setval('public.competency_definitions_competency_def_id_seq', 36, true);


--
-- Name: core_competencies_competency_id_seq; Type: SEQUENCE SET; Schema: public; Owner: neill
--

SELECT pg_catalog.setval('public.core_competencies_competency_id_seq', 6, true);


--
-- Name: departments_department_id_seq; Type: SEQUENCE SET; Schema: public; Owner: neill
--

SELECT pg_catalog.setval('public.departments_department_id_seq', 1, false);


--
-- Name: employee_benefits_employee_benefit_id_seq; Type: SEQUENCE SET; Schema: public; Owner: neill
--

SELECT pg_catalog.setval('public.employee_benefits_employee_benefit_id_seq', 1165, true);


--
-- Name: employee_competencies_employee_competency_id_seq; Type: SEQUENCE SET; Schema: public; Owner: neill
--

SELECT pg_catalog.setval('public.employee_competencies_employee_competency_id_seq', 36, true);


--
-- Name: employee_goals_goal_id_seq; Type: SEQUENCE SET; Schema: public; Owner: neill
--

SELECT pg_catalog.setval('public.employee_goals_goal_id_seq', 15, true);


--
-- Name: employee_reviews_review_id_seq; Type: SEQUENCE SET; Schema: public; Owner: neill
--

SELECT pg_catalog.setval('public.employee_reviews_review_id_seq', 3, true);


--
-- Name: employees_employee_id_seq; Type: SEQUENCE SET; Schema: public; Owner: neill
--

SELECT pg_catalog.setval('public.employees_employee_id_seq', 1, false);


--
-- Name: functions_function_id_seq; Type: SEQUENCE SET; Schema: public; Owner: neill
--

SELECT pg_catalog.setval('public.functions_function_id_seq', 1, false);


--
-- Name: interviews_interview_id_seq; Type: SEQUENCE SET; Schema: public; Owner: neill
--

SELECT pg_catalog.setval('public.interviews_interview_id_seq', 1, false);


--
-- Name: job_families_job_family_id_seq; Type: SEQUENCE SET; Schema: public; Owner: neill
--

SELECT pg_catalog.setval('public.job_families_job_family_id_seq', 11, true);


--
-- Name: job_offers_offer_id_seq; Type: SEQUENCE SET; Schema: public; Owner: neill
--

SELECT pg_catalog.setval('public.job_offers_offer_id_seq', 1, false);


--
-- Name: job_postings_job_posting_id_seq; Type: SEQUENCE SET; Schema: public; Owner: neill
--

SELECT pg_catalog.setval('public.job_postings_job_posting_id_seq', 1, false);


--
-- Name: review_cycles_review_cycle_id_seq; Type: SEQUENCE SET; Schema: public; Owner: neill
--

SELECT pg_catalog.setval('public.review_cycles_review_cycle_id_seq', 1, true);


--
-- Name: roles_role_id_seq; Type: SEQUENCE SET; Schema: public; Owner: neill
--

SELECT pg_catalog.setval('public.roles_role_id_seq', 45, true);


--
-- Name: roles_role_level_id_seq; Type: SEQUENCE SET; Schema: public; Owner: neill
--

SELECT pg_catalog.setval('public.roles_role_level_id_seq', 45, true);


--
-- Name: strategies_strategy_id_seq; Type: SEQUENCE SET; Schema: public; Owner: neill
--

SELECT pg_catalog.setval('public.strategies_strategy_id_seq', 3, true);


--
-- Name: time_off_accruals_accrual_id_seq; Type: SEQUENCE SET; Schema: public; Owner: neill
--

SELECT pg_catalog.setval('public.time_off_accruals_accrual_id_seq', 662, true);


--
-- Name: time_off_requests_request_id_seq; Type: SEQUENCE SET; Schema: public; Owner: neill
--

SELECT pg_catalog.setval('public.time_off_requests_request_id_seq', 9, true);


--
-- Name: applications applications_pkey; Type: CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.applications
    ADD CONSTRAINT applications_pkey PRIMARY KEY (application_id);


--
-- Name: benefit_plan benefit_plan_pkey; Type: CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.benefit_plan
    ADD CONSTRAINT benefit_plan_pkey PRIMARY KEY (benefit_plan_id);


--
-- Name: benefits_catalog benefits_catalog_pkey; Type: CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.benefits_catalog
    ADD CONSTRAINT benefits_catalog_pkey PRIMARY KEY (benefit_catalog_id);


--
-- Name: candidates candidates_pkey; Type: CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.candidates
    ADD CONSTRAINT candidates_pkey PRIMARY KEY (candidate_id);


--
-- Name: competencies competencies_competency_name_key; Type: CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.competencies
    ADD CONSTRAINT competencies_competency_name_key UNIQUE (competency_name);


--
-- Name: competencies competencies_pkey; Type: CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.competencies
    ADD CONSTRAINT competencies_pkey PRIMARY KEY (competency_id);


--
-- Name: competency_definitions competency_definitions_pkey; Type: CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.competency_definitions
    ADD CONSTRAINT competency_definitions_pkey PRIMARY KEY (competency_def_id);


--
-- Name: competency_definitions competency_definitions_role_level_code_competency_id_key; Type: CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.competency_definitions
    ADD CONSTRAINT competency_definitions_role_level_code_competency_id_key UNIQUE (role_level_code, competency_id);


--
-- Name: core_competencies core_competencies_competency_name_key; Type: CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.core_competencies
    ADD CONSTRAINT core_competencies_competency_name_key UNIQUE (competency_name);


--
-- Name: core_competencies core_competencies_pkey; Type: CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.core_competencies
    ADD CONSTRAINT core_competencies_pkey PRIMARY KEY (competency_id);


--
-- Name: departments departments_pkey; Type: CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_pkey PRIMARY KEY (department_id);


--
-- Name: employee_benefits employee_benefits_pkey; Type: CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.employee_benefits
    ADD CONSTRAINT employee_benefits_pkey PRIMARY KEY (employee_benefit_id);


--
-- Name: employee_competencies employee_competencies_pkey; Type: CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.employee_competencies
    ADD CONSTRAINT employee_competencies_pkey PRIMARY KEY (employee_competency_id);


--
-- Name: employee_goals employee_goals_pkey; Type: CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.employee_goals
    ADD CONSTRAINT employee_goals_pkey PRIMARY KEY (goal_id);


--
-- Name: employee_reviews employee_reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.employee_reviews
    ADD CONSTRAINT employee_reviews_pkey PRIMARY KEY (review_id);


--
-- Name: employees employees_pkey; Type: CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_pkey PRIMARY KEY (employee_id);


--
-- Name: functions functions_pkey; Type: CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.functions
    ADD CONSTRAINT functions_pkey PRIMARY KEY (function_id);


--
-- Name: interviews interviews_pkey; Type: CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.interviews
    ADD CONSTRAINT interviews_pkey PRIMARY KEY (interview_id);


--
-- Name: job_families job_families_pkey; Type: CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.job_families
    ADD CONSTRAINT job_families_pkey PRIMARY KEY (job_family_id);


--
-- Name: job_offers job_offers_pkey; Type: CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.job_offers
    ADD CONSTRAINT job_offers_pkey PRIMARY KEY (offer_id);


--
-- Name: job_postings job_postings_pkey; Type: CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.job_postings
    ADD CONSTRAINT job_postings_pkey PRIMARY KEY (job_posting_id);


--
-- Name: rating_scale rating_scale_pkey; Type: CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.rating_scale
    ADD CONSTRAINT rating_scale_pkey PRIMARY KEY (rating_value);


--
-- Name: review_cycles review_cycles_name_key; Type: CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.review_cycles
    ADD CONSTRAINT review_cycles_name_key UNIQUE (name);


--
-- Name: review_cycles review_cycles_pkey; Type: CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.review_cycles
    ADD CONSTRAINT review_cycles_pkey PRIMARY KEY (review_cycle_id);


--
-- Name: role_levels role_levels_pkey; Type: CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.role_levels
    ADD CONSTRAINT role_levels_pkey PRIMARY KEY (role_level_code);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (role_id);


--
-- Name: strategies strategies_pkey; Type: CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.strategies
    ADD CONSTRAINT strategies_pkey PRIMARY KEY (strategy_id);


--
-- Name: strategies strategies_strategy_name_key; Type: CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.strategies
    ADD CONSTRAINT strategies_strategy_name_key UNIQUE (strategy_name);


--
-- Name: time_off_accruals time_off_accruals_employee_id_type_year_key; Type: CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.time_off_accruals
    ADD CONSTRAINT time_off_accruals_employee_id_type_year_key UNIQUE (employee_id, type, year);


--
-- Name: time_off_accruals time_off_accruals_pkey; Type: CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.time_off_accruals
    ADD CONSTRAINT time_off_accruals_pkey PRIMARY KEY (accrual_id);


--
-- Name: time_off_requests time_off_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.time_off_requests
    ADD CONSTRAINT time_off_requests_pkey PRIMARY KEY (request_id);


--
-- Name: employee_reviews unique_employee_cycle; Type: CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.employee_reviews
    ADD CONSTRAINT unique_employee_cycle UNIQUE (employee_id, review_cycle_id);


--
-- Name: time_off_requests trg_update_accrual_before_request; Type: TRIGGER; Schema: public; Owner: neill
--

CREATE TRIGGER trg_update_accrual_before_request BEFORE INSERT ON public.time_off_requests FOR EACH ROW EXECUTE FUNCTION public.update_accrual_balance();


--
-- Name: applications applications_candidate_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.applications
    ADD CONSTRAINT applications_candidate_id_fkey FOREIGN KEY (candidate_id) REFERENCES public.candidates(candidate_id);


--
-- Name: applications applications_job_posting_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.applications
    ADD CONSTRAINT applications_job_posting_id_fkey FOREIGN KEY (job_posting_id) REFERENCES public.job_postings(job_posting_id);


--
-- Name: benefits_catalog benefits_catalog_benefit_plan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.benefits_catalog
    ADD CONSTRAINT benefits_catalog_benefit_plan_id_fkey FOREIGN KEY (benefit_plan_id) REFERENCES public.benefit_plan(benefit_plan_id);


--
-- Name: candidates candidates_referred_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.candidates
    ADD CONSTRAINT candidates_referred_by_fkey FOREIGN KEY (referred_by) REFERENCES public.employees(employee_id);


--
-- Name: competency_definitions competency_definitions_competency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.competency_definitions
    ADD CONSTRAINT competency_definitions_competency_id_fkey FOREIGN KEY (competency_id) REFERENCES public.core_competencies(competency_id);


--
-- Name: competency_definitions competency_definitions_role_level_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.competency_definitions
    ADD CONSTRAINT competency_definitions_role_level_code_fkey FOREIGN KEY (role_level_code) REFERENCES public.role_levels(role_level_code);


--
-- Name: departments departments_function_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_function_id_fkey FOREIGN KEY (function_id) REFERENCES public.functions(function_id);


--
-- Name: employee_benefits employee_benefits_benefit_plan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.employee_benefits
    ADD CONSTRAINT employee_benefits_benefit_plan_id_fkey FOREIGN KEY (benefit_plan_id) REFERENCES public.benefit_plan(benefit_plan_id);


--
-- Name: employee_benefits employee_benefits_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.employee_benefits
    ADD CONSTRAINT employee_benefits_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(employee_id);


--
-- Name: employee_competencies employee_competencies_employee_rating_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.employee_competencies
    ADD CONSTRAINT employee_competencies_employee_rating_fkey FOREIGN KEY (employee_rating) REFERENCES public.rating_scale(rating_value);


--
-- Name: employee_competencies employee_competencies_manager_rating_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.employee_competencies
    ADD CONSTRAINT employee_competencies_manager_rating_fkey FOREIGN KEY (manager_rating) REFERENCES public.rating_scale(rating_value);


--
-- Name: employee_competencies employee_competencies_review_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.employee_competencies
    ADD CONSTRAINT employee_competencies_review_id_fkey FOREIGN KEY (review_id) REFERENCES public.employee_reviews(review_id) ON DELETE CASCADE;


--
-- Name: employee_goals employee_goals_employee_rating_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.employee_goals
    ADD CONSTRAINT employee_goals_employee_rating_fkey FOREIGN KEY (employee_rating) REFERENCES public.rating_scale(rating_value);


--
-- Name: employee_goals employee_goals_manager_rating_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.employee_goals
    ADD CONSTRAINT employee_goals_manager_rating_fkey FOREIGN KEY (manager_rating) REFERENCES public.rating_scale(rating_value);


--
-- Name: employee_goals employee_goals_review_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.employee_goals
    ADD CONSTRAINT employee_goals_review_id_fkey FOREIGN KEY (review_id) REFERENCES public.employee_reviews(review_id) ON DELETE CASCADE;


--
-- Name: employee_goals employee_goals_strategy_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.employee_goals
    ADD CONSTRAINT employee_goals_strategy_id_fkey FOREIGN KEY (strategy_id) REFERENCES public.strategies(strategy_id);


--
-- Name: employee_reviews employee_reviews_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.employee_reviews
    ADD CONSTRAINT employee_reviews_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(employee_id);


--
-- Name: employee_reviews employee_reviews_review_cycle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.employee_reviews
    ADD CONSTRAINT employee_reviews_review_cycle_id_fkey FOREIGN KEY (review_cycle_id) REFERENCES public.review_cycles(review_cycle_id);


--
-- Name: employees employees_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.departments(department_id);


--
-- Name: employees employees_manager_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_manager_id_fkey FOREIGN KEY (manager_id) REFERENCES public.employees(employee_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: employees employees_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(role_id);


--
-- Name: employee_competencies fk_employee_competencies_core_competency; Type: FK CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.employee_competencies
    ADD CONSTRAINT fk_employee_competencies_core_competency FOREIGN KEY (competency_id) REFERENCES public.core_competencies(competency_id) ON DELETE CASCADE;


--
-- Name: roles fk_roles_role_level_code; Type: FK CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT fk_roles_role_level_code FOREIGN KEY (role_level_code) REFERENCES public.role_levels(role_level_code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: interviews interviews_application_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.interviews
    ADD CONSTRAINT interviews_application_id_fkey FOREIGN KEY (application_id) REFERENCES public.applications(application_id);


--
-- Name: interviews interviews_interviewer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.interviews
    ADD CONSTRAINT interviews_interviewer_id_fkey FOREIGN KEY (interviewer_id) REFERENCES public.employees(employee_id);


--
-- Name: job_offers job_offers_application_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.job_offers
    ADD CONSTRAINT job_offers_application_id_fkey FOREIGN KEY (application_id) REFERENCES public.applications(application_id);


--
-- Name: job_offers job_offers_offered_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.job_offers
    ADD CONSTRAINT job_offers_offered_role_id_fkey FOREIGN KEY (offered_role_id) REFERENCES public.roles(role_id);


--
-- Name: job_postings job_postings_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.job_postings
    ADD CONSTRAINT job_postings_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.departments(department_id);


--
-- Name: job_postings job_postings_hiring_manager_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.job_postings
    ADD CONSTRAINT job_postings_hiring_manager_id_fkey FOREIGN KEY (hiring_manager_id) REFERENCES public.employees(employee_id);


--
-- Name: job_postings job_postings_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.job_postings
    ADD CONSTRAINT job_postings_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(role_id);


--
-- Name: roles roles_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.departments(department_id);


--
-- Name: roles roles_job_family_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_job_family_id_fkey FOREIGN KEY (job_family_id) REFERENCES public.job_families(job_family_id);


--
-- Name: roles roles_parent_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_parent_role_id_fkey FOREIGN KEY (parent_role_id) REFERENCES public.roles(role_id);


--
-- Name: time_off_accruals time_off_accruals_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.time_off_accruals
    ADD CONSTRAINT time_off_accruals_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(employee_id);


--
-- Name: time_off_requests time_off_requests_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neill
--

ALTER TABLE ONLY public.time_off_requests
    ADD CONSTRAINT time_off_requests_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(employee_id);


--
-- PostgreSQL database dump complete
--

\unrestrict hvMqd3l257bgVh5SdnfsApByBC6uaqLHZD7isJkdYUJt2lkQvX1f6KNxMOFdebt

