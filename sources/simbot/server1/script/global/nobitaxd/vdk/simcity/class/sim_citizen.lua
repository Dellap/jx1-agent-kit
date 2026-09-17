Include("\\script\\global\\nobitaxd\\vdk\\simcity\\components\\sim.core.lua")
SimCitizen = objCopy(SimCore)

SimCitizen.fighterList = {}  -- Override with own list
SimCitizen.counter = 1
SimCitizen.removedIds = {}
SimCitizen.currentProcessGroup = 1 -- Add current group counter
SimCitizen.totalFighters = 0 -- Track total fighters

function SimCitizen:New(fighter)

    -- Setup minimum config
    self:initCharConfig(fighter)

    local nListId
    if getn(self.removedIds) > 0 then
        nListId = tremove(self.removedIds)
    else
        nListId = self.counter
        self.counter = self.counter + 1
    end

    -- Increment total fighters
    self.totalFighters = self.totalFighters + 1
    
    -- Assign to group 1 or 2 evenly
    local processGroup = (mod(self.totalFighters, 2) + 1)

    local tbNpc = {
        id = nListId,
        children = nil,
        worldInfo = SimCityWorld:Get(fighter.nMapId),
        last2VisitedEdges = {}, -- Track last visited edges for more natural movement
        processGroup = processGroup -- Alternate between group 1 and 2
    }

    -- Check if worldInfo is nil
    if (tbNpc.worldInfo == nil) then
        return nil
    end


    for k, v in fighter do
        tbNpc[k] = v
    end

    
    -- All good generate name for Thanh Thi
    if tbNpc.mode == nil or tbNpc.mode == "thanhthi" or tbNpc.mode == "train" then
        if tbNpc.worldInfo.showName == 1 then
            if (not tbNpc.szName) or tbNpc.szName == "" then
                tbNpc.szName = SimCityNPCInfo:getName(tbNpc.nNpcId)
            end
        else
            tbNpc.szName = " "
        end
    end

    self.fighterList[nListId] = tbNpc

    -- Setup walk paths
    if tbNpc.movementSys:resetPos(self, nListId) == 0 then
        return nil
    end

    -- Create the character on screen
    local canCreate = tbNpc.entitySys:CreateChar(self, tbNpc, 1, tbNpc.goX32, tbNpc.goY32)
    if canCreate == 0 then
        return nil
    end


    -- What about childrenSetup?
    self:initChildrenConfig(nListId, fighter)
    return nListId
end
 

-- For parent
function SimCitizen:initChildrenConfig(nListId, parentConfig)
    local tbNpc = self.fighterList[nListId]
    if tbNpc.childrenSetup and getn(tbNpc.childrenSetup) > 0 then
        local createdChildren = {}

        local nX32, nY32, nW32 = GetNpcPos(tbNpc.finalIndex)
        local nW = SubWorldIdx2ID(nW32) 

        -- Create children
        for i = 1, getn(tbNpc.childrenSetup) do
            local childConfig = objCopy(parentConfig)

            -- Do not inherit faction, series, settingsIdx, skillHoTro
            childConfig.faction = nil
            childConfig.series = nil
            childConfig.nSettingsIdx = nil
            childConfig.skillHoTro = nil
            
            -- Setup parents
            childConfig.parentID = tbNpc.id
            childConfig.childID = i
            childConfig.role = "child"
            childConfig.hardsetName = nil
            childConfig.childrenSetup = nil
            for k, v in tbNpc.childrenSetup[i] do
                childConfig[k] = v
            end
            childConfig.goX32 = nX32
            childConfig.goY32 = nY32
            local childId = self:New(childConfig)
            tinsert(createdChildren, childId)
        end

        tbNpc.children = createdChildren
    end
end

function SimCitizen:ClearMap(nW, clearType)
    -- Get info for npc in this world
    for key, fighter in self.fighterList do
        if fighter.nMapId == nW then
            if (not clearType) then
                self:Remove(fighter.id)
            elseif clearType == "thanhthi" then
                if fighter.mode ~= "chiendau" then
                    self:Remove(fighter.id)
                end
            elseif clearType == "chiendau" then
                if fighter.mode == "chiendau" then
                    self:Remove(fighter.id)
                end
            end
        end
    end
end


-- ===== TEN BANG NGAU NHIEN cho bot Tong Kim. Sua list ten tuy y 
g_TK_BangChance = 50   -- %% bot co ten bang (0-100)
g_TK_BangRanks = g_TK_BangRanks or { "Bang Chñ", "Tr­ëng l·o", "§­êng Chñ", "§Ö Tö" }   -- Bang Chu/Truong Lao/Duong Chu/De Tu
g_TK_BangNames = g_TK_BangNames or {
	"AnhEm", "BèGiµ", "ThÝchPK", "Ph¸Thiªn", "Thiªn§Þa",
	"T×nh", "TiÕuNg¹o", "Badboy", "Huynh§Ö", "S¸t",
}

function SimCitizen:UpdateBotLadder(nW)  
    local bptS, bptJ = 0, 0
    for ii, ff in self.fighterList do
        if ff.nMapId == nW and ff.tongkim == 1 then
            if ff.camp == 1 then bptS = bptS + (ff.fightingScore or 0)
            else bptJ = bptJ + (ff.fightingScore or 0) end
        end
    end 
    if (bptS + bptJ) == 0 then
        if BotLadderClear then BotLadderClear(SubWorldID2Idx(nW)) end
        return
    end

    local mult = (bt_getgn_awardtimes and bt_getgn_awardtimes()) or 1
    if isCuoiTuan and isCuoiTuan() == 1 then mult = mult * 2 end
    if mult < 1 then mult = 1 end
    g_simBotPointS = floor(bptS * mult)
    g_simBotPointJ = floor(bptJ * mult)
    if SetBotPoints then SetBotPoints(SubWorldID2Idx(nW), g_simBotPointS, g_simBotPointJ) end
    local allPlayers = {}
    for i, fighter in self.fighterList do
        if fighter.nMapId == nW then
            local raw_fs = fighter.fightingScore or 0
            local jit = mod((fighter.finalIndex or i) * 37, 71)  
            tinsert(allPlayers, { i, floor(raw_fs * mult) + jit, "npc" })
			SimCityTongKim:updateRank(fighter)
            if SetNpcTitle and fighter.finalIndex and fighter.finalIndex > 0 then
                SetNpcTitle(fighter.finalIndex, fighter.rank or 1)
                if fighter.bangSet == nil then
                    fighter.bangSet = 1
                    if (g_TK_BangNames and getn(g_TK_BangNames) > 0 and random(1, 100) <= (g_TK_BangChance or 50)) then
                        fighter.bangDisp = format("%s-[%s]", g_TK_BangNames[random(1, getn(g_TK_BangNames))], g_TK_BangRanks[random(1, getn(g_TK_BangRanks))])
                    end
                end
                if (SetNpcBang and fighter.bangDisp) then SetNpcBang(fighter.finalIndex, fighter.bangDisp) end
            end
        end
    end
    if (SimCityTongKim.playerInTK and SimCityTongKim.playerInTK[nW]) then
        for pId, data in SimCityTongKim.playerInTK[nW] do
            tinsert(allPlayers, { pId, data.score, "player" })
        end
    end
    if getn(allPlayers) > 1 then
        local maxIndex = getn(allPlayers)
        if maxIndex > 10 then maxIndex = 10 end
        sort(allPlayers, _sortByScore)
        local swIdx = SubWorldID2Idx(nW)
        if BotLadderClear then BotLadderClear(swIdx) end
        for j = 1, maxIndex do
            local info = allPlayers[j]
            if info[3] == "npc" then
                local fighter = self.fighterList[info[1]]
                if fighter and BotLadderAdd and fighter.finalIndex and fighter.finalIndex > 0 then
                    BotLadderAdd(swIdx, fighter.finalIndex, fighter.fightingScore or 0, 0, 0, mult)   -- [2026-06-28] raw fightingScore = PK realistic; mult = tich luy x2 weekend
                end
            end
        end
        if BotLadderBroadcast then BotLadderBroadcast(swIdx) end
    end
end


function SimCitizen:UpdateStallFlags(nW)
    if not SetNpcStall then return end
    for i, fighter in self.fighterList do
        if fighter.nMapId == nW and fighter.stall == 1 and fighter.finalIndex and fighter.finalIndex > 0 then
            SetNpcStall(fighter.finalIndex, 1)
        end
    end
end


function SimCitizen:UpdateCombatFlagsAll()
    if not SetNpcCombat then return end
    for i, fighter in self.fighterList do
        if fighter.finalIndex and fighter.finalIndex > 0 and fighter.isDead ~= 1 then         
            if fighter.isFighting == 1 then           
                SetNpcCombat(fighter.finalIndex, 1, fighter.skillCastBua and fighter.skillCastBua[1] or 0)
            end
        end
    end
end

function SimCitizen:FastCastTick()
    g_fcAlive = (g_fcAlive or 0) + 1; g_fcStage = 0   
    local _cand, _ncand, _ncast, _fi, _dbgIdx, _dbgPz, _dbgCm, _dbgMap = {}, 0, 0, 0, 0, -9, -9, -9
    g_fcFrame = (g_fcFrame or 0) + 1
    local _fpar = g_fcFrame - floor(g_fcFrame / 2) * 2   
    if self.fighterList then for i, fighter in self.fighterList do if fighter.finalIndex and fighter.finalIndex > 0 and fighter.isDead ~= 1 then _dbgIdx = fighter.finalIndex; _dbgCm = fighter.camp or -1; _dbgMap = fighter.nMapId or -1; break end end end
    g_fcStage = 1   
    if self.fighterList and BotDoSkill and SimPickSkill then
        for i, fighter in self.fighterList do
            if fighter.finalIndex and fighter.finalIndex > 0 and fighter.isDead ~= 1
               and fighter.camp and fighter.camp > 0
               and SimCityIsPeaceZone and SimCityIsPeaceZone(fighter) ~= 1 then  
                local _x, _y = GetNpcPos(fighter.finalIndex)
                if _x then
                    _ncand = _ncand + 1
                    _cand[_ncand] = { id = fighter.finalIndex, x = floor(_x / 32), y = floor(_y / 32), cp = fighter.camp, ft = fighter }
                end
            end
        end
        g_fcStage = 2; g_fcNc = _ncand      
        local _a, _b
        for _a = 1, _ncand do
            local ca = _cand[_a]
            local _ft = ca.ft  
            if NpcCastSkill and _ft and _ft.faction and SimCityPhai[_ft.faction] and SimCityPhai[_ft.faction].needCast
               and (not _ft.tranPhaiFcTick or _ft.tranPhaiFcTick <= g_fcFrame) then
                _ft.tranPhaiFcTick = g_fcFrame + 180
                if _ft.skillTranPhai and _ft.skillTranPhai[1] and _ft.skillTranPhai[1] > 0 then
                    NpcCastSkill(ca.id, _ft.skillTranPhai[1], _ft.skillTranPhai[2] or 20)
                else
                    for _ti = 1, getn(SimCityPhai[_ft.faction].needCast) do
                        NpcCastSkill(ca.id, SimCityPhai[_ft.faction].needCast[_ti][1], SimCityPhai[_ft.faction].needCast[_ti][2] or 1)
                    end
                end              
                local _abT = {thieulam = 16, vodang = 159, ngami = 92}
                local _abL = _abT[_ft.faction]
                if _abL then
                    if _ft.faction == "ngami" and BotDoSkill then BotDoSkill(ca.id, 92, 20, 0) end
                    if SetNpcAuraSkill then SetNpcAuraSkill(ca.id, _abL, 20) end
                end
            end
            if _fi == 0 then _fi = ca.id end
            if (ca.id - floor(ca.id / 2) * 2) == _fpar then   
                local _tgt = 0
                for _b = 1, _ncand do
                    if _b ~= _a then
                        local cb = _cand[_b]
                        if IsAttackableCamp(ca.cp, cb.cp) == 1 then
                            local _dx = ca.x - cb.x; local _dy = ca.y - cb.y
                            if _dx * _dx + _dy * _dy <= 625 then _tgt = cb.id; break end
                        end
                    end
                end
                if _tgt > 0 then
                    local sk = SimPickSkill(ca.ft)
                    if sk and sk[1] and sk[1] > 0 then
                        if SetNpcAtkSpeed then SetNpcAtkSpeed(ca.id, 250) end
                        if SetNpcCombat then SetNpcCombat(ca.id, 1, (ca.ft.skillCastBua and ca.ft.skillCastBua[1]) or 0) end  
                        if SetNpcFightTarget then SetNpcFightTarget(ca.id, _tgt) end   
                        BotDoSkill(ca.id, sk[1], sk[2] or 20, _tgt); _ncast = _ncast + 1
                    end
                end
            end
        end
        g_fcStage = 3; g_fcNm = _ncast
    end
    if SELFDEF_DIAG == 1 and NpcChat and _dbgIdx > 0 then g_fcDiagN = (g_fcDiagN or 0) + 1; if g_fcDiagN >= 6 then g_fcDiagN = 0; NpcChat(_dbgIdx, "cand="..tostring(_ncand).." cast="..tostring(_ncast).." pz="..tostring(_dbgPz).." cm="..tostring(_dbgCm).." map="..tostring(_dbgMap)) end end
end

function SimCitizen:ThongBaoBXH(nW)
    -- Collect all data
    local allPlayers = {}
    for i, fighter in self.fighterList do
        if fighter.nMapId == nW then
            tinsert(allPlayers, { i, fighter.fightingScore, "npc" })
        end
    end

    if (SimCityTongKim.playerInTK and SimCityTongKim.playerInTK[nW]) then
        for pId, data in SimCityTongKim.playerInTK[nW] do
            tinsert(allPlayers, { pId, data.score, "player" })
        end
    end

    if getn(allPlayers) > 1 then
        local maxIndex = getn(allPlayers)
        if maxIndex > 10 then
            maxIndex = 10
        end

        sort(allPlayers, _sortByScore)

        local swIdx = SubWorldID2Idx(nW)
        if BotLadderClear then BotLadderClear(swIdx) end

        Msg2Map(nW, "<color=yellow>========= B¶ng XÕp H¹ng =========<color>")
        Msg2Map(nW, "<color=yellow>=================================<color>")

        local _bxhMult = (bt_getgn_awardtimes and bt_getgn_awardtimes()) or 1   
        if isCuoiTuan and isCuoiTuan() == 1 then _bxhMult = _bxhMult * 2 end
        if _bxhMult < 1 then _bxhMult = 1 end
        for j = 1, maxIndex do
            local info = allPlayers[j]

            if info[3] == "npc" then
                local fighter = self.fighterList[info[1]]
                if fighter then
                    local phe = ""

                    if (fighter.tongkim == 1) then
                        if (fighter.tongkim_name) then
                            phe = fighter.tongkim_name
                        else
                            phe = "Kim"
                            if fighter.camp == 1 then
                                phe = "Tèng"
                            end
                        end
                    end

                    if phe == "Kim" then
                        phe = "K"
                    else
                        phe = "T"
                    end

                    local msg = "<color=white>" .. j .. " <color=yellow>[" .. phe .. "] " ..
                        SimCityTongKim.RANKS[fighter.rank] .. " <color>" ..
                        (fighter.hardsetName or SimCityNPCInfo:getName(fighter.nNpcId)) .. "<color=white> (" ..
                        allPlayers[j][2] .. ")<color>"
                    Msg2Map(nW, msg)                  
                    if BotLadderAdd and fighter.finalIndex and fighter.finalIndex > 0 then
                        BotLadderAdd(swIdx, fighter.finalIndex, allPlayers[j][2], 0, 0, _bxhMult) 
                    end
                end
            else
                local tbPlayer = SimCityTongKim.playerInTK[nW][info[1]]
                local msg = "<color=white>" .. j .. " <color=cyan>[" .. (tbPlayer.phe) .. "] " .. (tbPlayer.rank) ..
                    " <color>" .. (tbPlayer.name) .. "<color=white> (" .. (tbPlayer.score) .. ")<color>"
                Msg2Map(nW, msg)
            end
        end
        Msg2Map(nW, "<color=yellow>=================================<color>")
        if BotLadderBroadcast then BotLadderBroadcast(swIdx) end
    end
end 



-- Override parent initCharConfig
function SimCitizen:initCharConfig(config)

    config.role = config.role or "citizen"
    config.currentPointIndex = nil
    config.pathDirection = 1  -- 1 for forward, -1 for backward

    SimCore:initCharConfig(config)
end