CREATE OR REPLACE PROCEDURE balance_freestyle_heats(p_heat1_id INTEGER)
LANGUAGE plpgsql
AS $$
DECLARE
    v_round_id INTEGER;
    v_heat1_num INTEGER;
    v_heat2_id INTEGER;
    v_event_id INTEGER;
    v_division_id INTEGER;
    v_athlete_record RECORD;
    v_rank INTEGER := 0;
    v_target_heat_id INTEGER;
BEGIN
    SELECT hd.round_id, hd.heat_num, rd.event_id, rd.division_id
    INTO v_round_id, v_heat1_num, v_event_id, v_division_id
    FROM ss_heat_details hd
    JOIN ss_round_details rd ON hd.round_id = rd.round_id
    WHERE hd.round_heat_id = p_heat1_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Invalid input: The provided heat ID (%) does not exist or is not linked to a round.', p_heat1_id;
    END IF;

    IF v_heat1_num <> 1 THEN
        RAISE EXCEPTION 'Invalid input: The provided heat ID (%) is for Heat #%, not Heat #1.', p_heat1_id, v_heat1_num;
    END IF;

    SELECT hd.round_heat_id INTO v_heat2_id
    FROM ss_heat_details hd
    WHERE hd.round_id = v_round_id AND hd.heat_num = 2;

    IF v_heat2_id IS NULL THEN
        RAISE EXCEPTION 'Procedure failed: A corresponding Heat 2 could not be found for the round associated with heat ID %.', p_heat1_id;
    END IF;

    RAISE NOTICE 'Starting to balance athletes between Heat 1 (ID: %) and Heat 2 (ID: %) for round_id: %.', p_heat1_id, v_heat2_id, v_round_id;

    RAISE NOTICE 'Consolidating all athletes into Heat 1 for reseeding.';
    UPDATE ss_heat_results
    SET round_heat_id = p_heat1_id
    WHERE round_heat_id = v_heat2_id;

    RAISE NOTICE 'Calling reseed_heat(%) to establish a single ranked list.', p_heat1_id;
    CALL reseed_heat(p_heat1_id);

    RAISE NOTICE 'Distributing athletes into balanced heats...';
    FOR v_athlete_record IN
        SELECT
            hr.athlete_id,
            hr.seeding
        FROM ss_heat_results AS hr
        WHERE hr.round_heat_id = p_heat1_id
        ORDER BY hr.seeding ASC, hr.athlete_id ASC
    LOOP
        v_rank := v_rank + 1;

        IF (v_rank % 4 = 1) OR (v_rank % 4 = 0) THEN
            v_target_heat_id := p_heat1_id;
        ELSE
            v_target_heat_id := v_heat2_id;
        END IF;

        UPDATE ss_heat_results
        SET round_heat_id = v_target_heat_id
        WHERE
            athlete_id = v_athlete_record.athlete_id
            AND event_id = v_event_id
            AND division_id = v_division_id;

    END LOOP;

    CALL reseed_heat(p_heat1_id);
    CALL reseed_heat(v_heat2_id);

    RAISE NOTICE 'Serpentine seeding completed for round_id=%.', v_round_id;
END;
$$;