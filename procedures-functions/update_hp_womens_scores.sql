CREATE OR REPLACE PROCEDURE update_w_hp_f_scores()
LANGUAGE plpgsql
AS $$
BEGIN

    RAISE NOTICE 'Step 6: Populating womens halfpipe finals scores...';

    PERFORM update_run_score(200, 'Lola', 'Cowan', 'Finals', 1, 'Judge 1', 55);
    PERFORM update_run_score(200, 'Lola', 'Cowan', 'Finals', 1, 'Judge 2', 51);
    PERFORM update_run_score(200, 'Lola', 'Cowan', 'Finals', 1, 'Judge 3', 48);
    PERFORM update_run_score(200, 'Lola', 'Cowan', 'Finals', 1, 'Judge 4', 50);
    PERFORM update_run_score(200, 'Lola', 'Cowan', 'Finals', 1, 'Judge 5', 49);
    PERFORM update_run_score(200, 'Lola', 'Cowan', 'Finals', 2, 'Judge 1', 10);
    PERFORM update_run_score(200, 'Lola', 'Cowan', 'Finals', 2, 'Judge 2', 15);
    PERFORM update_run_score(200, 'Lola', 'Cowan', 'Finals', 2, 'Judge 3', 13);
    PERFORM update_run_score(200, 'Lola', 'Cowan', 'Finals', 2, 'Judge 4', 10);
    PERFORM update_run_score(200, 'Lola', 'Cowan', 'Finals', 2, 'Judge 5', 10);

    PERFORM update_run_score(200, 'Brooke', 'Dhondt', 'Finals', 1, 'Judge 1', 78);
    PERFORM update_run_score(200, 'Brooke', 'Dhondt', 'Finals', 1, 'Judge 2', 78);
    PERFORM update_run_score(200, 'Brooke', 'Dhondt', 'Finals', 1, 'Judge 3', 78);
    PERFORM update_run_score(200, 'Brooke', 'Dhondt', 'Finals', 1, 'Judge 4', 80);
    PERFORM update_run_score(200, 'Brooke', 'Dhondt', 'Finals', 1, 'Judge 5', 79);
    PERFORM update_run_score(200, 'Brooke', 'Dhondt', 'Finals', 2, 'Judge 1', 77);
    PERFORM update_run_score(200, 'Brooke', 'Dhondt', 'Finals', 2, 'Judge 2', 80);
    PERFORM update_run_score(200, 'Brooke', 'Dhondt', 'Finals', 2, 'Judge 3', 81);
    PERFORM update_run_score(200, 'Brooke', 'Dhondt', 'Finals', 2, 'Judge 4', 83);
    PERFORM update_run_score(200, 'Brooke', 'Dhondt', 'Finals', 2, 'Judge 5', 78);

    PERFORM update_run_score(200, 'Sascha', 'Elvy', 'Finals', 1, 'Judge 1', 65);
    PERFORM update_run_score(200, 'Sascha', 'Elvy', 'Finals', 1, 'Judge 2', 59);
    PERFORM update_run_score(200, 'Sascha', 'Elvy', 'Finals', 1, 'Judge 3', 55);
    PERFORM update_run_score(200, 'Sascha', 'Elvy', 'Finals', 1, 'Judge 4', 58);
    PERFORM update_run_score(200, 'Sascha', 'Elvy', 'Finals', 1, 'Judge 5', 58);
    PERFORM update_run_score(200, 'Sascha', 'Elvy', 'Finals', 2, 'Judge 1', 66);
    PERFORM update_run_score(200, 'Sascha', 'Elvy', 'Finals', 2, 'Judge 2', 63);
    PERFORM update_run_score(200, 'Sascha', 'Elvy', 'Finals', 2, 'Judge 3', 57);
    PERFORM update_run_score(200, 'Sascha', 'Elvy', 'Finals', 2, 'Judge 4', 63);
    PERFORM update_run_score(200, 'Sascha', 'Elvy', 'Finals', 2, 'Judge 5', 59);

    PERFORM update_run_score(200, 'Felicity', 'Geremia', 'Finals', 1, 'Judge 1', 85);
    PERFORM update_run_score(200, 'Felicity', 'Geremia', 'Finals', 1, 'Judge 2', 81);
    PERFORM update_run_score(200, 'Felicity', 'Geremia', 'Finals', 1, 'Judge 3', 83);
    PERFORM update_run_score(200, 'Felicity', 'Geremia', 'Finals', 1, 'Judge 4', 84);
    PERFORM update_run_score(200, 'Felicity', 'Geremia', 'Finals', 1, 'Judge 5', 84);
    PERFORM update_run_score(200, 'Felicity', 'Geremia', 'Finals', 2, 'Judge 1', 83);
    PERFORM update_run_score(200, 'Felicity', 'Geremia', 'Finals', 2, 'Judge 2', 77);
    PERFORM update_run_score(200, 'Felicity', 'Geremia', 'Finals', 2, 'Judge 3', 73);
    PERFORM update_run_score(200, 'Felicity', 'Geremia', 'Finals', 2, 'Judge 4', 84);
    PERFORM update_run_score(200, 'Felicity', 'Geremia', 'Finals', 2, 'Judge 5', 81);

    PERFORM update_run_score(200, 'Isla', 'Graven', 'Finals', 1, 'Judge 1', 63);
    PERFORM update_run_score(200, 'Isla', 'Graven', 'Finals', 1, 'Judge 2', 53);
    PERFORM update_run_score(200, 'Isla', 'Graven', 'Finals', 1, 'Judge 3', 53);
    PERFORM update_run_score(200, 'Isla', 'Graven', 'Finals', 1, 'Judge 4', 48);
    PERFORM update_run_score(200, 'Isla', 'Graven', 'Finals', 1, 'Judge 5', 52);
    PERFORM update_run_score(200, 'Isla', 'Graven', 'Finals', 2, 'Judge 1', 63);
    PERFORM update_run_score(200, 'Isla', 'Graven', 'Finals', 2, 'Judge 2', 66);
    PERFORM update_run_score(200, 'Isla', 'Graven', 'Finals', 2, 'Judge 3', 60);
    PERFORM update_run_score(200, 'Isla', 'Graven', 'Finals', 2, 'Judge 4', 57);
    PERFORM update_run_score(200, 'Isla', 'Graven', 'Finals', 2, 'Judge 5', 61);

    PERFORM update_run_score(200, 'Zoe', 'Guerrero', 'Finals', 1, 'Judge 1', 67);
    PERFORM update_run_score(200, 'Zoe', 'Guerrero', 'Finals', 1, 'Judge 2', 69);
    PERFORM update_run_score(200, 'Zoe', 'Guerrero', 'Finals', 1, 'Judge 3', 70);
    PERFORM update_run_score(200, 'Zoe', 'Guerrero', 'Finals', 1, 'Judge 4', 72);
    PERFORM update_run_score(200, 'Zoe', 'Guerrero', 'Finals', 1, 'Judge 5', 65);
    PERFORM update_run_score(200, 'Zoe', 'Guerrero', 'Finals', 2, 'Judge 1', 77);
    PERFORM update_run_score(200, 'Zoe', 'Guerrero', 'Finals', 2, 'Judge 2', 79);
    PERFORM update_run_score(200, 'Zoe', 'Guerrero', 'Finals', 2, 'Judge 3', 78);
    PERFORM update_run_score(200, 'Zoe', 'Guerrero', 'Finals', 2, 'Judge 4', 79);
    PERFORM update_run_score(200, 'Zoe', 'Guerrero', 'Finals', 2, 'Judge 5', 68);

    PERFORM update_run_score(200, 'Amelie', 'Haskell', 'Finals', 1, 'Judge 1', 75);
    PERFORM update_run_score(200, 'Amelie', 'Haskell', 'Finals', 1, 'Judge 2', 77);
    PERFORM update_run_score(200, 'Amelie', 'Haskell', 'Finals', 1, 'Judge 3', 77);
    PERFORM update_run_score(200, 'Amelie', 'Haskell', 'Finals', 1, 'Judge 4', 78);
    PERFORM update_run_score(200, 'Amelie', 'Haskell', 'Finals', 1, 'Judge 5', 75);
    PERFORM update_run_score(200, 'Amelie', 'Haskell', 'Finals', 2, 'Judge 1', 76);
    PERFORM update_run_score(200, 'Amelie', 'Haskell', 'Finals', 2, 'Judge 2', 77);
    PERFORM update_run_score(200, 'Amelie', 'Haskell', 'Finals', 2, 'Judge 3', 77);
    PERFORM update_run_score(200, 'Amelie', 'Haskell', 'Finals', 2, 'Judge 4', 82);
    PERFORM update_run_score(200, 'Amelie', 'Haskell', 'Finals', 2, 'Judge 5', 76);

    PERFORM update_run_score(200, 'Ava', 'Lilly', 'Finals', 1, 'Judge 1', 70);
    PERFORM update_run_score(200, 'Ava', 'Lilly', 'Finals', 1, 'Judge 2', 70);
    PERFORM update_run_score(200, 'Ava', 'Lilly', 'Finals', 1, 'Judge 3', 65);
    PERFORM update_run_score(200, 'Ava', 'Lilly', 'Finals', 1, 'Judge 4', 68);
    PERFORM update_run_score(200, 'Ava', 'Lilly', 'Finals', 1, 'Judge 5', 62);
    PERFORM update_run_score(200, 'Ava', 'Lilly', 'Finals', 2, 'Judge 1', 70);
    PERFORM update_run_score(200, 'Ava', 'Lilly', 'Finals', 2, 'Judge 2', 73);
    PERFORM update_run_score(200, 'Ava', 'Lilly', 'Finals', 2, 'Judge 3', 66);
    PERFORM update_run_score(200, 'Ava', 'Lilly', 'Finals', 2, 'Judge 4', 69);
    PERFORM update_run_score(200, 'Ava', 'Lilly', 'Finals', 2, 'Judge 5', 64);

    PERFORM update_run_score(200, 'Molly', 'Mailer', 'Finals', 1, 'Judge 1', 47);
    PERFORM update_run_score(200, 'Molly', 'Mailer', 'Finals', 1, 'Judge 2', 42);
    PERFORM update_run_score(200, 'Molly', 'Mailer', 'Finals', 1, 'Judge 3', 45);
    PERFORM update_run_score(200, 'Molly', 'Mailer', 'Finals', 1, 'Judge 4', 40);
    PERFORM update_run_score(200, 'Molly', 'Mailer', 'Finals', 1, 'Judge 5', 38);
    PERFORM update_run_score(200, 'Molly', 'Mailer', 'Finals', 2, 'Judge 1', 50);
    PERFORM update_run_score(200, 'Molly', 'Mailer', 'Finals', 2, 'Judge 2', 42);
    PERFORM update_run_score(200, 'Molly', 'Mailer', 'Finals', 2, 'Judge 3', 42);
    PERFORM update_run_score(200, 'Molly', 'Mailer', 'Finals', 2, 'Judge 4', 33);
    PERFORM update_run_score(200, 'Molly', 'Mailer', 'Finals', 2, 'Judge 5', 35);

    PERFORM update_run_score(200, 'Kaylie', 'Neal', 'Finals', 1, 'Judge 1', 71);
    PERFORM update_run_score(200, 'Kaylie', 'Neal', 'Finals', 1, 'Judge 2', 62);
    PERFORM update_run_score(200, 'Kaylie', 'Neal', 'Finals', 1, 'Judge 3', 63);
    PERFORM update_run_score(200, 'Kaylie', 'Neal', 'Finals', 1, 'Judge 4', 64);
    PERFORM update_run_score(200, 'Kaylie', 'Neal', 'Finals', 1, 'Judge 5', 60);
    PERFORM update_run_score(200, 'Kaylie', 'Neal', 'Finals', 2, 'Judge 1', 73);
    PERFORM update_run_score(200, 'Kaylie', 'Neal', 'Finals', 2, 'Judge 2', 67);
    PERFORM update_run_score(200, 'Kaylie', 'Neal', 'Finals', 2, 'Judge 3', 69);
    PERFORM update_run_score(200, 'Kaylie', 'Neal', 'Finals', 2, 'Judge 4', 71);
    PERFORM update_run_score(200, 'Kaylie', 'Neal', 'Finals', 2, 'Judge 5', 63);

    PERFORM update_run_score(200, 'Katie', 'Seidler', 'Finals', 1, 'Judge 1', 45);
    PERFORM update_run_score(200, 'Katie', 'Seidler', 'Finals', 1, 'Judge 2', 49);
    PERFORM update_run_score(200, 'Katie', 'Seidler', 'Finals', 1, 'Judge 3', 43);
    PERFORM update_run_score(200, 'Katie', 'Seidler', 'Finals', 1, 'Judge 4', 44);
    PERFORM update_run_score(200, 'Katie', 'Seidler', 'Finals', 1, 'Judge 5', 41);
    PERFORM update_run_score(200, 'Katie', 'Seidler', 'Finals', 2, 'Judge 1', 33);
    PERFORM update_run_score(200, 'Katie', 'Seidler', 'Finals', 2, 'Judge 2', 30);
    PERFORM update_run_score(200, 'Katie', 'Seidler', 'Finals', 2, 'Judge 3', 33);
    PERFORM update_run_score(200, 'Katie', 'Seidler', 'Finals', 2, 'Judge 4', 27);
    PERFORM update_run_score(200, 'Katie', 'Seidler', 'Finals', 2, 'Judge 5', 29);

    PERFORM update_run_score(200, 'Sydney', 'Tait', 'Finals', 1, 'Judge 1', 40);
    PERFORM update_run_score(200, 'Sydney', 'Tait', 'Finals', 1, 'Judge 2', 39);
    PERFORM update_run_score(200, 'Sydney', 'Tait', 'Finals', 1, 'Judge 3', 35);
    PERFORM update_run_score(200, 'Sydney', 'Tait', 'Finals', 1, 'Judge 4', 32);
    PERFORM update_run_score(200, 'Sydney', 'Tait', 'Finals', 1, 'Judge 5', 32);
    PERFORM update_run_score(200, 'Sydney', 'Tait', 'Finals', 2, 'Judge 1', 39);
    PERFORM update_run_score(200, 'Sydney', 'Tait', 'Finals', 2, 'Judge 2', 39);
    PERFORM update_run_score(200, 'Sydney', 'Tait', 'Finals', 2, 'Judge 3', 34);
    PERFORM update_run_score(200, 'Sydney', 'Tait', 'Finals', 2, 'Judge 4', 29);
    PERFORM update_run_score(200, 'Sydney', 'Tait', 'Finals', 2, 'Judge 5', 25);

    PERFORM update_run_score(200, 'Rochelle', 'Weinberg', 'Finals', 1, 'Judge 1', 72);
    PERFORM update_run_score(200, 'Rochelle', 'Weinberg', 'Finals', 1, 'Judge 2', 71);
    PERFORM update_run_score(200, 'Rochelle', 'Weinberg', 'Finals', 1, 'Judge 3', 75);
    PERFORM update_run_score(200, 'Rochelle', 'Weinberg', 'Finals', 1, 'Judge 4', 76);
    PERFORM update_run_score(200, 'Rochelle', 'Weinberg', 'Finals', 1, 'Judge 5', 70);
    PERFORM update_run_score(200, 'Rochelle', 'Weinberg', 'Finals', 2, 'Judge 1', 82);
    PERFORM update_run_score(200, 'Rochelle', 'Weinberg', 'Finals', 2, 'Judge 2', 77);
    PERFORM update_run_score(200, 'Rochelle', 'Weinberg', 'Finals', 2, 'Judge 3', 79);
    PERFORM update_run_score(200, 'Rochelle', 'Weinberg', 'Finals', 2, 'Judge 4', 81);
    PERFORM update_run_score(200, 'Rochelle', 'Weinberg', 'Finals', 2, 'Judge 5', 87);

    PERFORM update_run_score(200, 'Aimee', 'Wild', 'Finals', 1, 'Judge 1', 80);
    PERFORM update_run_score(200, 'Aimee', 'Wild', 'Finals', 1, 'Judge 2', 80);
    PERFORM update_run_score(200, 'Aimee', 'Wild', 'Finals', 1, 'Judge 3', 80);
    PERFORM update_run_score(200, 'Aimee', 'Wild', 'Finals', 1, 'Judge 4', 82);
    PERFORM update_run_score(200, 'Aimee', 'Wild', 'Finals', 1, 'Judge 5', 80);
    PERFORM update_run_score(200, 'Aimee', 'Wild', 'Finals', 2, 'Judge 1', 81);
    PERFORM update_run_score(200, 'Aimee', 'Wild', 'Finals', 2, 'Judge 2', 83);
    PERFORM update_run_score(200, 'Aimee', 'Wild', 'Finals', 2, 'Judge 3', 82);
    PERFORM update_run_score(200, 'Aimee', 'Wild', 'Finals', 2, 'Judge 4', 85);
    PERFORM update_run_score(200, 'Aimee', 'Wild', 'Finals', 2, 'Judge 5', 85);

    RAISE NOTICE 'Step 6: Womens halfpipe finals scores populated successfully.';
END;
$$;