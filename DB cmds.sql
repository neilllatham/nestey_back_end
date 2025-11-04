DB commands
\dt -- show all tables in the DB
\dt *.* -- show the schema
\d table_name -- shows columns in the table_name
SELECT COUNT(*) FROM table_name -- counts number of rows in table_name
\d+ -- employees show all constraints on a table
\conninf or \c -- show current connection info

SELECT column1, column2
FROM table_name;

-- Join example two tables
SELECT 
  a.column_name,
  b.column_name
FROM table_a a
JOIN table_b b 
  ON a.shared_column = b.shared_column;

  -- Join example three tables
  SELECT 
  a.column_name,
  b.column_name,
  c.column_name
FROM table_a a
JOIN table_b b 
  ON a.shared_column = b.shared_column
JOIN table_c c 
  ON b.another_shared_column = c.another_shared_column;

SELECT
e.employee_id,
e.first_name,
e.last_name,
d.department_name,
f.function_name,
r.role_name,
e.hire_date,
e.base_salary,
e.target_bonus,
e.commission_target

FROM employees e
JOIN departments d
    ON e.department_id = d.department_id
JOIN functions f 
    ON f.function_id = d.function_id 
JOIN roles r 
    ON r.role_id = e.role_id
LIMIT 30;

SELECT *
    --e.full_name,
    --e.job_title,
    --e.home_address,
    --bp.effective_date,
    --bp.expiry_date

FROM employees e
JOIN employee_benefits eb
    ON e.employee_id = eb.employee_id
JOIN benefit_plan bp 
    ON eb.benefit_plan_id = bp.benefit_plan_id
LIMIT 30;
