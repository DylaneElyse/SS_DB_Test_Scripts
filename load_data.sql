-- Active: 1749478571723@@127.0.0.1@5432@ss_test_db@public
INSERT INTO ss_roles (role_id, role_name) VALUES
(1, 'Executive Director'),
(2, 'Administrator'),
(3, 'Chief of Competition'),
(4, 'Technical Director'),
(5, 'Head Judge'),
(6, 'Volunteer'),
(7, 'Coach')
ON CONFLICT (role_id) DO NOTHING;

INSERT INTO ss_users(user_id, first_name, last_name, email, role_id, auth_provider_user_id) VALUES
  (1, 'Ryan', 'Howie', 'ryan.howie@edu.sait.ca', 2, 'user_2vkK4uWkGElV6eB1G3vULdHHJJY'),
  (2, 'Rodrigo', 'Rangel', 'rodrigo.alvesrangel@edu.sait.ca', 2, 'user_2wmwgrzZ0MXGgRsQwdkSCOwb7pV'),
  (3, 'Chris', 'Findlay',	'christopher.findlay@edu.sait.ca', 2, 'user_2wmwpP5GO0oTcQbzR6pJzvI8HQf'),
  (4,	'Hammad', 'Mahmood', 'hammad.mahmood@edu.sait.ca', 2, 'user_2wmwtt0HWdhWiAWvMIcl12h0ynJ'),
  (5, 'Anthony', 'Azimi', 'anthony.azimi@sait.ca', 2, 'user_2xSyx0DjSJiWYJkLcTPLxzNNgwP')
ON CONFLICT DO NOTHING;

INSERT INTO ss_disciplines (discipline_id, category_name, subcategory_name, discipline_name) VALUES
-- Freestyle
('FREE_BA_SBD', 'Freestyle', 'Big Air', 'Snowboard'),
('FREE_BA_SKI', 'Freestyle', 'Big Air', 'Ski'),
('FREE_HP_SBD', 'Freestyle', 'Halfpipe', 'Snowboard'),
('FREE_HP_SKI', 'Freestyle', 'Halfpipe', 'Ski'),
('FREE_SS_SBD', 'Freestyle', 'Slopestyle', 'Snowboard'),
('FREE_SS_SKI', 'Freestyle', 'Slopestyle', 'Ski'),
('FREE_MOG_SKI', 'Freestyle', 'Moguls', 'Ski'),
-- Alpine
('ALP_DH_SKI', 'Alpine', 'Downhill', 'Ski'),
('ALP_SG_SKI', 'Alpine', 'Super-G', 'Ski'),
('ALP_GS_SKI', 'Alpine', 'Giant Slalom', 'Ski'),
('ALP_SL_SKI', 'Alpine', 'Slalom', 'Ski'),
('ALP_SBX_SBD', 'Alpine', 'Snowboard Cross', 'Snowboard'),
('ALP_SKX_SKI', 'Alpine', 'Ski Cross', 'Ski'),
-- Nordic
('NORD_SP_SKI', 'Nordic', 'Sprint', 'Ski'),
('NORD_DIST_SKI', 'Nordic', 'Distance', 'Ski'),
('NORD_CP_SKI', 'Nordic', 'Combined Pursuit', 'Ski'),
('NORD_JUMP_SKI', 'Nordic', 'Ski Jumping', 'Ski'),
-- Other
('SNOW_PS_SBD', 'Snowboard', 'Parallel Slalom', 'Snowboard'),
('SNOW_PGS_SBD', 'Snowboard', 'Parallel Giant Slalom', 'Snowboard'),
('FREESKI_BX_SKI', 'Freeski', 'Big Air', 'Ski')
ON CONFLICT (discipline_id) DO NOTHING;

INSERT INTO ss_division(division_id, division_name) VALUES
  (1, 'Male'),
  (2, 'Female'),
  (3, 'Men'),
  (4, 'Women')
ON CONFLICT DO NOTHING;

-- INSERT INTO ss_events (name, start_date, end_date, location, discipline_id, status) VALUES
-- ('SBX Provincial Grassroots', '2025-01-25', '2025-01-26', 'Sunshine Village', 'ALP_SBX_SBD', 'COMPLETE'),
-- ('ASA Provincial Series', '2025-01-31', '2025-02-02', 'Winsport', 'FREE_HP_SBD', 'COMPLETE'),
-- ('ASA Provincial Series', '2025-01-31', '2025-02-02', 'Winsport', 'FREE_SS_SBD', 'COMPLETE'),
-- ('Air Nation - Sr Nationals', '2025-04-25', '2025-04-28', 'Winsport', 'FREE_HP_SKI', 'UPCOMING'),
-- ('Spring Provincials', '2025-05-02', '2025-05-04', 'Winsport', 'FREE_SS_SKI', 'UPCOMING'),
-- ('ASA Provincial Series', '2025-05-09', '2025-05-11', 'Winsport', 'FREE_SS_SBD', 'UPCOMING')
-- ON CONFLICT (name, start_date, end_date) DO NOTHING;

INSERT INTO ss_athletes (athlete_id, last_name, first_name, dob, gender) VALUES
  (27, 'Smith', 'John', '2000-01-01', 'male'),
  (28, 'Doe', 'Jane', '2001-01-01', 'female'),
  (29, 'Johnson', 'Mike', '2002-01-01', 'male'),
  (30, 'Williams', 'Sarah', '2003-01-01', 'female'),
  (31, 'Brown', 'Chris', '2004-01-01', 'male')
ON CONFLICT (athlete_id) DO NOTHING;

INSERT INTO ss_events(event_id, name, start_date, end_date, location, discipline_id, status) VALUES
  (7, 'Winter Gravity Games - Snowboard Half-Pipe', '2025-04-18', '2025-04-20', 'Winsport', 'FREE_HP_SBD', 'Scheduled'),
  (8, 'Test', '2025-04-16', '2025-04-20', 'Calgary', 'NORD_JUMP_SKI', 'Scheduled'),
  (9, 'Test (past)', '2025-04-08', '2025-04-10', 'Calgary', 'FREE_HP_SBD', 'Scheduled')
ON CONFLICT DO NOTHING;

INSERT INTO ss_event_divisions(event_id, division_id, num_rounds) VALUES
  (7, 3, 2),
  (7, 4, 3),
  (8, 1, 3),
  (8, 3, 2),
  (9, 2, 1)
ON CONFLICT DO NOTHING;

INSERT INTO ss_event_judges(event_id, personnel_id, header, name) VALUES
  (7,	'123',	'Judge 1',	'First1 Last1'),
  (8,	'828',	'Judge 2',	'First2 Last2'),
  (9,	'281',	'Judge 3', null),	
  (9,	'292',	'Judge 1',	'John Doe'),
  (9,	'882',	'Judge 2',	'Anna Bell')
ON CONFLICT DO NOTHING;

INSERT INTO ss_event_registrations(event_id, athlete_id, division_id) VALUES 
  (7,	27, 3),
  (7,	28,	3),
  (7,	29,	3),
  (7,	30,	3),
  (7,	31,	3)
  ON CONFLICT (event_id,division_id,athlete_id) DO NOTHING;
