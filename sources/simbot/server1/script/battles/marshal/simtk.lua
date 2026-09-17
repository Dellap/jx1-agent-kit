Include("\\script\\global\\nobitaxd\\vdk\\simcity\\head.lua")
simTK = {

}
function simTK:markWarStarted(idMap)
	local wi = SimCityWorld:Get(idMap)
	if wi then
		wi.tkWarStarted = 1; wi.tkMarshal = nil
		wi.tkMFB = nil			
		if BT_GetBattleParam and getNpcInfo and SetMissionV then
			for _ri = 1, 6 do
				local t1, l1 = getNpcInfo(BT_GetBattleParam(_ri))
				SetMissionV(MS_TRANK1_S + _ri - 1, t1); SetMissionV(MS_RANK1LVL_S + _ri - 1, l1)
				local t2, l2 = getNpcInfo(BT_GetBattleParam(_ri + 6))
				SetMissionV(MS_TRANK1_J + _ri - 1, t2); SetMissionV(MS_RANK1LVL_J + _ri - 1, l2)
			end
		end
		if BT_GetGameData and GetMapInfoFile and GetIniFileData and bt_str2xydata and GetMissionV then
			local mf = GetMapInfoFile(BT_GetGameData(GAME_MAPID))
			local sa = BT_GetGameData(GAME_CAMP1AREA)
			local ja = BT_GetGameData(GAME_CAMP2AREA)
			local sx, sy = bt_str2xydata(GetIniFileData(mf, "Area_"..sa, "generalpos"))
			local jx, jy = bt_str2xydata(GetIniFileData(mf, "Area_"..ja, "generalpos"))
			wi.tkMFB = { armTime = (GetGameTime and GetGameTime()) or 0, mapIdx = SubWorldID2Idx(idMap),
				s = {sx, sy, GetMissionV(MS_TRANK1_S + 5), GetMissionV(MS_RANK1LVL_S + 5)},
				j = {jx, jy, GetMissionV(MS_TRANK1_J + 5), GetMissionV(MS_RANK1LVL_J + 5)} }
		end
	end
end

function simTK:markMarshal(idMap, camp, x, y, idx)
	local wi = SimCityWorld:Get(idMap)
	if wi then wi.tkMarshal = wi.tkMarshal or {}; wi.tkMarshal[camp] = {x, y, idx} end
end

function simTK:checkMarshalFallback(idMap)
	local wi = SimCityWorld:Get(idMap)
	if not wi then return end
	wi.fbDbg = (wi.fbDbg or 0) + 1   
	if Msg2Map and mod(wi.fbDbg, 10) == 0 then
		Msg2Map(idMap, "<color=yellow>[FB] war="..tostring(wi.tkWarStarted).." mfb="..(wi.tkMFB and "set" or "NIL").." gt="..tostring((GetGameTime and GetGameTime()) or "NONE").." addnpc="..tostring(AddNpc and "ok" or "NIL").." tmplS="..tostring(wi.tkMFB and wi.tkMFB.s and wi.tkMFB.s[3] or "-").." stg="..tostring(wi.tkMFB and wi.tkMFB.stage or "-"))
	end
	if wi.tkWarStarted ~= 1 or not wi.tkMFB then return end
	local fb = wi.tkMFB

	if (fb.stage or 0) == 0 and wi.tkMarshal and (wi.tkMarshal[1] or wi.tkMarshal[2]) then wi.tkMFB = nil; return end
	local el = ((GetGameTime and GetGameTime()) or 0) - fb.armTime

	if (fb.stage or 0) < 1 and el >= 960 then
		fb.stage = 1
		local ps = g_simBotPointS or 0; local pj = g_simBotPointJ or 0
		fb.loserCamp = (ps <= pj) and 1 or 2
		local dat = (fb.loserCamp == 1) and fb.s or fb.j
		if dat[1] and dat[3] and dat[3] > 0 and AddNpc then
			local idx = AddNpc(dat[3], dat[4] or 95, fb.mapIdx, dat[1]*32, dat[2]*32, 1, "Nguyen Soai", 1)
			if idx and idx > 0 then
				if SetNpcCurCamp then SetNpcCurCamp(idx, fb.loserCamp) end
				self:markMarshal(idMap, fb.loserCamp, dat[1], dat[2], idx)
			end
		end
		if Msg2Map then Msg2Map(idMap, "<color=0x00FFFF>Tong Kim: Nguyen Soai phe yeu da xuat hien! Phong thu!") end
	end

	if (fb.stage or 0) < 2 and el >= 1260 then
		fb.stage = 2
		local wc = (fb.loserCamp == 1) and 2 or 1
		local dat = (wc == 1) and fb.s or fb.j
		if dat[1] and dat[3] and dat[3] > 0 and AddNpc then
			local idx = AddNpc(dat[3], dat[4] or 95, fb.mapIdx, dat[1]*32, dat[2]*32, 1, "Nguyen Soai", 1)
			if idx and idx > 0 then
				if SetNpcCurCamp then SetNpcCurCamp(idx, wc) end
				self:markMarshal(idMap, wc, dat[1], dat[2], idx)
			end
		end
		if Msg2Map then Msg2Map(idMap, "<color=0x9BFF9B>Tong Kim: Nguyen Soai phe con lai da xuat hien!") end
		wi.tkMFB = nil
	end
end
function SimCityChienTranh:taoNV_TK(id, camp, worldInfo, walkPathNames, nt, theosau, capHP, extraConfig)
	if not walkPathNames then
		return nil
	end

	local mapID = worldInfo.worldId
	local name = "Kim"
	local rank = 1
	local realCamp = camp   
	if camp == 1 then
		name = "Tèng"
		realCamp = camp  
	end
	
	local hardsetName = (nt == 1 and SimCityNPCInfo:generateName()) or SimCityNPCInfo:getName(id)
	if worldInfo.isTongKim == 1 then
		realCamp = camp
		hardsetName = (nt == 1 and SimCityNPCInfo:generateName()) or nil
	end
 
	local tbNpc = {
		mode = "chiendau",
		szName = name or "",

		nNpcId = id,                            -- required, main char ID
		nMapId = mapID,                         -- required, map
		camp = realCamp,                        -- optional, camp

		walkMode = (theosau and "formation") or "preset", -- optional: random, keoxe, or formation for formation
		walkVar = (theosau and 3) or 4,         -- random walk of radius of 4*2
		walkPathNames = walkPathNames,

		noStop = 1,          -- optional: cannot pause any stop (otherwise 90% walk 10% stop)
		leaveFightWhenNoEnemy = 5, -- optional: leave fight instantly after no enemy, otherwise there's waiting period

		noRevive = 0,        -- optional: 0: keep reviving, 1: dead
 

		CHANCE_ATTACK_PLAYER = 1, -- co hoi tan cong nguoi choi neu di ngang qua
		CHANCE_ATTACK_NPC = 1, -- co hoi bat chien dau khi thay NPC khac phe
		CHANCE_JOIN_FIGHT = 1, -- co hoi tang cong NPC neu di ngang qua NPC danh nhau
		RADIUS_FIGHT_PLAYER = 40, -- scan for player around and randomly attack
		RADIUS_FIGHT_NPC = 40, -- scan for NPC around and start randomly attack,
		RADIUS_FIGHT_SCAN = 40, -- scan for fight around and join/leave fight it
 
		kind = 0,          
		level = 95,        
		TIME_FIGHTING_minTs = 6000,
		TIME_FIGHTING_maxTs = 6000,
		TIME_RESTING_minTs = 0,
		TIME_RESTING_maxTs = 1,

		resetPosWhenRevive = 1,

		tongkim = 1,
		tongkim_name = name,

		ngoaitrang = nt or 0,
		hardsetName = hardsetName,

		capHP = 2,
		rank = rank or 1,
		childrenSetup = theosau or nil,
		childrenCheckDistance = (theosau and 8) or nil -- force distance check for child

	}

	if extraConfig then
		for k,v in extraConfig do
			tbNpc[k] = v
		end
	end

	return SimCitizen:New(tbNpc)
end
function SimCityChienTranh:genWalkPath_TK(forCamp) 
	local worldInfo = SimCityWorld:Get(self.nW)

	local myPath = {}
	local mySpawnODuoi = 1
	
	-- Don gian: camp 1 = duoi, camp 2 = tren
	if forCamp == 1 then
		mySpawnODuoi = 1  -- Tong luon o duoi
	else
		mySpawnODuoi = 0  -- Kim luon o tren
	end

	local presetCampDuoiKey = worldInfo.presetPaths.baseDuoi
	local presetCampTrenKey = worldInfo.presetPaths.baseTren 

	if (mySpawnODuoi == 1) then
		
		if worldInfo.restrictedSpawns.campduoi then
			local filtered = {}
			for i=1, getn(presetCampDuoiKey) do
				local key = presetCampDuoiKey[i]
				if not worldInfo.restrictedSpawns.campduoi[key] then
					tinsert(filtered, key)
				end
			end
			presetCampDuoiKey = filtered
		end

		local mySpawn = presetCampDuoiKey[random(1, getn(presetCampDuoiKey))]
		local theirSpawn = presetCampTrenKey[random(1, getn(presetCampTrenKey))]
		local mainPath = SimCityGraphToChienTranh:autoFindPathNames(worldInfo, mySpawn, theirSpawn, 0)

 		tinsert(myPath, { mySpawn, 0 })
		--tinsert(myPath, { mainPath, 1})
		tinsert(myPath, { theirSpawn, 1 })

	-- My spawn o tren
	else

		if worldInfo.restrictedSpawns.camptren then
			local filtered = {}
			for i=1, getn(presetCampTrenKey) do
				local key = presetCampTrenKey[i]
				if not worldInfo.restrictedSpawns.camptren[key] then
					tinsert(filtered, key)
				end
			end	
			presetCampTrenKey = filtered
		end

		local mySpawn = presetCampTrenKey[random(1, getn(presetCampTrenKey))]
		local theirSpawn = presetCampDuoiKey[random(1, getn(presetCampDuoiKey))]
		local mainPath = SimCityGraphToChienTranh:autoFindPathNames(worldInfo, mySpawn, theirSpawn, 1)
 		tinsert(myPath, { mySpawn, 0 })
		--tinsert(myPath, { mainPath, -1})
		tinsert(myPath, { theirSpawn, 1 })
	end  
 
	return myPath
end

function simTK:removeSimTK(mapid)
	--print("remove simTK in mapid "..mapid)
	SimCityChienTranh:removeAll(mapid)	
end
function simTK:add_npc_simcity_by_camp(nIdMap,nIdNpc,forCamp)
	SimCityChienTranh:init(nIdMap)
	local worldInfo = SimCityWorld:Get(nIdMap)
	local myPath = {}
	if isGioCaoDiem() == 1 then
		--myPath = SimCityChienTranh:genWalkPath_TK(forCamp)
		myPath = SimCityChienTranh:genWalkPath(forCamp)
	else
		myPath = SimCityChienTranh:genWalkPath(forCamp)
	end

	local fighter = SimCityChienTranh:taoNV_TK(nIdNpc, forCamp, worldInfo, myPath, 1)	
end
function simTK:call_npc_simcity(nIdMap,startNPCIndex, stopNPCIndex, nCount ,ngoaitrang)
	local nIdNpc = startNPCIndex
	for i = 1, nCount do 
		self:add_npc_simcity_by_camp(nIdMap,nIdNpc,1)
		self:add_npc_simcity_by_camp(nIdMap,nIdNpc,2)
		nIdNpc = nIdNpc + 1
		if nIdNpc > stopNPCIndex then
			nIdNpc = startNPCIndex
		end
	end

end
function simTK:add_npc_simcity(idMap)
		self:call_npc_simcity(idMap, 2000,2023,100,1)
	local _wi = SimCityWorld:Get(idMap)
	if _wi then _wi.tkWarStarted = 0 end
end