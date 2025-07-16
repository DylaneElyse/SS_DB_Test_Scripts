CREATE OR REPLACE PROCEDURE update_m_ss_q_scores()
LANGUAGE plpgsql
AS $$
BEGIN

    RAISE NOTICE 'Step 6: Populating mens slopestyle qualifications scores...';

    PERFORM update_run_score(100, 'Alejandro', 'Adib-Samii', 'Qualifications', 1, 'Judge 1', 43);
    PERFORM update_run_score(100, 'Alejandro', 'Adib-Samii', 'Qualifications', 1, 'Judge 2', 35);
    PERFORM update_run_score(100, 'Alejandro', 'Adib-Samii', 'Qualifications', 1, 'Judge 3', 44);
    PERFORM update_run_score(100, 'Alejandro', 'Adib-Samii', 'Qualifications', 2, 'Judge 1', 21);

    PERFORM update_run_score(100, 'Noah', 'Avallone', 'Qualifications', 1, 'Judge 1', 55);
    PERFORM update_run_score(100, 'Noah', 'Avallone', 'Qualifications', 1, 'Judge 2', 58);
    PERFORM update_run_score(100, 'Noah', 'Avallone', 'Qualifications', 1, 'Judge 3', 56);

    PERFORM update_run_score(100, 'Gus', 'Bald', 'Qualifications', 1, 'Judge 1', 10);
    PERFORM update_run_score(100, 'Gus', 'Bald', 'Qualifications', 1, 'Judge 2', 7);
    PERFORM update_run_score(100, 'Gus', 'Bald', 'Qualifications', 1, 'Judge 3', 9);
    PERFORM update_run_score(100, 'Gus', 'Bald', 'Qualifications', 2, 'Judge 1', 6);

    PERFORM update_run_score(100, 'Zachary', 'Bezushko', 'Qualifications', 1, 'Judge 1', 30);
    PERFORM update_run_score(100, 'Zachary', 'Bezushko', 'Qualifications', 1, 'Judge 2', 30);
    PERFORM update_run_score(100, 'Zachary', 'Bezushko', 'Qualifications', 1, 'Judge 3', 31);

    PERFORM update_run_score(100, 'Eli', 'Bouchard', 'Qualifications', 1, 'Judge 1', 15);
    PERFORM update_run_score(100, 'Eli', 'Bouchard', 'Qualifications', 1, 'Judge 2', 17);
    PERFORM update_run_score(100, 'Eli', 'Bouchard', 'Qualifications', 1, 'Judge 3', 15);
    PERFORM update_run_score(100, 'Eli', 'Bouchard', 'Qualifications', 2, 'Judge 1', 91);
    PERFORM update_run_score(100, 'Eli', 'Bouchard', 'Qualifications', 2, 'Judge 2', 95);
    PERFORM update_run_score(100, 'Eli', 'Bouchard', 'Qualifications', 2, 'Judge 3', 95);

    PERFORM update_run_score(100, 'William', 'Buffey', 'Qualifications', 1, 'Judge 1', 68);
    PERFORM update_run_score(100, 'William', 'Buffey', 'Qualifications', 1, 'Judge 2', 74);
    PERFORM update_run_score(100, 'William', 'Buffey', 'Qualifications', 1, 'Judge 3', 70);
    PERFORM update_run_score(100, 'William', 'Buffey', 'Qualifications', 2, 'Judge 1', 76);
    PERFORM update_run_score(100, 'William', 'Buffey', 'Qualifications', 2, 'Judge 2', 77);
    PERFORM update_run_score(100, 'William', 'Buffey', 'Qualifications', 2, 'Judge 3', 74);

    PERFORM update_run_score(100, 'Fynn', 'Bullock-Womble', 'Qualifications', 1, 'Judge 1', 75);
    PERFORM update_run_score(100, 'Fynn', 'Bullock-Womble', 'Qualifications', 1, 'Judge 2', 78);
    PERFORM update_run_score(100, 'Fynn', 'Bullock-Womble', 'Qualifications', 1, 'Judge 3', 76);

    PERFORM update_run_score(100, 'Jonah', 'Cantelon', 'Qualifications', 1, 'Judge 1', 16);
    PERFORM update_run_score(100, 'Jonah', 'Cantelon', 'Qualifications', 1, 'Judge 2', 11);
    PERFORM update_run_score(100, 'Jonah', 'Cantelon', 'Qualifications', 1, 'Judge 3', 13);

    PERFORM update_run_score(100, 'Kobe', 'Cantelon', 'Qualifications', 1, 'Judge 1', 73);
    PERFORM update_run_score(100, 'Kobe', 'Cantelon', 'Qualifications', 1, 'Judge 2', 67);
    PERFORM update_run_score(100, 'Kobe', 'Cantelon', 'Qualifications', 1, 'Judge 3', 66);

    PERFORM update_run_score(100, 'Brock', 'Crouch', 'Qualifications', 1, 'Judge 1', 84);
    PERFORM update_run_score(100, 'Brock', 'Crouch', 'Qualifications', 1, 'Judge 2', 82);
    PERFORM update_run_score(100, 'Brock', 'Crouch', 'Qualifications', 1, 'Judge 3', 85);

    PERFORM update_run_score(100, 'Keenan', 'Denchuk', 'Qualifications', 1, 'Judge 1', 14);
    PERFORM update_run_score(100, 'Keenan', 'Denchuk', 'Qualifications', 1, 'Judge 2', 15);
    PERFORM update_run_score(100, 'Keenan', 'Denchuk', 'Qualifications', 1, 'Judge 3', 12);
    PERFORM update_run_score(100, 'Keenan', 'Denchuk', 'Qualifications', 2, 'Judge 1', 25);
    PERFORM update_run_score(100, 'Keenan', 'Denchuk', 'Qualifications', 2, 'Judge 2', 23);
    PERFORM update_run_score(100, 'Keenan', 'Denchuk', 'Qualifications', 2, 'Judge 3', 25);

    PERFORM update_run_score(100, 'Brooklyn', 'DePriest', 'Qualifications', 1, 'Judge 1', 70);
    PERFORM update_run_score(100, 'Brooklyn', 'DePriest', 'Qualifications', 1, 'Judge 2', 74);
    PERFORM update_run_score(100, 'Brooklyn', 'DePriest', 'Qualifications', 1, 'Judge 3', 68);
    PERFORM update_run_score(100, 'Brooklyn', 'DePriest', 'Qualifications', 2, 'Judge 1', 60);
    PERFORM update_run_score(100, 'Brooklyn', 'DePriest', 'Qualifications', 2, 'Judge 2', 61);

    PERFORM update_run_score(100, 'Charles Emile', 'Dicaire', 'Qualifications', 1, 'Judge 1', 9);
    PERFORM update_run_score(100, 'Charles Emile', 'Dicaire', 'Qualifications', 1, 'Judge 2', 10);
    PERFORM update_run_score(100, 'Charles Emile', 'Dicaire', 'Qualifications', 1, 'Judge 3', 11);

    PERFORM update_run_score(100, 'Coltan', 'Eckert', 'Qualifications', 1, 'Judge 1', 70);
    PERFORM update_run_score(100, 'Coltan', 'Eckert', 'Qualifications', 1, 'Judge 2', 69);
    PERFORM update_run_score(100, 'Coltan', 'Eckert', 'Qualifications', 1, 'Judge 3', 69);
    PERFORM update_run_score(100, 'Laurent', 'Ethier', 'Qualifications', 1, 'Judge 1', 17);
    PERFORM update_run_score(100, 'Laurent', 'Ethier', 'Qualifications', 1, 'Judge 2', 21);
    PERFORM update_run_score(100, 'Laurent', 'Ethier', 'Qualifications', 1, 'Judge 3', 19);
    PERFORM update_run_score(100, 'Laurent', 'Ethier', 'Qualifications', 2, 'Judge 1', 13);

    PERFORM update_run_score(100, 'Lys', 'Fedorowycz', 'Qualifications', 1, 'Judge 1', 71);
    PERFORM update_run_score(100, 'Lys', 'Fedorowycz', 'Qualifications', 1, 'Judge 2', 72);
    PERFORM update_run_score(100, 'Lys', 'Fedorowycz', 'Qualifications', 1, 'Judge 3', 64);

    PERFORM update_run_score(100, 'Lucas', 'Ferry', 'Qualifications', 1, 'Judge 1', 45);
    PERFORM update_run_score(100, 'Lucas', 'Ferry', 'Qualifications', 1, 'Judge 2', 45);
    PERFORM update_run_score(100, 'Lucas', 'Ferry', 'Qualifications', 1, 'Judge 3', 46);
    PERFORM update_run_score(100, 'Lucas', 'Ferry', 'Qualifications', 2, 'Judge 1', 64);
    PERFORM update_run_score(100, 'Lucas', 'Ferry', 'Qualifications', 2, 'Judge 2', 64);
    PERFORM update_run_score(100, 'Lucas', 'Ferry', 'Qualifications', 2, 'Judge 3', 64);

    PERFORM update_run_score(100, 'Sean', 'FitzSimons', 'Qualifications', 1, 'Judge 1', 88);
    PERFORM update_run_score(100, 'Sean', 'FitzSimons', 'Qualifications', 1, 'Judge 2', 88);
    PERFORM update_run_score(100, 'Sean', 'FitzSimons', 'Qualifications', 1, 'Judge 3', 88);

    PERFORM update_run_score(100, 'James', 'Garth', 'Qualifications', 1, 'Judge 1', 50);
    PERFORM update_run_score(100, 'James', 'Garth', 'Qualifications', 1, 'Judge 2', 50);
    PERFORM update_run_score(100, 'James', 'Garth', 'Qualifications', 1, 'Judge 3', 61);
    PERFORM update_run_score(100, 'Chunyu', 'Ge', 'Qualifications', 1, 'Judge 1', 44);
    PERFORM update_run_score(100, 'Chunyu', 'Ge', 'Qualifications', 1, 'Judge 2', 40);
    PERFORM update_run_score(100, 'Chunyu', 'Ge', 'Qualifications', 1, 'Judge 3', 43);

    PERFORM update_run_score(100, 'Bendik', 'Gjerdalen', 'Qualifications', 1, 'Judge 1', 32);
    PERFORM update_run_score(100, 'Bendik', 'Gjerdalen', 'Qualifications', 1, 'Judge 2', 36);
    PERFORM update_run_score(100, 'Bendik', 'Gjerdalen', 'Qualifications', 1, 'Judge 3', 39);
    PERFORM update_run_score(100, 'Bendik', 'Gjerdalen', 'Qualifications', 2, 'Judge 1', 59);
    PERFORM update_run_score(100, 'Bendik', 'Gjerdalen', 'Qualifications', 2, 'Judge 2', 61);
    PERFORM update_run_score(100, 'Bendik', 'Gjerdalen', 'Qualifications', 2, 'Judge 3', 63);

    PERFORM update_run_score(100, 'Justus', 'Henkes', 'Qualifications', 1, 'Judge 1', 63);
    PERFORM update_run_score(100, 'Justus', 'Henkes', 'Qualifications', 1, 'Judge 2', 60);
    PERFORM update_run_score(100, 'Justus', 'Henkes', 'Qualifications', 1, 'Judge 3', 58);
    PERFORM update_run_score(100, 'Justus', 'Henkes', 'Qualifications', 2, 'Judge 1', 66);
    PERFORM update_run_score(100, 'Justus', 'Henkes', 'Qualifications', 2, 'Judge 2', 69);
    PERFORM update_run_score(100, 'Justus', 'Henkes', 'Qualifications', 2, 'Judge 3', 65);

    PERFORM update_run_score(100, 'Lj', 'Henriquez', 'Qualifications', 1, 'Judge 1', 62);
    PERFORM update_run_score(100, 'Lj', 'Henriquez', 'Qualifications', 1, 'Judge 2', 64);
    PERFORM update_run_score(100, 'Lj', 'Henriquez', 'Qualifications', 1, 'Judge 3', 61);
    PERFORM update_run_score(100, 'Lj', 'Henriquez', 'Qualifications', 2, 'Judge 1', 63);
    PERFORM update_run_score(100, 'Lj', 'Henriquez', 'Qualifications', 2, 'Judge 2', 67);
    PERFORM update_run_score(100, 'Lj', 'Henriquez', 'Qualifications', 2, 'Judge 3', 62);

    PERFORM update_run_score(100, 'Colin', 'Hunter', 'Qualifications', 1, 'Judge 1', 5);
    PERFORM update_run_score(100, 'Colin', 'Hunter', 'Qualifications', 1, 'Judge 2', 5);
    PERFORM update_run_score(100, 'Colin', 'Hunter', 'Qualifications', 1, 'Judge 3', 5);
    PERFORM update_run_score(100, 'Colin', 'Hunter', 'Qualifications', 2, 'Judge 1', 19);
    PERFORM update_run_score(100, 'Colin', 'Hunter', 'Qualifications', 2, 'Judge 2', 27);
    PERFORM update_run_score(100, 'Colin', 'Hunter', 'Qualifications', 2, 'Judge 3', 28);

    PERFORM update_run_score(100, 'Tosh', 'Krauskopf', 'Qualifications', 1, 'Judge 1', 68);
    PERFORM update_run_score(100, 'Tosh', 'Krauskopf', 'Qualifications', 1, 'Judge 2', 68);
    PERFORM update_run_score(100, 'Tosh', 'Krauskopf', 'Qualifications', 1, 'Judge 3', 65);
    PERFORM update_run_score(100, 'Tosh', 'Krauskopf', 'Qualifications', 2, 'Judge 1', 73);
    PERFORM update_run_score(100, 'Tosh', 'Krauskopf', 'Qualifications', 2, 'Judge 2', 75);
    PERFORM update_run_score(100, 'Tosh', 'Krauskopf', 'Qualifications', 2, 'Judge 3', 73);

    PERFORM update_run_score(100, 'Samuel', 'Kyme', 'Qualifications', 1, 'Judge 1', 30);
    PERFORM update_run_score(100, 'Samuel', 'Kyme', 'Qualifications', 1, 'Judge 2', 27);
    PERFORM update_run_score(100, 'Samuel', 'Kyme', 'Qualifications', 1, 'Judge 3', 27);
    PERFORM update_run_score(100, 'Samuel', 'Kyme', 'Qualifications', 2, 'Judge 1', 36);
    PERFORM update_run_score(100, 'Samuel', 'Kyme', 'Qualifications', 2, 'Judge 2', 31);
    PERFORM update_run_score(100, 'Samuel', 'Kyme', 'Qualifications', 2, 'Judge 3', 30);

    PERFORM update_run_score(100, 'Stian', 'Langbakk', 'Qualifications', 1, 'Judge 1', 61);
    PERFORM update_run_score(100, 'Stian', 'Langbakk', 'Qualifications', 1, 'Judge 2', 59);
    PERFORM update_run_score(100, 'Stian', 'Langbakk', 'Qualifications', 1, 'Judge 3', 62);
    PERFORM update_run_score(100, 'Stian', 'Langbakk', 'Qualifications', 2, 'Judge 1', 65);
    PERFORM update_run_score(100, 'Stian', 'Langbakk', 'Qualifications', 2, 'Judge 2', 61);
    PERFORM update_run_score(100, 'Stian', 'Langbakk', 'Qualifications', 2, 'Judge 3', 63);

    PERFORM update_run_score(100, 'Luke', 'Leal', 'Qualifications', 1, 'Judge 1', 51);
    PERFORM update_run_score(100, 'Luke', 'Leal', 'Qualifications', 1, 'Judge 2', 48);
    PERFORM update_run_score(100, 'Luke', 'Leal', 'Qualifications', 1, 'Judge 3', 45);

    PERFORM update_run_score(100, 'Haoyu', 'Liu', 'Qualifications', 1, 'Judge 1', 53);
    PERFORM update_run_score(100, 'Haoyu', 'Liu', 'Qualifications', 1, 'Judge 2', 50);
    PERFORM update_run_score(100, 'Haoyu', 'Liu', 'Qualifications', 1, 'Judge 3', 50);
    PERFORM update_run_score(100, 'Haoyu', 'Liu', 'Qualifications', 2, 'Judge 1', 51);

    PERFORM update_run_score(100, 'Oliver', 'Martin', 'Qualifications', 1, 'Judge 1', 85);
    PERFORM update_run_score(100, 'Oliver', 'Martin', 'Qualifications', 1, 'Judge 2', 85);
    PERFORM update_run_score(100, 'Oliver', 'Martin', 'Qualifications', 1, 'Judge 3', 85);
    PERFORM update_run_score(100, 'Oliver', 'Martin', 'Qualifications', 2, 'Judge 1', 79);

    PERFORM update_run_score(100, 'Maddox', 'Matte', 'Qualifications', 1, 'Judge 1', 23);
    PERFORM update_run_score(100, 'Maddox', 'Matte', 'Qualifications', 1, 'Judge 2', 25);
    PERFORM update_run_score(100, 'Maddox', 'Matte', 'Qualifications', 1, 'Judge 3', 23);
    PERFORM update_run_score(100, 'Maddox', 'Matte', 'Qualifications', 2, 'Judge 1', 75);
    PERFORM update_run_score(100, 'Maddox', 'Matte', 'Qualifications', 2, 'Judge 2', 66);
    PERFORM update_run_score(100, 'Maddox', 'Matte', 'Qualifications', 2, 'Judge 3', 67);

    PERFORM update_run_score(100, 'Maddox', 'McCorrister', 'Qualifications', 1, 'Judge 1', 7);
    PERFORM update_run_score(100, 'Maddox', 'McCorrister', 'Qualifications', 1, 'Judge 2', 14);
    PERFORM update_run_score(100, 'Maddox', 'McCorrister', 'Qualifications', 1, 'Judge 3', 11);
    PERFORM update_run_score(100, 'Maddox', 'McCorrister', 'Qualifications', 2, 'Judge 1', 10);
    PERFORM update_run_score(100, 'Maddox', 'McCorrister', 'Qualifications', 2, 'Judge 2', 19);
    PERFORM update_run_score(100, 'Maddox', 'McCorrister', 'Qualifications', 2, 'Judge 3', 16);

    PERFORM update_run_score(100, 'Blake', 'Montalvo', 'Qualifications', 1, 'Judge 1', 49);
    PERFORM update_run_score(100, 'Blake', 'Montalvo', 'Qualifications', 1, 'Judge 2', 47);
    PERFORM update_run_score(100, 'Blake', 'Montalvo', 'Qualifications', 1, 'Judge 3', 48);

    PERFORM update_run_score(100, 'Cooper', 'Park', 'Qualifications', 1, 'Judge 1', 60);
    PERFORM update_run_score(100, 'Cooper', 'Park', 'Qualifications', 1, 'Judge 2', 56);
    PERFORM update_run_score(100, 'Cooper', 'Park', 'Qualifications', 1, 'Judge 3', 59);

    PERFORM update_run_score(100, 'Neko', 'Reimer', 'Qualifications', 1, 'Judge 1', 10);
    PERFORM update_run_score(100, 'Neko', 'Reimer', 'Qualifications', 1, 'Judge 2', 10);
    PERFORM update_run_score(100, 'Neko', 'Reimer', 'Qualifications', 1, 'Judge 3', 10);
    PERFORM update_run_score(100, 'Neko', 'Reimer', 'Qualifications', 2, 'Judge 1', 57);
    PERFORM update_run_score(100, 'Neko', 'Reimer', 'Qualifications', 2, 'Judge 2', 59);
    PERFORM update_run_score(100, 'Neko', 'Reimer', 'Qualifications', 2, 'Judge 3', 58);

    PERFORM update_run_score(100, 'Brian', 'Rice', 'Qualifications', 1, 'Judge 1', 49);
    PERFORM update_run_score(100, 'Brian', 'Rice', 'Qualifications', 1, 'Judge 2', 46);
    PERFORM update_run_score(100, 'Brian', 'Rice', 'Qualifications', 1, 'Judge 3', 47);
    PERFORM update_run_score(100, 'Brian', 'Rice', 'Qualifications', 2, 'Judge 1', 59);
    PERFORM update_run_score(100, 'Brian', 'Rice', 'Qualifications', 2, 'Judge 2', 60);
    PERFORM update_run_score(100, 'Brian', 'Rice', 'Qualifications', 2, 'Judge 3', 60);

    PERFORM update_run_score(100, 'Alex', 'Schwab', 'Qualifications', 1, 'Judge 1', 54);
    PERFORM update_run_score(100, 'Alex', 'Schwab', 'Qualifications', 1, 'Judge 2', 54);
    PERFORM update_run_score(100, 'Alex', 'Schwab', 'Qualifications', 1, 'Judge 3', 52);

    PERFORM update_run_score(100, 'Alexandre', 'Slavinski', 'Qualifications', 1, 'Judge 1', 11);
    PERFORM update_run_score(100, 'Alexandre', 'Slavinski', 'Qualifications', 1, 'Judge 2', 6);
    PERFORM update_run_score(100, 'Alexandre', 'Slavinski', 'Qualifications', 1, 'Judge 3', 16);
    PERFORM update_run_score(100, 'Alexandre', 'Slavinski', 'Qualifications', 2, 'Judge 1', 17);
    PERFORM update_run_score(100, 'Alexandre', 'Slavinski', 'Qualifications', 2, 'Judge 2', 17);
    PERFORM update_run_score(100, 'Alexandre', 'Slavinski', 'Qualifications', 2, 'Judge 3', 20);

    PERFORM update_run_score(100, 'Truth', 'Smith', 'Qualifications', 1, 'Judge 1', 77);
    PERFORM update_run_score(100, 'Truth', 'Smith', 'Qualifications', 1, 'Judge 2', 84);
    PERFORM update_run_score(100, 'Truth', 'Smith', 'Qualifications', 1, 'Judge 3', 82);
    PERFORM update_run_score(100, 'Truth', 'Smith', 'Qualifications', 2, 'Judge 1', 78);
    PERFORM update_run_score(100, 'Truth', 'Smith', 'Qualifications', 2, 'Judge 2', 85);
    PERFORM update_run_score(100, 'Truth', 'Smith', 'Qualifications', 2, 'Judge 3', 83);

    PERFORM update_run_score(100, 'Will', 'Solomon', 'Qualifications', 1, 'Judge 1', 65);
    PERFORM update_run_score(100, 'Will', 'Solomon', 'Qualifications', 1, 'Judge 2', 63);
    PERFORM update_run_score(100, 'Will', 'Solomon', 'Qualifications', 1, 'Judge 3', 60);
    PERFORM update_run_score(100, 'Will', 'Solomon', 'Qualifications', 2, 'Judge 1', 40);

    PERFORM update_run_score(100, 'Jack', 'Spence', 'Qualifications', 1, 'Judge 1', 53);
    PERFORM update_run_score(100, 'Jack', 'Spence', 'Qualifications', 1, 'Judge 2', 49);
    PERFORM update_run_score(100, 'Jack', 'Spence', 'Qualifications', 1, 'Judge 3', 49);

    PERFORM update_run_score(100, 'Kai', 'Spitzer', 'Qualifications', 1, 'Judge 1', 18);
    PERFORM update_run_score(100, 'Kai', 'Spitzer', 'Qualifications', 1, 'Judge 2', 18);
    PERFORM update_run_score(100, 'Kai', 'Spitzer', 'Qualifications', 1, 'Judge 3', 19);
    PERFORM update_run_score(100, 'Kai', 'Spitzer', 'Qualifications', 2, 'Judge 1', 20);
    PERFORM update_run_score(100, 'Kai', 'Spitzer', 'Qualifications', 2, 'Judge 2', 26);
    PERFORM update_run_score(100, 'Kai', 'Spitzer', 'Qualifications', 2, 'Judge 3', 23);

    PERFORM update_run_score(100, 'Jack', 'Taggart', 'Qualifications', 1, 'Judge 1', 57);
    PERFORM update_run_score(100, 'Jack', 'Taggart', 'Qualifications', 1, 'Judge 2', 53);
    PERFORM update_run_score(100, 'Jack', 'Taggart', 'Qualifications', 1, 'Judge 3', 56);

    PERFORM update_run_score(100, 'Augustinho', 'Teixeira', 'Qualifications', 1, 'Judge 1', 16);
    PERFORM update_run_score(100, 'Augustinho', 'Teixeira', 'Qualifications', 1, 'Judge 2', 18);
    PERFORM update_run_score(100, 'Augustinho', 'Teixeira', 'Qualifications', 1, 'Judge 3', 17);
    PERFORM update_run_score(100, 'Augustinho', 'Teixeira', 'Qualifications', 2, 'Judge 1', 22);
    PERFORM update_run_score(100, 'Augustinho', 'Teixeira', 'Qualifications', 2, 'Judge 2', 24);
    PERFORM update_run_score(100, 'Augustinho', 'Teixeira', 'Qualifications', 2, 'Judge 3', 22);

    PERFORM update_run_score(100, 'Hayden', 'Tyler', 'Qualifications', 1, 'Judge 1', 10);
    PERFORM update_run_score(100, 'Hayden', 'Tyler', 'Qualifications', 1, 'Judge 2', 16);
    PERFORM update_run_score(100, 'Hayden', 'Tyler', 'Qualifications', 1, 'Judge 3', 15);
    PERFORM update_run_score(100, 'Hayden', 'Tyler', 'Qualifications', 2, 'Judge 1', 15);
    PERFORM update_run_score(100, 'Hayden', 'Tyler', 'Qualifications', 2, 'Judge 2', 21);
    PERFORM update_run_score(100, 'Hayden', 'Tyler', 'Qualifications', 2, 'Judge 3', 21);

    PERFORM update_run_score(100, 'Mateo', 'Vicentelo', 'Qualifications', 1, 'Judge 1', 12);
    PERFORM update_run_score(100, 'Mateo', 'Vicentelo', 'Qualifications', 1, 'Judge 2', 12);
    PERFORM update_run_score(100, 'Mateo', 'Vicentelo', 'Qualifications', 1, 'Judge 3', 12);

    PERFORM update_run_score(100, 'Ryan', 'Vo', 'Qualifications', 1, 'Judge 1', 23);
    PERFORM update_run_score(100, 'Ryan', 'Vo', 'Qualifications', 1, 'Judge 2', 24);
    PERFORM update_run_score(100, 'Ryan', 'Vo', 'Qualifications', 1, 'Judge 3', 24);
    PERFORM update_run_score(100, 'Ryan', 'Vo', 'Qualifications', 2, 'Judge 1', 30);
    PERFORM update_run_score(100, 'Ryan', 'Vo', 'Qualifications', 2, 'Judge 2', 33);
    PERFORM update_run_score(100, 'Ryan', 'Vo', 'Qualifications', 2, 'Judge 3', 30);

    PERFORM update_run_score(100, 'Lane', 'Weaver', 'Qualifications', 1, 'Judge 1', 67);
    PERFORM update_run_score(100, 'Lane', 'Weaver', 'Qualifications', 1, 'Judge 2', 65);
    PERFORM update_run_score(100, 'Lane', 'Weaver', 'Qualifications', 1, 'Judge 3', 62);

    PERFORM update_run_score(100, 'Keani', 'Wilson', 'Qualifications', 1, 'Judge 1', 10);
    PERFORM update_run_score(100, 'Keani', 'Wilson', 'Qualifications', 1, 'Judge 2', 8);
    PERFORM update_run_score(100, 'Keani', 'Wilson', 'Qualifications', 1, 'Judge 3', 17);

    PERFORM update_run_score(100, 'Evan', 'Wrobel', 'Qualifications', 1, 'Judge 1', 19);
    PERFORM update_run_score(100, 'Evan', 'Wrobel', 'Qualifications', 1, 'Judge 2', 19);
    PERFORM update_run_score(100, 'Evan', 'Wrobel', 'Qualifications', 1, 'Judge 3', 13);
    PERFORM update_run_score(100, 'Evan', 'Wrobel', 'Qualifications', 2, 'Judge 1', 12);
    PERFORM update_run_score(100, 'Evan', 'Wrobel', 'Qualifications', 2, 'Judge 2', 13);

    PERFORM update_run_score(100, 'Solomon', 'Wynnyk', 'Qualifications', 1, 'Judge 1', 22);
    PERFORM update_run_score(100, 'Solomon', 'Wynnyk', 'Qualifications', 1, 'Judge 2', 20);
    PERFORM update_run_score(100, 'Solomon', 'Wynnyk', 'Qualifications', 1, 'Judge 3', 22);

    RAISE NOTICE 'Step 6: Mens slopestyle qualifications scores populated successfully.';

END;
$$;
