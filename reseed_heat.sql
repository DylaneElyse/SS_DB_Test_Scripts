-- Active: 1749478571723@@127.0.0.1@5432@ss_test_db@public

CREATE OR REPLACE PROCEDURE public.reseed_heat(IN p_round_heat_id integer)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
  v_subcategory   ss_disciplines.subcategory_name%TYPE;
  v_points_column TEXT;
  v_sql           TEXT;
BEGIN
  -- Step 1: Find the discipline's subcategory for the given heat. (Unchanged)
  SELECT d.subcategory_name INTO v_subcategory
  FROM ss_heat_details AS hd
  JOIN ss_round_details AS rd ON hd.round_id = rd.round_id
  JOIN ss_events AS e ON rd.event_id = e.event_id
  JOIN ss_disciplines AS d ON e.discipline_id = d.discipline_id
  WHERE hd.round_heat_id = p_round_heat_id
  LIMIT 1;

  IF NOT FOUND THEN
    RAISE NOTICE 'reseed_heat: No heat found for round_heat_id %', p_round_heat_id;
    RETURN;
  END IF;

  -- Step 2: Map the subcategory to the correct points column. (Unchanged)
  v_points_column := CASE v_subcategory
    WHEN 'Big Air'    THEN 'fis_ba_points'
    WHEN 'Slopestyle' THEN 'fis_ss_points'
    WHEN 'Halfpipe'   THEN 'fis_hp_points'
    ELSE NULL
  END;

  IF v_points_column IS NULL THEN
    RAISE NOTICE 'reseed_heat: No seeding rule for subcategory "%". Seeding will not be changed.', v_subcategory;
    RETURN;
  END IF;

  -- Step 3: Build the dynamic SQL to update seeding.
  v_sql := format(
    'WITH new_seeding AS (
      SELECT
        hr.athlete_id,
        -- Per your rules (higher points = better), we order by points ASCENDING.
        -- This gives the lowest-ranked athlete (lowest points) seed #1.
        -- This gives the HIGHEST-ranked athlete (highest points) the HIGHEST seed number,
        -- so they start last.
        ROW_NUMBER() OVER (ORDER BY a.%I ASC, a.athlete_id ASC) AS new_seed_value
      FROM
        ss_heat_results hr
      JOIN
        ss_athletes a ON hr.athlete_id = a.athlete_id
      WHERE
        hr.round_heat_id = $1
    )
    UPDATE
      ss_heat_results
    SET
      seeding = new_seeding.new_seed_value
    FROM
      new_seeding
    WHERE
      ss_heat_results.athlete_id = new_seeding.athlete_id
      AND ss_heat_results.round_heat_id = $1;',
    v_points_column
  );

  -- Step 4: Execute the dynamic SQL. (Unchanged)
  RAISE NOTICE 'Reseeding heat % based on % points (best athlete starts last).', p_round_heat_id, v_points_column;
  EXECUTE v_sql USING p_round_heat_id;

END;
$procedure$;


-- CREATE OR REPLACE PROCEDURE reseed_heat(p_round_heat_id INTEGER)
-- LANGUAGE plpgsql
-- AS $$

-- DECLARE
--   v_subcategory ss_disciplines.subcategory_name%TYPE;

-- BEGIN
--   SELECT d.subcategory_name INTO v_subcategory
--     FROM ss_heat_details hd
--     JOIN ss_round_details rd ON hd.round_id = rd.round_id
--     JOIN ss_events e ON rd.event_id = e.event_id
--     JOIN ss_disciplines d ON e.discipline_id = d.discipline_id
--     WHERE hd.round_heat_id = p_round_heat_id
--     LIMIT 1; 

--   IF (v_subcategory = 'Big Air') THEN
--     WITH new_seeding AS (
--       SELECT
--         hr.athlete_id,
--         ROW_NUMBER() OVER (ORDER BY a.fis_ba_points ASC, a.athlete_id ASC) AS new_seed_value
--       FROM
--         ss_heat_results hr
--       JOIN
--         ss_athletes a ON hr.athlete_id = a.athlete_id
--       WHERE
--         hr.round_heat_id = p_round_heat_id
--     )
--     UPDATE
--       ss_heat_results
--     SET
--       seeding = new_seeding.new_seed_value
--     FROM
--       new_seeding
--     WHERE
--       ss_heat_results.athlete_id = new_seeding.athlete_id
--       AND ss_heat_results.round_heat_id = p_round_heat_id;

--   ELSEIF (v_subcategory = 'Slopestyle') THEN
--     WITH new_seeding AS (
--       SELECT
--         hr.athlete_id,
--         ROW_NUMBER() OVER (ORDER BY a.fis_ss_points ASC, a.athlete_id ASC) AS new_seed_value
--       FROM
--         ss_heat_results hr
--       JOIN
--         ss_athletes a ON hr.athlete_id = a.athlete_id
--       WHERE
--         hr.round_heat_id = p_round_heat_id
--     )
--     UPDATE
--       ss_heat_results
--     SET
--       seeding = new_seeding.new_seed_value
--     FROM
--       new_seeding
--     WHERE
--       ss_heat_results.athlete_id = new_seeding.athlete_id
--       AND ss_heat_results.round_heat_id = p_round_heat_id;

--   ELSEIF (v_subcategory = 'Halfpipe') THEN
--       WITH new_seeding AS (
--       SELECT
--         hr.athlete_id,
--         ROW_NUMBER() OVER (ORDER BY a.fis_hp_points ASC, a.athlete_id ASC) AS new_seed_value
--       FROM
--         ss_heat_results hr
--       JOIN
--         ss_athletes a ON hr.athlete_id = a.athlete_id
--       WHERE
--         hr.round_heat_id = p_round_heat_id
--     )
--     UPDATE
--       ss_heat_results
--     SET
--       seeding = new_seeding.new_seed_value
--     FROM
--       new_seeding
--     WHERE
--       ss_heat_results.athlete_id = new_seeding.athlete_id
--       AND ss_heat_results.round_heat_id = p_round_heat_id;
--   END IF;

-- END;
-- $$;





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