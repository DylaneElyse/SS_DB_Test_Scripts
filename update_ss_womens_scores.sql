CREATE OR REPLACE PROCEDURE update_w_ss_f_scores()
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE NOTICE 'Step 6: Populating womens slopestyle finals scores...';

    PERFORM update_run_score(100, 'Kaitlyn', 'Adams', 'Finals', 1, 'Judge 1', 81);
    PERFORM update_run_score(100, 'Kaitlyn', 'Adams', 'Finals', 1, 'Judge 2', 74);
    PERFORM update_run_score(100, 'Kaitlyn', 'Adams', 'Finals', 1, 'Judge 3', 76);
    PERFORM update_run_score(100, 'Kaitlyn', 'Adams', 'Finals', 1, 'Judge 4', 84);
    PERFORM update_run_score(100, 'Kaitlyn', 'Adams', 'Finals', 1, 'Judge 5', 79);
    PERFORM update_run_score(100, 'Kaitlyn', 'Adams', 'Finals', 1, 'Judge 6', 73);

    PERFORM update_run_score(100, 'Sonora', 'Alba', 'Finals', 1, 'Judge 1', 48);
    PERFORM update_run_score(100, 'Sonora', 'Alba', 'Finals', 1, 'Judge 2', 50);
    PERFORM update_run_score(100, 'Sonora', 'Alba', 'Finals', 1, 'Judge 3', 55);
    PERFORM update_run_score(100, 'Sonora', 'Alba', 'Finals', 1, 'Judge 4', 55);
    PERFORM update_run_score(100, 'Sonora', 'Alba', 'Finals', 1, 'Judge 5', 56);
    PERFORM update_run_score(100, 'Sonora', 'Alba', 'Finals', 1, 'Judge 6', 59);

    PERFORM update_run_score(100, 'Gabriella', 'Boday', 'Finals', 1, 'Judge 1', 40);
    PERFORM update_run_score(100, 'Gabriella', 'Boday', 'Finals', 1, 'Judge 2', 50);
    PERFORM update_run_score(100, 'Gabriella', 'Boday', 'Finals', 1, 'Judge 3', 42);
    PERFORM update_run_score(100, 'Gabriella', 'Boday', 'Finals', 1, 'Judge 4', 36);
    PERFORM update_run_score(100, 'Gabriella', 'Boday', 'Finals', 1, 'Judge 5', 38);
    PERFORM update_run_score(100, 'Gabriella', 'Boday', 'Finals', 1, 'Judge 6', 43);

    PERFORM update_run_score(100, 'Katie', 'Brayer', 'Finals', 1, 'Judge 1', 48);
    PERFORM update_run_score(100, 'Katie', 'Brayer', 'Finals', 1, 'Judge 2', 45);
    PERFORM update_run_score(100, 'Katie', 'Brayer', 'Finals', 1, 'Judge 3', 48);
    PERFORM update_run_score(100, 'Katie', 'Brayer', 'Finals', 1, 'Judge 4', 48);
    PERFORM update_run_score(100, 'Katie', 'Brayer', 'Finals', 1, 'Judge 5', 44);
    PERFORM update_run_score(100, 'Katie', 'Brayer', 'Finals', 1, 'Judge 6', 46);

    PERFORM update_run_score(100, 'Giada', 'Brienza', 'Finals', 1, 'Judge 1', 22);
    PERFORM update_run_score(100, 'Giada', 'Brienza', 'Finals', 1, 'Judge 2', 15);
    PERFORM update_run_score(100, 'Giada', 'Brienza', 'Finals', 1, 'Judge 3', 19);
    PERFORM update_run_score(100, 'Giada', 'Brienza', 'Finals', 1, 'Judge 4', 23);
    PERFORM update_run_score(100, 'Giada', 'Brienza', 'Finals', 1, 'Judge 5', 22);
    PERFORM update_run_score(100, 'Giada', 'Brienza', 'Finals', 1, 'Judge 6', 18);
    PERFORM update_run_score(100, 'Giada', 'Brienza', 'Finals', 2, 'Judge 1', 21);
    PERFORM update_run_score(100, 'Giada', 'Brienza', 'Finals', 3, 'Judge 1', 19);
    PERFORM update_run_score(100, 'Giada', 'Brienza', 'Finals', 3, 'Judge 2', 13);
    PERFORM update_run_score(100, 'Giada', 'Brienza', 'Finals', 3, 'Judge 5', 27);

    PERFORM update_run_score(100, 'Lily', 'Dhawornvej', 'Finals', 1, 'Judge 1', 66);
    PERFORM update_run_score(100, 'Lily', 'Dhawornvej', 'Finals', 1, 'Judge 2', 65);
    PERFORM update_run_score(100, 'Lily', 'Dhawornvej', 'Finals', 1, 'Judge 3', 65);
    PERFORM update_run_score(100, 'Lily', 'Dhawornvej', 'Finals', 1, 'Judge 4', 70);
    PERFORM update_run_score(100, 'Lily', 'Dhawornvej', 'Finals', 1, 'Judge 5', 64);
    PERFORM update_run_score(100, 'Lily', 'Dhawornvej', 'Finals', 1, 'Judge 6', 66);
    PERFORM update_run_score(100, 'Lily', 'Dhawornvej', 'Finals', 2, 'Judge 1', 70);
    PERFORM update_run_score(100, 'Lily', 'Dhawornvej', 'Finals', 2, 'Judge 2', 67);
    PERFORM update_run_score(100, 'Lily', 'Dhawornvej', 'Finals', 2, 'Judge 3', 67);
    PERFORM update_run_score(100, 'Lily', 'Dhawornvej', 'Finals', 2, 'Judge 4', 72);
    PERFORM update_run_score(100, 'Lily', 'Dhawornvej', 'Finals', 2, 'Judge 5', 69);
    PERFORM update_run_score(100, 'Lily', 'Dhawornvej', 'Finals', 2, 'Judge 6', 69);

    PERFORM update_run_score(100, 'Brooke', 'Dhondt', 'Finals', 1, 'Judge 1', 32);
    PERFORM update_run_score(100, 'Brooke', 'Dhondt', 'Finals', 1, 'Judge 2', 30);
    PERFORM update_run_score(100, 'Brooke', 'Dhondt', 'Finals', 1, 'Judge 3', 29);
    PERFORM update_run_score(100, 'Brooke', 'Dhondt', 'Finals', 1, 'Judge 4', 22);
    PERFORM update_run_score(100, 'Brooke', 'Dhondt', 'Finals', 1, 'Judge 5', 34);
    PERFORM update_run_score(100, 'Brooke', 'Dhondt', 'Finals', 1, 'Judge 6', 35);
    PERFORM update_run_score(100, 'Brooke', 'Dhondt', 'Finals', 2, 'Judge 1', 57);
    PERFORM update_run_score(100, 'Brooke', 'Dhondt', 'Finals', 2, 'Judge 2', 60);
    PERFORM update_run_score(100, 'Brooke', 'Dhondt', 'Finals', 2, 'Judge 3', 60);
    PERFORM update_run_score(100, 'Brooke', 'Dhondt', 'Finals', 2, 'Judge 4', 62);
    PERFORM update_run_score(100, 'Brooke', 'Dhondt', 'Finals', 2, 'Judge 5', 63);
    PERFORM update_run_score(100, 'Brooke', 'Dhondt', 'Finals', 2, 'Judge 6', 61);

    PERFORM update_run_score(100, 'Rebecca', 'Flynn', 'Finals', 1, 'Judge 1', 15);
    PERFORM update_run_score(100, 'Rebecca', 'Flynn', 'Finals', 1, 'Judge 2', 18);
    PERFORM update_run_score(100, 'Rebecca', 'Flynn', 'Finals', 1, 'Judge 3', 18);
    PERFORM update_run_score(100, 'Rebecca', 'Flynn', 'Finals', 1, 'Judge 4', 25);
    PERFORM update_run_score(100, 'Rebecca', 'Flynn', 'Finals', 1, 'Judge 5', 18);
    PERFORM update_run_score(100, 'Rebecca', 'Flynn', 'Finals', 1, 'Judge 6', 20);
    PERFORM update_run_score(100, 'Rebecca', 'Flynn', 'Finals', 3, 'Judge 1', 19);
    PERFORM update_run_score(100, 'Rebecca', 'Flynn', 'Finals', 3, 'Judge 2', 19);
    PERFORM update_run_score(100, 'Rebecca', 'Flynn', 'Finals', 3, 'Judge 3', 21);
    PERFORM update_run_score(100, 'Rebecca', 'Flynn', 'Finals', 3, 'Judge 4', 26);
    PERFORM update_run_score(100, 'Rebecca', 'Flynn', 'Finals', 3, 'Judge 5', 23);
    PERFORM update_run_score(100, 'Rebecca', 'Flynn', 'Finals', 3, 'Judge 6', 24);

    PERFORM update_run_score(100, 'Barrett', 'Hendrix', 'Finals', 1, 'Judge 1', 28);
    PERFORM update_run_score(100, 'Barrett', 'Hendrix', 'Finals', 1, 'Judge 2', 23);
    PERFORM update_run_score(100, 'Barrett', 'Hendrix', 'Finals', 1, 'Judge 3', 29);
    PERFORM update_run_score(100, 'Barrett', 'Hendrix', 'Finals', 1, 'Judge 4', 31);
    PERFORM update_run_score(100, 'Barrett', 'Hendrix', 'Finals', 1, 'Judge 5', 26);
    PERFORM update_run_score(100, 'Barrett', 'Hendrix', 'Finals', 1, 'Judge 6', 34);

    PERFORM update_run_score(100, 'Rongxi', 'Jin', 'Finals', 1, 'Judge 1', 25);
    PERFORM update_run_score(100, 'Rongxi', 'Jin', 'Finals', 1, 'Judge 2', 16);
    PERFORM update_run_score(100, 'Rongxi', 'Jin', 'Finals', 1, 'Judge 3', 22);
    PERFORM update_run_score(100, 'Rongxi', 'Jin', 'Finals', 1, 'Judge 4', 22);
    PERFORM update_run_score(100, 'Rongxi', 'Jin', 'Finals', 1, 'Judge 5', 23);
    PERFORM update_run_score(100, 'Rongxi', 'Jin', 'Finals', 1, 'Judge 6', 23);
    PERFORM update_run_score(100, 'Rongxi', 'Jin', 'Finals', 2, 'Judge 1', 47);
    PERFORM update_run_score(100, 'Rongxi', 'Jin', 'Finals', 2, 'Judge 2', 48);
    PERFORM update_run_score(100, 'Rongxi', 'Jin', 'Finals', 2, 'Judge 3', 53);
    PERFORM update_run_score(100, 'Rongxi', 'Jin', 'Finals', 2, 'Judge 4', 57);
    PERFORM update_run_score(100, 'Rongxi', 'Jin', 'Finals', 2, 'Judge 5', 53);
    PERFORM update_run_score(100, 'Rongxi', 'Jin', 'Finals', 2, 'Judge 6', 52);

    PERFORM update_run_score(100, 'Hahna', 'Norman', 'Finals', 1, 'Judge 1', 20);
    PERFORM update_run_score(100, 'Hahna', 'Norman', 'Finals', 1, 'Judge 2', 25);
    PERFORM update_run_score(100, 'Hahna', 'Norman', 'Finals', 1, 'Judge 3', 30);
    PERFORM update_run_score(100, 'Hahna', 'Norman', 'Finals', 1, 'Judge 4', 30);
    PERFORM update_run_score(100, 'Hahna', 'Norman', 'Finals', 1, 'Judge 5', 30);
    PERFORM update_run_score(100, 'Hahna', 'Norman', 'Finals', 1, 'Judge 6', 32);
    PERFORM update_run_score(100, 'Hahna', 'Norman', 'Finals', 3, 'Judge 1', 69);
    PERFORM update_run_score(100, 'Hahna', 'Norman', 'Finals', 3, 'Judge 2', 63);
    PERFORM update_run_score(100, 'Hahna', 'Norman', 'Finals', 3, 'Judge 3', 63);
    PERFORM update_run_score(100, 'Hahna', 'Norman', 'Finals', 3, 'Judge 4', 66);
    PERFORM update_run_score(100, 'Hahna', 'Norman', 'Finals', 3, 'Judge 5', 55);
    PERFORM update_run_score(100, 'Hahna', 'Norman', 'Finals', 3, 'Judge 6', 61);

    PERFORM update_run_score(100, 'Juliette', 'Pelchat', 'Finals', 1, 'Judge 1', 72);
    PERFORM update_run_score(100, 'Juliette', 'Pelchat', 'Finals', 1, 'Judge 2', 70);
    PERFORM update_run_score(100, 'Juliette', 'Pelchat', 'Finals', 1, 'Judge 3', 70);
    PERFORM update_run_score(100, 'Juliette', 'Pelchat', 'Finals', 1, 'Judge 4', 80);
    PERFORM update_run_score(100, 'Juliette', 'Pelchat', 'Finals', 1, 'Judge 5', 72);
    PERFORM update_run_score(100, 'Juliette', 'Pelchat', 'Finals', 1, 'Judge 6', 69);

    PERFORM update_run_score(100, 'Courtney', 'Rummel', 'Finals', 1, 'Judge 1', 17);
    PERFORM update_run_score(100, 'Courtney', 'Rummel', 'Finals', 1, 'Judge 2', 13);
    PERFORM update_run_score(100, 'Courtney', 'Rummel', 'Finals', 1, 'Judge 3', 12);
    PERFORM update_run_score(100, 'Courtney', 'Rummel', 'Finals', 1, 'Judge 4', 12);
    PERFORM update_run_score(100, 'Courtney', 'Rummel', 'Finals', 1, 'Judge 5', 20);
    PERFORM update_run_score(100, 'Courtney', 'Rummel', 'Finals', 1, 'Judge 6', 15);
    PERFORM update_run_score(100, 'Courtney', 'Rummel', 'Finals', 3, 'Judge 1', 43);
    PERFORM update_run_score(100, 'Courtney', 'Rummel', 'Finals', 3, 'Judge 2', 46);
    PERFORM update_run_score(100, 'Courtney', 'Rummel', 'Finals', 3, 'Judge 3', 50);
    PERFORM update_run_score(100, 'Courtney', 'Rummel', 'Finals', 3, 'Judge 4', 49);
    PERFORM update_run_score(100, 'Courtney', 'Rummel', 'Finals', 3, 'Judge 5', 49);
    PERFORM update_run_score(100, 'Courtney', 'Rummel', 'Finals', 3, 'Judge 6', 49);

    PERFORM update_run_score(100, 'Meila', 'Stalker', 'Finals', 2, 'Judge 1', 83);
    PERFORM update_run_score(100, 'Meila', 'Stalker', 'Finals', 2, 'Judge 2', 80);
    PERFORM update_run_score(100, 'Meila', 'Stalker', 'Finals', 2, 'Judge 3', 79);
    PERFORM update_run_score(100, 'Meila', 'Stalker', 'Finals', 2, 'Judge 4', 85);
    PERFORM update_run_score(100, 'Meila', 'Stalker', 'Finals', 2, 'Judge 5', 82);
    PERFORM update_run_score(100, 'Meila', 'Stalker', 'Finals', 2, 'Judge 6', 79);

    PERFORM update_run_score(100, 'Juliette', 'Vallerand', 'Finals', 1, 'Judge 1', 55);
    PERFORM update_run_score(100, 'Juliette', 'Vallerand', 'Finals', 1, 'Judge 2', 55);
    PERFORM update_run_score(100, 'Juliette', 'Vallerand', 'Finals', 1, 'Judge 3', 62);
    PERFORM update_run_score(100, 'Juliette', 'Vallerand', 'Finals', 1, 'Judge 4', 60);
    PERFORM update_run_score(100, 'Juliette', 'Vallerand', 'Finals', 1, 'Judge 5', 62);
    PERFORM update_run_score(100, 'Juliette', 'Vallerand', 'Finals', 1, 'Judge 6', 55);

    PERFORM update_run_score(100, 'Shirui', 'Xiong', 'Finals', 1, 'Judge 1', 12);
    PERFORM update_run_score(100, 'Shirui', 'Xiong', 'Finals', 1, 'Judge 2', 8);
    PERFORM update_run_score(100, 'Shirui', 'Xiong', 'Finals', 1, 'Judge 3', 8);
    PERFORM update_run_score(100, 'Shirui', 'Xiong', 'Finals', 1, 'Judge 4', 15);
    PERFORM update_run_score(100, 'Shirui', 'Xiong', 'Finals', 1, 'Judge 5', 16);
    PERFORM update_run_score(100, 'Shirui', 'Xiong', 'Finals', 1, 'Judge 6', 12);
    PERFORM update_run_score(100, 'Shirui', 'Xiong', 'Finals', 2, 'Judge 1', 75);
    PERFORM update_run_score(100, 'Shirui', 'Xiong', 'Finals', 2, 'Judge 2', 77);
    PERFORM update_run_score(100, 'Shirui', 'Xiong', 'Finals', 2, 'Judge 3', 75);
    PERFORM update_run_score(100, 'Shirui', 'Xiong', 'Finals', 2, 'Judge 4', 75);
    PERFORM update_run_score(100, 'Shirui', 'Xiong', 'Finals', 2, 'Judge 5', 80);
    PERFORM update_run_score(100, 'Shirui', 'Xiong', 'Finals', 2, 'Judge 6', 75);
    PERFORM update_run_score(100, 'Shirui', 'Xiong', 'Finals', 3, 'Judge 1', 69);

    PERFORM update_run_score(100, 'Xiaonan', 'Zhang', 'Finals', 1, 'Judge 1', 30);
    PERFORM update_run_score(100, 'Xiaonan', 'Zhang', 'Finals', 1, 'Judge 2', 21);
    PERFORM update_run_score(100, 'Xiaonan', 'Zhang', 'Finals', 1, 'Judge 3', 28);
    PERFORM update_run_score(100, 'Xiaonan', 'Zhang', 'Finals', 1, 'Judge 4', 27);
    PERFORM update_run_score(100, 'Xiaonan', 'Zhang', 'Finals', 1, 'Judge 5', 24);
    PERFORM update_run_score(100, 'Xiaonan', 'Zhang', 'Finals', 1, 'Judge 6', 29);
    PERFORM update_run_score(100, 'Xiaonan', 'Zhang', 'Finals', 2, 'Judge 1', 46);
    PERFORM update_run_score(100, 'Xiaonan', 'Zhang', 'Finals', 2, 'Judge 2', 47);
    PERFORM update_run_score(100, 'Xiaonan', 'Zhang', 'Finals', 2, 'Judge 3', 52);
    PERFORM update_run_score(100, 'Xiaonan', 'Zhang', 'Finals', 2, 'Judge 4', 52);
    PERFORM update_run_score(100, 'Xiaonan', 'Zhang', 'Finals', 2, 'Judge 5', 52);
    PERFORM update_run_score(100, 'Xiaonan', 'Zhang', 'Finals', 2, 'Judge 6', 52);
    PERFORM update_run_score(100, 'Xiaonan', 'Zhang', 'Finals', 3, 'Judge 1', 49);
    PERFORM update_run_score(100, 'Xiaonan', 'Zhang', 'Finals', 3, 'Judge 2', 53);
    PERFORM update_run_score(100, 'Xiaonan', 'Zhang', 'Finals', 3, 'Judge 3', 61);
    PERFORM update_run_score(100, 'Xiaonan', 'Zhang', 'Finals', 3, 'Judge 4', 58);
    PERFORM update_run_score(100, 'Xiaonan', 'Zhang', 'Finals', 3, 'Judge 5', 58);
    PERFORM update_run_score(100, 'Xiaonan', 'Zhang', 'Finals', 3, 'Judge 6', 60);

    RAISE NOTICE 'Step 6: Womens slopestyle finals scores populated successfully.';
END;
$$;
