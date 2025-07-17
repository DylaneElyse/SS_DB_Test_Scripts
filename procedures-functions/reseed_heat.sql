-- Active: 1749478571723@@127.0.0.1@5432@ss_test_db@public

CREATE OR REPLACE PROCEDURE reseed_heat(IN p_round_heat_id integer)
	AS $procedure$
DECLARE
	v_subcategory   ss_disciplines.subcategory_name%TYPE;
	v_points_column TEXT;
	v_sql           TEXT;
BEGIN
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

	RAISE NOTICE 'Reseeding heat % based on % points (best athlete starts last).', p_round_heat_id, v_points_column;
	EXECUTE v_sql USING p_round_heat_id;

END;
$procedure$ LANGUAGE plpgsql;


