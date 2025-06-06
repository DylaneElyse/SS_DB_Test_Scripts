CREATE OR REPLACE PROCEDURE reseed_heat(p_round_heat_id INTEGER)
LANGUAGE plpgsql
AS $$

DECLARE
  v_subcategory ss_disciplines.subcategory_name%TYPE;

BEGIN
  SELECT d.subcategory_name INTO v_subcategory
    FROM ss_heat_details hd
    JOIN ss_round_details rd ON hd.round_id = rd.round_id
    JOIN ss_events e ON rd.event_id = e.event_id
    JOIN ss_disciplines d ON e.discipline_id = d.discipline_id
    WHERE hd.round_heat_id = p_round_heat_id
    LIMIT 1; 

  IF (v_subcategory = 'Big Air') THEN
    WITH new_seeding AS (
      SELECT
        hr.athlete_id,
        ROW_NUMBER() OVER (ORDER BY a.fis_ba_points ASC, a.athlete_id ASC) AS new_seed_value
      FROM
        ss_heat_results hr
      JOIN
        ss_athletes a ON hr.athlete_id = a.athlete_id
      WHERE
        hr.round_heat_id = p_round_heat_id
    )
    UPDATE
      ss_heat_results
    SET
      seeding = new_seeding.new_seed_value
    FROM
      new_seeding
    WHERE
      ss_heat_results.athlete_id = new_seeding.athlete_id
      AND ss_heat_results.round_heat_id = p_round_heat_id;

  ELSEIF (v_subcategory = 'Slopestyle') THEN
    WITH new_seeding AS (
      SELECT
        hr.athlete_id,
        ROW_NUMBER() OVER (ORDER BY a.fis_ss_points ASC, a.athlete_id ASC) AS new_seed_value
      FROM
        ss_heat_results hr
      JOIN
        ss_athletes a ON hr.athlete_id = a.athlete_id
      WHERE
        hr.round_heat_id = p_round_heat_id
    )
    UPDATE
      ss_heat_results
    SET
      seeding = new_seeding.new_seed_value
    FROM
      new_seeding
    WHERE
      ss_heat_results.athlete_id = new_seeding.athlete_id
      AND ss_heat_results.round_heat_id = p_round_heat_id;

  ELSEIF (v_subcategory = 'Halfpipe') THEN
      WITH new_seeding AS (
      SELECT
        hr.athlete_id,
        ROW_NUMBER() OVER (ORDER BY a.fis_hp_points ASC, a.athlete_id ASC) AS new_seed_value
      FROM
        ss_heat_results hr
      JOIN
        ss_athletes a ON hr.athlete_id = a.athlete_id
      WHERE
        hr.round_heat_id = p_round_heat_id
    )
    UPDATE
      ss_heat_results
    SET
      seeding = new_seeding.new_seed_value
    FROM
      new_seeding
    WHERE
      ss_heat_results.athlete_id = new_seeding.athlete_id
      AND ss_heat_results.round_heat_id = p_round_heat_id;

END;
$$;





-- CREATE TYPE heat_seeding_obj AS OBJECT (
--     athlete_id ss_athlete.athlete_id%TYPE,
--     round_heat_id ss_heat_details.round_heat_id%TYPE,
--     seeding ss_heat_results.seeding%TYPE
--     fis_points ss_athlete.fis_hp_points%TYPE
-- );

-- CREATE OR REPLACE FUNCTION adjust_seeding_function(
--     p_round_heat_id ss_heat_details.round_heat_id%TYPE,
--     p_discipline_name ss_disciplines.discipline_name%TYPE
-- )
-- RETURNS TABLE (
--     athlete_id ss_athlete.athlete_id%TYPE,
--     round_heat_id ss_heat_details.round_heat_id%TYPE,
--     seeding ss_heat_results.seeding%TYPE,
--     fis_points ss_athlete.fis_hp_points%TYPE
-- ) AS $$

-- DECLARE
--     v_subcategory ss_disciplines.subcategory_name%TYPE;

-- BEGIN
--     SELECT d.subcategory_name INTO v_subcategory
--         FROM ss_heat_details hd
--         JOIN ss_round_details rd ON hd.round_id = rd.round_id
--         JOIN ss_events e ON rd.event_id = e.event_id
--         JOIN ss_disciplines d ON e.discipline_id = d.discipline_id
--         WHERE hd.round_heat_id = p_round_heat_id
--         LIMIT 1; -- Good practice for SELECT INTO

--     IF (v_subcategory = 'Big Air') THEN


--     RETURN QUERY
--     WITH athletes_in_heat AS (
--         SELECT
--             hr.athlete_id,
--             a.fis
--     )