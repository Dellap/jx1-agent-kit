Include("\\script\\global\\nobitaxd\\vdk\\simcity\\components\\sim.core.lua")
SimTheoSau = objCopy(SimCore)

SimTheoSau.fighterList = {}
SimTheoSau.counter = 1
SimTheoSau.removedIds = {}

g_KeoXe_BangRanks = g_KeoXe_BangRanks or { "Tr­ëng l·o", "§­êng Chñ", "§Ö Tö" }

function SimTheoSau:New(fighter)

    -- Setup minimum config
    self:initCharConfig(fighter)

    local nListId
    if getn(self.removedIds) > 0 then
        nListId = tremove(self.removedIds)
    else
        nListId = self.counter
        self.counter = self.counter + 1
    end

    local tbNpc = {
        id = nListId     
    }
 
    for k, v in fighter do
        tbNpc[k] = v
    end


    self.fighterList[nListId] = tbNpc

    -- Setup walk paths
    if tbNpc.movementSys:resetPos(self, nListId) == 0 then
        return nil
    end

    -- Bugfix series
    tbNpc.isPlayerFighting = CallPlayerFunction(tbNpc.playerID, GetFightState)

    -- Create the character on screen
    tbNpc.entitySys:CreateChar(self, tbNpc, 1, tbNpc.goX32, tbNpc.goY32)
    
    if (SetNpcBang and tbNpc.role == "keoxe" and tbNpc.finalIndex and tbNpc.finalIndex > 0
        and tbNpc.playerID and tbNpc.playerID ~= ""
        and self.m_TTDCStt and self.m_TTDCStt.m_IsRunning == 1) then   -- CHI hien bang trong mission sevencity
        local pIdxBang = SearchPlayer(tbNpc.playerID)
        if (pIdxBang and pIdxBang > 0) then
            local szTongBang = CallPlayerFunction(pIdxBang, GetTongName)
            if (szTongBang and szTongBang ~= "") then
                if (g_KeoXe_BangRanks and getn(g_KeoXe_BangRanks) > 0) then
                    szTongBang = format("%s-[%s]", szTongBang, g_KeoXe_BangRanks[random(1, getn(g_KeoXe_BangRanks))])
                end
                tbNpc.bangKeoxe = szTongBang   -- luu de re-broadcast dinh ky (OnTimer)
                SetNpcBang(tbNpc.finalIndex, szTongBang)
            end
        end
    end
 
    return nListId
end
 


-- For keo xe
function SimTheoSau:GetPlayer(nListId)
    local tbNpc = self.fighterList[nListId]
    if tbNpc.playerID == "" then
        return 0
    end
    return SearchPlayer(tbNpc.playerID)
end

-- Override parent initCharConfig
function SimTheoSau:initCharConfig(config)
    config.role = "keoxe"
    config.playerID = config.playerID or "" -- dang theo sau ai do
    config.isPlayerFighting = 1
    
    SimCore:initCharConfig(config)
end