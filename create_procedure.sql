-- 1.
CREATE OR REPLACE PROCEDURE reseed_heat(IN p_heat_id INTEGER)
AS $procedure$
DECLARE
    v_subcategory   ss_disciplines.subcategory_name%TYPE;
    v_points_column TEXT;
    v_sql           TEXT;
BEGIN
    SELECT d.subcategory_name
    INTO v_subcategory
    FROM ss_heat_details AS hd
    JOIN ss_round_details AS rd ON hd.round_id = rd.round_id
    JOIN ss_events AS e ON rd.event_id = e.event_id
    JOIN ss_disciplines AS d ON e.discipline_id = d.discipline_id
    WHERE hd.heat_id = p_heat_id
    LIMIT 1;

    IF NOT FOUND THEN
        RAISE NOTICE 'reseed_heat: No heat found for heat_id %', p_heat_id;
        RETURN;
    END IF;

    v_points_column := CASE v_subcategory
        WHEN 'Big Air'    THEN 'fis_ba_points'
        WHEN 'Slopestyle' THEN 'fis_ss_points'
        WHEN 'Halfpipe'   THEN 'fis_hp_points'
        ELSE NULL
    END;

    IF v_points_column IS NULL THEN
        RAISE NOTICE 'reseed_heat: No seeding rule for subcategory "%". Seeding will be based on athlete ID only.', v_subcategory;
        v_points_column := 'athlete_id';
    END IF;

  v_sql := format(
    $dynamic_sql$
    WITH new_seeding AS (
        SELECT
            -- CHANGE #1: Instead of athlete_id, we MUST select the key that
            -- ss_heat_results actually uses: registration_id.
            er.registration_id,
            -- The ranking logic itself is preserved.
            ROW_NUMBER() OVER (ORDER BY a.%I DESC, a.athlete_id ASC) AS new_seed_value
        FROM
            ss_heat_results AS hr
            JOIN ss_event_registrations AS er ON hr.registration_id = er.registration_id
            JOIN ss_athletes AS a ON er.athlete_id = a.athlete_id
        WHERE
            hr.heat_id = $1
    )
    UPDATE ss_heat_results
    SET seeding = ns.new_seed_value
    FROM new_seeding AS ns
    WHERE
        -- CHANGE #2: Now we can join ss_heat_results to our subquery
        -- using the correct common key: registration_id.
        ss_heat_results.registration_id = ns.registration_id
        AND ss_heat_results.heat_id = $1;
    $dynamic_sql$,
    v_points_column
  );
    RAISE NOTICE 'Executing reseed for heat_id % using column %I', p_heat_id, v_points_column;
    EXECUTE v_sql USING p_heat_id;

END;
$procedure$ LANGUAGE plpgsql;