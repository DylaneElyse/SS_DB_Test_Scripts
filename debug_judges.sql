-- Debug script to check judge assignments for event 303

-- 1. Check if event 303 exists
SELECT 'Event Check' as check_type, event_id, name, status 
FROM ss_events 
WHERE event_id = 303;

-- 2. Check event judges for event 303
SELECT 'Event Judges' as check_type, personnel_id, header, name, passcode
FROM ss_event_judges 
WHERE event_id = 303
ORDER BY personnel_id;

-- 3. Check heat judges assignments for event 303
SELECT 
    'Heat Judge Assignments' as check_type,
    hj.round_heat_id,
    hj.personnel_id,
    ej.header as judge_role,
    ej.name as judge_name,
    rd.round_name,
    hd.heat_num
FROM ss_heat_judges hj
JOIN ss_event_judges ej ON hj.personnel_id = ej.personnel_id
JOIN ss_heat_details hd ON hj.round_heat_id = hd.round_heat_id
JOIN ss_round_details rd ON hd.round_id = rd.round_id
WHERE ej.event_id = 303
ORDER BY rd.round_name, hd.heat_num, ej.header;

-- 4. Check heats for event 303
SELECT 
    'Heat Details' as check_type,
    hd.round_heat_id,
    rd.round_name,
    hd.heat_num,
    rd.division_id,
    d.division_name
FROM ss_heat_details hd
JOIN ss_round_details rd ON hd.round_id = rd.round_id
JOIN ss_division d ON rd.division_id = d.division_id
WHERE rd.event_id = 303
ORDER BY rd.division_id, rd.round_name, hd.heat_num;

-- 5. Check if athletes are registered and in heats
SELECT 
    'Athlete Heat Assignments' as check_type,
    a.first_name || ' ' || a.last_name as athlete_name,
    rd.round_name,
    hd.heat_num,
    hr.seeding
FROM ss_heat_results hr
JOIN ss_athletes a ON hr.athlete_id = a.athlete_id
JOIN ss_heat_details hd ON hr.round_heat_id = hd.round_heat_id
JOIN ss_round_details rd ON hd.round_id = rd.round_id
WHERE hr.event_id = 303
ORDER BY rd.division_id, rd.round_name, hd.heat_num, hr.seeding;
