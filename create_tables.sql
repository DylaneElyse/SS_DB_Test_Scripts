DROP TABLE IF EXISTS ss_run_scores CASCADE;
DROP TABLE IF EXISTS ss_heat_judges CASCADE;
DROP TABLE IF EXISTS ss_event_judges CASCADE;
DROP TABLE IF EXISTS ss_run_results CASCADE;
DROP TABLE IF EXISTS ss_heat_results CASCADE;
DROP TABLE IF EXISTS ss_event_registrations CASCADE;
DROP TABLE IF EXISTS ss_heat_details CASCADE;
DROP TABLE IF EXISTS ss_round_details CASCADE;
DROP TABLE IF EXISTS ss_event_divisions CASCADE;
DROP TABLE IF EXISTS ss_event_personnel CASCADE;
DROP TABLE IF EXISTS ss_users CASCADE;
DROP TABLE IF EXISTS ss_roles CASCADE;
DROP TABLE IF EXISTS ss_events CASCADE;
DROP TABLE IF EXISTS ss_disciplines CASCADE;
DROP TABLE IF EXISTS ss_division CASCADE;
DROP TABLE IF EXISTS ss_athletes CASCADE;

-- 1. Roles Table
CREATE TABLE ss_roles (
    role_id integer PRIMARY KEY, 
    role_name VARCHAR(100) NOT NULL
);

-- 2. Users Table
CREATE TABLE ss_users (
    user_id SERIAL PRIMARY KEY, 
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL, 
    role_id integer NOT NULL,
    auth_provider_user_id VARCHAR(100) NOT NULL,
    FOREIGN KEY (role_id) REFERENCES ss_roles(role_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    UNIQUE (email)
);

-- 3. Disciplines Table
CREATE TABLE ss_disciplines (
    discipline_id VARCHAR(100) PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    subcategory_name VARCHAR(100) NOT NULL,
    discipline_name VARCHAR(100) NOT NULL
);

-- 4. Division Table
CREATE TABLE ss_division (
    division_id SERIAL PRIMARY KEY,
    division_name VARCHAR(100) NOT NULL
);

-- 5. Athletes Table
CREATE TABLE ss_athletes (
    athlete_id SERIAL PRIMARY KEY, 
    last_name VARCHAR(255) NOT NULL,
    first_name VARCHAR(255) NOT NULL,
    dob DATE NOT NULL,
    gender VARCHAR(10) NOT NULL, 
    nationality VARCHAR(3),
    stance VARCHAR(20), 
    fis_num integer UNIQUE,
    fis_hp_points DECIMAL(10, 2),
    fis_ss_points DECIMAL(10, 2),
    fis_ba_points DECIMAL(10,2),
    wspl_points DECIMAL(10, 2)
);

-- 6. Events Table
CREATE TABLE ss_events (
    event_id SERIAL PRIMARY KEY, 
    name VARCHAR(255) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    location VARCHAR(255) NOT NULL,
    discipline_id VARCHAR(50) NOT NULL, 
    status VARCHAR(50) NOT NULL DEFAULT 'Upcoming', 
    FOREIGN KEY (discipline_id) REFERENCES ss_disciplines(discipline_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- 7. Event Divisions
CREATE TABLE ss_event_divisions (
    event_id integer NOT NULL,
    division_id integer NOT NULL,
    num_rounds integer NOT NULL DEFAULT 1,
    PRIMARY KEY (event_id, division_id),
    FOREIGN KEY (event_id) REFERENCES ss_events(event_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (division_id) REFERENCES ss_division(division_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- 8. Round Details Table
CREATE TABLE ss_round_details (
    event_id integer NOT NULL,
    division_id integer NOT NULL,
    round_id SERIAL NOT NULL UNIQUE, 
    round_num integer NOT NULL,
    round_name VARCHAR(100) NOT NULL DEFAULT 'Final',
    num_heats integer NOT NULL DEFAULT 1, 
    round_sequence integer,
    schedule_sequence integer,
    num_athletes integer NOT NULL DEFAULT 0,
    PRIMARY KEY (event_id, division_id, round_id),
    FOREIGN KEY (event_id, division_id) REFERENCES ss_event_divisions(event_id, division_id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- 9. Heat Details
CREATE TABLE ss_heat_details (
    round_heat_id SERIAL PRIMARY KEY,
    heat_num integer NOT NULL,
    num_runs integer NOT NULL DEFAULT 3,
    round_id integer NOT NULL,
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    schedule_sequence integer,
    FOREIGN KEY (round_id) REFERENCES ss_round_details(round_id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- 10. Event Registrations
CREATE TABLE ss_event_registrations (
    event_id integer NOT NULL,
    division_id integer NOT NULL,
    athlete_id integer NOT NULL,
    bib_num integer,
    PRIMARY KEY (event_id, division_id, athlete_id),
    UNIQUE (event_id, division_id, bib_num),
    FOREIGN KEY (event_id, division_id) REFERENCES ss_event_divisions(event_id, division_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (athlete_id) REFERENCES ss_athletes(athlete_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- 11. Heat Results
CREATE TABLE ss_heat_results (
    round_heat_id integer NOT NULL,
    event_id integer NOT NULL,  
    division_id integer NOT NULL,   
    athlete_id integer NOT NULL,
    best DECIMAL(10, 2),
    seeding DECIMAL,
    PRIMARY KEY (round_heat_id, event_id, division_id, athlete_id), 
    UNIQUE (round_heat_id, athlete_id),
    FOREIGN KEY (round_heat_id) REFERENCES ss_heat_details(round_heat_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (event_id, division_id, athlete_id) REFERENCES ss_event_registrations(event_id, division_id, athlete_id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- 12. Run Results
CREATE TABLE ss_run_results (
    run_result_id SERIAL PRIMARY KEY,  
    round_heat_id integer NOT NULL,
    event_id integer NOT NULL,         
    division_id integer NOT NULL,      
    athlete_id integer NOT NULL,
    run_num integer NOT NULL,
    calc_score DECIMAL(10, 2),
    dn_flag VARCHAR(3),
    UNIQUE (run_result_id, round_heat_id), 
    UNIQUE (round_heat_id, event_id, division_id, athlete_id, run_num),
    FOREIGN KEY (round_heat_id, event_id, division_id, athlete_id)
        REFERENCES ss_heat_results(round_heat_id, event_id, division_id, athlete_id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- 13. Event Judges 
CREATE TABLE ss_event_judges (
    personnel_id SERIAL PRIMARY KEY,
    event_id integer NOT NULL,
    header VARCHAR(50) NOT NULL,
    name VARCHAR(100),
    passcode CHAR(4) NOT NULL,
    UNIQUE (passcode),
    FOREIGN KEY (event_id) REFERENCES ss_events(event_id) ON DELETE CASCADE ON UPDATE CASCADE 
);

-- 14. Heat Judges
CREATE TABLE ss_heat_judges (
    round_heat_id integer NOT NULL,
    personnel_id integer NOT NULL,
    PRIMARY KEY (round_heat_id, personnel_id),
    FOREIGN KEY (round_heat_id) REFERENCES ss_heat_details(round_heat_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (personnel_id) REFERENCES ss_event_judges(personnel_id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- 15. Run Scores
CREATE TABLE ss_run_scores (
    run_result_id integer NOT NULL,
    personnel_id integer NOT NULL,
    round_heat_id integer NOT NULL,
    score DECIMAL(10, 2),
    PRIMARY KEY (run_result_id, personnel_id),
    FOREIGN KEY (run_result_id, round_heat_id) 
        REFERENCES ss_run_results(run_result_id, round_heat_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (round_heat_id, personnel_id) 
        REFERENCES ss_heat_judges(round_heat_id, personnel_id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- 16. Event Personnel
CREATE TABLE ss_event_personnel (
    event_id integer NOT NULL,
    user_id integer NOT NULL,
    event_role VARCHAR(50),
    PRIMARY KEY (event_id, user_id),
    FOREIGN KEY (user_id) REFERENCES ss_users(user_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (event_id) REFERENCES ss_events(event_id) ON DELETE CASCADE ON UPDATE CASCADE
);



-- DROP TABLE IF EXISTS ss_run_scores CASCADE;
-- DROP TABLE IF EXISTS ss_heat_judges CASCADE;
-- DROP TABLE IF EXISTS ss_event_judges CASCADE;
-- DROP TABLE IF EXISTS ss_run_results CASCADE;
-- DROP TABLE IF EXISTS ss_heat_results CASCADE;
-- DROP TABLE IF EXISTS ss_event_registrations CASCADE;
-- DROP TABLE IF EXISTS ss_heat_details CASCADE;
-- DROP TABLE IF EXISTS ss_round_details CASCADE;
-- DROP TABLE IF EXISTS ss_event_divisions CASCADE;
-- DROP TABLE IF EXISTS ss_event_personnel CASCADE;
-- DROP TABLE IF EXISTS ss_users CASCADE;
-- DROP TABLE IF EXISTS ss_roles CASCADE;
-- DROP TABLE IF EXISTS ss_events CASCADE;
-- DROP TABLE IF EXISTS ss_disciplines CASCADE;
-- DROP TABLE IF EXISTS ss_division CASCADE;
-- DROP TABLE IF EXISTS ss_athletes CASCADE;

-- -- 1. Roles Table
-- CREATE TABLE ss_roles (
--     role_id integer PRIMARY KEY, 
--     role_name VARCHAR(100) NOT NULL
-- );

-- -- 2. Users Table
-- CREATE TABLE ss_users (
--     user_id SERIAL PRIMARY KEY, 
--     first_name VARCHAR(100) NOT NULL,
--     last_name VARCHAR(100) NOT NULL,
--     email VARCHAR(100) UNIQUE NOT NULL, 
--     role_id integer NOT NULL,
--     auth_provider_user_id VARCHAR(100) NOT NULL,
--     FOREIGN KEY (role_id) REFERENCES ss_roles(role_id) ON DELETE RESTRICT ON UPDATE CASCADE,
--     UNIQUE (email)
-- );

-- -- 3. Disciplines Table
-- CREATE TABLE ss_disciplines (
--     discipline_id VARCHAR(100) PRIMARY KEY,
--     category_name VARCHAR(100) NOT NULL,
--     subcategory_name VARCHAR(100) NOT NULL,
--     discipline_name VARCHAR(100) NOT NULL
-- );

-- -- 4. Division Table
-- CREATE TABLE ss_division (
--     division_id SERIAL PRIMARY KEY,
--     division_name VARCHAR(100) NOT NULL
-- );

-- -- 5. Athletes Table
-- CREATE TABLE ss_athletes (
--     athlete_id SERIAL PRIMARY KEY, 
--     last_name VARCHAR(255) NOT NULL,
--     first_name VARCHAR(255) NOT NULL,
--     dob DATE NOT NULL,
--     gender VARCHAR(10) NOT NULL, 
--     nationality VARCHAR(3),
--     stance VARCHAR(20), 
--     fis_num integer UNIQUE,
--     fis_hp_points DECIMAL(10, 2),
--     fis_ss_points DECIMAL(10, 2),
--     fis_ba_points DECIMAL(10,2),
--     wspl_points DECIMAL(10, 2)
-- );

-- -- 6. Events Table
-- CREATE TABLE ss_events (
--     event_id SERIAL PRIMARY KEY, 
--     name VARCHAR(255) NOT NULL,
--     start_date DATE NOT NULL,
--     end_date DATE NOT NULL,
--     location VARCHAR(255) NOT NULL,
--     discipline_id VARCHAR(50) NOT NULL, 
--     status VARCHAR(50) NOT NULL DEFAULT 'Upcoming', 
--     FOREIGN KEY (discipline_id) REFERENCES ss_disciplines(discipline_id) ON DELETE RESTRICT ON UPDATE CASCADE
-- );

-- -- 7. Event Divisions
-- CREATE TABLE ss_event_divisions (
--     event_id integer NOT NULL,
--     division_id integer NOT NULL,
--     num_rounds integer NOT NULL DEFAULT 1,
--     PRIMARY KEY (event_id, division_id),
--     FOREIGN KEY (event_id) REFERENCES ss_events(event_id) ON DELETE CASCADE ON UPDATE CASCADE,
--     FOREIGN KEY (division_id) REFERENCES ss_division(division_id) ON DELETE RESTRICT ON UPDATE CASCADE
-- );

-- -- 8. Round Details Table
-- CREATE TABLE ss_round_details (
--     event_id integer NOT NULL,
--     division_id integer NOT NULL,
--     round_id SERIAL NOT NULL UNIQUE, 
--     round_num integer NOT NULL,
--     round_name VARCHAR(100) NOT NULL DEFAULT 'Final',
--     num_heats integer NOT NULL DEFAULT 1, 
--     round_sequence integer,
--     schedule_sequence integer,
--     num_athletes integer NOT NULL DEFAULT 0,
--     PRIMARY KEY (event_id, division_id, round_id),
--     FOREIGN KEY (event_id, division_id) REFERENCES ss_event_divisions(event_id, division_id) ON DELETE CASCADE ON UPDATE CASCADE
-- );

-- -- 9. Heat Details
-- CREATE TABLE ss_heat_details (
--     round_heat_id SERIAL PRIMARY KEY,
--     heat_num integer NOT NULL,
--     num_runs integer NOT NULL DEFAULT 3,
--     round_id integer NOT NULL,
--     start_time TIMESTAMP,
--     end_time TIMESTAMP,
--     schedule_sequence integer,
--     FOREIGN KEY (round_id) REFERENCES ss_round_details(round_id) ON DELETE CASCADE ON UPDATE CASCADE
-- );

-- -- 10. Event Registrations
-- CREATE TABLE ss_event_registrations (
--     event_id integer NOT NULL,
--     division_id integer NOT NULL,
--     athlete_id integer NOT NULL,
--     bib_num integer,
--     PRIMARY KEY (event_id, division_id, athlete_id),
--     UNIQUE (event_id, division_id, bib_num),
--     FOREIGN KEY (event_id, division_id) REFERENCES ss_event_divisions(event_id, division_id) ON DELETE CASCADE ON UPDATE CASCADE,
--     FOREIGN KEY (athlete_id) REFERENCES ss_athletes(athlete_id) ON DELETE RESTRICT ON UPDATE CASCADE
-- );

-- -- 11. Heat Results
-- CREATE TABLE ss_heat_results (
--     round_heat_id integer NOT NULL,
--     event_id integer NOT NULL,  
--     division_id integer NOT NULL,   
--     athlete_id integer NOT NULL,
--     best DECIMAL(10, 2),
--     seeding DECIMAL,
--     PRIMARY KEY (round_heat_id, event_id, division_id, athlete_id), 
--     UNIQUE (round_heat_id, athlete_id),
--     FOREIGN KEY (round_heat_id) REFERENCES ss_heat_details(round_heat_id) ON DELETE CASCADE ON UPDATE CASCADE,
--     FOREIGN KEY (event_id, division_id, athlete_id) REFERENCES ss_event_registrations(event_id, division_id, athlete_id) ON DELETE CASCADE ON UPDATE CASCADE
-- );

-- -- 12. Run Results
-- CREATE TABLE ss_run_results (
--     run_result_id SERIAL PRIMARY KEY,  
--     round_heat_id integer NOT NULL,
--     event_id integer NOT NULL,         
--     division_id integer NOT NULL,      
--     athlete_id integer NOT NULL,
--     run_num integer NOT NULL,
--     calc_score DECIMAL(10, 2),
--     dn_flag VARCHAR(3),
--     UNIQUE (run_result_id, round_heat_id), 
--     UNIQUE (round_heat_id, event_id, division_id, athlete_id, run_num),
--     FOREIGN KEY (round_heat_id, event_id, division_id, athlete_id)
--         REFERENCES ss_heat_results(round_heat_id, event_id, division_id, athlete_id) ON DELETE CASCADE ON UPDATE CASCADE
-- );

-- -- 13. Event Judges 
-- CREATE TABLE ss_event_judges (
--     personnel_id SERIAL PRIMARY KEY,
--     event_id integer NOT NULL,
--     header VARCHAR(50) NOT NULL,
--     name VARCHAR(100),
--     passcode CHAR(4) NOT NULL,
--     UNIQUE (passcode),
--     FOREIGN KEY (event_id) REFERENCES ss_events(event_id) ON DELETE CASCADE ON UPDATE CASCADE 
-- );

-- -- 14. Heat Judges
-- CREATE TABLE ss_heat_judges (
--     round_heat_id integer NOT NULL,
--     personnel_id integer NOT NULL,
--     PRIMARY KEY (round_heat_id, personnel_id),
--     FOREIGN KEY (round_heat_id) REFERENCES ss_heat_details(round_heat_id) ON DELETE CASCADE ON UPDATE CASCADE,
--     FOREIGN KEY (personnel_id) REFERENCES ss_event_judges(personnel_id) ON DELETE CASCADE ON UPDATE CASCADE
-- );

-- -- 15. Run Scores
-- CREATE TABLE ss_run_scores (
--     run_result_id integer NOT NULL,
--     personnel_id integer NOT NULL,
--     round_heat_id integer NOT NULL,
--     score DECIMAL(10, 2),
--     PRIMARY KEY (run_result_id, personnel_id),
--     FOREIGN KEY (run_result_id, round_heat_id) 
--         REFERENCES ss_run_results(run_result_id, round_heat_id) ON DELETE CASCADE ON UPDATE CASCADE,
--     FOREIGN KEY (round_heat_id, personnel_id) 
--         REFERENCES ss_heat_judges(round_heat_id, personnel_id) ON DELETE CASCADE ON UPDATE CASCADE
-- );

-- -- 16. Event Personnel
-- CREATE TABLE ss_event_personnel (
--     event_id integer NOT NULL,
--     user_id integer NOT NULL,
--     event_role VARCHAR(50),
--     PRIMARY KEY (event_id, user_id),
--     FOREIGN KEY (user_id) REFERENCES ss_users(user_id) ON DELETE RESTRICT ON UPDATE CASCADE,
--     FOREIGN KEY (event_id) REFERENCES ss_events(event_id) ON DELETE CASCADE ON UPDATE CASCADE
-- );