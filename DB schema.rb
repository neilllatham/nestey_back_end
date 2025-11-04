DB schema

// Use DBML to define your database structure
// Docs: https://dbml.dbdiagram.io/docs

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

Table time_off {
  time_off_id pk
  employee_id integer // fk from employees table
  start_date date
  end_date date
  type varchar // PTO, sick leave, FMLA, bereavement
  time_off_amount numeric //starting hours for the year
  time_off_accrued numeric // starting balance + accrued
  time_off_balance numeric // starting balance + accrued - used
  date_created date
  date_updated date
}


Table employee_review {
  employee_review_id pk
  employee_id integer //fk from employees table
  employee_name varchar // pulled in from employee table
  review_year integer
  strategy_id integer // fk from strategy table
  objective varchar
  key_result_target numeric
  key_result_actual numeric
  key_result_pct decimal (1,2)
  date_created date
  date_updated date
}

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
  enrollment_window varchar
  created_at date
  updated_at date
  benefit_plan_id integer

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

Ref: employees.manager_id > employees.employee_id
Ref: employees.department_id > departments.department_id
Ref: departments.function_id > functions.function_id
Ref: employee_benefits.employee_id > employees.employee_id
Ref: employee_benefits.benefit_plan_id > benefit_plan.benefit_plan_id
Ref: benefits_catalog.benefit_plan_id > benefit_plan.benefit_plan_id
Ref: employee_review.employee_id > employees.employee_id
Ref: time_off.employee_id > employees.employee_id
