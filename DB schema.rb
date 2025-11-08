// Use DBML to define your database structure
// Docs: https://dbml.dbdiagram.io/docs

/////////////////////////////////////////////////////////
// NESTEY V1.0 — CORE HRIS
/////////////////////////////////////////////////////////

Table employees {
  employee_id integer pk
  employee_number varchar
  first_name varchar
  middle_initial varchar
  last_name varchar
  full_name varchar
  preferred_name varchar
  job_title varchar
  email varchar
  hire_date datetime
  department_id integer // fk to departments table
  role_id integer // fk to roles table
  manager_id integer // fk to pk in employees table
  status varchar
  base_salary decimal (10,2)
  bonus_eligible bool
  target_bonus decimal (10,2)
  commission_eligible bool
  commission_target decimal (2,2)
  compensation_currency varchar
  date_of_birth date
  employment_type varchar
  gender varchar
  home_address varchar
  mobile_number varchar
  hours_per_week decimal (3,1)
}

Table departments {
  department_id pk
  department_name varchar
  function_id integer // fk to function table
}

Table functions {
  function_id pk
  function_name varchar
}

/////////////////////////////////////////////////////////
// Time off accruals and requests
/////////////////////////////////////////////////////////

Table time_off_accruals {
  accrual_id integer [pk]
  employee_id integer // fk → employees.employee_id
  type varchar // PTO, Sick Leave, etc.
  year integer // e.g., 2025
  accrued_days numeric(5,1) // total earned days for the year
  used_days numeric(5,1) // days already taken
  remaining_days numeric(5,1) // accrued_days - used_days
  last_updated date
}

Table time_off_requests {
  request_id integer [pk]
  employee_id integer // fk → employees.employee_id
  type varchar // PTO, Sick Leave
  start_date date
  end_date date
  days_requested numeric(5,1)
  status varchar // Approved, Pending, Rejected
  created_at timestamp
  updated_at timestamp
}

// Note: 'TRIGGER: trg_update_accrual_before_request
// BEFORE INSERT ON time_off_requests
// CALLS FUNCTION update_accrual_balance()
// -------------------------------------------------
// FUNCTION: update_accrual_balance()
// - Calculates weekdays between start_date and end_date using count_weekdays()
// - Sets NEW.days_requested
// - Updates time_off_accruals.used_days and remaining_days
// -------------------------------------------------
// FUNCTION: count_weekdays(start_date, end_date)
// - Returns number of workdays (Mon–Fri) between the two dates
// -------------------------------------------------
// Purpose:
// Automatically deducts PTO/Sick Leave from employee balance when a new request is inserted.'

/////////////////////////////////////////////////////////
// Benefits
/////////////////////////////////////////////////////////

Table benefits_catalog {
  benefit_catalog_id pk
  benefit_name varchar
  benefit_category varchar // medical, dental, vision
  description varchar
  employer_contribution decimal (1,2)
  employee_contribution decimal (1,2)
  dependent_coverage_allowed bool
  eligibility_criteria varchar
  created_at date
  updated_at date
  benefit_plan_id integer
  employee_pays decimal(10,2)
  employer_pays decimal(10,2)
  total_plan_cost decimal(10,2)
  enrollment_start_date date
  enrollment_end_date date
}

Table benefit_plan {
  benefit_plan_id pk
  plan_name varchar
  coverage_level varchar
  region varchar
  employer_contribution decimal (1,2)
  employee_contribution decimal (1,2)
  effective_date date
  expiry_date date
}

Table employee_benefits {
  employee_benefit_id pk
  employee_id integer // fk from employees table
  benefit_plan_id integer // fk from benefit_plan table
  dependants integer
  effective_date date
  expiry_date date
  date_created date
  date_updated date
}

/////////////////////////////////////////////////////////
// JOB ARCHITECTURE
/////////////////////////////////////////////////////////

Table role_levels {
  role_level_code varchar [pk]
  role_level_name varchar
  hierarchy_rank int
  description text
}

Table roles {
  role_id integer pk
  role_name varchar // e.g., Analyst, Senior Analyst, Manager
  role_level_code varchar // fk → role_levels.role_level_code
  parent_role_id integer // fk to self for hierarchical structure
  job_family_id integer // fk to job_families table
  department_id integer // fk to departments table
  description varchar
  date_created date
  date_updated date
}

Table job_families {
  job_family_id integer pk
  job_family_name varchar // e.g., Engineering, Finance, HR
  description varchar
}

Ref: roles.role_level_code > role_levels.role_level_code
Ref: roles.department_id > departments.department_id
Ref: roles.parent_role_id > roles.role_id
Ref: roles.job_family_id > job_families.job_family_id

/////////////////////////////////////////////////////////
// NESTEY — PERFORMANCE REVIEW MODULE (What + How)
/////////////////////////////////////////////////////////

Table review_cycles {
  review_cycle_id integer [pk]
  name varchar // e.g., "FY2025 Annual"
  cycle_type varchar // Annual, Mid-Year
  period_start date
  period_end date
  midyear_start date
  midyear_end date
  status varchar // Draft, Open, Closed
  is_active boolean
}

Table employee_review {
  review_id integer [pk]
  employee_id integer
  reviewer_id integer
  review_cycle_id integer
  overall_rating decimal(3,2)
  performance_category varchar
  summary_comments text
  review_status varchar // Draft, Submitted, Finalized
  created_at datetime
  updated_at datetime
  submitted_at timestamp
  finalized_at timestamp
}

Table employee_goals {
  goal_id integer [pk]
  review_id integer // fk → employee_review.review_id
  strategy_id integer // fk → strategies table
  objective text
  goal_description text
  target_date date
  employee_rating decimal(3,2)
  manager_rating decimal(3,2)
  employee_comments text
  manager_comments text
}

Table employee_competencies {
  employee_competency_id integer [pk]
  review_id integer // fk → employee_review.review_id
  competency_id integer // fk → core_competencies.competency_id
  employee_rating decimal(3,2)
  manager_rating decimal(3,2)
  employee_comments text
  manager_comments text
}

Table core_competencies {
  competency_id integer [pk]
  competency_name varchar
  description text
}

Table competency_definitions {
  competency_def_id integer [pk]
  role_level_code varchar // fk → role_levels.role_level_code
  competency_id integer // fk → core_competencies.competency_id
  expected_behavior text
}

Table review_feedback {
  review_feedback_id integer [pk]
  review_id integer
  feedback_provider_id integer
  relationship varchar // e.g., "Peer", "Direct Report"
  continue_doing text
  start_doing text
  stop_doing text
  summary_comments text
}

/////////////////////////////////////////////////////////
// EMPLOYEE PERFORMANCE RELATIONSHIPS
/////////////////////////////////////////////////////////

Ref: employee_review.employee_id > employees.employee_id
Ref: employee_review.reviewer_id > employees.employee_id
Ref: employee_review.review_cycle_id > review_cycles.review_cycle_id
Ref: employee_goals.review_id > employee_review.review_id
Ref: employee_competencies.review_id > employee_review.review_id
Ref: employee_competencies.competency_id > core_competencies.competency_id
Ref: competency_definitions.role_level_code > role_levels.role_level_code
Ref: competency_definitions.competency_id > core_competencies.competency_id
Ref: review_feedback.review_id > employee_review.review_id
Ref: review_feedback.feedback_provider_id > employees.employee_id

/////////////////////////////////////////////////////////
// GLOBAL RELATIONSHIPS
/////////////////////////////////////////////////////////

Ref: time_off_requests.employee_id > employees.employee_id
Ref: time_off_accruals.employee_id > employees.employee_id
Ref: employees.role_id > roles.role_id
Ref: employees.manager_id > employees.employee_id
Ref: employees.department_id > departments.department_id
Ref: departments.function_id > functions.function_id
Ref: employee_benefits.employee_id > employees.employee_id
Ref: employee_benefits.benefit_plan_id > benefit_plan.benefit_plan_id
Ref: benefits_catalog.benefit_plan_id > benefit_plan.benefit_plan_id

/////////////////////////////////////////////////////////
// EMPLOYEE ENGAGEMENT PULSE
/////////////////////////////////////////////////////////

Table employee_pulse {
  pulse_id integer [pk]
  employee_id integer
  pulse_date date
  mood_score integer
  comment text
  created_at datetime
}

Ref: employee_pulse.employee_id > employees.employee_id

/////////////////////////////////////////////////////////
// RECRUITING / TALENT ACQUISITION
/////////////////////////////////////////////////////////

Table job_postings {
  job_posting_id integer pk
  title varchar
  department_id integer
  role_id integer
  hiring_manager_id integer
  location varchar
  employment_type varchar
  description text
  requirements text
  salary_range_min decimal(10,2)
  salary_range_max decimal(10,2)
  currency varchar
  status varchar
  date_posted date
  date_closed date
  created_at timestamp
  updated_at timestamp
}

Table candidates {
  candidate_id integer pk
  first_name varchar
  last_name varchar
  email varchar
  phone varchar
  resume_url varchar
  linkedin_profile varchar
  referred_by integer
  current_company varchar
  notes text
  created_at timestamp
  updated_at timestamp
}

Table applications {
  application_id integer pk
  candidate_id integer
  job_posting_id integer
  source varchar
  status varchar
  applied_date date
  last_updated timestamp
}

Table interviews {
  interview_id integer pk
  application_id integer
  interviewer_id integer
  interview_date datetime
  interview_type varchar
  feedback text
  rating integer
  decision varchar
  created_at timestamp
  updated_at timestamp
}

Table job_offers {
  offer_id integer pk
  application_id integer
  offered_role_id integer
  offered_salary decimal(10,2)
  offered_bonus decimal(10,2)
  start_date date
  offer_status varchar
  sent_date date
  accepted_date date
  created_at timestamp
  updated_at timestamp
}

Ref: job_postings.department_id > departments.department_id
Ref: job_postings.role_id > roles.role_id
Ref: job_postings.hiring_manager_id > employees.employee_id
Ref: candidates.referred_by > employees.employee_id
Ref: applications.candidate_id > candidates.candidate_id
Ref: applications.job_posting_id > job_postings.job_posting_id
Ref: interviews.application_id > applications.application_id
Ref: interviews.interviewer_id > employees.employee_id
Ref: job_offers.application_id > applications.application_id
Ref: job_offers.offered_role_id > roles.role_id
