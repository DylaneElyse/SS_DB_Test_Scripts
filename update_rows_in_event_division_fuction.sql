CREATE OR REPLACE FUNCTION handle_row_update_on_event_division()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.num_rounds IS DISTINCT FROM OLD.num_rounds THEN
      DECLARE
        v_event_id ss_round_details.event_id%TYPE;
        v_division_id ss_round_details.division_id%TYPE;
        v_num_rounds ss_event_divisions.num_rounds%TYPE;
        v_count INT; -- Simpler to declare as INT
        v_round_name TEXT; -- To store the current round name from the list

        -- Define round names arrays (consider making these constants or a lookup if they don't change)
        v_round_list_2 TEXT[] := ARRAY['Qualifications', 'Finals']; -- Order might matter
        v_round_list_3 TEXT[] := ARRAY['Qualifications', 'Semi-Finals', 'Finals'];
        v_round_list_4 TEXT[] := ARRAY['Qualifications', 'Quarter-Finals', 'Semi-Finals', 'Finals'];
        -- Note: I've reordered these lists to be more typical (Qual -> Quarter -> Semi -> Final). Adjust if your order is different.
        -- PostgreSQL arrays are 1-indexed.

      BEGIN
        v_event_id := NEW.event_id;
        v_division_id := NEW.division_id;
        v_num_rounds := NEW.num_rounds;

        IF (v_num_rounds = 1) THEN
          -- Assuming 'Finals' or a specific name for a single round.
          -- If round_name has a DEFAULT in the table, you might not need to specify it.
          -- If round_id and num_heats also have defaults, they can be omitted too.
          INSERT INTO ss_round_details (event_id, division_id, round_name, num_heats) -- Assuming round_id is DEFAULT
            VALUES (v_event_id, v_division_id, 'Finals', DEFAULT); -- Or another specific name, or DEFAULT if defined

        ELSEIF (v_num_rounds = 2) THEN
          v_count := 1;
          WHILE (v_count <= v_num_rounds) LOOP
            v_round_name := v_round_list_2[v_count];
            INSERT INTO ss_round_details (event_id, division_id, round_name, num_heats) -- Assuming round_id is DEFAULT
              VALUES (v_event_id, v_division_id, v_round_name, DEFAULT);
            v_count := v_count + 1;
          END LOOP; -- Removed the incorrect EXIT LOOP

        ELSEIF (v_num_rounds = 3) THEN
          v_count := 1;
          WHILE (v_count <= v_num_rounds) LOOP
            v_round_name := v_round_list_3[v_count];
            INSERT INTO ss_round_details (event_id, division_id, round_name, num_heats) -- Assuming round_id is DEFAULT
              VALUES (v_event_id, v_division_id, v_round_name, DEFAULT);
            v_count := v_count + 1;
          END LOOP; -- Removed the incorrect EXIT LOOP

        ELSEIF (v_num_rounds = 4) THEN
          v_count := 1;
          WHILE (v_count <= v_num_rounds) LOOP
            v_round_name := v_round_list_4[v_count];
            INSERT INTO ss_round_details (event_id, division_id, round_name, num_heats) -- Assuming round_id is DEFAULT
              VALUES (v_event_id, v_division_id, v_round_name, DEFAULT);
            v_count := v_count + 1;
          END LOOP; -- Removed the incorrect EXIT LOOP
        END IF;
      END;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trg_after_update_on_event_division
AFTER INSERT ON ss_event_divisions
FOR EACH ROW
EXECUTE FUNCTION handle_row_update_on_event_division();