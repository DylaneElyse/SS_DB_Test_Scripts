CREATE OR REPLACE PROCEDURE update_m_hp_f_scores()
LANGUAGE plpgsql
AS $$
BEGIN

    RAISE NOTICE 'Step 6: Populating mens halfpipe finals scores...';

    PERFORM update_run_score(200, 'Noah', 'Avallone', 'Finals', 1, 'Judge 1', 80);
    PERFORM update_run_score(200, 'Noah', 'Avallone', 'Finals', 1, 'Judge 2', 84);
    PERFORM update_run_score(200, 'Noah', 'Avallone', 'Finals', 1, 'Judge 3', 85);
    PERFORM update_run_score(200, 'Noah', 'Avallone', 'Finals', 1, 'Judge 4', 88);
    PERFORM update_run_score(200, 'Noah', 'Avallone', 'Finals', 1, 'Judge 5', 82);

    PERFORM update_run_score(200, 'Quinn', 'Bachman', 'Finals', 1, 'Judge 1', 44);
    PERFORM update_run_score(200, 'Quinn', 'Bachman', 'Finals', 1, 'Judge 2', 38);
    PERFORM update_run_score(200, 'Quinn', 'Bachman', 'Finals', 1, 'Judge 3', 28);
    PERFORM update_run_score(200, 'Quinn', 'Bachman', 'Finals', 1, 'Judge 4', 36);
    PERFORM update_run_score(200, 'Quinn', 'Bachman', 'Finals', 1, 'Judge 5', 34);

    PERFORM update_run_score(200, 'Lucas', 'Briggs', 'Finals', 1, 'Judge 1', 22);
    PERFORM update_run_score(200, 'Lucas', 'Briggs', 'Finals', 1, 'Judge 2', 19);
    PERFORM update_run_score(200, 'Lucas', 'Briggs', 'Finals', 1, 'Judge 3', 25);
    PERFORM update_run_score(200, 'Lucas', 'Briggs', 'Finals', 1, 'Judge 4', 22);
    PERFORM update_run_score(200, 'Lucas', 'Briggs', 'Finals', 1, 'Judge 5', 24);

    PERFORM update_run_score(200, 'Orion', 'Casas', 'Finals', 1, 'Judge 1', 15);
    PERFORM update_run_score(200, 'Orion', 'Casas', 'Finals', 1, 'Judge 2', 15);
    PERFORM update_run_score(200, 'Orion', 'Casas', 'Finals', 1, 'Judge 3', 20);
    PERFORM update_run_score(200, 'Orion', 'Casas', 'Finals', 1, 'Judge 4', 20);
    PERFORM update_run_score(200, 'Orion', 'Casas', 'Finals', 1, 'Judge 5', 20);
    PERFORM update_run_score(200, 'Orion', 'Casas', 'Finals', 2, 'Judge 1', 77);
    PERFORM update_run_score(200, 'Orion', 'Casas', 'Finals', 2, 'Judge 2', 85);
    PERFORM update_run_score(200, 'Orion', 'Casas', 'Finals', 2, 'Judge 3', 80);
    PERFORM update_run_score(200, 'Orion', 'Casas', 'Finals', 2, 'Judge 4', 82);
    PERFORM update_run_score(200, 'Orion', 'Casas', 'Finals', 2, 'Judge 5', 79);

    PERFORM update_run_score(200, 'Harry', 'Coleman', 'Finals', 1, 'Judge 1', 50);
    PERFORM update_run_score(200, 'Harry', 'Coleman', 'Finals', 1, 'Judge 2', 49);
    PERFORM update_run_score(200, 'Harry', 'Coleman', 'Finals', 1, 'Judge 3', 42);
    PERFORM update_run_score(200, 'Harry', 'Coleman', 'Finals', 1, 'Judge 4', 46);
    PERFORM update_run_score(200, 'Harry', 'Coleman', 'Finals', 1, 'Judge 5', 48);

    PERFORM update_run_score(200, 'Taitten', 'Cowan', 'Finals', 1, 'Judge 1', 27);
    PERFORM update_run_score(200, 'Taitten', 'Cowan', 'Finals', 1, 'Judge 2', 32);
    PERFORM update_run_score(200, 'Taitten', 'Cowan', 'Finals', 1, 'Judge 3', 33);
    PERFORM update_run_score(200, 'Taitten', 'Cowan', 'Finals', 1, 'Judge 4', 30);
    PERFORM update_run_score(200, 'Taitten', 'Cowan', 'Finals', 1, 'Judge 5', 35);
    PERFORM update_run_score(200, 'Taitten', 'Cowan', 'Finals', 2, 'Judge 1', 66);
    PERFORM update_run_score(200, 'Taitten', 'Cowan', 'Finals', 2, 'Judge 2', 70);
    PERFORM update_run_score(200, 'Taitten', 'Cowan', 'Finals', 2, 'Judge 3', 73);
    PERFORM update_run_score(200, 'Taitten', 'Cowan', 'Finals', 2, 'Judge 4', 75);
    PERFORM update_run_score(200, 'Taitten', 'Cowan', 'Finals', 2, 'Judge 5', 70);

    PERFORM update_run_score(200, 'Yuyang', 'Dai', 'Finals', 1, 'Judge 1', 38);
    PERFORM update_run_score(200, 'Yuyang', 'Dai', 'Finals', 1, 'Judge 2', 46);
    PERFORM update_run_score(200, 'Yuyang', 'Dai', 'Finals', 1, 'Judge 3', 40);
    PERFORM update_run_score(200, 'Yuyang', 'Dai', 'Finals', 1, 'Judge 4', 32);
    PERFORM update_run_score(200, 'Yuyang', 'Dai', 'Finals', 1, 'Judge 5', 39);
    PERFORM update_run_score(200, 'Yuyang', 'Dai', 'Finals', 2, 'Judge 1', 60);
    PERFORM update_run_score(200, 'Yuyang', 'Dai', 'Finals', 2, 'Judge 2', 63);
    PERFORM update_run_score(200, 'Yuyang', 'Dai', 'Finals', 2, 'Judge 3', 53);
    PERFORM update_run_score(200, 'Yuyang', 'Dai', 'Finals', 2, 'Judge 4', 63);
    PERFORM update_run_score(200, 'Yuyang', 'Dai', 'Finals', 2, 'Judge 5', 52);

    PERFORM update_run_score(200, 'Kyle', 'Germain', 'Finals', 1, 'Judge 1', 40);
    PERFORM update_run_score(200, 'Kyle', 'Germain', 'Finals', 1, 'Judge 2', 45);
    PERFORM update_run_score(200, 'Kyle', 'Germain', 'Finals', 1, 'Judge 3', 35);
    PERFORM update_run_score(200, 'Kyle', 'Germain', 'Finals', 1, 'Judge 4', 42);
    PERFORM update_run_score(200, 'Kyle', 'Germain', 'Finals', 1, 'Judge 5', 40);
    PERFORM update_run_score(200, 'Kyle', 'Germain', 'Finals', 2, 'Judge 1', 41);
    PERFORM update_run_score(200, 'Kyle', 'Germain', 'Finals', 2, 'Judge 2', 48);
    PERFORM update_run_score(200, 'Kyle', 'Germain', 'Finals', 2, 'Judge 3', 39);
    PERFORM update_run_score(200, 'Kyle', 'Germain', 'Finals', 2, 'Judge 4', 43);
    PERFORM update_run_score(200, 'Kyle', 'Germain', 'Finals', 2, 'Judge 5', 41);

    PERFORM update_run_score(200, 'Tristam', 'Henkels', 'Finals', 1, 'Judge 1', 30);
    PERFORM update_run_score(200, 'Tristam', 'Henkels', 'Finals', 1, 'Judge 2', 35);
    PERFORM update_run_score(200, 'Tristam', 'Henkels', 'Finals', 1, 'Judge 3', 30);
    PERFORM update_run_score(200, 'Tristam', 'Henkels', 'Finals', 1, 'Judge 4', 28);
    PERFORM update_run_score(200, 'Tristam', 'Henkels', 'Finals', 1, 'Judge 5', 33);
    PERFORM update_run_score(200, 'Tristam', 'Henkels', 'Finals', 2, 'Judge 1', 72);
    PERFORM update_run_score(200, 'Tristam', 'Henkels', 'Finals', 2, 'Judge 2', 74);
    PERFORM update_run_score(200, 'Tristam', 'Henkels', 'Finals', 2, 'Judge 3', 77);
    PERFORM update_run_score(200, 'Tristam', 'Henkels', 'Finals', 2, 'Judge 4', 78);
    PERFORM update_run_score(200, 'Tristam', 'Henkels', 'Finals', 2, 'Judge 5', 69);

    PERFORM update_run_score(200, 'Samuel', 'Kyme', 'Finals', 1, 'Judge 1', 25);
    PERFORM update_run_score(200, 'Samuel', 'Kyme', 'Finals', 1, 'Judge 2', 32);
    PERFORM update_run_score(200, 'Samuel', 'Kyme', 'Finals', 1, 'Judge 3', 21);
    PERFORM update_run_score(200, 'Samuel', 'Kyme', 'Finals', 1, 'Judge 4', 24);
    PERFORM update_run_score(200, 'Samuel', 'Kyme', 'Finals', 1, 'Judge 5', 30);
    PERFORM update_run_score(200, 'Samuel', 'Kyme', 'Finals', 2, 'Judge 1', 33);
    PERFORM update_run_score(200, 'Samuel', 'Kyme', 'Finals', 2, 'Judge 2', 40);
    PERFORM update_run_score(200, 'Samuel', 'Kyme', 'Finals', 2, 'Judge 3', 29);
    PERFORM update_run_score(200, 'Samuel', 'Kyme', 'Finals', 2, 'Judge 4', 29);
    PERFORM update_run_score(200, 'Samuel', 'Kyme', 'Finals', 2, 'Judge 5', 34);

    PERFORM update_run_score(200, 'Terje', 'LaMont', 'Finals', 1, 'Judge 1', 11);
    PERFORM update_run_score(200, 'Terje', 'LaMont', 'Finals', 1, 'Judge 2', 13);
    PERFORM update_run_score(200, 'Terje', 'LaMont', 'Finals', 1, 'Judge 3', 13);
    PERFORM update_run_score(200, 'Terje', 'LaMont', 'Finals', 1, 'Judge 4', 14);
    PERFORM update_run_score(200, 'Terje', 'LaMont', 'Finals', 1, 'Judge 5', 18);
    PERFORM update_run_score(200, 'Terje', 'LaMont', 'Finals', 2, 'Judge 1', 55);
    PERFORM update_run_score(200, 'Terje', 'LaMont', 'Finals', 2, 'Judge 2', 63);
    PERFORM update_run_score(200, 'Terje', 'LaMont', 'Finals', 2, 'Judge 3', 59);
    PERFORM update_run_score(200, 'Terje', 'LaMont', 'Finals', 2, 'Judge 4', 59);
    PERFORM update_run_score(200, 'Terje', 'LaMont', 'Finals', 2, 'Judge 5', 58);

    PERFORM update_run_score(200, 'Abenu', 'Levere', 'Finals', 1, 'Judge 1', 31);
    PERFORM update_run_score(200, 'Abenu', 'Levere', 'Finals', 1, 'Judge 2', 35);
    PERFORM update_run_score(200, 'Abenu', 'Levere', 'Finals', 1, 'Judge 3', 26);
    PERFORM update_run_score(200, 'Abenu', 'Levere', 'Finals', 1, 'Judge 4', 26);
    PERFORM update_run_score(200, 'Abenu', 'Levere', 'Finals', 1, 'Judge 5', 28);
    PERFORM update_run_score(200, 'Abenu', 'Levere', 'Finals', 2, 'Judge 1', 34);
    PERFORM update_run_score(200, 'Abenu', 'Levere', 'Finals', 2, 'Judge 2', 41);
    PERFORM update_run_score(200, 'Abenu', 'Levere', 'Finals', 2, 'Judge 3', 35);
    PERFORM update_run_score(200, 'Abenu', 'Levere', 'Finals', 2, 'Judge 4', 31);
    PERFORM update_run_score(200, 'Abenu', 'Levere', 'Finals', 2, 'Judge 5', 36);

    PERFORM update_run_score(200, 'Blake', 'Montalvo', 'Finals', 1, 'Judge 1', 42);
    PERFORM update_run_score(200, 'Blake', 'Montalvo', 'Finals', 1, 'Judge 2', 44);
    PERFORM update_run_score(200, 'Blake', 'Montalvo', 'Finals', 1, 'Judge 3', 38);
    PERFORM update_run_score(200, 'Blake', 'Montalvo', 'Finals', 1, 'Judge 4', 40);
    PERFORM update_run_score(200, 'Blake', 'Montalvo', 'Finals', 1, 'Judge 5', 42);

    PERFORM update_run_score(200, 'Kiran', 'Pershad', 'Finals', 1, 'Judge 1', 71);
    PERFORM update_run_score(200, 'Kiran', 'Pershad', 'Finals', 1, 'Judge 2', 75);
    PERFORM update_run_score(200, 'Kiran', 'Pershad', 'Finals', 1, 'Judge 3', 66);
    PERFORM update_run_score(200, 'Kiran', 'Pershad', 'Finals', 1, 'Judge 4', 68);
    PERFORM update_run_score(200, 'Kiran', 'Pershad', 'Finals', 1, 'Judge 5', 62);

    PERFORM update_run_score(200, 'Augustinho', 'Teixeira', 'Finals', 1, 'Judge 1', 2);
    PERFORM update_run_score(200, 'Augustinho', 'Teixeira', 'Finals', 1, 'Judge 2', 10);
    PERFORM update_run_score(200, 'Augustinho', 'Teixeira', 'Finals', 1, 'Judge 3', 7);
    PERFORM update_run_score(200, 'Augustinho', 'Teixeira', 'Finals', 1, 'Judge 4', 8);
    PERFORM update_run_score(200, 'Augustinho', 'Teixeira', 'Finals', 1, 'Judge 5', 8);
    PERFORM update_run_score(200, 'Augustinho', 'Teixeira', 'Finals', 2, 'Judge 1', 70);
    PERFORM update_run_score(200, 'Augustinho', 'Teixeira', 'Finals', 2, 'Judge 2', 80);
    PERFORM update_run_score(200, 'Augustinho', 'Teixeira', 'Finals', 2, 'Judge 3', 78);
    PERFORM update_run_score(200, 'Augustinho', 'Teixeira', 'Finals', 2, 'Judge 4', 79);
    PERFORM update_run_score(200, 'Augustinho', 'Teixeira', 'Finals', 2, 'Judge 5', 72);

    PERFORM update_run_score(200, 'Joao', 'Teixeira', 'Finals', 1, 'Judge 1', 7);
    PERFORM update_run_score(200, 'Joao', 'Teixeira', 'Finals', 1, 'Judge 2', 10);
    PERFORM update_run_score(200, 'Joao', 'Teixeira', 'Finals', 1, 'Judge 3', 9);
    PERFORM update_run_score(200, 'Joao', 'Teixeira', 'Finals', 1, 'Judge 4', 12);
    PERFORM update_run_score(200, 'Joao', 'Teixeira', 'Finals', 1, 'Judge 5', 11);
    PERFORM update_run_score(200, 'Joao', 'Teixeira', 'Finals', 2, 'Judge 1', 39);
    PERFORM update_run_score(200, 'Joao', 'Teixeira', 'Finals', 2, 'Judge 2', 45);
    PERFORM update_run_score(200, 'Joao', 'Teixeira', 'Finals', 2, 'Judge 3', 36);
    PERFORM update_run_score(200, 'Joao', 'Teixeira', 'Finals', 2, 'Judge 4', 37);
    PERFORM update_run_score(200, 'Joao', 'Teixeira', 'Finals', 2, 'Judge 5', 41);

    PERFORM update_run_score(200, 'Siddhartha', 'Ullah', 'Finals', 1, 'Judge 1', 73);
    PERFORM update_run_score(200, 'Siddhartha', 'Ullah', 'Finals', 1, 'Judge 2', 82);
    PERFORM update_run_score(200, 'Siddhartha', 'Ullah', 'Finals', 1, 'Judge 3', 83);
    PERFORM update_run_score(200, 'Siddhartha', 'Ullah', 'Finals', 1, 'Judge 4', 84);
    PERFORM update_run_score(200, 'Siddhartha', 'Ullah', 'Finals', 1, 'Judge 5', 75);
    PERFORM update_run_score(200, 'Siddhartha', 'Ullah', 'Finals', 2, 'Judge 1', 82);
    PERFORM update_run_score(200, 'Siddhartha', 'Ullah', 'Finals', 2, 'Judge 2', 86);
    PERFORM update_run_score(200, 'Siddhartha', 'Ullah', 'Finals', 2, 'Judge 3', 87);
    PERFORM update_run_score(200, 'Siddhartha', 'Ullah', 'Finals', 2, 'Judge 4', 87);
    PERFORM update_run_score(200, 'Siddhartha', 'Ullah', 'Finals', 2, 'Judge 5', 84);

    PERFORM update_run_score(200, 'Ryan', 'Vo', 'Finals', 1, 'Judge 1', 68);
    PERFORM update_run_score(200, 'Ryan', 'Vo', 'Finals', 1, 'Judge 2', 74);
    PERFORM update_run_score(200, 'Ryan', 'Vo', 'Finals', 1, 'Judge 3', 75);
    PERFORM update_run_score(200, 'Ryan', 'Vo', 'Finals', 1, 'Judge 4', 76);
    PERFORM update_run_score(200, 'Ryan', 'Vo', 'Finals', 1, 'Judge 5', 71);

    PERFORM update_run_score(200, 'Aaron', 'Wild', 'Finals', 1, 'Judge 1', 60);
    PERFORM update_run_score(200, 'Aaron', 'Wild', 'Finals', 1, 'Judge 2', 65);
    PERFORM update_run_score(200, 'Aaron', 'Wild', 'Finals', 1, 'Judge 3', 70);
    PERFORM update_run_score(200, 'Aaron', 'Wild', 'Finals', 1, 'Judge 4', 70);
    PERFORM update_run_score(200, 'Aaron', 'Wild', 'Finals', 1, 'Judge 5', 73);

    PERFORM update_run_score(200, 'Jason', 'Wolle', 'Finals', 1, 'Judge 1', 85);
    PERFORM update_run_score(200, 'Jason', 'Wolle', 'Finals', 1, 'Judge 2', 88);
    PERFORM update_run_score(200, 'Jason', 'Wolle', 'Finals', 1, 'Judge 3', 90);
    PERFORM update_run_score(200, 'Jason', 'Wolle', 'Finals', 1, 'Judge 4', 90);
    PERFORM update_run_score(200, 'Jason', 'Wolle', 'Finals', 1, 'Judge 5', 87);

    RAISE NOTICE 'Step 6: Mens halfpipe finals scores updated successfully.';
END;
$$;