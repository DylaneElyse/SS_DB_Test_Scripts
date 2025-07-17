DROP FUNCTION IF EXISTS handle_insert_on_heat_details() CASCADE;

CREATE OR REPLACE FUNCTION handle_insert_on_heat_details()
    RETURNS trigger
	AS $function$
DECLARE
    v_event_id INT;
    v_division_id INT;
    v_num_rounds INT;
    v_round_heat_id INT := new.round_heat_id;
    v_round_id INT := new.round_id;
BEGIN
    SELECT rd.event_id, rd.division_id
    INTO v_event_id, v_division_id
    FROM ss_round_details rd
    WHERE v_round_id = rd.round_id;

    SELECT COUNT(*)
    INTO v_num_rounds
    FROM ss_round_details rd
    WHERE rd.event_id = v_event_id AND rd.division_id = v_division_id;

    IF v_num_rounds > 1 THEN
        SELECT INTO v_round_heat_id
            FROM ss_heat_details hd
            JOIN ss_round_details rd ON hd.round_id = rd.round_id
            WHERE rd.round_id = v_round_id
            AND rd.round_num = 1;

        INSERT INTO ss_heat_results (round_heat_id, event_id, division_id, athlete_id, seeding)
        SELECT
            v_round_heat_id,
            rd.event_id,
            rd.division_id,
            reg.athlete_id,
            0
        FROM
            ss_event_registrations reg
        INNER JOIN ss_round_details rd ON reg.event_id = rd.event_id AND reg.division_id = rd.division_id
        WHERE
            rd.round_id = v_round_id
            AND NOT EXISTS (
                SELECT 1
                FROM ss_heat_results hr
                INNER JOIN ss_heat_details hd ON hr.round_heat_id = hd.round_heat_id
                WHERE hd.round_id = v_round_id AND hr.athlete_id = reg.athlete_id
            )
        ON CONFLICT (round_heat_id, athlete_id) DO NOTHING;

        IF NOT FOUND THEN
            RAISE NOTICE 'Heat created (round_heat_id=%), but no available athletes were found to add.', v_round_heat_id;
        END IF;

        CALL reseed_heat(v_round_heat_id);
    END IF;

	RETURN NULL;
END;
$function$ LANGUAGE plpgsql;


CREATE TRIGGER trg_handle_insert_on_heat_details
	AFTER INSERT ON ss_heat_details
	FOR EACH ROW
	EXECUTE FUNCTION handle_insert_on_heat_details();