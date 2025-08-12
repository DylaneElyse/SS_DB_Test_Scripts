-- Insert the athletes you want to use for testing
INSERT INTO ss_athletes (athlete_id, last_name, first_name, dob, nationality, stance, gender, fis_num, fis_hp_points, fis_ss_points, fis_ba_points) VALUES
(1, 'Adams', 'Kaitlyn', '2005-09-16', 'USA', 'Regular', 'Female', 9535573, NULL, 111.70, 157.30),
(2, 'Adib-Samii', 'Alejandro', '2008-08-31', 'USA', 'Regular', 'Male', 9531806, NULL, 22.65, 42.30),
(3, 'Alba', 'Sonora', '2006-07-16', 'USA', 'Goofy', 'Female', 9535609, 369.35, NULL, 37.50),
(4, 'Avallone', 'Noah', '2007-05-16', 'USA', 'Goofy', 'Male', 9531687, 127.70, NULL, 48.85),
(7, 'Bezushko', 'Zachary', '2008-01-06', 'CAN', 'Goofy', 'Male', 9101342, 22.50, 12.25, 41.75),
(8, 'Boday', 'Gabriella', '2010-06-12', 'USA', 'Regular', 'Female', 9535746, 6.51, 19.60, 110.00),
(10, 'Brayer', 'Katie', '2003-12-11', 'CAN', 'Regular', 'Female', 9105528, NULL, 2.81, 43.65),
(11, 'Brienza', 'Giada', '2010-11-03', 'USA', 'Goofy', 'Female', 9535749, 59.10, 70.40, 108.85),
(13, 'Buffey', 'William', '2002-07-16', 'CAN', 'Goofy', 'Male', 9100947, NULL, 64.20, 141.20),
(14, 'Bullock-Womble', 'Fynn', '2005-02-03', 'USA', 'Regular', 'Male', 9531486, 0.15, 174.35, 334.05),
(15, 'Cantelon', 'Jonah', '2002-12-09', 'CAN', 'Goofy', 'Male', 9101215, NULL, 45.25, 19.90),
(19, 'Cowan', 'Lola', '2005-06-06', 'CHI', 'Goofy', 'Female', 9535575, 49.60, 1.12, 0.94)
ON CONFLICT (athlete_id) DO NOTHING;

-- Verify athletes were inserted
SELECT 
    athlete_id,
    first_name || ' ' || last_name AS athlete_name,
    gender
FROM ss_athletes 
WHERE athlete_id IN (1, 2, 3, 4, 7, 8, 10, 11, 13, 14, 15, 19)
ORDER BY athlete_id;
