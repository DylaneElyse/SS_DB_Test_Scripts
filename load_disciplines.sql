-- Active: 1748017951744@@localhost@5432@snow_score_test
INSERT INTO ss_disciplines (discipline_id, category_name, subcategory_name, discipline_name) VALUES
-- Freestyle
('FREE_BA_SBD', 'Freestyle', 'Big Air', 'Snowboard'),
('FREE_BA_SKI', 'Freestyle', 'Big Air', 'Ski'),
('FREE_HP_SBD', 'Freestyle', 'Halfpipe', 'Snowboard'),
('FREE_HP_SKI', 'Freestyle', 'Halfpipe', 'Ski'),
('FREE_SS_SBD', 'Freestyle', 'Slopestyle', 'Snowboard'),
('FREE_SS_SKI', 'Freestyle', 'Slopestyle', 'Ski'),
('FREE_MOG_SKI', 'Freestyle', 'Moguls', 'Ski'),

-- Alpine
('ALP_DH_SKI', 'Alpine', 'Downhill', 'Ski'),
('ALP_SG_SKI', 'Alpine', 'Super-G', 'Ski'),
('ALP_GS_SKI', 'Alpine', 'Giant Slalom', 'Ski'),
('ALP_SL_SKI', 'Alpine', 'Slalom', 'Ski'),
('ALP_SBX_SBD', 'Alpine', 'Snowboard Cross', 'Snowboard'),
('ALP_SKX_SKI', 'Alpine', 'Ski Cross', 'Ski'),

-- Nordic
('NORD_SP_SKI', 'Nordic', 'Sprint', 'Ski'),
('NORD_DIST_SKI', 'Nordic', 'Distance', 'Ski'),
('NORD_CP_SKI', 'Nordic', 'Combined Pursuit', 'Ski'),
('NORD_JUMP_SKI', 'Nordic', 'Ski Jumping', 'Ski'),

-- Other
('SNOW_PS_SBD', 'Snowboard', 'Parallel Slalom', 'Snowboard'),
('SNOW_PGS_SBD', 'Snowboard', 'Parallel Giant Slalom', 'Snowboard'),
('FREESKI_BX_SKI', 'Freeski', 'Big Air', 'Ski')

ON CONFLICT (discipline_id) DO NOTHING;