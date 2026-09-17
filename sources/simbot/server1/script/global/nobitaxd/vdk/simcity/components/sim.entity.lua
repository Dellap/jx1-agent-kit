/*
    Public functions
*/

function execCreateChar(self, simInstance, tbNpc, isNew, goX32, goY32)
    local nListId = tbNpc.id
    local nMapIndex = SubWorldID2Idx(tbNpc.nMapId)

    if nMapIndex >= 0 then
        local nNpcIndex

        local tX32, tY32
        if tbNpc.role == "keoxe" then
            local pW, pX, pY = CallPlayerFunction(simInstance:GetPlayer(nListId), GetWorldPos)
            tX32 = pX*32
            tY32 = pY*32
        elseif tbNpc.role == "child" then
            local pW, pX32, pY32 = tbNpc.movementSys:GetParentPos(simInstance, nListId)
            tX32 = pX32
            tY32 = pY32
        else
            if (tbNpc.walkMode == "preset" or tbNpc.walkMode == "formation") and tbNpc.worldInfo.presetPaths and tbNpc.currentPathIndex then
                local path = tbNpc.worldInfo.presetPaths[tbNpc.currentPathIndex]
                if path and tbNpc.currentPointIndex and tbNpc.currentPointIndex <= getn(path) then
                    local node = getNodeInfoByNodeName(tbNpc, path[tbNpc.currentPointIndex])
                    tX32 = node.x*32
                    tY32 = node.y*32
                end
            else                
                local _spool = (tbNpc.daTau == 1 and tbNpc.worldInfo.daTauNodes and getn(tbNpc.worldInfo.daTauNodes) > 0) and tbNpc.worldInfo.daTauNodes or tbNpc.worldInfo.attractionNodes  
                if tbNpc.stall == 1 and _spool and getn(_spool) > 0 then
                    tbNpc.nPosId = _spool[random(1, getn(_spool))]
                end
                local node = getNodeInfoByNodeName(tbNpc, tbNpc.nPosId)
                tX32 = node.x*32
                tY32 = node.y*32
                if tbNpc.stall == 1 then                    
                    tX32 = tX32 + random(-12, 12) * 32
                    tY32 = tY32 + random(-12, 12) * 32
                end
            end
        end

        if not tX32 or not tY32 then            
            return 0
        end

        if goX32 and goY32 and goX32 > 0 and goY32 > 0 then
            tX32 = goX32
            tY32 = goY32
        end

        local name = tbNpc.szName or SimCityNPCInfo:getName(tbNpc.nNpcId)

        if (tbNpc.tongkim == 1) then
            if (tbNpc.tongkim_name) then
                name = tbNpc.tongkim_name
            else
                name = "Kim"
                if tbNpc.camp == 1 then
                    name = "Tèng"
                end
            end
            name = name .. " " .. SimCityTongKim.RANKS[tbNpc.rank]
        end

        if (tbNpc.hardsetName) then
			name = tbNpc.hardsetName     
		end

        local _spawnLv = (tbNpc.level and tbNpc.level >= 1 and tbNpc.level <= 119) and tbNpc.level or 95
        nNpcIndex = AddNpcEx(tbNpc.nNpcId, _spawnLv, tbNpc.series, nMapIndex, tX32, tY32, 1, name, 0)

        if nNpcIndex > 0 then
            local kind = GetNpcKind(nNpcIndex)
            if kind ~= 0 then
                DelNpcSafe(nNpcIndex)
            else
                tbNpc.szName = GetNpcName(nNpcIndex)
                tbNpc.finalIndex = nNpcIndex
                tbNpc.isDead = 0
                tbNpc.lastPos = {
                    nX32 = tX32,
                    nY32 = tY32
                }

                -- Otherwise choose side
				
                SetNpcCurCamp(nNpcIndex, tbNpc.camp)

                SetNpcActiveRegion(nNpcIndex, 1)
                SetNpcParam(nNpcIndex, PARAM_LIST_ID, tbNpc.id)
                if tbNpc.role == "keoxe" then
                    SetNpcParam(nNpcIndex, PARAM_TYPE, 2)
                else
                    SetNpcParam(nNpcIndex, PARAM_TYPE, 1)
                end

                -- Indicate SIM npc
                SetNpcParam(nNpcIndex, 4, 1)

                -- SimCity Helper?
                if tbNpc.mode == "tieuthiep" then
                    SetNpcScript(nNpcIndex, "\\script\\global\\nobitaxd\\vdk\\simcity\\controllers\\tieuthiep.lua")
                else
                    SetNpcScript(nNpcIndex, "\\script\\global\\nobitaxd\\vdk\\simcity\\components\\sim.timer.lua")
                end
			
                -- Ngoai trang?
                if (tbNpc.ngoaitrang and tbNpc.ngoaitrang == 1) then
                    SimCityNgoaiTrang:makeup(tbNpc, nNpcIndex)
                end
                
                if tbNpc.faction and SetBotFaction then
                    local _f2i = {thieulam=1, thienvuong=2, duongmon=3, ngudoc=4, ngami=5, thuyyen=6, thiennhan=7, caibang=8, vodang=9, conlon=10}
                    local _fi = _f2i[tbNpc.faction]
                    if _fi then SetBotFaction(nNpcIndex, _fi) end
                end
               
                if tbNpc.skillCastBua and SetBotWeaponView then
                    local _ak = {[342]=1, [339]=2, [302]=3}  
                    local _wc = _ak[tbNpc.skillCastBua[1]]
                    if _wc then SetBotWeaponView(nNpcIndex, _wc) end
                end
				
				if tbNpc.stall == 1 and NpcSit then
                    NpcSit(nNpcIndex)
                    if SetNpcStall then SetNpcStall(nNpcIndex, 1) end   
                    if tbNpc.daTau == 1 and SetBotStallTier then SetBotStallTier(nNpcIndex, 0, 1) end   
                end
				
				if tbNpc.tongkim == 1 and SetNpcTitle then
                    SetNpcTitle(nNpcIndex, tbNpc.rank or 1)
                end
				
                local nX32, nY32, nMapIndex = GetNpcPos(nNpcIndex)
                tbNpc.lastFightPos = {
                    X = nX32,
                    Y = nY32,
                    W = nMapIndex
                }
                tbNpc.lastPos = {
                    nX32 = nX32,
                    nY32 = nY32
                }

                if tbNpc.isFighting == 1 then
                    SetNpcKind(nNpcIndex, 0)
                else
                    SetNpcKind(nNpcIndex, tbNpc.kind or 0)
                end
              
                if (tbNpc.isFighting == 0) then
                    tbNpc.fightSys:SetFightState(tbNpc, 0)
                end
        
                if tbNpc.maxHP then
                    NPCINFO_SetNpcCurrentMaxLife(nNpcIndex, tbNpc.maxHP)
                end
                
                if SetNpcLevel then SetNpcLevel(nNpcIndex, 95) end                
                if SetNpcAtkSpeed then SetNpcAtkSpeed(nNpcIndex, 250) end

                -- Life?
                if tbNpc.lastHP then
                    NPCINFO_SetNpcCurrentLife(nNpcIndex, tbNpc.lastHP)
                elseif tbNpc.maxHP then
                    NPCINFO_SetNpcCurrentLife(nNpcIndex, tbNpc.maxHP)
                end

                tbNpc.fightSys:BuffChar(simInstance, tbNpc)
                return tbNpc.id
            end
        end

        return 0
    end
    return 0
end

SimEntity = {}

SimEntity.Base = {
}

SimEntity.Citizen = {
    CreateChar = execCreateChar,


    Respawn = function(self, simInstance, tbNpc, code, reason)
        local nListId = tbNpc.id
        local isAllDead = code == 1 and 1 or 0
        local nX32, nY32, nMapIndex = GetNpcPos(tbNpc.finalIndex) 
    
        if code == 4 or code == 2 then
            nX32 = 0
            nY32 = 0
            tbNpc.movementSys:resetPos(simInstance, nListId)

            -- otherwise reset
        elseif isAllDead == 1 and tbNpc.role == "child" then
            nX32 = tbNpc.parentAppointPos[1]*32
            nY32 = tbNpc.parentAppointPos[2]*32
        elseif (isAllDead == 1 and tbNpc.resetPosWhenRevive and tbNpc.resetPosWhenRevive == 1) then
            tbNpc.movementSys:resetPos(simInstance, nListId)
            nX32 = 0
            nY32 = 0
        elseif (isAllDead == 1 and tbNpc.lastPos ~= nil) then
            nX32 = tbNpc.lastPos.nX32
            nY32 = tbNpc.lastPos.nY32
        else
            tbNpc.lastPos = {
                nX32 = nX32,
                nY32 = nY32
            }
        end

        tbNpc.tick_checklag = nil
        tbNpc.lastHP = NPCINFO_GetNpcCurrentLife(tbNpc.finalIndex)
        if (isAllDead == 1) then
            tbNpc.lastHP = nil
        end

        -- Normal respawn ? Can del NPC
        DelNpcSafe(tbNpc.finalIndex) 
        self:CreateChar(simInstance, tbNpc, 0, nX32, nY32)
    end,
    
    OnDeath = function(self, simInstance, tbNpc, nNpcIndex, attackerIndex)        
        if tbNpc == nil then
            return 0
        end

        tbNpc.funSys:OnDeath(simInstance, tbNpc, nNpcIndex, attackerIndex)    

        if tbNpc.role == "citizen" and tbNpc.children then
            local child

            for i = 1, getn(tbNpc.children) do
                local each = simInstance:Get(tbNpc.children[i])
                if each and each.isDead ~= 1 then
                    child = each

                    local tmp = {
                        finalIndex = tbNpc.finalIndex,
                        szName = tbNpc.szName,
                        nNpcId = tbNpc.nNpcId,
                        series = tbNpc.series,
                        lastHP = tbNpc.lastHP,
                        isFighting = tbNpc.isFighting,
                    }

                    tbNpc.finalIndex = child.finalIndex
                    tbNpc.szName = child.szName
                    tbNpc.nNpcId = child.nNpcId
                    tbNpc.series = child.series
                    tbNpc.lastHP = child.lastHP
                    tbNpc.isFighting = child.isFighting


                    child.finalIndex = tmp.finalIndex
                    child.szName = tmp.szName
                    child.series = tmp.series
                    child.lastHP = tmp.lastHP
                    child.isFighting = tmp.isFighting

                    SetNpcParam(tbNpc.finalIndex, PARAM_LIST_ID, tbNpc.id)
                    SetNpcParam(child.finalIndex, PARAM_LIST_ID, child.id)    

                    child.isDead = 1

                    return 1
                end
            end
        end

        tbNpc.isDead = 1
        tbNpc.finalIndex = nil

        -- If child dead do nothing, let parent do it
        if tbNpc.role == "child" then
            return 1
        end

        local doRespawn = 0

        if tbNpc.isFighting == 1 and tbNpc.tick_breath > tbNpc.tick_canswitch then
            doRespawn = 1
        end


        -- Is every one dead?
        if (doRespawn == 1 or tbNpc.isDead == 1) then
            tbNpc.fightingScore = ceil(tbNpc.fightingScore * 0.7)
            SimCityTongKim:updateRank(tbNpc)


            -- No revive? Do removal
            if tbNpc.noRevive == 1 then
                if tbNpc.role == "citizen" then
                    simInstance:Remove(tbNpc.id)
                end
                return 1
            end
            -- Do revive? Reset and leave fight
            tbNpc.fightSys:LeaveFight(simInstance, tbNpc, 1, "die toan bo")
        end
    end
}

SimEntity.KeoXe = {
    CreateChar = execCreateChar,
    Respawn = function(self, simInstance, tbNpc, code, reason)

        local nListId = tbNpc.id
        -- code: 0: con nv con song 1: da chet toan bo 2: keo xe qua map khac 3: chuyen sang chien dau 4: bi lag dung 1 cho nay gio ko di duoc


        local isAllDead = code == 1 and 1 or 0

        local nX32, nY32, nMapIndex = GetNpcPos(tbNpc.finalIndex)
 

        -- 4 = bi lag? 2= qua map khac, tim cho khac hien len nao
        if code == 4 or code == 2 then
            nX32 = 0
            nY32 = 0
            tbNpc.movementSys:resetPos(simInstance, nListId)

            -- otherwise reset
        elseif isAllDead == 1 then
            nX32 = tbNpc.parentAppointPos[1]*32
            nY32 = tbNpc.parentAppointPos[2]*32
        else
            tbNpc.lastPos = {
                nX32 = nX32,
                nY32 = nY32
            }
        end

        tbNpc.tick_checklag = nil
        tbNpc.lastHP = NPCINFO_GetNpcCurrentLife(tbNpc.finalIndex)
        if (isAllDead == 1) then
            tbNpc.lastHP = nil
        end


        -- Normal respawn ? Can del NPC
        DelNpcSafe(tbNpc.finalIndex) 
        self:CreateChar(simInstance, tbNpc, 0, nX32, nY32)
    end,
    OnDeath = function(self, simInstance, tbNpc, nNpcIndex, attackerIndex)
        if tbNpc == nil then
            return 0
        end

        tbNpc.funSys:OnDeath(simInstance, tbNpc, nNpcIndex, attackerIndex)
    
        tbNpc.isDead = 1
        tbNpc.finalIndex = nil
    

        local doRespawn = 0

        if tbNpc.isFighting == 1 and tbNpc.tick_breath > tbNpc.tick_canswitch then
            doRespawn = 1
        end


        -- Is every one dead?
        if (doRespawn == 1 or tbNpc.isDead == 1) then
            tbNpc.fightingScore = ceil(tbNpc.fightingScore * 0.7)
            SimCityTongKim:updateRank(tbNpc)


            -- No revive? Do removal
            if tbNpc.noRevive == 1 then 
                return 1
            end
            -- Do revive? Reset and leave fight
            tbNpc.fightSys:LeaveFight(simInstance, tbNpc, 1, "die toan bo")
        end
    end
} 

 

-- Helper function to create a movement behavior by name
function SimEntitySys(tbNpc)     
    if tbNpc.role == "keoxe" then
        return SimEntity.KeoXe
    end
    return SimEntity.Citizen
end