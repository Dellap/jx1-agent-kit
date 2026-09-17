-- SimCity cho That Thanh Dai Chien - offline single-player edition
-- WAR FLOW:

Include("\\script\\missions\\sevencity\\war.lua")
Include("\\script\\global\\nobitaxd\\vdk\\simcity\\head.lua")

SCRIPT_SIMTDC_DEATH = "\\script\\missions\\sevencity\\simsevencity_death.lua"

-- Main state
SimThatThanh = SimThatThanh or {}
SimThatThanh.m_FakeBangs          = SimThatThanh.m_FakeBangs          or {}
SimThatThanh.m_MapNpcs            = SimThatThanh.m_MapNpcs            or {}
SimThatThanh.m_BangByIdx          = SimThatThanh.m_BangByIdx          or {}
SimThatThanh.m_RespawnQueue       = SimThatThanh.m_RespawnQueue       or {}
SimThatThanh.m_LastBatchTime      = SimThatThanh.m_LastBatchTime      or {}
SimThatThanh.m_BatchPending       = SimThatThanh.m_BatchPending       or {}
SimThatThanh.m_BatchTickCounter   = SimThatThanh.m_BatchTickCounter   or 0
SimThatThanh.m_QueueCounter       = SimThatThanh.m_QueueCounter       or 0
SimThatThanh.m_IsRunning          = SimThatThanh.m_IsRunning          or 0
SimThatThanh.m_NpcIdx2BangIdx     = SimThatThanh.m_NpcIdx2BangIdx     or {}
SimThatThanh.m_MapCaptured        = SimThatThanh.m_MapCaptured        or {}
SimThatThanh.m_MapAttackerActive  = SimThatThanh.m_MapAttackerActive  or {}
SimThatThanh.m_MapAttackerBangIdx = SimThatThanh.m_MapAttackerBangIdx or {}
SimThatThanh.m_MapDefenderBangIdx = SimThatThanh.m_MapDefenderBangIdx or {}
-- Track bao nhieu bot moi bang/map da spawn -> phan rank theo thu tu spawn
SimThatThanh.m_BangRankCounter    = SimThatThanh.m_BangRankCounter    or {}

-- ====== CONFIG - chinh sua thong so o day =====================
SimThatThanh.CFG = {

	-- ===== TEN CAC FAKE BANG (DEFENDER) =====
	BANG_NAMES = {
		"ThÝchPK",
		"BèGiµ",
		"Thiªn§Þa",
		"T×nh",
		"Ph¸Thiªn",
		"Huynh§Ö",
		"TiÕuNg¹o",
	},
	BANG_REAL_TONGS = {
		"ThÝchPK", "BèGiµ", "Thiªn§Þa", "T×nh",
		"Ph¸Thiªn", "Huynh§Ö", "TiÕuNg¹o",
	},
	BANG_INTERNAL_PREFIX = "@SIMBOT@",

	-- ===== ASSIGNMENT BANG -> MAP =====
	BANG_RANDOM_SHUFFLE = 1,

	-- ===== SO LUONG BOT (Layered Defense Mode B) =====
	PILLAR_TANK_PER_BANG = 0,
	CENTER_BOTS_PER_BANG = 50,
	GATE_BOTS_PER_BANG   = 0,

	-- ===== PHAN CAP BANG (TITLE BOT) =====
	BANG_RANK_BANG_CHU   = 1,
	BANG_RANK_TRUONG_LAO = 5,
	BANG_RANK_DUONG_CHU  = 10,
	-- Con lai = "De Tu" tu dong (vd 100 - 1 - 5 - 10 = 84 De Tu)

	-- ===== INVADER (BOT TAN CONG MAP DA CHIEM) =====
	INVADER_ENABLED          = 1,
	INVADER_GATE_BOTS        = 80,
	INVADER_RING_BOTS        = 0,
	INVADER_ANNOUNCE         = 1,
	PLAYER_LOCATION_INTERVAL = 1,
	ATTACKER_MIN_DIST        = 18,
	ATTACKER_MAX_DIST        = 22,

	-- ===== POSITION CONFIG =====
	GATE_DISTANCE      = 8,
	GATE_PATROL_OFFSET = 8,
	RING_RADIUS        = 8,

	-- ===== AGGRO RADIUS =====
	AGGRO_RADIUS_PLAYER = 50,
	AGGRO_RADIUS_NPC    = 30,
	AGGRO_RADIUS_SCAN   = 80,

	-- ===== RESPAWN BOT =====
	RESPAWN_MIN_SEC = 45,
	RESPAWN_MAX_SEC = 60,
	
	-- ===== BATCH RESPAWN (TANG VIEN THEO DOT) =====
	BATCH_RESPAWN_ENABLED = 1,
	
	-- Threshold trigger: khi alive bot <= phan tram nay (cua tong bot/map) -> spawn
	BATCH_TRIGGER_RATIO = 0.5,
	
	-- Cooldown giua cac batch tren cung 1 map (giay)
	-- 30s = nhe nhang, tranh spam khi player lien tuc dap
	BATCH_COOLDOWN_SEC = 30,
	
	-- Stagger spawn: spawn N bot moi tick (~0.5s) cho mut, khong lag.
	BATCH_STAGGER_PER_TICK = 5,
	
	-- 1 = thong bao "[<thanh>] Bang <X> tiep vien N nhan vat!"
	BATCH_ANNOUNCE = 0,

	-- ===== NPC TEMPLATE =====
	USE_SIMCITIZEN = 1,
	NPC_POOL = {
		2000, 2001, 2002, 2003, 2004,
		2005, 2006, 2007, 2008, 2009,
		2010, 2011, 2012, 2013, 2014,
		2015, 2016, 2017, 2018, 2019,
		2020, 2021, 2022, 2023,
	},
	NPC_LEVEL = 95,

	-- ===== ENGINE CAMP =====
	-- BOT_CUR_CAMP_OVERRIDE: chi anh huong CurCamp (visual / AI). 0 = auto pick != player.
	-- TmpCamp (combat damage check) luon dung bang.camp registered tong (5+).
	-- Ly do: server config camp 1/2/3 danh nhau duoc; player.TmpCamp = registered tong (12+).
	-- matrix(player_tong, bang_camp) = 1 (different registered) -> bot dap duoc.
	BOT_CUR_CAMP_OVERRIDE = 0,
	-- Backward-compat alias (giu de khong break code cu neu co):
	BOT_ENGINE_CAMP_OVERRIDE = 0,
	
	-- ===== BOT MOVEMENT =====
	-- Bot defender di chuyen the nao quanh tru.
	
	-- BOT_SPAWN_RADIUS: ban kinh tile spawn quanh tru (cho bot center_attacker)
	BOT_SPAWN_RADIUS = 15,
	
	-- WANDER_SCALE: ban kinh walkAreas (cho bot di chuyen sau khi spawn)
	WANDER_SCALE = 2.0,
	
	-- WANDER_OUTER_RING: them 4 area xa tru cho walkAreas
	WANDER_OUTER_RING = 1,
	
	-- BOT_WALK_VAR: random wander step radius (tile)
	BOT_WALK_VAR = 5,

	-- ===== SIM KEOXE SPREAD =====
	-- Khi player goi sim (de tu/cao thu/bang huu), sim mac dinh spawn sat player.
	-- Cau hinh nay teleport sim ra vi tri random quanh player ngay sau spawn
	-- de tao cam giac "bang hoi di chung" thay vi cluster.
	KEOXE_SPREAD_ENABLED = 1,    -- 0 = giu hanh vi cu (sat player)
	KEOXE_SPREAD_MIN_DIST = 3,   -- min tile cach player luc spawn
	KEOXE_SPREAD_MAX_DIST = 6,  -- max tile cach player luc spawn
	
	-- ===== SIM KEOXE FORMATION (luc player di chuyen) =====
	-- SimCityKeoXe:ATick re-organize formation gon quanh player moi khi player
	-- di. Cau hinh nay scale formation rong ra + add jitter de khong bi cluster
	-- + cung khong qua deu.
	KEOXE_FORMATION_ENABLED = 1, -- 0 = formation goc (gon)
	KEOXE_FORMATION_SCALE = 2,   -- scale distance tu player. 1 = goc gon, 3 = rong gap 3.
	KEOXE_FORMATION_JITTER = 1,  -- random offset (tile) de khong bi grid deu cung
	-- childrenCheckDistance bounds: SimCity force sim trong N tile cua parent.
	-- Goc=8 -> sim luon bi keo gan player du parentAppointPos o xa. Tang len de spread.
	-- Set 0 = disable bounds (sim tu do); 30+ = rong rai cho phep formation rong.
	KEOXE_CHILDREN_CHECK_DIST = 15,
}
-- ====== HET CONFIG. Khong sua phia duoi tru khi biet ro. =====

-- ====== HELPERS ======
-- Set DEBUG_LOG = 1 de bat lai log file (debug). Default 0 = no-op cho production.
SimThatThanh.DEBUG_LOG = 0
function SimThatThanh:log(msg)
	if (self.DEBUG_LOG == 1) then
		WriteLog("[SIMTDC]" .. msg)
	end
end

function SimThatThanh:randomNpcId()
	local n = getn(self.CFG.NPC_POOL)
	return self.CFG.NPC_POOL[random(1, n)]
end

-- Tinh rank title cho bot tiep theo cua bang nay/map nay.
function SimThatThanh:getBangRankTitle(mapid, bangIdx)
	local key = mapid .. "_" .. bangIdx
	local cnt = (self.m_BangRankCounter[key] or 0) + 1
	self.m_BangRankCounter[key] = cnt
	
	local nBangChu   = self.CFG.BANG_RANK_BANG_CHU   or 1
	local nTruongLao = self.CFG.BANG_RANK_TRUONG_LAO or 5
	local nDuongChu  = self.CFG.BANG_RANK_DUONG_CHU  or 10
	
	if (cnt <= nBangChu) then
		return "Bang Chñ"
	elseif (cnt <= nBangChu + nTruongLao) then
		return "Tr­ëng l·o"
	elseif (cnt <= nBangChu + nTruongLao + nDuongChu) then
		return "§­êng Chñ"
	else
		return "§Ö Tö"
	end
end

-- Reset counter khi map start lai (StartAll, ClearAll)
function SimThatThanh:resetAllBangRankCounters()
	self.m_BangRankCounter = {}
end

-- Engine CurCamp visual cho bot defender (1-3 valid combat camp).
-- Server config: chi camp 1, 2, 3 danh nhau duoc; camp 4 = sat thu khong combat.
-- TmpCamp (combat damage check) handled rieng = bang.camp (5+) registered.
function SimThatThanh:getBotCurCamp()
	local pCamp = self.m_RegisteredPlayerCamp or 0
	-- Manual override (uu tien BOT_CUR_CAMP_OVERRIDE; fallback BOT_ENGINE_CAMP_OVERRIDE backward-compat)
	local ov = self.CFG.BOT_CUR_CAMP_OVERRIDE
	if (not ov or ov == 0) then ov = self.CFG.BOT_ENGINE_CAMP_OVERRIDE end
	if (ov and ov > 0) then return ov end
	-- Auto: pick 1/2/3 != player.CurCamp
	if (pCamp == 1) then return 2 end
	if (pCamp == 2) then return 3 end
	if (pCamp == 3) then return 1 end
	return 1  -- default truoc khi cache player camp
end

-- Backward compat alias - existing call sites uses getBotEngineCamp.
function SimThatThanh:getBotEngineCamp()
	return self:getBotCurCamp()
end

-- Resolve TmpCamp (combat) cho bot dua tren bang.camp (registered tong 5+).
-- Engine combat: matrix(player_tong=12, bang_camp=5/6/7...) = different registered = hostile.
function SimThatThanh:getBotTmpCamp(bangIdx)
	local bang = bangIdx and self.m_FakeBangs[bangIdx]
	if (bang and bang.camp and bang.camp > 0) then return bang.camp end
	return self:getBotCurCamp()  -- fallback
end

-- Cache player CurCamp moi khi co player vao TTDC field (BattleField:Enter)
-- HOAC khi sim Move hook detect player. Dung CallPlayerFunction.
function SimThatThanh:cachePlayerCamp(playerObj)
	if (not playerObj) then return end
	local pIdx = playerObj.m_PlayerIndex or 0
	if (pIdx <= 0 or not CallPlayerFunction) then return end
	local newCamp = CallPlayerFunction(pIdx, GetCurCamp) or 0
	if (newCamp > 0 and self.m_RegisteredPlayerCamp ~= newCamp) then
		local oldCamp = self.m_RegisteredPlayerCamp or 0
		self.m_RegisteredPlayerCamp = newCamp
		local botCamp = self:getBotCurCamp()
		if (self.m_IsRunning == 1) then
			self:reapplyBotEngineCamp(botCamp)
		end
	end
end

-- Cache player CurCamp directly (called tu sim Move hook khi co pID).
function SimThatThanh:cachePlayerCampByID(pID)
	if (not pID or pID <= 0 or not CallPlayerFunction) then return end
	local newCamp = CallPlayerFunction(pID, GetCurCamp) or 0
	if (newCamp > 0) then
		self:cachePlayerCampValue(newCamp)
	end
end

-- Cache player CurCamp tu raw value (vd tbNpc.camp cua sim spawned outside TTDC).
function SimThatThanh:cachePlayerCampValue(newCamp)
	if (not newCamp or newCamp <= 0 or newCamp > 4) then return end
	local cur = self.m_RegisteredPlayerCamp or 0
	if (cur ~= newCamp) then
		self.m_RegisteredPlayerCamp = newCamp
		local botCamp = self:getBotCurCamp()

		if (self.m_IsRunning == 1) then
			self:reapplyBotEngineCamp(botCamp)
		end
	end
end

-- Re-apply engine.CurCamp + TmpCamp cho tat ca bot dang ton tai.
-- CurCamp = botCurCamp (1-3 visual). TmpCamp = bang.camp (registered) per bot.
function SimThatThanh:reapplyBotEngineCamp(botCamp)
	if (not self.m_MapNpcs) then return end
	local cnt = 0
	for mapid, list in self.m_MapNpcs do
		for i = 1, getn(list) do
			local botInfo = list[i]
			if (botInfo and botInfo.npcIdx > 0
			    and (IsNpcExist == nil or IsNpcExist(botInfo.npcIdx) ~= 0)) then
				local bang = self.m_FakeBangs[botInfo.bangIdx]
				local tmpC = (bang and bang.camp) or botCamp
				if (SetNpcCurCamp) then SetNpcCurCamp(botInfo.npcIdx, botCamp) end
				if (SetTmpCamp) then SetTmpCamp(tmpC, botInfo.npcIdx) end
				cnt = cnt + 1
			end
		end
	end
	-- Re-apply pillars too. CurCamp=visual, TmpCamp=field.m_Monster.m_Camp (registered).
	if (BattleWorld and BattleWorld.m_FieldList) then
		for mapid, field in BattleWorld.m_FieldList do
			if (field and field.m_Monster and field.m_Monster.m_NpcIndex
			    and field.m_Monster.m_NpcIndex > 0) then
				local pidx = field.m_Monster.m_NpcIndex
				local targetCur = botCamp
				if (self.m_MapCaptured and self.m_MapCaptured[mapid] == 1
				    and self.m_RegisteredPlayerCamp and self.m_RegisteredPlayerCamp > 0) then
					targetCur = self.m_RegisteredPlayerCamp
				end
				local targetTmp = (field.m_Monster.m_Camp and field.m_Monster.m_Camp > 0)
				                  and field.m_Monster.m_Camp or targetCur
				if (SetNpcCurCamp) then SetNpcCurCamp(pidx, targetCur) end
				if (SetTmpCamp) then SetTmpCamp(targetTmp, pidx) end
			end
		end
	end
	self:log(format("Re-applied engine.CurCamp=%d for %d bots", botCamp, cnt))
end

-- Monster.CreateNpc hook: register pillar idx + set engine CurCamp + TmpCamp.
if (Monster and Monster.CreateNpc and not Monster.m_TTDCCreatePatched) then
	Monster.m_TTDCSimThatThanh = SimThatThanh
	Monster.m_TTDCOriginalCreateNpc = Monster.CreateNpc
	Monster.CreateNpc = function(monsterSelf, name)
		local result = Monster.m_TTDCOriginalCreateNpc(monsterSelf, name)
		if (monsterSelf and monsterSelf.m_NpcIndex and monsterSelf.m_NpcIndex > 0
		    and SimFight and SimFight.Citizen) then
			local idx = monsterSelf.m_NpcIndex
			local mapid = monsterSelf.m_MapId or 0
			if (SimFight.Citizen.m_TTDCPillarIdx and SimFight.Citizen.m_TTDCRegistry) then
				local oldIdx = SimFight.Citizen.m_TTDCPillarIdx[mapid] or 0
				if (oldIdx > 0 and oldIdx ~= idx) then
					SimFight.Citizen.m_TTDCRegistry[oldIdx] = nil
				end
			end
			if (SimFight.Citizen.m_TTDCPillarIdx) then
				SimFight.Citizen.m_TTDCPillarIdx[mapid] = idx
			end
			if (SimFight.Citizen.m_TTDCRegistry) then
				SimFight.Citizen.m_TTDCRegistry[idx] = -1
			end
			-- CurCamp = engine 1-3 visual.
			local requestedCamp = monsterSelf.m_TTDCEngineCurCamp
			local engineCurCamp = requestedCamp
			if (not engineCurCamp or engineCurCamp <= 0) then
				local stt = Monster.m_TTDCSimThatThanh
				engineCurCamp = (stt and stt.getBotCurCamp and stt:getBotCurCamp()) or 1
			end
			if (SetNpcCurCamp) then
				SetNpcCurCamp(idx, engineCurCamp)
			end
			-- TmpCamp = monsterSelf.m_Camp (registered tong owner: bang.camp or player.TmpCamp).
			-- Captured -> player tong; uncaptured -> bang.camp.
			local pillarTmpC = engineCurCamp
			if (monsterSelf.m_Camp and monsterSelf.m_Camp > 0) then
				pillarTmpC = monsterSelf.m_Camp
			end
			if (SetTmpCamp) then
				SetTmpCamp(pillarTmpC, idx)
			end
			-- One-shot: clear sau khi dung
			monsterSelf.m_TTDCEngineCurCamp = nil
		end
		return result
	end
	Monster.m_TTDCCreatePatched = 1
end

-- Monster.OnTime hook: skip OnTime(1) auto-dialog conversion (mat tru silent),
-- handle OnTime(3) cho deferred pillar respawn.
if (Monster and Monster.OnTime and not Monster.m_TTDCOnTimePatched) then
	Monster.m_TTDCOriginalOnTime = Monster.OnTime
	Monster.OnTime = function(monsterSelf, nIndex)
		if (SimThatThanh and SimThatThanh.m_IsRunning == 1) then
			if (nIndex == 1) then
				-- TIMEOUT_MONSTER het -> chuyen Thu Long Tru (bat tu) cho moi owner:
				-- player kill, sim of player, fake bang defender. Match original game.
				return Monster.m_TTDCOriginalOnTime(monsterSelf, nIndex)
			elseif (nIndex == 3) then
				-- Deferred pillar respawn - new timer fires 1.5s after pillar destroyed
				-- de player auto-attack chain bi cat (no target trong 1.5s)
				local pName = monsterSelf.m_TTDCPendingPillarName or "Long Trô"
				monsterSelf.m_TTDCPendingPillarName = nil
				monsterSelf.m_TTDCDeferTimerId = 0
				monsterSelf:CreateNpc(pName)

				return 0
			end
		end
		return Monster.m_TTDCOriginalOnTime(monsterSelf, nIndex)
	end
	Monster.m_TTDCOnTimePatched = 1
end

-- Monster.Down hook: defer 0.5s pillar respawn de break engine
-- auto-retarget chain (player kill -> spawn lien -> bot dap luon).
if (Monster and Monster.Down and not Monster.m_TTDCDownPatched) then
	Monster.m_TTDCOriginalDown = Monster.Down
	Monster.Down = function(monsterSelf, killer)
		if (not (SimThatThanh and SimThatThanh.m_IsRunning == 1)) then
			-- Khong phai SimCity mode, behavior goc
			return Monster.m_TTDCOriginalDown(monsterSelf, killer)
		end
		if (not (monsterSelf.m_NpcIndex and monsterSelf.m_NpcIndex > 0)) then
			return
		end
		-- Replicate logic Monster:Down nhung KHONG goi CreateNpc ngay
		monsterSelf.m_Camp = killer:GetTmpCamp()
		-- Luu CurCamp cua killer de set engine CurCamp cho tru moi
		local killerIdx = killer.m_PlayerIndex or 0
		local killerCurCamp = (CallPlayerFunction and killerIdx > 0
			and CallPlayerFunction(killerIdx, GetCurCamp)) or 0
		if (killerCurCamp <= 0) then
			killerCurCamp = (SimThatThanh and SimThatThanh.m_RegisteredPlayerCamp) or 0
		end
		monsterSelf.m_TTDCEngineCurCamp = killerCurCamp
		DelNpc(monsterSelf.m_NpcIndex)
		if (monsterSelf.CloseTimer) then monsterSelf:CloseTimer() end
		monsterSelf.m_NpcIndex = 0
		local kName = killer:GetName() or "?"
		local tong = (BattleWorld:GetWarriorTong(kName)) or kName
		local mapName = (MAP_INFO[monsterSelf.m_MapId] and MAP_INFO[monsterSelf.m_MapId].Name) or ""
		AddGlobalNews(format("[%s] long trô bÞ bang héi %s %s ph¸ vì!", mapName, tong, kName))
		killer:Msg2Player(format("[%s] C¸c h¹ ®· ph¸ vì long trô!", mapName))
		-- Schedule respawn 1500ms later
		monsterSelf.m_TTDCPendingPillarName = format("Long trô [%s]", tong)
		monsterSelf.m_TTDCDeferTimerId = TimerList:AddTimer(monsterSelf, 9, 3)
		-- Schedule TIMEOUT_MONSTER countdown -> OnTime(1) -> Thu Long Tru (bat tu)
		if (monsterSelf.StartTimer) then monsterSelf:StartTimer() end
		if (monsterSelf.CloseScoreTimer) then monsterSelf:CloseScoreTimer() end
		if (monsterSelf.StartScoreTimer) then monsterSelf:StartScoreTimer() end
	end
	Monster.m_TTDCDownPatched = 1
end

-- BattleWorld.NewCamp: bump m_CampIndex >= 5 de tranh collision voi
-- engine valid camp range 1-4 (chinh/ta/trung/sat thu).
if (BattleWorld and BattleWorld.NewCamp and not BattleWorld.m_TTDCNewCampPatched) then
	BattleWorld.m_TTDCOriginalNewCamp = BattleWorld.NewCamp
	BattleWorld.NewCamp = function(self)
		if (self.m_CampIndex and self.m_CampIndex < 5) then
			self.m_CampIndex = 5
		end
		return BattleWorld.m_TTDCOriginalNewCamp(self)
	end
	BattleWorld.m_TTDCNewCampPatched = 1
end

-- ANTI-STICKY-CAMP: hook global SetTmpCamp.
-- Engine combat copy attacker.TmpCamp -> victim.TmpCamp on hit. Hook block this
-- de giu bot.TmpCamp = bang.camp (registered tong, 5+) -> matrix khac registered tong = hostile.
if (SetTmpCamp and not _G_TTDCSetTmpCampPatched) then
	_G_TTDCOriginalSetTmpCamp = SetTmpCamp
	SetTmpCamp = function(camp, npcIdx)
		-- Whitelist check: chi block neu npcIdx la bot defender TTDC da register
		if (npcIdx and npcIdx > 0 and SimFight and SimFight.Citizen
		    and SimFight.Citizen.m_TTDCRegistry
		    and SimFight.Citizen.m_TTDCRegistry[npcIdx]
		    and SimFight.Citizen.m_TTDCRegistry[npcIdx] > 0) then
			-- La bot TTDC. TmpCamp PHAI = bang.camp (registered) cho damage check.
			-- Engine combat copy attacker.TmpCamp -> victim.TmpCamp; hook block lai,
			-- giu bang.camp -> matrix(player_tong, bang_camp) = hostile.
			local bangIdx = SimFight.Citizen.m_TTDCRegistry[npcIdx]
			local bang = SimThatThanh and SimThatThanh.m_FakeBangs[bangIdx]
			local targetTmp = (bang and bang.camp) or 1
			if (camp ~= targetTmp) then
				return _G_TTDCOriginalSetTmpCamp(targetTmp, npcIdx)
			end
		end
		-- Pillar: TmpCamp = field.m_Monster.m_Camp (registered tong owner).
		-- Captured -> player tong; uncaptured -> bang.camp. Engine combat OK.
		if (npcIdx and npcIdx > 0 and SimFight and SimFight.Citizen
		    and SimFight.Citizen.m_TTDCPillarIdx) then
			for mapid, pIdx in SimFight.Citizen.m_TTDCPillarIdx do
				if (pIdx == npcIdx) then
					local targetC = 0
					local field = (BattleWorld and BattleWorld.FindField
					               and BattleWorld:FindField(mapid))
					if (field and field.m_Monster and field.m_Monster.m_Camp
					    and field.m_Monster.m_Camp > 0) then
						targetC = field.m_Monster.m_Camp
					end
					if (targetC <= 0) then
						-- Fallback: defender bang neu chua co m_Camp
						local bangIdx2 = SimThatThanh
						              and SimThatThanh.m_MapDefenderBangIdx[mapid]
						local bang2 = bangIdx2
						           and SimThatThanh.m_FakeBangs[bangIdx2]
						targetC = (bang2 and bang2.camp) or 1
					end
					if (camp ~= targetC) then
						return _G_TTDCOriginalSetTmpCamp(targetC, npcIdx)
					end
					break  -- Found pillar, no need scan further
				end
			end
		end
		-- Khong phai bot/pillar TTDC -> pass through nguyen ven (sim keoxe, NPC khac)
		return _G_TTDCOriginalSetTmpCamp(camp, npcIdx)
	end
	_G_TTDCSetTmpCampPatched = 1
end

-- BattleWorld.RegisterCamp hook: capture player REAL CurCamp moi khi player
if (BattleWorld and BattleWorld.RegisterCamp and not BattleWorld.m_TTDCRegisterCampPatched) then
	BattleWorld.m_TTDCOriginalRegisterCamp = BattleWorld.RegisterCamp
	BattleWorld.RegisterCamp = function(self, tong)
		local r = BattleWorld.m_TTDCOriginalRegisterCamp(self, tong)
		-- Truoc khi return, neu co player active, capture CurCamp cua ho.
		-- PlayerIndex global thuong duoc set khi player goi RegisterCamp.
		local pIdx = (PlayerIndex or 0)
		if (pIdx > 0 and CallPlayerFunction) then
			local pCurCamp = CallPlayerFunction(pIdx, GetCurCamp) or 0
			if (pCurCamp > 0 and pCurCamp <= 4 and SimThatThanh
			    and SimThatThanh.cachePlayerCampValue) then
				SimThatThanh:cachePlayerCampValue(pCurCamp)
			end
			-- Cache TmpCamp cua player nay (cho sim keoxe sync sau).
			if (r and r > 0 and SimThatThanh) then
				SimThatThanh.m_PlayerTmpCampCache = SimThatThanh.m_PlayerTmpCampCache or {}
				local pName = CallPlayerFunction(pIdx, GetName) or ""
				if (pName ~= "") then
					SimThatThanh.m_PlayerTmpCampCache[pName] = r
				end
			end
		end
		return r
	end
	BattleWorld.m_TTDCRegisterCampPatched = 1
end

-- BattleField.Enter hook: cache player CurCamp moi khi co player vao TTDC field.
-- Bot engine.CurCamp se duoc tinh dynamic dua tren player camp (avoid same-camp).
if (BattleField and BattleField.Enter and not BattleField.m_TTDCEnterPatched) then
	BattleField.m_TTDCOriginalEnter = BattleField.Enter
	BattleField.Enter = function(self, player)
		local r = BattleField.m_TTDCOriginalEnter(self, player)
		if (SimThatThanh and SimThatThanh.cachePlayerCamp) then
			SimThatThanh:cachePlayerCamp(player)
		end
		return r
	end
	BattleField.m_TTDCEnterPatched = 1
end

-- SimEntity.Citizen.CreateChar: bot defender TTDC engine CurCamp = visual 1-3,
-- TmpCamp = bang.camp (registered tong) cho damage check.
if (SimEntity and SimEntity.Citizen and SimEntity.Citizen.CreateChar
    and not SimEntity.Citizen.m_TTDCCreateCharPatched) then
	SimEntity.Citizen.m_TTDCSimThatThanh = SimThatThanh
	SimEntity.Citizen.m_TTDCOriginalCreateChar = SimEntity.Citizen.CreateChar
	SimEntity.Citizen.CreateChar = function(self, simInstance, tbNpc, isNew, goX32, goY32)
		-- PRE-CREATE: override spawn position cho TTDC bot defender.
		local sttCfg = (SimEntity.Citizen.m_TTDCSimThatThanh
		                and SimEntity.Citizen.m_TTDCSimThatThanh.CFG) or {}
		local spawnRadius = sttCfg.BOT_SPAWN_RADIUS or 6
		if (spawnRadius > 0
		    and tbNpc and tbNpc.isTTDCBot == 1 and tbNpc.nMapId
		    and tbNpc.walkMode == "random"
		    and MAP_INFO and MAP_INFO[tbNpc.nMapId]
		    and MAP_INFO[tbNpc.nMapId].MonsterPos) then
			-- Lay toa do tru (pixel -> tile)
			local pillarPxX = MAP_INFO[tbNpc.nMapId].MonsterPos[1]
			local pillarPxY = MAP_INFO[tbNpc.nMapId].MonsterPos[2]
			local pillarTX = floor(pillarPxX / 32)
			local pillarTY = floor(pillarPxY / 32)
			-- Random offset trong vong tron ban kinh spawnRadius
			local offsetX = random(-spawnRadius, spawnRadius)
			local offsetY = random(-spawnRadius, spawnRadius)
			goX32 = (pillarTX + offsetX) * 32
			goY32 = (pillarTY + offsetY) * 32
		end
		
		local result = SimEntity.Citizen.m_TTDCOriginalCreateChar(self, simInstance, tbNpc, isNew, goX32, goY32)
		if (result and tbNpc.finalIndex and tbNpc.finalIndex > 0
		    and tbNpc.nMapId and FIELD_LIST) then
			local isTTDCMap = 0
			for i = 1, getn(FIELD_LIST) do
				if (FIELD_LIST[i] == tbNpc.nMapId) then
					isTTDCMap = 1
					break
				end
			end
			if (isTTDCMap == 1 and SetNpcCurCamp) then
				local stt = SimEntity.Citizen.m_TTDCSimThatThanh
				local botCurC = (stt and stt.getBotCurCamp and stt:getBotCurCamp()) or 1
				SetNpcCurCamp(tbNpc.finalIndex, botCurC)
				if (SetNpcBang and tbNpc.bangDisp) then SetNpcBang(tbNpc.finalIndex, tbNpc.bangDisp); if (stt and stt.m_BangByIdx) then stt.m_BangByIdx[tbNpc.finalIndex] = tbNpc.bangDisp end end
				-- TmpCamp = bang.camp (registered) cho damage check.
				-- Lookup bang.camp tu tbNpc.bangIdx (set boi spawnSimCitizen).
				local botTmpC = botCurC  -- fallback
				if (tbNpc.bangIdx and stt and stt.m_FakeBangs
				    and stt.m_FakeBangs[tbNpc.bangIdx]) then
					botTmpC = stt.m_FakeBangs[tbNpc.bangIdx].camp or botCurC
				end
				if (SetTmpCamp) then
					SetTmpCamp(botTmpC, tbNpc.finalIndex)
				end
				-- RE-REGISTER: SimCity co the recreate engine NPC khi sim tu revival
				-- ma khong di qua spawnSimCitizen path -> finalIndex moi mat reg.
				-- Hook nay chay moi lan engine NPC tao ra -> re-register lai.
				if (tbNpc.isTTDCBot == 1 and tbNpc.bangIdx
				    and SimFight and SimFight.Citizen
				    and SimFight.Citizen.m_TTDCRegistry) then
					SimFight.Citizen.m_TTDCRegistry[tbNpc.finalIndex] = tbNpc.bangIdx
				end
				-- Force AI=1, kind=0 (defender bot luon co the bi attack)
				if (tbNpc.isTTDCBot == 1) then
					if (SetNpcAI) then SetNpcAI(tbNpc.finalIndex, 1) end
					if (SetNpcKind) then SetNpcKind(tbNpc.finalIndex, 0) end
					if (SetNpcDeathScript and SCRIPT_SIMTDC_DEATH) then
						SetNpcDeathScript(tbNpc.finalIndex, SCRIPT_SIMTDC_DEATH)
					end
				end
			end
		end
		return result
	end
	SimEntity.Citizen.m_TTDCCreateCharPatched = 1
end

-- SimTheoSau:New hook - Doi ten sim keoxe trong TTDC
-- SimCityKeoXe:taoNV() set fighter.szName = SimCityNPCInfo:generateName()
if (SimTheoSau and SimTheoSau.New and not SimTheoSau.m_TTDCNamePatched) then
	SimTheoSau.m_TTDCOriginalNew = SimTheoSau.New
	SimTheoSau.m_TTDCStt = SimThatThanh   -- cache: base New doc m_IsRunning (gate keoxe bang)
	SimTheoSau.New = function(self, fighter)
		-- TTDC-only: chi rename khi sim spawn trong map TTDC.
		-- Outside TTDC giu nguyen ten random tu names.txt (giong SimCity goc).
		if (fighter and fighter.role == "keoxe" and fighter.playerID
		    and fighter.playerID ~= "" and FIELD_LIST) then
			-- Detect TTDC: try fighter.nMapId truoc, fallback ve player current map.
			local mapToCheck = fighter.nMapId or 0
			if (mapToCheck == 0 and SearchPlayer and CallPlayerFunction) then
				local pIdx = SearchPlayer(fighter.playerID)
				if (pIdx and pIdx > 0) then
					mapToCheck = CallPlayerFunction(pIdx, GetWorldPos) or 0
				end
			end
			local isTTDCMap = 0
			for i = 1, getn(FIELD_LIST) do
				if (FIELD_LIST[i] == mapToCheck) then
					isTTDCMap = 1
					break
				end
			end
			if (isTTDCMap == 1 and BattleWorld and BattleWorld.GetWarriorTong) then
				local pTong = BattleWorld:GetWarriorTong(fighter.playerID) or ""
				if (pTong ~= "") then
					-- Sim cua player: phan rank giong bot defender, nhung BO QUA Bang Chu
					-- (vi player chinh la Bang Chu). Counter per playerID rieng.
					SimThatThanh.m_SimRankCounter = SimThatThanh.m_SimRankCounter or {}
					local pid = fighter.playerID or "?"
					local cnt = (SimThatThanh.m_SimRankCounter[pid] or 0) + 1
					SimThatThanh.m_SimRankCounter[pid] = cnt
					-- Phan rank: 1-5 = Truong Lao, 6-15 = Duong Chu, 16+ = De Tu
					local nTL = SimThatThanh.CFG.BANG_RANK_TRUONG_LAO or 5
					local nDC = SimThatThanh.CFG.BANG_RANK_DUONG_CHU or 10
					local rankTitle = "§Ö Tö"
					if (cnt <= nTL) then
						rankTitle = "Tr­ëng l·o"
					elseif (cnt <= nTL + nDC) then
						rankTitle = "§­êng Chñ"
					end
					local bangName = format("%s-[%s]", pTong, rankTitle)
					fighter.bangDisp = bangName
					fighter.hardsetName = fighter.szName
				end
			end
		end
		-- KEOXE_FORMATION bounds override: SimCity force sim trong childrenCheckDistance
		-- tile cua parent. Goc=8 -> sim luon bi keo gan player du parentAppointPos
		-- (da scale boi Move hook) o xa. Override theo CFG de cho phep spread rong.
		if (fighter and fighter.role == "keoxe"
		    and SimThatThanh and SimThatThanh.CFG
		    and SimThatThanh.CFG.KEOXE_FORMATION_ENABLED == 1) then
			local newDist = SimThatThanh.CFG.KEOXE_CHILDREN_CHECK_DIST or 30
			if (newDist == 0) then
				fighter.childrenCheckDistance = nil  -- disable bounds hoan toan
			else
				fighter.childrenCheckDistance = newDist
			end
		end
		-- Goi original New de spawn sim (set finalIndex)
		local result = SimTheoSau.m_TTDCOriginalNew(self, fighter)
		if (SetNpcBang and fighter.finalIndex and fighter.finalIndex > 0 and fighter.bangDisp) then SetNpcBang(fighter.finalIndex, fighter.bangDisp) end
		
		-- POST-SPAWN: sim da co finalIndex, sync TmpCamp NGAY tu owner.
		if (fighter and fighter.role == "keoxe" and fighter.finalIndex
		    and fighter.finalIndex > 0 and fighter.playerID
		    and fighter.playerID ~= "" and SearchPlayer and CallPlayerFunction) then
			local pIdx = SearchPlayer(fighter.playerID)
			if (pIdx and pIdx > 0) then
				-- Doc TRUC TIEP TmpCamp cua player luc nay (PlayerIndex still valid)
				local pTmpC = CallPlayerFunction(pIdx, GetTmpCamp) or 0
				if (pTmpC > 0 and SetTmpCamp) then
					SetTmpCamp(pTmpC, fighter.finalIndex)
					fighter.m_TTDClastTmpCamp = pTmpC
					fighter.m_TTDClastValidTmpCamp = pTmpC
					-- Cache tu day cho future lookup boi Move hook
					if (SimThatThanh) then
						SimThatThanh.m_PlayerTmpCampCache = SimThatThanh.m_PlayerTmpCampCache or {}
						SimThatThanh.m_PlayerTmpCampCache[fighter.playerID] = pTmpC
					end
				end
				-- Sync CurCamp luon
				local pCurC = CallPlayerFunction(pIdx, GetCurCamp) or 0
				if (pCurC > 0 and SetNpcCurCamp) then
					SetNpcCurCamp(fighter.finalIndex, pCurC)
					fighter.camp = pCurC
				end
				-- (POST-SPAWN spread cu dung SetNpcPos da bo - JX1 khong co ham nay.
				-- Pre-spawn spread duoc xu ly trong SimEntity.KeoXe.CreateChar hook.)
			end
		end
		return result
	end
	SimTheoSau.m_TTDCNamePatched = 1
end

-- KeoXe sim hooks: prevent sim danh chu + sync camp follow chu.
if (SimMovement and SimMovement.KeoXe and not SimMovement.KeoXe.m_TTDCKeoXePatched) then
	-- Lua 4.x: store original + helper refs tren table.
	SimMovement.KeoXe.m_TTDCSimThatThanh = SimThatThanh
	SimMovement.KeoXe.m_TTDCOriginalIsActive = SimMovement.KeoXe.IsActive
	SimMovement.KeoXe.m_TTDCOriginalMove = SimMovement.KeoXe.Move
	
	-- Hook IsActive: clear owner khoi isPlayerEnemyAround.
	SimMovement.KeoXe.IsActive = function(self, simInstance, tbNpc)
		local r = SimMovement.KeoXe.m_TTDCOriginalIsActive(self, simInstance, tbNpc)
		if (tbNpc.isPlayerEnemyAround and tbNpc.isPlayerEnemyAround > 0) then
			local ownerPID = simInstance:GetPlayer(tbNpc.id)
			if (ownerPID and ownerPID > 0 and ownerPID == tbNpc.isPlayerEnemyAround) then
				tbNpc.isPlayerEnemyAround = 0
			end
		end
		return r
	end
	
	-- Hook Move: sync sim.camp = owner CurCamp (chu KHONG phai TmpCamp).
	SimMovement.KeoXe.Move = function(self, simInstance, tbNpc)
		-- (Code cu set parentAppointPos da bo - SimMovement.KeoXe.Move KHONG dung
		-- parentAppointPos. No NpcWalk(player + randomRange(walkVar=2)) -> sim
		-- luon ve sat player. Fix: GOI NpcWalk DE OVERRIDE target SAU original Move.)
		
		if (tbNpc.role == "keoxe" and tbNpc.playerID and tbNpc.playerID ~= ""
		    and tbNpc.finalIndex and tbNpc.finalIndex > 0) then
			-- GUARD: skip neu sim da chet han - tranh corrupt camp NPC khac
			if (tbNpc.isDead == 1 or tbNpc.noRevive == 1) then
				return SimMovement.KeoXe.m_TTDCOriginalMove(self, simInstance, tbNpc)
			end
			if (IsNpcExist and IsNpcExist(tbNpc.finalIndex) == 0) then
				return SimMovement.KeoXe.m_TTDCOriginalMove(self, simInstance, tbNpc)
			end
			-- GUARD: verify finalIndex VAN POINT toi DUNG sim nay (tranh index reuse).
			if (GetNpcParam and PARAM_LIST_ID) then
				local actualListId = GetNpcParam(tbNpc.finalIndex, PARAM_LIST_ID) or 0
				if (actualListId ~= tbNpc.id) then
					tbNpc.isDead = 1
					return SimMovement.KeoXe.m_TTDCOriginalMove(self, simInstance, tbNpc)
				end
			end
			local pID = simInstance:GetPlayer(tbNpc.id)
			if (pID and pID > 0) then
				local stt = SimMovement.KeoXe.m_TTDCSimThatThanh
				-- Cache player CurCamp neu valid (sim spawn outside TTDC)
				if (tbNpc.camp and tbNpc.camp >= 1 and tbNpc.camp <= 4
				    and stt and stt.cachePlayerCampValue) then
					stt:cachePlayerCampValue(tbNpc.camp)
				end
				-- Fix sim spawn TRONG TTDC voi camp = 0
				if ((not tbNpc.camp or tbNpc.camp <= 0 or tbNpc.camp > 4)
				    and stt and stt.m_RegisteredPlayerCamp
				    and stt.m_RegisteredPlayerCamp > 0) then
					tbNpc.camp = stt.m_RegisteredPlayerCamp
					if (SetNpcCurCamp) then SetNpcCurCamp(tbNpc.finalIndex, tbNpc.camp) end
				end
				-- Sync sim.camp Lua-side = owner CurCamp (cho Layer 2 filter)
				local curC = CallPlayerFunction(pID, GetCurCamp) or 0
				if (curC > 0 and curC ~= tbNpc.camp) then
					tbNpc.camp = curC
					if (SetNpcCurCamp) then SetNpcCurCamp(tbNpc.finalIndex, curC) end
					tbNpc.isPlayerEnemyAround = 0
					if (tbNpc.isFighting == 1 and tbNpc.fightSys and tbNpc.fightSys.LeaveFight) then
						tbNpc.fightSys:LeaveFight(simInstance, tbNpc, 0, "camp re-synced")
					end
				end
				-- Sync engine TmpCamp = owner TmpCamp (THROTTLE: check moi 5 tick)
				-- Tranh goi GetTmpCamp + SetTmpCamp moi tick cho 100+ sim -> giam load.
				tbNpc.m_TTDCTmpTick = (tbNpc.m_TTDCTmpTick or 0) + 1
				if (tbNpc.m_TTDCTmpTick >= 5) then
					tbNpc.m_TTDCTmpTick = 0
					local tmpC = CallPlayerFunction(pID, GetTmpCamp) or 0
					if (tmpC <= 0 and stt and stt.m_PlayerTmpCampCache
					    and stt.m_PlayerTmpCampCache[tbNpc.playerID]) then
						tmpC = stt.m_PlayerTmpCampCache[tbNpc.playerID]
					end
					if (tmpC <= 0 and tbNpc.m_TTDClastValidTmpCamp
					    and tbNpc.m_TTDClastValidTmpCamp > 0) then
						tmpC = tbNpc.m_TTDClastValidTmpCamp
					end
					if (tmpC > 0) then
						tbNpc.m_TTDClastValidTmpCamp = tmpC
						if (SetTmpCamp and GetTmpCamp) then
							local actualEngineTmpC = GetTmpCamp(tbNpc.finalIndex) or -1
							if (actualEngineTmpC ~= tmpC) then
								SetTmpCamp(tmpC, tbNpc.finalIndex)
								tbNpc.m_TTDClastTmpCamp = tmpC
							end
						end
					end
				end

				-- AGGRESSIVE LEAVE-FIGHT: chi trong TTDC (owner co TmpCamp > 0)
				local tmpCheck = tbNpc.m_TTDClastValidTmpCamp or 0
				if (tbNpc.isFighting == 1 and tbNpc.fightSys
				    and tbNpc.fightSys.IsNpcEnemyAround
				    and tmpCheck > 0) then
					local enemyIdx = tbNpc.fightSys:IsNpcEnemyAround(simInstance, tbNpc)
					local hasPlayerEnemy = (tbNpc.isPlayerEnemyAround
					                       and tbNpc.isPlayerEnemyAround > 0)
					if (enemyIdx == 0 and not hasPlayerEnemy) then
						if (SetNpcAI) then SetNpcAI(tbNpc.finalIndex, 0) end
						if (SetNpcKind) then SetNpcKind(tbNpc.finalIndex, 0) end
						if (tbNpc.fightSys.LeaveFight) then
							tbNpc.fightSys:LeaveFight(simInstance, tbNpc, 0,
								"force leave - chi co ally trong scan")
						end
					end
				end
			end
		end
		-- Goi original Move (handles fight, respawn, kind tracking, etc)
		local result = SimMovement.KeoXe.m_TTDCOriginalMove(self, simInstance, tbNpc)
		
		-- KEOXE_FORMATION OVERRIDE: original Move goi NpcWalk(player + walkVar=2)
		-- -> sim luon ve sat player. Sau original Move, GOI LAI NpcWalk voi target
		-- = player + fixed_offset + jitter de override walk goal.
		-- Cuoc goi NpcWalk sau win (engine lay walk target moi nhat).
		if (tbNpc and tbNpc.role == "keoxe"
		    and tbNpc.playerID and tbNpc.playerID ~= ""
		    and tbNpc.isDead ~= 1 and tbNpc.isFighting ~= 1
		    and tbNpc.finalIndex and tbNpc.finalIndex > 0
		    and (IsNpcExist == nil or IsNpcExist(tbNpc.finalIndex) ~= 0)
		    and NpcWalk) then
			local stt = SimMovement.KeoXe.m_TTDCSimThatThanh
			local cfg = (stt and stt.CFG) or nil
			if (cfg and cfg.KEOXE_FORMATION_ENABLED == 1) then
				local pID = simInstance:GetPlayer(tbNpc.id)
				if (pID and pID > 0) then
					local pW, pX, pY = CallPlayerFunction(pID, GetWorldPos)
					-- Chi override khi cung map (tranh interfere voi respawn logic)
					local nX32, nY32, nW32 = GetNpcPos(tbNpc.finalIndex)
					local nW = (SubWorldIdx2ID and SubWorldIdx2ID(nW32)) or nW32
					if (pX and pY and pX > 0 and pY > 0 and nW == pW) then
						-- Lazy compute fixed offset (1 lan moi sim)
						if (not tbNpc.m_TTDCFixedOffX) then
							local rMin = cfg.KEOXE_SPREAD_MIN_DIST or 4
							local rMax = cfg.KEOXE_SPREAD_MAX_DIST or 10
							local offX = random(-rMax, rMax)
							local offY = random(-rMax, rMax)
							local distSq = offX*offX + offY*offY
							if (distSq < rMin*rMin) then
								if (offX >= 0) then offX = rMin else offX = -rMin end
								if (offY >= 0) then offY = rMin else offY = -rMin end
							end
							tbNpc.m_TTDCFixedOffX = offX
							tbNpc.m_TTDCFixedOffY = offY
						end
						-- Walk to player + offset + jitter
						local jitter = cfg.KEOXE_FORMATION_JITTER or 2
						local jx = (jitter > 0 and random(-jitter, jitter)) or 0
						local jy = (jitter > 0 and random(-jitter, jitter)) or 0
						local targetX = pX + tbNpc.m_TTDCFixedOffX + jx
						local targetY = pY + tbNpc.m_TTDCFixedOffY + jy
						-- Override walk target (call sau original NpcWalk -> win)
						NpcWalk(tbNpc.finalIndex, targetX, targetY)
					end
				end
			end
		end
		return result
	end
	SimMovement.KeoXe.MoveInactive = SimMovement.KeoXe.Move
	
	SimMovement.KeoXe.m_TTDCKeoXePatched = 1
end

-- SimEntity.KeoXe.CreateChar hook - PRE-SPAWN spread vi tri sim keoxe quanh player.
-- Override goX32/goY32 truoc khi original CreateChar -> sim spawn truc tiep tai vi tri
-- spread (khong can teleport sau, khong can SetNpcPos - JX1 khong co).
if (SimEntity and SimEntity.KeoXe and SimEntity.KeoXe.CreateChar
    and not SimEntity.KeoXe.m_TTDCCreatePatched) then
	SimEntity.KeoXe.m_TTDCSimThatThanh = SimThatThanh
	SimEntity.KeoXe.m_TTDCOriginalCreateChar = SimEntity.KeoXe.CreateChar
	SimEntity.KeoXe.CreateChar = function(self, simInstance, tbNpc, isNew, goX32, goY32)
		-- Pre-create: override goX32/goY32 voi vi tri random quanh player.
		local stt = SimEntity.KeoXe.m_TTDCSimThatThanh
		local cfg = (stt and stt.CFG) or nil
		if (cfg and cfg.KEOXE_SPREAD_ENABLED == 1
		    and tbNpc and tbNpc.role == "keoxe"
		    and tbNpc.playerID and tbNpc.playerID ~= ""
		    and SearchPlayer and CallPlayerFunction) then
			local pIdx = SearchPlayer(tbNpc.playerID)
			if (pIdx and pIdx > 0) then
				local pW, pX, pY = CallPlayerFunction(pIdx, GetWorldPos)
				if (pX and pY and pX > 0 and pY > 0) then
					local rMin = cfg.KEOXE_SPREAD_MIN_DIST or 4
					local rMax = cfg.KEOXE_SPREAD_MAX_DIST or 10
					local offX = random(-rMax, rMax)
					local offY = random(-rMax, rMax)
					-- Push out neu qua sat (distSq < rMin^2)
					local distSq = offX*offX + offY*offY
					if (distSq < rMin*rMin) then
						if (offX >= 0) then offX = rMin else offX = -rMin end
						if (offY >= 0) then offY = rMin else offY = -rMin end
					end
					goX32 = (pX + offX) * 32
					goY32 = (pY + offY) * 32
					-- Cung cap nhat tbNpc.goX32/goY32 (cho code khac doc lai)
					tbNpc.goX32 = goX32
					tbNpc.goY32 = goY32
				end
			end
		end
		return SimEntity.KeoXe.m_TTDCOriginalCreateChar(self, simInstance, tbNpc, isNew, goX32, goY32)
	end
	SimEntity.KeoXe.m_TTDCCreatePatched = 1
end

-- SimCityKeoXe.ATick hook - scale formation rong ra + jitter khi player di chuyen.
-- ATick goc tao formation gon quanh player -> sim tu lai 1 cuc che player.
-- Hook nay re-implement ATick: van dung genCoords_squareshape de lay HUONG formation,
-- nhung scale distance tu player (theo CFG.KEOXE_FORMATION_SCALE) + add jitter.
if (SimCityKeoXe and SimCityKeoXe.ATick and not SimCityKeoXe.m_TTDCATickPatched) then
	-- Cross-env: cache refs tren table (timer/scheduler env khong thay globals).
	SimCityKeoXe.m_TTDCSimThatThanh = SimThatThanh
	SimCityKeoXe.m_TTDCRefSimTheoSau = SimTheoSau
	SimCityKeoXe.m_TTDCRefGenCoords = genCoords_squareshape
	SimCityKeoXe.m_TTDCRefCreateFormation = createFormation
	SimCityKeoXe.m_TTDCRefGetCenteredCell = getCenteredCell
	SimCityKeoXe.m_TTDCATickFireCount = 0
	SimCityKeoXe.m_TTDCATickWriteCount = 0
	SimCityKeoXe.m_TTDCOriginalATick = SimCityKeoXe.ATick
	SimCityKeoXe.ATick = function(self)
		-- Tang counter de SimTDC_KeoXeStatus check
		SimCityKeoXe.m_TTDCATickFireCount = (SimCityKeoXe.m_TTDCATickFireCount or 0) + 1
		
		local stt = SimCityKeoXe.m_TTDCSimThatThanh
		local cfg = (stt and stt.CFG) or nil
		-- Disable -> goi original
		if (not cfg or cfg.KEOXE_FORMATION_ENABLED ~= 1) then
			return SimCityKeoXe.m_TTDCOriginalATick(self)
		end
		local scale = cfg.KEOXE_FORMATION_SCALE or 3
		local jitter = cfg.KEOXE_FORMATION_JITTER or 2
		
		-- Cross-env-safe refs
		local _SimTheoSau = SimCityKeoXe.m_TTDCRefSimTheoSau or SimTheoSau
		local _genCoords = SimCityKeoXe.m_TTDCRefGenCoords or genCoords_squareshape
		local _createFormation = SimCityKeoXe.m_TTDCRefCreateFormation or createFormation
		local _getCenteredCell = SimCityKeoXe.m_TTDCRefGetCenteredCell or getCenteredCell
		
		-- Neu thieu ref, fallback ve original (de khong break sim)
		if (not _SimTheoSau or not _genCoords or not _createFormation or not _getCenteredCell) then
			return SimCityKeoXe.m_TTDCOriginalATick(self)
		end
		
		for name, children in self.collections do
			local parentID = SearchPlayer(name)
			if (parentID and parentID > 0) then
				local pW, pX, pY = CallPlayerFunction(parentID, GetWorldPos)
				local newLoc = "" .. pW .. pY .. pX
				if (not self.collections_knownPoint[name]
				    or self.collections_knownPoint[name] ~= newLoc) then
					self.collections_knownPoint[name] = newLoc
					local size = getn(children)
					if (size > 0) then
						local centerCharId = _getCenteredCell(_createFormation(size))
						local fighter = _SimTheoSau:Get(children[centerCharId])
						if (fighter and fighter.finalIndex and fighter.finalIndex > 0) then
							local nX, nY, nMapIndex = GetNpcPos(fighter.finalIndex)
							local newPath = _genCoords(
								{ nX / 32, nY / 32 }, { pX, pY }, size)
							for i = 1, size do
								local sim = _SimTheoSau:Get(children[i])
								if (sim and newPath[i]) then
									-- Scale outward from player center
									local dx = newPath[i][1] - pX
									local dy = newPath[i][2] - pY
									local jx, jy = 0, 0
									if (jitter > 0) then
										jx = random(-jitter, jitter)
										jy = random(-jitter, jitter)
									end
									sim.parentAppointPos = {
										pX + floor(dx * scale) + jx,
										pY + floor(dy * scale) + jy
									}
									SimCityKeoXe.m_TTDCATickWriteCount =
										(SimCityKeoXe.m_TTDCATickWriteCount or 0) + 1
								end
							end
						end
					end
				end
			end
		end
	end
	SimCityKeoXe.m_TTDCATickPatched = 1
end

if (SimEntity and SimEntity.KeoXe and SimEntity.KeoXe.OnDeath
    and not SimEntity.KeoXe.m_TTDCDeathPatched) then
	-- Cache FIELD_LIST vao table de hook truy cap (Lua 4.x: closure khong upvalue,
	-- va hook chay trong env khac co the khong thay FIELD_LIST global).
	SimEntity.KeoXe.m_TTDCFieldList = FIELD_LIST
	SimEntity.KeoXe.m_TTDCOriginalOnDeath = SimEntity.KeoXe.OnDeath
	SimEntity.KeoXe.OnDeath = function(self, simInstance, tbNpc, nNpcIndex, attackerIndex)
		local actualMapId = tbNpc and tbNpc.nMapId or 0
		if (actualMapId == 0 and nNpcIndex and nNpcIndex > 0 and GetNpcWorld) then
			local subWorldIdx = GetNpcWorld(nNpcIndex)
			if (subWorldIdx and subWorldIdx >= 0 and SubWorldIdx2ID) then
				actualMapId = SubWorldIdx2ID(subWorldIdx) or 0
			end
		end
		
		-- Lay FIELD_LIST tu cache (an toan voi env khac)
		local fieldList = SimEntity.KeoXe.m_TTDCFieldList
		local fieldCount = (fieldList and getn(fieldList)) or 0
		
		if (tbNpc and tbNpc.role == "keoxe" and actualMapId > 0
		    and fieldList and fieldCount > 0) then
			local isTTDCMap = 0
			for i = 1, fieldCount do
				if (fieldList[i] == actualMapId) then
					isTTDCMap = 1
					break
				end
			end
			if (isTTDCMap == 1) then
				tbNpc.noRevive = 1
			end
		end
		-- Goi original OnDeath (handle noRevive=1 logic, leave fight, etc.)
		local result = SimEntity.KeoXe.m_TTDCOriginalOnDeath(self, simInstance, tbNpc, nNpcIndex, attackerIndex)
		
		-- Sim chet han trong TTDC: SimCity skip Remove cho keoxe role.
		if (tbNpc and tbNpc.role == "keoxe" and tbNpc.noRevive == 1
		    and simInstance and simInstance.Remove) then
			local playerID = tbNpc.playerID or ""
			local simID = tbNpc.id
			simInstance:Remove(simID)
			
			if (SimCityKeoXe and SimCityKeoXe.collections
			    and SimCityKeoXe.collections[playerID]) then
				local list = SimCityKeoXe.collections[playerID]
				local newList = {}
				for i = 1, getn(list) do
					if (list[i] ~= simID) then
						tinsert(newList, list[i])
					end
				end
				SimCityKeoXe.collections[playerID] = newList
			end
			if (SimCityKeoXe and SimCityKeoXe.collections_knownPoint) then
				SimCityKeoXe.collections_knownPoint[playerID] = nil
			end
			if (SimCityKeoXe and SimCityKeoXe.collections_knownPoint) then
				SimCityKeoXe.collections_knownPoint[playerID] = nil
			end
		end
		return result
	end
	SimEntity.KeoXe.m_TTDCDeathPatched = 1
end

-- SimCityKeoXe.nv_tudo_xe hook - tang so luong sim moi lan goi.
if (SimCityKeoXe and SimCityKeoXe.nv_tudo_xe
    and not SimCityKeoXe.m_TTDCSimCountPatched) then
	SimCityKeoXe.m_TTDCOriginalNvTudoXe = SimCityKeoXe.nv_tudo_xe
	SimCityKeoXe.nv_tudo_xe = function(self, capHP)
		-- Map capHP -> so luong sim
		local count = 10
		if (capHP == 1) then
			if (self.m_TTDCStt and self.m_TTDCStt.m_IsRunning == 1) then count = 40 else count = 10 end
		elseif (capHP == 2) then count = 10
		elseif (capHP == 3) then count = 10
		elseif (capHP == 4) then count = 10 end
		
		-- Replicate logic original nhung voi count tuy chinh
		local forCamp = GetCurCamp()
		local pW, pX, pY = GetWorldPos()
		local pool = SimCityNPCInfo:getPoolByCap(capHP)
		
		for i = 1, count do
			local pid = pool[random(1, getn(pool))]
			while SimCityNPCInfo:notFightingChar(pid) == 1 do
				pid = pool[random(1, getn(pool))]
			end
			local children = {}
			self:taoNV(pid, forCamp, pW, {}, 1, children, capHP)
		end
	end
	SimCityKeoXe.m_TTDCStt = SimThatThanh
	SimCityKeoXe.m_TTDCSimCountPatched = 1
end

-- SimFight.KeoXe.IsNpcEnemyAround (TTDC-aware ally filter):
if (SimFight and SimFight.KeoXe and SimFight.KeoXe.IsNpcEnemyAround
    and not SimFight.KeoXe.m_TTDCEnemyFilterPatched) then
	SimFight.KeoXe.m_TTDCOriginalIsNpcEnemyAround = SimFight.KeoXe.IsNpcEnemyAround
	SimFight.KeoXe.IsNpcEnemyAround = function(self, simInstance, tbNpc)
		local radius = tbNpc.RADIUS_FIGHT_SCAN or RADIUS_FIGHT_SCAN
		local pID = simInstance:GetPlayer(tbNpc.id)
		if (not pID or pID <= 0) then return 0 end
		local allNpcs, nCount = CallPlayerFunction(pID, GetAroundNpcList, radius)
		local ownerTmpCamp = CallPlayerFunction(pID, GetTmpCamp) or 0
		local ownerCurCamp = CallPlayerFunction(pID, GetCurCamp) or 0
		for i = 1, nCount do
			if (allNpcs[i] ~= tbNpc.finalIndex) then
				local fKind = GetNpcKind(allNpcs[i])
				local fCamp = GetNpcCurCamp(allNpcs[i]) or 0
				if (fKind == 0 and fCamp > 0) then
					local isEnemy = 0
					if (ownerTmpCamp > 0) then
						-- Trong TTDC: enemy = fCamp khac CA owner.TmpCamp lan owner.CurCamp.
						if (fCamp ~= ownerTmpCamp and fCamp ~= ownerCurCamp) then
							isEnemy = 1
						end
					else
						-- Ngoai TTDC: dung engine logic
						if (IsAttackableCamp(tbNpc.camp, fCamp) == 1) then
							isEnemy = 1
						end
					end
					if (isEnemy == 1) then
						return allNpcs[i]
					end
				end
			end
		end
		return 0
	end
	SimFight.KeoXe.m_TTDCEnemyFilterPatched = 1
end

-- Bot-kill tru detection: thong qua monster_death.lua OnDeath script
-- (PlayerIndex=0 -> HandleBotKillPillar) hoac PollCaptures watchdog.

function SimThatThanh:mapIdOfIndex(mapid)
	for i = 1, getn(FIELD_LIST) do
		if (FIELD_LIST[i] == mapid) then return i end
	end
	return 0
end

function SimThatThanh:findPlayerMap()
	local seen = {}
	for i = 1, getn(FIELD_LIST) do
		local field = BattleWorld:FindField(FIELD_LIST[i])
		if (field and field.m_List) then
			for pIdx, player in field.m_List do
				if (player and player.m_PlayerIndex and player.m_PlayerIndex > 0
				    and not seen[player.m_PlayerIndex]) then
					seen[player.m_PlayerIndex] = 1
					local curMap, _, _ = player:GetWorldPos()
					for j = 1, getn(FIELD_LIST) do
						if (FIELD_LIST[j] == curMap) then
							return curMap, player.m_PlayerIndex
						end
					end
				end
			end
		end
	end
	return 0, 0
end

-- ============== PATCHES (SimCityWorld, SimFight) ==============
function SimThatThanh:patchSimCityWorld()
	if (not SimCityWorld or not SimCityWorld.Get) then
		self:log("ERROR: SimCityWorld is nil"); return
	end
	if (SimCityWorld.m_TTDCPatched == 1) then return end
	
	SimCityWorld.m_TTDCInjected    = {}
	SimCityWorld.m_TTDCOriginalGet = SimCityWorld.Get
	SimCityWorld.Get = function(scwSelf, nMapId)
		if (SimCityWorld.m_TTDCInjected[nMapId]) then
			return SimCityWorld.m_TTDCInjected[nMapId]
		end
		return SimCityWorld.m_TTDCOriginalGet(scwSelf, nMapId)
	end
	SimCityWorld.m_TTDCPatched = 1
	self:log("Patched SimCityWorld:Get")
end

function SimThatThanh:patchFightSys()
	if (not SimFight or not SimFight.Citizen) then
		self:log("ERROR: SimFight.Citizen is nil"); return
	end
	if (SimFight.Citizen.m_TTDCPatched == 1) then return end
	if (not SimFight.Citizen.IsNpcEnemyAround) then
		self:log("ERROR: IsNpcEnemyAround is nil"); return
	end
	
	SimFight.Citizen.m_TTDCRegistry  = SimFight.Citizen.m_TTDCRegistry  or {}
	SimFight.Citizen.m_TTDCPillarIdx = SimFight.Citizen.m_TTDCPillarIdx or {}
	SimFight.Citizen.m_TTDCOriginal  = SimFight.Citizen.IsNpcEnemyAround
	-- Cache global SimThatThanh ref tren table de hook truy cap duoc trong
	-- env khac (component env khong thay global SimThatThanh - Lua 4.x closure
	-- khong upvalue + IsNpcEnemyAround duoc goi tu env khac).
	SimFight.Citizen.m_TTDCSimThatThanh = SimThatThanh
	if (BattleWorld) then
		SimFight.Citizen.m_TTDCBW = BattleWorld
	end
	
	SimFight.Citizen.IsNpcEnemyAround = function(fsSelf, simInstance, tbNpc)
		if (tbNpc.isTTDCBot == 1) then
			local stt = SimFight.Citizen.m_TTDCSimThatThanh
			local radius = tbNpc.RADIUS_FIGHT_SCAN
				or (stt and stt.CFG and stt.CFG.AGGRO_RADIUS_SCAN) or 25
			local allNpcs, nCount = GetNpcAroundNpcList(tbNpc.finalIndex, radius)
			local lookup = SimFight.Citizen.m_TTDCRegistry
			local myBangIdx = tbNpc.bangIdx or 0
			local mapid = tbNpc.nMapId or 0
			
			local pillarIdx = SimFight.Citizen.m_TTDCPillarIdx[mapid] or 0
			local pillarCamp = 0
			local bw = SimFight.Citizen.m_TTDCBW
			if (bw and bw.m_FieldList and bw.m_FieldList[mapid]
			    and bw.m_FieldList[mapid].m_Monster
			    and bw.m_FieldList[mapid].m_Monster.m_NpcIndex
			    and bw.m_FieldList[mapid].m_Monster.m_NpcIndex > 0) then
				pillarIdx = bw.m_FieldList[mapid].m_Monster.m_NpcIndex
				pillarCamp = bw.m_FieldList[mapid].m_Monster.m_Camp or 0
			end
			
			-- Xet pillar co phai enemy cua bot khong:
			-- pillar.m_Camp = bang.camp (uncaptured) hoac player.TmpCamp (captured).
			-- bot.TmpCamp = bang.camp cua bot. Khac registered tong = enemy.
			local pillarIsEnemy = 0
			if (pillarIdx > 0 and pillarCamp > 0) then
				local botBang = (stt and stt.m_FakeBangs and stt.m_FakeBangs[myBangIdx])
				local myTmpC = (botBang and botBang.camp) or 0
				if (myTmpC > 0 and pillarCamp ~= myTmpC) then
					pillarIsEnemy = 1
				end
			end
			
			-- TEST MODE: 100% focus tru khi tru la enemy (player da chiem)
			if (pillarIsEnemy == 1) then
				return pillarIdx
			end
			
			for i = 1, nCount do
				local targetIdx = allNpcs[i]
				if (targetIdx ~= tbNpc.finalIndex) then
					-- Truong hop target la pillar (cua bang minh vi pillarIsEnemy=0)
					if (targetIdx == pillarIdx) then
						-- pillar cua bang minh -> skip
					else
						local targetBangIdx = lookup[targetIdx]
						if (targetBangIdx) then
							if (targetBangIdx == -1) then
								-- pillar marker (cached tu registry) - SKIP
							elseif (targetBangIdx ~= myBangIdx) then
								return targetIdx
							end
						else
							local fcamp = GetNpcCurCamp(targetIdx)
							if (IsAttackableCamp(tbNpc.camp, fcamp) == 1) then
								return targetIdx
							end
						end
					end
				end
			end
			return 0
		end
		return SimFight.Citizen.m_TTDCOriginal(fsSelf, simInstance, tbNpc)
	end
	
	if (SimFight.Citizen.SetFightState and SimFight.Citizen.m_TTDCSFSPatched ~= 1) then
		SimFight.Citizen.m_TTDCOriginalSFS = SimFight.Citizen.SetFightState
		SimFight.Citizen.SetFightState = function(fsSelf, tbNpc, mode, nX, nY)
			if (tbNpc.isTTDCBot == 1) then
				SetNpcAI(tbNpc.finalIndex, 1)
				return
			end
			return SimFight.Citizen.m_TTDCOriginalSFS(fsSelf, tbNpc, mode, nX, nY)
		end
		SimFight.Citizen.m_TTDCSFSPatched = 1
		self:log("Patched SimFight.Citizen.SetFightState")
	end
	
	SimFight.Citizen.m_TTDCPatched = 1
	self:log("Patched SimFight.Citizen.IsNpcEnemyAround")
end

function SimThatThanh:patchMonsterCreateNpc()
	-- Top-level auto-hook (line ~118) da hook Monster.CreateNpc/OnTime/Down.
	if (not Monster or not Monster.CreateNpc) then
		self:log("ERROR: Monster.CreateNpc is nil"); return
	end
	if (BattleWorld and BattleWorld.m_FieldList) then
		local cnt = 0
		local regCnt = 0
		for mapid, field in BattleWorld.m_FieldList do
			if (field and field.m_Monster) then
				field.m_Monster.CreateNpc = Monster.CreateNpc
				field.m_Monster.OnTime = Monster.OnTime
				field.m_Monster.Down = Monster.Down
				cnt = cnt + 1
				if (field.m_Monster.m_NpcIndex and field.m_Monster.m_NpcIndex > 0
				    and SimFight and SimFight.Citizen and SimFight.Citizen.m_TTDCRegistry) then
					local pIdx = field.m_Monster.m_NpcIndex
					SimFight.Citizen.m_TTDCRegistry[pIdx] = -1
					if (SimFight.Citizen.m_TTDCPillarIdx) then
						SimFight.Citizen.m_TTDCPillarIdx[mapid] = pIdx
					end
					regCnt = regCnt + 1
				end
			end
		end
		if (cnt > 0) then
			self:log(format("Patched %d Monster clones (CreateNpc+Down), registered %d pillars",
				cnt, regCnt))
		end
	end
end

-- HandleBotKillPillar: goi tu monster_death.lua khi phat hien bot-kill
function SimThatThanh:HandleBotKillPillar(killed_index, attackerIndex)
		-- Suppress trong luc StartAll/ClearAll (DelNpc trigger OnDeath false-positive)
	if (self.m_SuppressBotKill == 1) then
		return
	end
	
	-- Tim map co tru vua chet: STRICT match killed_index voi cached pillar idx
	-- KHONG match m_NpcIndex=0 (false-positive cho tat ca map co tru tam thoi unset)
	local mapid = 0
	local field = nil
	for i = 1, getn(FIELD_LIST) do
		local mid = FIELD_LIST[i]
		local cachedIdx = (SimFight and SimFight.Citizen
			and SimFight.Citizen.m_TTDCPillarIdx
			and SimFight.Citizen.m_TTDCPillarIdx[mid]) or 0
		if (cachedIdx == killed_index) then
			mapid = mid
			field = BattleWorld:FindField(mid)
			break
		end
	end
	
	if (mapid == 0 or not field or not field.m_Monster) then
		return
	end
	
	-- Check tru vua chet CO PHAI bi player chiem khong
	local lastCamp = field.m_Monster.m_Camp or 0
	if (lastCamp == CAMP_MONSTER) then
		-- Tru CAMP_MONSTER chet -> player kill, default flow se chay
		self:log(format("HandleBotKillPillar map %d: pillar camp=CAMP_MONSTER, skip (edge case)", mapid))
		return
	end
	if (self.m_FakeCamps and self.m_FakeCamps[lastCamp]) then
		-- Tru fake bang (uncaptured) chet boi gi do KHONG phai player.
		local ownerName = nil
		local ownerTmpCamp = 0
		-- Method 1: dung attackerIndex (chinh xac nhat). Engine co the khong pass
		-- attackerIndex cho monster_death script -> attacker=0.
		if (attackerIndex and attackerIndex > 0 and GetNpcParam) then
			local atkType = GetNpcParam(attackerIndex, PARAM_TYPE) or 0
			if (atkType == 2) then
				local atkListId = GetNpcParam(attackerIndex, PARAM_LIST_ID) or 0
				if (atkListId > 0 and SimTheoSau and SimTheoSau.fighterList) then
					local atkSim = SimTheoSau.fighterList[atkListId]
					if (atkSim and atkSim.playerID and atkSim.playerID ~= "") then
						ownerName = atkSim.playerID
						local pID = SearchPlayer(ownerName)
						if (pID and pID > 0) then
							ownerTmpCamp = CallPlayerFunction(pID, GetTmpCamp) or 0
						end
					end
				end
			end
		end
		-- Method 2 (fallback): tim player dang trong field's m_List. Trong TTDC
		-- thuong 1 player 1 map -> sim cua player do dap tru. Hop ly pick first.
		if ((not ownerName or ownerTmpCamp <= 0) and field.m_List) then
			for pIdx, p in field.m_List do
				if (p and p.GetName and p.GetTmpCamp) then
					local pName = p:GetName() or ""
					local pTmp = p:GetTmpCamp() or 0
					if (pName ~= "" and pTmp > 0) then
						ownerName = pName
						ownerTmpCamp = pTmp
						self:log(format("Map %d sim-kill: fallback m_List found player='%s' tmpC=%d",
							mapid, pName, pTmp))
						break
					end
				end
			end
		end
		
		if (ownerName and ownerTmpCamp > 0) then
			-- CASE A: sim cua player giet uncaptured pillar -> CAPTURE bang owner
			local ownerTong = (BattleWorld and BattleWorld.GetWarriorTong
				and BattleWorld:GetWarriorTong(ownerName)) or ownerName
			self:log(format("Map %d FAKE pillar killed by SIM (owner=%s tong=%s) -> CAPTURE",
				mapid, ownerName, ownerTong))
			field.m_Monster.m_Camp = ownerTmpCamp
			-- Luu owner CurCamp de pillar mar engine CurCamp = 1-4 valid
			-- (sim cung CurCamp -> engine no attack)
			local ownerPID = SearchPlayer(ownerName)
			local ownerCurC = 0
			if (ownerPID and ownerPID > 0) then
				ownerCurC = CallPlayerFunction(ownerPID, GetCurCamp) or 0
			end
			if (ownerCurC <= 0) then
				ownerCurC = self.m_RegisteredPlayerCamp or 0
			end
			field.m_Monster.m_TTDCEngineCurCamp = ownerCurC
			field.m_Monster.m_NpcIndex = 0
			if (field.m_Monster.CloseTimer) then field.m_Monster:CloseTimer() end
			local pillarName = "Long trô [" .. ownerTong .. "]"
			field.m_Monster.m_TTDCPendingPillarName = pillarName
			field.m_Monster.m_TTDCDeferTimerId = TimerList:AddTimer(field.m_Monster, 9, 3)
			-- Schedule TIMEOUT_MONSTER countdown -> OnTime(1) -> Thu Long Tru (bat tu)
			if (field.m_Monster.StartTimer) then field.m_Monster:StartTimer() end
			self.m_MapCaptured[mapid] = 1
			if (AddGlobalNews and MAP_INFO and MAP_INFO[mapid]) then
				AddGlobalNews(format("[%s] long trô bÞ bang héi %s %s ph¸ vì!",
					MAP_INFO[mapid].Name or "?", ownerTong, ownerName))
			end
			if (ObjBuffer and RemoteExecute and REMOTE_SCRIPT) then
				local buff = ObjBuffer:New()
				buff:Push(mapid)
				buff:Push(ownerTong)
				RemoteExecute(REMOTE_SCRIPT, "BattleWorld:SimTDCOccupy", buff.m_Handle)
				buff:Destroy()
			end
		else
			-- CASE B: khong xac dinh attacker -> respawn same fake bang
			local defenderBangIdx = self.m_MapDefenderBangIdx[mapid]
			local defenderBang = defenderBangIdx and self.m_FakeBangs[defenderBangIdx]
			if (defenderBang and defenderBang.camp == lastCamp) then
				self:log(format("Map %d FAKE pillar killed (unknown) -> respawn same bang '%s'",
					mapid, defenderBang.name))
				field.m_Monster.m_Camp = defenderBang.camp
				field.m_Monster.m_NpcIndex = 0
				if (field.m_Monster.CloseTimer) then field.m_Monster:CloseTimer() end
				local pillarName = "Long Trô [" .. defenderBang.name .. "]"
				field.m_Monster.m_TTDCPendingPillarName = pillarName
				field.m_Monster.m_TTDCDeferTimerId = TimerList:AddTimer(field.m_Monster, 9, 3)
				-- Schedule TIMEOUT_MONSTER countdown -> Thu Long Tru
				if (field.m_Monster.StartTimer) then field.m_Monster:StartTimer() end
			end
		end
		return
	end
	-- Tru camp player (hoac unknown) -> bot giet tru player -> takeover
	
	local defenderBangIdx = self.m_MapDefenderBangIdx[mapid]
	local defenderBang = defenderBangIdx and self.m_FakeBangs[defenderBangIdx]
	if (not defenderBang) then
		self:log(format("HandleBotKillPillar map %d: no defender bang", mapid))
		return
	end
	
	self:log(format("Map %d BOT-KILL via OnDeath -> takeover by '%s'",
		mapid, defenderBang.name))
	
	-- Set camp + DEFER pillar respawn 0.5s (giong fix Monster:Down)
	field.m_Monster.m_Camp = defenderBang.camp
	field.m_Monster.m_NpcIndex = 0
	if (field.m_Monster.CloseTimer) then field.m_Monster:CloseTimer() end
	
	local pillarName = "Long Trô [" .. defenderBang.name .. "]"
	field.m_Monster.m_TTDCPendingPillarName = pillarName
	field.m_Monster.m_TTDCDeferTimerId = TimerList:AddTimer(field.m_Monster, 9, 3)
	-- Schedule TIMEOUT_MONSTER countdown -> Thu Long Tru
	if (field.m_Monster.StartTimer) then field.m_Monster:StartTimer() end
	
	self.m_MapCaptured[mapid] = nil
	
	if (AddGlobalNews) then
		local cityname = (MAP_INFO[mapid] and MAP_INFO[mapid].CityName) or "?"
		AddGlobalNews(format("[%s] Long Trô ®· bÞ bang %s chiÕm gi÷!",
			cityname, defenderBang.name))
	end
	
	if (ObjBuffer and RemoteExecute and REMOTE_SCRIPT) then
		local buff = ObjBuffer:New()
		buff:Push(mapid)
		buff:Push(defenderBang.realTong or defenderBang.name)
		RemoteExecute(REMOTE_SCRIPT, "BattleWorld:SimTDCOccupy", buff.m_Handle)
		buff:Destroy()
	end
end

-- ====== POLL CAPTURES ======
function SimThatThanh:PollCaptures()
	if (not SimFight or not SimFight.Citizen or not SimFight.Citizen.m_TTDCPillarIdx) then
		return
	end
	for i = 1, getn(FIELD_LIST) do
		local mapid = FIELD_LIST[i]
		local field = BattleWorld:FindField(mapid)
		if (field and field.m_Monster) then
			local currentPillarIdx = field.m_Monster.m_NpcIndex or 0
			if (currentPillarIdx > 0) then
				SimFight.Citizen.m_TTDCPillarIdx[mapid] = currentPillarIdx
			end
			
			-- CASE 1: Bot giet tru. Tru chet -> death_script chay -> co the
			if (currentPillarIdx == 0 and self.m_MapCaptured[mapid] == 1) then
				-- GUARD: skip neu dang trong defer window cua Monster:Down
				-- (1.5s sau player giet tru, idx=0 nhung pending respawn cho player)
				if (field.m_Monster.m_TTDCPendingPillarName) then
					self:log(format("Map %d skip BOT-KILL detect (defer window)", mapid))
				else
				local defenderBangIdx = self.m_MapDefenderBangIdx[mapid]
				local defenderBang = defenderBangIdx and self.m_FakeBangs[defenderBangIdx]
				if (defenderBang) then
					self:log(format("Map %d BOT-KILL detected (pillar idx=0) -> takeover by '%s'",
						mapid, defenderBang.name))
					
					-- Reset monster state + DEFER respawn 0.5s (giong HandleBotKillPillar)
					field.m_Monster.m_Camp = defenderBang.camp
					field.m_Monster.m_NpcIndex = 0
					if (field.m_Monster.CloseTimer) then field.m_Monster:CloseTimer() end
					
					local pillarName = "Long Trô [" .. defenderBang.name .. "]"
					field.m_Monster.m_TTDCPendingPillarName = pillarName
					field.m_Monster.m_TTDCDeferTimerId = TimerList:AddTimer(field.m_Monster, 9, 3)
					
					-- Reset captured state -> map thuoc fake bang lai
					self.m_MapCaptured[mapid] = nil
					
					-- Broadcast news
					if (AddGlobalNews) then
						local cityname = (MAP_INFO[mapid] and MAP_INFO[mapid].CityName) or "?"
						AddGlobalNews(format("[%s] Long Trô ®· bÞ bang %s chiÕm gi÷!",
							cityname, defenderBang.name))
					end
					
					-- Sync gateway
					if (ObjBuffer and RemoteExecute and REMOTE_SCRIPT) then
						local buff = ObjBuffer:New()
						buff:Push(mapid)
						buff:Push(defenderBang.realTong or defenderBang.name)
						RemoteExecute(REMOTE_SCRIPT, "BattleWorld:SimTDCOccupy", buff.m_Handle)
						buff:Destroy()
					end
				end
				end
			end
			
			-- CASE 2: PLAYER capture (first time) - m_Camp doi sang player camp
			if (field.m_Monster.m_Camp ~= CAMP_MONSTER
			    and (not self.m_FakeCamps or not self.m_FakeCamps[field.m_Monster.m_Camp])
			    and self.m_MapCaptured[mapid] ~= 1) then
				self.m_MapCaptured[mapid] = 1
				self:log(format("Map %d CAPTURED by PLAYER (defender bots giu lai, tru binh thuong)",
					mapid))
				if (AddLocalNews) then
					AddLocalNews(format("<color=yellow>B¹n ®· chiÕm ®­îc thµnh %s! H·y Gi÷ Long Trô!<color>",
						MAP_INFO[mapid].CityName or "thµnh"))
				end
			end
		end
	end
end

-- ====== BATCH RESPAWN SYSTEM ======
function SimThatThanh:checkBatchRespawn()
	if (self.CFG.BATCH_RESPAWN_ENABLED ~= 1) then return end
	
	local totalPerMap = (self.CFG.PILLAR_TANK_PER_BANG or 0)
	                  + (self.CFG.CENTER_BOTS_PER_BANG or 16)
	                  + (self.CFG.GATE_BOTS_PER_BANG or 0)
	local triggerRatio = self.CFG.BATCH_TRIGGER_RATIO or 0.7
	local threshold = floor(totalPerMap * triggerRatio)
	-- Time-based cooldown (giay) - dung GetCurrentTime() chinh xac.
	-- Cu cu dung tick math sai unit -> 30s thanh 180s.
	local cooldownSec = self.CFG.BATCH_COOLDOWN_SEC or 30
	local now = (GetCurrentTime and GetCurrentTime()) or 0
	
	for i = 1, getn(FIELD_LIST) do
		local mapid = FIELD_LIST[i]
		if (not self.m_BatchPending[mapid]) then
			local lastTime = self.m_LastBatchTime[mapid] or 0
			if ((now - lastTime) >= cooldownSec) then
				-- Dem alive defender (skip invader)
				local alive = 0
				-- Dung fighterList cho chinh xac (m_MapNpcs co the stale)
				local _SimCitizen = self.m_RefSimCitizen or SimCitizen
				if (_SimCitizen and _SimCitizen.fighterList) then
					for listId, fighter in _SimCitizen.fighterList do
						if (fighter and fighter.isTTDCBot == 1
						    and fighter.nMapId == mapid
						    and fighter.isDead ~= 1
						    and fighter.finalIndex and fighter.finalIndex > 0
						    and (IsNpcExist == nil or IsNpcExist(fighter.finalIndex) ~= 0)) then
							alive = alive + 1
						end
					end
				end
				
				if (alive <= threshold) then
					self:triggerBatchRespawn(mapid, totalPerMap - alive)
				end
			end
		end
	end
end

-- Trigger batch respawn: spawn N bot mei tai tru qua stagger timer.
function SimThatThanh:triggerBatchRespawn(mapid, count)
	if (count <= 0) then return 0 end
	
	local info = MAP_INFO[mapid]
	if (not info or not info.MonsterPos) then return 0 end
	local pillarTX = floor(info.MonsterPos[1] / 32)
	local pillarTY = floor(info.MonsterPos[2] / 32)
	
	local bang = nil
	local defenderBangIdx = self.m_MapDefenderBangIdx[mapid]
	if (defenderBangIdx) then
		bang = self.m_FakeBangs[defenderBangIdx]
	end
	if (not bang) then return 0 end
	
	self.m_BatchPending[mapid] = {
		bang = bang, pillarTX = pillarTX, pillarTY = pillarTY,
		totalRemaining = count, perTick = self.CFG.BATCH_STAGGER_PER_TICK or 5,
	}
	self.m_LastBatchTime[mapid] = (GetCurrentTime and GetCurrentTime()) or 0
	
	-- Schedule first tick spawn
	if (TimerList and TimerList.AddTimer) then
		TimerList:AddTimer(TTDCBatchSpawnHandler, 9, mapid)
	end
	
	-- Thong bao
	--if (self.CFG.BATCH_ANNOUNCE == 1 and AddGlobalNews) then
	--	local cityName = info.CityName or ("Map " .. mapid)
	--	AddGlobalNews(format("[%s] Bang %s tiep vien %d nhan vat!",
	--		cityName, bang.name, count))
	--end
	
	self:log(format("Map %d: BATCH respawn %d bots (bang=%s)",
		mapid, count, bang.name))
	return 1
end

-- Stagger handler: spawn perTick bot moi tick.
TTDCBatchSpawnHandler = TTDCBatchSpawnHandler or {}
function TTDCBatchSpawnHandler:OnTime(mapid)
	if (SimThatThanh.m_IsRunning == 0) then return 0 end
	local batch = SimThatThanh.m_BatchPending[mapid]
	if (not batch) then return 0 end
	
	local toSpawn = batch.perTick
	if (toSpawn > batch.totalRemaining) then toSpawn = batch.totalRemaining end
	
	for i = 1, toSpawn do
		local idx = SimThatThanh:spawnOneNpc(mapid, batch.bang, "center_attacker",
			batch.pillarTX, batch.pillarTY)
		if (idx and idx > 0) then
			-- Track in m_MapNpcs (giong defender)
			if (not SimThatThanh.m_MapNpcs[mapid]) then SimThatThanh.m_MapNpcs[mapid] = {} end
			tinsert(SimThatThanh.m_MapNpcs[mapid], {
				npcIdx = idx, bangIdx = batch.bang.index, role = "center_attacker",
				pillarTX = batch.pillarTX, pillarTY = batch.pillarTY,
				isInvader = 0,
			})
		end
	end
	batch.totalRemaining = batch.totalRemaining - toSpawn
	
	if (batch.totalRemaining <= 0) then
		SimThatThanh.m_BatchPending[mapid] = nil
	else
		TimerList:AddTimer(TTDCBatchSpawnHandler, 9, mapid)
	end
	return 0
end

-- ====== WATCHDOGS ======
function SimThatThanh:KindCampWatchdog()
	if (self.m_IsRunning == 0) then return end
	-- Cross-env safety: timer env co the KHONG thay global SimCitizen/SimFight.
	-- Doc cached ref (set tu StartAll). Fallback ve global neu cache rong.
	local _SimCitizen = self.m_RefSimCitizen or SimCitizen
	local _SimFight = self.m_RefSimFight or SimFight
	local _BattleWorld = self.m_RefBattleWorld or BattleWorld
	local totalFixed = 0
	local totalChecked = 0
	local botC = self:getBotCurCamp()
	-- (m_MapNpcs loop cu da bo: dung idx tu m_MapNpcs entry co the la idx
	-- recycled (bot da chet, idx reused cho NPC khac vd sim keoxe) -> watchdog
	-- set state nham NPC khac. Comprehensive fighter sweep ben duoi co
	-- PARAM_LIST_ID guard nen tranh van de nay, va cover toan bo SimCitizen-
	-- spawned bots. AddNpc fallback bots (hiem) duoc SetTmpCamp anti-sticky
	-- hook bao ve.)
	-- ENFORCE pillar engine state - safety net cho captured pillars.
	-- CurCamp = engine 1-3 visual. TmpCamp = field.m_Monster.m_Camp (registered tong).
	local pillarsFixed = 0
	local botCamp = self:getBotCurCamp()
	local playerCamp = self.m_RegisteredPlayerCamp or 0
	for i = 1, getn(FIELD_LIST) do
		local mapid = FIELD_LIST[i]
		local field = (_BattleWorld and _BattleWorld.FindField
		              and _BattleWorld:FindField(mapid))
		if (field and field.m_Monster and field.m_Monster.m_NpcIndex
		    and field.m_Monster.m_NpcIndex > 0) then
			local pidx = field.m_Monster.m_NpcIndex
			if (IsNpcExist == nil or IsNpcExist(pidx) ~= 0) then
				-- CurCamp visual: captured -> player camp; uncaptured -> botCamp.
				local targetCur = botCamp
				if (self.m_MapCaptured[mapid] == 1 and playerCamp > 0) then
					targetCur = playerCamp
				end
				-- TmpCamp = field.m_Monster.m_Camp (registered tong owner).
				local targetTmp = (field.m_Monster.m_Camp and field.m_Monster.m_Camp > 0)
				                  and field.m_Monster.m_Camp or targetCur
				if (SetNpcCurCamp) then SetNpcCurCamp(pidx, targetCur) end
				if (SetTmpCamp) then SetTmpCamp(targetTmp, pidx) end
				pillarsFixed = pillarsFixed + 1
			end
		end
	end
	
	-- COMPREHENSIVE FIGHTER SWEEP: thay vi orphan scanner cu (chi check registry),
	-- LUON enforce engine state cho moi TTDC fighter. Ly do:
	-- - SimMovement.Citizen co the reset CurCamp=6 TmpCamp=0 khi bot r?i fight
	--   -> registry van dung nhung engine state stale -> player ko danh duoc.
	-- - Sweep moi tick (~0.22s) tu fighterList -> bao phu ca bot recycled idx.
	-- GUARD: PARAM_LIST_ID check tranh sweep nham NPC khac sau idx recycling
	-- (vd: defender bot chet, fighter.finalIndex stale, idx duoc reuse cho keoxe).
	local orphansFixed = 0
	local stateFixed = 0
	local skippedRecycled = 0
	if (_SimCitizen and _SimCitizen.fighterList
	    and _SimFight and _SimFight.Citizen
	    and _SimFight.Citizen.m_TTDCRegistry) then
		for listId, fighter in _SimCitizen.fighterList do
			if (fighter and fighter.isTTDCBot == 1 and fighter.bangIdx
			    and fighter.finalIndex and fighter.finalIndex > 0
			    and fighter.isDead ~= 1
			    and (IsNpcExist == nil or IsNpcExist(fighter.finalIndex) ~= 0)) then
				-- GUARD: verify finalIndex VAN POINT toi DUNG fighter nay
				-- (tranh idx recycled cho NPC khac vd sim keoxe).
				local idValid = 1
				if (GetNpcParam and PARAM_LIST_ID) then
					local actualListId = GetNpcParam(fighter.finalIndex, PARAM_LIST_ID) or 0
					-- fighter.id la listId trong SimCitizen.fighterList.
					-- Co the la fighter.id hoac chinh listId tu for-loop.
					local expectedId = fighter.id or listId
					if (actualListId ~= expectedId) then
						idValid = 0
						skippedRecycled = skippedRecycled + 1
						-- Mark dead de OnBotDeath cleanup sau (tranh re-iterate)
						fighter.isDead = 1
					end
				end
				if (idValid == 1) then
					local bang = self.m_FakeBangs[fighter.bangIdx]
					if (bang) then
						-- 1) Register if missing/wrong
						if (_SimFight.Citizen.m_TTDCRegistry[fighter.finalIndex] ~= fighter.bangIdx) then
							_SimFight.Citizen.m_TTDCRegistry[fighter.finalIndex] = fighter.bangIdx
							self.m_NpcIdx2BangIdx[fighter.finalIndex] = fighter.bangIdx
							if (SetNpcDeathScript and SCRIPT_SIMTDC_DEATH) then
								SetNpcDeathScript(fighter.finalIndex, SCRIPT_SIMTDC_DEATH)
							end
							orphansFixed = orphansFixed + 1
						end
						-- 2) ALWAYS check engine state - fix if drifted (cur=6/tmp=0 cycle)
						if (GetTmpCamp and SetTmpCamp) then
							if (GetTmpCamp(fighter.finalIndex) ~= bang.camp) then
								SetTmpCamp(bang.camp, fighter.finalIndex)
								stateFixed = stateFixed + 1
							end
						end
						if (GetNpcCurCamp and SetNpcCurCamp) then
							if (GetNpcCurCamp(fighter.finalIndex) ~= botC) then
								SetNpcCurCamp(fighter.finalIndex, botC)
							end
						end
						if (GetNpcKind and SetNpcKind) then
							if (GetNpcKind(fighter.finalIndex) ~= 0) then
								SetNpcKind(fighter.finalIndex, 0)
							end
						end
						-- 3) AI luon = 1 (cheap call, idempotent)
						if (SetNpcAI) then SetNpcAI(fighter.finalIndex, 1) end
					end
				end
			end
		end
	end
	
	-- BATCH RESPAWN: check moi ~5s (23 ticks * 0.22s) - responsive hon nhieu so 60s cu.
	-- Cooldown per-map dung GetCurrentTime() (BATCH_COOLDOWN_SEC trong CFG = giay thuc).
	self.m_KCWBatchCounter = (self.m_KCWBatchCounter or 0) + 1
	if (self.m_KCWBatchCounter >= 23) then
		self.m_KCWBatchCounter = 0
		self:checkBatchRespawn()
	end
	
	self.m_KCWCounter = (self.m_KCWCounter or 0) + 1
	if (self.m_KCWCounter >= 270) then  -- ~60s log interval
		self.m_KCWCounter = 0
		self:log(format("KindCampWatchdog: pillars=%d orphans=%d state=%d recycled-skipped=%d",
			pillarsFixed, orphansFixed, stateFixed, skippedRecycled))
	end
end

TTDCKindCampHandler = TTDCKindCampHandler or {}
function TTDCKindCampHandler:OnTime()
	-- Cross-env safety: timer env co the khong thay global SimThatThanh.
	-- Dung cached ref tren table (set tu StartAll).
	local stt = TTDCKindCampHandler.m_TTDCSimThatThanh or SimThatThanh
	if (stt and stt.m_IsRunning == 1) then
		-- Tang tick counter de SimTDC_WatchdogStatus check
		stt.m_WatchdogTickCount = (stt.m_WatchdogTickCount or 0) + 1
		stt:KindCampWatchdog()
		if (TimerList and TimerList.AddTimer) then
			-- 4 frames = ~0.22s. Anti sticky-camp reactive backup (hook block la primary).
			TimerList:AddTimer(TTDCKindCampHandler, 4, 0)
		end
	end
	return 0
end

function SimThatThanh:PlayerLocationWatchdog()
	if (self.m_IsRunning == 0) then return end
	-- Flow A: KHONG spawn invader bang khac. Defender bang goc giu lai
	-- danh player (khong despawn khi captured). Bot-kill detection xu ly trong PollCaptures.
	self:PollCaptures()
	if (SetNpcBang and self.m_BangByIdx and self.m_MapNpcs) then
		for bk, bl in self.m_MapNpcs do
			for bi = 1, getn(bl) do
				local be = bl[bi]
				if (be and be.npcIdx and be.npcIdx > 0 and self.m_BangByIdx[be.npcIdx] and (IsNpcExist == nil or IsNpcExist(be.npcIdx) ~= 0)) then
					SetNpcBang(be.npcIdx, self.m_BangByIdx[be.npcIdx])
				end
			end
		end
	end
end

TTDCPlayerLocHandler = TTDCPlayerLocHandler or {}
function TTDCPlayerLocHandler:OnTime()
	-- Cross-env safety
	local stt = TTDCPlayerLocHandler.m_TTDCSimThatThanh or SimThatThanh
	if (stt and stt.m_IsRunning == 1) then
		stt:PlayerLocationWatchdog()
		if (TimerList and TimerList.AddTimer) then
			local interval = stt.CFG.PLAYER_LOCATION_INTERVAL or 3
			TimerList:AddTimer(TTDCPlayerLocHandler, interval * 18, 0)
		end
	end
	return 0
end

-- ====== WAR AUTO-CLOSE FALLBACK ======
-- Khi GM trigger war thu cong (ngoai lich s3relay), khong co scheduler
-- tu dong dong war sau WAR_TIME. Handler nay poll moi 30s, khi
-- elapsed >= WAR_TIME -> goi Protocol:Close tren relay (full flow voi awards).
-- Lua 4.x: timer env khong thay globals -> dung CACHED REFS tu stt.
TTDCWarCloseHandler = TTDCWarCloseHandler or {}
function TTDCWarCloseHandler:OnTime()
	local stt = TTDCWarCloseHandler.m_TTDCSimThatThanh or SimThatThanh
	-- Lay refs tu cache (set trong StartAll). Fallback ve global neu cache nil.
	local bw = (stt and stt.m_RefBattleWorld) or BattleWorld
	local wt = (stt and stt.m_RefWarTime) or WAR_TIME
	local ssw = (stt and stt.m_RefStateStartWar) or STATE_STARTWAR
	local glt = (stt and stt.m_RefGetLocalTime) or GetLocalTime
	local re = (stt and stt.m_RefRemoteExecute) or RemoteExecute
	local rs = (stt and stt.m_RefRemoteScript) or REMOTE_SCRIPT
	local tl = (stt and stt.m_RefTimerList) or TimerList
	
	if (stt and bw and wt and ssw and glt) then
		-- Reset flag khi war moi (m_StartTime doi)
		if (bw.m_StartTime ~= stt.m_FallbackLastStartTime) then
			stt.m_FallbackFired = 0
			stt.m_FallbackLastStartTime = bw.m_StartTime
		end
		if (bw.m_State == ssw
		    and bw.m_StartTime
		    and bw.m_StartTime > 0
		    and stt.m_FallbackFired ~= 1) then
			local elapsed = glt() - bw.m_StartTime
			if (elapsed >= wt) then
				stt:log(format("[FALLBACK] WAR_TIME (%ds) elapsed (%ds), close via Protocol:Close",
					wt, elapsed))
				stt.m_FallbackFired = 1
				if (re and rs) then
					re(rs, "Protocol:Close", 0)
					stt:log("Sent Protocol:Close to relay")
				else
					stt:log("[WARN] RemoteExecute unavailable, fallback to local close")
					if (RelayProtocol and RelayProtocol.Close) then
						RelayProtocol:Close(0, 0)
					end
				end
			end
		end
	else
		if (stt) then
			stt:log(format("[FALLBACK SKIP] missing refs: bw=%s wt=%s ssw=%s glt=%s",
				tostring(bw and "ok" or "nil"),
				tostring(wt and "ok" or "nil"),
				tostring(ssw and "ok" or "nil"),
				tostring(glt and "ok" or "nil")))
		end
	end
	-- Reschedule moi 30s
	if (tl and tl.AddTimer) then
		tl:AddTimer(TTDCWarCloseHandler, 30 * 18, 0)
	end
	return 0
end

-- ====== WORLDINFO BUILDER ======
function SimThatThanh:buildWorldInfo(mapid)
	local info = MAP_INFO[mapid]
	if (not info or not info.MonsterPos) then return nil end
	
	local pillarTX = floor(info.MonsterPos[1] / 32)
	local pillarTY = floor(info.MonsterPos[2] / 32)
	local R = self.CFG.RING_RADIUS
	
	local wi = {
		worldId = mapid,
		name = info.CityName or "TTDC",
		showName = 1, allowFighting = 1, allowChat = 0,
		showFightingArea = 0, showingId = 0, showThangCap = 0, isTongKim = 0,
		playerTracker = {}, playerTrackerCount = 0,
		nodes = {}, presetPaths = {}, restrictedSpawns = {},
		-- walkAreas: SimCity dung khi walkMode="random" - bot pick 1 area random
		walkAreas = {},
	}
	
	wi.nodes["center"] = {
		x = pillarTX, y = pillarTY,
		linkedNodes = {}, nodeType = 1, isNearAtraction = 0,
	}
	
	local ringDirs = {
		{1,0,"e"},{-1,0,"w"},{0,1,"s"},{0,-1,"n"},
		{1,1,"se"},{-1,1,"sw"},{1,-1,"ne"},{-1,-1,"nw"},
	}
	for i = 1, 8 do
		local key = "r_" .. ringDirs[i][3]
		wi.nodes[key] = {
			x = pillarTX + ringDirs[i][1] * R,
			y = pillarTY + ringDirs[i][2] * R,
			linkedNodes = {"center"},
			nodeType = 1, isNearAtraction = 0,
		}
		tinsert(wi.nodes["center"].linkedNodes, key)
		wi.presetPaths["atk_" .. ringDirs[i][3]] = {key, "center"}
	end
	
	local D = self.CFG.GATE_DISTANCE or 30
	local Po = self.CFG.GATE_PATROL_OFFSET or 8
	
	for i = 1, 8 do
		local outerKey = "outer_" .. ringDirs[i][3]
		local ringKey  = "r_" .. ringDirs[i][3]
		wi.nodes[outerKey] = {
			x = pillarTX + ringDirs[i][1] * D,
			y = pillarTY + ringDirs[i][2] * D,
			linkedNodes = {ringKey, "center"},
			nodeType = 1, isNearAtraction = 0,
		}
		tinsert(wi.nodes[ringKey].linkedNodes, outerKey)
		wi.presetPaths["march8_" .. ringDirs[i][3]] = {outerKey, ringKey, "center"}
	end
	
	local wallDirs = {
		{"N", -D, -D,  Po, -Po, -Po,  Po},
		{"S",  D,  D,  Po, -Po, -Po,  Po},
		{"E",  D, -D,  Po,  Po, -Po, -Po},
		{"W", -D,  D,  Po,  Po, -Po, -Po},
	}
	local ringOfWall = { N="nw", S="se", E="ne", W="sw" }
	for i = 1, 4 do
		local dir = wallDirs[i][1]
		local wx  = pillarTX + wallDirs[i][2]
		local wy  = pillarTY + wallDirs[i][3]
		local main = "wall_" .. dir
		local patA = "wall_" .. dir .. "_a"
		local patB = "wall_" .. dir .. "_b"
		wi.nodes[main] = {
			x = wx, y = wy,
			linkedNodes = {"center", patA, patB},
			nodeType = 1, isNearAtraction = 0,
		}
		wi.nodes[patA] = {
			x = wx + wallDirs[i][4], y = wy + wallDirs[i][5],
			linkedNodes = {main}, nodeType = 1, isNearAtraction = 0,
		}
		wi.nodes[patB] = {
			x = wx + wallDirs[i][6], y = wy + wallDirs[i][7],
			linkedNodes = {main}, nodeType = 1, isNearAtraction = 0,
		}
		tinsert(wi.nodes["center"].linkedNodes, main)
		wi.presetPaths["hold_" .. dir] = {patA, main, patB, main}
		local ringKey = "r_" .. ringOfWall[dir]
		wi.presetPaths["march_" .. dir] = {main, ringKey, "center"}
	end
	
	-- PILLAR TANK paths: 4 nodes ngay sat tru (4 huong N/S/E/W).
	-- Bot tank dung tai vi tri va patrol qua lai ban kinh 2-3 tile.
	local tankDirs = {
		{"N", 0, -3,  0, -5},
		{"S", 0,  3,  0,  5},
		{"E",  3, 0,   5, 0},
		{"W", -3, 0,  -5, 0},
	}
	for i = 1, getn(tankDirs) do
		local dir = tankDirs[i][1]
		local nodeKey = "tank_" .. dir
		local patKey = "tank_" .. dir .. "_p"
		wi.nodes[nodeKey] = {
			x = pillarTX + tankDirs[i][2],
			y = pillarTY + tankDirs[i][3],
			linkedNodes = {"center", patKey},
			nodeType = 1, isNearAtraction = 0,
		}
		wi.nodes[patKey] = {
			x = pillarTX + tankDirs[i][4],
			y = pillarTY + tankDirs[i][5],
			linkedNodes = {nodeKey},
			nodeType = 1, isNearAtraction = 0,
		}
		wi.presetPaths["tank_" .. dir] = {nodeKey, patKey, nodeKey}
	end
	
	-- BUILD walkAreas cho walkMode="random" (style ThanhThi)
	local scale = self.CFG.WANDER_SCALE or 1.0
	local R1 = floor(R * 1.2 * scale)
	local R2 = floor(R * 1.8 * scale)
	local innerOff = floor(8 * scale)
	local outerOff = floor(14 * scale)
	
	-- INNER ring: 4 area quanh tru
	local areaCfgs = {
		{ pillarTX,             pillarTY,             R1 },
		{ pillarTX + innerOff,  pillarTY + innerOff,  R1 },
		{ pillarTX - innerOff,  pillarTY - innerOff,  R1 },
		{ pillarTX + innerOff,  pillarTY - innerOff,  R1 },
	}
	
	-- OUTER ring (optional): 4 area xa tru hon
	if (self.CFG.WANDER_OUTER_RING == 1) then
		tinsert(areaCfgs, { pillarTX + outerOff,  pillarTY,             R2 })
		tinsert(areaCfgs, { pillarTX - outerOff,  pillarTY,             R2 })
		tinsert(areaCfgs, { pillarTX,             pillarTY + outerOff,  R2 })
		tinsert(areaCfgs, { pillarTX,             pillarTY - outerOff,  R2 })
	end
	
	-- Build area tu moi cfg (coord pair format).
	for i = 1, getn(areaCfgs) do
		local cfg = areaCfgs[i]
		local cx = cfg[1]
		local cy = cfg[2]
		local spread = cfg[3]
		local area = {}
		tinsert(area, { cx + spread, cy          })
		tinsert(area, { cx,          cy + spread })
		tinsert(area, { cx - spread, cy          })
		tinsert(area, { cx,          cy - spread })
		tinsert(wi.walkAreas, area)
	end
	
	return wi
end

function SimThatThanh:ensureWorldInfo(mapid)
	self:patchSimCityWorld()
	if (not SimCityWorld or not SimCityWorld.m_TTDCInjected) then return 0 end
	if (SimCityWorld.m_TTDCInjected[mapid]) then return 1 end
	local wi = self:buildWorldInfo(mapid)
	if (not wi) then return 0 end
	SimCityWorld.m_TTDCInjected[mapid] = wi
	self:log(format("Injected worldInfo for map %d", mapid))
	return 1
end

-- ====== SETUP BANGS ======
function SimThatThanh:SetupFakeBangs()
	self.m_FakeBangs = {}
	self.m_FakeCamps = {}
	local prefix = self.CFG.BANG_INTERNAL_PREFIX or "@SIMBOT@"
	for i = 1, getn(self.CFG.BANG_NAMES) do
		local displayName = self.CFG.BANG_NAMES[i]
		local internalName = prefix .. displayName
		local camp = BattleWorld:RegisterCamp(internalName)
		
		local realTong = nil
		if (self.CFG.BANG_REAL_TONGS and self.CFG.BANG_REAL_TONGS[i]) then
			realTong = self.CFG.BANG_REAL_TONGS[i]
		else
			if (strsub(displayName, 1, 5) == "Bang ") then
				realTong = strsub(displayName, 6)
			else
				realTong = displayName
			end
		end
		
		if (BattleWorld.m_SignupList) then
			BattleWorld.m_SignupList[internalName] = 1
		end
		tinsert(self.m_FakeBangs, {
			name = displayName,
			realTong = realTong,
			internalName = internalName,
			camp = camp,
			index = i,
		})
		self.m_FakeCamps[camp] = 1
		self:log(format("Fake bang '%s' (real tong '%s') => camp %d",
			displayName, realTong, camp))
	end
end

-- Q2: SHUFFLE - Random gan 7 bang vao 7 map moi lan StartAll
-- Ket qua: m_MapDefenderBangIdx[mapid] = bangIdx
function SimThatThanh:assignBangsToMaps()
	self.m_MapDefenderBangIdx = {}
	local nBangs = getn(self.m_FakeBangs)
	local nMaps  = getn(FIELD_LIST)
	
	if (self.CFG.BANG_RANDOM_SHUFFLE ~= 1) then
		-- Fix thu tu: map i -> bang i
		for i = 1, nMaps do
			self.m_MapDefenderBangIdx[FIELD_LIST[i]] = mod(i - 1, nBangs) + 1
		end
		self:log("Bang assignment: FIXED (no shuffle)")
		return
	end
	
	-- Fisher-Yates shuffle: pick random bang cho tung map, remove tu pool
	local pool = {}
	for i = 1, nBangs do tinsert(pool, i) end
	local poolSize = nBangs
	
	for i = 1, nMaps do
		if (poolSize <= 0) then
			-- Refill pool neu het (case: more maps than bangs)
			for j = 1, nBangs do tinsert(pool, j) end
			poolSize = nBangs
		end
		local pick = random(1, poolSize)
		local bangIdx = pool[pick]
		self.m_MapDefenderBangIdx[FIELD_LIST[i]] = bangIdx
		-- Remove picked tu pool (swap voi last, decrement size)
		pool[pick] = pool[poolSize]
		pool[poolSize] = nil
		poolSize = poolSize - 1
	end
	
	self:log("=== RANDOM BANG ASSIGNMENT (shuffled) ===")
	for i = 1, nMaps do
		local mapid = FIELD_LIST[i]
		local bang = self.m_FakeBangs[self.m_MapDefenderBangIdx[mapid]]
		local info = MAP_INFO[mapid]
		self:log(format("  Map %d (%s) -> %s",
			mapid, (info and info.CityName) or "?", (bang and bang.name) or "?"))
	end
end

function SimThatThanh:pickInvaderBangIdx(mapid)
	if (self.m_MapAttackerBangIdx[mapid]) then
		return self.m_MapAttackerBangIdx[mapid]
	end
	-- Tranh dung current defender (sau shuffle)
	local defenderBangIdx = self.m_MapDefenderBangIdx[mapid] or self:mapIdOfIndex(mapid)
	local nBangs = getn(self.m_FakeBangs)
	local attackerBangIdx
	local attempts = 0
	repeat
		attackerBangIdx = random(1, nBangs)
		attempts = attempts + 1
	until (attackerBangIdx ~= defenderBangIdx or attempts > 20)
	self.m_MapAttackerBangIdx[mapid] = attackerBangIdx
	return attackerBangIdx
end

function SimThatThanh:pickPath(role)
	if (role == "gate_guard") then
		local dirs = {"N","S","E","W"}
		return "hold_" .. dirs[random(1, 4)]
	elseif (role == "invader_march") then
		local dirs = {"e","w","n","s","ne","nw","se","sw"}
		return "march8_" .. dirs[random(1, 8)]
	end
	local atks = {"atk_e","atk_w","atk_n","atk_s","atk_se","atk_sw","atk_ne","atk_nw"}
	return atks[random(1, getn(atks))]
end

-- ====== SPAWN FUNCTIONS ======
function SimThatThanh:spawnSimCitizen(mapid, bang, role)
	if (not SimCitizen or not SimCitizen.New) then
		self:log("spawnSimCitizen FAIL: SimCitizen not loaded"); return 0
	end
	if (self:ensureWorldInfo(mapid) == 0) then
		self:log(format("spawnSimCitizen FAIL map %d: ensureWorldInfo returned 0", mapid))
		return 0
	end
	
	-- Phan cap bang: bot 1 = Bang Chu, 2-6 = Truong Lao, 7-16 = Duong Chu, 17+ = De Tu
	local rankTitle = self:getBangRankTitle(mapid, bang.index)
	local displayName = format("%s-[%s]", bang.name, rankTitle)
	local botRealName = SimCityNPCInfo:generateName()
	
	-- Role-based walk behavior:
	local useRandom = 1
	local presetPath = nil
	if (role == "gate_guard") then
		useRandom = 0
		local dirs = {"N","S","E","W"}
		presetPath = "hold_" .. dirs[random(1, 4)]
	elseif (role == "pillar_tank") then
		useRandom = 0
		local dirs = {"N","S","E","W"}
		presetPath = "tank_" .. dirs[random(1, 4)]
	end
	
	local tbNpc = {
		mode = "chiendau",
		szName = botRealName,
		nNpcId = self:randomNpcId(),
		nMapId = mapid,
		camp = bang.camp,
		noStop = 1,
		leaveFightWhenNoEnemy = 5,
		noRevive = 1,
		resetPosWhenRevive = 1,
		isTTDCBot = 1,
		bangIdx = bang.index,
		CHANCE_ATTACK_PLAYER = 1,
		CHANCE_ATTACK_NPC = 1,
		CHANCE_JOIN_FIGHT = 1,
		RADIUS_FIGHT_PLAYER = self.CFG.AGGRO_RADIUS_PLAYER or 15,
		RADIUS_FIGHT_NPC    = self.CFG.AGGRO_RADIUS_NPC or 15,
		RADIUS_FIGHT_SCAN   = self.CFG.AGGRO_RADIUS_SCAN or 25,
		kind = 0,
		level = self.CFG.NPC_LEVEL,
		capHP = 2,
		rank = 1,
		TIME_FIGHTING_minTs = 6000,
		TIME_FIGHTING_maxTs = 6000,
		TIME_RESTING_minTs = 0,
		TIME_RESTING_maxTs = 1,
		ngoaitrang = 1,
		hardsetName = botRealName,
		bangDisp = displayName,
	}
	
	-- ROLE-SPECIFIC ADJUSTMENTS:
	if (role == "pillar_tank") then
		-- Tank: HP cao gap doi, aggro range to (chong player rush tru)
		tbNpc.capHP = 3
		tbNpc.RADIUS_FIGHT_PLAYER = 30
		tbNpc.RADIUS_FIGHT_NPC    = 30
		tbNpc.RADIUS_FIGHT_SCAN   = 50
	end
	
	if (useRandom == 1) then
		tbNpc.walkMode = "random"
		tbNpc.walkVar = self.CFG.BOT_WALK_VAR or 2
		-- walkPathNames khong set - SimCity auto-pick tu walkAreas (4 vung trong thanh)
	else
		tbNpc.walkMode = "preset"
		tbNpc.walkVar = 1
		tbNpc.walkPathNames = { { presetPath, 1 } }
	end
	
	local nListId = SimCitizen:New(tbNpc)
	if (not nListId) then
		self:log(format("spawnSimCitizen FAIL map %d bang %s", mapid, bang.name))
		return 0
	end
	
	local fighter = SimCitizen.fighterList[nListId]
	if (not fighter or not fighter.finalIndex) then
		self:log(format("spawnSimCitizen FAIL map %d: fighter missing", mapid))
		return 0
	end
	
	-- CurCamp = engine combat camp 1-3 (visual + AI).
	-- TmpCamp = bang.camp registered tong (5+) -> matrix(player_tong, bang_camp) hostile.
	local botC = self:getBotCurCamp()
	SetTmpCamp(bang.camp, fighter.finalIndex)
	if (SetNpcCurCamp) then SetNpcCurCamp(fighter.finalIndex, botC) end
	SetNpcDeathScript(fighter.finalIndex, SCRIPT_SIMTDC_DEATH)
	SetNpcAI(fighter.finalIndex, 1)
	-- FORCE kind=0 (quai mode). SimCity co the spawn voi kind=1 (NPC mode)
	-- cho mot so vai tro -> bot khong attackable. Force lai kind=0 ngay sau spawn.
	if (SetNpcKind) then SetNpcKind(fighter.finalIndex, 0) end
	self.m_NpcIdx2BangIdx[fighter.finalIndex] = bang.index
	SimFight.Citizen.m_TTDCRegistry[fighter.finalIndex] = bang.index
	return fighter.finalIndex
end

function SimThatThanh:spawnAddNpc(mapid, bang, role, pillarTX, pillarTY)
	local world = SubWorldID2Idx(mapid)
	if (world < 0) then return 0 end
	
	-- Distribute bot spawn voi WANDER_SCALE.
	-- Co hoi spawn near (50%) hoac far (50%) -> bot rai rac inner + outer ring.
	local scale = self.CFG.WANDER_SCALE or 1.0
	local baseMin = self.CFG.ATTACKER_MIN_DIST or 18
	local baseMax = self.CFG.ATTACKER_MAX_DIST or 22
	local nearDist = random(baseMin, baseMax)
	local farDist  = floor(random(baseMin, baseMax) * 2.5 * scale)
	local dist = nearDist
	if (random(1, 100) <= 50) then
		dist = farDist
	end
	
	-- Random direction 0-360 degree thay vi 4 cardinals -> distribution mac
	local angle = random(0, 359)
	local radX = floor(dist * (mathcos and mathcos(angle * 3.14159 / 180) or 0))
	local radY = floor(dist * (mathsin and mathsin(angle * 3.14159 / 180) or 0))
	if (radX == 0 and radY == 0) then
		-- Fallback 4 cardinals neu math khong co
		local dir = mod(random(1, 99999), 4)
		if (dir == 0) then radX, radY = dist, random(-6, 6)
		elseif (dir == 1) then radX, radY = -dist, random(-6, 6)
		elseif (dir == 2) then radX, radY = random(-6, 6), dist
		else radX, radY = random(-6, 6), -dist end
	end
	local tileX = pillarTX + radX
	local tileY = pillarTY + radY
	
	-- Phan cap bang giong spawnSimCitizen
	local rankTitle = self:getBangRankTitle(mapid, bang.index)
	local displayName = format("%s-[%s]", bang.name, rankTitle)
	local botRealName = SimCityNPCInfo:generateName()
	-- kind = 0 (quai mode) de match SimCity bot config + co the bi attack
	local idx = AddNpc(self:randomNpcId(), 0, world, tileX * 32, tileY * 32, 1, botRealName)
	if (idx <= 0) then return 0 end
	
	-- CurCamp = engine 1-3 visual. TmpCamp = bang.camp (registered) cho damage check.
	local botC2 = self:getBotCurCamp()
	SetTmpCamp(bang.camp, idx)
	if (SetNpcCurCamp) then SetNpcCurCamp(idx, botC2) end
	SyncNpc(idx)
	if (SetNpcBang) then SetNpcBang(idx, displayName); if (self.m_BangByIdx) then self.m_BangByIdx[idx] = displayName end end
	SetNpcDeathScript(idx, SCRIPT_SIMTDC_DEATH)
	SetNpcAI(idx, 1)
	if (SetNpcKind) then SetNpcKind(idx, 0) end
	self.m_NpcIdx2BangIdx[idx] = bang.index
	SimFight.Citizen.m_TTDCRegistry[idx] = bang.index
	return idx
end

function SimThatThanh:spawnOneNpc(mapid, bang, role, pillarTX, pillarTY)
	if (self.CFG.USE_SIMCITIZEN == 1) then
		local idx = self:spawnSimCitizen(mapid, bang, role)
		if (idx > 0) then
			self.m_LastSpawnMethod = "simcitizen"
			return idx
		end
		self:log(format("FALLBACK to AddNpc: map %d bang %s", mapid, bang.name))
	end
	local idx = self:spawnAddNpc(mapid, bang, role, pillarTX, pillarTY)
	if (idx > 0) then self.m_LastSpawnMethod = "addnpc" end
	return idx
end

-- ====== SPAWN DEFENDERS ======
-- Q1 helper: spawn voi bang cu the (dung tu Monster:Down hook sau takeover)
function SimThatThanh:spawnMapWithBang(mapid, bang)
	local info = MAP_INFO[mapid]
	if (not info or not info.MonsterPos) then
		self:log(format("ERROR: MAP_INFO[%d] missing", mapid)); return 0
	end
	local pTX = floor(info.MonsterPos[1] / 32)
	local pTY = floor(info.MonsterPos[2] / 32)
	
	if (not self.m_MapNpcs[mapid]) then self.m_MapNpcs[mapid] = {} end
	local list = self.m_MapNpcs[mapid]
	
	if (not bang) then
		self:log(format("ERROR: spawnMapWithBang(%d) - bang nil", mapid)); return 0
	end
	
	local spawned = 0
	-- LAYER 1: Pillar tank (sat tru, HP cao, dung yen patrol nho)
	for i = 1, (self.CFG.PILLAR_TANK_PER_BANG or 0) do
		local idx = self:spawnOneNpc(mapid, bang, "pillar_tank", pTX, pTY)
		if (idx > 0) then
			tinsert(list, { npcIdx=idx, role="pillar_tank", bangIdx=bang.index,
			                pillarTX=pTX, pillarTY=pTY, isInvader=0 })
			spawned = spawned + 1
		end
	end
	-- LAYER 2: Center attacker (wander quanh tru)
	for i = 1, self.CFG.CENTER_BOTS_PER_BANG do
		local idx = self:spawnOneNpc(mapid, bang, "center_attacker", pTX, pTY)
		if (idx > 0) then
			tinsert(list, { npcIdx=idx, role="center_attacker", bangIdx=bang.index,
			                pillarTX=pTX, pillarTY=pTY, isInvader=0 })
			spawned = spawned + 1
		end
	end
	-- LAYER 3: Gate guard (canh 4 cong N/S/E/W)
	for i = 1, self.CFG.GATE_BOTS_PER_BANG do
		local idx = self:spawnOneNpc(mapid, bang, "gate_guard", pTX, pTY)
		if (idx > 0) then
			tinsert(list, { npcIdx=idx, role="gate_guard", bangIdx=bang.index,
			                pillarTX=pTX, pillarTY=pTY, isInvader=0 })
			spawned = spawned + 1
		end
	end
	
	self:log(format("Map %d (%s): spawned %d DEFENDERS [bang: %s]",
		mapid, info.CityName or "?", spawned, bang.name))
	return spawned
end

function SimThatThanh:spawnMap(mapid, mapIdx)
	-- Q2: lookup bang tu shuffled assignment thay vi index goc
	local bangIdx = self.m_MapDefenderBangIdx[mapid] or mapIdx
	local bang = self.m_FakeBangs[bangIdx]
	return self:spawnMapWithBang(mapid, bang)
end

function SimThatThanh:despawnDefendersForMap(mapid)
	local list = self.m_MapNpcs[mapid]
	if (not list) then return 0 end
	local cnt = 0
	for i = 1, getn(list) do
		local info = list[i]
		if (info.npcIdx and info.npcIdx > 0 and info.isInvader ~= 1) then
			self.m_NpcIdx2BangIdx[info.npcIdx] = nil
			if (SimFight and SimFight.Citizen and SimFight.Citizen.m_TTDCRegistry) then
				SimFight.Citizen.m_TTDCRegistry[info.npcIdx] = nil
			end
			if (SimCitizen and SimCitizen.fighterList) then
				for listId, fighter in SimCitizen.fighterList do
					if (fighter and fighter.finalIndex == info.npcIdx) then
						SimCitizen.fighterList[listId] = nil
						break
					end
				end
			end
			DelNpcSafe(info.npcIdx)
			cnt = cnt + 1
		end
	end
	self.m_MapNpcs[mapid] = nil
	return cnt
end

function SimThatThanh:spawnInvaderForMap(mapid)
	if (self.m_MapAttackerActive[mapid] == 1) then return 0 end
	if (self.m_MapCaptured[mapid] ~= 1) then return 0 end
	
	local info = MAP_INFO[mapid]
	if (not info or not info.MonsterPos) then return 0 end
	local pTX = floor(info.MonsterPos[1] / 32)
	local pTY = floor(info.MonsterPos[2] / 32)
	
	local attackerBangIdx = self:pickInvaderBangIdx(mapid)
	local bang = self.m_FakeBangs[attackerBangIdx]
	if (not bang) then
		self:log(format("spawnInvader FAIL: no bang for idx %d", attackerBangIdx))
		return 0
	end
	
	local field = BattleWorld:FindField(mapid)
	if (field and field.m_Monster and field.m_Monster.m_NpcIndex
	    and field.m_Monster.m_NpcIndex > 0) then
		SimFight.Citizen.m_TTDCPillarIdx[mapid] = field.m_Monster.m_NpcIndex
	end
	
	if (not self.m_MapNpcs[mapid]) then self.m_MapNpcs[mapid] = {} end
	local list = self.m_MapNpcs[mapid]
	
	local spawned = 0
	local gateBots = self.CFG.INVADER_GATE_BOTS or 40
	local ringBots = self.CFG.INVADER_RING_BOTS or 40
	
	for i = 1, gateBots do
		local idx = self:spawnOneNpc(mapid, bang, "invader_march", pTX, pTY)
		if (idx > 0) then
			tinsert(list, { npcIdx=idx, role="invader_march", bangIdx=bang.index,
			                pillarTX=pTX, pillarTY=pTY, isInvader=1 })
			spawned = spawned + 1
		end
	end
	for i = 1, ringBots do
		local idx = self:spawnOneNpc(mapid, bang, "center_attacker", pTX, pTY)
		if (idx > 0) then
			tinsert(list, { npcIdx=idx, role="center_attacker", bangIdx=bang.index,
			                pillarTX=pTX, pillarTY=pTY, isInvader=1 })
			spawned = spawned + 1
		end
	end
	
	self.m_MapAttackerActive[mapid] = 1
	self:log(format("Map %d: INVADER arrived - bang '%s', %d bots",
		mapid, bang.name, spawned))
	
	if (self.CFG.INVADER_ANNOUNCE == 1 and AddLocalNews) then
		AddLocalNews(format("Bang <color=red>%s<color> dang tien cong %s, hãy phong thu!",
			bang.name, info.CityName or "thanh"))
	end
	return spawned
end

function SimThatThanh:despawnInvaderForMap(mapid)
	if (self.m_MapAttackerActive[mapid] ~= 1) then return 0 end
	local list = self.m_MapNpcs[mapid]
	if (not list) then
		self.m_MapAttackerActive[mapid] = 0; return 0
	end
	local cnt = 0
	for i = 1, getn(list) do
		local info = list[i]
		if (info.npcIdx and info.npcIdx > 0 and info.isInvader == 1) then
			self.m_NpcIdx2BangIdx[info.npcIdx] = nil
			if (SimFight and SimFight.Citizen and SimFight.Citizen.m_TTDCRegistry) then
				SimFight.Citizen.m_TTDCRegistry[info.npcIdx] = nil
			end
			if (SimCitizen and SimCitizen.fighterList) then
				for listId, fighter in SimCitizen.fighterList do
					if (fighter and fighter.finalIndex == info.npcIdx) then
						SimCitizen.fighterList[listId] = nil
						break
					end
				end
			end
			DelNpcSafe(info.npcIdx)
			cnt = cnt + 1
		end
	end
	self.m_MapNpcs[mapid] = nil
	self.m_MapAttackerActive[mapid] = 0
	self:log(format("Map %d: INVADER despawned (%d bots)", mapid, cnt))
	return cnt
end

-- ====== ENTRY POINTS ======
function SimThatThanh:StartAll()
	self:log("StartAll() called")
	if (self.m_IsRunning == 1) then self:ClearAll() end
	
	self:patchFightSys()
	self:patchMonsterCreateNpc()
	self:patchSimFunChat()
	self:SetupFakeBangs()
	self:assignBangsToMaps()
	
	local nMaps  = getn(FIELD_LIST)
	local nBangs = getn(self.m_FakeBangs)
	if (nBangs < nMaps) then
		self:log(format("WARN: %d bang, %d map - %d map khong co defender!",
			nBangs, nMaps, nMaps - nBangs))
	end
	
	local total = 0
	for i = 1, nMaps do
		total = total + self:spawnMap(FIELD_LIST[i], i)
	end
	
	-- AUTO-CAPTURE: dung bang da shuffled
	-- Suppress BOT-KILL handling trong luc setup (DelNpc trigger OnDeath false-positive)
	self.m_SuppressBotKill = 1
	for i = 1, nMaps do
		local mapid = FIELD_LIST[i]
		local bangIdx = self.m_MapDefenderBangIdx[mapid] or i
		local bang = self.m_FakeBangs[bangIdx]
		local field = BattleWorld:FindField(mapid)
		if (field and field.m_Monster and bang) then
			field.m_Monster.m_Camp = bang.camp
			if (field.m_Monster.m_NpcIndex and field.m_Monster.m_NpcIndex > 0) then
				DelNpc(field.m_Monster.m_NpcIndex)
				field.m_Monster.m_NpcIndex = 0
			end
			local pillarName = "Long Trô [" .. bang.name .. "]"
			field.m_Monster:CreateNpc(pillarName)
			-- (Monster.CreateNpc hook auto-set engine CurCamp = botCurCamp + TmpCamp = bang.camp)
			-- Schedule TIMEOUT_MONSTER countdown -> Thu Long Tru sau 18p neu khong ai pha
			if (field.m_Monster.StartTimer) then field.m_Monster:StartTimer() end
			
			if (ObjBuffer and RemoteExecute and REMOTE_SCRIPT) then
				local syncName = bang.realTong or bang.name
				local buff = ObjBuffer:New()
				buff:Push(mapid)
				buff:Push(syncName)
				RemoteExecute(REMOTE_SCRIPT, "BattleWorld:SimTDCOccupy", buff.m_Handle)
				buff:Destroy()
			end
			
			self:log(format("Map %d auto-captured by '%s' (real tong '%s')",
				mapid, bang.name, bang.realTong or bang.name))
		end
	end
	
	-- Release suppress flag SAU auto-capture loop xong
	-- (neu khong, HandleBotKillPillar se luon early-return -> khong co takeover!)
	self.m_SuppressBotKill = 0
	
	self.m_IsRunning = 1
	self:log(format("StartAll DONE: %d bang, %d NPCs", nBangs, total))
	
	-- CACHE cross-env refs - timer env khong thay global SimCitizen/SimFight/...
	-- Watchdog dung self.m_RefSimCitizen / self.m_RefSimFight thay vi global.
	self.m_RefSimCitizen = SimCitizen
	self.m_RefSimFight = SimFight
	self.m_RefBattleWorld = BattleWorld
	-- Refs cho TTDCWarCloseHandler (cung Lua 4.x cross-env issue)
	self.m_RefWarTime = WAR_TIME
	self.m_RefStateStartWar = STATE_STARTWAR
	self.m_RefGetLocalTime = GetLocalTime
	self.m_RefRemoteExecute = RemoteExecute
	self.m_RefRemoteScript = REMOTE_SCRIPT
	self.m_RefTimerList = TimerList
	self.m_RefOutputMsg = OutputMsg
	self.m_RefWriteLog = WriteLog
	TTDCKindCampHandler.m_TTDCSimThatThanh = self
	TTDCPlayerLocHandler.m_TTDCSimThatThanh = self
	TTDCWarCloseHandler.m_TTDCSimThatThanh = self
	-- Reset fallback fire flag (cho war moi)
	self.m_FallbackFired = 0
	self.m_FallbackLastStartTime = nil
	self.m_WatchdogTickCount = 0
	
	if (TimerList and TimerList.AddTimer) then
		TimerList:AddTimer(TTDCKindCampHandler, 4, 0)  -- ~0.22s anti sticky-camp backup
		TimerList:AddTimer(TTDCPlayerLocHandler,
			(self.CFG.PLAYER_LOCATION_INTERVAL or 3) * 18, 0)
		-- WAR auto-close fallback (poll moi 30s, force close khi qua WAR_TIME)
		TimerList:AddTimer(TTDCWarCloseHandler, 30 * 18, 0)
		self:log("Timers started")
	end
	
	return total
end

function SimThatThanh:StartMap(mapid)
	if (not MAP_INFO[mapid]) then return 0 end
	if (getn(self.m_FakeBangs) == 0) then
		self:patchFightSys()
		self:patchMonsterCreateNpc()
		self:SetupFakeBangs()
		self:assignBangsToMaps()
	end
	self:ClearMap(mapid)
	local mapIdx = self:mapIdOfIndex(mapid)
	if (mapIdx == 0) then
		self:log(format("StartMap ERROR: map %d not in FIELD_LIST", mapid)); return 0
	end
	local spawned = self:spawnMap(mapid, mapIdx)
	self.m_MapCaptured[mapid] = nil
	self.m_MapAttackerActive[mapid] = 0
	self.m_IsRunning = 1
	return spawned
end

function SimThatThanh:ClearMap(mapid)
	local list = self.m_MapNpcs[mapid]
	if (not list) then return 0 end
	local cnt = 0
	for i = 1, getn(list) do
		local info = list[i]
		if (info.npcIdx and info.npcIdx > 0) then
			self.m_NpcIdx2BangIdx[info.npcIdx] = nil
			if (SimFight and SimFight.Citizen and SimFight.Citizen.m_TTDCRegistry) then
				SimFight.Citizen.m_TTDCRegistry[info.npcIdx] = nil
			end
			if (SimCitizen and SimCitizen.fighterList) then
				for listId, fighter in SimCitizen.fighterList do
					if (fighter and fighter.finalIndex == info.npcIdx) then
						SimCitizen.fighterList[listId] = nil
						break
					end
				end
			end
			DelNpcSafe(info.npcIdx)
			cnt = cnt + 1
		end
	end
	self.m_MapNpcs[mapid] = nil
	self.m_MapCaptured[mapid] = nil
	self.m_MapAttackerActive[mapid] = 0
	self:log(format("ClearMap %d: xoa %d NPC", mapid, cnt))
	return cnt
end

function SimThatThanh:ClearAll()
	self:log("ClearAll() called")
	-- Suppress bot-kill handling trong luc clean up (tru bi DelNpc tu nhien)
	self.m_SuppressBotKill = 1
	local total = 0
	for mapid, _ in self.m_MapNpcs do
		total = total + (self:ClearMap(mapid) or 0)
	end
	self.m_MapNpcs = {}
	self.m_FakeBangs = {}
	self.m_RespawnQueue = {}
	self.m_NpcIdx2BangIdx = {}
	self.m_MapCaptured = {}
	self.m_MapAttackerActive = {}
	self.m_MapAttackerBangIdx = {}
	self.m_MapDefenderBangIdx = {}
	self.m_LastBatchTime = {}
	self.m_BatchPending = {}
	self.m_BatchTickCounter = 0
	self.m_BangRankCounter = {}
	self.m_SimRankCounter = {}
	if (SimFight and SimFight.Citizen) then
		SimFight.Citizen.m_TTDCRegistry  = {}
		SimFight.Citizen.m_TTDCPillarIdx = {}
	end
	self.m_IsRunning = 0
	-- Release suppress (ClearAll het)
	self.m_SuppressBotKill = 0
	self:log(format("ClearAll DONE: xoa %d NPC", total))
	return total
end

-- ====== RESPAWN SYSTEM ======
function SimThatThanh:findBotInfo(npcIdx)
	for mapid, list in self.m_MapNpcs do
		for i = 1, getn(list) do
			if (list[i].npcIdx == npcIdx) then
				return list[i], mapid, i
			end
		end
	end
	return nil
end

function SimThatThanh:OnBotDeath(deadNpcIdx)
	if (self.m_IsRunning == 0) then return end
	local botInfo, mapid, index = self:findBotInfo(deadNpcIdx)
	if (not botInfo or not mapid) then
		self:log(format("OnBotDeath: npc(%d) not in registry", deadNpcIdx))
		return
	end
	-- DBG: log wave bot death
	if (botInfo.isWave == 1) then
	end
	self.m_NpcIdx2BangIdx[deadNpcIdx] = nil
	if (SimFight and SimFight.Citizen and SimFight.Citizen.m_TTDCRegistry) then
		SimFight.Citizen.m_TTDCRegistry[deadNpcIdx] = nil
	end
	tremove(self.m_MapNpcs[mapid], index)
	
	local isInvader = botInfo.isInvader or 0
	
	-- Flow A: defender RESPAWN luon (du map da captured) -> tiep tuc danh player
	-- Khong skip khi captured nua.
	if (isInvader == 1 and self.m_MapAttackerActive[mapid] ~= 1) then return end
	
	-- BATCH MODE: bot chet -> KHONG respawn le. Doi watchdog detect alive <= 70%
	if (self.CFG.BATCH_RESPAWN_ENABLED == 1 and isInvader ~= 1) then
		return
	end
	
	self.m_QueueCounter = self.m_QueueCounter + 1
	local qid = self.m_QueueCounter
	self.m_RespawnQueue[qid] = {
		bangIdx = botInfo.bangIdx, role = botInfo.role,
		mapid = mapid, pillarTX = botInfo.pillarTX, pillarTY = botInfo.pillarTY,
		isInvader = isInvader,
	}
	if (TimerList and TimerList.AddTimer) then
		local delay = random(self.CFG.RESPAWN_MIN_SEC, self.CFG.RESPAWN_MAX_SEC) * 18
		TimerList:AddTimer(TTDCRespawnHandler, delay, qid)
	end
end

TTDCRespawnHandler = TTDCRespawnHandler or {}
function TTDCRespawnHandler:OnTime(queueId)
	if (SimThatThanh.m_IsRunning == 0) then
		SimThatThanh.m_RespawnQueue[queueId] = nil; return 0
	end
	local info = SimThatThanh.m_RespawnQueue[queueId]
	SimThatThanh.m_RespawnQueue[queueId] = nil
	if (not info) then return 0 end
	
	local isInvader = info.isInvader or 0
	-- Flow A: defender respawn luon, khong skip khi captured
	if (isInvader == 1 and SimThatThanh.m_MapAttackerActive[info.mapid] ~= 1) then return 0 end
	
	local bang = SimThatThanh.m_FakeBangs[info.bangIdx]
	if (not bang) then return 0 end
	
	local idx = SimThatThanh:spawnOneNpc(info.mapid, bang, info.role, info.pillarTX, info.pillarTY)
	if (idx > 0) then
		if (not SimThatThanh.m_MapNpcs[info.mapid]) then
			SimThatThanh.m_MapNpcs[info.mapid] = {}
		end
		tinsert(SimThatThanh.m_MapNpcs[info.mapid], {
			npcIdx = idx, role = info.role, bangIdx = info.bangIdx,
			pillarTX = info.pillarTX, pillarTY = info.pillarTY,
			isInvader = isInvader,
		})
	end
	return 0
end

-- Patch SimFun.Update hooks to disable chat in TTDC maps.
function SimThatThanh:patchSimFunChat()
	-- Layer 1a: SimFun.KeoXe.Update
	if (SimFun and SimFun.KeoXe and SimFun.KeoXe.Update
	    and not SimFun.KeoXe.m_TTDCNoChatPatched) then
		SimFun.KeoXe.m_TTDCOriginalUpdate = SimFun.KeoXe.Update
		SimFun.KeoXe.m_TTDCFieldList = FIELD_LIST
		SimFun.KeoXe.Update = function(this, tbNpc)
			if (tbNpc.isDead == 1) then return end
			local isTTDCMap = 0
			local flist = SimFun.KeoXe.m_TTDCFieldList
			if (tbNpc.nMapId and flist) then
				for i = 1, getn(flist) do
					if (flist[i] == tbNpc.nMapId) then
						isTTDCMap = 1
						break
					end
				end
			end
			if (isTTDCMap == 1) then
				if (execRestoreLife) then execRestoreLife(tbNpc) end
			else
				SimFun.KeoXe.m_TTDCOriginalUpdate(this, tbNpc)
			end
		end
		SimFun.KeoXe.m_TTDCNoChatPatched = 1
		self:log(">>> SimFun.KeoXe.Update PATCHED <<<")
	else
		self:log("WARN: SimFun.KeoXe not available or already patched")
	end
	
	-- Layer 1b: SimFun.Citizen.Update
	if (SimFun and SimFun.Citizen and SimFun.Citizen.Update
	    and not SimFun.Citizen.m_TTDCNoChatPatched) then
		SimFun.Citizen.m_TTDCOriginalUpdate = SimFun.Citizen.Update
		SimFun.Citizen.m_TTDCFieldList = FIELD_LIST
		SimFun.Citizen.Update = function(this, tbNpc)
			if (tbNpc.isDead == 1) then return end
			local isTTDCMap = 0
			local flist = SimFun.Citizen.m_TTDCFieldList
			if (tbNpc.nMapId and flist) then
				for i = 1, getn(flist) do
					if (flist[i] == tbNpc.nMapId) then
						isTTDCMap = 1
						break
					end
				end
			end
			if (isTTDCMap == 1) then
				if (execRestoreLife) then execRestoreLife(tbNpc) end
			else
				SimFun.Citizen.m_TTDCOriginalUpdate(this, tbNpc)
			end
		end
		SimFun.Citizen.m_TTDCNoChatPatched = 1
		self:log(">>> SimFun.Citizen.Update PATCHED <<<")
	end
	
	-- Layer 2: Override global execChat function (fallback).
	if (execChat and not m_TTDCExecChatPatched) then
		m_TTDCOriginalExecChat = execChat
		m_TTDCExecChatFieldList = FIELD_LIST
		execChat = function(tbNpc, isKeoXe)
			local isTTDCMap = 0
			local flist = m_TTDCExecChatFieldList
			if (tbNpc and tbNpc.nMapId and flist) then
				for i = 1, getn(flist) do
					if (flist[i] == tbNpc.nMapId) then
						isTTDCMap = 1
						break
					end
				end
			end
			if (isTTDCMap == 1) then
				return
			end
			return m_TTDCOriginalExecChat(tbNpc, isKeoXe)
		end
		m_TTDCExecChatPatched = 1
		self:log(">>> global execChat PATCHED (fallback) <<<")
	else
		self:log("WARN: execChat not visible from this env (cannot patch fallback)")
	end
end

-- ====== HOOKS ======
function SimThatThanh:OnWarStart()
	self:log("OnWarStart hook fired")
	self:patchSimFunChat()
	self:StartAll()
end

function SimThatThanh:OnWarClose()
	self:log("OnWarClose hook fired")
	
	local prefix = self.CFG.BANG_INTERNAL_PREFIX or "@SIMBOT@"
	local prefixLen = strlen(prefix)
	
	for i = 1, getn(FIELD_LIST) do
		local mapid = FIELD_LIST[i]
		local field = BattleWorld:FindField(mapid)
		if (field and field.m_Monster) then
			local camp = field.m_Monster.m_Camp
			local tong = BattleWorld:FindCampTong(camp)
			
			if (tong and tong ~= "") then
				if (strsub(tong, 1, prefixLen) == prefix) then
					tong = strsub(tong, prefixLen + 1)
				end
				
				local buff = ObjBuffer:New()
				buff:Push(mapid)
				buff:Push(tong)
				buff:Push(1)
				RemoteExecute("\\script\\missions\\sevencity\\relay_protocol.lua",
					"RelayProtocol:SyncViceroy", buff.m_Handle)
				buff:Destroy()
				self:log(format("SyncViceroy sent: map=%d tong='%s'", mapid, tong))
			else
				local buff = ObjBuffer:New()
				buff:Push(mapid)
				buff:Push("")
				buff:Push(0)
				RemoteExecute("\\script\\missions\\sevencity\\relay_protocol.lua",
					"RelayProtocol:SyncViceroy", buff.m_Handle)
				buff:Destroy()
			end
		end
	end
	
	self:ClearAll()
end

-- ====== GM COMMANDS ======
-- DEBUG: kiem tra player co bi nham la bot khong (chay khi bug chat)
function SimTDC_StartAll() SimThatThanh:StartAll() end
function SimTDC_StartMap(mapid) SimThatThanh:StartMap(tonumber(mapid)) end
function SimTDC_ClearAll() SimThatThanh:ClearAll() end

-- Status fallback handler (kiem tra fallback co fire dung khong).
-- User trigger war qua CTC_BatDau() -> goi /Lua SimTDC_WarCloseStatus()
-- de check elapsed/refs. Fallback tu fire sau WAR_TIME (1800s).
-- Dung OutputMsg truc tiep (khong qua self:log) de luon hien thi du DEBUG_LOG=0.
function SimTDC_WarCloseStatus()
	local stt = SimThatThanh
	OutputMsg("=== WAR CLOSE FALLBACK STATUS ===")
	OutputMsg(format("Cached refs: bw=%s wt=%s ssw=%s glt=%s re=%s rs=%s tl=%s",
		tostring(stt.m_RefBattleWorld and "ok" or "NIL"),
		tostring(stt.m_RefWarTime and "ok" or "NIL"),
		tostring(stt.m_RefStateStartWar and "ok" or "NIL"),
		tostring(stt.m_RefGetLocalTime and "ok" or "NIL"),
		tostring(stt.m_RefRemoteExecute and "ok" or "NIL"),
		tostring(stt.m_RefRemoteScript and "ok" or "NIL"),
		tostring(stt.m_RefTimerList and "ok" or "NIL")))
	local bw = stt.m_RefBattleWorld or BattleWorld
	local wt = stt.m_RefWarTime or WAR_TIME
	local ssw = stt.m_RefStateStartWar or STATE_STARTWAR
	local glt = stt.m_RefGetLocalTime or GetLocalTime
	OutputMsg(format("BattleWorld.m_State = %s (STATE_STARTWAR=%s)",
		tostring(bw and bw.m_State), tostring(ssw)))
	OutputMsg(format("BattleWorld.m_StartTime = %s",
		tostring(bw and bw.m_StartTime)))
	OutputMsg(format("WAR_TIME = %s", tostring(wt)))
	if (bw and bw.m_StartTime and bw.m_StartTime > 0 and glt) then
		local elapsed = glt() - bw.m_StartTime
		OutputMsg(format("Elapsed = %ds (need %s to fire)", elapsed, tostring(wt)))
	end
	OutputMsg(format("m_FallbackFired = %s", tostring(stt.m_FallbackFired)))
	OutputMsg(format("RelayProtocol.m_Step = %s",
		tostring(RelayProtocol and RelayProtocol.m_Step)))
	OutputMsg(format("SimThatThanh.m_IsRunning = %s", tostring(stt.m_IsRunning)))
	OutputMsg(format("SimThatThanh.DEBUG_LOG = %s (set 1 de xem log fallback fire)",
		tostring(stt.DEBUG_LOG)))
end

function SimTDC_SetMode(mode)
	SimThatThanh.CFG.USE_SIMCITIZEN = tonumber(mode) or 0
	SimThatThanh:log(format("USE_SIMCITIZEN = %d", SimThatThanh.CFG.USE_SIMCITIZEN))
end
function SimTDC_SetInvader(enable)
	SimThatThanh.CFG.INVADER_ENABLED = tonumber(enable) or 0
	SimThatThanh:log(format("INVADER_ENABLED = %d", SimThatThanh.CFG.INVADER_ENABLED))
end

-- Q2 GM commands
function SimTDC_SetShuffle(enable)
	SimThatThanh.CFG.BANG_RANDOM_SHUFFLE = tonumber(enable) or 0
	SimThatThanh:log(format("BANG_RANDOM_SHUFFLE = %d - hieu luc lan StartAll tiep theo",
		SimThatThanh.CFG.BANG_RANDOM_SHUFFLE))
end

function SimTDC_ShowAssignments()
	if (PlayerIndex and PlayerIndex > 0) then
		local player = Player:New(PlayerIndex)
		player:Say("=== Bang assignments ===")
		for i = 1, getn(FIELD_LIST) do
			local mapid = FIELD_LIST[i]
			local bangIdx = SimThatThanh.m_MapDefenderBangIdx[mapid]
			local bang = SimThatThanh.m_FakeBangs[bangIdx]
			local info = MAP_INFO[mapid]
			player:Say(format("Map %d (%s) -> %s",
				mapid, (info and info.CityName) or "?", (bang and bang.name) or "?"))
		end
	end
end

function SimTDC_ForceInvader()
	local player = Player:New(PlayerIndex)
	local mapid, _, _ = player:GetWorldPos()
	SimThatThanh.m_MapCaptured[mapid] = 1
	local n = SimThatThanh:spawnInvaderForMap(mapid)
	player:Say(format("Force invader spawn map %d: %d bots", mapid, n))
end

function SimTDC_ForceInvaderClear()
	local player = Player:New(PlayerIndex)
	local mapid, _, _ = player:GetWorldPos()
	local n = SimThatThanh:despawnInvaderForMap(mapid)
	player:Say(format("Force invader despawn map %d: %d bots", mapid, n))
end

function SimTDC_JoinMe()
	local player = Player:New(PlayerIndex)
	local mapid, _, _ = player:GetWorldPos()
	local field = BattleWorld:FindField(mapid)
	if (not field) then
		player:Say("<color=red>[SIMTDC]<color> Map " .. mapid .. " khong phai TTDC")
		return
	end
	field:Enter(player)
	player:SetFightState(1)
	player:Say(format("<color=green>[SIMTDC]<color> Joined map %d", mapid))
end

function SimTDC_WeakLongTru(hp)
	hp = tonumber(hp) or 100000
	local cnt = 0
	for i = 1, getn(FIELD_LIST) do
		local field = BattleWorld:FindField(FIELD_LIST[i])
		if (field and field.m_Monster and field.m_Monster.m_NpcIndex and
		    field.m_Monster.m_NpcIndex > 0 and NPCINFO_SetNpcCurrentMaxLife) then
			NPCINFO_SetNpcCurrentMaxLife(field.m_Monster.m_NpcIndex, hp)
			NPCINFO_SetNpcCurrentLife(field.m_Monster.m_NpcIndex, hp)
			SyncNpc(field.m_Monster.m_NpcIndex)
			cnt = cnt + 1
		end
	end
	print(format("[SIMTDC] Set Long Tru HP=%d cho %d map", hp, cnt))
end

function SimTDC_LongTruInfo()
	local player = Player:New(PlayerIndex)
	local mapid, _, _ = player:GetWorldPos()
	local field = BattleWorld:FindField(mapid)
	if (not field or not field.m_Monster) then
		player:Say("Khong tim thay Long Tru map " .. mapid); return
	end
	local idx = field.m_Monster.m_NpcIndex or 0
	local life = (idx > 0 and NPCINFO_GetNpcCurrentLife and NPCINFO_GetNpcCurrentLife(idx)) or 0
	local maxLife = (idx > 0 and NPCINFO_GetNpcCurrentMaxLife and NPCINFO_GetNpcCurrentMaxLife(idx)) or 0
	local captured = (SimThatThanh.m_MapCaptured[mapid] == 1) and "YES" or "NO"
	local invader = (SimThatThanh.m_MapAttackerActive[mapid] == 1) and "YES" or "NO"
	player:Say(format("Map %d Tru: idx=%d HP=%d/%d camp=%d captured=%s invader=%s",
		mapid, idx, life, maxLife, field.m_Monster.m_Camp or 0, captured, invader))
end

function SimTDC_Status()
	local totalReg = 0
	local mapLines = {}
	for mapid, list in SimThatThanh.m_MapNpcs do
		local n = getn(list)
		totalReg = totalReg + n
		local capFlag = (SimThatThanh.m_MapCaptured[mapid] == 1) and "C" or "-"
		local invFlag = (SimThatThanh.m_MapAttackerActive[mapid] == 1) and "I" or "-"
		tinsert(mapLines, format("%d[%s%s]:%d", mapid, capFlag, invFlag, n))
	end
	for mapid, cap in SimThatThanh.m_MapCaptured do
		if (cap == 1 and not SimThatThanh.m_MapNpcs[mapid]) then
			tinsert(mapLines, format("%d[C-]:0", mapid))
		end
	end
	
	local fighterCount = 0
	if (SimCitizen and SimCitizen.fighterList) then
		for k, v in SimCitizen.fighterList do
			if (v and v.mode == "chiendau") then fighterCount = fighterCount + 1 end
		end
	end
	local queueSize = 0
	for k, v in SimThatThanh.m_RespawnQueue do queueSize = queueSize + 1 end
	local capturedCount = 0
	local invaderActiveCount = 0
	for k, v in SimThatThanh.m_MapCaptured do
		if (v == 1) then capturedCount = capturedCount + 1 end
	end
	for k, v in SimThatThanh.m_MapAttackerActive do
		if (v == 1) then invaderActiveCount = invaderActiveCount + 1 end
	end
	
	print(format("[SIMTDC] Reg:%d SimCitizen:%d Queue:%d Captured:%d InvaderActive:%d",
		totalReg, fighterCount, queueSize, capturedCount, invaderActiveCount))
	local mstr = ""
	for i = 1, getn(mapLines) do mstr = mstr .. mapLines[i] .. " " end
	print(format("[SIMTDC] Maps (C=captured I=invader): %s", mstr))
	
	if (PlayerIndex and PlayerIndex > 0) then
		local player = Player:New(PlayerIndex)
		player:Say(format("Reg:%d Cap:%d Inv:%d Queue:%d",
			totalReg, capturedCount, invaderActiveCount, queueSize))
	end
end

-- Inspect bot defender camps. Usage:
--   /Lua SimTDC_InspectBots()       -> quet tat ca 7 map TTDC
--   /Lua SimTDC_InspectBots(926)    -> chi 1 map cu the
function SimTDC_InspectBots(mapid)
	mapid = tonumber(mapid) or 0
	-- Build danh sach map de quet
	local mapsToScan = {}
	if (mapid > 0) then
		tinsert(mapsToScan, mapid)
	else
		for i = 1, getn(FIELD_LIST) do
			tinsert(mapsToScan, FIELD_LIST[i])
		end
	end
	
	print("================================================================")
	print(format("[SIMTDC] INSPECT BOTS - scan %d map", getn(mapsToScan)))
	print(format("[SIMTDC] Player CurCamp=%d TmpCamp=%d (de tham chieu matrix)",
		(PlayerIndex and CallPlayerFunction(PlayerIndex, GetCurCamp)) or -1,
		(PlayerIndex and CallPlayerFunction(PlayerIndex, GetTmpCamp)) or -1))
	
	local grandTotal = 0
	local grandCampStats = {}
	local grandTmpStats = {}
	local grandAnomalies = 0
	
	for mi = 1, getn(mapsToScan) do
		local m = mapsToScan[mi]
		local list = SimThatThanh.m_MapNpcs[m]
		if (not list) then
			print(format("[SIMTDC] Map %d: 0 bot trong m_MapNpcs (skip)", m))
		else
			local n = getn(list)
			print("----------------------------------------------------------------")
			print(format("[SIMTDC] Map %d: %d bot", m, n))
			local mapAnom = 0
			local mapStats = {}
			local mapTmpStats = {}
			local shownCount = 0
			for i = 1, n do
				local botInfo = list[i]
				if (botInfo and botInfo.npcIdx > 0) then
					local exists = (IsNpcExist == nil or IsNpcExist(botInfo.npcIdx) ~= 0)
					local cur = (GetNpcCurCamp and GetNpcCurCamp(botInfo.npcIdx)) or -1
					local tmp = (GetTmpCamp and GetTmpCamp(botInfo.npcIdx)) or -1
					local kind = (GetNpcKind and GetNpcKind(botInfo.npcIdx)) or -1
					local bang = SimThatThanh.m_FakeBangs[botInfo.bangIdx]
					local bangName = (bang and bang.name) or "?"
					local expectedTmp = (bang and bang.camp) or -1
					mapStats[cur] = (mapStats[cur] or 0) + 1
					mapTmpStats[tmp] = (mapTmpStats[tmp] or 0) + 1
					grandCampStats[cur] = (grandCampStats[cur] or 0) + 1
					grandTmpStats[tmp] = (grandTmpStats[tmp] or 0) + 1
					grandTotal = grandTotal + 1
					-- Anomaly: not exist OR TmpCamp != bang.camp OR Kind != 0 (NPC mode = unattackable)
					local botCurExpected = SimThatThanh:getBotCurCamp()
					local isAnom = (not exists or tmp ~= expectedTmp
						or cur ~= botCurExpected or kind ~= 0)
					if (isAnom) then
						mapAnom = mapAnom + 1
						grandAnomalies = grandAnomalies + 1
					end
					if (shownCount < 3 or isAnom) then
						print(format("  bot[%d] npcIdx=%d bang=%s exists=%s CurCamp=%d TmpCamp=%d Kind=%d (expect Tmp=%d Kind=0)",
							i, botInfo.npcIdx, bangName, exists and "Y" or "N",
							cur, tmp, kind, expectedTmp))
						shownCount = shownCount + 1
					end
				end
			end
			-- Map summary
			local cstr = "  CurCamp:"
			for c, cnt in mapStats do cstr = cstr .. format(" %d=%d", c, cnt) end
			local tstr = "  TmpCamp:"
			for t, cnt in mapTmpStats do tstr = tstr .. format(" %d=%d", t, cnt) end
			print(cstr .. " | " .. tstr .. format(" | anomalies=%d", mapAnom))
		end
	end
	
	-- Grand summary
	print("================================================================")
	local gcs = "GRAND CurCamp:"
	for c, cnt in grandCampStats do gcs = gcs .. format(" %d=%d", c, cnt) end
	print(gcs)
	local gts = "GRAND TmpCamp:"
	for t, cnt in grandTmpStats do gts = gts .. format(" %d=%d", t, cnt) end
	print(gts)
	print(format("[SIMTDC] TOTAL bots=%d  anomalies=%d (TmpCamp != bang.camp hoac CurCamp != expect)",
		grandTotal, grandAnomalies))
	print("================================================================")
end

-- Probe engine IsAttackableCamp matrix tu goc nhin player. 
-- Usage: /Lua SimTDC_ProbeMatrix()
function SimTDC_ProbeMatrix()
	if (not IsAttackableCamp) then
		print("[SIMTDC] IsAttackableCamp not available")
		return
	end
	local pCur = (PlayerIndex and CallPlayerFunction(PlayerIndex, GetCurCamp)) or -1
	local pTmp = (PlayerIndex and CallPlayerFunction(PlayerIndex, GetTmpCamp)) or -1
	print("================================================================")
	print(format("[SIMTDC] PROBE MATRIX. Player CurCamp=%d TmpCamp=%d", pCur, pTmp))
	print("----------------------------------------------------------------")
	-- Player CurCamp vs target X (0-12): co dap target khong?
	local s1 = format("matrix(pCur=%d, X)= ", pCur)
	for x = 0, 12 do
		s1 = s1 .. format("%d:%d ", x, IsAttackableCamp(pCur, x) or -1)
	end
	print(s1)
	-- Player TmpCamp vs target X
	local s2 = format("matrix(pTmp=%d, X)= ", pTmp)
	for x = 0, 12 do
		s2 = s2 .. format("%d:%d ", x, IsAttackableCamp(pTmp, x) or -1)
	end
	print(s2)
	-- Target X vs Player CurCamp: co bi dap khong?
	local s3 = format("matrix(X, pCur=%d)= ", pCur)
	for x = 0, 12 do
		s3 = s3 .. format("%d:%d ", x, IsAttackableCamp(x, pCur) or -1)
	end
	print(s3)
	print("================================================================")
end

-- Manual force-fix tat ca bot TmpCamp ngay lap tuc.
-- Dung de test: neu chay xong InspectBots khong con anomaly => watchdog co van de.
-- Neu chay xong van con anomaly => engine resist SetTmpCamp (bug khac).
function SimTDC_ForceFixCamp()
	if (not SimThatThanh.m_MapNpcs) then
		print("[SIMTDC] m_MapNpcs empty"); return
	end
	local botCur = SimThatThanh:getBotCurCamp()
	local total, fixed = 0, 0
	for mapid, list in SimThatThanh.m_MapNpcs do
		for i = 1, getn(list) do
			local botInfo = list[i]
			if (botInfo and botInfo.npcIdx > 0
			    and (IsNpcExist == nil or IsNpcExist(botInfo.npcIdx) ~= 0)) then
				total = total + 1
				local bang = SimThatThanh.m_FakeBangs[botInfo.bangIdx]
				local targetTmp = (bang and bang.camp) or botCur
				local before = (GetTmpCamp and GetTmpCamp(botInfo.npcIdx)) or -1
				if (SetTmpCamp) then SetTmpCamp(targetTmp, botInfo.npcIdx) end
				if (SetNpcCurCamp) then SetNpcCurCamp(botInfo.npcIdx, botCur) end
				local after = (GetTmpCamp and GetTmpCamp(botInfo.npcIdx)) or -1
				if (before ~= targetTmp) then
					fixed = fixed + 1
					if (after ~= targetTmp) then
						-- ENGINE RESIST! SetTmpCamp khong stick
						print(format("  [RESIST] npcIdx=%d before=%d set=%d after=%d",
							botInfo.npcIdx, before, targetTmp, after))
					end
				end
			end
		end
	end
	print(format("[SIMTDC] ForceFixCamp: total=%d fixed=%d (CurCamp=%d, TmpCamp=bang.camp)",
		total, fixed, botCur))
end

-- Check watchdog co dang chay khong (phai thay counter tang sau vai giay)
function SimTDC_WatchdogStatus()
	print(format("[SIMTDC] m_IsRunning=%s", tostring(SimThatThanh.m_IsRunning)))
	print(format("[SIMTDC] m_WatchdogTickCount=%s (phai tang ~5/s neu watchdog dang chay)",
		tostring(SimThatThanh.m_WatchdogTickCount)))
	print(format("[SIMTDC] KCWCounter=%s (sau 270 ticks moi log 1 lan ~60s)",
		tostring(SimThatThanh.m_KCWCounter)))
	print(format("[SIMTDC] KCWBatchCounter=%s", tostring(SimThatThanh.m_KCWBatchCounter)))
	print(format("[SIMTDC] m_RefSimCitizen=%s m_RefSimFight=%s (cached cross-env refs)",
		tostring(SimThatThanh.m_RefSimCitizen ~= nil),
		tostring(SimThatThanh.m_RefSimFight ~= nil)))
	-- Run watchdog manually 1 lan de chac chan
	if (SimThatThanh.m_IsRunning == 1) then
		print("[SIMTDC] Manual run KindCampWatchdog now...")
		SimThatThanh:KindCampWatchdog()
	end
end

-- Fix orphan + drift bot ngay lap tuc (khong doi watchdog tick).
-- Quet SimCitizen.fighterList: register neu thieu, force-reset cur/tmp/kind/AI
-- bat ke registry da co dung khong (vi engine state co the drift sau revival).
function SimTDC_FixOrphans()
	if (not SimCitizen or not SimCitizen.fighterList) then
		print("[SIMTDC] SimCitizen.fighterList unavailable"); return
	end
	if (not SimFight or not SimFight.Citizen
	    or not SimFight.Citizen.m_TTDCRegistry) then
		print("[SIMTDC] m_TTDCRegistry unavailable"); return
	end
	local botC = SimThatThanh:getBotCurCamp()
	local total, orphans, stateFixed, skipped = 0, 0, 0, 0
	for listId, fighter in SimCitizen.fighterList do
		if (fighter and fighter.isTTDCBot == 1 and fighter.bangIdx
		    and fighter.finalIndex and fighter.finalIndex > 0
		    and fighter.isDead ~= 1
		    and (IsNpcExist == nil or IsNpcExist(fighter.finalIndex) ~= 0)) then
			-- GUARD: PARAM_LIST_ID check tranh idx recycled
			local idValid = 1
			if (GetNpcParam and PARAM_LIST_ID) then
				local actualListId = GetNpcParam(fighter.finalIndex, PARAM_LIST_ID) or 0
				local expectedId = fighter.id or listId
				if (actualListId ~= expectedId) then
					idValid = 0
					skipped = skipped + 1
					fighter.isDead = 1
				end
			end
			if (idValid == 1) then
				total = total + 1
				local bang = SimThatThanh.m_FakeBangs[fighter.bangIdx]
				if (bang) then
					-- Register
					if (SimFight.Citizen.m_TTDCRegistry[fighter.finalIndex] ~= fighter.bangIdx) then
						SimFight.Citizen.m_TTDCRegistry[fighter.finalIndex] = fighter.bangIdx
						SimThatThanh.m_NpcIdx2BangIdx[fighter.finalIndex] = fighter.bangIdx
						if (SetNpcDeathScript and SCRIPT_SIMTDC_DEATH) then
							SetNpcDeathScript(fighter.finalIndex, SCRIPT_SIMTDC_DEATH)
						end
						orphans = orphans + 1
					end
					-- Engine state: TmpCamp
					local actualTmp = (GetTmpCamp and GetTmpCamp(fighter.finalIndex)) or 0
					if (actualTmp ~= bang.camp and SetTmpCamp) then
						SetTmpCamp(bang.camp, fighter.finalIndex)
						stateFixed = stateFixed + 1
					end
					-- Engine state: CurCamp
					local actualCur = (GetNpcCurCamp and GetNpcCurCamp(fighter.finalIndex)) or 0
					if (actualCur ~= botC and SetNpcCurCamp) then
						SetNpcCurCamp(fighter.finalIndex, botC)
					end
					-- Kind
					if (GetNpcKind and SetNpcKind) then
						if (GetNpcKind(fighter.finalIndex) ~= 0) then
							SetNpcKind(fighter.finalIndex, 0)
						end
					end
					-- AI
					if (SetNpcAI) then SetNpcAI(fighter.finalIndex, 1) end
				end
			end
		end
	end
	print(format("[SIMTDC] FixOrphans: total=%d orphans-registered=%d state-reset=%d recycled-skipped=%d",
		total, orphans, stateFixed, skipped))
end


-- Dung de tim ra "bot ko danh duoc": no la sim keoxe cua minh? Pillar? Defender?
-- Usage: /Lua SimTDC_ScanAround()  hoac  /Lua SimTDC_ScanAround(50)
function SimTDC_ScanAround(radius)
	radius = tonumber(radius) or 30
	if (not PlayerIndex or PlayerIndex <= 0) then
		print("[SIMTDC] No PlayerIndex"); return
	end
	local player = Player:New(PlayerIndex)
	local mapid, pX, pY = player:GetWorldPos()
	local pTmp = CallPlayerFunction(PlayerIndex, GetTmpCamp) or 0
	local pCur = CallPlayerFunction(PlayerIndex, GetCurCamp) or 0
	local pName = CallPlayerFunction(PlayerIndex, GetName) or "?"
	local pTong = (BattleWorld and BattleWorld.GetWarriorTong
		and BattleWorld:GetWarriorTong(pName)) or "?"
	
	local allNpcs, nCount = CallPlayerFunction(PlayerIndex, GetAroundNpcList, radius)
	if (not allNpcs) then nCount = 0 end
	
	print("================================================================")
	print(format("[SIMTDC] SCAN around player '%s' tong='%s'", pName, pTong))
	print(format("[SIMTDC] map=%d pos=(%d,%d) radius=%d nCount=%d",
		mapid, pX, pY, radius, nCount))
	print(format("[SIMTDC] Player CurCamp=%d TmpCamp=%d", pCur, pTmp))
	print("----------------------------------------------------------------")
	
	local stat_pillar, stat_def, stat_sim, stat_unk = 0, 0, 0, 0
	local stat_canAttack, stat_cantAttack = 0, 0
	
	for i = 1, nCount do
		local idx = allNpcs[i]
		if (idx and idx > 0) then
			local cur = (GetNpcCurCamp and GetNpcCurCamp(idx)) or -1
			local tmp = (GetTmpCamp and GetTmpCamp(idx)) or -1
			local kind = (GetNpcKind and GetNpcKind(idx)) or -1
			local name = (GetNpcName and GetNpcName(idx)) or "?"
			
			-- Identify origin
			local origin = "UNKNOWN"
			local reg = (SimFight and SimFight.Citizen
				and SimFight.Citizen.m_TTDCRegistry
				and SimFight.Citizen.m_TTDCRegistry[idx])
			if (reg == -1) then
				origin = "PILLAR"
				stat_pillar = stat_pillar + 1
			elseif (reg and reg > 0) then
				local bang = SimThatThanh.m_FakeBangs[reg]
				origin = format("DEFENDER bang=%s(camp=%d)",
					(bang and bang.name) or "?", (bang and bang.camp) or -1)
				stat_def = stat_def + 1
			else
				-- Check if sim keoxe (cua bat ky player nao)
				if (GetNpcParam and PARAM_LIST_ID and PARAM_TYPE) then
					local npcType = GetNpcParam(idx, PARAM_TYPE) or 0
					local listId = GetNpcParam(idx, PARAM_LIST_ID) or 0
					if (npcType == 2 and listId > 0 and SimTheoSau
					    and SimTheoSau.fighterList) then
						local sim = SimTheoSau.fighterList[listId]
						if (sim and sim.role == "keoxe") then
							origin = format("SIM-KEOXE owner='%s'",
								sim.playerID or "?")
							stat_sim = stat_sim + 1
						elseif (sim and sim.role) then
							origin = format("SIM-%s owner='%s'",
								sim.role, sim.playerID or "?")
							stat_sim = stat_sim + 1
						else
							stat_unk = stat_unk + 1
						end
					else
						stat_unk = stat_unk + 1
					end
				else
					stat_unk = stat_unk + 1
				end
			end
			
			-- Compute attackability tu goc nhin player
			local atkResult = -1
			if (IsAttackableCamp and pTmp > 0 and tmp > 0) then
				atkResult = IsAttackableCamp(pTmp, tmp) or -1
			end
			local atkStr = "ATK?"
			if (atkResult == 1) then
				atkStr = "ATK_OK"
				stat_canAttack = stat_canAttack + 1
			elseif (atkResult == 0) then
				atkStr = "ATK_NO"
				stat_cantAttack = stat_cantAttack + 1
			end
			
			print(format("  [%d] idx=%d cur=%d tmp=%d kind=%d %s '%s' %s",
				i, idx, cur, tmp, kind, atkStr, name, origin))
		end
	end
	
	print("----------------------------------------------------------------")
	print(format("[SIMTDC] Origin: pillar=%d defender=%d sim=%d unknown=%d",
		stat_pillar, stat_def, stat_sim, stat_unk))
	print(format("[SIMTDC] Attack: ATK_OK=%d ATK_NO=%d (matrix(player_tong, npc_tmp))",
		stat_canAttack, stat_cantAttack))
	print("[SIMTDC] => 'ATK_NO' la cac NPC quanh player KHONG dap duoc.")
	print("================================================================")
end


-- Check trang thai sim keoxe formation hook (verify hook co fire khong + write count).
-- Dung khi sim van bu mot cho ko spread du da config CFG.
function SimTDC_KeoXeStatus()
	print("================================================================")
	print(format("[SIMTDC] SimCityKeoXe ATick patched: %s",
		tostring(SimCityKeoXe and SimCityKeoXe.m_TTDCATickPatched)))
	print(format("[SIMTDC] ATick fire count: %s (phai tang khi player di chuyen)",
		tostring(SimCityKeoXe and SimCityKeoXe.m_TTDCATickFireCount)))
	print(format("[SIMTDC] ATick write count: %s (so lan set parentAppointPos)",
		tostring(SimCityKeoXe and SimCityKeoXe.m_TTDCATickWriteCount)))
	print(format("[SIMTDC] CFG.KEOXE_FORMATION_ENABLED=%s SCALE=%s JITTER=%s",
		tostring(SimThatThanh.CFG.KEOXE_FORMATION_ENABLED),
		tostring(SimThatThanh.CFG.KEOXE_FORMATION_SCALE),
		tostring(SimThatThanh.CFG.KEOXE_FORMATION_JITTER)))
	-- Check refs availability
	if (SimCityKeoXe) then
		print(format("[SIMTDC] Refs cached: SimTheoSau=%s genCoords=%s createForm=%s getCenteredCell=%s",
			tostring(SimCityKeoXe.m_TTDCRefSimTheoSau ~= nil),
			tostring(SimCityKeoXe.m_TTDCRefGenCoords ~= nil),
			tostring(SimCityKeoXe.m_TTDCRefCreateFormation ~= nil),
			tostring(SimCityKeoXe.m_TTDCRefGetCenteredCell ~= nil)))
	end
	-- Check current sim formation
	local pName = (PlayerIndex and CallPlayerFunction
		and CallPlayerFunction(PlayerIndex, GetName)) or ""
	if (pName ~= "" and SimCityKeoXe and SimCityKeoXe.collections
	    and SimCityKeoXe.collections[pName]) then
		local children = SimCityKeoXe.collections[pName]
		print(format("[SIMTDC] Player '%s' co %d sim trong collections",
			pName, getn(children)))
		local pW, pX, pY = CallPlayerFunction(PlayerIndex, GetWorldPos)
		print(format("[SIMTDC] Player pos: w=%s (%s,%s)",
			tostring(pW), tostring(pX), tostring(pY)))
		for i = 1, getn(children) do
			if (i <= 5) then  -- show first 5
				local sim = SimTheoSau:Get(children[i])
				if (sim and sim.finalIndex and sim.finalIndex > 0) then
					local nX, nY = GetNpcPos(sim.finalIndex)
					local apos = sim.parentAppointPos
					print(format("  sim[%d] idx=%d pos=(%d,%d) appoint=(%s,%s) offset=(%s,%s) bounds=%s",
						i, sim.finalIndex,
						(nX or 0)/32, (nY or 0)/32,
						(apos and tostring(apos[1])) or "nil",
						(apos and tostring(apos[2])) or "nil",
						tostring(sim.m_TTDCFixedOffX or "nil"),
						tostring(sim.m_TTDCFixedOffY or "nil"),
						tostring(sim.childrenCheckDistance or "nil")))
				end
			end
		end
	else
		print(format("[SIMTDC] Player '%s' khong co sim trong collections", pName))
	end
	print("================================================================")
end


-- Dung khi mot so bot bi spawn voi kind=1 (NPC mode, unattackable).
function SimTDC_FixKind()
	if (not SimThatThanh.m_MapNpcs) then
		print("[SIMTDC] m_MapNpcs empty"); return
	end
	if (not SetNpcKind or not GetNpcKind) then
		print("[SIMTDC] SetNpcKind/GetNpcKind not available"); return
	end
	local total, fixed = 0, 0
	local kindStats = {}
	for mapid, list in SimThatThanh.m_MapNpcs do
		for i = 1, getn(list) do
			local botInfo = list[i]
			if (botInfo and botInfo.npcIdx > 0
			    and (IsNpcExist == nil or IsNpcExist(botInfo.npcIdx) ~= 0)) then
				total = total + 1
				local k = GetNpcKind(botInfo.npcIdx) or -1
				kindStats[k] = (kindStats[k] or 0) + 1
				if (k ~= 0) then
					SetNpcKind(botInfo.npcIdx, 0)
					SetNpcAI(botInfo.npcIdx, 1)
					fixed = fixed + 1
				end
			end
		end
	end
	local kstr = "Kind distribution:"
	for k, cnt in kindStats do kstr = kstr .. format(" %d=%d", k, cnt) end
	print("[SIMTDC] " .. kstr)
	print(format("[SIMTDC] FixKind: total=%d fixed=%d (set kind=0)", total, fixed))
end


function SimTDC_ShowBangCamps()
	print("================================================================")
	print("[SIMTDC] FAKE BANG CAMPS (registered tong numbers, 5+):")
	if (not SimThatThanh.m_FakeBangs or getn(SimThatThanh.m_FakeBangs) == 0) then
		print("  (chua co bang - chay StartAll truoc)")
		return
	end
	for i = 1, getn(SimThatThanh.m_FakeBangs) do
		local bang = SimThatThanh.m_FakeBangs[i]
		print(format("  [%d] %s (real='%s') => bang.camp = %d",
			i, bang.name or "?", bang.realTong or "?", bang.camp or -1))
	end
	if (PlayerIndex and CallPlayerFunction) then
		local pTmp = CallPlayerFunction(PlayerIndex, GetTmpCamp) or -1
		local pCur = CallPlayerFunction(PlayerIndex, GetCurCamp) or -1
		print(format("[SIMTDC] Player.CurCamp=%d TmpCamp=%d (registered tong)", pCur, pTmp))
		if (IsAttackableCamp) then
			print("Matrix(player_tong, bang_camp) - phai = 1 de player danh duoc bot:")
			for i = 1, getn(SimThatThanh.m_FakeBangs) do
				local bang = SimThatThanh.m_FakeBangs[i]
				local r = IsAttackableCamp(pTmp, bang.camp) or -1
				print(format("  matrix(%d, %d) = %d  [%s]",
					pTmp, bang.camp, r, bang.name or "?"))
			end
		end
	end
	print("================================================================")
end
