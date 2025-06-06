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

INSERT INTO ss_events(event_id, name, start_date, end_date, location, discipline_id, status) VALUES
  (7, 'Winter Gravity Games - Snowboard Half-Pipe', '2025-04-18', '2025-04-20', 'Winsport', 'FREE_HP_SBD', 'Scheduled'),
  (8, 'Test', '2025-04-16', '2025-04-20', 'Calgary', 'NORD_JUMP_SKI', 'Scheduled'),
  (9, 'Test (past)', '2025-04-08', '2025-04-10', 'Calgary', 'FREE_HP_SBD', 'Scheduled')
  
ON CONFLICT DO NOTHING;

INSERT INTO ss_event_registrations(event_id, athlete_id, division_id) VALUES 
  (7,	27, 3),
  (7,	28,	3),
  (7,	29,	3),
  (7,	30,	3),
  (7,	31,	3),
  (8,	27,	3),
  (8,	28, 3),
  (8,	29,	3),
  (8,	30,	3),
  (9,	35,	2),
  (9,	36,	2),
  (9,	37,	2),
  (9,	38,	2),
  (9,	39,	2)
  
ON CONFLICT DO NOTHING;

INSERT INTO ss_division(division_id, division_name) VALUES
  (1, 'Male'),
  (2, 'Female'),
  (3, 'Men'),
  (4, 'Women')
  
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


