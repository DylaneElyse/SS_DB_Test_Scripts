CREATE OR REPLACE FUNCTION generate_random_4_digit_code()
  RETURNS TEXT AS $function$
DECLARE
    v_random_code TEXT;
    v_is_unique   BOOLEAN := FALSE;
BEGIN
    WHILE NOT v_is_unique LOOP
        v_random_code := lpad(floor(random() * 10000)::TEXT, 4, '0');

        SELECT NOT EXISTS (
            SELECT 1
            FROM ss_event_judges
            WHERE passcode = v_random_code
        ) INTO v_is_unique;
    END LOOP;

    RETURN v_random_code;
END;
$function$ LANGUAGE plpgsql VOLATILE;