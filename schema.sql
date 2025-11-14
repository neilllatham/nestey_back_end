--
-- PostgreSQL database dump
--

\restrict KGM9TdCzhMtSyHkU0NUNHpxBLttqna8MHnK7fYoFHgopJjm4UabYU9i7HL0Mu9C

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
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    status character varying DEFAULT 'active'::character varying
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
    employee_overall_comments text,
    manager_overall_comments text,
    employee_overall_rating integer,
    manager_overall_rating integer,
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

\unrestrict KGM9TdCzhMtSyHkU0NUNHpxBLttqna8MHnK7fYoFHgopJjm4UabYU9i7HL0Mu9C

