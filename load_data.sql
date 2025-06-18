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

INSERT INTO ss_athletes (last_name, first_name, dob, gender, nationality, stance, fis_num) VALUES
('Yoshida', 'Kenji', '1998-03-15', 'Male', 'JPN', NULL, '8462011'),
('Müller', 'Lena', '2005-08-22', 'Female', 'DEU', 'Regular', '5198374'),
('Smith', 'Ethan', '1991-11-01', 'Male', 'USA', NULL, '2884096'),
('Tremblay', 'Chloé', '2012-04-30', 'Female', 'CAN', 'Goofy', '7651239'),
('Rossi', 'Matteo', '1987-07-19', 'Male', 'ITA', 'Goofy', '9302755'),
('Kim', 'Ji-hoon', '2008-01-10', 'Male', 'KOR', NULL, '4112980'),
('Dubois', 'Manon', '2001-09-05', 'Female', 'FRA', 'Regular', '6830147'),
('Novak', 'Anja', '2015-12-12', 'Female', 'SVN', NULL, NULL),
('Andersen', 'Elias', '1995-02-28', 'Male', 'NOR', NULL, '1578423'),
('Silva', 'Sofia', '2003-06-18', 'Female', 'BRA', 'Goofy', '3927501'),
('Patel', 'Aarav', '2010-10-25', 'Male', 'IND', 'Regular', NULL),
('Johnson', 'Olivia', '1999-05-14', 'Female', 'USA', NULL, '8765432'),
('García', 'Mateo', '2017-03-08', 'Male', 'ESP', NULL, NULL),
('Schneider', 'Felix', '1989-08-03', 'Male', 'AUT', 'Regular', '4501289'),
('Li', 'Mei', '2006-11-11', 'Female', 'CHN', 'Goofy', '7109824'),
('Williams', 'Noah', '2002-07-29', 'Male', 'GBR', NULL, '5583910'),
('Svensson', 'Astrid', '1993-01-21', 'Female', 'SWE', 'Regular', '2345678'),
('Meyer', 'Leon', '2014-09-15', 'Male', 'CHE', 'Goofy', NULL),
('Brown', 'Isabella', '1997-04-02', 'Female', 'AUS', NULL, '6917345'),
('Ivanov', 'Maxim', '1985-10-17', 'Male', 'RUS', 'Regular', '1122334'),
('Nakamura', 'Yui', '2009-02-09', 'Female', 'JPN', 'Goofy', '8801256'),
('Fischer', 'Jonas', '2000-12-20', 'Male', 'DEU', NULL, '3678901'),
('Wilson', 'Ava', '2018-06-05', 'Female', 'CAN', 'Regular', NULL),
('Conti', 'Lorenzo', '1992-03-28', 'Male', 'ITA', NULL, '9912347'),
('Park', 'Seo-yeon', '2004-08-14', 'Female', 'KOR', 'Goofy', '2759013'),
('Martin', 'Lucas', '1990-11-30', 'Male', 'FRA', 'Regular', '7401826'),
('Horvat', 'Luka', '2011-07-07', 'Male', 'HRV', NULL, NULL),
('Olsen', 'Ingrid', '1988-01-03', 'Female', 'NOR', 'Goofy', '5392081'),
('Costa', 'Gabriel', '2007-05-26', 'Male', 'PRT', 'Regular', '1098765'),
('Singh', 'Priya', '2016-02-18', 'Female', 'IND', NULL, NULL),
('Davis', 'Mason', '1996-09-11', 'Male', 'USA', NULL, '6218734'),
('Rodríguez', 'Valentina', '2001-04-09', 'Female', 'ARG', 'Regular', '4820195'),
('Weber', 'Paul', '2013-10-01', 'Male', 'DEU', 'Goofy', NULL),
('Pichler', 'Anna', '1994-06-24', 'Female', 'AUT', NULL, '3175928'),
('Wang', 'Hao', '1986-12-07', 'Male', 'CHN', 'Regular', '8520369'),
('Taylor', 'Emily', '2003-02-14', 'Female', 'GBR', NULL, '1470258'),
('Gustafsson', 'Oskar', '2010-08-08', 'Male', 'SWE', 'Goofy', NULL),
('Keller', 'Lara', '1998-11-23', 'Female', 'CHE', 'Regular', '9630852'),
('Campbell', 'Jack', '2005-03-17', 'Male', 'NZL', NULL, '2580147'),
('Smirnov', 'Sofia', '2015-01-30', 'Female', 'RUS', NULL, NULL),
('Tanaka', 'Haruto', '1991-07-12', 'Male', 'JPN', 'Goofy', '7019283'),
('Schmidt', 'Marie', '2002-10-04', 'Female', 'DEU', NULL, '5931784'),
('Miller', 'Benjamin', '2012-05-21', 'Male', 'USA', NULL, '6804219'),
('Gagnon', 'Florence', '1997-09-09', 'Female', 'CAN', 'Regular', '3028751'),
('Romano', 'Alessia', '2017-11-06', 'Female', 'ITA', 'Goofy', NULL),
('Choi', 'Min-jun', '1993-02-02', 'Male', 'KOR', NULL, '8194730'),
('Leroy', 'Hugo', '2006-06-28', 'Male', 'FRA', 'Regular', '4371958'),
('Kovačič', 'Nika', '1990-04-13', 'Female', 'SVN', 'Goofy', '6713049'),
('Hansen', 'Sofie', '2004-01-19', 'Female', 'DNK', NULL, '2085617'),
('Pereira', 'Lucas', '1988-08-27', 'Male', 'BRA', NULL, '5169284'),
('Kumar', 'Ishaan', '2014-04-04', 'Male', 'IND', 'Regular', NULL),
('Moore', 'Chloe', '2000-10-31', 'Female', 'USA', NULL, '9431075'),
('Martínez', 'Lucía', '1995-12-15', 'Female', 'ESP', 'Goofy', '1785302'),
('Bauer', 'Tobias', '2008-03-03', 'Male', 'AUT', 'Regular', '7950164'),
('Zhang', 'Wei', '2003-09-29', 'Male', 'CHN', NULL, '3409812'),
('Walker', 'Jessica', '1992-05-07', 'Female', 'GBR', NULL, '6073491'),
('Nilsson', 'Elsa', '2011-11-18', 'Female', 'SWE', 'Goofy', NULL),
('Frei', 'Noah', '1987-02-11', 'Male', 'CHE', 'Regular', '8264017'),
('White', 'William', '2001-08-01', 'Male', 'AUS', NULL, '4197538'),
('Popov', 'Anastasia', '1999-01-25', 'Female', 'RUS', NULL, '7531092'),
('Sato', 'Ren', '2016-07-22', 'Male', 'JPN', 'Goofy', NULL),
('Hoffmann', 'Finn', '1996-04-19', 'Male', 'DEU', NULL, '1975320'),
('Anderson', 'Sophia', '2007-10-13', 'Female', 'USA', 'Regular', '5824601'),
('Roy', 'Olivier', '1989-06-06', 'Male', 'CAN', NULL, '3910748'),
('Ferrari', 'Giulia', '2005-12-02', 'Female', 'ITA', 'Goofy', '8642097'),
('Lee', 'Ha-yoon', '2013-03-23', 'Female', 'KOR', 'Regular', NULL),
('Moreau', 'Léa', '1994-09-17', 'Female', 'FRA', NULL, '6307159'),
('Zupan', 'Filip', '2018-01-09', 'Male', 'SVN', 'Goofy', NULL),
('Jensen', 'Mikkel', '1991-05-05', 'Male', 'DNK', NULL, '4729513'),
('Fernandes', 'Beatriz', '2002-11-27', 'Female', 'PRT', 'Regular', '1856390'),
('Gupta', 'Anaya', '2009-07-03', 'Female', 'IND', NULL, NULL),
('Harris', 'Daniel', '1986-03-14', 'Male', 'USA', 'Regular', '5091827'),
('Gómez', 'Sofía', '2006-08-21', 'Female', 'MEX', NULL, '3748206'),
('Gruber', 'Simon', '2000-01-06', 'Male', 'AUT', 'Goofy', '9173548'),
('Chen', 'Ling', '1997-06-10', 'Female', 'CHN', 'Regular', '2680471'),
('Roberts', 'Thomas', '2012-12-28', 'Male', 'GBR', NULL, '8319560'),
('Lundqvist', 'Filip', '1993-10-22', 'Male', 'SWE', 'Goofy', '4952183'),
('Zimmermann', 'Chloé', '2010-05-16', 'Female', 'CHE', 'Regular', NULL),
('Kelly', 'Liam', '1988-12-31', 'Male', 'IRL', NULL, '7204815'),
('Volkov', 'Ivan', '2004-02-26', 'Male', 'RUS', NULL, '1357902'),
('Ito', 'Sakura', '2015-08-19', 'Female', 'JPN', 'Goofy', NULL),
('Krause', 'Emilia', '1990-11-08', 'Female', 'DEU', NULL, '6821739'),
('Clark', 'Jackson', '2003-07-01', 'Male', 'USA', 'Regular', '5497126'),
('Fortin', 'Mia', '2014-10-27', 'Female', 'CAN', NULL, NULL),
('Ricci', 'Leonardo', '1998-04-23', 'Male', 'ITA', 'Goofy', '2109873'),
('Han', 'Ji-woo', '2001-09-12', 'Female', 'KOR', 'Regular', '7753190'),
('Bernard', 'Nathan', '2011-01-11', 'Male', 'FRA', NULL, NULL),
('Potočnik', 'Eva', '1985-05-29', 'Female', 'SVN', NULL, '3286401'),
('Larsen', 'Freja', '2009-03-05', 'Female', 'NOR', 'Regular', '6910534'),
('Santos', 'Isabella', '1996-10-08', 'Female', 'BRA', 'Goofy', '4078215'),
('Sharma', 'Vivaan', '2007-12-24', 'Male', 'IND', NULL, '8502637'),
('Lewis', 'Harper', '2017-06-14', 'Female', 'USA', 'Regular', NULL),
('Fernández', 'Daniel', '1992-08-31', 'Male', 'ESP', 'Goofy', '1608472'),
('Moser', 'Lena', '2005-02-07', 'Female', 'AUT', NULL, '5274918'),
('Liu', 'Fang', '1999-07-16', 'Female', 'CHN', NULL, '9836104'),
('Evans', 'George', '1987-10-10', 'Male', 'GBR', 'Regular', '2468013'),
('Eriksson', 'Maja', '2008-05-02', 'Female', 'SWE', 'Goofy', '7391546'),
('Baumgartner', 'Elias', '2002-01-28', 'Male', 'CHE', NULL, '6148379'),
('Thompson', 'Olivia', '2013-09-07', 'Female', 'AUS', NULL, NULL),
('Kuznetsov', 'Dmitry', '1995-04-01', 'Male', 'RUS', 'Regular', '8024671')
ON CONFLICT (athlete_id) DO NOTHING;

INSERT INTO ss_events(event_id, name, start_date, end_date, location, discipline_id, status) VALUES
  (7, 'Winter Gravity Games - Snowboard Half-Pipe', '2025-04-18', '2025-04-20', 'Winsport', 'FREE_HP_SBD', 'Scheduled'),
  (8, 'Test', '2025-04-16', '2025-04-20', 'Calgary', 'FREE_HP_SBD', 'Scheduled'),
  (9, 'Test (past)', '2025-04-08', '2025-04-10', 'Calgary', 'FREE_HP_SBD', 'Scheduled'),
  (10, 'SBX Provincial Grassroots', '2025-01-25', '2025-01-26', 'Sunshine Village', 'FREE_SS_SBD', 'COMPLETE'),
  (11, 'ASA Provincial Series', '2025-01-31', '2025-02-02', 'Winsport', 'FREE_HP_SBD', 'COMPLETE'),
  (12, 'ASA Provincial Series', '2025-01-31', '2025-02-02', 'Winsport', 'FREE_SS_SBD', 'COMPLETE'),
  (13, 'Air Nation - Sr Nationals', '2025-04-25', '2025-04-28', 'Winsport', 'FREE_SS_SBD', 'UPCOMING'),
  (14, 'Spring Provincials', '2025-05-02', '2025-05-04', 'Winsport', 'FREE_SS_SKI', 'UPCOMING'),
  (15, 'ASA Provincial Series', '2025-05-09', '2025-05-11', 'Winsport', 'FREE_SS_SBD', 'UPCOMING')
ON CONFLICT DO NOTHING;

INSERT INTO ss_event_divisions(event_id, division_id, num_rounds) VALUES
  (7, 3, 2),
  (7, 4, 3),
  (8, 1, 3),
  (8, 3, 2),
  (9, 2, 1)
ON CONFLICT (event_id, division_id) DO NOTHING;

INSERT INTO ss_event_judges(event_id, personnel_id, header, name) VALUES
  (7,	'123',	'Judge 1',	'First1 Last1'),
  (8,	'828',	'Judge 2',	'First2 Last2'),
  (9,	'281',	'Judge 3', null),	
  (9,	'292',	'Judge 1',	'John Doe'),
  (9,	'882',	'Judge 2',	'Anna Bell')
ON CONFLICT DO NOTHING;

INSERT INTO ss_event_registrations(event_id, athlete_id, division_id) VALUES 
  (7, 27, 3),
  (7, 28, 3),
  (7, 29, 3),
  (7, 30, 3),
  (7, 31, 3)
ON CONFLICT (event_id, division_id, athlete_id) DO NOTHING;
