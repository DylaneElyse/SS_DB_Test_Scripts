CREATE OR REPLACE PROCEDURE calculate_average_score(p_run_result_id INTEGER)
	AS $procedure$
BEGIN
    UPDATE ss_run_results
    SET
        calc_score = (
            SELECT ROUND(AVG(score), 2)
            FROM ss_run_scores
            WHERE run_result_id = p_run_result_id AND score <> 0 AND score IS NOT NULL
        )
    WHERE run_result_id = p_run_result_id;

    CALL find_best_score(p_run_result_id);
END;
$procedure$ LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE find_best_score(p_run_result_id INTEGER)
	AS $procedure$
DECLARE
    v_athlete_id INTEGER;
    v_round_heat_id INTEGER;
    v_best_score DECIMAL;
BEGIN
    SELECT rr.athlete_id, rr.round_heat_id
    INTO v_athlete_id, v_round_heat_id
    FROM ss_run_results AS rr
    WHERE rr.run_result_id = p_run_result_id;

    IF NOT FOUND THEN
        RAISE NOTICE 'No run result found for id %', p_run_result_id;
        RETURN;
    END IF;

    SELECT MAX(rr.calc_score)
    INTO v_best_score
    FROM ss_run_results AS rr
    WHERE rr.athlete_id = v_athlete_id AND rr.round_heat_id = v_round_heat_id;

    UPDATE ss_heat_results
    SET
        best = v_best_score
    WHERE
        athlete_id = v_athlete_id AND round_heat_id = v_round_heat_id;
END;
$procedure$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION trg_start_score_calculation_chain()
    RETURNS TRIGGER
    LANGUAGE plpgsql
AS $function$
DECLARE
    v_run_result_id INTEGER;
BEGIN
    IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
        v_run_result_id := NEW.run_result_id;
    ELSE
        v_run_result_id := OLD.run_result_id;
    END IF;

    CALL calculate_average_score(v_run_result_id);

    RETURN NULL;
END;
$function$;


CREATE TRIGGER trg_update_scores_after_change
AFTER INSERT OR UPDATE OR DELETE ON ss_run_scores
FOR EACH ROW
EXECUTE FUNCTION trg_start_score_calculation_chain();