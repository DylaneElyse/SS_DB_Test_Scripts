-- Active: 1749478571723@@127.0.0.1@5432@ss_test_db@public
CREATE OR REPLACE FUNCTION generate_random_4_digit_code()
RETURNS TEXT AS $$
DECLARE
    random_int INT;
    random_code TEXT;
    v_count INT;

BEGIN
    v_count := 1;

    WHILE v_count > 0 LOOP
        random_int := floor(random() * 10000);
        random_code := lpad(random_int::text, 4, '0');

        SELECT COUNT(*) INTO v_count FROM ss_event_judges WHERE passcode = random_code;

        IF v_count = 0 THEN
            RETURN random_code;
        END IF;
    END LOOP;
    RETURN random_code;
END;
$$ LANGUAGE plpgsql VOLATILE;


-- DB:
-- CREATE OR REPLACE FUNCTION generate_random_4_digit_code()
--   RETURNS TEXT AS $function$
-- DECLARE
--     v_random_code TEXT;
--     v_is_unique   BOOLEAN := FALSE;
-- BEGIN
--     WHILE NOT v_is_unique LOOP
--         v_random_code := lpad(floor(random() * 10000)::TEXT, 4, '0');

--         SELECT NOT EXISTS (
--             SELECT 1
--             FROM ss_event_judges
--             WHERE passcode = v_random_code
--         ) INTO v_is_unique;
--     END LOOP;

--     RETURN v_random_code;
-- END;
-- $function$ LANGUAGE plpgsql VOLATILE;






