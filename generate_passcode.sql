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

        -- Check if the code already exists in the database
        SELECT COUNT(*) INTO v_count FROM ss_event_judges WHERE passcode = random_code;

        IF v_count = 0 THEN
            RETURN random_code;
        END IF;
    END LOOP;
    RETURN random_code;
END;
$$ LANGUAGE plpgsql VOLATILE;






