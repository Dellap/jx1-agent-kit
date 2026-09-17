CHANCE_AUTO_ATTACK = 1    -- 1/8000 co hoi chuyen sang chien dau
CHANCE_JOIN_FIGHT = 1     -- 1/3000 co hoi tham gia danh nhau khi di ngang qua dam danh nhau
CHANCE_ATTACK_PLAYER = 1  -- 1/3000 co hoi danh nguoi neu den gan nguoi choi dang chien dau

STARTUP_AUTOADD_THANHTHI = 1 -- tu dong moi nhan si tren tat ca ban do
THANHTHI_SIZE = 600   		 -- so luong nhan si trong thanh thi
THON_SIZE = 100               -- so luong bot trong THON nho (it hon thanh, chong ket/chay 1 cho)
THANHTHI_QUAI = 0			 -- co cho phep quai nhan tu dong xuat hien trong thanh thi hay khong
LUYENCONG_AUTOADD = 1		 -- tu dong them nhan si luyen cong vao map 9x

RADIUS_FIGHT_PLAYER = 20     -- tam quet+tan cong player
RADIUS_FIGHT_NPC = 8         -- tam quet NPC chung quanh va tan cong
RADIUS_FIGHT_SCAN = 8        -- tam quet dam danh nhau chung quanh de tham gia


CHANCE_CHAT = 200               -- 10/1000 co hoi noi chuyen moi giay
CHANCE_DROP_MONEY = 0 		   -- 1/10000 co hoi lam rot tien khi di chuyen


TIME_FIGHTING = { -- khoang thoi gian danh nhau  (45-120giay)
	minTs = 6000,
	maxTs = 6000
}

TIME_RESTING = { -- nghi ngoi, khong danh nhau lai trong vong thoi gian nay
	minTs = 0,
	maxTs = 1
}

-- TONG KIM setup
TONGKIM_SPAWN_MINSTAY = 0         -- thoi gian toi thieu o lai dai doanh truoc khi xong len
TONGKIM_SPAWN_MAXSTAY = 1        -- thoi gian toi da co the nup trong dai doanh


-- PARAM setup
PARAM_LIST_ID = 1                  -- param to store fighter id
PARAM_CHILD_ID = 2                 -- param to store child id
PARAM_TYPE = 3                     -- param to store type
REFRESH_RATE = 18                  -- refresh rate
BOT_VS_BOT = 1                     -- bot ngoai thanh TU tim+danh bot khac camp (BAT KE PK-mode/vi tri player). 0=tat
BOT_COMBAT_RADIUS = 20             -- tam quet bot combat

-- CHILD SIM CITIZEN/KEOXE setup
DISTANCE_CAN_CONTINUE = 5          -- start next position if within 3 points from destination
DISTANCE_CAN_SPIN = 2              -- when spinning make sure the check is tighter
SPINNING_WAIT_TIME = 0             -- wait time to correct position
CHAR_SPACING = 1                   -- spacing between fighter characters
DISTANCE_FOLLOW_PLAYER = 28        -- chay theo nguoi choi neu cach xa
DISTANCE_SUPPORT_PLAYER = 8        -- neu gan nguoi choi khoang cach 12 thi chuyen sang chien dau
DISTANCE_FOLLOW_PLAYER_TOOFAR = 30 -- neu qua xa nguoi choi vi chay nhanh thi phai bien hinh theo
DISTANCE_VISION = 15               -- qua 15 = phai respawn vi no se quay ve cho cu

LIFE_RESTORE_PERCENT = 5       -- phan tram life se duoc hoi lai moi 1s

ENABLE_BANNGUAMIXDEV = 1	   -- sua lai thanh 1 neu xai ban mix dev vi bi mat ban ngua

-- SIMCITY BOT STALL PRICE/CHINH SUA GIA BAN CUA SIMBOT
BOT_STALL_PRICE_MULTIPLIER = 100  -- 1=gia goc, 5=x5, 10=x10, 15=x15, ... (toi da 100)
LUYENCONG_THEOCAP=1
NGOAITRANG_THEOCAP=1
LUYENCONG_GROUPS=5
LUYENCONG_PK_MINLEVEL=100
PARTY_OPEN_GROUPS=10
PARTY_OPEN_CHILDREN=2
SKILL_BOT_8X=3
LUYENCONG_HP_PCT=50
SKILL_MIN_LEVEL=60
LEVEL_TRACK_PLAYERS=1
LEVEL_HEADROOM=3
LEVEL_SAMPLE_MIN=1
NEWBIE_PROTECT_LEVEL=30
STABLE_IDENTITY=1
GEAR_MATCH_CLASS=1
BOT_FLEE_HP=25
REST_CHANCE=150
REST_TIME_MIN=15
REST_TIME_MAX=45
GREET_CHANCE=80
GREET_RADIUS=8
BIKIP_LV2=90
REST_PRACTICE=1
