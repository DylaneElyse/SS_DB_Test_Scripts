Table "public.ss_roles"
Column	Type	Collation	Nullable	Default	Storage	Compression	Stats target	Description
role_id 	integer 		not null 		plain 			
role_name 	character varying(100) 		not null 		extended 			

Indexes:
    "ss_roles_pkey" PRIMARY KEY, btree (role_id)
Referenced by:
    TABLE "ss_users" CONSTRAINT "ss_users_role_id_fkey" FOREIGN KEY (role_id) REFERENCES ss_roles(role_id) ON UPDATE CASCADE ON DELETE RESTRICT
Access method: heap


Table "public.ss_users"
Column	Type	Collation	Nullable	Default	Storage	Compression	Stats target	Description
user_id 	integer 		not null 	nextval('ss_users_user_id_seq'::regclass) 	plain 			
first_name 	character varying(100) 		not null 		extended 			
last_name 	character varying(100) 		not null 		extended 			
email 	character varying(100) 		not null 		extended 			
role_id 	integer 		not null 		plain 			
auth_provider_user_id 	character varying(100) 		not null 		extended 			

Indexes:
    "ss_users_pkey" PRIMARY KEY, btree (user_id)
    "ss_users_auth_provider_user_id_key" UNIQUE CONSTRAINT, btree (auth_provider_user_id)
    "ss_users_email_key" UNIQUE CONSTRAINT, btree (email)
Foreign-key constraints:
    "ss_users_role_id_fkey" FOREIGN KEY (role_id) REFERENCES ss_roles(role_id) ON UPDATE CASCADE ON DELETE RESTRICT
Referenced by:
    TABLE "ss_event_personnel" CONSTRAINT "ss_event_personnel_user_id_fkey" FOREIGN KEY (user_id) REFERENCES ss_users(user_id) ON UPDATE CASCADE ON DELETE RESTRICT
Access method: heap


Table "public.ss_disciplines"
Column	Type	Collation	Nullable	Default	Storage	Compression	Stats target	Description
discipline_id 	character varying(100) 		not null 		extended 			
category_name 	character varying(100) 		not null 		extended 			
subcategory_name 	character varying(100) 		not null 		extended 			
discipline_name 	character varying(100) 		not null 		extended 			

Indexes:
    "ss_disciplines_pkey" PRIMARY KEY, btree (discipline_id)
Referenced by:
    TABLE "ss_events" CONSTRAINT "ss_events_discipline_id_fkey" FOREIGN KEY (discipline_id) REFERENCES ss_disciplines(discipline_id) ON UPDATE CASCADE ON DELETE RESTRICT
Access method: heap


Table "public.ss_division"
Column	Type	Collation	Nullable	Default	Storage	Compression	Stats target	Description
division_id 	integer 		not null 	nextval('ss_division_division_id_seq'::regclass) 	plain 			
division_name 	character varying(100) 		not null 		extended 			

Indexes:
    "ss_division_pkey" PRIMARY KEY, btree (division_id)
Referenced by:
    TABLE "ss_event_divisions" CONSTRAINT "ss_event_divisions_division_id_fkey" FOREIGN KEY (division_id) REFERENCES ss_division(division_id) ON UPDATE CASCADE ON DELETE RESTRICT
Access method: heap


Table "public.ss_athletes"
Column	Type	Collation	Nullable	Default	Storage	Compression	Stats target	Description
athlete_id 	integer 		not null 	nextval('ss_athletes_athlete_id_seq'::regclass) 	plain 			
last_name 	character varying(255) 		not null 		extended 			
first_name 	character varying(255) 		not null 		extended 			
dob 	date 		not null 		plain 			
gender 	character varying(10) 		not null 		extended 			
nationality 	character varying(3) 				extended 			
stance 	character varying(20) 				extended 			
fis_num 	integer 				plain 			
fis_hp_points 	numeric(10,2) 				main 			
fis_ss_points 	numeric(10,2) 				main 			
fis_ba_points 	numeric(10,2) 				main 			
wspl_points 	numeric(10,2) 				main 			

Indexes:
    "ss_athletes_pkey" PRIMARY KEY, btree (athlete_id)
    "ss_athletes_fis_num_key" UNIQUE CONSTRAINT, btree (fis_num)
Referenced by:
    TABLE "ss_event_registrations" CONSTRAINT "ss_event_registrations_athlete_id_fkey" FOREIGN KEY (athlete_id) REFERENCES ss_athletes(athlete_id) ON UPDATE CASCADE ON DELETE RESTRICT
Access method: heap


Table "public.ss_events"
Column	Type	Collation	Nullable	Default	Storage	Compression	Stats target	Description
event_id 	integer 		not null 	nextval('ss_events_event_id_seq'::regclass) 	plain 			
name 	character varying(255) 		not null 		extended 			
start_date 	date 		not null 		plain 			
end_date 	date 		not null 		plain 			
location 	character varying(255) 		not null 		extended 			
discipline_id 	character varying(50) 		not null 		extended 			
status 	character varying(50) 		not null 	'Inactive'::character varying 	extended 			

Indexes:
    "ss_events_pkey" PRIMARY KEY, btree (event_id)
Foreign-key constraints:
    "ss_events_discipline_id_fkey" FOREIGN KEY (discipline_id) REFERENCES ss_disciplines(discipline_id) ON UPDATE CASCADE ON DELETE RESTRICT
Referenced by:
    TABLE "ss_event_divisions" CONSTRAINT "ss_event_divisions_event_id_fkey" FOREIGN KEY (event_id) REFERENCES ss_events(event_id) ON UPDATE CASCADE ON DELETE CASCADE
    TABLE "ss_event_judges" CONSTRAINT "ss_event_judges_event_id_fkey" FOREIGN KEY (event_id) REFERENCES ss_events(event_id) ON UPDATE CASCADE ON DELETE CASCADE
    TABLE "ss_event_personnel" CONSTRAINT "ss_event_personnel_event_id_fkey" FOREIGN KEY (event_id) REFERENCES ss_events(event_id) ON UPDATE CASCADE ON DELETE CASCADE
Access method: heap


Table "public.ss_event_divisions"
Column	Type	Collation	Nullable	Default	Storage	Compression	Stats target	Description
event_id 	integer 		not null 		plain 			
division_id 	integer 		not null 		plain 			
num_rounds 	integer 		not null 	1 	plain 			

Indexes:
    "ss_event_divisions_pkey" PRIMARY KEY, btree (event_id, division_id)
Foreign-key constraints:
    "ss_event_divisions_division_id_fkey" FOREIGN KEY (division_id) REFERENCES ss_division(division_id) ON UPDATE CASCADE ON DELETE RESTRICT
    "ss_event_divisions_event_id_fkey" FOREIGN KEY (event_id) REFERENCES ss_events(event_id) ON UPDATE CASCADE ON DELETE CASCADE
Referenced by:
    TABLE "ss_event_registrations" CONSTRAINT "ss_event_registrations_event_id_division_id_fkey" FOREIGN KEY (event_id, division_id) REFERENCES ss_event_divisions(event_id, division_id) ON UPDATE CASCADE ON DELETE CASCADE
    TABLE "ss_round_details" CONSTRAINT "ss_round_details_event_id_division_id_fkey" FOREIGN KEY (event_id, division_id) REFERENCES ss_event_divisions(event_id, division_id) ON UPDATE CASCADE ON DELETE CASCADE
Triggers:
    trg_manage_event_divisions_after_insert AFTER INSERT ON ss_event_divisions FOR EACH ROW EXECUTE FUNCTION handle_event_divisions()
    trg_manage_event_divisions_after_update AFTER UPDATE ON ss_event_divisions FOR EACH ROW WHEN (old.num_rounds IS DISTINCT FROM new.num_rounds) EXECUTE FUNCTION handle_event_divisions()
Access method: heap


Table "public.ss_round_details"
Column	Type	Collation	Nullable	Default	Storage	Compression	Stats target	Description
event_id 	integer 		not null 		plain 			
division_id 	integer 		not null 		plain 			
round_id 	integer 		not null 	nextval('ss_round_details_round_id_seq'::regclass) 	plain 			
round_num 	integer 		not null 		plain 			
round_name 	character varying(100) 		not null 	'Final'::character varying 	extended 			
num_heats 	integer 		not null 	1 	plain 			
round_sequence 	integer 				plain 			
schedule_sequence 	integer 				plain 			
num_athletes 	integer 		not null 	0 	plain 			

Indexes:
    "ss_round_details_pkey" PRIMARY KEY, btree (event_id, division_id, round_id)
    "ss_round_details_round_id_key" UNIQUE CONSTRAINT, btree (round_id)
Foreign-key constraints:
    "ss_round_details_event_id_division_id_fkey" FOREIGN KEY (event_id, division_id) REFERENCES ss_event_divisions(event_id, division_id) ON UPDATE CASCADE ON DELETE CASCADE
Referenced by:
    TABLE "ss_heat_details" CONSTRAINT "ss_heat_details_round_id_fkey" FOREIGN KEY (round_id) REFERENCES ss_round_details(round_id) ON UPDATE CASCADE ON DELETE CASCADE
Triggers:
    trg_after_insert_update_round_details AFTER INSERT OR UPDATE ON ss_round_details FOR EACH ROW EXECUTE FUNCTION handle_round_details()
Access method: heap


Table "public.ss_heat_details"
Column	Type	Collation	Nullable	Default	Storage	Compression	Stats target	Description
round_heat_id 	integer 		not null 	nextval('ss_heat_details_round_heat_id_seq'::regclass) 	plain 			
heat_num 	integer 		not null 		plain 			
num_runs 	integer 		not null 	3 	plain 			
round_id 	integer 		not null 		plain 			
start_time 	timestamp without time zone 				plain 			
end_time 	timestamp without time zone 				plain 			
schedule_sequence 	integer 				plain 			

Indexes:
    "ss_heat_details_pkey" PRIMARY KEY, btree (round_heat_id)
    "ss_heat_details_round_id_heat_num_key" UNIQUE CONSTRAINT, btree (round_id, heat_num)
Foreign-key constraints:
    "ss_heat_details_round_id_fkey" FOREIGN KEY (round_id) REFERENCES ss_round_details(round_id) ON UPDATE CASCADE ON DELETE CASCADE
Referenced by:
    TABLE "ss_heat_judges" CONSTRAINT "ss_heat_judges_round_heat_id_fkey" FOREIGN KEY (round_heat_id) REFERENCES ss_heat_details(round_heat_id) ON UPDATE CASCADE ON DELETE CASCADE
    TABLE "ss_heat_results" CONSTRAINT "ss_heat_results_round_heat_id_fkey" FOREIGN KEY (round_heat_id) REFERENCES ss_heat_details(round_heat_id) ON UPDATE CASCADE ON DELETE CASCADE
Triggers:
    trg_handle_insert_on_heat_details AFTER INSERT ON ss_heat_details FOR EACH ROW EXECUTE FUNCTION handle_insert_on_heat_details()
    trg_handle_update_on_heat_details AFTER UPDATE ON ss_heat_details FOR EACH ROW WHEN (old.num_runs IS DISTINCT FROM new.num_runs) EXECUTE FUNCTION handle_update_on_heat_details()
Access method: heap


Table "public.ss_event_registrations"
Column	Type	Collation	Nullable	Default	Storage	Compression	Stats target	Description
event_id 	integer 		not null 		plain 			
division_id 	integer 		not null 		plain 			
athlete_id 	integer 		not null 		plain 			
bib_num 	integer 				plain 			

Indexes:
    "ss_event_registrations_pkey" PRIMARY KEY, btree (event_id, division_id, athlete_id)
    "ss_event_registrations_event_id_division_id_bib_num_key" UNIQUE CONSTRAINT, btree (event_id, division_id, bib_num)
Foreign-key constraints:
    "ss_event_registrations_athlete_id_fkey" FOREIGN KEY (athlete_id) REFERENCES ss_athletes(athlete_id) ON UPDATE CASCADE ON DELETE RESTRICT
    "ss_event_registrations_event_id_division_id_fkey" FOREIGN KEY (event_id, division_id) REFERENCES ss_event_divisions(event_id, division_id) ON UPDATE CASCADE ON DELETE CASCADE
Referenced by:
    TABLE "ss_heat_results" CONSTRAINT "ss_heat_results_event_id_division_id_athlete_id_fkey" FOREIGN KEY (event_id, division_id, athlete_id) REFERENCES ss_event_registrations(event_id, division_id, athlete_id) ON UPDATE CASCADE ON DELETE CASCADE
Triggers:
    trg_handle_insert_on_event_registrations AFTER INSERT ON ss_event_registrations FOR EACH ROW EXECUTE FUNCTION handle_insert_on_event_registrations()
    trg_handle_update_on_event_registrations AFTER UPDATE ON ss_event_registrations FOR EACH ROW WHEN (old.event_id IS DISTINCT FROM new.event_id OR old.division_id IS DISTINCT FROM new.division_id) EXECUTE FUNCTION handle_update_on_event_registrations()
    trg_reseeding_after_registration_delete AFTER DELETE ON ss_event_registrations REFERENCING OLD TABLE AS old_rows FOR EACH STATEMENT EXECUTE FUNCTION manage_registration_reseeding()
    trg_reseeding_after_registration_insert AFTER INSERT ON ss_event_registrations REFERENCING NEW TABLE AS new_rows FOR EACH STATEMENT EXECUTE FUNCTION manage_registration_reseeding()
    trg_reseeding_after_registration_update AFTER UPDATE ON ss_event_registrations REFERENCING OLD TABLE AS old_rows NEW TABLE AS new_rows FOR EACH STATEMENT EXECUTE FUNCTION manage_registration_reseeding()
Access method: heap


Table "public.ss_heat_results"
Column	Type	Collation	Nullable	Default	Storage	Compression	Stats target	Description
round_heat_id 	integer 		not null 		plain 			
event_id 	integer 		not null 		plain 			
division_id 	integer 		not null 		plain 			
athlete_id 	integer 		not null 		plain 			
best 	numeric(10,2) 				main 			
seeding 	numeric 				main 			

Indexes:
    "ss_heat_results_pkey" PRIMARY KEY, btree (round_heat_id, event_id, division_id, athlete_id)
    "ss_heat_results_round_heat_id_athlete_id_key" UNIQUE CONSTRAINT, btree (round_heat_id, athlete_id)
Foreign-key constraints:
    "ss_heat_results_event_id_division_id_athlete_id_fkey" FOREIGN KEY (event_id, division_id, athlete_id) REFERENCES ss_event_registrations(event_id, division_id, athlete_id) ON UPDATE CASCADE ON DELETE CASCADE
    "ss_heat_results_round_heat_id_fkey" FOREIGN KEY (round_heat_id) REFERENCES ss_heat_details(round_heat_id) ON UPDATE CASCADE ON DELETE CASCADE
Referenced by:
    TABLE "ss_run_results" CONSTRAINT "ss_run_results_round_heat_id_event_id_division_id_athlete__fkey" FOREIGN KEY (round_heat_id, event_id, division_id, athlete_id) REFERENCES ss_heat_results(round_heat_id, event_id, division_id, athlete_id) ON UPDATE CASCADE ON DELETE CASCADE
Triggers:
    trg_handle_insert_on_heat_results AFTER INSERT ON ss_heat_results FOR EACH ROW EXECUTE FUNCTION handle_insert_on_heat_results()
    trg_handle_update_on_heat_results AFTER UPDATE ON ss_heat_results FOR EACH ROW WHEN (old.round_heat_id IS DISTINCT FROM new.round_heat_id OR old.best IS DISTINCT FROM new.best) EXECUTE FUNCTION handle_update_on_heat_results()
    trg_reseed_after_heat_results_delete AFTER DELETE ON ss_heat_results REFERENCING OLD TABLE AS old_rows FOR EACH STATEMENT EXECUTE FUNCTION manage_heat_reseeding()
    trg_reseed_after_heat_results_insert AFTER INSERT ON ss_heat_results REFERENCING NEW TABLE AS new_rows FOR EACH STATEMENT EXECUTE FUNCTION manage_heat_reseeding()
    trg_reseed_after_heat_results_update AFTER UPDATE ON ss_heat_results REFERENCING OLD TABLE AS old_rows NEW TABLE AS new_rows FOR EACH STATEMENT EXECUTE FUNCTION manage_heat_reseeding()
    trg_update_round_athlete_count_after_delete AFTER DELETE ON ss_heat_results REFERENCING OLD TABLE AS old_rows FOR EACH STATEMENT EXECUTE FUNCTION update_round_athlete_count()
    trg_update_round_athlete_count_after_insert AFTER INSERT ON ss_heat_results REFERENCING NEW TABLE AS new_rows FOR EACH STATEMENT EXECUTE FUNCTION update_round_athlete_count()
    trg_update_round_athlete_count_after_update AFTER UPDATE ON ss_heat_results REFERENCING OLD TABLE AS old_rows NEW TABLE AS new_rows FOR EACH STATEMENT EXECUTE FUNCTION update_round_athlete_count()
Access method: heap


Table "public.ss_run_results"
Column	Type	Collation	Nullable	Default	Storage	Compression	Stats target	Description
run_result_id 	integer 		not null 	nextval('ss_run_results_run_result_id_seq'::regclass) 	plain 			
round_heat_id 	integer 		not null 		plain 			
event_id 	integer 		not null 		plain 			
division_id 	integer 		not null 		plain 			
athlete_id 	integer 		not null 		plain 			
run_num 	integer 		not null 		plain 			
calc_score 	numeric(10,2) 				main 			
dn_flag 	character varying(3) 				extended 			

Indexes:
    "ss_run_results_pkey" PRIMARY KEY, btree (run_result_id)
    "ss_run_results_round_heat_id_event_id_division_id_athlete_i_key" UNIQUE CONSTRAINT, btree (round_heat_id, event_id, division_id, athlete_id, run_num)
    "ss_run_results_run_result_id_round_heat_id_key" UNIQUE CONSTRAINT, btree (run_result_id, round_heat_id)
Foreign-key constraints:
    "ss_run_results_round_heat_id_event_id_division_id_athlete__fkey" FOREIGN KEY (round_heat_id, event_id, division_id, athlete_id) REFERENCES ss_heat_results(round_heat_id, event_id, division_id, athlete_id) ON UPDATE CASCADE ON DELETE CASCADE
Referenced by:
    TABLE "ss_run_scores" CONSTRAINT "ss_run_scores_run_result_id_round_heat_id_fkey" FOREIGN KEY (run_result_id, round_heat_id) REFERENCES ss_run_results(run_result_id, round_heat_id) ON UPDATE CASCADE ON DELETE CASCADE
Triggers:
    trg_handle_insert_on_run_results AFTER INSERT OR UPDATE ON ss_run_results FOR EACH ROW EXECUTE FUNCTION handle_insert_on_run_results()
Access method: heap


Table "public.ss_event_judges"
Column	Type	Collation	Nullable	Default	Storage	Compression	Stats target	Description
personnel_id 	integer 		not null 	nextval('ss_event_judges_personnel_id_seq'::regclass) 	plain 			
event_id 	integer 		not null 		plain 			
header 	character varying(50) 		not null 		extended 			
name 	character varying(100) 				extended 			
passcode 	character(4) 		not null 		extended 			

Indexes:
    "ss_event_judges_pkey" PRIMARY KEY, btree (personnel_id)
    "ss_event_judges_passcode_key" UNIQUE CONSTRAINT, btree (passcode)
Foreign-key constraints:
    "ss_event_judges_event_id_fkey" FOREIGN KEY (event_id) REFERENCES ss_events(event_id) ON UPDATE CASCADE ON DELETE CASCADE
Referenced by:
    TABLE "ss_heat_judges" CONSTRAINT "ss_heat_judges_personnel_id_fkey" FOREIGN KEY (personnel_id) REFERENCES ss_event_judges(personnel_id) ON UPDATE CASCADE ON DELETE CASCADE
Triggers:
    trg_prevent_event_judge_reassignment BEFORE UPDATE ON ss_event_judges FOR EACH ROW WHEN (old.event_id IS DISTINCT FROM new.event_id) EXECUTE FUNCTION prevent_event_judge_reassignment()
    trg_set_judge_passcode_if_null BEFORE INSERT ON ss_event_judges FOR EACH ROW EXECUTE FUNCTION set_judge_passcode_if_null()
Access method: heap


Table "public.ss_heat_judges"
Column	Type	Collation	Nullable	Default	Storage	Compression	Stats target	Description
round_heat_id 	integer 		not null 		plain 			
personnel_id 	integer 		not null 		plain 			

Indexes:
    "ss_heat_judges_pkey" PRIMARY KEY, btree (round_heat_id, personnel_id)
Foreign-key constraints:
    "ss_heat_judges_personnel_id_fkey" FOREIGN KEY (personnel_id) REFERENCES ss_event_judges(personnel_id) ON UPDATE CASCADE ON DELETE CASCADE
    "ss_heat_judges_round_heat_id_fkey" FOREIGN KEY (round_heat_id) REFERENCES ss_heat_details(round_heat_id) ON UPDATE CASCADE ON DELETE CASCADE
Referenced by:
    TABLE "ss_run_scores" CONSTRAINT "ss_run_scores_round_heat_id_personnel_id_fkey" FOREIGN KEY (round_heat_id, personnel_id) REFERENCES ss_heat_judges(round_heat_id, personnel_id) ON UPDATE CASCADE ON DELETE CASCADE
Triggers:
    trg_handle_update_on_heat_judges AFTER UPDATE ON ss_heat_judges FOR EACH ROW EXECUTE FUNCTION handle_update_on_heat_judges()
    trg_prevent_heat_judge_reassignment BEFORE UPDATE ON ss_heat_judges FOR EACH ROW EXECUTE FUNCTION prevent_heat_judge_reassignment()
Access method: heap


Table "public.ss_run_scores"
Column	Type	Collation	Nullable	Default	Storage	Compression	Stats target	Description
run_result_id 	integer 		not null 		plain 			
personnel_id 	integer 		not null 		plain 			
round_heat_id 	integer 		not null 		plain 			
score 	numeric(10,2) 				main 			

Indexes:
    "ss_run_scores_pkey" PRIMARY KEY, btree (run_result_id, personnel_id)
Foreign-key constraints:
    "ss_run_scores_round_heat_id_personnel_id_fkey" FOREIGN KEY (round_heat_id, personnel_id) REFERENCES ss_heat_judges(round_heat_id, personnel_id) ON UPDATE CASCADE ON DELETE CASCADE
    "ss_run_scores_run_result_id_round_heat_id_fkey" FOREIGN KEY (run_result_id, round_heat_id) REFERENCES ss_run_results(run_result_id, round_heat_id) ON UPDATE CASCADE ON DELETE CASCADE
Triggers:
    trg_update_scores_after_delete AFTER DELETE ON ss_run_scores FOR EACH ROW EXECUTE FUNCTION trg_start_score_calculation_chain()
    trg_update_scores_after_insert_update AFTER INSERT OR UPDATE ON ss_run_scores FOR EACH ROW WHEN (new.score IS NOT NULL) EXECUTE FUNCTION trg_start_score_calculation_chain()
Access method: heap


Table "public.ss_event_personnel"
Column	Type	Collation	Nullable	Default	Storage	Compression	Stats target	Description
event_id 	integer 		not null 		plain 			
user_id 	integer 		not null 		plain 			
event_role 	character varying(50) 				extended 			

Indexes:
    "ss_event_personnel_pkey" PRIMARY KEY, btree (event_id, user_id)
Foreign-key constraints:
    "ss_event_personnel_event_id_fkey" FOREIGN KEY (event_id) REFERENCES ss_events(event_id) ON UPDATE CASCADE ON DELETE CASCADE
    "ss_event_personnel_user_id_fkey" FOREIGN KEY (user_id) REFERENCES ss_users(user_id) ON UPDATE CASCADE ON DELETE RESTRICT
Access method: heap