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




// Benefit catalog (types of benefits) 
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
  employee_pays decimal(10,2)                    // Employee cost per pay period ($)
  employer_pays decimal(10,2)                    // Employer cost per pay period ($)
  total_plan_cost decimal(10,2)                  // Total plan cost per pay period ($)
  enrollment_start_date date
  enrollment_end_date date

}

// Specific plan/variant of a Benefit (e.g., Gold vs. Silver, regional differences)
// a benefit_plan has many benefits from the catalog
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


// Enrollment / employee’s instance of a benefit plan
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


Table roles {
  role_id integer pk
  role_name varchar // e.g., Analyst, Senior Analyst, Manager
  role_level integer // numeric ordering for hierarchy (1=entry, 2=manager, etc.)
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

/////////////////////////////////////////////////////////
// NESTEY — PERFORMANCE REVIEW MODULE (What + How)
/////////////////////////////////////////////////////////

Table review_cycles {
  review_cycle_id integer [pk]
  name varchar // e.g., "FY2025 Annual"
  period_start date
  period_end date
  status varchar // Draft, Open, Closed
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
}

Table review_goals {
  review_goal_id integer [pk]
  review_id integer 
  goal_description text
  goal_rating decimal(3,2)
  goal_comments text
}

Table review_competencies {
  review_competency_id integer [pk]
  review_id integer 
  competency_name varchar
  competency_rating decimal(3,2)
  competency_comments text
}

Table review_feedback {
  review_feedback_id integer [pk]
  review_id integer 
  feedback_provider_id integer 
  relationship varchar // e.g., "Peer", "Direct Report"
  feedback_text text
} 

/////////////////////////////////////////////////////////
// EMPLOYEE PERFORMANCE RELATIONSHIPS
/////////////////////////////////////////////////////////

Ref: employee_review.employee_id > employees.employee_id
Ref: employee_review.reviewer_id > employees.employee_id
Ref: employee_review.review_cycle_id > review_cycles.review_cycle_id

Ref: review_goals.review_id > employee_review.review_id
Ref: review_competencies.review_id > employee_review.review_id
Ref: review_feedback.review_id > employee_review.review_id
Ref: review_feedback.feedback_provider_id > employees.employee_id

/////////////////////////////////////////////////////////
// GLOBAL RELATIONSHIPS
/////////////////////////////////////////////////////////

Ref: time_off_requests.employee_id > employees.employee_id
Ref: time_off_accruals.employee_id > employees.employee_id
Ref: roles.department_id > departments.department_id
Ref: roles.parent_role_id > roles.role_id
Ref: roles.job_family_id > job_families.job_family_id
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
  pulse_date date // typically captured automatically (e.g., CURRENT_DATE)
  mood_score integer // 1–5 scale (1 = very low, 5 = very high)
  comment text // optional freeform feedback
  created_at datetime
}

/////////////////////////////////////////////////////////
// RELATIONSHIPS
/////////////////////////////////////////////////////////

Ref: employee_pulse.employee_id > employees.employee_id


/////////////////////////////////////////////////////////
// RECRUITING / TALENT ACQUISITION
/////////////////////////////////////////////////////////

// Job postings / requisitions
Table job_postings {
  job_posting_id integer pk
  title varchar
  department_id integer // fk to departments
  role_id integer // fk to roles (target role)
  hiring_manager_id integer // fk to employees
  location varchar
  employment_type varchar // Full-time, Part-time, Contract
  description text
  requirements text
  salary_range_min decimal(10,2)
  salary_range_max decimal(10,2)
  currency varchar
  status varchar // Draft, Open, Closed, On Hold
  date_posted date
  date_closed date
  created_at timestamp
  updated_at timestamp
}

// Candidates (people applying for jobs)
Table candidates {
  candidate_id integer pk
  first_name varchar
  last_name varchar
  email varchar
  phone varchar
  resume_url varchar
  linkedin_profile varchar
  referred_by integer // fk to employees (employee referral)
  current_company varchar
  notes text
  created_at timestamp
  updated_at timestamp
}

// Applications — join between candidates and job postings
Table applications {
  application_id integer pk
  candidate_id integer // fk to candidates
  job_posting_id integer // fk to job_postings
  source varchar // e.g., LinkedIn, Referral, Company Site
  status varchar // e.g., Applied, Screening, Interview, Offer, Hired, Rejected
  applied_date date
  last_updated timestamp
}

// Interviews / assessments
Table interviews {
  interview_id integer pk
  application_id integer // fk to applications
  interviewer_id integer // fk to employees
  interview_date datetime
  interview_type varchar // e.g., Phone, Onsite, Technical, HR
  feedback text
  rating integer // 1–5
  decision varchar // Move Forward, Hold, Reject
  created_at timestamp
  updated_at timestamp
}

// Job offers
Table job_offers {
  offer_id integer pk
  application_id integer // fk to applications
  offered_role_id integer // fk to roles
  offered_salary decimal(10,2)
  offered_bonus decimal(10,2)
  start_date date
  offer_status varchar // Draft, Sent, Accepted, Declined, Withdrawn
  sent_date date
  accepted_date date
  created_at timestamp
  updated_at timestamp
}


// RELATIONSHIPS
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