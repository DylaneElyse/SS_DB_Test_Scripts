-- Active: 1749478571723@@127.0.0.1@5432@ss_test_db@public
SELECT * FROM ss_roles;
SELECT * FROM ss_users;
SELECT * FROM ss_disciplines;
SELECT * FROM ss_division;
SELECT * FROM ss_athletes;
SELECT * FROM ss_events;
SELECT * FROM ss_event_divisions;
SELECT * FROM ss_round_details;
SELECT * FROM ss_heat_details;
SELECT * FROM ss_event_registrations;
SELECT * FROM ss_heat_results;
SELECT * FROM ss_run_results;
SELECT * FROM ss_event_judges;
SELECT * FROM ss_run_scores;
SELECT * FROM ss_event_personnel;


DELETE FROM ss_roles;
DELETE FROM ss_users;
DELETE FROM ss_disciplines;
DELETE FROM ss_division;
DELETE FROM ss_athletes;
DELETE FROM ss_events;
DELETE FROM ss_event_divisions;
DELETE FROM ss_round_details;
DELETE FROM ss_heat_details;
DELETE FROM ss_event_registrations;
DELETE FROM ss_heat_results;
DELETE FROM ss_run_results;
DELETE FROM ss_event_judges;
DELETE FROM ss_run_scores;
DELETE FROM ss_event_personnel;


describe ss_event_registrations;


INSERT INTO ss_heat_details (heat_num, num_runs, round_id)
VALUES (2, 3, 1);

SELECT * FROM ss_heat_results
WHERE round_heat_id = 23;

INSERT INTO ss_athletes (first_name, last_name, dob, gender)
VALUES ('John', 'Doe', '1990-01-01', 'M');