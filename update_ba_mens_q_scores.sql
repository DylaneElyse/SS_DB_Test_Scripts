CREATE OR REPLACE PROCEDURE update_m_ba_q_scores()
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE NOTICE 'Step 6: Populating mens big air qualification scores...';

    PERFORM update_run_score(300, 'Zachary', 'Bezushko', 'Qualifications', 1, 'Judge 1', 53);
    PERFORM update_run_score(300, 'Zachary', 'Bezushko', 'Qualifications', 1, 'Judge 2', 61);
    PERFORM update_run_score(300, 'Zachary', 'Bezushko', 'Qualifications', 1, 'Judge 3', 58);

    PERFORM update_run_score(300, 'William', 'Buffey', 'Qualifications', 1, 'Judge 1', 86);
    PERFORM update_run_score(300, 'William', 'Buffey', 'Qualifications', 1, 'Judge 2', 85);
    PERFORM update_run_score(300, 'William', 'Buffey', 'Qualifications', 1, 'Judge 3', 82);

    PERFORM update_run_score(300, 'Fynn', 'Bullock-Womble', 'Qualifications', 1, 'Judge 1', 88);
    PERFORM update_run_score(300, 'Fynn', 'Bullock-Womble', 'Qualifications', 1, 'Judge 2', 88);
    PERFORM update_run_score(300, 'Fynn', 'Bullock-Womble', 'Qualifications', 1, 'Judge 3', 89);

    PERFORM update_run_score(300, 'Jonah', 'Cantelon', 'Qualifications', 1, 'Judge 1', 75);
    PERFORM update_run_score(300, 'Jonah', 'Cantelon', 'Qualifications', 1, 'Judge 2', 77);
    PERFORM update_run_score(300, 'Jonah', 'Cantelon', 'Qualifications', 1, 'Judge 3', 78);
    PERFORM update_run_score(300, 'Jonah', 'Cantelon', 'Qualifications', 2, 'Judge 1', 84);
    PERFORM update_run_score(300, 'Jonah', 'Cantelon', 'Qualifications', 2, 'Judge 2', 82);
    PERFORM update_run_score(300, 'Jonah', 'Cantelon', 'Qualifications', 2, 'Judge 3', 83);

    PERFORM update_run_score(300, 'Kobe', 'Cantelon', 'Qualifications', 1, 'Judge 1', 89);
    PERFORM update_run_score(300, 'Kobe', 'Cantelon', 'Qualifications', 1, 'Judge 2', 94);
    PERFORM update_run_score(300, 'Kobe', 'Cantelon', 'Qualifications', 1, 'Judge 3', 94);

    PERFORM update_run_score(300, 'Harry', 'Coleman', 'Qualifications', 1, 'Judge 1', 10);
    PERFORM update_run_score(300, 'Harry', 'Coleman', 'Qualifications', 1, 'Judge 2', 5);
    PERFORM update_run_score(300, 'Harry', 'Coleman', 'Qualifications', 1, 'Judge 3', 8);
    PERFORM update_run_score(300, 'Harry', 'Coleman', 'Qualifications', 2, 'Judge 1', 40);
    PERFORM update_run_score(300, 'Harry', 'Coleman', 'Qualifications', 2, 'Judge 2', 41);
    PERFORM update_run_score(300, 'Harry', 'Coleman', 'Qualifications', 2, 'Judge 3', 39);

    PERFORM update_run_score(300, 'Brock', 'Crouch', 'Qualifications', 1, 'Judge 1', 85);
    PERFORM update_run_score(300, 'Brock', 'Crouch', 'Qualifications', 1, 'Judge 2', 83);
    PERFORM update_run_score(300, 'Brock', 'Crouch', 'Qualifications', 1, 'Judge 3', 84);

    PERFORM update_run_score(300, 'Keenan', 'Denchuk', 'Qualifications', 1, 'Judge 1', 13);
    PERFORM update_run_score(300, 'Keenan', 'Denchuk', 'Qualifications', 1, 'Judge 2', 17);
    PERFORM update_run_score(300, 'Keenan', 'Denchuk', 'Qualifications', 1, 'Judge 3', 13);

    PERFORM update_run_score(300, 'Brooklyn', 'DePriest', 'Qualifications', 1, 'Judge 1', 14);
    PERFORM update_run_score(300, 'Brooklyn', 'DePriest', 'Qualifications', 1, 'Judge 2', 20);
    PERFORM update_run_score(300, 'Brooklyn', 'DePriest', 'Qualifications', 1, 'Judge 3', 15);
    PERFORM update_run_score(300, 'Brooklyn', 'DePriest', 'Qualifications', 2, 'Judge 1', 89);
    PERFORM update_run_score(300, 'Brooklyn', 'DePriest', 'Qualifications', 2, 'Judge 2', 95);
    PERFORM update_run_score(300, 'Brooklyn', 'DePriest', 'Qualifications', 2, 'Judge 3', 87);

    PERFORM update_run_score(300, 'Charles Emile', 'Dicaire', 'Qualifications', 1, 'Judge 1', 60);
    PERFORM update_run_score(300, 'Charles Emile', 'Dicaire', 'Qualifications', 1, 'Judge 2', 56);
    PERFORM update_run_score(300, 'Charles Emile', 'Dicaire', 'Qualifications', 1, 'Judge 3', 51);

    PERFORM update_run_score(300, 'Coltan', 'Eckert', 'Qualifications', 1, 'Judge 1', 92);
    PERFORM update_run_score(300, 'Coltan', 'Eckert', 'Qualifications', 1, 'Judge 2', 90);
    PERFORM update_run_score(300, 'Coltan', 'Eckert', 'Qualifications', 1, 'Judge 3', 93);

    PERFORM update_run_score(300, 'Laurent', 'Ethier', 'Qualifications', 1, 'Judge 1', 89);
    PERFORM update_run_score(300, 'Laurent', 'Ethier', 'Qualifications', 1, 'Judge 2', 92);
    PERFORM update_run_score(300, 'Laurent', 'Ethier', 'Qualifications', 1, 'Judge 3', 95);

    PERFORM update_run_score(300, 'Lys', 'Fedorowycz', 'Qualifications', 1, 'Judge 1', 17);
    PERFORM update_run_score(300, 'Lys', 'Fedorowycz', 'Qualifications', 1, 'Judge 2', 11);
    PERFORM update_run_score(300, 'Lys', 'Fedorowycz', 'Qualifications', 1, 'Judge 3', 14);

    PERFORM update_run_score(300, 'Lucas', 'Ferry', 'Qualifications', 1, 'Judge 1', 73);
    PERFORM update_run_score(300, 'Lucas', 'Ferry', 'Qualifications', 1, 'Judge 2', 73);
    PERFORM update_run_score(300, 'Lucas', 'Ferry', 'Qualifications', 1, 'Judge 3', 72);
    PERFORM update_run_score(300, 'Lucas', 'Ferry', 'Qualifications', 2, 'Judge 1', 80);
    PERFORM update_run_score(300, 'Lucas', 'Ferry', 'Qualifications', 2, 'Judge 2', 80);
    PERFORM update_run_score(300, 'Lucas', 'Ferry', 'Qualifications', 2, 'Judge 3', 81);

    PERFORM update_run_score(300, 'James', 'Garth', 'Qualifications', 1, 'Judge 1', 60);
    PERFORM update_run_score(300, 'James', 'Garth', 'Qualifications', 1, 'Judge 2', 60);
    PERFORM update_run_score(300, 'James', 'Garth', 'Qualifications', 1, 'Judge 3', 59);

    PERFORM update_run_score(300, 'Chunyu', 'Ge', 'Qualifications', 1, 'Judge 1', 18);
    PERFORM update_run_score(300, 'Chunyu', 'Ge', 'Qualifications', 1, 'Judge 2', 16);
    PERFORM update_run_score(300, 'Chunyu', 'Ge', 'Qualifications', 1, 'Judge 3', 14);
    PERFORM update_run_score(300, 'Chunyu', 'Ge', 'Qualifications', 2, 'Judge 1', 63);
    PERFORM update_run_score(300, 'Chunyu', 'Ge', 'Qualifications', 2, 'Judge 2', 65);
    PERFORM update_run_score(300, 'Chunyu', 'Ge', 'Qualifications', 2, 'Judge 3', 67);

    PERFORM update_run_score(300, 'Lj', 'Henriquez', 'Qualifications', 1, 'Judge 1', 44);
    PERFORM update_run_score(300, 'Lj', 'Henriquez', 'Qualifications', 1, 'Judge 2', 48);
    PERFORM update_run_score(300, 'Lj', 'Henriquez', 'Qualifications', 1, 'Judge 3', 49);

    PERFORM update_run_score(300, 'Colin', 'Hunter', 'Qualifications', 1, 'Judge 1', 47);
    PERFORM update_run_score(300, 'Colin', 'Hunter', 'Qualifications', 1, 'Judge 2', 50);
    PERFORM update_run_score(300, 'Colin', 'Hunter', 'Qualifications', 1, 'Judge 3', 50);

    PERFORM update_run_score(300, 'Tosh', 'Krauskopf', 'Qualifications', 1, 'Judge 1', 69);
    PERFORM update_run_score(300, 'Tosh', 'Krauskopf', 'Qualifications', 1, 'Judge 2', 67);
    PERFORM update_run_score(300, 'Tosh', 'Krauskopf', 'Qualifications', 1, 'Judge 3', 66);

    PERFORM update_run_score(300, 'Samuel', 'Kyme', 'Qualifications', 1, 'Judge 1', 11);
    PERFORM update_run_score(300, 'Samuel', 'Kyme', 'Qualifications', 1, 'Judge 2', 10);
    PERFORM update_run_score(300, 'Samuel', 'Kyme', 'Qualifications', 1, 'Judge 3', 10);

    PERFORM update_run_score(300, 'Stian', 'Langbakk', 'Qualifications', 1, 'Judge 1', 51);
    PERFORM update_run_score(300, 'Stian', 'Langbakk', 'Qualifications', 1, 'Judge 2', 58);
    PERFORM update_run_score(300, 'Stian', 'Langbakk', 'Qualifications', 1, 'Judge 3', 53);

    PERFORM update_run_score(300, 'Luke', 'Leal', 'Qualifications', 1, 'Judge 1', 85);
    PERFORM update_run_score(300, 'Luke', 'Leal', 'Qualifications', 1, 'Judge 2', 87);
    PERFORM update_run_score(300, 'Luke', 'Leal', 'Qualifications', 1, 'Judge 3', 86);

    PERFORM update_run_score(300, 'Haoyu', 'Liu', 'Qualifications', 1, 'Judge 1', 66);
    PERFORM update_run_score(300, 'Haoyu', 'Liu', 'Qualifications', 1, 'Judge 2', 68);
    PERFORM update_run_score(300, 'Haoyu', 'Liu', 'Qualifications', 1, 'Judge 3', 69);

    PERFORM update_run_score(300, 'Oliver', 'Martin', 'Qualifications', 1, 'Judge 1', 90);
    PERFORM update_run_score(300, 'Oliver', 'Martin', 'Qualifications', 1, 'Judge 2', 90);
    PERFORM update_run_score(300, 'Oliver', 'Martin', 'Qualifications', 1, 'Judge 3', 90);

    PERFORM update_run_score(300, 'Maddox', 'Matte', 'Qualifications', 1, 'Judge 1', 20);
    PERFORM update_run_score(300, 'Maddox', 'Matte', 'Qualifications', 1, 'Judge 2', 22);
    PERFORM update_run_score(300, 'Maddox', 'Matte', 'Qualifications', 1, 'Judge 3', 10);

    PERFORM update_run_score(300, 'Blake', 'Montalvo', 'Qualifications', 1, 'Judge 1', 65);
    PERFORM update_run_score(300, 'Blake', 'Montalvo', 'Qualifications', 1, 'Judge 2', 70);
    PERFORM update_run_score(300, 'Blake', 'Montalvo', 'Qualifications', 1, 'Judge 3', 72);

    PERFORM update_run_score(300, 'Cooper', 'Park', 'Qualifications', 1, 'Judge 1', 33);
    PERFORM update_run_score(300, 'Cooper', 'Park', 'Qualifications', 1, 'Judge 2', 30);
    PERFORM update_run_score(300, 'Cooper', 'Park', 'Qualifications', 1, 'Judge 3', 25);
    PERFORM update_run_score(300, 'Cooper', 'Park', 'Qualifications', 2, 'Judge 1', 77);
    PERFORM update_run_score(300, 'Cooper', 'Park', 'Qualifications', 2, 'Judge 2', 81);
    PERFORM update_run_score(300, 'Cooper', 'Park', 'Qualifications', 2, 'Judge 3', 79);

    PERFORM update_run_score(300, 'Neko', 'Reimer', 'Qualifications', 1, 'Judge 1', 52);
    PERFORM update_run_score(300, 'Neko', 'Reimer', 'Qualifications', 1, 'Judge 2', 54);
    PERFORM update_run_score(300, 'Neko', 'Reimer', 'Qualifications', 1, 'Judge 3', 48);
    PERFORM update_run_score(300, 'Neko', 'Reimer', 'Qualifications', 2, 'Judge 1', 59);
    PERFORM update_run_score(300, 'Neko', 'Reimer', 'Qualifications', 2, 'Judge 2', 61);
    PERFORM update_run_score(300, 'Neko', 'Reimer', 'Qualifications', 2, 'Judge 3', 54);

    PERFORM update_run_score(300, 'Brian', 'Rice', 'Qualifications', 1, 'Judge 1', 86);
    PERFORM update_run_score(300, 'Brian', 'Rice', 'Qualifications', 1, 'Judge 2', 86);
    PERFORM update_run_score(300, 'Brian', 'Rice', 'Qualifications', 1, 'Judge 3', 85);
    PERFORM update_run_score(300, 'Brian', 'Rice', 'Qualifications', 2, 'Judge 1', 90);
    PERFORM update_run_score(300, 'Brian', 'Rice', 'Qualifications', 2, 'Judge 2', 93);
    PERFORM update_run_score(300, 'Brian', 'Rice', 'Qualifications', 2, 'Judge 3', 96);

    PERFORM update_run_score(300, 'Alex', 'Schwab', 'Qualifications', 1, 'Judge 1', 75);
    PERFORM update_run_score(300, 'Alex', 'Schwab', 'Qualifications', 1, 'Judge 2', 68);
    PERFORM update_run_score(300, 'Alex', 'Schwab', 'Qualifications', 1, 'Judge 3', 71);

    PERFORM update_run_score(300, 'Alexandre', 'Slavinski', 'Qualifications', 1, 'Judge 1', 16);
    PERFORM update_run_score(300, 'Alexandre', 'Slavinski', 'Qualifications', 1, 'Judge 2', 15);
    PERFORM update_run_score(300, 'Alexandre', 'Slavinski', 'Qualifications', 1, 'Judge 3', 16);

    PERFORM update_run_score(300, 'Will', 'Solomon', 'Qualifications', 1, 'Judge 1', 11);
    PERFORM update_run_score(300, 'Will', 'Solomon', 'Qualifications', 1, 'Judge 2', 13);
    PERFORM update_run_score(300, 'Will', 'Solomon', 'Qualifications', 1, 'Judge 3', 12);

    PERFORM update_run_score(300, 'Kai', 'Spitzer', 'Qualifications', 1, 'Judge 1', 33);
    PERFORM update_run_score(300, 'Kai', 'Spitzer', 'Qualifications', 1, 'Judge 2', 38);
    PERFORM update_run_score(300, 'Kai', 'Spitzer', 'Qualifications', 1, 'Judge 3', 40);

    PERFORM update_run_score(300, 'Jack', 'Taggart', 'Qualifications', 1, 'Judge 1', 70);
    PERFORM update_run_score(300, 'Jack', 'Taggart', 'Qualifications', 1, 'Judge 2', 72);
    PERFORM update_run_score(300, 'Jack', 'Taggart', 'Qualifications', 1, 'Judge 3', 73);

    PERFORM update_run_score(300, 'Hayden', 'Tyler', 'Qualifications', 1, 'Judge 1', 16);
    PERFORM update_run_score(300, 'Hayden', 'Tyler', 'Qualifications', 1, 'Judge 2', 16);
    PERFORM update_run_score(300, 'Hayden', 'Tyler', 'Qualifications', 1, 'Judge 3', 18);
    PERFORM update_run_score(300, 'Hayden', 'Tyler', 'Qualifications', 2, 'Judge 1', 35);
    PERFORM update_run_score(300, 'Hayden', 'Tyler', 'Qualifications', 2, 'Judge 2', 27);
    PERFORM update_run_score(300, 'Hayden', 'Tyler', 'Qualifications', 2, 'Judge 3', 20);

    PERFORM update_run_score(300, 'Mateo', 'Vicentelo', 'Qualifications', 1, 'Judge 1', 12);
    PERFORM update_run_score(300, 'Mateo', 'Vicentelo', 'Qualifications', 1, 'Judge 2', 7);
    PERFORM update_run_score(300, 'Mateo', 'Vicentelo', 'Qualifications', 1, 'Judge 3', 11);
    PERFORM update_run_score(300, 'Mateo', 'Vicentelo', 'Qualifications', 2, 'Judge 1', 34);
    PERFORM update_run_score(300, 'Mateo', 'Vicentelo', 'Qualifications', 2, 'Judge 2', 35);
    PERFORM update_run_score(300, 'Mateo', 'Vicentelo', 'Qualifications', 2, 'Judge 3', 31);

    PERFORM update_run_score(300, 'Ryan', 'Vo', 'Qualifications', 1, 'Judge 1', 13);
    PERFORM update_run_score(300, 'Ryan', 'Vo', 'Qualifications', 1, 'Judge 2', 9);
    PERFORM update_run_score(300, 'Ryan', 'Vo', 'Qualifications', 1, 'Judge 3', 11);
    PERFORM update_run_score(300, 'Ryan', 'Vo', 'Qualifications', 2, 'Judge 1', 22);
    PERFORM update_run_score(300, 'Ryan', 'Vo', 'Qualifications', 2, 'Judge 2', 21);
    PERFORM update_run_score(300, 'Ryan', 'Vo', 'Qualifications', 2, 'Judge 3', 21);

    PERFORM update_run_score(300, 'Lane', 'Weaver', 'Qualifications', 1, 'Judge 1', 82);
    PERFORM update_run_score(300, 'Lane', 'Weaver', 'Qualifications', 1, 'Judge 2', 84);
    PERFORM update_run_score(300, 'Lane', 'Weaver', 'Qualifications', 1, 'Judge 3', 81);
    PERFORM update_run_score(300, 'Evan', 'Wrobel', 'Qualifications', 1, 'Judge 1', 71);
    PERFORM update_run_score(300, 'Evan', 'Wrobel', 'Qualifications', 1, 'Judge 2', 71);
    PERFORM update_run_score(300, 'Evan', 'Wrobel', 'Qualifications', 1, 'Judge 3', 70);

    RAISE NOTICE 'Step 6: Mens big air qualification scores populated successfully.';
END;
$$;